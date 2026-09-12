import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';

/// The filled run summary that leads the pre-trip screen (design page 08).
///
/// A different component from the Active Trip Hero on page 09, and worth
/// keeping different: before departure the driver is confirming an assignment,
/// so the card is the assignment. Once the run is under way the same space has
/// to carry what is happening now, and a filled block of route facts would be
/// in the way.
///
/// One departure from the file. The frames set this card's text in white over
/// both the light fill and the lighter dark-theme fill, and white on the dark
/// theme's #7A9AB8 is about 2.6:1 — under the 4.5 a driver needs on a sunlit
/// windscreen mount. The tokens page states the rule the card breaks, so the
/// rule wins: [AppColors.onAction] is white in light and blue-black in dark.
class TripSummary extends StatelessWidget {
  const TripSummary({super.key, required this.data});

  final RunDetail data;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final run = data.run;
    final ink = colors.onAction;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: colors.action,
        borderRadius: AppRadii.circular(AppRadii.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${CorridorTime.hhmm(run.scheduledAt)} ${run.routeName}',
            style: AppTypography.heading3.copyWith(color: ink),
          ),
          const SizedBox(height: AppSpacing.space12),

          // The departure strip: a lighter panel inside the fill, so the one
          // time-critical fact is not competing with the route name.
          Container(
            // The file draws 42 exactly. A minimum instead: the upper line is
            // a computed phrase, and "DEPARTS IN 1H 20MIN" at a large text
            // scale has to be allowed to grow rather than be clipped.
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space14,
              vertical: AppSpacing.space4,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadii.circular(21),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _departure(run.scheduledAt),
                        style: AppTypography.tileLabel.copyWith(
                          fontSize: 11,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        data.vehicleRegistration == null
                            // No plate is a real state before operations
                            // assigns a van, and saying so is the point of the
                            // readiness card below.
                            ? 'No vehicle assigned yet'
                            : '${data.vehicleRegistration} · assigned vehicle',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.tileCaption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.space8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space12,
                  ),
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surfaceStrong,
                    borderRadius: AppRadii.circular(AppRadii.button),
                  ),
                  child: Text(
                    '${data.expected} riders',
                    style: AppTypography.tileLabel.copyWith(
                      fontSize: 11,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space12),

          Row(
            children: [
              _Stat(value: '${data.stops.length} stops', label: 'Route', ink: ink),
              _Stat(
                value: '${data.expected - data.standby} booked',
                label: 'Confirmed',
                ink: ink,
              ),
              _Stat(
                value: '${data.standby} standby',
                label: 'Waitlist',
                ink: ink,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// "DEPARTS IN 50 MIN", and the states the file does not draw.
  ///
  /// A scheduled time that has passed is the common case at a depot, and a card
  /// that still counts down to it would be the only thing on the screen lying
  /// about the clock.
  ///
  /// @param at - the scheduled departure.
  /// @returns the strip's upper line.
  static String _departure(DateTime at) {
    final minutes = at.difference(DateTime.now()).inMinutes;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final rest = minutes % 60;
      return rest == 0
          ? 'DEPARTS IN ${hours}H'
          : 'DEPARTS IN ${hours}H ${rest}MIN';
    }
    if (minutes > 0) return 'DEPARTS IN $minutes MIN';
    if (minutes == 0) return 'DUE NOW';
    return '${-minutes} MIN BEHIND SCHEDULE';
  }
}

/// One of the three figures along the bottom of [TripSummary].
class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.ink});

  final String value;
  final String label;
  final Color ink;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: ink,
          ),
        ),
        Text(label, style: AppTypography.footnote.copyWith(color: ink)),
      ],
    ),
  );
}

/// "Ready to depart?" and what that answer rests on.
///
/// The file draws all three rows green. They are rendered from the run's actual
/// state instead: a pre-trip check that always says ready is a decoration, and
/// the one morning it matters is the morning a van was never assigned.
class ReadinessCard extends StatelessWidget {
  const ReadinessCard({super.key, required this.data});

  final RunDetail data;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final rows = <(bool, String, String)>[
      (
        data.vehicleRegistration != null,
        'Vehicle assigned',
        data.vehicleRegistration ?? 'Not yet',
      ),
      (
        data.stops.isNotEmpty,
        'Route loaded',
        data.stops.isEmpty ? 'No stops' : '${data.stops.length} stops',
      ),
      (
        data.riders.isNotEmpty,
        'Passenger list synced',
        data.riders.isEmpty ? 'Nobody booked' : '${data.expected} riders',
      ),
    ];
    final ready = rows.every((r) => r.$1);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: AppSpacing.space16,
      ),
      decoration: BoxDecoration(
        color: colors.field,
        borderRadius: AppRadii.circular(AppRadii.xl),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ready to depart?',
                  style: AppTypography.label.copyWith(
                    fontSize: 16,
                    height: 24 / 16,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space10,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceStrong,
                  borderRadius: AppRadii.circular(AppRadii.md),
                ),
                child: Text(
                  // A driver can still start a run that is short something, so
                  // this reports rather than gates.
                  ready ? 'READY' : 'CHECK',
                  style: AppTypography.tileLabel.copyWith(
                    color: ready ? colors.textPrimary : colors.warning,
                  ),
                ),
              ),
            ],
          ),
          for (final (ok, label, value) in rows)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: ok ? colors.success : colors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space8),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.screenContext.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    value,
                    style: AppTypography.tileCaption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
