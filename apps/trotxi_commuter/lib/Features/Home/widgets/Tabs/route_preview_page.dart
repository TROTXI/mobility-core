import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_map/trotxi_map.dart';

/// A public route preview. It never requests the live vehicle endpoint.
class RoutePreviewPage extends StatefulWidget {
  const RoutePreviewPage({
    super.key,
    required this.client,
    required this.trip,
    required this.routeName,
  });

  final CommuterApi client;
  final wire.Trip trip;
  final String routeName;

  @override
  State<RoutePreviewPage> createState() => _RoutePreviewPageState();
}

class _RoutePreviewPageState extends State<RoutePreviewPage> {
  wire.PatternVersion? _version;
  wire.Geometry? _geometry;
  String? _warning;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final generation = widget.client.sessionGeneration;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final version = await widget.client.patternVersion(
        widget.trip.patternId,
        widget.trip.patternVersionId,
      );
      if (version.id != widget.trip.patternVersionId ||
          version.patternId != widget.trip.patternId) {
        throw const ApiException(502, 'Route details did not match this trip.');
      }
      wire.Geometry? geometry;
      String? warning;
      if (version.geometryId != null) {
        try {
          final fetched = await widget.client.geometry(version.geometryId!);
          if (fetched.patternVersionId != version.id) {
            throw const ApiException(
              502,
              'Route line did not match this trip.',
            );
          }
          geometry = fetched;
        } on TrotxiException catch (error) {
          if (error is UnauthorizedException ||
              error is UpgradeRequiredException) {
            rethrow;
          }
          warning = 'Route line unavailable. Stops are still shown.';
        }
      }
      widget.client.ensureSession(generation);
      if (!mounted) return;
      setState(() {
        _version = version;
        _geometry = geometry;
        _warning = warning;
      });
    } catch (error) {
      if (!mounted || generation != widget.client.sessionGeneration) return;
      setState(
        () => _error = error is TrotxiException
            ? error.message
            : 'Could not load this route. Please retry.',
      );
    } finally {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final version = _version;
    final tiles = widget.client.configuration?.mapTiles;
    String? clean(String? value) =>
        value == null || value.trim().isEmpty ? null : value.trim();
    final style = TrotxiMapStyle(
      lightUrl: clean(tiles?.styleUrl),
      darkUrl: clean(tiles?.darkStyleUrl),
      attribution: clean(tiles?.attribution) ?? TrotxiMapStyle.none.attribution,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Route preview')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.routeName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.trip.direction == wire.TripDirectionEnum.outbound ? 'Outbound' : 'Return'}'
            ' · ${DateFormat('EEE, d MMM, HH:mm').format(widget.trip.scheduledAt.toUtc())}',
          ),
          const SizedBox(height: 8),
          const Text(
            'This preview shows the planned route, not the live bus. '
            'Confirm a trip to access live tracking.',
          ),
          const SizedBox(height: 16),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null) ...[
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
          if (version != null) ...[
            RouteStopsMap(version: version, geometry: _geometry, style: style),
            if (_warning != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_warning!),
              ),
            const SizedBox(height: 20),
            Text('Stops', style: Theme.of(context).textTheme.titleLarge),
            for (final stop
                in version.stops.toList()
                  ..sort((a, b) => a.ordinal.compareTo(b.ordinal)))
              ListTile(
                leading: CircleAvatar(child: Text('${stop.ordinal}')),
                title: Text(stop.name),
              ),
          ],
        ],
      ),
    );
  }
}

/// Preview for offer selection, including routes without a generated trip yet.
class RouteChoicePreviewPage extends StatefulWidget {
  const RouteChoicePreviewPage({
    super.key,
    required this.client,
    required this.version,
    required this.routeName,
    required this.departureLabel,
  });

  final CommuterApi client;
  final wire.PatternVersion version;
  final String routeName;
  final String departureLabel;

  @override
  State<RouteChoicePreviewPage> createState() => _RouteChoicePreviewPageState();
}

class _RouteChoicePreviewPageState extends State<RouteChoicePreviewPage> {
  late final Future<wire.Geometry?> _geometry = _loadGeometry();

  Future<wire.Geometry?> _loadGeometry() async {
    final id = widget.version.geometryId;
    if (id == null) return null;
    final generation = widget.client.sessionGeneration;
    final geometry = await widget.client.geometry(id);
    widget.client.ensureSession(generation);
    if (geometry.patternVersionId != widget.version.id) {
      throw const ApiException(502, 'Route line did not match this route.');
    }
    return geometry;
  }

