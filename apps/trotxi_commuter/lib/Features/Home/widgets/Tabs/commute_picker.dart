import 'package:flutter/material.dart';
import 'package:trotxi_client/commute_selection.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/repositories/commute_repository.dart'
    show commuteError;

class SelectedCommuteLeg {
  const SelectedCommuteLeg(this.choice, this.pickup, this.dropoff);
  final CommuteLegChoice choice;
  final wire.StopOccurrence pickup, dropoff;
}

class CommuteRouteSelection {
  const CommuteRouteSelection(this.outbound, this.returning);
  final SelectedCommuteLeg outbound, returning;
  String get routeName => outbound.choice.route.name;
  String get pickupStopName => outbound.pickup.name;
  String get destinationStopName => outbound.dropoff.name;
  wire.CommuteRequestInput request(wire.Date date, bool pause, String note) =>
      buildCommuteRequest(
        outbound: outbound.choice,
        outboundPickup: outbound.pickup.id,
        outboundDropoff: outbound.dropoff.id,
        returning: returning.choice,
        returnPickup: returning.pickup.id,
        returnDropoff: returning.dropoff.id,
        requestedDate: date,
        pauseIfWaitlisted: pause,
        note: note.isEmpty ? null : note,
      );
}

enum _Step { route, departure, pickup, dropoff }

class CommutePickerPage extends StatefulWidget {
  const CommutePickerPage({super.key, required this.client});
  final CommuterApi client;
  @override
  State<CommutePickerPage> createState() => _CommutePickerPageState();
}

class _CommutePickerPageState extends State<CommutePickerPage> {
  _Step _step = _Step.route;
  bool _loading = true;
  Object? _error;
  int _attempt = 0;
  List<wire.Route> _routes = [];
  List<CommuteLegChoice> _choices = [];
  wire.Route? _route;
  CommuteLegChoice? _choice;
  wire.StopOccurrence? _pickup;
  SelectedCommuteLeg? _outbound;
  bool get _returning => _outbound != null;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  @override
  void dispose() {
    _attempt++;
    super.dispose();
  }

  Future<void> _loadRoutes() async {
    final attempt = ++_attempt;
    setState(() {
      _loading = true;
      _error = null;
      _step = _Step.route;
    });
    try {
      final routes = await widget.client.routes();
      if (mounted && attempt == _attempt) setState(() => _routes = routes);
    } catch (e) {
      if (mounted && attempt == _attempt) setState(() => _error = e);
    } finally {
      if (mounted && attempt == _attempt) setState(() => _loading = false);
    }
  }

  Future<void> _selectRoute(wire.Route route) async {
    final attempt = ++_attempt;
    final generation = widget.client.sessionGeneration;
    setState(() {
      _loading = true;
      _error = null;
      _route = route;
      _outbound = null;
    });
    try {
      final schedules = await widget.client.schedules(route.id);
      final patterns = <wire.Pattern>[];
      for (final id in schedules.map((s) => s.patternId).toSet()) {
        widget.client.ensureSession(generation);
        patterns.add(await widget.client.pattern(id));
      }
      // The schedule names its exact parent and version. Current route links
      // need not contain a future or retired pattern used by this departure.
      final versions = <String, wire.PatternVersion>{};
      for (final schedule in schedules) {
        if (versions.containsKey(schedule.patternVersionId)) continue;
        widget.client.ensureSession(generation);
        versions[schedule.patternVersionId] = await widget.client
            .patternVersion(schedule.patternId, schedule.patternVersionId);
      }
      widget.client.ensureSession(generation);
      final choices =
          [
            for (final schedule in schedules)
              CommuteLegChoice(
                route: route,
                pattern: patterns.singleWhere(
                  (p) => p.id == versions[schedule.patternVersionId]!.patternId,
                ),
                version: versions[schedule.patternVersionId]!,
                schedule: schedule,
              ),
          ]..sort(
            (a, b) =>
                a.schedule.localDeparture.compareTo(b.schedule.localDeparture),
          );
      if (mounted && attempt == _attempt) {
        setState(() {
          _choices = choices;
          _step = _Step.departure;
        });
      }
    } catch (e) {
      if (mounted && attempt == _attempt) setState(() => _error = e);
    } finally {
      if (mounted && attempt == _attempt) setState(() => _loading = false);
    }
  }

  void _back() {
    if (_loading) {
      _attempt++;
      setState(() {
        _loading = false;
        _error = null;
        _step = _Step.route;
      });
      return;
    }
    setState(() {
      _error = null;
      switch (_step) {
        case _Step.route:
          Navigator.pop(context);
        case _Step.departure:
          if (_returning) {
            _outbound = null;
          } else {
            _step = _Step.route;
          }
        case _Step.pickup:
          _step = _Step.departure;
        case _Step.dropoff:
          _step = _Step.pickup;
      }
    });
  }

  void _dropoff(wire.StopOccurrence stop) {
    final leg = SelectedCommuteLeg(_choice!, _pickup!, stop);
    if (!_returning) {
      setState(() {
        _outbound = leg;
        _choice = null;
        _pickup = null;
        _step = _Step.departure;
      });
    } else {
      Navigator.pop(context, CommuteRouteSelection(_outbound!, leg));
    }
  }

  @override
  Widget build(BuildContext context) {
    final direction = _returning ? 'return' : 'outbound';
    final title = switch (_step) {
      _Step.route => 'Choose a route',
      _Step.departure => 'Choose $direction departure',
      _Step.pickup => 'Choose $direction pickup',
      _Step.dropoff => 'Choose $direction destination',
    };
    final departures = _choices
        .where(
          (c) =>
              c.pattern.direction ==
                  (_returning
                      ? wire.PatternDirectionEnum.return_
                      : wire.PatternDirectionEnum.outbound) &&
              (!_returning ||
                  c.schedule.serviceWindow !=
                      _outbound!.choice.schedule.serviceWindow),
        )
        .toList();
    final stops = _choice == null
        ? <wire.StopOccurrence>[]
        : _step == _Step.pickup
        ? _choice!.pickups
        : _pickup == null
        ? <wire.StopOccurrence>[]
        : _choice!.dropoffsAfter(_pickup!.id);
    return Scaffold(
      backgroundColor: context.appColors.backgroundDefault,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          onPressed: _back,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(commuteError(_error!)),
                    ),
                    TextButton(
                      onPressed: _route == null
                          ? _loadRoutes
                          : () => _selectRoute(_route!),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_step == _Step.route) ...[
                    if (_routes.isEmpty) const Text('No routes available yet.'),
                    for (final route in _routes)
                      _tile(
                        route.name,
                        route.description,
                        () => _selectRoute(route),
                      ),
                  ] else if (_step == _Step.departure) ...[
                    if (departures.isEmpty)
                      const Text(
                        'No compatible departures available. Choose another route or contact operations.',
                      ),
                    for (final c in departures)
                      _tile(
                        '${c.schedule.localDeparture} · Africa/Accra',
                        'Service days: ${c.schedule.weekdays.map((d) => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1]).join(', ')}',
                        () => setState(() {
                          _choice = c;
                          _step = _Step.pickup;
                        }),
                      ),
                  ] else ...[
                    for (final stop in stops)
                      _tile(
                        stop.name,
                        'Stop occurrence ${stop.ordinal}',
                        () => _step == _Step.pickup
                            ? setState(() {
                                _pickup = stop;
                                _step = _Step.dropoff;
                              })
                            : _dropoff(stop),
                      ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _tile(String title, String? subtitle, VoidCallback onTap) => Card(
    child: ListTile(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
