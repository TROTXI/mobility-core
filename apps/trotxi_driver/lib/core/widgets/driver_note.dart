import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';

/// A quiet note card: a round glyph, a title and one line of explanation.
///
/// The file uses it wherever a screen has to say something a driver did not
/// ask about — who to ask for access, why a permission is wanted. It is
/// deliberately not a banner: banners in this app carry failures, and giving
/// standing advice the same weight as a failed sign-in would teach drivers to
/// read past both.
class DriverNote extends StatelessWidget {
  const DriverNote({
    super.key,
    required this.title,
    required this.body,
    this.glyph = 'i',
    this.tone,
  });

  final String title;
  final String body;

  /// A single character. The file sets "i" in the type face rather than
  /// reaching for an icon font, so the note matches the type around it.
  final String glyph;

  /// Overrides the glyph's colour where the note carries a warning rather than
  /// information. Null keeps it the same ink as the title.
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space14),
      decoration: BoxDecoration(
        color: colors.field,
        borderRadius: AppRadii.circular(AppRadii.note),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceStrong,
              shape: BoxShape.circle,
            ),
            child: Text(
              glyph,
              style: AppTypography.fieldLabel.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: tone ?? colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.fieldLabel.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  body,
                  style: AppTypography.footnote.copyWith(
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
