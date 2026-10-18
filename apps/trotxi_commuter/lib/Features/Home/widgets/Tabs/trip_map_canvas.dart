import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:trotxi_client/commuter_trip_tracking.dart';
import 'package:trotxi_map/trotxi_map.dart';

/// Calculates the route camera in Dart instead of relying on MapLibre's native
/// iOS bounds fitting while the platform view is still settling.
@visibleForTesting
CameraPosition tripRouteCamera(
  List<LatLng> points,
  Size viewport, {
  double padding = 28,
}) {
  assert(points.isNotEmpty);
  var south = points.first.latitude,
      north = south,
      west = points.first.longitude,
      east = west;
  for (final point in points.skip(1)) {
    if (point.latitude < south) south = point.latitude;
    if (point.latitude > north) north = point.latitude;
    if (point.longitude < west) west = point.longitude;
    if (point.longitude > east) east = point.longitude;
  }

  // Give a single point and very short corridors a little breathing room.
  south -= .001;
  north += .001;
  west -= .001;
  east += .001;

  double worldY(double latitude) {
    final radians = latitude.clamp(-85.0511, 85.0511) * math.pi / 180;
    final sine = math.sin(radians).clamp(-.9999, .9999);
    return .5 - math.log((1 + sine) / (1 - sine)) / (4 * math.pi);
  }

  final longitudeFraction = (east - west).abs() / 360;
  final latitudeFraction = (worldY(north) - worldY(south)).abs();
  final width = math.max(1.0, viewport.width - padding * 2);
  final height = math.max(1.0, viewport.height - padding * 2);
  double zoomFor(double pixels, double fraction) =>
      fraction <= 0 ? 16 : math.log(pixels / 256 / fraction) / math.ln2;
  final zoom = math
      .min(zoomFor(width, longitudeFraction), zoomFor(height, latitudeFraction))
      .clamp(1.0, 16.0)
      .toDouble();

  return CameraPosition(
    target: LatLng((south + north) / 2, (west + east) / 2),
    zoom: zoom,
  );
}

/// Only server coordinates are drawn. Shared map disables device location.
class TripMapCanvas extends StatefulWidget {
  const TripMapCanvas({super.key, required this.snapshot, required this.style});
  final CommuterTripSnapshot snapshot;
  final TrotxiMapStyle style;
  @override
  State<TripMapCanvas> createState() => _TripMapCanvasState();
}

class _TripMapCanvasState extends State<TripMapCanvas> {
  MapLibreMapController? _controller;
  bool _ready = false, _framed = false, _failed = false;
  int _revision = 0;
  int? _drawnRoute;
  Future<void> _draws = Future.value();
  late final VehicleMarker _marker = VehicleMarker(
    options: (point, _) => CircleOptions(
      geometry: point,
      // Neutral marker: the live/stale text below ages with the server fix.
      circleColor: '#19364D',
      circleRadius: 10,
      circleStrokeColor: '#FFFFFF',
      circleStrokeWidth: 3,
    ),
  );

  @override
  void initState() {
    super.initState();
    _acceptPosition();
  }

  void _acceptPosition() {
    final position = widget.snapshot.hasPosition
        ? widget.snapshot.live.position
        : null;
    if (position == null) {
      _marker.clear();
    } else {
      _marker.accept(
        LatLng(
          position.location.latitude.toDouble(),
          position.location.longitude.toDouble(),
        ),
        position.receivedAt,
        fresh: widget.snapshot.fresh,
      );
    }
  }

