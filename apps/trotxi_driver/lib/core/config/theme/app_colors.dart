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
  // Read from the file's own "02 — Driver Colour System" page via the Figma
  // API, not eyedropped. Its stated intent: "Muted off-blue signals brand and
  // action. Semantic status colours remain distinct and are used only for
  // operational meaning."

  // Blue-black — navigation, structure, text hierarchy, dark surfaces.
  static const ink900 = Color(0xFF09131D); // dark page
  static const ink800 = Color(0xFF0E1B28); // dark surface
  static const ink700 = Color(0xFF152235); // light text primary
  static const ink600 = Color(0xFF466681); // footnote / muted
  static const ink500 = Color(0xFF46596D); // light text secondary

  // Muted off-blue — the primary action, in BOTH themes. Not navy in light and
  // something else in dark: the file's rule is one action colour per mode of
  // the same hue, so a driver learns one shape of "this is the button".
  static const action = Color(0xFF5B7896);
  static const actionDark = Color(0xFF7A9AB8);

  // Surfaces and text on the light side.
  static const paper = Color(0xFFF7F9FB); // light page
  static const paperRaised = Color(0xFFEDF2F6); // light surface
  /// The stronger off-blue the file uses where a surface has to carry weight:
  /// the next-stop card, and the selected pill in the phone nav.
  static const paperStrong = Color(0xFFDCE6EF);
  /// Hairlines. Previously borders were drawn in `paperRaised`, which is the
  /// surface colour — so every border in light mode was invisible against the
  /// thing it was meant to bound.
  /// The placeholder and the security note under the sign-in button. Lighter
  /// than [ink500] without dropping to a tint of the border, and the only pair
  /// on the auth frames that no existing role covered.
  static const slate500 = Color(0xFF6B7C8D); // light muted
  static const slate400 = Color(0xFF8795A3); // dark muted

  static const line = Color(0xFFD4DEE7);
  static const lineDark = Color(0xFF2D4053);
  static const mist = Color(0xFFBAC5D0); // dark text secondary
  static const frost = Color(0xFFF2F5F8); // dark text primary

  // Status. Reserved for operational meaning, never decoration: green is
  // "verified success, live connectivity and completed boarding".
  static const successLight = Color(0xFF147A3B);
  static const successDark = Color(0xFF4FD37A);
  static const errorLight = Color(0xFFB42318);
  static const errorDark = Color(0xFFFF776B);
  static const infoLight = Color(0xFF1769AA);
  static const infoDark = Color(0xFF64B5F6);
  static const warningLight = Color(0xFFB76512);
  static const warningDark = Color(0xFFFF9D3D);

  static const white = Color(0xFFFFFFFF);
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
    required this.surfaceStrong,
    required this.field,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textInverse,
    required this.action,
    required this.onAction,
    required this.live,
    required this.success,
    required this.info,
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

  /// One step heavier than [surfaceSelected]. The file uses it where a surface
  /// has to pull the eye without becoming the action colour — the next-stop
  /// card, and the selected pill in the phone nav.
  final Color surfaceStrong;

  /// An input's ground, and the quiet note cards that share its fill. Its own
  /// role rather than a surface: light raises the field off a white card, dark
  /// sinks it into the page, so no single existing token is correct in both.
  final Color field;

  final Color border;
  final Color borderStrong;

  final Color textPrimary;
  final Color textSecondary;

  /// Text that must recede without becoming decoration: a field's placeholder,
  /// and the line telling a driver their PIN is never shown to operations.
  final Color textMuted;

  /// Text on top of [action].
  final Color textInverse;

  /// The primary button fill.
  final Color action;
  final Color onAction;

  /// "Location sharing live" and other in-progress affordances.
  final Color live;
  final Color success;

  /// Informational, never success or warning. The file keeps these four apart
  /// deliberately: they carry operational meaning, not emphasis.
  final Color info;
  final Color warning;
  final Color danger;

  /// The QR viewfinder's inner field and its frame.
  final Color scanTrack;
  final Color scanTrackBorder;

  /// The light theme's roles, from the "Phone prototype — Light" frames.
  static const light = AppColors(
    page: AppPrimitiveColors.paper,
    surface: AppPrimitiveColors.white,
    surfaceElevated: AppPrimitiveColors.white,
    surfaceSelected: AppPrimitiveColors.paperRaised,
    surfaceStrong: AppPrimitiveColors.paperStrong,
    field: AppPrimitiveColors.paperRaised,
    border: AppPrimitiveColors.line,
    borderStrong: AppPrimitiveColors.mist,
    textPrimary: AppPrimitiveColors.ink700,
    textSecondary: AppPrimitiveColors.ink500,
    textMuted: AppPrimitiveColors.slate500,
    // The file's contrast rule, verbatim: "muted off-blue CTAs use white text".
    textInverse: AppPrimitiveColors.white,
    action: AppPrimitiveColors.action,
    onAction: AppPrimitiveColors.white,
    live: AppPrimitiveColors.successLight,
    success: AppPrimitiveColors.successLight,
    info: AppPrimitiveColors.infoLight,
    warning: AppPrimitiveColors.warningLight,
    danger: AppPrimitiveColors.errorLight,
    scanTrack: AppPrimitiveColors.paperRaised,
    scanTrackBorder: AppPrimitiveColors.mist,
  );

  /// The dark theme's roles, from the "Phone prototype — Dark" frames. Dark is
  /// the one drivers will actually use: these screens are read at 05:40 and
  /// again after dusk, mounted on a windscreen.
  static const dark = AppColors(
    page: AppPrimitiveColors.ink900,
    surface: AppPrimitiveColors.ink800,
    surfaceElevated: AppPrimitiveColors.ink800,
    surfaceSelected: AppPrimitiveColors.ink700,
    surfaceStrong: AppPrimitiveColors.ink700,
    field: AppPrimitiveColors.ink800,
    border: AppPrimitiveColors.lineDark,
    borderStrong: AppPrimitiveColors.ink600,
    textPrimary: AppPrimitiveColors.frost,
    textSecondary: AppPrimitiveColors.mist,
    textMuted: AppPrimitiveColors.slate400,
    textInverse: AppPrimitiveColors.ink900,
    action: AppPrimitiveColors.actionDark,
    // Blue-black on the lighter off-blue, the other half of the contrast rule.
    onAction: AppPrimitiveColors.ink900,
    live: AppPrimitiveColors.successDark,
    success: AppPrimitiveColors.successDark,
    info: AppPrimitiveColors.infoDark,
    warning: AppPrimitiveColors.warningDark,
    danger: AppPrimitiveColors.errorDark,
    scanTrack: AppPrimitiveColors.ink900,
    scanTrackBorder: AppPrimitiveColors.ink700,
  );

  @override
  AppColors copyWith({
    Color? page,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceSelected,
    Color? surfaceStrong,
    Color? field,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textInverse,
    Color? action,
    Color? onAction,
    Color? live,
    Color? success,
    Color? info,
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
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      field: field ?? this.field,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textInverse: textInverse ?? this.textInverse,
      action: action ?? this.action,
      onAction: onAction ?? this.onAction,
      live: live ?? this.live,
      success: success ?? this.success,
      info: info ?? this.info,
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
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      field: Color.lerp(field, other.field, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      action: Color.lerp(action, other.action, t)!,
      onAction: Color.lerp(onAction, other.onAction, t)!,
      live: Color.lerp(live, other.live, t)!,
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
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
