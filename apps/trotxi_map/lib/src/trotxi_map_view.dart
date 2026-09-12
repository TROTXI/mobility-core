import 'dart:math' show Point;

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:trotxi_map/src/map_attribution.dart';
import 'package:trotxi_map/src/map_style.dart';

/// The base map both apps draw on.
///
/// Built once and shared so the rider and driver apps do not grow two
/// integrations against the same tile server. It owns three things and nothing
/// else: the renderer, the light/dark style swap, and the attribution. What
/// goes ON the map — a vehicle, a route line, a stop sequence — belongs to the
/// screen that knows about those, and arrives through [onMapReady].
class TrotxiMapView extends StatefulWidget {
  const TrotxiMapView({
    super.key,
    required this.style,
    required this.initialCenter,
    this.initialZoom = 13,
    this.onMapReady,
    this.onStyleReloaded,
    this.interactive = true,
    this.showAttribution = true,
  });

  final TrotxiMapStyle style;

  /// Where to open. A map that opens on null island and then jumps is worse
  /// than one that opens roughly right, so callers pass the best guess they
  /// have — the first stop, the last known fix, the corridor's midpoint.
  final LatLng initialCenter;

  final double initialZoom;

  /// The controller, once the map exists. Annotations go on here.
  final void Function(MapLibreMapController controller)? onMapReady;

  /// Fired after every style load, including the reload a theme flip causes.
  ///
  /// MapLibre drops all annotations when the style changes, so anything a
  /// screen drew has to be drawn again here. Without this, switching to dark
  /// mid-run silently loses the route line and the vehicle.
  final void Function(MapLibreMapController controller)? onStyleReloaded;

  /// False for the small map on a card, where a pan gesture would fight the
  /// scrolling list it sits in.
  final bool interactive;

  final bool showAttribution;

  @override
  State<TrotxiMapView> createState() => _TrotxiMapViewState();
}

class _TrotxiMapViewState extends State<TrotxiMapView> {
  MapLibreMapController? _controller;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final styleUrl = widget.style.urlFor(brightness);

    if (styleUrl == null) {
      // The documented fallback: no basemap, and the screen around it still
      // works. Drawn as a plain surface rather than an error, because an
      // operator who has not configured tiles is not a fault the driver can act
      // on and a red panel on the trip screen would read as one.
      return const _NoBasemap();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        MapLibreMap(
          // The key is what forces a fresh map when the theme flips. Without
          // it MapLibre keeps the old style and the map stays light under a
          // dark app.
          key: ValueKey(styleUrl),
          styleString: styleUrl,
          initialCameraPosition: CameraPosition(
            target: widget.initialCenter,
            zoom: widget.initialZoom,
          ),
          // The plugin's own (i) button defaults to bottom-right, straight on
          // top of the credit we draw there. Kept — it is the conventional
          // control that opens the full attribution — but moved to the corner
          // nothing else claims. ODbL wants the credit VISIBLE, which is what
          // MapAttribution below is for; a tappable (i) alone is weaker
          // compliance, so the two are complementary rather than redundant.
          attributionButtonPosition: AttributionButtonPosition.topLeft,
          attributionButtonMargins: const Point(8, 8),
          myLocationEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          scrollGesturesEnabled: widget.interactive,
          zoomGesturesEnabled: widget.interactive,
          onMapCreated: (controller) {
            _controller = controller;
            widget.onMapReady?.call(controller);
          },
          onStyleLoadedCallback: () {
            final controller = _controller;
            if (controller != null) widget.onStyleReloaded?.call(controller);
          },
        ),
        if (widget.showAttribution)
          Positioned(
            right: 0,
            bottom: 0,
            child: MapAttribution(text: widget.style.attribution),
          ),
      ],
    );
  }
}

/// What a screen shows when no basemap is configured or reachable.
class _NoBasemap extends StatelessWidget {
  const _NoBasemap();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Map unavailable',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
