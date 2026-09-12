import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

class AppSignInButton extends StatelessWidget {
  const AppSignInButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.borderRadius = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;

  /// Colors default to theme tokens (via [context.appColors]) when left
  /// unset, so the button follows light/dark automatically. Pass an
  /// explicit color only when a caller needs to override that.
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedBackground = backgroundColor ?? colors.surfaceElevated;
    final resolvedBorder = borderColor ?? colors.actionPrimaryDefault;
    final resolvedText = textColor ?? colors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: resolvedBackground,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: resolvedBorder),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: colors.textPrimary.withValues(alpha: 0.05),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                text,
                style: TextStyle(
                  color: resolvedText,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
