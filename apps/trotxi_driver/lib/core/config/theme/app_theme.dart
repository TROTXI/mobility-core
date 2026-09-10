import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';

/// Light and dark themes for the driver app.
///
/// Both are first class. The prototype specifies all 54 frames twice, and dark
/// is the one that matters most in practice: these screens are read before dawn
/// and after dusk, on a phone clamped to a windscreen.
abstract final class AppTheme {
  /// Minimum tap target. Above Material's 48dp floor on purpose — the driver is
  /// tapping a mounted phone, often with the engine running.
  static const double minTapTarget = 56;

  static ThemeData get lightTheme => _build(AppColors.light, Brightness.light);

  static ThemeData get darkTheme => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.action,
        brightness: brightness,
      ).copyWith(
        primary: colors.action,
        onPrimary: colors.onAction,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        error: colors.danger,
      ),
      scaffoldBackgroundColor: colors.page,
      extensions: <ThemeExtension<dynamic>>[colors],
      textTheme: _textTheme(colors, base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.page,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.title.copyWith(color: colors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.circular(AppRadii.lg),
          side: BorderSide(color: colors.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.border, space: 1, thickness: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.action,
          foregroundColor: colors.onAction,
          disabledBackgroundColor: colors.border,
          disabledForegroundColor: colors.textSecondary,
          textStyle: AppTypography.label.copyWith(fontSize: 16),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space24,
            vertical: AppSpacing.space16,
          ),
          minimumSize: const Size.fromHeight(minTapTarget),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.circular(AppRadii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          textStyle: AppTypography.label.copyWith(fontSize: 16),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space24,
            vertical: AppSpacing.space16,
          ),
          minimumSize: const Size.fromHeight(minTapTarget),
          side: BorderSide(color: colors.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.circular(AppRadii.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.action,
          textStyle: AppTypography.label,
          minimumSize: const Size(0, minTapTarget),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        hintStyle: AppTypography.body.copyWith(color: colors.textSecondary),
        labelStyle: AppTypography.label.copyWith(color: colors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.circular(AppRadii.md),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.circular(AppRadii.md),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.circular(AppRadii.md),
          borderSide: BorderSide(color: colors.action, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.circular(AppRadii.md),
          borderSide: BorderSide(color: colors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.circular(AppRadii.md),
          borderSide: BorderSide(color: colors.danger, width: 2),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        // Material's default outline is a low-contrast grey that all but
        // disappears on the dark ground, and "Remember this device" is a
        // decision a driver makes on a shared handset in a dim yard.
        side: BorderSide(color: colors.borderStrong, width: 2),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? colors.action : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(colors.onAction),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.circular(AppRadii.xs)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.surfaceSelected,
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(
          AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceElevated,
        contentTextStyle: AppTypography.body.copyWith(color: colors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.circular(AppRadii.md),
        ),
      ),
    );
  }

  static TextTheme _textTheme(AppColors colors, TextTheme base) {
    final primary = colors.textPrimary;
    final secondary = colors.textSecondary;
    return base.copyWith(
      headlineLarge: AppTypography.heading1.copyWith(color: primary),
      headlineMedium: AppTypography.heading2.copyWith(color: primary),
      headlineSmall: AppTypography.heading3.copyWith(color: primary),
      titleLarge: AppTypography.title.copyWith(color: primary),
      titleMedium: AppTypography.runTitle.copyWith(color: primary),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: primary),
      bodyMedium: AppTypography.body.copyWith(color: primary),
      bodySmall: AppTypography.bodySmall.copyWith(color: secondary),
      labelLarge: AppTypography.label.copyWith(color: primary),
      labelSmall: AppTypography.caption.copyWith(color: secondary),
    );
  }
}
