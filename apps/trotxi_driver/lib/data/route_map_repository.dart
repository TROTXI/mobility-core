import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_driver/core/api/driver_api.dart';
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

  /// Unknown in the replacement geometry contract; never infer a sample count
  /// from its provenance. ETA confidence is returned separately per segment.
  final int? runCount;

  /// Whether the line follows roads or just joins stops with straight segments.
  bool get followsRoads => source != RouteShapeSource.stops;

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
    this.basis = 'fallback',
  });

  final int seq;
  final String name;
  final double distanceMeters;
  final double etaSeconds;
  final String basis;

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
    return '$distance · $when${basis == 'fallback' ? ' (fallback)' : ''}';
  }
}

/// The vehicle's last known position, and how old it is.
class VehicleFix {
  const VehicleFix({
    required this.position,
    required this.recordedAt,
    this.receivedAt,
    this._etas = const [],
    this.receivedLocallyAt,
    this.ageAtReceipt,
  });

  final LatLng position;
  final DateTime recordedAt;

  /// Server receipt orders fixes even when a device clock is corrected.
  final DateTime? receivedAt;

  /// Every stop still ahead, in order. Empty when the corridor has fewer than
  /// two stops or the van is past the last one, both of which the API states.
  final List<StopEta> _etas;
  final DateTime? receivedLocallyAt;
  final Duration? ageAtReceipt;
  List<StopEta> get etas =>
      age > const Duration(seconds: 120) ? const [] : _etas;

  /// The next stop the van is due at, or null when it is past the last.
  StopEta? get nextStop => etas.isEmpty ? null : etas.first;

  /// How stale this fix is.
  ///
  /// Always shown beside the marker. #180 is explicit about it and it is the
  /// right rule: a stale fix presented as current is worse than no fix, because
  /// the map looks confident either way.
  Duration get age => receivedLocallyAt == null || ageAtReceipt == null
      ? DateTime.now().difference(recordedAt)
      : ageAtReceipt! + DateTime.now().difference(receivedLocallyAt!);
}

/// The corridor's shape and the vehicle on it, for the driver's map surfaces.
class RouteMapRepository {
  RouteMapRepository({required this.client});
  final DriverApi client;
  final Map<String, RouteShape> _shapes = {};
  final Map<String, (DateTime, VehicleFix)> _fixes = {};
  int? _generation;
  void _sync() {
    if (_generation != client.store.generation) {
      _shapes.clear();
      _fixes.clear();
      _generation = client.store.generation;
    }
  }

  /// Shapes belong to the immutable version operated by this trip, not the
  /// corridor's latest revision or an inferred morning/evening direction.
  Future<RouteShape> shapeFor(String runId) async {
    _sync();
    final generation = client.sessionGeneration;
    final trip = await client.trip(runId);
    final cached = _shapes[trip.patternVersionId];
    if (cached != null) return cached;
    final stops =
        trip.stops
            .map(
              (s) => MappedStop(
                id: s.id,
                name: s.name,
                seq: s.ordinal,
                position: LatLng(
                  s.location.latitude.toDouble(),
                  s.location.longitude.toDouble(),
                ),
              ),
            )
            .toList()
          ..sort((a, b) => a.seq.compareTo(b.seq));
    wire.Geometry? geometry;
    try {
      // Assigned history may operate a pattern absent from today's catalogue.
      // Resolve the immutable version through the trip's explicit owner.
      final patternId = trip.patternId;
      final version = (await client.get(
        '/v1/route-patterns/${Uri.encodeComponent(patternId)}/versions/${Uri.encodeComponent(trip.patternVersionId)}',
        wire.PatternVersionResponse.serializer,
      )).data;
      if (version.id != trip.patternVersionId ||
          version.patternId != patternId) {
        throw const ApiException(
          502,
          'The route version did not match this run.',
        );
      }
      if (version.geometryId != null) {
        geometry = (await client.get(
          '/v1/route-geometries/${Uri.encodeComponent(version.geometryId!)}',
          wire.GeometryResponse.serializer,
        )).data;
        if (geometry.patternVersionId != trip.patternVersionId) {
          throw const ApiException(
            502,
            'The route geometry did not match this run.',
          );
        }
      }
    } on TrotxiException {
      // Known trip stops remain drawable during a geometry/network failure.
      // Never cache the fallback: the next load must be able to recover.
      geometry = null;
    }
    client.ensureSession(generation);
    final shape = RouteShape(
      points:
          geometry?.points
              .map((p) => LatLng(p.latitude.toDouble(), p.longitude.toDouble()))
              .toList() ??
          stops.map((s) => s.position).toList(),
      stops: stops,
      source: geometry == null
          ? RouteShapeSource.stops
          : geometry.source_.name == 'observed'
          ? RouteShapeSource.traces
          : RouteShapeSource.manual,
      runCount: null,
    );
    if (geometry != null) _shapes[trip.patternVersionId] = shape;
    return shape;
  }

  Future<VehicleFix?> vehicleOn(String runId) async {
    _sync();
    final cached = _fixes[runId];
    if (cached != null &&
        DateTime.now().difference(cached.$1) < const Duration(seconds: 5)) {
      return cached.$2;
    }
    try {
      final trip = await client.trip(runId);
      final live = (await client.get(
        '/v1/trips/${Uri.encodeComponent(runId)}/live',
        wire.LiveTripResponse.serializer,
      )).data;
      if (live.tripId != runId ||
          live.patternVersionId != trip.patternVersionId) {
        throw const ApiException(502, 'The position did not match this run.');
      }
      final position = live.position;
      if (position == null ||
          ['ended', 'notStarted'].contains(live.state.name)) {
        _fixes.remove(runId);
        return null;
      }
      final fetched = DateTime.now();
      final fix = VehicleFix(
        position: LatLng(
          position.location.latitude.toDouble(),
          position.location.longitude.toDouble(),
        ),
        recordedAt: position.capturedAt,
        receivedAt: position.receivedAt,
        receivedLocallyAt: fetched,
        ageAtReceipt: Duration(seconds: position.ageSeconds),
        etas: [
          if (position.ageSeconds <= 120)
            for (final eta in live.etas)
              for (final stop in trip.stops.where(
                (s) => s.id == eta.stopOccurrenceId,
              ))
                StopEta(
                  seq: stop.ordinal,
                  name: stop.name,
                  distanceMeters: eta.distanceMeters.toDouble(),
                  etaSeconds: eta.durationSeconds.toDouble(),
                  basis: eta.basis.name,
                ),
        ],
      );
      _fixes[runId] = (fetched, fix);
      return fix;
    } on TrotxiException {
      _fixes.remove(runId);
      return null;
    }
  }
}
