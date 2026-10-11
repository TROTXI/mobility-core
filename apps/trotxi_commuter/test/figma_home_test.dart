import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/Features/Home/pages/home_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/home_tab.dart';
import 'package:trotxi_commuter/Features/Home/widgets/home_overview.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_commuter/main.dart';
import 'replacement_fixture.dart';

Map<String, Object?> reservation({
  String status = 'reserved',
  String id = 'seat',
  int days = 0,
}) => {
  'id': id,
  'tripId': 'trip',
  'travelDate': DateTime.now()
      .toUtc()
      .add(Duration(days: days))
      .toIso8601String()
      .substring(0, 10),
  'direction': 'outbound',
  'status': status,
  'source': 'confirmation',
  'pickupOccurrenceId': 'pickup',
  'dropoffOccurrenceId': 'dropoff',
  'createdAt': timestamp,
  'updatedAt': timestamp,
  'version': 1,
};

Map<String, Object?> membership({bool active = true}) => {
  'membership': null,
  'coverage': active
      ? {
          'id': 'period',
          'startsAt': timestamp,
          'endsAt': '2030-11-10T00:00:00Z',
          'state': 'open',
          'paused': false,
          'renewalMode': 'manual',
        }
      : null,
  'upcomingCoverage': null,
  'lastCoverageEndedAt': null,
  'commute': null,
  'access': {'canReserve': active, 'blocks': []},
  'entitlements': {
    'remainingRides': active ? 12 : 0,
    for (final key in ['credit', 'heldCredit', 'availableCredit'])
      key: {'amountMinor': 0, 'currency': 'GHS'},
  },
};

Fixture homeFixture({bool empty = false}) {
  final f = Fixture();
  f.transport.dio.interceptors.removeWhere((i) => i is wire.AuthInterceptor);
  f.reply = (r) {
    if (r.path == '/v1/me') {
      return jsonResponse({'data': account('Kofi Mensah')});
    }
    if (r.path == '/v1/me/membership') {
      return jsonResponse({'data': membership(active: !empty)});
    }
    if (r.path == '/v1/me/reservations') {
      return jsonResponse(page(empty ? [] : [reservation()]));
    }
    if (r.path == '/v1/me/reservations/seat') {
      return jsonResponse({
        'data': {
          'reservation': reservation(),
          'route': {'id': 'route', 'name': 'Adenta to Airport City'},
          'trip': {
            'id': 'trip',
            'scheduledAt': '${reservation()['travelDate']}T06:30:00Z',
            'status': 'scheduled',
          },
          'pickupStop': {
            'occurrenceId': 'pickup',
            'name': 'Adenta',
            'location': {'latitude': 5.7, 'longitude': -.1},
            'ordinal': 1,
          },
          'dropoffStop': {
            'occurrenceId': 'dropoff',
            'name': 'Airport City',
            'location': {'latitude': 5.6, 'longitude': -.2},
            'ordinal': 2,
          },
        },
      });
    }
    return jsonResponse({
      'error': {'code': 'unavailable', 'message': 'Try again'},
    }, 503);
  };
  return f;
}

