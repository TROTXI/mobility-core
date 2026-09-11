import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/widgets/pending_backend_notice.dart';

/// Schedule and future trips (prototype page 18).
///
/// Skeleton. `GET /me/trips` takes a single date, so a month view would be
/// thirty-one requests; the calendar needs a range endpoint before it can mark
/// anything. The grid, the selection behaviour and the day agenda are real, so
/// the shape is settled and only the data source is missing.
///
/// "Planning principle: show only driver-assigned duties" — this is not a
/// roster of everything the depot runs, only what this driver has been given.
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return ListView(
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
          DateFormat('MMMM yyyy').format(_month),
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space16),

        const PendingBackendNotice(
          waitingOn:
              'a date-range trips endpoint; /me/trips only takes one day',
        ),

        Container(
          padding: const EdgeInsets.all(AppSpacing.space12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadii.circular(AppRadii.lg),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(
                      () => _month = DateTime(_month.year, _month.month - 1),
                    ),
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
                    onPressed: () => setState(
                      () => _month = DateTime(_month.year, _month.month + 1),
                    ),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space8),
              _MonthGrid(
                month: _month,
                selected: _selected,
                colors: colors,
                onSelect: (day) => setState(() => _selected = day),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space16),

        Text(
          DateFormat('EEEE, d MMMM').format(_selected).toUpperCase(),
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space8),
        Container(
          padding: const EdgeInsets.all(AppSpacing.space24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadii.circular(AppRadii.lg),
          ),
          child: Text(
            'Assignments for this day appear here once the schedule endpoint exists.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// A month laid out Sunday-first, matching the frame's SUN..SAT header.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.colors,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final AppColors colors;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // weekday is 1=Mon..7=Sun; the grid starts on Sunday, so Sunday is 0.
    final leading = first.weekday % 7;

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

            return InkWell(
              onTap: () => onSelect(day),
              customBorder: const CircleBorder(),
              child: Container(
                margin: const EdgeInsets.all(2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? colors.action : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${day.day}',
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected ? colors.onAction : colors.textPrimary,
                  ),
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
