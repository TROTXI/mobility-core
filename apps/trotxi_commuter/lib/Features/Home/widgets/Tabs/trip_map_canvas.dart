import 'package:flutter/material.dart';
import 'package:trotxi_client/commuter_trip_tracking.dart';
import 'package:trotxi_map/trotxi_map.dart';

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
            final all = [
              ...points,
              for (final stop in snapshot.stops)
                LatLng(
                  stop.location.latitude.toDouble(),
                  stop.location.longitude.toDouble(),
                ),
              if (position != null)
                LatLng(
                  position.location.latitude.toDouble(),
                  position.location.longitude.toDouble(),
                ),
            ];
            if (all.isNotEmpty) {
              _framed = true;
              var south = all.first.latitude,
                  north = south,
                  west = all.first.longitude,
                  east = west;
              for (final p in all) {
                if (p.latitude < south) south = p.latitude;
                if (p.latitude > north) north = p.latitude;
                if (p.longitude < west) west = p.longitude;
                if (p.longitude > east) east = p.longitude;
              }
              await controller.animateCamera(
                CameraUpdate.newLatLngBounds(
                  LatLngBounds(
                    southwest: LatLng(south - .001, west - .001),
                    northeast: LatLng(north + .001, east + .001),
                  ),
                  left: 28,
                  right: 28,
                  top: 28,
                  bottom: 28,
                ),
              );
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
