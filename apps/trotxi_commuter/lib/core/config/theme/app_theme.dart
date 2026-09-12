import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  /// iOS already gets an edge-swipe-to-go-back gesture for free from
  /// Cupertino's default page transition; Android doesn't unless it's
  /// given the same transition builder. Applying this app-wide means every
  /// `MaterialPageRoute` push (personal info, commute preferences,
  /// notifications, security, etc.) gets "drag left-to-right = back"
  /// without each screen needing its own gesture handling.
  static const _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(primary: AppColors.primary, surface: AppColors.lightBackground),
    scaffoldBackgroundColor: AppColors.lightBackground,
    extensions: const [AppSemanticColors.light],
    pageTransitionsTheme: _pageTransitionsTheme,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.buttontext,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        minimumSize: const Size.fromHeight(56), // 56dp tap target floor
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );

  static ThemeData get darkTheme {
    const colors = AppSemanticColors.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppPrimitiveColors.trotxiGreen,
            brightness: Brightness.dark,
          ).copyWith(
            primary: colors.actionPrimaryDefault,
            surface: colors.surfaceDefault,
          ),
      scaffoldBackgroundColor: colors.backgroundDefault,
      extensions: const [AppSemanticColors.dark],
      pageTransitionsTheme: _pageTransitionsTheme,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.actionPrimaryDefault,
          foregroundColor: colors.actionOnPrimary,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
