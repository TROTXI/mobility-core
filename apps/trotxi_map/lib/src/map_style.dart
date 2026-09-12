import 'package:flutter/material.dart';

/// Where the basemap comes from, and what has to be credited for using it.
///
/// Served by `GET /flags` rather than compiled into either app (#178). Depots
/// and hosts change; three simultaneous app releases to move a URL is not a
/// deployment strategy. The apps pass what they were given straight through —
/// this package never calls the API itself, so it stays a rendering concern.
@immutable
class TrotxiMapStyle {
  const TrotxiMapStyle({
    required this.lightUrl,
    required this.darkUrl,
    required this.attribution,
  });

  /// MapLibre style for the light theme. Null when the operator has not
  /// configured one, which renders as no basemap rather than as a failure.
  final String? lightUrl;

  /// The dark variant. Every screen in the driver designs has one, and a
  /// windscreen-mounted phone before dawn is the case that matters.
  final String? darkUrl;

  /// The credit the data licences require, travelling with the URL because it
  /// is a licence condition rather than decoration: OpenStreetMap is ODbL and
  /// the OpenMapTiles schema carries its own visible-credit grant.
  final String attribution;

  /// Nothing configured. The map draws blank and the rest of the screen works,
  /// which is the documented fallback — position, ETA and boarding are all API
  /// paths and never touch the tile host.
  static const none = TrotxiMapStyle(
    lightUrl: null,
    darkUrl: null,
    attribution: '© OpenStreetMap contributors · © OpenMapTiles',
  );

  /// Whether there is a basemap to draw at all.
  bool get isConfigured => lightUrl != null || darkUrl != null;

  /// The style for a brightness, falling back to the other when only one is
  /// configured. A dark app over a light basemap is ugly; a dark app over no
  /// basemap is useless, and the first is the better failure.
  ///
  /// @param brightness - the theme's brightness.
  /// @returns the style URL, or null when neither is configured.
  String? urlFor(Brightness brightness) =>
      brightness == Brightness.dark ? (darkUrl ?? lightUrl) : (lightUrl ?? darkUrl);
}
