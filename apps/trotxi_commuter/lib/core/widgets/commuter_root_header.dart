import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/widgets/figma_commuter_icon.dart';

/// The header shared by the four persistent commuter destinations.
///
/// Figma keeps notifications and appearance in the same position on every
/// root screen. Pushed screens continue to use a conventional back app bar.
class CommuterRootHeader extends StatelessWidget {
  const CommuterRootHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onNotifications,
  });

  final String title;
  final String subtitle;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final themeController = AppThemeControllerScope.maybeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.heading2.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        CommuterHeaderAction(
          tooltip: 'Open notifications',
          onPressed: onNotifications,
          child: Icon(
            Icons.notifications_none_rounded,
            size: 22,
            color: colors.iconDefault,
          ),
        ),
        if (themeController != null) ...[
          const SizedBox(width: 8),
          CommuterHeaderAction(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: () =>
                themeController.toggle(Theme.of(context).brightness),
            child: FigmaCommuterIcon(
              isDark ? CommuterIcon.sun : CommuterIcon.moon,
            ),
          ),
        ],
      ],
    );
  }
}

class CommuterHeaderAction extends StatelessWidget {
  const CommuterHeaderAction({
    super.key,
    required this.tooltip,
    required this.onPressed,
    required this.child,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    color: context.appColors.surfaceElevated,
    shape: CircleBorder(
      side: BorderSide(color: context.appColors.borderSubtle),
    ),
    child: IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      padding: const EdgeInsets.all(10),
      icon: child,
    ),
  );
}
