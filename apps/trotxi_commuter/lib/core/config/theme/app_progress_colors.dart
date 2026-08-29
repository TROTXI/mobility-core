import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

/// Component colors for the indeterminate splash progress treatment.
@immutable
class AppProgressColors extends ThemeExtension<AppProgressColors> {
  const AppProgressColors({required this.track, required this.active});

  final Color track;
  final Color active;

  static const light = AppProgressColors(
    track: Color(0xFFDDE4E0),
    active: AppColors.primary,
  );

  static const dark = AppProgressColors(
    track: Color(0xFF29322C),
    active: AppColors.primary,
  );

  static AppProgressColors of(BuildContext context) {
    return Theme.of(context).extension<AppProgressColors>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  @override
  AppProgressColors copyWith({Color? track, Color? active}) {
    return AppProgressColors(
      track: track ?? this.track,
      active: active ?? this.active,
    );
  }

  @override
  AppProgressColors lerp(
    covariant ThemeExtension<AppProgressColors>? other,
    double t,
  ) {
    if (other is! AppProgressColors) {
      return this;
    }
    return AppProgressColors(
      track: Color.lerp(track, other.track, t)!,
      active: Color.lerp(active, other.active, t)!,
    );
  }
}
