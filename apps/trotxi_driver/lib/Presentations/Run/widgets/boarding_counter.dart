import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';

/// The two numbers a driver reads while moving: boarded against confirmed, and
/// stop N of M.
///
/// Tabular figures on the value so the layout does not shift as riders board
/// and the digits change width. On a phone clamped to a windscreen, text that
/// jumps is text that gets misread.
class BoardingCounter extends StatelessWidget {
  const BoardingCounter({
    super.key,
    required this.label,
    required this.value,
    required this.of,
    this.tone,
  });

  final String label;
  final int value;
  final int of;

  /// Overrides the value colour, for a count that means something.
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$value',
                style: AppTypography.counter.copyWith(
                  color: tone ?? colors.textPrimary,
                ),
              ),
              Text(
                ' / $of',
                style: AppTypography.title.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
