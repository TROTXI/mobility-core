/// The shared map surface for the Trotxi apps (#180).
///
/// One integration against the tile server, used by both apps: the renderer,
/// the light/dark style swap, and the attribution the data licences require.
/// Screens supply what goes on top.
library;

export 'package:maplibre_gl/maplibre_gl.dart'
    show
        CameraPosition,
        CameraUpdate,
        CircleOptions,
        LatLng,
        LatLngBounds,
        LineOptions,
        MapLibreMapController,
        SymbolOptions;

export 'src/map_attribution.dart';
export 'src/map_style.dart';
export 'src/trotxi_map_view.dart';
