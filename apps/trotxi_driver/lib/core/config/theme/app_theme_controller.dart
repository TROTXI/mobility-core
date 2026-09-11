import 'package:flutter/material.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController({ThemeMode initialMode = ThemeMode.system})
    : _themeMode = initialMode;

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) {
      return;
    }
    _themeMode = themeMode;
    notifyListeners();
  }

  void toggle(Brightness effectiveBrightness) {
    final isDark = switch (_themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => effectiveBrightness == Brightness.dark,
    };
    setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}
