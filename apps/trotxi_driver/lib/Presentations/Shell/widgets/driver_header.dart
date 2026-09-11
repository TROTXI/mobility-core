import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';

/// The persistent identity bar (every phone frame in the file carries it).
///
/// Not an AppBar. It sits above the screen title rather than replacing it, and
/// it answers a question a driver asks all shift without meaning to: which
/// account is this handset signed in as, and which vehicle. On a phone passed
/// between drivers that is the difference between boarding riders as yourself
/// and boarding them as the last person who held it.
class DriverHeader extends StatelessWidget {
  const DriverHeader({super.key, this.vehicleRegistration});

  /// Shown beside the role when a run has told us which vehicle this is.
  final String? vehicleRegistration;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final theme = context.watch<AppThemeController>();
    final name =
        context.watch<SessionController>().session?.fullName ?? 'Driver';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space8,
        AppSpacing.space16,
        AppSpacing.space8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  // The registration only appears once a run has named a
                  // vehicle. Showing a placeholder would be inventing a plate.
                  vehicleRegistration == null
                      ? 'Driver'
                      : '$vehicleRegistration · Driver',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _CircleButton(
            colors: colors,
            // The icon shows what tapping SWITCHES TO, which is the convention
            // the frames use: a moon on the light screens, a sun on the dark.
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            onTap: () => theme.toggle(Theme.of(context).brightness),
            semanticLabel: isDark
                ? 'Switch to light theme'
                : 'Switch to dark theme',
          ),
          const SizedBox(width: AppSpacing.space8),
          _Initials(name: name, colors: colors),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.colors,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  final AppColors colors;
  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surfaceSelected,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: colors.textSecondary),
        ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.name, required this.colors});

  final String name;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    final initials = parts.isEmpty
        ? '?'
        : parts.length == 1
        ? parts.first.characters.first.toUpperCase()
        : (parts.first.characters.first + parts.last.characters.first)
              .toUpperCase();

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceSelected,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: AppTypography.label.copyWith(color: colors.textPrimary),
      ),
    );
  }
}