Future<void> mountHome(
  WidgetTester tester,
  Fixture f, {
  bool dark = false,
  double scale = 1,
  Size size = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final controller = AppThemeController(
    initialMode: dark ? ThemeMode.dark : ThemeMode.light,
  );
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [trotxiClientProvider.overrideWithValue(f.api)],
      child: AppThemeControllerScope(
        controller: controller,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: controller.themeMode,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: RepaintBoundary(
              key: const ValueKey('figma-home-render'),
              child: HomePage(client: f.api),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('Figma source colours replace the lime palette', () {
    expect(AppSemanticColors.dark.backgroundDefault, const Color(0xFF0E110F));
    expect(AppSemanticColors.dark.surfaceStrong, const Color(0xFF1F2822));
    expect(
      AppSemanticColors.dark.actionPrimaryDefault,
      const Color(0xFF058740),
    );
    expect(AppSemanticColors.dark.actionOnPrimary, Colors.white);
    expect(AppSemanticColors.light.backgroundDefault, const Color(0xFFF8FAF9));
    expect(AppSemanticColors.light.surfaceStrong, const Color(0xFF061421));
    expect(
      AppSemanticColors.light.actionPrimaryDefault,
      const Color(0xFF058740),
    );
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('compact home and dock fit 320px dark=$dark scale=$scale', (
        tester,
      ) async {
        final f = homeFixture();
        addTearDown(f.api.dispose);
        await mountHome(
          tester,
          f,
          dark: dark,
          scale: scale,
          size: const Size(320, 720),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Call driver'), findsNothing);
        expect(find.text('Share trip'), findsNothing);
        for (final name in ['home', 'trips', 'wallet', 'profile', 'search']) {
          final target = find.byKey(ValueKey('dock-$name'));
          expect(tester.getSize(target).width, greaterThanOrEqualTo(44));
          expect(tester.getSize(target).height, greaterThanOrEqualTo(44));
          expect(tester.getBottomRight(target).dy, lessThanOrEqualTo(720));
        }
        await tester.scrollUntilVisible(
          find.text('Upcoming'),
          300,
          scrollable: find
              .descendant(
                of: find.byType(HomeTab),
                matching: find.byType(Scrollable),
              )
              .first,
          maxScrolls: 30,
        );
        await tester.pumpAndSettle();
        expect(find.text('Adenta to Airport City'), findsWidgets);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('home shows real balance, pickup, and shared detail request', (
    tester,
  ) async {
    final f = homeFixture();
    addTearDown(f.api.dispose);
    await mountHome(tester, f);
    expect(find.text('12 rides remaining'), findsOneWidget);
    expect(find.text('Pickup info'), findsOneWidget);
    expect(
      f.requests.where((r) => r.path == '/v1/me/reservations/seat'),
      hasLength(1),
    );
    await tester.tap(find.byTooltip('Switch to dark mode'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(HomePage))).brightness,
      Brightness.dark,
    );
    expect(find.text('12 rides remaining'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('dock-search')));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('empty home never advertises an active plan or pickup', (
    tester,
  ) async {
    final f = homeFixture(empty: true);
    addTearDown(f.api.dispose);
    await mountHome(tester, f);
    expect(find.text('Plan your commute'), findsOneWidget);
    expect(find.text('Commute plan active'), findsNothing);
    expect(find.text('Pickup info'), findsNothing);
    expect(
      find.text('Your next reservation will appear here.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  for (final viaInbox in [false, true]) {
    testWidgets(
      'home refreshes after returning from ${viaInbox ? 'inbox' : 'Wallet'}',
      (tester) async {
        final f = homeFixture();
        addTearDown(f.api.dispose);
        final originalReply = f.reply;
        var changed = false;
        f.reply = (r) {
          if (r.path == '/v1/me/membership') {
            return jsonResponse({'data': membership(active: !changed)});
          }
          if (r.path == '/v1/me/reservations' && changed) {
            return jsonResponse(page([]));
          }
          if ([
            '/v1/me/notifications',
            '/v1/me/ride-entries',
            '/v1/me/purchases',
          ].contains(r.path)) {
            return jsonResponse(page([]));
          }
          return originalReply(r);
        };
        await mountHome(tester, f);
        expect(find.text('12 rides remaining'), findsOneWidget);
        if (viaInbox) {
          await tester.ensureVisible(find.text('Updates'));
          await tester.tap(find.text('Updates'));
        } else {
          await tester.tap(find.byKey(const ValueKey('dock-wallet')));
        }
        await tester.pumpAndSettle();
        changed = true;
        if (viaInbox) {
          await tester.pageBack();
        } else {
          await tester.tap(find.byKey(const ValueKey('dock-home')));
        }
        await tester.pumpAndSettle();
        expect(find.text('12 rides remaining'), findsNothing);
        expect(find.text('Plan your commute'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Upcoming'),
          300,
          scrollable: find
              .descendant(
                of: find.byType(HomeTab),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Your next reservation will appear here.'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  test(
    'upcoming selects earliest active reservation, not cancelled/history',
    () async {
      final f = homeFixture();
      addTearDown(f.api.dispose);
      f.reply = (r) => jsonResponse(
        page([
          reservation(id: 'later', days: 4),
          reservation(id: 'cancelled', status: 'operator_cancelled'),
          reservation(id: 'old', days: -1),
          reservation(id: 'next', days: 1, status: 'pending'),
        ]),
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        (await container.read(homeUpcomingProvider(f.api).future))?.id,
        'next',
      );
    },
  );

  const output = String.fromEnvironment('DESIGN_OUTPUT');
  if (output.isNotEmpty) {
    for (final dark in [false, true]) {
      testWidgets('render full Figma home ${dark ? 'dark' : 'light'}', (
        tester,
      ) async {
        final f = homeFixture();
        addTearDown(f.api.dispose);
        final previousShadows = debugDisableShadows;
        debugDisableShadows = false;
        try {
          await (FontLoader(
            'Inter',
          )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
          await (FontLoader('MaterialIcons')
                ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
              .load();
          await mountHome(tester, f, dark: dark);
          await expectLater(
            find.byKey(const ValueKey('figma-home-render')),
            matchesGoldenFile(
              '$output/figma-home-${dark ? 'dark' : 'light'}.png',
            ),
          );
          await tester.pumpWidget(const SizedBox());
        } finally {
          debugDisableShadows = previousShadows;
        }
      });
    }
  }
}
