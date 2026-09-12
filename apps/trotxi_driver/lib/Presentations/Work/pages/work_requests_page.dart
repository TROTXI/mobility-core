import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/today_controller.dart';
import 'package:trotxi_driver/data/work_repository.dart';

/// Work routes and requests (prototype page 19).
///
/// One rule runs through every screen here, and it is the file's own:
/// "submitting a request never changes the active or published assignment
/// automatically". It holds in the API — nothing in that module writes to a
/// trip — and it is said plainly to drivers, because it is the thing they would
/// otherwise assume wrongly while waiting for an answer.
class WorkRequestsPage extends StatefulWidget {
  const WorkRequestsPage({super.key});

  @override
  State<WorkRequestsPage> createState() => _WorkRequestsPageState();
}

class _WorkRequestsPageState extends State<WorkRequestsPage> {
  late Future<List<WorkRequest>> _requests;

  @override
  void initState() {
    super.initState();
    _requests = context.read<WorkRepository>().mine();
  }

  void _reload() {
    setState(() {
      _requests = context.read<WorkRepository>().mine();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final board = context.watch<TodayController>().board.valueOrNull;
    final next = board?.active ?? board?.next;

    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        children: [
          Text(
            'Work & Requests',
            style: AppTypography.heading2.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            'Routes, schedule changes and time-away requests.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.space16),

          if (next != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.space16),
              decoration: BoxDecoration(
                color: colors.surfaceSelected,
                borderRadius: AppRadii.circular(AppRadii.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEXT ASSIGNMENT',
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    '${CorridorTime.hhmm(next.scheduledAt)} ${next.routeName}',
                    style: AppTypography.title.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
          ],

          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadii.circular(AppRadii.lg),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.alt_route_outlined, color: colors.action),
                  title: Text(
                    'Request route change',
                    style: AppTypography.body.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Ask operations to reassign a future run.',
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _open(const RouteChangeRequestPage()),
                ),
                Divider(height: 1, color: colors.border),
                ListTile(
                  leading: Icon(
                    Icons.event_busy_outlined,
                    color: colors.action,
                  ),
                  title: Text(
                    'Request leave',
                    style: AppTypography.body.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Submit dates and coverage information.',
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _open(const LeaveRequestPage()),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space24),
          Text(
            'YOUR REQUESTS',
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space8),
          FutureBuilder<List<WorkRequest>>(
            future: _requests,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.space24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return _Placeholder(
                  text: snapshot.error is TrotxiException
                      ? (snapshot.error! as TrotxiException).message
                      : 'Could not load your requests.',
                  onRetry: _reload,
                );
              }
              final requests = snapshot.data ?? [];
              if (requests.isEmpty) {
                return const _Placeholder(
                  text: 'You have not asked operations for anything yet.',
                );
              }
              return Column(
                children: [
                  for (final request in requests) ...[
                    _RequestCard(request: request, onChanged: _reload),
                    const SizedBox(height: AppSpacing.space12),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.space8),
          Text(
            // The control principle, said in the app rather than only in the
            // design file. A driver who assumes an approval moved them would
            // turn up at the wrong corridor.
            'Submitting a request never changes your current assignment. '
            'Operations has to approve it and publish the change.',
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space24),
        ],
      ),
    );
  }

  /// Push a request form and refresh the list when it comes back.
  ///
  /// @param page - the form to open.
  Future<void> _open(Widget page) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) _reload();
  }
}

/// One request and operations' answer.
class _RequestCard extends StatefulWidget {
  const _RequestCard({required this.request, required this.onChanged});

  final WorkRequest request;
  final VoidCallback onChanged;

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _withdrawing = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final request = widget.request;
    final tone = switch (request.status) {
      RequestStatus.pending => colors.warning,
      RequestStatus.approved => colors.success,
      RequestStatus.declined => colors.danger,
      RequestStatus.withdrawn => colors.textSecondary,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.kind.label,
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space8,
                  vertical: AppSpacing.space4,
                ),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.15),
                  borderRadius: AppRadii.circular(AppRadii.full),
                ),
                child: Text(
                  request.status.label,
                  style: AppTypography.caption.copyWith(color: tone),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            _detail(request),
            style: AppTypography.bodySmall.copyWith(color: colors.textPrimary),
          ),
          if (request.note != null) ...[
            const SizedBox(height: AppSpacing.space4),
            Text(
              request.note!,
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.space12),
          Container(
            padding: const EdgeInsets.all(AppSpacing.space12),
            decoration: BoxDecoration(
              color: colors.surfaceSelected,
              borderRadius: AppRadii.circular(AppRadii.md),
            ),
            child: Text(
              // What ops wrote, or what the status means. "Approved" alone
              // would leave a driver guessing whether to turn up somewhere new.
              request.decisionNote ?? request.status.detail,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          if (request.isPending) ...[
            const SizedBox(height: AppSpacing.space8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _withdrawing ? null : _withdraw,
                child: Text(_withdrawing ? 'Withdrawing…' : 'Withdraw'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// The one-line summary of what was asked for.
  ///
  /// @param request - the request.
  /// @returns the summary.
  static String _detail(WorkRequest request) {
    if (request.kind == RequestKind.leave) {
      return request.fromDate == request.toDate
          ? 'On ${request.fromDate}'
          : '${request.fromDate} to ${request.toDate}';
    }
    final route = request.routeName ?? 'another corridor';
    return request.fromDate == null
        ? 'Move to $route'
        : 'Move to $route from ${request.fromDate}';
  }

  Future<void> _withdraw() async {
    setState(() => _withdrawing = true);
    final work = context.read<WorkRepository>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await work.withdraw(widget.request.id);
      widget.onChanged();
    } on TrotxiException catch (err) {
      messenger.showSnackBar(SnackBar(content: Text(err.message)));
    } on Object {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not withdraw that request.')),
      );
    } finally {
      if (mounted) setState(() => _withdrawing = false);
    }
  }
}

/// Ask to be moved to another corridor (prototype page 19).
class RouteChangeRequestPage extends StatefulWidget {
  const RouteChangeRequestPage({super.key});

  @override
  State<RouteChangeRequestPage> createState() => _RouteChangeRequestPageState();
}

class _RouteChangeRequestPageState extends State<RouteChangeRequestPage> {
  late Future<List<OpenRoute>> _routes;
  OpenRoute? _selected;
  DateTime? _from;
  final _note = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _routes = context.read<WorkRepository>().openRoutes();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return Scaffold(
      appBar: AppBar(title: const Text('Request route change')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          children: [
            Text(
              'Which corridor?',
              style: AppTypography.title.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              // The design's rule, and the reason this list is short. Showing
              // every corridor would collect requests that could only ever be
              // declined.
              'Routes appear here only when operations can accept reassignment '
              'requests for them.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space16),

            FutureBuilder<List<OpenRoute>>(
              future: _routes,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.space24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return _Placeholder(
                    text: snapshot.error is TrotxiException
                        ? (snapshot.error! as TrotxiException).message
                        : 'Could not load the open routes.',
                    onRetry: () => setState(() {
                      _routes = context.read<WorkRepository>().openRoutes();
                    }),
                  );
                }
                final routes = snapshot.data ?? [];
                if (routes.isEmpty) {
                  return const _Placeholder(
                    text:
                        'Operations is not accepting reassignment requests for '
                        'any corridor right now.',
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppRadii.circular(AppRadii.lg),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      for (final route in routes) ...[
                        ListTile(
                          title: Text(
                            route.name,
                            style: AppTypography.body.copyWith(
                              color: _selected?.id == route.id
                                  ? colors.action
                                  : colors.textPrimary,
                            ),
                          ),
                          subtitle: route.description == null
                              ? null
                              : Text(
                                  route.description!,
                                  style: AppTypography.caption.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                          trailing: _selected?.id == route.id
                              ? Icon(Icons.check_circle, color: colors.action)
                              : Icon(
                                  Icons.circle_outlined,
                                  color: colors.textSecondary,
                                ),
                          onTap: _sending
                              ? null
                              : () => setState(() => _selected = route),
                        ),
                        if (route != routes.last)
                          Divider(height: 1, color: colors.border),
                      ],
                    ],
                  ),
                );
              },
            ),

            if (_selected != null) ...[
              const SizedBox(height: AppSpacing.space24),
              _DateRow(
                label: 'From (optional)',
                value: _from,
                hint: 'As soon as operations can',
                enabled: !_sending,
                onPick: (picked) => setState(() => _from = picked),
                onClear: () => setState(() => _from = null),
              ),
              const SizedBox(height: AppSpacing.space16),
              TextField(
                controller: _note,
                enabled: !_sending,
                maxLines: 3,
                maxLength: 1000,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Why (optional)',
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.circular(AppRadii.md),
                  ),
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: AppSpacing.space12),
              _ErrorBox(message: _error!),
            ],

            const SizedBox(height: AppSpacing.space16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selected == null || _sending ? null : _send,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.circular(AppRadii.full),
                  ),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('SEND REQUEST'),
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              'Your current assignment does not change while operations decides.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    final work = context.read<WorkRepository>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await work.requestRouteChange(
        routeId: _selected!.id,
        fromDate: _from == null ? null : CorridorTime.calendarDay(_from!),
        note: _note.text,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Sent to operations.')),
      );
      navigator.pop();
    } on TrotxiException catch (err) {
      if (mounted) {
        setState(() {
          _error = err.message;
          _sending = false;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _error = 'The request did not send. Check your signal and try again.';
          _sending = false;
        });
      }
    }
  }
}

/// Ask for days off (prototype page 19).
class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  DateTime? _from;
  DateTime? _to;
  final _note = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return Scaffold(
      appBar: AppBar(title: const Text('Request leave')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          children: [
            Text(
              'Which days?',
              style: AppTypography.title.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space16),
            _DateRow(
              label: 'First day',
              value: _from,
              hint: 'Pick a date',
              enabled: !_sending,
              onPick: (picked) => setState(() {
                _from = picked;
                // A range that runs backwards is refused by the database
                // constraint; fixing it here means the driver never meets it.
                if (_to != null && _to!.isBefore(picked)) _to = picked;
              }),
            ),
            const SizedBox(height: AppSpacing.space12),
            _DateRow(
              label: 'Last day',
              value: _to,
              hint: 'Pick a date',
              enabled: !_sending,
              firstDate: _from,
              onPick: (picked) => setState(() => _to = picked),
            ),
            const SizedBox(height: AppSpacing.space16),
            TextField(
              controller: _note,
              enabled: !_sending,
              maxLines: 3,
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Cover and reason',
                hintText: 'Who can take your runs, and why you need the days.',
                border: OutlineInputBorder(
                  borderRadius: AppRadii.circular(AppRadii.md),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: AppSpacing.space12),
              _ErrorBox(message: _error!),
            ],

            const SizedBox(height: AppSpacing.space16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _from == null || _to == null || _sending
                    ? null
                    : _send,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.circular(AppRadii.full),
                  ),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('SEND REQUEST'),
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              'You stay rostered on your published runs until operations '
              'answers.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    final work = context.read<WorkRepository>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await work.requestLeave(
        fromDate: CorridorTime.calendarDay(_from!),
        toDate: CorridorTime.calendarDay(_to!),
        note: _note.text,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Sent to operations.')),
      );
      navigator.pop();
    } on TrotxiException catch (err) {
      if (mounted) {
        setState(() {
          _error = err.message;
          _sending = false;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _error = 'The request did not send. Check your signal and try again.';
          _sending = false;
        });
      }
    }
  }
}

/// A labelled date, tappable to change.
class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.hint,
    required this.enabled,
    required this.onPick,
    this.onClear,
    this.firstDate,
  });

  final String label;
  final DateTime? value;
  final String hint;
  final bool enabled;
  final ValueChanged<DateTime> onPick;
  final VoidCallback? onClear;

  /// Lower bound, so a leave range cannot be built backwards.
  final DateTime? firstDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final today = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.md),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        enabled: enabled,
        title: Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
        subtitle: Text(
          value == null ? hint : DateFormat('EEE d MMM y').format(value!),
          style: AppTypography.body.copyWith(
            color: value == null ? colors.textSecondary : colors.textPrimary,
          ),
        ),
        trailing: value != null && onClear != null
            ? IconButton(
                onPressed: enabled ? onClear : null,
                icon: const Icon(Icons.close),
              )
            : const Icon(Icons.calendar_today_outlined),
        onTap: enabled
            ? () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: value ?? firstDate ?? today,
                  firstDate: firstDate ?? today,
                  lastDate: today.add(const Duration(days: 365)),
                );
                if (picked != null) onPick(picked);
              }
            : null,
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.1),
        borderRadius: AppRadii.circular(AppRadii.md),
        border: Border.all(color: colors.danger),
      ),
      child: Text(
        message,
        style: AppTypography.bodySmall.copyWith(color: colors.danger),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.space12),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ],
      ),
    );
  }
}
