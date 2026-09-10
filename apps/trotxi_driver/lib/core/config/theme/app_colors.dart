import 'package:flutter/material.dart';

/// Raw palette for the driver app, read from the "Blue Black" prototype.
///
/// Deliberately NOT shared with the commuter app. That app is built on a dark
/// green identity; this one is navy, and the two sets of frames disagree on
/// almost every role. Sharing values would mean one app silently restyling the
/// other every time a token moved.
///
/// Naming is `role + weight`, so a designer changing "the 700 navy" changes one
/// line here rather than a search across screens.
abstract final class AppPrimitiveColors {
  // Navy — the app's ground in dark, and its ink in light.
  static const navy950 = Color(0xFF060F1C);
  static const navy900 = Color(0xFF0B1220);
  static const navy800 = Color(0xFF0B1C30);
  static const navy700 = Color(0xFF142438);
  static const navy600 = Color(0xFF1B3350);
  static const navy500 = Color(0xFF27466B);

  // Steel — borders, dividers and secondary text across both themes.
  static const steel400 = Color(0xFF6E7A8A);
  static const steel300 = Color(0xFF8FA3B8);
  static const steel200 = Color(0xFFBDC9D8);
  static const steel100 = Color(0xFFE2E8F0);
  static const steel50 = Color(0xFFF1F5F9);

  // Periwinkle — the primary action in dark, where a navy button would vanish.
  static const periwinkle300 = Color(0xFFA8C4E0);
  static const periwinkle200 = Color(0xFFC7DAEE);

  // Ghana green — Trotxi's accent. Live location, boarded riders, success.
  static const green700 = Color(0xFF006B3F);
  static const green600 = Color(0xFF008751);
  static const green500 = Color(0xFF00A651);
  static const green400 = Color(0xFF22C55E);

  static const amber500 = Color(0xFFF59E0B);
  static const red600 = Color(0xFFDC2626);
  static const red500 = Color(0xFFEF4444);

  static const white = Color(0xFFFFFFFF);
  static const pageWhite = Color(0xFFF8F9FF);
}

/// Semantic colour roles, resolved per theme.
///
/// A [ThemeExtension] rather than the `xDark`/`xLight` suffix pairs used in the
/// commuter app. The driver prototype ships a full dark AND light set for all
/// 54 frames, so every role needs two values; suffixed statics force each widget
/// to re-derive the current brightness and pick, which is where a screen ends up
/// half-themed. Here a widget asks for `context.driverColors.surface` and gets
/// the right one because Flutter already resolved it.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.page,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceSelected,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textInverse,
    required this.action,
    required this.onAction,
    required this.live,
    required this.success,
    required this.warning,
    required this.danger,
    required this.scanTrack,
    required this.scanTrackBorder,
  });

  /// The scaffold ground.
  final Color page;

  /// Cards and sheets sitting on [page].
  final Color surface;

  /// A card that needs to lift off the others, such as the next run on Today.
  final Color surfaceElevated;

  /// The active assignment card, which the frames tint rather than outline.
  final Color surfaceSelected;

  final Color border;
  final Color borderStrong;

  final Color textPrimary;
  final Color textSecondary;

  /// Text on top of [action].
  final Color textInverse;

  /// The primary button fill.
  final Color action;
  final Color onAction;

  /// "Location sharing live" and other in-progress affordances.
  final Color live;
  final Color success;
  final Color warning;
  final Color danger;

  /// The QR viewfinder's inner field and its frame.
  final Color scanTrack;
  final Color scanTrackBorder;

  /// The light theme's roles, from the "Phone prototype — Light" frames.
  static const light = AppColors(
    page: AppPrimitiveColors.pageWhite,
    surface: AppPrimitiveColors.white,
    surfaceElevated: AppPrimitiveColors.white,
    surfaceSelected: AppPrimitiveColors.steel50,
    border: AppPrimitiveColors.steel100,
    borderStrong: AppPrimitiveColors.steel200,
    textPrimary: AppPrimitiveColors.navy800,
    textSecondary: AppPrimitiveColors.steel400,
    textInverse: AppPrimitiveColors.white,
    action: AppPrimitiveColors.navy800,
    onAction: AppPrimitiveColors.white,
    live: AppPrimitiveColors.green600,
    success: AppPrimitiveColors.green600,
    warning: AppPrimitiveColors.amber500,
    danger: AppPrimitiveColors.red600,
    scanTrack: AppPrimitiveColors.steel50,
    scanTrackBorder: AppPrimitiveColors.steel100,
  );

  /// The dark theme's roles, from the "Phone prototype — Dark" frames. Dark is
  /// the one drivers will actually use: these screens are read at 05:40 and
  /// again after dusk, mounted on a windscreen.
  static const dark = AppColors(
    page: AppPrimitiveColors.navy900,
    surface: AppPrimitiveColors.navy800,
    surfaceElevated: AppPrimitiveColors.navy700,
    surfaceSelected: AppPrimitiveColors.navy600,
    border: AppPrimitiveColors.navy600,
    borderStrong: AppPrimitiveColors.navy500,
    textPrimary: AppPrimitiveColors.white,
    textSecondary: AppPrimitiveColors.steel300,
    textInverse: AppPrimitiveColors.navy900,
    action: AppPrimitiveColors.periwinkle300,
    onAction: AppPrimitiveColors.navy900,
    live: AppPrimitiveColors.green400,
    success: AppPrimitiveColors.green500,
    warning: AppPrimitiveColors.amber500,
    danger: AppPrimitiveColors.red500,
    scanTrack: AppPrimitiveColors.navy950,
    scanTrackBorder: AppPrimitiveColors.navy600,
  );

  @override
  AppColors copyWith({
    Color? page,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceSelected,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textInverse,
    Color? action,
    Color? onAction,
    Color? live,
    Color? success,
    Color? warning,
    Color? danger,
    Color? scanTrack,
    Color? scanTrackBorder,
  }) {
    return AppColors(
      page: page ?? this.page,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceSelected: surfaceSelected ?? this.surfaceSelected,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textInverse: textInverse ?? this.textInverse,
      action: action ?? this.action,
      onAction: onAction ?? this.onAction,
      live: live ?? this.live,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      scanTrack: scanTrack ?? this.scanTrack,
      scanTrackBorder: scanTrackBorder ?? this.scanTrackBorder,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      page: Color.lerp(page, other.page, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceSelected: Color.lerp(surfaceSelected, other.surfaceSelected, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      action: Color.lerp(action, other.action, t)!,
      onAction: Color.lerp(onAction, other.onAction, t)!,
      live: Color.lerp(live, other.live, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      scanTrack: Color.lerp(scanTrack, other.scanTrack, t)!,
      scanTrackBorder: Color.lerp(scanTrackBorder, other.scanTrackBorder, t)!,
    );
  }
}

/// `context.driverColors.surface` at the call site, instead of a
/// `Theme.of(context).extension<AppColors>()!` incantation on every widget.
extension AppColorsContext on BuildContext {
  AppColors get driverColors => Theme.of(this).extension<AppColors>()!;
}
