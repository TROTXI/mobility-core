import 'commuter_data_client.dart';
import 'trotxi_client_next.dart';

/// Age comes from the server plus monotonic elapsed time, never the rider's
/// wall clock. Count request latency conservatively rather than extending TTL.
class CommuterTripSnapshot {
  CommuterTripSnapshot(
      {required this.trip,
      required this.live,
      required this.elapsed,
      this.geometry,
      this.stops = const [],
      this.routeName,
      this.mapWarning});
  final Trip trip;
  final LiveTrip live;
  final Duration Function() elapsed;
  final Geometry? geometry;
  final List<StopOccurrence> stops;
  final String? routeName, mapWarning;
  bool get hasPosition =>
      live.position != null &&
      (live.state == LiveTripStateEnum.live ||
          live.state == LiveTripStateEnum.stale);
  Duration? get age => !hasPosition
      ? null
      : Duration(seconds: live.position!.ageSeconds) + elapsed();
  bool get fresh =>
      hasPosition &&
      live.state == LiveTripStateEnum.live &&
      age! <= const Duration(seconds: 30);
  List<StopEta> get etas => hasPosition && age! <= const Duration(seconds: 120)
      ? live.etas.toList()
      : const [];
  StopEta? get pickupEta {
    for (final eta in etas) {
      if (eta.stopOccurrenceId == live.riderPickupOccurrenceId) return eta;
    }
    return null; // A reached/absent pickup is not the next stop or zero minutes.
  }

  String stopName(String occurrenceId) {
    for (final stop in stops) {
      if (stop.id == occurrenceId) return stop.name;
    }
    return occurrenceId == live.riderPickupOccurrenceId
        ? 'Your pickup'
        : 'Stop details unavailable';
  }
}

/// No location cache. Static geometry/stops can be reused only AFTER a fresh
/// live read succeeds. An inaccessible historical version never becomes the
/// latest revision, a straight-line ETA, or a reason to guess stop identity.
class CommuterTripTracking {
  CommuterTripTracking(this.data, this.tripId)
      : generation = data.sessionGeneration;
  final CommuterDataClient data;
  final String tripId;
  final int generation;
  Geometry? _geometry;
  List<StopOccurrence>? _stops;
  String? _versionId, _routeName;
  bool _disposed = false;
  int _revision = 0;
  void invalidate() {
    _revision++;
  }

  void dispose() {
    _disposed = true;
    _geometry = null;
    _stops = null;
  }

  void _check() {
    data.ensureSession(generation);
    if (_disposed) throw const UnauthorizedException();
  }

  Future<CommuterTripSnapshot> load() async {
    final revision = _revision;
    void check() {
      _check();
      if (revision != _revision) throw const UnauthorizedException();
    }

    check();
    final watch = Stopwatch()..start();
    final live = await data.liveTrip(tripId);
    check();
    final trip = await data.trip(tripId);
    check();
    if (live.tripId != tripId ||
        trip.id != tripId ||
        live.patternVersionId != trip.patternVersionId) {
      throw const ApiException(
          502, 'The live position did not match this trip.');
    }
    if (_versionId != trip.patternVersionId) {
      _versionId = trip.patternVersionId;
      _geometry = null;
      _stops = null;
      _routeName = null;
    }
    String? warning;
    // Geometry failure must not hide an authorized textual position/ETA, but
    // authorization/upgrade failures must still clear the entire live view.
    try {
      if (live.geometryId == null) {
        _geometry = null;
      } else if (_geometry?.id != live.geometryId) {
        final geometry = await data.geometry(live.geometryId!);
        check();
        if (geometry.id != live.geometryId ||
            geometry.patternVersionId != trip.patternVersionId) {
          throw const ApiException(
              502, 'Route geometry does not belong to this trip.');
        }
        _geometry = geometry;
      }
    } on TrotxiException catch (e) {
      check();
      if (e is UnauthorizedException ||
          e is UpgradeRequiredException ||
          e is RateLimitException ||
          e is ApiException && e.statusCode == 403) rethrow;
      _geometry = null;
      warning = 'Route line unavailable; no substitute route is drawn.';
    }
    try {
      if (_stops == null) {
        final route = await data.route(trip.routeId);
        check();
        if (route.id != trip.routeId)
          throw const ApiException(502, 'Route identity mismatch.');
        _routeName = route.name;
        for (final patternId in route.patternIds) {
          final pattern = await data.pattern(patternId);
          check();
          if (pattern.id != patternId || pattern.routeId != trip.routeId) {
            throw const ApiException(502, 'Pattern identity mismatch.');
          }
          if (pattern.direction.name != trip.direction.name) continue;
          PatternVersion version;
          try {
            version =
                await data.patternVersion(patternId, trip.patternVersionId);
          } on ApiException catch (e) {
            check();
            if (e.statusCode == 404) continue;
            rethrow;
          }
          check();
          if (version.id != trip.patternVersionId ||
              version.patternId != patternId) {
            throw const ApiException(502, 'Stop version identity mismatch.');
          }
          _stops = List.unmodifiable(version.stops.toList()
            ..sort((a, b) => a.ordinal.compareTo(b.ordinal)));
          break;
        }
        if (_stops == null)
          warning = 'Stop details for this trip version are unavailable.';
      }
    } on TrotxiException catch (e) {
      check();
      if (e is UnauthorizedException ||
          e is UpgradeRequiredException ||
          e is RateLimitException ||
          e is ApiException && e.statusCode == 403) rethrow;
      warning ??=
          'Stop details unavailable. Live access is checked separately.';
    }
    check();
    return CommuterTripSnapshot(
        trip: trip,
        live: live,
        elapsed: () => watch.elapsed,
        geometry: _geometry,
        stops: _stops ?? const [],
        routeName: _routeName,
        mapWarning: warning);
  }
}
