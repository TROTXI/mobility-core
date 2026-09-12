import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/widgets/driver_chip.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// Schedule and future trips (prototype page 18).
///
/// One request per month, not thirty-one: `GET /me/trips?from=&to=` (#231).
/// The grid marks the days that carry work and the agenda below shows the day
/// the driver tapped, both off the same fetch.
///
/// "Planning principle: show only driver-assigned duties" — not a roster of
/// everything the depot runs, only what this driver has been given.
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  // Both in the corridor's clock, not the device's. West of UTC in the evening
  // the corridor has already rolled over, so opening on the local date would
  // land the driver on a day with no work while their real next run sits on the
  // cell beside it.
  DateTime _month = DateTime(
    CorridorTime.todayDate().year,
    CorridorTime.todayDate().month,
  );
  DateTime _selected = CorridorTime.todayDate();

  /// The month's runs, grouped by corridor day. Empty until the first fetch
  /// lands, which is why the grid marks nothing rather than marking wrongly.
  Map<String, List<DriverRun>> _byDay = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Fetch the visible month in one request.
  ///
  /// The range covers the whole month rather than only the cells drawn, which
  /// keeps the grid and the agenda reading from the same set — a day agenda
  /// that disagreed with its own dot is worse than either being absent.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final trips = context.read<TripsRepository>();
    final first = DateTime(_month.year, _month.month);
    final last = DateTime(_month.year, _month.month + 1, 0);

    try {
      final runs = await trips.myRuns(
        from: CorridorTime.calendarDay(first),
        to: CorridorTime.calendarDay(last),
      );
      final grouped = <String, List<DriverRun>>{};
      for (final run in runs) {
        // Grouped on the run's own corridor day, the same day the API filtered
        // on. Grouping on a device-local day would scatter a corridor's evening
        // runs across two cells anywhere but Accra.
        grouped.putIfAbsent(CorridorTime.day(run.scheduledAt), () => []).add(run);
      }
      if (mounted) {
        setState(() {
          _byDay = grouped;
          _loading = false;
        });
      }
    } on TrotxiException catch (err) {
      if (mounted) {
        setState(() {
          _error = err.message;
          _loading = false;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _error = 'Could not load your schedule.';
          _loading = false;
        });
      }
    }
  }

  /// Step a month and refetch.
  ///
  /// @param delta - months to move, negative for back.
  void _stepMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final selectedRuns = _byDay[CorridorTime.calendarDay(_selected)] ?? const [];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        children: [
          Text(
            'Schedule',
            style: AppTypography.heading2.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            'Only the runs assigned to you.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.space16),

          Container(
            padding: const EdgeInsets.all(AppSpacing.space12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadii.circular(AppRadii.lg),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _loading ? null : () => _stepMonth(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        DateFormat('MMMM yyyy').format(_month),
                        textAlign: TextAlign.center,
                        style: AppTypography.label.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loading ? null : () => _stepMonth(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space8),
                _MonthGrid(
                  month: _month,
                  selected: _selected,
                  byDay: _byDay,
                  colors: colors,
                  onSelect: (day) => setState(() => _selected = day),
                ),
                if (_loading) ...[
                  const SizedBox(height: AppSpacing.space8),
                  const LinearProgressIndicator(minHeight: 2),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space16),

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.space16),
              decoration: BoxDecoration(
                color: colors.danger.withValues(alpha: 0.1),
                borderRadius: AppRadii.circular(AppRadii.md),
                border: Border.all(color: colors.danger),
              ),
              child: Column(
                children: [
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.danger,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  OutlinedButton(
                    onPressed: _load,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
          ],

          Text(
            DateFormat('EEEE, d MMMM').format(_selected).toUpperCase(),
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space8),

          if (selectedRuns.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space24),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadii.circular(AppRadii.lg),
                border: Border.all(color: colors.border),
              ),
              child: Text(
                _loading ? 'Loading…' : 'Nothing assigned on this day.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            )
          else
            for (final run in selectedRuns) ...[
              _AgendaRow(run: run, colors: colors),
              const SizedBox(height: AppSpacing.space8),
            ],
          const SizedBox(height: AppSpacing.space24),
        ],
      ),
    );
  }
}

/// One run in the day agenda.
class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.run, required this.colors});

  final DriverRun run;
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
      child: Row(
        children: [
          Text(
            CorridorTime.hhmm(run.scheduledAt),
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  run.routeName,
                  style: AppTypography.body.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  switch (run.status) {
                    RunStatus.active => 'Running now',
                    RunStatus.completed => 'Finished',
                    RunStatus.cancelled => 'Cancelled',
                    RunStatus.scheduled => 'Scheduled',
                  },
                  style: AppTypography.caption.copyWith(
                    color: run.status == RunStatus.cancelled
                        ? colors.danger
                        : colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Read from `assignmentChangedAt` rather than from a push (#233), so
          // it survives a notification the phone never received.
          if (run.wasRecentlyChanged)
            const DriverChip(label: 'Changed', status: DriverStatus.warning),
        ],
      ),
    );
  }
}

/// A month laid out Sunday-first, matching the frame's SUN..SAT header.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.byDay,
    required this.colors,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;

  /// Runs keyed by corridor day. A day with an entry gets a dot.
  final Map<String, List<DriverRun>> byDay;

  final AppColors colors;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // weekday is 1=Mon..7=Sun; the grid starts on Sunday, so Sunday is 0.
    final leading = first.weekday % 7;
    final today = CorridorTime.todayDate();

    return Column(
      children: [
        Row(
          children: [
            for (final label in [
              'SUN',
              'MON',
              'TUE',
              'WED',
              'THU',
              'FRI',
              'SAT',
            ])
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.space8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: leading + daysInMonth,
          itemBuilder: (context, index) {
            if (index < leading) return const SizedBox.shrink();
            final day = DateTime(month.year, month.month, index - leading + 1);
            final isSelected = _sameDay(day, selected);
            final isToday = _sameDay(day, today);
            final runs = byDay[CorridorTime.calendarDay(day)] ?? const [];
            final changed = runs.any((run) => run.wasRecentlyChanged);

            return InkWell(
              onTap: () => onSelect(day),
              customBorder: const CircleBorder(),
              child: Container(
                margin: const EdgeInsets.all(2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? colors.action : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday && !isSelected
                      ? Border.all(color: colors.action)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${day.day}',
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected
                            ? colors.onAction
                            : colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // A dot means work, and its colour says whether operations
                    // has moved something. A day with nothing keeps the space
                    // so the grid does not jump as a month loads.
                    SizedBox(
                      height: 4,
                      child: runs.isEmpty
                          ? null
                          : Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? colors.onAction
                                    : (changed
                                          ? colors.warning
                                          : colors.action),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
