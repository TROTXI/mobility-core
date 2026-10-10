import 'package:flutter/material.dart';
import 'package:trotxi_client/commute_selection.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/repositories/commute_repository.dart'
    show commuteError;
import 'route_preview_page.dart';

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
  String _routeQuery = '';
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
    final colors = context.appColors;
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
    final routes = _routes
        .where((route) => route.name.toLowerCase().contains(_routeQuery))
        .toList();
    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          onPressed: _back,
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
              children: [
                _progress(context),
                const SizedBox(height: 28),
                Text(
                  switch (_step) {
                    _Step.route => 'Where are you travelling?',
                    _Step.departure =>
                      _returning
                          ? 'When will you head back?'
                          : 'When will you leave?',
                    _Step.pickup => 'Where should we pick you up?',
                    _Step.dropoff => 'Where will you get off?',
                  },
                  style: AppTypography.heading2.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  switch (_step) {
                    _Step.route =>
                      'Choose a route to see its departures and stops.',
                    _Step.departure =>
                      'Select the time that works for your ${_returning ? 'return' : 'outbound'} journey.',
                    _Step.pickup => 'Select the stop where you will board.',
                    _Step.dropoff => 'Select a stop after your pickup.',
                  },
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                if (_route != null && _step != _Step.route) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.backgroundSubtle,
                      border: Border.all(color: colors.borderSubtle),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.route_rounded,
                          color: colors.actionPrimaryDefault,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _route!.name,
                                style: AppTypography.label.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                              if (_outbound != null)
                                Text(
                                  'Outbound: ${_outbound!.pickup.name} → ${_outbound!.dropoff.name} · ${_outbound!.choice.schedule.localDeparture}',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_loading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: colors.actionPrimaryDefault,
                      ),
                    ),
                  )
                else if (_error != null)
                  _messageCard(
                    context,
                    icon: Icons.wifi_off_rounded,
                    title: 'Could not load choices',
                    message: commuteError(_error!),
                    action: 'Try again',
                    onAction: _route == null
                        ? _loadRoutes
                        : () => _selectRoute(_route!),
                  )
                else if (_step == _Step.route) ...[
                  TextField(
                    onChanged: (value) => setState(
                      () => _routeQuery = value.trim().toLowerCase(),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Search routes',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (routes.isEmpty)
                    _messageCard(
                      context,
                      icon: Icons.route_rounded,
                      title: _routes.isEmpty
                          ? 'No routes yet'
                          : 'No matching routes',
                      message: _routes.isEmpty
                          ? 'Routes will appear here when they are available.'
                          : 'Try a different route name.',
                    ),
                  for (final route in routes)
                    _choiceCard(
                      context,
                      icon: Icons.route_rounded,
                      title: route.name,
                      subtitle: route.description?.trim().isNotEmpty == true
                          ? route.description!.trim()
                          : 'View departures and stops',
                      onTap: () => _selectRoute(route),
                    ),
                ] else if (_step == _Step.departure) ...[
                  if (departures.isEmpty)
                    _messageCard(
                      context,
                      icon: Icons.schedule_rounded,
                      title: 'No departures available',
                      message: 'Go back and choose another route.',
                    ),
                  for (final choice in departures)
                    _choiceCard(
                      context,
                      icon: Icons.schedule_rounded,
                      title: choice.schedule.localDeparture,
                      subtitle: choice.schedule.weekdays
                          .map(
                            (day) => const [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun',
                            ][day - 1],
                          )
                          .join(' · '),
                      onTap: () => setState(() {
                        _choice = choice;
                        _step = _Step.pickup;
                      }),
                      onPreview: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => RouteChoicePreviewPage(
                            client: widget.client,
                            version: choice.version,
                            routeName: choice.route.name,
                            departureLabel:
                                '${_returning ? 'Return' : 'Outbound'} · ${choice.schedule.localDeparture}',
                          ),
                        ),
                      ),
                    ),
                ] else ...[
                  if (stops.isEmpty)
                    _messageCard(
                      context,
                      icon: Icons.location_off_outlined,
                      title: 'No stops available',
                      message:
                          'Go back and choose another departure or pickup.',
                    ),
                  for (final stop in stops)
                    _choiceCard(
                      context,
                      icon: _step == _Step.pickup
                          ? Icons.radio_button_checked_rounded
                          : Icons.location_on_rounded,
                      title: stop.name,
                      subtitle: _step == _Step.pickup
                          ? 'Board here'
                          : 'Get off here',
                      onTap: () => _step == _Step.pickup
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
        ),
      ),
    );
  }

  Widget _progress(BuildContext context) {
    final colors = context.appColors;
    final step = _Step.values.indexOf(_step);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _returning ? 'RETURN JOURNEY' : 'OUTBOUND JOURNEY',
          style: AppTypography.caption.copyWith(
            color: colors.actionPrimaryDefault,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var index = 0; index < _Step.values.length; index++) ...[
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index <= step
                        ? colors.actionPrimaryDefault
                        : colors.borderSubtle,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (index != _Step.values.length - 1) const SizedBox(width: 6),
            ],
          ],
        ),
      ],
    );
  }

  Widget _choiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    VoidCallback? onPreview,
  }) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.actionPrimaryDefault.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: colors.actionPrimaryDefault),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.buttonAction.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded, color: colors.iconSubtle),
                  ],
                ),
              ),
            ),
            if (onPreview != null) ...[
              Divider(height: 1, color: colors.borderSubtle),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Preview route and stops'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _messageCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    String? action,
    VoidCallback? onAction,
  }) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.backgroundSubtle,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.actionPrimaryDefault),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.buttonAction.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          if (action != null && onAction != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(action)),
          ],
        ],
      ),
    );
  }
}
