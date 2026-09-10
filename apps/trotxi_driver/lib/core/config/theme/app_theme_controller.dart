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

class AppThemeControllerScope extends InheritedNotifier<AppThemeController> {
  const AppThemeControllerScope({
    super.key,
    required AppThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppThemeController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'No AppThemeControllerScope found in context.');
    return controller!;
  }

  static AppThemeController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppThemeControllerScope>()
        ?.notifier;
  }
}
