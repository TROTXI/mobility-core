import 'package:flutter/material.dart';

// Place holder values ---> replace with tokens from ux-design when delivered
class AppColors {
  static const primary = AppPrimitiveColors.green950;
  static const lightBackground = AppPrimitiveColors.neutral0;
  static const buttontext = AppPrimitiveColors.neutral0;

  static const alert = Color.fromARGB(255, 216, 59, 32);

  static const darkbackground = Color(0xff0D110F);

  static const buttontextdark = Color(0xff0D110F);
  static const textsecondary = Color(0xff3E4A41);
  static const textPrimary = Color(0xff0B1C30);
  static const elevatedbackground = Color(0xffFFFFFF);
  static const elevatedbackgrounddark = Color(0xff28312C);
  static const navborder = Color.fromARGB(
    255,
    243,
    243,
    243,
  ); // bottom Navigation border color
  static const dark = Color.fromARGB(255, 3, 10, 18);
  static const green = Color(0xFF006B3F);
  static const greenAccent = Color(0xFF008751);
  static const muted = Color(0xFF5D5E61);
  static const body = Color(0xFF3E4A41);
  static const border = Color(0xFFBDCABE);
  static const pageBg = Color(0xFFF8F9FF);
  static const qrTrack = Color(0xFFF8FAFC);
  static const qrTrackBorder = Color(0xFFF1F5F9);
  static const tipBg = Color(0x7FDCE9FF);
  static const tipBorder = Color(0x4CBDCABE);
  static const buttonBorder = Color(0xFF6E7A70);
  static const background = Color(0xFFBDCABE);
}

abstract final class AppPrimitiveColors {
  static const trotxiGreen = Color(0xFF00A651);

  // Canonical commuter Home palette from the approved phone lifecycle frames
  // (2061:66, 2065:66, 2066:90 and 2091:54). These shared primitives keep
  // page, card, navigation and map roles distinct without duplicating raw
  // values across individual lifecycle screens.
  static const homeGreen = Color(0xFF058740);
  static const homeDarkPage = Color(0xFF0E110F);
  static const homeDarkPrimaryCard = Color(0xFF121C17);
  static const homeDarkConfirmedCard = Color(0xFF111B16);
  static const homeDarkSecondaryCard = Color(0xFF131614);
  static const homeDarkSecondaryBorder = Color(0xFF292E2B);
  static const homeDarkNavigation = Color(0xFF151B17);
  static const homeDarkNavigationBorder = Color(0xFF29322C);
  static const homeDarkMap = Color(0xFF0A0D0B);
  static const homeDarkTextPrimary = Color(0xFFFFFFFF);
  static const homeDarkTextSecondary = Color(0xFFABB5B0);

  // Auth V2 page colors from the canonical phone Sign In frames
  // (2444:35 Light and 2444:613 Dark). The Dark role aliases the approved
  // commuter page primitive so Auth and Home cannot drift to different dark
  // page colors while retaining separate semantic ownership in screen code.
  static const authLightPage = Color(0xFFFBFCFB);
  static const authDarkPage = homeDarkPage;

  static Color authPage(Brightness brightness) =>
      brightness == Brightness.dark ? authDarkPage : authLightPage;

  static const navy50 = Color(0xFFF2F6F8);
  static const navy100 = Color(0xFFE1E9ED);
  static const navy200 = Color(0xFFC3D3DB);
  static const navy300 = Color(0xFF9BB3C0);
  static const navy400 = Color(0xFF6F8D9C);
  static const navy500 = Color(0xFF4E6E7E);
  static const navy600 = Color(0xFF385464);
  static const navy700 = Color(0xFF2A414F);
  static const navy800 = Color(0xFF1B303C);
  static const navy900 = Color(0xFF0B1C30);
  static const navy950 = Color(0xFF06111F);

