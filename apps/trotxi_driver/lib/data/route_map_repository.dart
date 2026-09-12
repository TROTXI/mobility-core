import 'package:dio/dio.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_map/trotxi_map.dart';

/// Where a corridor's drawn line came from.
///
/// Shown rather than hidden, which is the API's own reasoning for returning it:
/// `traces` is the road-following path derived from completed runs (#179),
/// `stops` is the straight line between stops for a corridor that has not run
/// enough times to have learned one. Both are drawable; only one follows the
/// road, and a driver reading the map should be able to tell.
enum RouteShapeSource { traces, matched, manual, stops }

/// A stop, with the position the map needs.
class MappedStop {
  const MappedStop({
    required this.id,
    required this.name,
    required this.seq,
    required this.position,
  });

  final String id;
  final String name;
  final int seq;
  final LatLng position;
}

/// Everything a map needs to draw one corridor.
class RouteShape {
  const RouteShape({
    required this.points,
    required this.stops,
    required this.source,
    required this.runCount,
  });

  /// The line to draw. Empty when the corridor has neither a learned path nor
  /// enough stops to join up, in which case the map shows the basemap alone
  /// rather than an invented line.
  final List<LatLng> points;

  final List<MappedStop> stops;
  final RouteShapeSource source;

  /// How many completed runs the path was derived from. Zero for the stop
  /// fallback, which is what makes "this is a guess" checkable rather than a
  /// matter of trust.
  final int runCount;

  /// Whether the line follows roads or just joins stops with straight segments.
  bool get followsRoads =>
      source == RouteShapeSource.traces || source == RouteShapeSource.matched;

