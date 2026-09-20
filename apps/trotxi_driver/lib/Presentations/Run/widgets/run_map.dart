import 'dart:async';
import 'package:trotxi_driver/core/state/foreground_refresh.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/config_controller.dart';
import 'package:trotxi_driver/data/route_map_repository.dart';
import 'package:trotxi_map/trotxi_map.dart';

/// The corridor, drawn (#237, active trip / page 09).
///
/// Three things on one surface, and they fail independently by design (#180):
/// the basemap, the route line with its stops, and the vehicle. A corridor with
/// no learned path still gets its stops joined up; a vehicle that has not
/// reported yet leaves the line alone; tiles that will not load leave both.
///
/// The vehicle's age is always shown. A stale fix presented as current is worse
/// than no fix, because the map looks equally confident either way.
class RunMap extends StatefulWidget {
  const RunMap({
    super.key,
    required this.routeId,
    required this.runId,
    required this.isActive,
    this.height = 220,
    this.onExpand,
  });

  final String routeId;
  final String runId;

  /// Whether the run is under way. The vehicle is only polled on a live run —
  /// a scheduled trip has no position and asking for one every few seconds is
  /// battery spent on a known answer.
  final bool isActive;

  final double height;

  /// The design makes the active-trip map expandable. Null hides the control.
  final VoidCallback? onExpand;

  @override
  State<RunMap> createState() => _RunMapState();
}

