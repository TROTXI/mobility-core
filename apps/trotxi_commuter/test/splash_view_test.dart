import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Onboarding/widgets/splash_view.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';

void main() {
  Widget app({required ThemeMode themeMode}) => MaterialApp(
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: themeMode,
    home: const SplashView(),
  );

  testWidgets('phone landscape keeps loading status in the first viewport', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(844, 390);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app(themeMode: ThemeMode.light));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('splash-layout-phone-landscape')),
      findsOneWidget,
    );
    final progress = find.byType(LinearProgressIndicator);
    expect(progress, findsOneWidget);
    expect(tester.getBottomRight(progress).dy, lessThanOrEqualTo(390));
    expect(tester.takeException(), isNull);
  });

  testWidgets('theme logos use fits that normalize their visible artwork', (
    tester,
  ) async {
    await tester.pumpWidget(app(themeMode: ThemeMode.light));
    final lightLogo = tester.widget<Image>(
      find.byKey(const ValueKey('splash-logo-light')),
    );
    expect(lightLogo.fit, BoxFit.cover);

    await tester.pumpWidget(app(themeMode: ThemeMode.dark));
    await tester.pump(const Duration(seconds: 1));
    final darkLogo = tester.widget<Image>(
      find.byKey(const ValueKey('splash-logo-dark')),
    );
    expect(darkLogo.fit, BoxFit.contain);
  });
}