  /// A box containing the whole corridor, for framing the camera. Null when
  /// there is nothing to frame.
  LatLngBounds? get bounds {
    final all = [...points, ...stops.map((s) => s.position)];
    if (all.isEmpty) return null;
    var minLat = all.first.latitude, maxLat = all.first.latitude;
    var minLng = all.first.longitude, maxLng = all.first.longitude;
    for (final p in all) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

/// How far a stop is and when the vehicle is due, from the API.
///
/// Not computed here. The server derives both from the corridor's learned
/// geometry and the vehicle's progress along it (system-design §7), which is
/// the only place in this stack that can: a straight line between two points
/// is not a road, and a driver reading "1.2 km" off one would be reading a
/// number no van can drive.
class StopEta {
  const StopEta({
    required this.seq,
    required this.name,
    required this.distanceMeters,
    required this.etaSeconds,
  });

  final int seq;
  final String name;
  final double distanceMeters;
  final double etaSeconds;

  /// "1.2 km · ~4 min", as the file sets it.
  String get summary {
    final km = distanceMeters / 1000;
    final distance = km >= 1
        ? '${km.toStringAsFixed(1)} km'
        : '${distanceMeters.round()} m';
    final minutes = (etaSeconds / 60).round();
    // Under a minute is "arriving", not "~0 min": a driver reading zero would
    // look up expecting to already be there.
    final when = minutes < 1 ? 'arriving' : '~$minutes min';
    return '$distance · $when';
  }
}

/// The vehicle's last known position, and how old it is.
class VehicleFix {
  const VehicleFix({
    required this.position,
    required this.recordedAt,
    this.etas = const [],
  });

  final LatLng position;
  final DateTime recordedAt;

  /// Every stop still ahead, in order. Empty when the corridor has fewer than
  /// two stops or the van is past the last one, both of which the API states.
  final List<StopEta> etas;

  /// The next stop the van is due at, or null when it is past the last.
  StopEta? get nextStop => etas.isEmpty ? null : etas.first;

  /// How stale this fix is.
  ///
  /// Always shown beside the marker. #180 is explicit about it and it is the
  /// right rule: a stale fix presented as current is worse than no fix, because
  /// the map looks confident either way.
  Duration get age => DateTime.now().difference(recordedAt);
}

/// The corridor's shape and the vehicle on it, for the driver's map surfaces.
class RouteMapRepository {
  RouteMapRepository({required this._client});

  final TrotxiApiClient _client;

  /// Shapes cached for the session. A corridor's learned path changes when
  /// route learning runs, not during a shift, so one fetch each is plenty and
  /// a driver reopening the trip screen should not pay for it again.
  final Map<String, RouteShape> _shapes = {};

  /// Fixes are cached for seconds, not for the session: a position that is
  /// stale by design is the one thing this app must not serve.
  static const Duration _fixTtl = Duration(seconds: 5);
  final Map<String, (DateTime, VehicleFix)> _fixes = {};

  /// The line and stops for a corridor.
  ///
  /// Geometry and stops are fetched together and degrade independently: a
  /// corridor with no learned path still gets its stops joined up, and stops
  /// that will not load still leave whatever line there is.
  ///
  /// @param routeId - the corridor.
  /// @returns its shape.
  Future<RouteShape> shapeFor(String routeId) async {
    final cached = _shapes[routeId];
    if (cached != null) return cached;

    final stops = await _stopsFor(routeId);
    final geometry = await _geometryFor(routeId);

    // The documented fallback: null geometry draws the stop-to-stop line.
    // Angular, but not broken — and `source` says so, so the screen can label
    // it rather than passing it off as the real path.
    final shape =
        geometry ??
        RouteShape(
          points: stops.map((s) => s.position).toList(),
          stops: stops,
          source: RouteShapeSource.stops,
          runCount: 0,
        );
    final withStops = RouteShape(
      points: shape.points,
      stops: stops,
      source: shape.source,
      runCount: shape.runCount,
    );
    _shapes[routeId] = withStops;
    return withStops;
  }

  /// The latest fix for a run.
  ///
  /// Null rather than throwing when there is none: a run that has not reported
  /// yet is an ordinary state, and the map draws the corridor without a vehicle
  /// on it.
  ///
  /// @param runId - the run.
  /// @returns the fix, or null.
  Future<VehicleFix?> vehicleOn(String runId) async {
    // Two surfaces on the trip screen want this: the marker on the map and the
    // next-stop card's ETA. A few seconds of cache means they share one call
    // rather than each polling the same endpoint.
    final cached = _fixes[runId];
    if (cached != null && DateTime.now().difference(cached.$1) < _fixTtl) {
      return cached.$2;
    }
    try {
      final response = await _client.getMobilityApi().tripsIdPositionGet(
        id: runId,
      );
      final body = response.data;
      final p = body?.position;
      if (body == null || p == null) return null;
      final fix = VehicleFix(
        position: LatLng(p.latitude.toDouble(), p.longitude.toDouble()),
        recordedAt: p.recordedAt,
        etas: [
          for (final e in body.etaToStops)
            StopEta(
              seq: e.seq,
              name: e.name,
              distanceMeters: e.distanceMeters.toDouble(),
              etaSeconds: e.etaSeconds.toDouble(),
            ),
        ],
      );
      _fixes[runId] = (DateTime.now(), fix);
      return fix;
    } on DioException {
      // The vehicle marker is one of two independent things on this map (#180).
      // A position that will not load must not take the route line with it.
      return null;
    }
  }

  /// The corridor's stops, ordered.
  ///
  /// @param routeId - the corridor.
  /// @returns its stops; empty when they cannot be read.
  Future<List<MappedStop>> _stopsFor(String routeId) async {
    try {
      final response = await _client.getMobilityApi().routesIdGet(id: routeId);
      return (response.data?.stops.toList() ?? [])
          .map(
            (s) => MappedStop(
              id: s.id,
              name: s.name,
              seq: s.seq,
              position: LatLng(s.latitude.toDouble(), s.longitude.toDouble()),
            ),
          )
          .toList()
        ..sort((a, b) => a.seq.compareTo(b.seq));
    } on DioException {
      return const [];
    }
  }

  /// The learned path, when the corridor has one.
  ///
  /// @param routeId - the corridor.
  /// @returns the shape, or null to fall back to the stop line.
  Future<RouteShape?> _geometryFor(String routeId) async {
    try {
      final response = await _client.getMobilityApi().routesIdGeometryGet(
        id: routeId,
      );
      final data = response.data;
      if (data == null || data.points.isEmpty) return null;
      return RouteShape(
        points: data.points
            .map((p) => LatLng(p.latitude.toDouble(), p.longitude.toDouble()))
            .toList(),
        stops: const [],
        source: switch (data.source_.name) {
          'traces' => RouteShapeSource.traces,
          'matched' => RouteShapeSource.matched,
          'manual' => RouteShapeSource.manual,
          _ => RouteShapeSource.stops,
        },
        runCount: data.runCount,
      );
    } on DioException {
      return null;
    }
  }
}
