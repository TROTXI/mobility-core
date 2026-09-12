import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';

/// Which operational state a chip is reporting.
///
/// The file's set, kept whole: "colour communicates status, but every state
/// remains understandable through its visible label". The dot and the word both
/// carry it, so the chip still reads for a driver who cannot separate the
/// colours.
enum DriverStatus { active, ready, boarded, warning, error, offline, neutral }

/// A compact operational state label (Components / Driver Status Chips).
///
/// Spec from the file: 32 high, radius 16, 12 of horizontal padding, a 7px dot,
/// and an 11/600 uppercase label at 0.44 letter spacing.
///
/// Fills come from the theme rather than the file's literal hexes so the chip
/// survives dark mode, where the file's own dark palette shifts every semantic
/// colour. Text is white on a filled chip and the ink colour on a soft one,
/// which is the file's stated contrast rule — a few of its component captions
/// draw dark ink on a dark fill, and those are authoring slips rather than
/// intent.
class DriverChip extends StatelessWidget {
  const DriverChip({super.key, required this.label, required this.status});

  final String label;
  final DriverStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final (background, foreground, dot) = _palette(colors);

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.circular(AppRadii.chip),
        border: status == DriverStatus.offline || status == DriverStatus.neutral
            ? Border.all(color: colors.border)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: AppTypography.chipLabel.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }

  /// Background, text and dot for this status.
  ///
  /// @param colors - the resolved theme colours.
  /// @returns the three colours the chip draws with.
  (Color, Color, Color) _palette(AppColors colors) => switch (status) {
    DriverStatus.active => (colors.action, colors.onAction, colors.onAction),
    DriverStatus.ready => (
      colors.surfaceStrong,
      colors.textPrimary,
      colors.action,
    ),
    DriverStatus.boarded => (
      colors.success,
      colors.textInverse,
      colors.textInverse,
    ),
    DriverStatus.warning => (
      colors.warning,
      colors.textInverse,
      colors.textInverse,
    ),
    DriverStatus.error => (
      colors.danger,
      colors.textInverse,
      colors.textInverse,
    ),
    DriverStatus.offline => (
      colors.surface,
      colors.textSecondary,
      colors.textSecondary,
    ),
    DriverStatus.neutral => (
      colors.surfaceSelected,
      colors.textSecondary,
      colors.textSecondary,
    ),
  };
}
