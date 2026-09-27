import 'dart:async';

import 'package:dio/dio.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'position_queue.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';

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

/// Publishes an active trip through a native location session, including while
/// the app is backgrounded. This is not a killed-process/reboot tracking agent.
///
/// Owned by the signed-in trip lifecycle, not by a tab. Upload failures are
/// represented as state instead of taking the driver's working screen down.
class PositionPublisher extends ChangeNotifier {
  /// Platform settings are explicit so native background behaviour is tested
  /// independently of network and permission-channel mocks.
  static LocationSettings trackingSettings(TargetPlatform platform) {
    if (platform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Trotxi trip location sharing',
          notificationText:
              'Sharing bus location during your active trip. Open Trotxi to finish the trip or sign out.',
          notificationChannelName: 'Active trip tracking',
          color: AppPrimitiveColors.action,
          notificationIcon: AndroidResource(name: 'ic_trip_tracking'),
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    }
    if (platform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        activityType: ActivityType.automotiveNavigation,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
  }

  PositionPublisher({
    required this._client,
    DateTime Function()? now,
    this.freshFor = const Duration(seconds: 30),
    this.weakAccuracyMeters = 50,
    PositionQueue? queue,
    this.captureEvery = const Duration(seconds: 5),
  }) : _now = now ?? DateTime.now,
       queue = queue ?? PositionQueue();

  final PositionQueue queue;
  final Duration captureEvery;
  Timer? _captureTimer;
  bool _capturing = false;
  bool _finishing = false;
  DateTime? _lastCaptured;
  Future<void> _recording = Future.value();
  int get queuedFixes => queue.rows.length;
  int get expiredFixes => queue.expiredFixes;
  int get rejectedFixes => queue.rejectedFixes;
  String? uploadError;
  Future<void> acknowledgeRejections() async {
    await queue.acknowledgeRejections();
    queueError = null;
    if (!_disposed) notifyListeners();
  }

  Future<void> acknowledgeExpiry() async {
    await queue.acknowledgeExpiry();
    if (!_disposed) notifyListeners();
  }

  String? queueError;
  String? _boundOwner;

  Future<void> bindOwner(String? owner) async {
    await stop();
    await _recording;
    try {
      await queue.bind(owner);
      if (owner != _boundOwner) {
        queueError = null;
        uploadError = null;
        _refusedRunId = null;
        _retryNotBefore = null;
        _boundOwner = owner;
      }
    } catch (_) {
      queueError =
          'Saved GPS positions could not be read safely. Contact operations before continuing.';
      _set(PositionSharing.failed);
      rethrow;
    }
    if (!_disposed) notifyListeners();
  }

  /// Get a fresh native reading even when stationary. Do not manufacture a new
  /// timestamp for the last position; the capture timestamp comes from GPS.
  Future<void> captureNow() async {
    if (_disposed ||
        _capturing ||
        _finishing ||
        _runId == null ||
        _subscription == null) {
      return;
    }
    final generation = _generation;
    _capturing = true;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );
      if (generation == _generation) await _record(position, generation);
    } catch (_) {
      if (generation == _generation) _set(PositionSharing.stale);
    } finally {
      _capturing = false;
    }
  }

  Future<void> _record(Position position, int generation) {
    final task = _recording.then((_) async {
      if (generation != _generation || _finishing) return;
      final age = _now().difference(position.timestamp);
      if (age > freshFor || age.isNegative) {
        _set(PositionSharing.stale);
        return;
      }
      if (_lastCaptured != null &&
          position.timestamp.difference(_lastCaptured!) < captureEvery) {
        return;
      }
      final run = _runId!;
      try {
        await queue.add({
          'tripId': run,
          'clientFixId': const Uuid().v4(),
          'capturedAt': position.timestamp.toUtc().toIso8601String(),
          'latitude': position.latitude,
          'longitude': position.longitude,
          if (position.accuracy.isFinite && position.accuracy >= 0)
            'accuracyMeters': position.accuracy,
        });
        if (generation != _generation) return;
        _lastCaptured = position.timestamp;
        queueError = null;
        unawaited(_drain(generation));
      } on PositionQueueFull {
        if (generation == _generation) {
          queueError =
              'GPS storage is full. Saved positions must upload or be reviewed before new positions can be saved.';
          _set(PositionSharing.failed);
          unawaited(_drain(generation));
        }
      } catch (_) {
        if (generation == _generation) {
          queueError =
              'Device storage could not save this position. Retry or contact operations.';
          _set(PositionSharing.failed);
        }
      }
    });
    _recording = task;
    return task;
  }

  /// Freeze capture, upload all already captured fixes, then permit completion.
  /// A timeout cancels delivery, keeps the stable IDs and leaves the run active.
  Future<void> flushBeforeComplete(String tripId) async {
    if (rejectedFixes > 0) {
      throw const ApiException(
        409,
        'Some saved GPS positions were refused. Review Location & connectivity before ending this trip.',
      );
    }
    if (expiredFixes > 0) {
      throw const ApiException(
        409,
        'Some saved GPS positions expired. Review the notice under Location & connectivity before ending this trip.',
      );
    }
    if (_runId != tripId) {
      if (expiredFixes > 0 || queue.rows.any((r) => r['tripId'] == tripId)) {
        throw const ApiException(
          409,
          'Resume location sharing to upload saved positions before ending this trip.',
        );
      }
      return;
    }
    _finishing = true;
    try {
      await _recording;
      final deadline = DateTime.now().add(const Duration(seconds: 12));
      while (_uploading && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      if (!_uploading) {
        await _drain(_generation).timeout(const Duration(seconds: 10));
      }
      if (expiredFixes > 0) {
        throw const ApiException(
          409,
          'Saved positions expired. Review Location & connectivity before ending this trip.',
        );
      }
      if (queue.rows.any((r) => r['tripId'] == tripId)) {
        throw const ApiException(
          409,
          'Saved GPS positions still need uploading. Check your connection and retry ending the trip.',
        );
      }
    } on TimeoutException {
      _finishing = false;
      _cancel?.cancel();
      _cancel = CancelToken();
      throw const ApiException(
        409,
        'GPS upload timed out. Your positions are saved; reconnect and retry.',
      );
    } catch (_) {
      _finishing = false;
      rethrow;
    }
  }

  void resumeAfterCompletionFailure() => _finishing = false;

  final DriverApi _client;
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
  bool _drainRequested = false;
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
  String? _refusedRunId;
  DateTime? _retryNotBefore;

  /// Start publishing only with existing location access. Permission prompts
  /// belong to device readiness, not a side effect of opening an active run.
  ///
  /// @param runId - the run to attach fixes to.
  /// @returns null once publishing, or why it could not start.
  Future<PositionBlock?> start(String runId) async {
    if (_disposed) return PositionBlock.notRequested;
    if (_refusedRunId == runId) return PositionBlock.unavailable;
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
    _captureTimer?.cancel();
    _finishing = false;
    _lastCaptured = null;
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
      // Permission checks can finish after the driver locks the phone. Android
      // does not allow creating a while-in-use service from that state.
      final lifecycle = WidgetsBinding.instance.lifecycleState;
      if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
        return _blocked(PositionBlock.notRequested);
      }
      _subscription =
          Geolocator.getPositionStream(
            locationSettings: trackingSettings(defaultTargetPlatform),
          ).listen(
            (position) {
              if (generation != _generation) return;
              unawaited(_record(position, generation));
            },
            onError: (Object _) {
              if (generation != _generation) return;
              _healthRevision++;
              _expiry?.cancel();
              _set(PositionSharing.stale);
            },
            onDone: () {
              if (generation != _generation) return;
              _healthRevision++;
              _subscription = null;
              _expiry?.cancel();
              _set(PositionSharing.stale);
            },
          );
      _captureTimer = Timer.periodic(captureEvery, (_) {
        unawaited(captureNow());
        if (!_uploading) unawaited(_drain(generation));
      });
      if (queue.rows.isNotEmpty) unawaited(_drain(generation));
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
    _captureTimer?.cancel();
    _finishing = false;
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
    final runId = _runId ?? _refusedRunId;
    if (runId == null) return PositionBlock.notRequested;
    await stop();
    _refusedRunId = null;
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

  /// One request at a time. A failed or uncertain delivery retains its identity.
  Future<void> _drain(int generation) async {
    if (generation != _generation) return;
    final retryAt = _retryNotBefore;
    if (retryAt != null && _now().isBefore(retryAt)) return;
    if (_uploading) {
      _drainRequested = true;
      return;
    }
    _drainRequested = false;
    _uploading = true;
    try {
      await queue.pruneExpired();
      if (generation != _generation) return;
      if (expiredFixes > 0) _set(PositionSharing.stale);
      while (generation == _generation && _runId != null) {
        final saved = queue.rows
            .where((r) => r['tripId'] == _runId && r['rejected'] == null)
            .firstOrNull;
        if (saved == null) break;
        final timestamp = DateTime.parse(saved['capturedAt'] as String);
        try {
          final health = _healthRevision;
          final fixId = saved['clientFixId'] as String;
          final response = await _client.post(
            '/v1/driver/trips/${Uri.encodeComponent(_runId!)}/positions',
            wire.PositionReceiptResponse.serializer,
            command: false,
            cancelToken: _cancel,
            body: {...saved}..remove('tripId'),
          );
          if (generation != _generation) return;
          final receipt = response.data;
          if (receipt.clientFixId != fixId ||
              !receipt.capturedAt.isAtSameMomentAs(timestamp)) {
            _expiry?.cancel();
            _set(PositionSharing.failed);
            break;
          }
          await queue.acknowledge(fixId);
          uploadError = null;
          queueError = null;
          if (generation != _generation) return;
          if (health != _healthRevision) continue;
          if (!receipt.acceptedForLive) {
            _expiry?.cancel();
            _set(PositionSharing.stale);
            continue;
          }
          final remaining = freshFor - _now().difference(timestamp);
          _expiry?.cancel();
          if (remaining <= Duration.zero) {
            _set(PositionSharing.stale);
          } else {
            _lastAcknowledgedAt = _now();
            _lastAccuracyMeters = (saved['accuracyMeters'] as num?)?.toDouble();
            _set(
              (_lastAccuracyMeters ?? double.infinity) > weakAccuracyMeters
                  ? PositionSharing.weak
                  : PositionSharing.live,
            );
            _expiry = Timer(remaining, () {
              if (generation == _generation) _set(PositionSharing.stale);
            });
          }
        } on RateLimitException catch (error) {
          if (generation != _generation) return;
          _retryNotBefore = _now().add(error.retryAfter);
          uploadError =
              'GPS uploads are rate-limited. Retry after ${error.retryAfter.inSeconds} seconds.';
          _expiry?.cancel();
          _set(PositionSharing.failed);
          break;
        } on UnauthorizedException {
          if (generation != _generation) return;
          _refusedRunId = _runId;
          await stop();
          return;
        } on ApiException catch (error) {
          if (generation != _generation) return;
          const rejectedReasons = {
            'capture_before_start': 'A saved position predates the trip start.',
            'capture_too_old':
                'A saved position is outside the accepted upload window.',
            'invalid_capture_time':
                'A saved position has an invalid capture time.',
            'fix_payload_conflict':
                'A saved position identity conflicts with an existing receipt.',
          };
          uploadError =
              rejectedReasons[error.code] ??
              'Trotxi refused a GPS upload (HTTP ${error.statusCode}). Retry or contact operations.';
          if (error.code == 'collection_session_expired') {
            // The API closed this run's collection window. Retrying these
            // rows cannot recover them; keep them for explicit local review.
            uploadError =
                'This trip’s GPS collection window has expired. Review the refused saved positions before ending it.';
            for (final row in queue.rows.where(
              (row) => row['tripId'] == _runId && row['rejected'] == null,
            )) {
              await queue.reject(row['clientFixId'] as String, error.code!);
            }
          }
          if (rejectedReasons.containsKey(error.code)) {
            await queue.reject(saved['clientFixId'] as String, error.code!);
            _set(PositionSharing.failed);
            continue;
          }
          if (error.statusCode == 403 ||
              error.statusCode == 404 ||
              error.code == 'trip_not_active' ||
              error.code == 'collection_session_expired') {
            _refusedRunId = _runId;
            await stop();
            return;
          }
          _expiry?.cancel();
          _set(PositionSharing.failed);
          break;
        } catch (_) {
          if (generation != _generation) return;
          uploadError =
              'GPS upload failed or its receipt could not be verified. Check your connection and retry.';
          _expiry?.cancel();
          _set(PositionSharing.failed);
          break;
        }
      }
    } catch (_) {
      if (generation == _generation) {
        queueError =
            'Saved positions could not be read or updated. Please retry.';
        _set(PositionSharing.failed);
      }
    } finally {
      if (generation == _generation) {
        _uploading = false;
        // An enqueue can finish while the previous drain is exiting. Do not
        // lose that wake-up; failure without another enqueue waits for retry.
        if (_drainRequested) unawaited(_drain(generation));
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(stop());
    super.dispose();
  }
}
