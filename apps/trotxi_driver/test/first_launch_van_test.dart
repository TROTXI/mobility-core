import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/Presentations/Onboarding/pages/first_launch_page.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester, {required bool reduceMotion}) =>
    tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: DriverFirstLaunchPage(onContinue: () async {}),
        ),
      ),
    );

void main() {
  testWidgets('the van drives onto the road once, then parks', (tester) async {
    await _pump(tester, reduceMotion: false);
    expect(find.bySemanticsLabel('Trotxi van on its route'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('with reduce motion on, the van is simply parked', (
    tester,
  ) async {
    await _pump(tester, reduceMotion: true);
    await tester.pump();
    expect(find.bySemanticsLabel('Trotxi van on its route'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
