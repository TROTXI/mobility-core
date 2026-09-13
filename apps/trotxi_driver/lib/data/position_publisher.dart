import 'dart:async';

import 'package:dio/dio.dart';
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
}

/// Publishes the vehicle's position while a run is open (#25).
///
/// While in use, never in the background. The app shares where the BUS is so
/// riders can see it approaching, and it only needs that while a driver has a
/// run open. Background location would be tracking a person's whereabouts off
/// shift, which is not something this product needs or should hold.
///
/// Failures are swallowed on purpose. A fix that does not reach the server
/// costs riders a stale marker; an exception thrown up into the run screen
/// would cost the driver the screen they are working from.
class PositionPublisher {
  PositionPublisher({required this._client});

  final TrotxiApiClient _client;
  StreamSubscription<Position>? _subscription;
  String? _runId;
  int _generation = 0;

  /// The run currently being published for, or null when idle.
  String? get runId => _runId;
  bool get isPublishing => _subscription != null;

  /// Start publishing only with existing location access. Permission prompts
  /// belong to device readiness, not a side effect of opening an active run.
  ///
  /// @param runId - the run to attach fixes to.
  /// @returns null once publishing, or why it could not start.
  Future<PositionBlock?> start(String runId) async {
    final generation = ++_generation;
    final previous = _subscription;
    _subscription = null;
    _runId = null;
    await previous?.cancel();
    if (generation != _generation) return PositionBlock.notRequested;
    final servicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (generation != _generation) return PositionBlock.notRequested;
    if (!servicesEnabled) {
      return PositionBlock.servicesOff;
    }

    final permission = await Geolocator.checkPermission();
    // Leaving the run while a native check is pending must not start a stream
    // after dispose has already stopped this publisher.
    if (generation != _generation) return PositionBlock.notRequested;
    if (permission == LocationPermission.deniedForever) {
      return PositionBlock.deniedForever;
    }
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return PositionBlock.denied;
    }

    _runId = runId;
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
          _publish,
          // A stream error is a dropped GPS lock, not a reason to tear down the
          // run. The next fix re-establishes it.
          onError: (Object _) {},
        );
    return null;
  }

  /// Stop publishing.
  Future<void> stop() async {
    _generation++;
    final subscription = _subscription;
    _subscription = null;
    _runId = null;
    await subscription?.cancel();
  }

  Future<void> _publish(Position position) async {
    final runId = _runId;
    if (runId == null) return;
    try {
      await _client.getMobilityApi().tripsIdPositionPost(
        id: runId,
        tripsIdPositionPostRequest: TripsIdPositionPostRequest(
          (b) => b
            ..latitude = position.latitude
            ..longitude = position.longitude,
        ),
      );
    } on DioException {
      // Dropped. Riders see a slightly older marker; the driver sees nothing,
      // which is correct, because there is nothing for them to do about it.
    }
  }
}