class _RunMapState extends State<RunMap> {
  MapLibreMapController? _controller;
  RouteShape? _shape;
  VehicleFix? _vehicle;
  bool _framed = false;
  ForegroundRefresh? _refresh;
  int _revision = 0;
  bool _drawing = false;
  bool _redraw = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _refresh = ForegroundRefresh(() async {
      if (mounted && widget.isActive) await _load();
    });
  }

  @override
  void didUpdateWidget(RunMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.runId != widget.runId ||
        oldWidget.isActive != widget.isActive) {
      _revision++;
      _vehicle = null;
      if (oldWidget.runId != widget.runId) {
        _shape = null;
        _framed = false;
      }
      unawaited(_load());
    }
  }

  @override
  void dispose() {
    _revision++;
    _refresh?.dispose();
    super.dispose();
  }

  /// Fetch the corridor and, on a live run, where the bus is.
  Future<void> _load() async {
    if (!mounted) return;
    final revision = ++_revision;
    final maps = context.read<RouteMapRepository>();
    try {
      final shape = await maps.shapeFor(widget.runId);
      final vehicle = widget.isActive
          ? await maps.vehicleOn(widget.runId)
          : null;
      if (!mounted || revision != _revision) return;
      setState(() {
        _shape = shape;
        _vehicle = vehicle;
      });
      await _draw();
    } on TrotxiException {
      if (mounted && revision == _revision) setState(() => _vehicle = null);
    }
  }

  /// Put the corridor and the vehicle on the map.
  ///
  /// Called after a load AND after every style reload, because MapLibre drops
  /// all annotations when the style changes — so a theme flip mid-run would
  /// otherwise leave an empty basemap.
  Future<void> _draw() async {
    if (_drawing) {
      _redraw = true;
      return;
    }
    _drawing = true;
    try {
      await _drawNow();
    } on PlatformException {
      // The native map can disappear during a theme change/navigation.
    } finally {
      _drawing = false;
      if (_redraw && mounted) {
        _redraw = false;
        unawaited(_draw());
      }
    }
  }

  Future<void> _drawNow() async {
    final controller = _controller;
    final shape = _shape;
    if (controller == null || shape == null || !mounted) return;

    final colors = context.driverColors;
    await controller.clearLines();
    await controller.clearCircles();

    if (shape.points.length > 1) {
      await controller.addLine(
        LineOptions(
          geometry: shape.points,
          lineColor: _hex(colors.action),
          lineWidth: 5,
          lineOpacity: 0.9,
          // A guessed line is drawn dashed-thin rather than solid, so the map
          // does not present a straight hop between stops as the road.
          lineJoin: 'round',
        ),
      );
    }

    for (final stop in shape.stops) {
      await controller.addCircle(
        CircleOptions(
          geometry: stop.position,
          circleRadius: 5,
          circleColor: _hex(colors.surface),
          circleStrokeColor: _hex(colors.action),
          circleStrokeWidth: 2,
        ),
      );
    }

    final vehicle = _vehicle;
    if (vehicle != null) {
      await controller.addCircle(
        CircleOptions(
          geometry: vehicle.position,
          circleRadius: 9,
          circleColor: _hex(colors.live),
          circleStrokeColor: _hex(colors.surface),
          circleStrokeWidth: 3,
        ),
      );
    }

    // Framed once. Re-framing on every redraw would fight a driver who has
    // panned the map to look at something.
    if (!_framed) {
      final bounds = shape.bounds;
      if (bounds != null) {
        _framed = true;
        await controller.animateCamera(
          CameraUpdate.newLatLngBounds(
            bounds,
            left: 24,
            right: 24,
            top: 24,
            bottom: 24,
          ),
        );
      }
    }
  }

  /// MapLibre takes colours as hex strings.
  ///
  /// @param color - the theme colour.
  /// @returns it as `#RRGGBB`.
  static String _hex(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final style = context.watch<ConfigController>().mapStyle;
    final shape = _shape;

    return ClipRRect(
      borderRadius: AppRadii.circular(AppRadii.lg),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            TrotxiMapView(
              style: style,
              // Opens on the first stop rather than on nothing, so the map does
              // not jump from null island once the corridor loads.
              initialCenter:
                  shape?.stops.firstOrNull?.position ??
                  const LatLng(5.6037, -0.187),
              interactive: false,
              onMapReady: (controller) {
                _controller = controller;
                unawaited(_draw());
              },
              onStyleReloaded: (_) => unawaited(_draw()),
            ),

            // Both notes sit bottom-left, clear of the attribution's own line
            // along the bottom edge and of the two corner controls. The credit
            // is 230-odd points wide at 9px, so it owns that strip on a phone
            // and nothing else can share it.
            Positioned(
              left: AppSpacing.space8,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_vehicle != null) ...[
                    _MapNote(
                      // Never a position without its age.
                      text: 'Bus ${_ago(_vehicle!.age)}',
                      colors: colors,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                  ],
                  // The line's provenance, where the corridor has not been
                  // learned yet. The API returns `source` precisely so this can
                  // be said out loud rather than the guess being passed off as
                  // the road.
                  if (shape != null &&
                      !shape.followsRoads &&
                      shape.points.length > 1)
                    _MapNote(
                      text: 'Straight line between stops',
                      colors: colors,
                    ),
                ],
              ),
            ),

            if (widget.onExpand != null)
              Positioned(
                right: AppSpacing.space8,
                top: AppSpacing.space8,
                child: Material(
                  color: colors.surface,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: widget.onExpand,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space8),
                      child: Icon(
                        Icons.open_in_full,
                        size: 18,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// How old a fix is, in words a driver reads at a glance.
  ///
  /// @param age - how long ago it was recorded.
  /// @returns the phrase.
  static String _ago(Duration age) {
    if (age.inSeconds < 20) return 'here now';
    if (age.inMinutes < 1) return '${age.inSeconds}s ago';
    if (age.inMinutes < 60) return '${age.inMinutes}m ago';
    return '${age.inHours}h ago';
  }
}

/// A small caption over the map.
class _MapNote extends StatelessWidget {
  const _MapNote({required this.text, required this.colors});

  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: colors.surface.withValues(alpha: 0.9),
      borderRadius: AppRadii.circular(AppRadii.full),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(color: colors.textPrimary),
      ),
    ),
  );
}
