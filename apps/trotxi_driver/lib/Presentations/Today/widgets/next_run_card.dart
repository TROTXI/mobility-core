import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/today_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// The run that dominates Today.
///
/// Filled with the action colour rather than outlined, which is the file's
/// hierarchy rule made visual: "the next required trip dominates; later
/// assignments remain visible without competing for attention." A driver
/// glancing at a mounted phone should not have to read to find the one thing
/// they are meant to do next.
///
/// The button inverts against the fill — light on the card in light mode, dark
/// in dark — because a button in the action colour ON the action colour is not
/// a button.
class NextRunCard extends StatelessWidget {
  const NextRunCard({
    super.key,
    required this.run,
    required this.onPrimary,
    this.headline,
    this.isBusy = false,
    this.onTap,
  });

  final DriverRun run;
  final VoidCallback onPrimary;
  final RunHeadline? headline;
  final bool isBusy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onFill = colors.onAction;

    return Material(
      color: colors.action,
      borderRadius: AppRadii.circular(AppRadii.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.circular(AppRadii.xl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${CorridorTime.hhmm(run.scheduledAt)}  ${run.routeName}',
                      style: AppTypography.heading3.copyWith(color: onFill),
                    ),
                  ),
                  // Operations moved this run (#233). Read from the trip rather
                  // than from the push that announced it, so a phone that was
                  // off at 04:00 still finds out.
                  if (run.wasRecentlyChanged)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space8,
                        vertical: AppSpacing.space4,
                      ),
                      decoration: BoxDecoration(
                        color: onFill.withValues(alpha: 0.2),
                        borderRadius: AppRadii.circular(AppRadii.full),
                      ),
                      child: Text(
                        'CHANGED',
                        style: AppTypography.caption.copyWith(color: onFill),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.space16),
              _StatusStrip(
                run: run,
                headline: headline,
                colors: colors,
                isDark: isDark,
                onFill: onFill,
              ),
              if (headline != null) ...[
                const SizedBox(height: AppSpacing.space12),
                Text(
                  [
                    '${headline!.stops} stops',
                    '${headline!.riders} confirmed',
                  ].join(' · '),
                  style: AppTypography.bodySmall.copyWith(
                    color: onFill.withValues(alpha: 0.85),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.space20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isBusy ? null : onPrimary,
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark ? colors.page : Colors.white,
                    foregroundColor: isDark
                        ? colors.textPrimary
                        : colors.action,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.circular(AppRadii.full),
                    ),
                  ),
                  child: isBusy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          run.isActive ? 'End trip' : 'Start trip',
                          style: AppTypography.label,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The inset row the frame puts inside the card: state on the left, headcount
/// on the right, on a surface that reads as a panel within the fill.
class _StatusStrip extends StatelessWidget {
  const _StatusStrip({
    required this.run,
    required this.headline,
    required this.colors,
    required this.isDark,
    required this.onFill,
  });

  final DriverRun run;
  final RunHeadline? headline;
  final AppColors colors;
  final bool isDark;
  final Color onFill;

  @override
  Widget build(BuildContext context) {
    final panel = isDark ? colors.page : Colors.white;
    final ink = isDark ? colors.textPrimary : colors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: AppRadii.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _state(run),
                  style: AppTypography.caption.copyWith(color: ink),
                ),
                if (run.vehicleRegistration != null)
                  Text(
                    run.vehicleRegistration!,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (headline != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space12,
                vertical: AppSpacing.space4,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceSelected,
                borderRadius: AppRadii.circular(AppRadii.full),
              ),
              child: Text(
                headline!.riders == 1
                    ? '1 rider'
                    : '${headline!.riders} riders',
                style: AppTypography.caption.copyWith(color: ink),
              ),
            ),
        ],
      ),
    );
  }

  /// "RUNNING" once started, otherwise how long until it should.
  ///
  /// Counted rather than shown as a clock time, because the card already says
  /// 06:30 and what a driver wants from a second line is the gap, not the same
  /// number again.
  static String _state(DriverRun run) {
    if (run.isActive) return 'RUNNING NOW';
    final minutes = run.scheduledAt.difference(DateTime.now()).inMinutes;
    if (minutes < -1) return 'NEXT · OVERDUE';
    if (minutes < 1) return 'NEXT · DUE NOW';
    if (minutes < 60) return 'NEXT · IN $minutes MIN';
    final hours = (minutes / 60).floor();
    return 'NEXT · IN ${hours}H ${minutes % 60}M';
  }
}
