import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/routes_tab.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/onboard_page.dart';
import 'package:trotxi_commuter/core/auth/password_requirements.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'package:trotxi_commuter/core/widgets/app_surfaces.dart';
import 'replacement_fixture.dart';

double contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance(), b = background.computeLuminance();
  return ((a > b ? a : b) + .05) / ((a < b ? a : b) + .05);
}

// Resolve the real widget colours, including transparent badge fills over
// their card/page, rather than testing only the semantic token in isolation.
void expectReadableText(WidgetTester tester, String text) {
  final finder = find.text(text);
  expect(finder, findsOneWidget);
  final element = tester.element(finder);
  final theme = Theme.of(element);
  final foreground =
      tester.widget<Text>(finder).style?.color ??
      DefaultTextStyle.of(element).style.color!;
  var background = Colors.transparent;
  element.visitAncestorElements((ancestor) {
    final layer = switch (ancestor.widget) {
      DecoratedBox(decoration: BoxDecoration(:final color)) => color,
      Material(type: MaterialType.transparency) => null,
      Material(:final color) => color ?? theme.canvasColor,
      Scaffold(:final backgroundColor) =>
        backgroundColor ?? theme.scaffoldBackgroundColor,
      _ => null,
    };
    if (layer != null) background = Color.alphaBlend(background, layer);
    return background.a < 1;
  });
  background = Color.alphaBlend(background, theme.scaffoldBackgroundColor);
  expect(
    contrast(foreground, background),
    greaterThanOrEqualTo(4.5),
    reason: '$text must remain readable on its composited background',
  );
}

void main() {
  test(
    'foreground accents contrast on surfaces and tints; fills stay Figma green',
    () {
      for (final colors in [AppSemanticColors.light, AppSemanticColors.dark]) {
        expect(colors.actionPrimaryDefault, const Color(0xFF058740));
        expect(
          contrast(colors.actionOnPrimary, colors.actionPrimaryDefault),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(colors.actionSecondary, colors.backgroundSubtle),
          greaterThanOrEqualTo(4.5),
        );
        // Departure/stop/avatar tiles and status badges tint page/card
        // surfaces. The already-tinted backgroundSubtle is used directly.
        for (final base in [
          colors.backgroundDefault,
          colors.surfaceElevated,
          colors.surfaceDefault,
        ]) {
          for (final tint in [
            Colors.transparent,
            colors.actionPrimaryDefault.withValues(alpha: .1),
            colors.actionPrimaryDefault.withValues(alpha: .12),
            colors.actionSecondary.withValues(alpha: .1),
          ]) {
            expect(
              contrast(colors.actionSecondary, Color.alphaBlend(tint, base)),
              greaterThanOrEqualTo(4.5),
            );
          }
        }
      }
    },
  );

  for (final dark in [false, true]) {
    final theme = dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    testWidgets('onboarding captions and filled actions contrast dark=$dark', (
      tester,
    ) async {
      final f = Fixture();
      addTearDown(f.api.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: OnBoardPage(client: f.api),
        ),
      );
      await tester.scrollUntilVisible(find.text('Scheduled journeys'), 200);
      expectReadableText(tester, 'Scheduled journeys');
      expectReadableText(tester, 'Simple commute plans');
      final button = tester.element(
        find.widgetWithText(FilledButton, 'Create account'),
      );
      final style = FilledButtonTheme.of(button).style!;
      expect(style.backgroundColor!.resolve({}), const Color(0xFF058740));
      expect(
        contrast(
          style.foregroundColor!.resolve({})!,
          style.backgroundColor!.resolve({})!,
        ),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets('departure time contrasts on its tinted card dark=$dark', (
      tester,
    ) async {
      final f = Fixture();
      addTearDown(f.api.dispose);
      f.transport.dio.interceptors.removeWhere(
        (i) => i is wire.AuthInterceptor,
      );
      f.reply = (r) => jsonResponse(
        page(
          r.path == '/v1/trips'
              ? [
                  {
                    'id': 'trip',
                    'departureId': 'departure',
                    'patternId': 'outbound',
                    'serviceDate': '2026-10-11',
                    'runNumber': 1,
                    'routeId': 'route',
                    'patternVersionId': 'version',
                    'direction': 'outbound',
                    'scheduledAt': '2026-10-11T06:30:00Z',
                    'status': 'scheduled',
                    'vehicleLabel': 'Bus A',
                  },
                ]
              : [],
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: RoutesPage(client: f.api),
        ),
      );
      await tester.pumpAndSettle();
      expectReadableText(tester, '06:30');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'password feedback and tinted status badge contrast dark=$dark',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(
              body: Column(
                children: [
                  PasswordRequirements(password: 'MorningTrip!8392'),
                  AppStatusBadge(label: 'Ready'),
                ],
              ),
            ),
          ),
        );
        for (final label in [
          'At least 12 characters',
          'Uppercase letter',
          'Number',
          'Symbol',
          'Ready',
        ]) {
          expectReadableText(tester, label);
        }
      },
    );
  }
}
