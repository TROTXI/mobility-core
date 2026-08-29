import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

/// Component-level semantic colors for Figma `Control / Toggle Switch`.
///
/// The canonical track colors do not map cleanly to the shared action or route
/// roles, so they remain centralized here instead of being embedded in the
/// control widget.
@immutable
class AppToggleColors extends ThemeExtension<AppToggleColors> {
  const AppToggleColors({
    required this.activeTrack,
    required this.inactiveTrack,
  });

  final Color activeTrack;
  final Color inactiveTrack;

  static const light = AppToggleColors(
    activeTrack: AppPrimitiveColors.trotxiGreen,
    inactiveTrack: Color(0xFFDDE4E0),
  );

  static const dark = AppToggleColors(
    activeTrack: AppPrimitiveColors.trotxiGreen,
    inactiveTrack: Color(0xFF36423A),
  );

  static AppToggleColors of(BuildContext context) {
    return Theme.of(context).extension<AppToggleColors>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  @override
  AppToggleColors copyWith({Color? activeTrack, Color? inactiveTrack}) {
    return AppToggleColors(
      activeTrack: activeTrack ?? this.activeTrack,
      inactiveTrack: inactiveTrack ?? this.inactiveTrack,
    );
  }

  @override
  AppToggleColors lerp(
    covariant ThemeExtension<AppToggleColors>? other,
    double t,
  ) {
    if (other is! AppToggleColors) {
      return this;
    }
    return AppToggleColors(
      activeTrack: Color.lerp(activeTrack, other.activeTrack, t)!,
      inactiveTrack: Color.lerp(inactiveTrack, other.inactiveTrack, t)!,
    );
  }
}