  @override
  void didUpdateWidget(covariant TripMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapshot != widget.snapshot) {
      _acceptPosition();
      _draw();
    }
  }

  @override
  void dispose() {
    _revision++;
    _ready = false;
    _marker.dispose();
    super.dispose();
  }

  void _draw() {
    final revision = ++_revision;
    _draws = _draws
        .then((_) async {
          final controller = _controller;
          bool current() =>
              mounted &&
              _ready &&
              revision == _revision &&
              controller == _controller;
          if (controller == null || !current()) return;
          final snapshot = widget.snapshot;
          final signature = Object.hash(
            snapshot.trip.id,
            snapshot.geometry?.id,
            snapshot.live.riderPickupOccurrenceId,
            Object.hashAll(
              snapshot.stops.map(
                (s) => Object.hash(
                  s.id,
                  s.ordinal,
                  s.location.latitude,
                  s.location.longitude,
                ),
              ),
            ),
          );
          final points =
              snapshot.geometry?.points
                  .map(
                    (p) =>
                        LatLng(p.latitude.toDouble(), p.longitude.toDouble()),
                  )
                  .toList() ??
              <LatLng>[];
          if (_drawnRoute != signature) {
            await controller.clearLines();
            if (!current()) return;
            await controller.clearCircles();
            if (!current()) return;
            if (points.length >= 2) {
              await controller.addLine(
                LineOptions(
                  geometry: points,
                  lineColor: '#50789A',
                  lineWidth: 5,
                ),
              );
              if (!current()) return;
            }
            for (final stop in snapshot.stops) {
              await controller.addCircle(
                CircleOptions(
                  geometry: LatLng(
                    stop.location.latitude.toDouble(),
                    stop.location.longitude.toDouble(),
                  ),
                  circleRadius: stop.id == snapshot.live.riderPickupOccurrenceId
                      ? 8
                      : 5,
                  circleColor: stop.id == snapshot.live.riderPickupOccurrenceId
                      ? '#F2A900'
                      : '#FFFFFF',
                  circleStrokeColor: '#50789A',
                  circleStrokeWidth: 2,
                ),
              );
              if (!current()) return;
            }
            _drawnRoute = signature;
            _marker.attach(controller);
          }
          final position = snapshot.hasPosition ? snapshot.live.position : null;
          if (!_framed) {
            final route = [
              ...points,
              for (final stop in snapshot.stops)
                LatLng(
                  stop.location.latitude.toDouble(),
                  stop.location.longitude.toDouble(),
                ),
            ];
            // A delayed or malformed vehicle fix must never shrink an entire
            // commuter route to a dot. Use the fix only when no route shape is
            // available at all.
            final framePoints = route.isNotEmpty
                ? route
                : [
                    if (position != null)
                      LatLng(
                        position.location.latitude.toDouble(),
                        position.location.longitude.toDouble(),
                      ),
                  ];
            if (framePoints.isNotEmpty) {
              // onStyleLoaded can run before the iOS platform view has its
              // final dimensions. Wait for Flutter's frame, then use a
              // deterministic camera rather than native bounds fitting.
              await WidgetsBinding.instance.endOfFrame;
              if (!mounted || !current()) return;
              final viewport = context.size;
              if (viewport == null || viewport.isEmpty) return;
              await controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  tripRouteCamera(framePoints, viewport),
                ),
              );
              if (!current()) return;
              _framed = true;
            }
          }
          if (current() && _failed) setState(() => _failed = false);
        })
        .catchError((Object _) {
          if (mounted && revision == _revision) setState(() => _failed = true);
        });
  }

  @override
  Widget build(BuildContext context) {
    final point =
        widget.snapshot.geometry?.points.firstOrNull ??
        (widget.snapshot.hasPosition
            ? widget.snapshot.live.position?.location
            : null);
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TrotxiMapView(
            style: widget.style,
            initialCenter: point == null
                ? const LatLng(5.6037, -.187)
                : LatLng(point.latitude.toDouble(), point.longitude.toDouble()),
            onMapReady: (controller) {
              _revision++;
              _controller = controller;
              _ready = false;
              _framed = false;
              _drawnRoute = null;
            },
            onStyleReloaded: (controller) {
              _controller = controller;
              _ready = true;
              _drawnRoute = null;
              _draw();
            },
          ),
          if (_failed)
            const ColoredBox(
              color: Color(0xFFF4F6F8),
              child: Center(
                child: Text(
                  'Map could not be drawn. Trip information remains available below.',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
