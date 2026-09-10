// The driver design system. These assert the two things that break silently:
// a role missing from one brightness, and a widget reading a colour that does
// not actually change between themes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/config/theme/app_theme_controller.dart';

void main() {
  group('AppTheme', () {
    test('both themes carry the AppColors extension', () {
      // Without this a `context.driverColors` call site throws a null assertion
      // at runtime rather than failing to compile.
      expect(AppTheme.lightTheme.extension<AppColors>(), AppColors.light);
      expect(AppTheme.darkTheme.extension<AppColors>(), AppColors.dark);
    });

    test('every role differs between light and dark', () {
      // Catches a role that was added to one set and copy-pasted into the other,
      // which reads as "theming works" until that one screen is opened at night.
      final light = AppColors.light;
      final dark = AppColors.dark;
      expect(light.page, isNot(dark.page));
      expect(light.surface, isNot(dark.surface));
      expect(light.textPrimary, isNot(dark.textPrimary));
      expect(light.textSecondary, isNot(dark.textSecondary));
      expect(light.action, isNot(dark.action));
      expect(light.onAction, isNot(dark.onAction));
      expect(light.scanTrack, isNot(dark.scanTrack));
    });

    test('scaffold ground matches the page role in both themes', () {
      expect(AppTheme.lightTheme.scaffoldBackgroundColor, AppColors.light.page);
      expect(AppTheme.darkTheme.scaffoldBackgroundColor, AppColors.dark.page);
    });

    test('primary buttons clear the driver tap-target floor', () {
      // 56dp, above Material's 48. The driver taps a mounted phone, often with
      // the engine running.
      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        final size = theme.elevatedButtonTheme.style?.minimumSize?.resolve({});
        expect(size?.height, AppTheme.minTapTarget);
      }
    });

    test('lerp resolves to the far end at t = 1', () {
      final mixed = AppColors.light.lerp(AppColors.dark, 1);
      expect(mixed.page, AppColors.dark.page);
      expect(mixed.action, AppColors.dark.action);
    });

    testWidgets('context.driverColors resolves per brightness', (tester) async {
      late AppColors seen;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              seen = context.driverColors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen, AppColors.dark);
    });
  });

  group('AppThemeController', () {
    test('toggle flips away from the effective brightness', () {
      // From system mode the toggle has to resolve what the device is actually
      // showing, or the first tap appears to do nothing.
      final controller = AppThemeController();
      expect(controller.themeMode, ThemeMode.system);

      controller.toggle(Brightness.dark);
      expect(controller.themeMode, ThemeMode.light);

      controller.toggle(Brightness.light);
      expect(controller.themeMode, ThemeMode.dark);
    });

    test('setting the current mode does not notify', () {
      final controller = AppThemeController(initialMode: ThemeMode.dark);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.setThemeMode(ThemeMode.dark);
      expect(notifications, 0);

      controller.setThemeMode(ThemeMode.light);
      expect(notifications, 1);
    });
  });
}
