import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(primary: AppColors.primary, surface: AppColors.lightBackground),
    scaffoldBackgroundColor: AppColors.lightBackground,

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
}
