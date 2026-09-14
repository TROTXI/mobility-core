import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trotxi_client/trotxi_client.dart';

/// Why position sharing is not running.
enum PositionBlock {
  /// The driver has not been asked yet.
  notRequested,

  /// They said no. Recoverable by asking again.
  denied,

  /// They said no permanently, so only device settings can undo it.
  deniedForever,

  /// Location is switched off on the device entirely.
  servicesOff,

  /// A native check or stream failed; do not report this as permission granted.
  unavailable,
}

enum PositionSharing {
  idle,
  checking,
  waiting,
  live,
  weak,
  stale,
  failed,
  blocked,
}

/// Publishes the active trip's position while the app is in the foreground.
///
/// Owned by the signed-in trip lifecycle, not by a tab. Upload failures are
/// represented as state instead of taking the driver's working screen down.
class PositionPublisher extends ChangeNotifier {
  PositionPublisher({
    required this._client,
    DateTime Function()? now,
    this.freshFor = const Duration(minutes: 2),
    this.weakAccuracyMeters = 50,
  }) : _now = now ?? DateTime.now;

  final TrotxiApiClient _client;
  final DateTime Function() _now;
  final Duration freshFor;

  /// Accuracy worse than this is acknowledged but not described as precise.
  /// The page-14 reference shows a ±65m weak fix; 50m keeps that state honest.
  final double weakAccuracyMeters;
  StreamSubscription<Position>? _subscription;
  String? _runId;
  int _generation = 0;
  int _healthRevision = 0;
  bool _disposed = false;
  bool _uploading = false;
  Position? _pending;
  Timer? _expiry;
  CancelToken? _cancel;
  PositionSharing _state = PositionSharing.idle;
  PositionBlock? _block;
  DateTime? _lastAcknowledgedAt;
  double? _lastAccuracyMeters;

  PositionSharing get state => _state;
  PositionBlock? get block => _block;
  DateTime? get lastAcknowledgedAt => _lastAcknowledgedAt;
  double? get lastAccuracyMeters => _lastAccuracyMeters;

  /// The run currently being published for, or null when idle.
  String? get runId => _runId;
  bool get isPublishing => _subscription != null;

  /// Start publishing only with existing location access. Permission prompts
  /// belong to device readiness, not a side effect of opening an active run.
  ///
  /// @param runId - the run to attach fixes to.
  /// @returns null once publishing, or why it could not start.
  Future<PositionBlock?> start(String runId) async {
    if (_disposed) return PositionBlock.notRequested;
    if (_runId == runId &&
        (_subscription != null || _state == PositionSharing.checking)) {
      return _block;
    }
    final generation = ++_generation;
    final previous = _subscription;
    _subscription = null;
    _runId = runId;
    _cancel?.cancel();
    _cancel = CancelToken();
    _expiry?.cancel();
    _pending = null;
    _uploading = false;
    _lastAcknowledgedAt = null;
    _lastAccuracyMeters = null;
    _block = null;
    _set(PositionSharing.checking);
    try {
      await previous?.cancel();
      if (generation != _generation) return PositionBlock.notRequested;
      final servicesEnabled = await Geolocator.isLocationServiceEnabled();
      if (generation != _generation) return PositionBlock.notRequested;
      if (!servicesEnabled) {
        return _blocked(PositionBlock.servicesOff);
      }

      final permission = await Geolocator.checkPermission();
      // Leaving the run while a native check is pending must not start a stream
      // after dispose has already stopped this publisher.
      if (generation != _generation) return PositionBlock.notRequested;
      if (permission == LocationPermission.deniedForever) {
        return _blocked(PositionBlock.deniedForever);
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return _blocked(PositionBlock.denied);
      }

      _set(PositionSharing.waiting);
      _subscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              // Distance rather than time: a bus held at an interchange should not
              // spend the driver's data reporting the same corner every few
              // seconds, and one moving reports often enough on its own.
              distanceFilter: 25,
            ),
          ).listen(
            (position) {
              if (generation != _generation) return;
              _pending = position;
              if (!_uploading) unawaited(_drain(generation));
            },
            onError: (Object _) {
              if (generation != _generation) return;
              _healthRevision++;
              _pending = null;
              _expiry?.cancel();
              _set(PositionSharing.stale);
            },
            onDone: () {
              if (generation != _generation) return;
              _healthRevision++;
              _pending = null;
              _subscription = null;
              _expiry?.cancel();
              _set(PositionSharing.stale);
            },
          );
      return null;
    } catch (_) {
      if (generation != _generation) return PositionBlock.notRequested;
      return _blocked(PositionBlock.unavailable);
    }
  }

  /// Stop publishing.
  Future<void> stop() async {
    _generation++;
    final subscription = _subscription;
    _subscription = null;
    _runId = null;
    _cancel?.cancel();
    _expiry?.cancel();
    _pending = null;
    _uploading = false;
    _block = null;
    _lastAcknowledgedAt = null;
    _lastAccuracyMeters = null;
    _set(PositionSharing.idle);
    await subscription?.cancel();
  }

  /// Re-run device checks and replace the current native stream for this run.
  ///
  /// Calling [start] for the same active stream is deliberately idempotent, so
  /// the page-14 retry action needs an explicit restart rather than a button
  /// that appears to work while doing nothing.
  Future<PositionBlock?> retry() async {
    final runId = _runId;
    if (runId == null) return PositionBlock.notRequested;
    await stop();
    return start(runId);
  }

  PositionBlock _blocked(PositionBlock block) {
    _block = block;
    _set(PositionSharing.blocked);
    return block;
  }

  void _set(PositionSharing state) {
    _state = state;
    if (!_disposed) notifyListeners();
  }

  /// One request at a time, coalescing newer fixes in memory. This is not a
  /// durable offline queue: failed fixes are not replayed or labelled queued.
  Future<void> _drain(int generation) async {
    _uploading = true;
    try {
      while (generation == _generation && _pending != null && _runId != null) {
        final position = _pending!;
        _pending = null;
        final age = _now().difference(position.timestamp);
        if (age > freshFor || age.isNegative) {
          _set(PositionSharing.stale);
          continue;
        }
        try {
          final health = _healthRevision;
          final response = await _client.getMobilityApi().tripsIdPositionPost(
            id: _runId!,
            cancelToken: _cancel,
            tripsIdPositionPostRequest: TripsIdPositionPostRequest(
              (b) => b
                ..latitude = position.latitude
                ..longitude = position.longitude,
            ),
          );
          if (generation != _generation) return;
          if (health != _healthRevision) continue;
          final receipt = response.data;
          if (receipt == null ||
              receipt.tripId != _runId ||
              receipt.position.latitude != position.latitude ||
              receipt.position.longitude != position.longitude) {
            _expiry?.cancel();
            _set(PositionSharing.failed);
            continue;
          }
          final remaining = freshFor - _now().difference(position.timestamp);
          _expiry?.cancel();
          if (remaining <= Duration.zero) {
            _set(PositionSharing.stale);
          } else {
            _lastAcknowledgedAt = _now();
            _lastAccuracyMeters = position.accuracy;
            _set(
              position.accuracy > weakAccuracyMeters
                  ? PositionSharing.weak
                  : PositionSharing.live,
            );
            _expiry = Timer(remaining, () {
              if (generation == _generation) _set(PositionSharing.stale);
            });
          }
        } on DioException {
          if (generation != _generation) return;
          _expiry?.cancel();
          _set(PositionSharing.failed);
        }
      }
    } finally {
      if (generation == _generation) _uploading = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(stop());
    super.dispose();
  }
}
