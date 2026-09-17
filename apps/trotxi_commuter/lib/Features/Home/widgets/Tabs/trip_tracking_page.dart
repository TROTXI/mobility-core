import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/commuter_trip_tracking.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_map/trotxi_map.dart';
import 'trip_map_canvas.dart';

typedef TripMapBuilder =
    Widget Function(CommuterTripSnapshot snapshot, TrotxiMapStyle style);
Widget buildTripMap(CommuterTripSnapshot snapshot, TrotxiMapStyle style) =>
    TripMapCanvas(snapshot: snapshot, style: style);

class TripTrackingPage extends StatefulWidget {
  const TripTrackingPage({
    super.key,
    required this.client,
    required this.tripId,
    this.mapBuilder = buildTripMap,
    this.pollInterval = const Duration(seconds: 5),
  });
  final CommuterApi client;
  final String tripId;
  final TripMapBuilder mapBuilder;

  /// Injectable scheduler interval for lifecycle tests; app callers use 5s.
  final Duration pollInterval;
  @override
  State<TripTrackingPage> createState() => _TripTrackingPageState();
}

class _TripTrackingPageState extends State<TripTrackingPage>
    with WidgetsBindingObserver {
  late CommuterTripTracking _tracking;
  CommuterTripSnapshot? _snapshot;
  String? _error;
  Timer? _poll, _age;
  bool _foreground = true,
      _inFlight = false,
      _loading = false,
      _resumePending = false;
  int _epoch = 0;
  Duration _delay = const Duration(seconds: 5);
  @override
  void initState() {
    super.initState();
    _tracking = CommuterTripTracking(widget.client, widget.tripId);
    _delay = widget.pollInterval;
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    if (_foreground) _refresh();
  }

  @override
  void dispose() {
    _stop();
    _tracking.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _stop() {
    _epoch++;
    _resumePending = false;
    _tracking.invalidate();
    _poll?.cancel();
    _age?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _stop();
    setState(() {
      _snapshot = null;
      _error = null;
    });
    if (_foreground) {
      if (_inFlight) {
        _resumePending = true;
      } else {
        _refresh();
      }
    }
  }

  Future<void> _refresh() async {
    if (!_foreground || _inFlight) return;
    _poll?.cancel();
    final epoch = _epoch;
    _inFlight = true;
    setState(() {
      _loading = true;
      _error = null;
    });
    var again = true;
    try {
      final snapshot = await _tracking.load();
      if (!mounted || epoch != _epoch || !_foreground) return;
      setState(() {
        _snapshot = snapshot;
        _delay = widget.pollInterval;
      });
      again = snapshot.live.state != wire.LiveTripStateEnum.ended;
      _age?.cancel();
      if (snapshot.hasPosition) {
        _age = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted && _foreground && _snapshot != null) setState(() {});
        });
      }
    } catch (e) {
      if (!mounted || epoch != _epoch || !_foreground) return;
      _age?.cancel();
      setState(() {
        _snapshot = null;
        _error =
            e is ApiException && (e.statusCode == 404 || e.statusCode == 403)
            ? 'Live tracking is unavailable for this trip or your current access. Refresh after your access changes.'
            : e is TrotxiException
            ? e.message
            : 'Could not refresh live tracking. Please retry.';
      });
      if (e is RateLimitException) {
        _delay = e.retryAfter > const Duration(seconds: 5)
            ? e.retryAfter
            : const Duration(seconds: 5);
      } else {
        _delay = Duration(seconds: (_delay.inSeconds * 2).clamp(5, 60));
      }
      again =
          !(e is UnauthorizedException ||
              e is UpgradeRequiredException ||
              e is ApiException &&
                  (e.statusCode == 403 || e.statusCode == 404));
    } finally {
      _inFlight = false;
      if (mounted) {
        setState(() => _loading = false);
        if (_foreground && _resumePending) {
          _resumePending = false;
          unawaited(_refresh());
        } else if (_foreground && epoch == _epoch && again) {
          _poll = Timer(_delay, _refresh);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final tiles = widget.client.configuration?.mapTiles;
    String? clean(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
    final style = TrotxiMapStyle(
      lightUrl: clean(tiles?.styleUrl),
      darkUrl: clean(tiles?.darkStyleUrl),
      attribution: clean(tiles?.attribution) ?? TrotxiMapStyle.none.attribution,
    );
    return Scaffold(
      appBar: AppBar(title: Text(snapshot?.routeName ?? 'Trip tracking')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Only the bus location is shown. This app does not collect your location.',
          ),
          TextButton(
            onPressed: _inFlight || !_foreground ? null : _refresh,
            child: const Text('Refresh tracking'),
          ),
          if (_loading) const LinearProgressIndicator(),
          if (!_foreground)
            const Text('Tracking paused while the app is not active.'),
          if (_error != null) Text(_error!),
          if (snapshot != null) ...[
            Text(
              'Service ${snapshot.trip.serviceDate} · Departure ${DateFormat('d MMM HH:mm').format(snapshot.trip.scheduledAt.toUtc())} Ghana time',
            ),
            Text(
              snapshot.trip.direction == wire.TripDirectionEnum.outbound
                  ? 'Outbound'
                  : 'Return',
            ),
            Text(snapshot.trip.vehicleLabel ?? 'Vehicle not assigned'),
            widget.mapBuilder(snapshot, style),
            if (snapshot.mapWarning != null) Text(snapshot.mapWarning!),
            if (snapshot.geometry != null)
              Text(
                snapshot.geometry!.source_ == wire.GeometrySource_Enum.observed
                    ? 'Route line: observed'
                    : 'Route line: configured',
              ),
            Text(switch (snapshot.live.state) {
              wire.LiveTripStateEnum.notStarted => 'Trip has not started.',
              wire.LiveTripStateEnum.awaitingFix =>
                'Waiting for the driver’s first location update.',
              wire.LiveTripStateEnum.ended =>
                'Trip ended. No live bus location is shown.',
              _ =>
                snapshot.hasPosition
                    ? '${snapshot.fresh ? 'Live bus' : 'Last known bus position'} · ${snapshot.age!.inSeconds}s old'
                    : 'Bus location unavailable.',
            }),
            if (snapshot.age != null &&
                snapshot.age! > const Duration(seconds: 120))
              const Text('Position is too old for an arrival prediction.'),
            if (snapshot.pickupEta == null)
              const Text(
                'No current pickup prediction. This does not mean the bus has arrived.',
              )
            else
              Text(
                'Your pickup · ~${(snapshot.pickupEta!.durationSeconds / 60).ceil()} min · ${snapshot.pickupEta!.basis.name} estimate',
              ),
            for (final eta in snapshot.etas)
              ListTile(
                title: Text(snapshot.stopName(eta.stopOccurrenceId)),
                subtitle: Text(
                  '~${(eta.durationSeconds / 60).ceil()} min · ${eta.distanceMeters.round()} m · ${eta.basis.name} estimate',
                ),
                leading: Icon(
                  eta.stopOccurrenceId == snapshot.live.riderPickupOccurrenceId
                      ? Icons.place
                      : Icons.circle_outlined,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
