import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/today_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// One clear next action. Starting and ending remain inside the trip workflow.
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
    final ink = colors.onAction;
    return Material(
      color: colors.action,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    run.isActive ? 'IN PROGRESS' : 'YOUR NEXT TRIP',
                    style: AppTypography.chipLabel.copyWith(color: ink),
                  ),
                  if (run.wasRecentlyChanged)
                    Text(
                      'Assignment updated',
                      style: AppTypography.caption.copyWith(color: ink),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                CorridorTime.hhmm(run.scheduledAt),
                style: AppTypography.heading1.copyWith(
                  color: ink,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                run.routeName,
                style: AppTypography.heading3.copyWith(color: ink),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ink.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (run.vehicleRegistration != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.directions_bus_outlined,
                            color: ink,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              run.vehicleRegistration!,
                              style: AppTypography.label.copyWith(color: ink),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      _timing(run),
                      style: AppTypography.bodySmall.copyWith(color: ink),
                    ),
                    if (headline != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${headline!.riders} confirmed ${headline!.riders == 1 ? 'rider' : 'riders'} · ${headline!.stops} ${headline!.stops == 1 ? 'stop' : 'stops'}',
                        style: AppTypography.bodySmall.copyWith(color: ink),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: isBusy ? null : onPrimary,
                style: FilledButton.styleFrom(
                  backgroundColor: ink,
                  foregroundColor: colors.action,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: isBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        run.isActive
                            ? Icons.route_outlined
                            : Icons.checklist_rounded,
                      ),
                label: Text(run.isActive ? 'Continue trip' : 'Review trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _timing(DriverRun run) {
    if (run.isActive) return 'Trip underway';
    final minutes = run.scheduledAt.difference(DateTime.now()).inMinutes;
    if (minutes < -1) return 'Scheduled departure has passed';
    if (minutes < 1) return 'Departure due now';
    if (minutes < 60) return 'Departs in $minutes min';
    return 'Departs in ${minutes ~/ 60}h ${minutes % 60}m';
  }
}