  static const green50 = Color(0xFFEFFCF5);
  static const green100 = Color(0xFFD8F8E7);
  static const green200 = Color(0xFFB4EFCF);
  static const green300 = Color(0xFF7DE0AD);
  static const green400 = Color(0xFF3ECF8E);
  static const green500 = Color(0xFF16B36B);
  static const green600 = Color(0xFF0A8F54);
  static const green700 = Color(0xFF067647);
  static const green800 = Color(0xFF075E3B);
  static const green900 = Color(0xFF064C31);
  static const green950 = Color(0xFF013215);

  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral50 = Color(0xFFF8FAF9);
  static const neutral100 = Color(0xFFF1F4F2);
  static const neutral200 = Color(0xFFE2E8E4);
  static const neutral300 = Color(0xFFCAD3CD);
  static const neutral400 = Color(0xFF9EAAA2);
  static const neutral500 = Color(0xFF728078);
  static const neutral600 = Color(0xFF56635B);
  static const neutral700 = Color(0xFF3D4941);
  static const neutral800 = Color(0xFF29342D);
  static const neutral900 = Color(0xFF18221C);
  static const neutral950 = Color(0xFF0C1410);

  static const yellow50 = Color(0xFFFFFBEA);
  static const yellow100 = Color(0xFFFFF3C4);
  static const yellow200 = Color(0xFFFFE58A);
  static const yellow300 = Color(0xFFFFD45A);
  static const yellow400 = Color(0xFFF4C547);
  static const yellow500 = Color(0xFFD99A00);
  static const yellow600 = Color(0xFFB87900);
  static const yellow700 = Color(0xFF9A5C00);
  static const yellow800 = Color(0xFF7A4500);
  static const yellow900 = Color(0xFF613500);
  static const yellow950 = Color(0xFF3D2000);

