import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _type(Brightness brightness) =>
      ThemeData(brightness: brightness).textTheme
          .apply(fontFamily: AppTypography.fontFamily)
          .merge(AppTypography.textTheme);

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
    fontFamily: AppTypography.fontFamily,
    textTheme: _type(Brightness.light),
    primaryTextTheme: _type(Brightness.light),
    pageTransitionsTheme: _pageTransitionsTheme,
    dialogTheme: DialogThemeData(
      backgroundColor: AppSemanticColors.light.surfaceElevated,
      titleTextStyle: AppTypography.title.copyWith(
        color: AppSemanticColors.light.textPrimary,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppSemanticColors.light.surfaceElevated,
      modalBackgroundColor: AppSemanticColors.light.surfaceElevated,
    ),
    listTileTheme: ListTileThemeData(
      textColor: AppSemanticColors.light.textPrimary,
      iconColor: AppSemanticColors.light.iconDefault,
      subtitleTextStyle: AppTypography.bodySmall.copyWith(
        color: AppSemanticColors.light.textSecondary,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppSemanticColors.light.actionPrimaryDefault,
        textStyle: AppTypography.buttonAction,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.buttontext,
        textStyle: AppTypography.buttonAction,
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
      fontFamily: AppTypography.fontFamily,
      textTheme: _type(Brightness.dark),
      primaryTextTheme: _type(Brightness.dark),
      pageTransitionsTheme: _pageTransitionsTheme,
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceElevated,
        titleTextStyle: AppTypography.title.copyWith(color: colors.textPrimary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceElevated,
        modalBackgroundColor: colors.surfaceElevated,
      ),
      listTileTheme: ListTileThemeData(
        textColor: colors.textPrimary,
        iconColor: colors.iconDefault,
        subtitleTextStyle: AppTypography.bodySmall.copyWith(
          color: colors.textSecondary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.actionPrimaryDefault,
          textStyle: AppTypography.buttonAction,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.actionPrimaryDefault,
          foregroundColor: colors.actionOnPrimary,
          textStyle: AppTypography.buttonAction,
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
