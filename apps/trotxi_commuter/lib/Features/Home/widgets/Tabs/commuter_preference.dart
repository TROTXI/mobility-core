import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'commute_picker.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/layout/responsive_layout.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/repositories/commute_repository.dart';

/// Requests ops review rather than silently editing a paid commute.
class CommutePreferencesPage extends StatefulWidget {
  const CommutePreferencesPage({super.key, required this.client});

  final CommuterApi client;

  @override
  State<CommutePreferencesPage> createState() => _CommutePreferencesPageState();
}

class _CommutePreferencesPageState extends State<CommutePreferencesPage> {
  CommuteRouteSelection? _routeSelection;
  bool _pauseIfWaitlisted = false;
  bool _busy = false;
  bool _loading = true;
  bool _editing = false;
  String? _error;
  List<CommuteRequest> _requests = [];
  wire.MembershipCommute? _currentCommute;
  bool _currentCommuteUnavailable = false;
  DateTime _requestedDate = DateTime.now().toUtc();
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
    }
    await _loadCurrentCommute();
    if (mounted) setState(() => _loading = false);
  }

  /// The commute the rider has paid for. A failure here must not block
  /// requesting a change, so it only hides the summary card.
  Future<void> _loadCurrentCommute() async {
    final meta = widget.client.metadata;
    try {
      final response = await widget.client.getRiderOwnApi().getMembership(
        xTrotxiClient: meta.app,
        xTrotxiBuild: meta.build,
        xTrotxiPlatform: meta.platform,
      );
      if (!mounted) return;
      setState(() {
        _currentCommute = response.data?.data.commute;
        _currentCommuteUnavailable = false;
      });
    } catch (_) {
      if (mounted) setState(() => _currentCommuteUnavailable = true);
    }
  }

  String _date(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _withdraw(CommuteRequest request) async {
    final generation = widget.client.sessionGeneration;
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
    if (confirmed != true ||
        !mounted ||
        generation != widget.client.sessionGeneration) {
      return;
    }
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
        builder: (context) => CommutePickerPage(client: widget.client),
      ),
    );
    if (selection == null || !mounted) return;
    setState(() => _routeSelection = selection);
  }

  Future<void> _onSavePreferences() async {
    final route = _routeSelection;
    if (_busy || _hasOpen || route == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _repository.submit(
        route.request(
          wire.Date(
            _requestedDate.year,
            _requestedDate.month,
            _requestedDate.day,
          ),
          _pauseIfWaitlisted,
          _note.text.trim(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Request sent to operations. Your commute has not changed yet.',
          ),
        ),
      );
      setState(() {
        _editing = false;
        _routeSelection = null;
        _pauseIfWaitlisted = false;
        _note.clear();
      });
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
      appBar: AppBar(title: const Text('Commute preferences')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
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
                  Text(
                    'Need a different route or time? Send us a request. Your current commute stays the same until the change is approved.',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _busy || _loading ? null : _refresh,
                    child: const Text('Refresh requests'),
                  ),
                  if (_loading) const LinearProgressIndicator(),
                  if (_error != null) Text(_error!, semanticsLabel: _error),
                  const SizedBox(height: 12),
                  _buildSectionTitle(context, 'My current commute'),
                  const SizedBox(height: 12),
                  _buildCurrentCommuteCard(context),
                  if (_requests.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Requested routes'),
                    const SizedBox(height: 4),
                  ],
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
                  if (!_hasOpen && !_editing) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _busy || _loading
                            ? null
                            : () => setState(() => _editing = true),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.actionPrimaryDefault,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Request a new route',
                          style: AppTypography.buttonAction.copyWith(
                            color: colors.actionOnPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (!_hasOpen && _editing) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'New route request'),
                    const SizedBox(height: 12),
                    _buildRouteCard(context),
                    const SizedBox(height: 28),
                    _buildSectionTitle(
                      context,
                      'Scheduled departures · Africa/Accra',
                    ),
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
                              final now = DateTime.now().toUtc();
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
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                              _editing = false;
                              _routeSelection = null;
                            }),
                      child: const Text('Cancel'),
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

  String _day(wire.Date date) => DateFormat(
    'd MMM yyyy',
  ).format(DateTime(date.year, date.month, date.day));

  Widget _buildCurrentCommuteCard(BuildContext context) {
    final colors = context.appColors;
    final commute = _currentCommute;
    // Outbound before return, whatever order the API listed them in.
    final legs = <wire.CommuteLegView>[...?commute?.legs]
      ..sort((a, b) => a.direction.name.compareTo(b.direction.name));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: commute == null
          ? Text(
              _loading
                  ? 'Loading your commute…'
                  : _currentCommuteUnavailable
                  ? "Couldn't load your current commute. Pull to refresh or try again."
                  : "You don't have a paid commute yet. Subscribe from the Wallet tab.",
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commute.routeName,
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                for (final leg in legs)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${leg.direction == wire.CommuteLegViewDirectionEnum.outbound ? 'Outbound' : 'Return'}'
                      ' · ${leg.localDeparture}\n'
                      '${leg.pickupName} → ${leg.dropoffName}',
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  commute.effectiveTo == null
                      ? 'Since ${_day(commute.effectiveFrom)}'
                      : '${_day(commute.effectiveFrom)} – ${_day(commute.effectiveTo!)}',
                  style: AppTypography.caption.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
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
            label: 'Outbound departure',
            time:
                _routeSelection?.outbound.choice.schedule.localDeparture ??
                'Choose departure',
            onTap: _onChangeRoute,
          ),
          Divider(height: 1, color: colors.borderSubtle, indent: 16),
          _TimeRow(
            label: 'Return departure',
            time:
                _routeSelection?.returning.choice.schedule.localDeparture ??
                'Choose departure',
            onTap: _onChangeRoute,
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

/// A selected scheduled departure; changing it reopens the schedule picker.
class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final String time;
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
              time,
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