  static const red50 = Color(0xFFFFF3F2);
  static const red100 = Color(0xFFFEE4E2);
  static const red200 = Color(0xFFFECDCA);
  static const red300 = Color(0xFFFDA29B);
  static const red400 = Color(0xFFF97066);
  static const red500 = Color(0xFFF04438);
  static const red600 = Color(0xFFD92D20);
  static const red700 = Color(0xFFB42318);
  static const red800 = Color(0xFF912018);
  static const red900 = Color(0xFF7A271A);
  static const red950 = Color(0xFF55160C);
}

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.backgroundDefault,
    required this.backgroundSubtle,
    required this.surfaceDefault,
    required this.surfaceElevated,
    required this.surfaceStrong,
    required this.onSurfaceStrong,
    required this.borderDefault,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.iconDefault,
    required this.iconSubtle,
    required this.actionPrimaryDefault,
    required this.actionPrimaryHover,
    required this.actionPrimaryPressed,
    required this.actionPrimaryDisabled,
    required this.actionOnPrimary,
    required this.actionOnDisabled,
    required this.actionSecondary,
    required this.focus,
    required this.success,
    required this.warning,
    required this.error,
    required this.routeActive,
    required this.routeInactive,
    required this.mapHighlight,
  });

  final Color backgroundDefault;
  final Color backgroundSubtle;
  final Color surfaceDefault;
  final Color surfaceElevated;
  final Color surfaceStrong;

  /// Derived companion for strong surfaces so reusable surfaces never inherit
  /// a non-contrasting default foreground.
  final Color onSurfaceStrong;

  final Color borderDefault;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textInverse;
  final Color iconDefault;
  final Color iconSubtle;
  final Color actionPrimaryDefault;
  final Color actionPrimaryHover;
  final Color actionPrimaryPressed;
  final Color actionPrimaryDisabled;
  final Color actionOnPrimary;
  final Color actionOnDisabled;
  final Color actionSecondary;
  final Color focus;
  final Color success;
  final Color warning;
  final Color error;
  final Color routeActive;
  final Color routeInactive;
  final Color mapHighlight;

  static const light = AppSemanticColors(
    backgroundDefault: AppPrimitiveColors.neutral0,
    backgroundSubtle: AppPrimitiveColors.neutral50,
    surfaceDefault: AppPrimitiveColors.neutral0,
    surfaceElevated: AppPrimitiveColors.neutral0,
    surfaceStrong: AppPrimitiveColors.navy900,
    onSurfaceStrong: AppPrimitiveColors.neutral0,
    borderDefault: AppPrimitiveColors.neutral500,
    borderSubtle: AppPrimitiveColors.neutral200,
    textPrimary: AppPrimitiveColors.navy900,
    textSecondary: AppPrimitiveColors.neutral700,
    textTertiary: AppPrimitiveColors.neutral600,
    textInverse: AppPrimitiveColors.neutral0,
    iconDefault: AppPrimitiveColors.navy900,
    iconSubtle: AppPrimitiveColors.neutral600,
    actionPrimaryDefault: AppPrimitiveColors.green700,
    actionPrimaryHover: AppPrimitiveColors.green800,
    actionPrimaryPressed: AppPrimitiveColors.green900,
    actionPrimaryDisabled: AppPrimitiveColors.neutral200,
    actionOnPrimary: AppPrimitiveColors.neutral0,
    actionOnDisabled: AppPrimitiveColors.neutral600,
    actionSecondary: AppPrimitiveColors.navy900,
    focus: AppPrimitiveColors.yellow700,
    success: AppPrimitiveColors.green700,
    warning: AppPrimitiveColors.yellow800,
    error: AppPrimitiveColors.red700,
    routeActive: AppPrimitiveColors.green600,
    routeInactive: AppPrimitiveColors.neutral500,
    mapHighlight: AppPrimitiveColors.yellow500,
  );

  static const dark = AppSemanticColors(
    backgroundDefault: AppPrimitiveColors.homeDarkPage,
    backgroundSubtle: AppPrimitiveColors.homeDarkPage,
    surfaceDefault: AppPrimitiveColors.homeDarkNavigation,
    surfaceElevated: Color(0xFF171F1A),
    surfaceStrong: Color(0xFF29322C),
    onSurfaceStrong: Color(0xFFF7FAF8),
    borderDefault: AppPrimitiveColors.homeDarkNavigationBorder,
    borderSubtle: Color(0xFF28312C),
    textPrimary: Color(0xFFF7FAF8),
    textSecondary: Color(0xFFAAB3AD),
    textTertiary: Color(0xFF8B9690),
    textInverse: Color(0xFF0D110F),
    iconDefault: Color(0xFFF7FAF8),
    iconSubtle: Color(0xFFAAB3AD),
    actionPrimaryDefault: Color(0xFF058740),
    actionPrimaryHover: Color(0xFF067647),
    actionPrimaryPressed: Color(0xFF064C31),
    actionPrimaryDisabled: Color(0xFF29322C),
    actionOnPrimary: Color(0xFFFFFFFF),
    actionOnDisabled: Color(0xFF8B9690),
    actionSecondary: Color(0xFFF7FAF8),
    focus: Color(0xFFD99720),
    success: Color(0xFF00A651),
    warning: Color(0xFFD99720),
    error: Color(0xFFD14343),
    routeActive: Color(0xFF00A651),
    routeInactive: Color(0xFF8B9690),
    mapHighlight: Color(0xFFD99720),
  );

  static AppSemanticColors of(BuildContext context) {
    return Theme.of(context).extension<AppSemanticColors>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  @override
  AppSemanticColors copyWith({
    Color? backgroundDefault,
    Color? backgroundSubtle,
    Color? surfaceDefault,
    Color? surfaceElevated,
    Color? surfaceStrong,
    Color? onSurfaceStrong,
    Color? borderDefault,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textInverse,
    Color? iconDefault,
    Color? iconSubtle,
    Color? actionPrimaryDefault,
    Color? actionPrimaryHover,
    Color? actionPrimaryPressed,
    Color? actionPrimaryDisabled,
    Color? actionOnPrimary,
    Color? actionOnDisabled,
    Color? actionSecondary,
    Color? focus,
    Color? success,
    Color? warning,
    Color? error,
    Color? routeActive,
    Color? routeInactive,
    Color? mapHighlight,
  }) {
    return AppSemanticColors(
      backgroundDefault: backgroundDefault ?? this.backgroundDefault,
      backgroundSubtle: backgroundSubtle ?? this.backgroundSubtle,
      surfaceDefault: surfaceDefault ?? this.surfaceDefault,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      onSurfaceStrong: onSurfaceStrong ?? this.onSurfaceStrong,
      borderDefault: borderDefault ?? this.borderDefault,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textInverse: textInverse ?? this.textInverse,
      iconDefault: iconDefault ?? this.iconDefault,
      iconSubtle: iconSubtle ?? this.iconSubtle,
      actionPrimaryDefault: actionPrimaryDefault ?? this.actionPrimaryDefault,
      actionPrimaryHover: actionPrimaryHover ?? this.actionPrimaryHover,
      actionPrimaryPressed: actionPrimaryPressed ?? this.actionPrimaryPressed,
      actionPrimaryDisabled:
          actionPrimaryDisabled ?? this.actionPrimaryDisabled,
      actionOnPrimary: actionOnPrimary ?? this.actionOnPrimary,
      actionOnDisabled: actionOnDisabled ?? this.actionOnDisabled,
      actionSecondary: actionSecondary ?? this.actionSecondary,
      focus: focus ?? this.focus,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      routeActive: routeActive ?? this.routeActive,
      routeInactive: routeInactive ?? this.routeInactive,
      mapHighlight: mapHighlight ?? this.mapHighlight,
    );
  }

  @override
  AppSemanticColors lerp(
    covariant ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) {
      return this;
    }
    return AppSemanticColors(
      backgroundDefault: Color.lerp(
        backgroundDefault,
        other.backgroundDefault,
        t,
      )!,
      backgroundSubtle: Color.lerp(
        backgroundSubtle,
        other.backgroundSubtle,
        t,
      )!,
      surfaceDefault: Color.lerp(surfaceDefault, other.surfaceDefault, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      onSurfaceStrong: Color.lerp(onSurfaceStrong, other.onSurfaceStrong, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      iconDefault: Color.lerp(iconDefault, other.iconDefault, t)!,
      iconSubtle: Color.lerp(iconSubtle, other.iconSubtle, t)!,
      actionPrimaryDefault: Color.lerp(
        actionPrimaryDefault,
        other.actionPrimaryDefault,
        t,
      )!,
      actionPrimaryHover: Color.lerp(
        actionPrimaryHover,
        other.actionPrimaryHover,
        t,
      )!,
      actionPrimaryPressed: Color.lerp(
        actionPrimaryPressed,
        other.actionPrimaryPressed,
        t,
      )!,
      actionPrimaryDisabled: Color.lerp(
        actionPrimaryDisabled,
        other.actionPrimaryDisabled,
        t,
      )!,
      actionOnPrimary: Color.lerp(actionOnPrimary, other.actionOnPrimary, t)!,
      actionOnDisabled: Color.lerp(
        actionOnDisabled,
        other.actionOnDisabled,
        t,
      )!,
      actionSecondary: Color.lerp(actionSecondary, other.actionSecondary, t)!,
      focus: Color.lerp(focus, other.focus, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      routeActive: Color.lerp(routeActive, other.routeActive, t)!,
      routeInactive: Color.lerp(routeInactive, other.routeInactive, t)!,
      mapHighlight: Color.lerp(mapHighlight, other.mapHighlight, t)!,
    );
  }
}

extension AppSemanticColorsBuildContext on BuildContext {
  AppSemanticColors get appColors => AppSemanticColors.of(this);
}