  @override
  Widget build(BuildContext context) {
    final tiles = widget.client.configuration?.mapTiles;
    String? clean(String? value) =>
        value == null || value.trim().isEmpty ? null : value.trim();
    final style = TrotxiMapStyle(
      lightUrl: clean(tiles?.styleUrl),
      darkUrl: clean(tiles?.darkStyleUrl),
      attribution: clean(tiles?.attribution) ?? TrotxiMapStyle.none.attribution,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Preview stops')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.routeName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(widget.departureLabel),
          const SizedBox(height: 8),
          const Text(
            'Planned route only. A bus position appears after a confirmed trip begins.',
          ),
          const SizedBox(height: 16),
          FutureBuilder<wire.Geometry?>(
            future: _geometry,
            builder: (context, snapshot) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (snapshot.connectionState != ConnectionState.done)
                  const LinearProgressIndicator(),
                RouteStopsMap(
                  version: widget.version,
                  geometry: snapshot.data,
                  style: style,
                ),
                if (snapshot.hasError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Route line unavailable. Stops are still shown.',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Stops', style: Theme.of(context).textTheme.titleLarge),
          for (final stop
              in widget.version.stops.toList()
                ..sort((a, b) => a.ordinal.compareTo(b.ordinal)))
            ListTile(
              leading: CircleAvatar(child: Text('${stop.ordinal}')),
              title: Text(stop.name),
            ),
        ],
      ),
    );
  }
}

class RouteStopsMap extends StatefulWidget {
  const RouteStopsMap({
    super.key,
    required this.version,
    required this.geometry,
    required this.style,
  });
  final wire.PatternVersion version;
  final wire.Geometry? geometry;
  final TrotxiMapStyle style;

  @override
  State<RouteStopsMap> createState() => _RoutePreviewMapState();
}

class _RoutePreviewMapState extends State<RouteStopsMap> {
  MapLibreMapController? _controller;
  int _revision = 0;
  bool _failed = false;
  bool _ready = false;

  @override
  void didUpdateWidget(covariant RouteStopsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ready &&
        (oldWidget.version != widget.version ||
            oldWidget.geometry != widget.geometry)) {
      final controller = _controller;
      if (controller != null) unawaited(_draw(controller));
    }
  }

  @override
  void dispose() {
    _revision++;
    super.dispose();
  }

  Future<void> _draw(MapLibreMapController controller) async {
    final revision = ++_revision;
    bool current() =>
        mounted && _ready && revision == _revision && _controller == controller;
    try {
      await controller.clearLines();
      if (!current()) return;
      await controller.clearCircles();
      if (!current()) return;
      final points =
          widget.geometry?.points
              .map(
                (point) => LatLng(
                  point.latitude.toDouble(),
                  point.longitude.toDouble(),
                ),
              )
              .toList() ??
          <LatLng>[];
      if (points.length >= 2) {
        await controller.addLine(
          LineOptions(geometry: points, lineColor: '#50789A', lineWidth: 5),
        );
      }
      if (!current()) return;
      for (final stop in widget.version.stops) {
        await controller.addCircle(
          CircleOptions(
            geometry: LatLng(
              stop.location.latitude.toDouble(),
              stop.location.longitude.toDouble(),
            ),
            circleRadius: 7,
            circleColor: '#FFFFFF',
            circleStrokeColor: '#50789A',
            circleStrokeWidth: 2,
          ),
        );
        if (!current()) return;
      }
      final all = [
        ...points,
        for (final stop in widget.version.stops)
          LatLng(
            stop.location.latitude.toDouble(),
            stop.location.longitude.toDouble(),
          ),
      ];
      if (all.isNotEmpty) {
        var south = all.first.latitude, north = south;
        var west = all.first.longitude, east = west;
        for (final point in all) {
          if (point.latitude < south) south = point.latitude;
          if (point.latitude > north) north = point.latitude;
          if (point.longitude < west) west = point.longitude;
          if (point.longitude > east) east = point.longitude;
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
      if (current() && _failed) setState(() => _failed = false);
    } catch (_) {
      if (current()) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = widget.version.stops.firstOrNull?.location;
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TrotxiMapView(
            style: widget.style,
            initialCenter: first == null
                ? const LatLng(5.6037, -.187)
                : LatLng(first.latitude.toDouble(), first.longitude.toDouble()),
            onMapReady: (controller) {
              _controller = controller;
              _ready = false;
            },
            onStyleReloaded: (controller) {
              _controller = controller;
              _ready = true;
              unawaited(_draw(controller));
            },
          ),
          if (_failed)
            const ColoredBox(
              color: Color(0xFFF4F6F8),
              child: Center(
                child: Text(
                  'Map could not be drawn. Stop details remain available below.',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
