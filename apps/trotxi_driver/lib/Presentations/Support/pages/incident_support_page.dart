import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/config_controller.dart';
import 'package:trotxi_driver/core/state/today_controller.dart';
import 'package:trotxi_driver/core/widgets/driver_chip.dart';
import 'package:trotxi_driver/core/widgets/operations_contact.dart';
import 'package:trotxi_driver/data/incidents_repository.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// Incident and support (prototype page 15).
///
/// The escalation hierarchy is the point: "urgent safety actions remain
/// visually distinct from routine support and reporting". Emergency help is a
/// filled danger control standing alone; everything else is a quiet row. That
/// ordering is a safety decision rather than a layout preference.
///
/// Emergency dials operations. It does not file anything, and that is the
/// design's rule carried through to the API, which refuses `emergency` as a
/// category: a crash must not queue behind a broken wiper.
class IncidentSupportPage extends StatelessWidget {
  const IncidentSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final config = context.watch<ConfigController>();
    final active = context.watch<TodayController>().board.valueOrNull?.active;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      children: [
        Text(
          'Incident & support',
          style: AppTypography.heading2.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.space4),
        Text(
          active == null
              ? 'No active trip'
              : 'Active trip · ${_runLabel(active)}',
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space16),

        // Before any of the actions, because every one of them takes a driver's
        // attention off the road.
        Container(
          padding: const EdgeInsets.all(AppSpacing.space16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadii.circular(AppRadii.lg),
            border: Border.all(color: colors.warning),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stop safely before using support',
                style: AppTypography.label.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'Do not report or call while the vehicle is moving.',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space16),

        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadii.circular(AppRadii.lg),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.support_agent_outlined, color: colors.action),
                title: Text(
                  'Operations support',
                  style: AppTypography.body.copyWith(color: colors.textPrimary),
                ),
                subtitle: Text(
                  config.operations.canCall
                      ? 'Call the control room for immediate trip assistance.'
                      : 'No number published by your operator.',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                enabled: config.operations.canCall,
                onTap: config.operations.canCall
                    ? () => _call(context, config.operations.phone!)
                    : null,
              ),
              Divider(height: 1, color: colors.border),
              ListTile(
                leading: Icon(Icons.report_outlined, color: colors.action),
                title: Text(
                  'Report incident',
                  style: AppTypography.body.copyWith(color: colors.textPrimary),
                ),
                subtitle: Text(
                  'Vehicle, road, passenger safety or route problems.',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReportIncidentPage(activeRun: active),
                  ),
                ),
              ),
              Divider(height: 1, color: colors.border),
              ListTile(
                leading: Icon(Icons.history_outlined, color: colors.action),
                title: Text(
                  'My reports',
                  style: AppTypography.body.copyWith(color: colors.textPrimary),
                ),
                subtitle: Text(
                  'What you have sent, and what operations said.',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const MyReportsPage()),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.space16),
        OperationsContactCard(
          contact: config.operations,
          isLoaded: config.isLoaded,
        ),

        const SizedBox(height: AppSpacing.space16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            // Disabled rather than hidden when no number is configured. A driver
            // who has looked for emergency help once must find it in the same
            // place the next time; its absence would read as "not available".
            onPressed: config.operations.canCall
                ? () => _call(context, config.operations.phone!)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: colors.danger,
              disabledBackgroundColor: colors.danger.withValues(alpha: 0.45),
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.circular(AppRadii.full),
              ),
            ),
            child: Text('EMERGENCY HELP', style: AppTypography.label),
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        Text(
          config.operations.canCall
              ? 'Emergency help calls operations directly. It does not file a '
                    'report — say what has happened.'
              : 'Your operator has not published an emergency number. Ask at '
                    'the depot office.',
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space24),
      ],
    );
  }

  /// Dial, falling back to showing the number when the handset will not.
  ///
  /// @param context - for the fallback message.
  /// @param phone - the number to dial.
  static Future<void> _call(BuildContext context, String phone) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!await dialOperations(phone)) {
      messenger.showSnackBar(SnackBar(content: Text('Dial $phone')));
    }
  }

  /// "7:40 Madina · Circle", the label every frame uses for a run.
  ///
  /// @param run - the active run.
  /// @returns the label.
  static String _runLabel(DriverRun run) =>
      '${CorridorTime.hhmm(run.scheduledAt)} ${run.routeName}';
}

