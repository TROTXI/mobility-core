import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';

/// One of the two numbers the Active Trip Hero leads with.
///
/// Three lines, in the file's own order: a small uppercase label, the number,
/// and a caption that says what the number leaves out. The caption is the part
/// the earlier build dropped, and it is the part that makes the number
/// actionable — "11 / 18" tells a driver where they are, "7 remaining" tells
/// them what is left.
///
/// Spec: surface at radius 16 with 14 of padding, label 10/600, value 28/700,
/// caption 11/400.
class DriverStatTile extends StatelessWidget {
  const DriverStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    this.tone,
  });

  final String label;

  /// Already formatted — "11 / 18", "3 of 11". Composed by the caller because
  /// the two tiles say it differently and neither is the tile's business.
  final String value;

  final String caption;

  /// Overrides the value colour where the number means something, e.g. every
  /// confirmed rider aboard.
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space14),
      decoration: BoxDecoration(
        color: colors.surfaceSelected,
        borderRadius: AppRadii.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.tileLabel.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.counter.copyWith(
              color: tone ?? colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.tileCaption.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Where the van is heading (Components / Stop / Next Stop Card).
///
/// Drawn on the heavier surface so it pulls the eye without becoming the action
/// colour: it is information, not a button. Geometry stays fixed as the stop
/// progresses, which is the file's stated rule — a card that changes size on
/// arrival is a card a driver has to re-read.
class NextStopCard extends StatelessWidget {
  const NextStopCard({
    super.key,
    required this.label,
    required this.stop,
    this.detail,
  });

  /// "NEXT STOP", or "AT STOP" once the driver has reported arriving.
  final String label;

  final String stop;

  /// "1.2 km · ~4 min" in the file. Null here until a routing engine exists —
  /// distance and time to a stop are not something this app can compute, and a
  /// made-up number on the one card a driver navigates by would be worse than
  /// an absent one.
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space14,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceStrong,
        borderRadius: AppRadii.circular(AppRadii.lg),
        // The stroke is what separates this card from the stat tiles above it
        // in DARK, where the file gives both the same fill (#0E1B28) and relies
        // on the border alone. In light the heavier fill already does the work
        // and the edge is just a gentle one.
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.tileLabel.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            stop,
            style: AppTypography.stopName.copyWith(color: colors.textPrimary),
          ),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Text(
              detail!,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// What the app is actually doing with the driver's location.
///
/// The file's rule is the whole point of this component: "never imply live
/// accuracy when GPS is weak, queued offline or disabled". Four states, each
/// with its own dot, its own words, and its own chip — not one line that says
/// "sharing" whatever is happening underneath.
enum GpsState { live, weak, queued, disabled }

/// Telemetry status (Components / GPS & Connectivity).
class GpsIndicator extends StatelessWidget {
  const GpsIndicator({super.key, required this.state, this.detail});

  final GpsState state;

  /// The second line — "Last fix 4s ago", "3 fixes queued to send". Null when
  /// the app does not know, which is honest and common.
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final tone = switch (state) {
      GpsState.live => colors.live,
      GpsState.weak => colors.warning,
      GpsState.queued => colors.info,
      GpsState.disabled => colors.danger,
    };
    final (title, chip) = switch (state) {
      GpsState.live => ('Location sharing live', 'LIVE'),
      GpsState.weak => ('Weak GPS signal', 'WEAK GPS'),
      GpsState.queued => ('Offline — storing updates', 'QUEUED'),
      GpsState.disabled => ('Location is turned off', 'ACTION'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space14,
        vertical: AppSpacing.space10,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSelected,
        borderRadius: AppRadii.circular(AppRadii.indicator),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.label.copyWith(color: colors.textPrimary),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: tone,
              borderRadius: AppRadii.circular(AppRadii.full),
            ),
            child: Text(
              chip,
              style: AppTypography.chipLabel.copyWith(color: colors.textInverse),
            ),
          ),
        ],
      ),
    );
  }
}
