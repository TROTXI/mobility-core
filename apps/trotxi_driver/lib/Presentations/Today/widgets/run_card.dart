import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// One assigned run, as Today draws it.
///
/// Three weights in one widget rather than three widgets, because they are the
/// same card at different emphasis: the run you act on now is filled and
/// carries a button, the ones after it are quiet rows. Splitting them would
/// mean keeping three layouts in step every time the design moves.
class RunCard extends StatelessWidget {
  const RunCard({
    super.key,
    required this.run,
    this.emphasis = RunCardEmphasis.later,
    this.onPrimary,
    this.primaryLabel,
    this.isBusy = false,
    this.onTap,
  });

  final DriverRun run;
  final RunCardEmphasis emphasis;
  final VoidCallback? onPrimary;
  final String? primaryLabel;
  final bool isBusy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final prominent = emphasis != RunCardEmphasis.later;

    return Container(
      decoration: BoxDecoration(
        color: prominent ? colors.surfaceSelected : colors.surface,
        borderRadius: AppRadii.circular(AppRadii.lg),
        border: Border.all(
          color: emphasis == RunCardEmphasis.active ? colors.live : colors.border,
          width: emphasis == RunCardEmphasis.active ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.circular(AppRadii.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      DateFormat('HH:mm').format(run.scheduledAt.toLocal()),
                      style: AppTypography.runTitle.copyWith(color: colors.textPrimary),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(
                      child: Text(
                        run.routeName,
                        style: AppTypography.runTitle.copyWith(color: colors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (emphasis == RunCardEmphasis.active) _LivePill(colors: colors),
                  ],
                ),
                if (run.isFinished) ...[
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    run.status == RunStatus.completed ? 'Completed' : 'Cancelled',
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
                if (onPrimary != null) ...[
                  const SizedBox(height: AppSpacing.space16),
                  ElevatedButton(
                    onPressed: isBusy ? null : onPrimary,
                    child: isBusy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(primaryLabel ?? 'Start trip'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// How much weight a [RunCard] carries.
enum RunCardEmphasis {
  /// Under way.
  active,

  /// The one to start next.
  next,

  /// Everything after that.
  later,
}

class _LivePill extends StatelessWidget {
  const _LivePill({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: colors.live,
        borderRadius: AppRadii.circular(AppRadii.full),
      ),
      child: Text(
        'RUNNING',
        style: AppTypography.caption.copyWith(color: colors.textInverse),
      ),
    );
  }
}
