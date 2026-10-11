import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/Features/Home/models/home_ride_lifecycle_state.dart';
import 'package:trotxi_commuter/Features/Home/pages/home_page_provider.dart';
import 'package:trotxi_commuter/Features/Home/widgets/BottomNavigation/commuter_navigation.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/home_tab.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/onboard_page.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/phone_password_page.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';

import 'replacement_fixture.dart';

class _Reserved extends RideLifecycleNotifier {
  @override
  Future<RideLifecycleState?> build() async =>
      const RideReserved(tripId: 'trip', etaPhase: EtaPhase(isEstimated: true));
}

void main() {
  test(
    'text and primary actions retain accessible contrast in both themes',
    () {
      double contrast(Color a, Color b) {
        final x = a.computeLuminance(), y = b.computeLuminance();
        return ((x > y ? x : y) + .05) / ((x < y ? x : y) + .05);
      }

      for (final colors in [AppSemanticColors.light, AppSemanticColors.dark]) {
        expect(
          contrast(colors.textPrimary, colors.backgroundDefault),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(colors.textSecondary, colors.surfaceElevated),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(colors.actionPrimaryDefault, colors.actionOnPrimary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(colors.onSurfaceStrong, colors.surfaceStrong),
          greaterThanOrEqualTo(4.5),
        );
      }
    },
  );

  for (final dark in [false, true]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets(
        'entry and signup fit a narrow phone: dark=$dark scale=$scale',
        (tester) async {
          final fixture = Fixture();
          addTearDown(fixture.api.dispose);
          await tester.binding.setSurfaceSize(const Size(320, 640));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: OnBoardPage(client: fixture.api),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(
            tester
                .getBottomRight(
                  find.widgetWithText(FilledButton, 'Create account'),
                )
                .dy,
            lessThan(640),
          );
          await tester.tap(find.text('Create account'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(tester.getTopLeft(find.byTooltip('Back')).dy, lessThan(60));
          expect(
            tester
                .getBottomRight(find.widgetWithText(FilledButton, 'Continue'))
                .dy,
            lessThan(640),
          );
          expect(fixture.requests, isEmpty);
        },
      );
    }
  }

  testWidgets('navigation has four full-size targets and preserves selection', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var selected = CommuterDestination.home;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            bottomNavigationBar: CommuterNavigation(
              selected: selected,
              onDestinationSelected: (value) =>
                  setState(() => selected = value),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();
    expect(selected, CommuterDestination.trips);
    expect(tester.takeException(), isNull);
  });

  // Opt-in renders for design review. Normal CI checks layout and behaviour,
  // not platform-specific font rasterisation baselines.
  const output = String.fromEnvironment('DESIGN_OUTPUT');
  if (output.isNotEmpty) {
    for (final dark in [false, true]) {
      for (final page in ['welcome', 'signup', 'home']) {
        testWidgets('render $page ${dark ? 'dark' : 'light'}', (tester) async {
          final fixture = Fixture();
          addTearDown(fixture.api.dispose);
          final loader = FontLoader('Inter')
            ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
          await loader.load();
          final icons = FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
          await icons.load();
          await tester.binding.setSurfaceSize(const Size(390, 844));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final child = switch (page) {
            'welcome' => OnBoardPage(client: fixture.api),
            'signup' => PhonePasswordPage(client: fixture.api, signup: true),
            _ => HomeTab(
              client: fixture.api,
              userData: wire.Account(
                (b) => b
                  ..id = 'preview'
                  ..displayName = 'Ama Mensah'
                  ..role = wire.AccountRoleEnum.commuter
                  ..createdAt = DateTime.utc(2026),
              ),
            ),
          };
          await tester.pumpWidget(
            ProviderScope(
              overrides: [rideLifecycleProvider.overrideWith(_Reserved.new)],
              child: MaterialApp(
                theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                home: RepaintBoundary(
                  key: const ValueKey('preview'),
                  child: child,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await expectLater(
            find.byKey(const ValueKey('preview')),
            matchesGoldenFile('$output/$page-${dark ? 'dark' : 'light'}.png'),
          );
        });
      }
    }
  }
}
