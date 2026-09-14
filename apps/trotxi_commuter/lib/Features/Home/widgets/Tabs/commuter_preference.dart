import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/config/layout/responsive_layout.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/repositories/commute_repository.dart';

/// The requested route and its ordered stops; approval changes the membership.
class CommuteRouteSelection {
  const CommuteRouteSelection({
    required this.routeId,
    required this.routeName,
    required this.pickupStopName,
    required this.destinationStopName,
    required this.pickupStopId,
    required this.destinationStopId,
  });

  final String routeId;
  final String routeName;
  final String pickupStopName;
  final String destinationStopName;
  final String pickupStopId;
  final String destinationStopId;
}

/// Requests ops review rather than silently editing a paid commute.
class CommutePreferencesPage extends StatefulWidget {
  const CommutePreferencesPage({super.key, required this.client});

  final TrotxiApiClient client;

  @override
  State<CommutePreferencesPage> createState() => _CommutePreferencesPageState();
}

class _CommutePreferencesPageState extends State<CommutePreferencesPage> {
  CommuteRouteSelection? _routeSelection;
  TimeOfDay _morningDeparture = const TimeOfDay(hour: 6, minute: 30);
  TimeOfDay _eveningReturn = const TimeOfDay(hour: 17, minute: 30);
  bool _pauseIfWaitlisted = false;
  bool _busy = false;
  bool _loading = true;
  String? _error;
  List<CommuteRequest> _requests = [];
  DateTime _requestedDate = DateTime.now();
  final _note = TextEditingController();
  late final _repository = CommuteRepository(widget.client);
  bool get _hasOpen => _requests.any((request) => request.isOpen);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final requests = await _repository.list();
      if (mounted) setState(() => _requests = requests);
    } catch (error) {
      if (mounted) setState(() => _error = commuteError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _date(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  String _time(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _withdraw(CommuteRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw commute request?'),
        content: const Text(
          'Your current commute stays unchanged. Any held transfer slot will be released.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep request'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await _repository.withdraw(request.id);
      await _refresh();
    } catch (error) {
      if (mounted) setState(() => _error = commuteError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onChangeRoute() async {
    final selection = await Navigator.of(context).push<CommuteRouteSelection>(
      MaterialPageRoute(
        builder: (context) => _RoutePickerPage(client: widget.client),
      ),
    );
    if (selection == null || !mounted) return;
    setState(() => _routeSelection = selection);
  }

  Future<void> _pickMorningDeparture() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _morningDeparture,
    );
    if (picked == null || !mounted) return;
    setState(() => _morningDeparture = picked);
  }

  Future<void> _pickEveningReturn() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _eveningReturn,
    );
    if (picked == null || !mounted) return;
    setState(() => _eveningReturn = picked);
  }

  Future<void> _onSavePreferences() async {
    final route = _routeSelection;
    if (_busy || _hasOpen || route == null) return;
    if (_morningDeparture.hour >= 12 || _eveningReturn.hour < 12) {
      setState(
        () => _error =
            'Choose a morning departure before noon and a return after noon.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _repository.submit({
        'routeId': route.routeId,
        'pickupStopId': route.pickupStopId,
        'dropoffStopId': route.destinationStopId,
        'morningDeparture': _time(_morningDeparture),
        'eveningReturn': _time(_eveningReturn),
        'requestedDate': _date(_requestedDate),
        'pauseIfWaitlisted': _pauseIfWaitlisted,
        'note': _note.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Request sent to operations. Your commute has not changed yet.',
          ),
        ),
      );
      await _refresh();
    } catch (error) {
      if (mounted) setState(() => _error = commuteError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final layout = ResponsiveLayoutInfo.of(context);
    final maxContentWidth = layout.select(
      phone: 520.0,
      tabletPortrait: 680.0,
      tabletLandscape: 960.0,
    );
    final horizontalPadding = layout.select(
      phone: 16.0,
      tabletPortrait: 24.0,
      tabletLandscape: 32.0,
    );

    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  TextButton(
                    onPressed: _busy || _loading ? null : _refresh,
                    child: const Text('Refresh requests'),
                  ),
                  if (_loading) const LinearProgressIndicator(),
                  if (_error != null) Text(_error!, semanticsLabel: _error),
                  for (final request in _requests)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${request.routeName} — ${request.status}'),
                            Text('Requested: ${request.requestedDate}'),
                            if (request.effectiveDate != null)
                              Text(
                                'Effective date: ${request.effectiveDate}. Operations applies the change when ready.',
                              ),
                            if (request.decisionNote != null)
                              Text(request.decisionNote!),
                            if (request.paused)
                              const Text(
                                'Subscription paused. Rides and remaining paid time are preserved. Contact operations to resume before withdrawing.',
                              ),
                            if (request.isOpen && !request.paused)
                              TextButton(
                                onPressed: _busy
                                    ? null
                                    : () => _withdraw(request),
                                child: const Text('Withdraw request'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  if (_hasOpen)
                    const Text(
                      'Your request is with operations. Refresh here for the decision; your current route stays assigned until the change is applied.',
                    ),
                  if (!_hasOpen) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Requested route'),
                    const SizedBox(height: 12),
                    _buildRouteCard(context),
                    const SizedBox(height: 28),
                    _buildSectionTitle(context, 'Preferred commute times'),
                    const SizedBox(height: 12),
                    _buildTimesCard(context),
                    const SizedBox(height: 28),
                    _buildSectionTitle(
                      context,
                      'When should the change start?',
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _requestedDate.isBefore(now)
                                    ? now
                                    : _requestedDate,
                                firstDate: now,
                                lastDate: DateTime(
                                  now.year + 1,
                                  now.month,
                                  now.day,
                                ),
                              );
                              if (picked != null && mounted) {
                                setState(() => _requestedDate = picked);
                              }
                            },
                      child: Text(_date(_requestedDate)),
                    ),
                    _RidePreferenceTile(
                      title: 'Allow a pause if waitlisted',
                      subtitle:
                          'Operations may pause my subscription while I wait. I cannot book rides while paused; unused rides and paid time are preserved.',
                      value: _pauseIfWaitlisted,
                      onChanged: (value) =>
                          setState(() => _pauseIfWaitlisted = value),
                    ),
                    TextField(
                      controller: _note,
                      maxLength: 1000,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Note for operations (optional)',
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: colors.actionPrimaryDefault,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap:
                              _busy ||
                                  _loading ||
                                  _error != null ||
                                  _routeSelection == null
                              ? null
                              : _onSavePreferences,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                _busy
                                    ? 'Sending…'
                                    : 'Send request to operations',
                                style: AppTypography.buttonAction.copyWith(
                                  color: colors.actionOnPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Semantics(
              button: true,
              label: 'Back',
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Commute preferences',
                style: AppTypography.title.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Moving or changing your commute? Request a new route and times. Operations checks availability before changing your subscription.',
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.appColors;
    return Text(
      title,
      style: AppTypography.label.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context) {
    final colors = context.appColors;
    final selection = _routeSelection;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _RouteEndpoint(
                  label: 'Pickup',
                  value: selection?.pickupStopName ?? 'Not set',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _RouteEndpoint(
                  label: 'Destination',
                  value: selection?.destinationStopName ?? 'Not set',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _onChangeRoute,
            child: Text(
              selection == null ? 'Choose route' : 'Change route',
              style: AppTypography.caption.copyWith(
                color: colors.actionPrimaryDefault,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimesCard(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _TimeRow(
            label: 'Morning departure',
            time: _morningDeparture,
            onTap: _pickMorningDeparture,
          ),
          Divider(height: 1, color: colors.borderSubtle, indent: 16),
          _TimeRow(
            label: 'Evening return',
            time: _eveningReturn,
            onTap: _pickEveningReturn,
          ),
        ],
      ),
    );
  }
}

/// The "Pickup"/"Destination" label + value pair shown in the route card.
class _RouteEndpoint extends StatelessWidget {
  const _RouteEndpoint({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.label.copyWith(color: colors.textPrimary),
        ),
      ],
    );
  }
}

/// A tappable row showing a commute time — opens the native time-picker
/// modal to change it.
class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            Text(
              time.format(context),
              style: AppTypography.label.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colors.iconSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

/// A pill-shaped switch row under "Ride preferences".
class _RidePreferenceTile extends StatelessWidget {
  const _RidePreferenceTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colors.actionPrimaryDefault,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Route + stop picker — real data from GET /routes and GET /routes/{id}
// ---------------------------------------------------------------------

enum _PickerStep { route, pickup, destination }

class _RoutePickerPage extends StatefulWidget {
  const _RoutePickerPage({required this.client});

  final TrotxiApiClient client;

  @override
  State<_RoutePickerPage> createState() => _RoutePickerPageState();
}

class _RoutePickerPageState extends State<_RoutePickerPage> {
  _PickerStep _step = _PickerStep.route;
  bool _loading = true;
  Object? _error;

  List<RoutesGet200ResponseInner> _routes = const [];
  RoutesGet200ResponseInner? _selectedRoute;
  List<RoutesIdGet200ResponseStopsInner> _stops = const [];
  RoutesIdGet200ResponseStopsInner? _pickupStop;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await widget.client.getMobilityApi().routesGet();
      if (!mounted) return;
      setState(() {
        _routes = response.data?.toList() ?? const [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
      debugPrint('Error loading routes: $e');
    }
  }

  Future<void> _selectRoute(RoutesGet200ResponseInner route) async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedRoute = route;
    });
    try {
      final response = await widget.client.getMobilityApi().routesIdGet(
        id: route.id,
      );
      if (!mounted) return;
      final stops = (response.data?.stops.toList() ?? [])
        ..sort((a, b) => a.seq.compareTo(b.seq));
      setState(() {
        _stops = stops;
        _loading = false;
        _step = _PickerStep.pickup;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
      debugPrint('Error loading stops for route ${route.id}: $e');
    }
  }

  void _selectPickup(RoutesIdGet200ResponseStopsInner stop) {
    setState(() {
      _pickupStop = stop;
      _step = _PickerStep.destination;
    });
  }

  void _selectDestination(RoutesIdGet200ResponseStopsInner stop) {
    final route = _selectedRoute;
    final pickup = _pickupStop;
    if (route == null || pickup == null) return;
    Navigator.of(context).pop(
      CommuteRouteSelection(
        routeId: route.id,
        routeName: route.name,
        pickupStopName: pickup.name,
        destinationStopName: stop.name,
        pickupStopId: pickup.id,
        destinationStopId: stop.id,
      ),
    );
  }

  void _handleBack() {
    switch (_step) {
      case _PickerStep.route:
        Navigator.of(context).pop();
      case _PickerStep.pickup:
        setState(() => _step = _PickerStep.route);
      case _PickerStep.destination:
        setState(() => _step = _PickerStep.pickup);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final title = switch (_step) {
      _PickerStep.route => 'Choose a route',
      _PickerStep.pickup => 'Choose pickup stop',
      _PickerStep.destination => 'Choose destination stop',
    };

    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Back',
                    child: InkWell(
                      onTap: _handleBack,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.appColors;
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: colors.actionPrimaryDefault),
      );
    }
    if (_error != null) {
      final selectedRoute = _selectedRoute;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load routes",
              style: AppTypography.label.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _step == _PickerStep.route || selectedRoute == null
                  ? _loadRoutes
                  : () => _selectRoute(selectedRoute),
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    return switch (_step) {
      _PickerStep.route => _buildRouteList(context),
      _PickerStep.pickup => _buildStopList(
        context,
        onTap: _selectPickup,
        excludeStopId: null,
      ),
      _PickerStep.destination => _buildStopList(
        context,
        onTap: _selectDestination,
        excludeStopId: _pickupStop?.id,
      ),
    };
  }

  Widget _buildRouteList(BuildContext context) {
    final colors = context.appColors;
    if (_routes.isEmpty) {
      return Center(
        child: Text(
          'No routes available yet.',
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      itemCount: _routes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final route = _routes[index];
        return _PickerTile(
          title: route.name,
          subtitle: route.description,
          onTap: () => _selectRoute(route),
        );
      },
    );
  }

  Widget _buildStopList(
    BuildContext context, {
    required ValueChanged<RoutesIdGet200ResponseStopsInner> onTap,
    required String? excludeStopId,
  }) {
    final colors = context.appColors;
    final stops = excludeStopId == null
        ? _stops.where((s) => s.seq < _stops.last.seq).toList()
        : _stops.where((s) => s.seq > _pickupStop!.seq).toList();
    if (stops.isEmpty) {
      return Center(
        child: Text(
          'No stops available on this route.',
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      itemCount: stops.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final stop = stops[index];
        return _PickerTile(title: stop.name, onTap: () => onTap(stop));
      },
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({required this.title, this.subtitle, required this.onTap});

  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.label.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      if (hasSubtitle) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTypography.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.iconSubtle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