/// Report an incident (prototype page 15, select and review).
///
/// Two steps in one screen. The file separates them into frames, but the review
/// step is only a summary of the choice plus trip context a driver never edits,
/// and a second screen is a second thing to navigate at a roadside.
class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({super.key, this.activeRun});

  /// The run to attach, when one is under way. Null is allowed and useful: a
  /// broken door found in the yard at 05:20 is exactly the report worth filing,
  /// and the API accepts one with no trip.
  final DriverRun? activeRun;

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  IncidentCategory? _selected;
  final _note = TextEditingController();
  bool _sending = false;
  String? _error;

  /// Where the device thinks it is. Read once when the driver picks a category
  /// rather than on every keystroke, and never blocking: a report from a dead
  /// spot is still worth more than no report.
  Position? _position;
  bool _locating = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return Scaffold(
      appBar: AppBar(title: const Text('Report an incident')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          children: [
            Text(
              'What happened?',
              style: AppTypography.title.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Select one issue. You can review everything before sending.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space16),

            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadii.circular(AppRadii.lg),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                children: [
                  for (final category in IncidentCategory.values) ...[
                    ListTile(
                      title: Text(
                        category.label,
                        style: AppTypography.body.copyWith(
                          color: _selected == category
                              ? colors.action
                              : colors.textPrimary,
                        ),
                      ),
                      trailing: _selected == category
                          ? Icon(Icons.check_circle, color: colors.action)
                          : Icon(
                              Icons.circle_outlined,
                              color: colors.textSecondary,
                            ),
                      onTap: _sending ? null : () => _choose(category),
                    ),
                    if (category != IncidentCategory.values.last)
                      Divider(height: 1, color: colors.border),
                  ],
                ],
              ),
            ),

            if (_selected != null) ...[
              const SizedBox(height: AppSpacing.space24),
              Text(
                'ANYTHING ELSE OPERATIONS SHOULD KNOW',
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              TextField(
                controller: _note,
                enabled: !_sending,
                maxLines: 3,
                maxLength: 2000,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: _selected == IncidentCategory.other
                      ? 'Required for "Other issue" — say what happened.'
                      : 'Optional.',
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.circular(AppRadii.md),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.space8),
              Text(
                'ATTACHED TO THIS REPORT',
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppRadii.circular(AppRadii.lg),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    _Attached(
                      label: 'Trip',
                      value: widget.activeRun == null
                          ? 'No active trip'
                          : IncidentSupportPage._runLabel(widget.activeRun!),
                      ok: widget.activeRun != null,
                    ),
                    _Attached(
                      label: 'Vehicle',
                      // Resolved by the SERVER from the trip, not sent from
                      // here: a report is evidence, and the field ops most
                      // needs to trust should not be one this app can get wrong.
                      value: widget.activeRun == null
                          ? 'None — no trip to take it from'
                          : 'From the assignment',
                      ok: widget.activeRun != null,
                    ),
                    _Attached(
                      label: 'Time',
                      value: DateFormat('HH:mm').format(DateTime.now()),
                      ok: true,
                    ),
                    _Attached(
                      label: 'Location',
                      value: _locationLabel,
                      ok: _position != null,
                    ),
                  ],
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: AppSpacing.space12),
              Container(
                padding: const EdgeInsets.all(AppSpacing.space12),
                decoration: BoxDecoration(
                  color: colors.danger.withValues(alpha: 0.1),
                  borderRadius: AppRadii.circular(AppRadii.md),
                  border: Border.all(color: colors.danger),
                ),
                child: Text(
                  _error!,
                  style: AppTypography.bodySmall.copyWith(color: colors.danger),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.space16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canSend ? _send : null,
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
                    : const Text('SEND REPORT'),
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              'Continue only when the vehicle is safely stopped.',
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

  /// "Other issue" with no words is a row nobody can act on, so it is the one
  /// category that needs the note.
  bool get _canSend {
    if (_selected == null || _sending) return false;
    if (_selected == IncidentCategory.other) return _note.text.trim().isNotEmpty;
    return true;
  }

  String get _locationLabel {
    if (_locating) return 'Reading…';
    final position = _position;
    if (position == null) return 'Not available on this device';
    return '${position.latitude.toStringAsFixed(4)}, '
        '${position.longitude.toStringAsFixed(4)}';
  }

  /// Pick a category, and start reading the position in the background.
  ///
  /// @param category - the chosen category.
  void _choose(IncidentCategory category) {
    setState(() {
      _selected = category;
      _error = null;
    });
    if (_position == null && !_locating) unawaitedLocate();
  }

  /// Read the device position, current if it comes quickly and last-known
  /// otherwise, exactly as the screen's copy promises.
  ///
  /// Never throws and never blocks the report. A refused permission or a dead
  /// spot means the report goes without coordinates, which is worth far more
  /// than no report.
  void unawaitedLocate() {
    setState(() => _locating = true);
    () async {
      Position? found;
      try {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          found = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 6),
            ),
          );
        }
      } on Exception {
        found = null;
      }
      // The "or last-known" half. A driver stopped under a flyover has no fix
      // now but had one two minutes ago, and that is the useful answer.
      found ??= await _lastKnown();
      if (mounted) {
        setState(() {
          _position = found;
          _locating = false;
        });
      }
    }();
  }

  /// The last fix the platform kept, or null.
  ///
  /// @returns the position, or null when there is none.
  Future<Position?> _lastKnown() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } on Exception {
      return null;
    }
  }

  /// Send the report and leave the screen on success.
  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });

    final incidents = context.read<IncidentsRepository>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await incidents.file(
        category: _selected!,
        tripId: widget.activeRun?.id,
        note: _note.text,
        lat: _position?.latitude,
        lng: _position?.longitude,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Report sent. Operations can see it now.'),
        ),
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
          _error = 'The report did not send. Check your signal and try again.';
          _sending = false;
        });
      }
    }
  }
}

/// One line of the "attached to this report" summary.
class _Attached extends StatelessWidget {
  const _Attached({
    required this.label,
    required this.value,
    required this.ok,
  });

  final String label;
  final String value;

  /// Whether the thing is actually attached. A missing trip or position is
  /// shown rather than hidden, because the screen told the driver all four
  /// travel with the report and an absent one changes what operations receives.
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return ListTile(
      dense: true,
      leading: Icon(
        ok ? Icons.check_circle_outline : Icons.remove_circle_outline,
        color: ok ? colors.success : colors.textSecondary,
        size: 20,
      ),
      title: Text(
        label,
        style: AppTypography.bodySmall.copyWith(color: colors.textPrimary),
      ),
      trailing: Text(
        value,
        style: AppTypography.caption.copyWith(color: colors.textSecondary),
      ),
    );
  }
}

/// The driver's own reports and what operations said (#226).
///
/// Worth its own screen: a report with no visible answer is indistinguishable
/// from one that never sent, and a driver who thinks nothing happened files it
/// again.
class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  late Future<List<DriverIncident>> _reports;

  @override
  void initState() {
    super.initState();
    _reports = context.read<IncidentsRepository>().mine();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return Scaffold(
      appBar: AppBar(title: const Text('My reports')),
      body: SafeArea(
        child: FutureBuilder<List<DriverIncident>>(
          future: _reports,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _Message(
                text: snapshot.error is TrotxiException
                    ? (snapshot.error! as TrotxiException).message
                    : 'Could not load your reports.',
                onRetry: () => setState(() {
                  _reports = context.read<IncidentsRepository>().mine();
                }),
              );
            }
            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return const _Message(text: 'You have not sent any reports.');
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.space16),
              itemCount: reports.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.space12),
              itemBuilder: (context, i) =>
                  _ReportCard(report: reports[i], colors: colors),
            );
          },
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.colors});

  final DriverIncident report;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
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
                  report.category.label,
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              DriverChip(
                label: report.status.label,
                status: switch (report.status) {
                  IncidentStatus.open => DriverStatus.warning,
                  IncidentStatus.acknowledged => DriverStatus.ready,
                  IncidentStatus.resolved => DriverStatus.boarded,
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            '${CorridorTime.day(report.occurredAt)} · '
            '${CorridorTime.hhmm(report.occurredAt)}',
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          if (report.note != null) ...[
            const SizedBox(height: AppSpacing.space8),
            Text(
              report.note!,
              style: AppTypography.bodySmall.copyWith(
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
              // The answer, or an honest statement that there is not one yet.
              // "Operations has not opened it" is a real answer; silence is not.
              report.resolution ?? report.status.detail,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.space16),
              OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}
