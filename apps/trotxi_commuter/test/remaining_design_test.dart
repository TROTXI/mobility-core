import 'dart:convert';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/trip_details_page.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/full_name_page.dart';
import 'package:trotxi_commuter/core/notifications/commuter_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/auto_renewal_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/checkout_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/commute_picker.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/commuter_preference.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/email_security_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/help_support_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/notifications_inbox_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/personal_info.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/phone_verification_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/profile_notification.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/profile_security.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/profile_tab.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/reservation_trips_tab.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/routes_tab.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/standby_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/wallet_tab.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'replacement_fixture.dart';

const _pages = [
  'profile',
  'security',
  'email',
  'password',
  'phone',
  'personal',
  'commute',
  'notifications',
  'inbox',
  'wallet',
  'waitlist-empty',
  'waitlist',
  'offer',
  'payments',
  'renewal',
  'renewal-empty',
  'trips',
  'departures',
  'route-picker',
  'support',
  'trip-details',
  'trip-cancelled',
  'full-name',
];

Map<String, Object?> _money(int value) => {
  'amountMinor': value,
  'currency': 'GHS',
};
Map<String, Object?> _terms() => {
  'coverageStart': '2030-10-11',
  'coverageEnd': '2030-11-10',
  'price': _money(126000),
  'legs': [
    for (final direction in ['outbound', 'return'])
      {
        'direction': direction,
        'scheduleId': '$direction-schedule',
        'patternVersionId': '$direction-version',
        'pickupOccurrenceId': '$direction-pickup',
        'dropoffOccurrenceId': '$direction-dropoff',
        'fareId': 'fare',
        'fare': _money(3000),
        'pickupName': direction == 'outbound' ? 'Circle' : 'Madina',
        'dropoffName': direction == 'outbound' ? 'Madina' : 'Circle',
        'ridesGranted': 21,
        'travelDays': [1, 2, 3, 4, 5],
        'creditPerUnusedRide': _money(500),
      },
  ],
};
Map<String, Object?> _application(String state) => {
  'id': 'application',
  'riderId': 'rider',
  'riderName': 'Ama Mensah',
  'routeName': 'Circle to Madina',
  'state': state,
  'createdAt': timestamp,
  'travelDays': [1, 2, 3, 4, 5],
  'selection': {
    'plan': 'monthly',
    'routeId': 'route',
    'useCredit': false,
    'legs': [
      for (final direction in ['outbound', 'return'])
        {
          'direction': direction,
          'scheduleId': '$direction-schedule',
          'patternVersionId': '$direction-version',
          'pickupOccurrenceId': '$direction-pickup',
          'dropoffOccurrenceId': '$direction-dropoff',
        },
    ],
  },
  'offer': state == 'offered' || state == 'completed'
      ? {
          'id': 'offer',
          'state': state == 'offered' ? 'offered' : 'checkout_open',
          'expiresAt': '2030-10-10T18:00:00Z',
          'purchaseId': state == 'offered' ? null : 'purchase',
          'terms': _terms(),
        }
      : null,
};

Fixture _fixture(String pageName) {
  final fixture = Fixture();
  // Layout tests exercise the generated contracts without an OS token queue.
  fixture.transport.dio.interceptors.removeWhere(
    (i) => i is wire.AuthInterceptor,
  );
  fixture.reply = (r) {
    if (r.path == '/v1/me') {
      return jsonResponse({
        'data': {
          ...account('Ama Mensah'),
          'firstName': 'Ama',
          'lastName': 'Mensah',
          'phone': '+233241234567',
        },
      });
    }
    if (r.path == '/v1/me/reservations/reserved') {
      return jsonResponse({
        'data': {
          'reservation': {
            'id': 'reserved',
            'tripId': 'trip',
            'travelDate': '2026-10-11',
            'direction': 'outbound',
            'status': pageName == 'trip-cancelled'
                ? 'operator_cancelled'
                : 'reserved',
            'source': 'confirmation',
            'pickupOccurrenceId': 'pickup',
            'dropoffOccurrenceId': 'dropoff',
            'createdAt': timestamp,
            'updatedAt': timestamp,
            'version': 1,
          },
          'route': {'id': 'route', 'name': 'Circle to Madina'},
          'trip': {
            'id': 'trip',
            'scheduledAt': '2026-10-11T06:30:00Z',
            'status': 'scheduled',
            'vehicleLabel': 'Bus 1',
          },
          'pickupStop': null,
          'dropoffStop': null,
        },
      });
    }
    if (r.path == '/v1/me/email-access') {
      return jsonResponse({
        'data': {
          'email': 'ama@example.com',
          'passwordEnabled': true,
          'emailVerified': true,
        },
      });
    }
    if (r.path == '/v1/me/verification') {
      return jsonResponse({
        'data': {
          'phone': {
            'status': 'verified',
            'maskedNumber': '+233 ** *** 4567',
            'verifiedAt': timestamp,
          },
          'standbyEligible': true,
          'missing': <String>[],
        },
      });
    }
    if (r.path == '/v1/me/auto-renewal') {
      return jsonResponse({
        'data': {
          'enabled': false,
          'upcoming': null,
          'card': pageName == 'renewal-empty'
              ? null
              : {
                  'brand': 'Visa',
                  'last4': '4838',
                  'expMonth': 12,
                  'expYear': 2030,
                },
        },
      });
    }
    if (r.path == '/v1/me/notification-preferences') {
      return ResponseBody.fromString(
        jsonEncode({
          'data': {
            'dailyAskTime': '17:00',
            'optionalUpdatesEnabled': false,
            'updatedAt': timestamp,
            'version': 1,
          },
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
          'etag': ['"notification-preferences:1"'],
        },
      );
    }
    if (r.path == '/v1/me/membership') {
      return jsonResponse({
        'data': {
          'membership': null,
          'coverage': null,
          'upcomingCoverage': null,
          'lastCoverageEndedAt': null,
          'commute': null,
          'access': {'canReserve': false, 'blocks': <String>[]},
          'entitlements': {
            'remainingRides': 0,
            'credit': _money(0),
            'heldCredit': _money(0),
            'availableCredit': _money(0),
          },
        },
      });
    }
    if (r.path == '/v1/me/purchases') {
      return jsonResponse(
        page(
          pageName == 'payments'
              ? [
                  {
                    'id': 'private-purchase-id',
                    'plan': 'monthly',
                    'state': 'fulfilled',
                    'collectionState': 'successful',
                    'price': _money(126000),
                    'appliedCredit': _money(0),
                    'cashDue': _money(126000),
                    'checkout': null,
                    'billingPeriodId': 'private-period-id',
                    'failureCode': null,
                    'createdAt': timestamp,
                    'offerTerms': _terms(),
                  },
                ]
              : [],
        ),
      );
    }
    if (r.path == '/v1/me/standby') {
      return jsonResponse(
        page(
          pageName == 'waitlist'
              ? [_application('submitted')]
              : pageName == 'offer'
              ? [_application('offered')]
              : pageName == 'paid'
              ? [_application('completed')]
              : [],
        ),
      );
    }
    if ([
      '/v1/me/ride-entries',
      '/v1/me/reservations',
      '/v1/me/commute-requests',
      '/v1/routes',
      '/v1/trips',
      '/v1/me/notifications',
    ].contains(r.path)) {
      return jsonResponse(page([]));
    }
    throw StateError('Missing design fixture: ${r.method} ${r.path}');
  };
  return fixture;
}

Widget _screen(String name, Fixture f) => switch (name) {
  'profile' => Scaffold(body: ProfileTab(client: f.api)),
  'security' => ProfileSecurityPage(client: f.api),
  'trip-details' ||
  'trip-cancelled' => TripDetailsPage(client: f.api, reservationId: 'reserved'),
  'full-name' => FullNamePage(client: f.api, requiredForSignup: true),
  'email' => EmailSecurityPage(
    client: f.api,
    section: EmailSecuritySection.email,
  ),
  'password' => EmailSecurityPage(
    client: f.api,
    section: EmailSecuritySection.password,
  ),
  'phone' => PhoneVerificationPage(client: f.api),
  'personal' => PersonalInfoPage(
    client: f.api,
    initialUser: wire.Account(
      (b) => b
        ..id = 'rider'
        ..displayName = 'Ama Mensah'
        ..firstName = 'Ama'
        ..lastName = 'Mensah'
        ..role = wire.AccountRoleEnum.commuter
        ..createdAt = DateTime.utc(2026),
    ),
  ),
  'commute' => CommutePreferencesPage(client: f.api),
  'notifications' => ProfileNotificationsPage(client: f.api),
  'inbox' => NotificationsInboxPage(client: f.api),
  'wallet' => Scaffold(body: WalletTab(client: f.api)),
  'waitlist-empty' || 'waitlist' || 'offer' => StandbyPage(client: f.api),
  'payments' => CheckoutPage(client: f.api),
  'renewal' || 'renewal-empty' => AutoRenewalPage(client: f.api),
  'trips' => ReservationTripsTab(client: f.api),
  'departures' => RoutesPage(client: f.api),
  'route-picker' => CommutePickerPage(client: f.api),
  _ => HelpSupportPage(client: f.api),
};

void main() {
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      for (final name in _pages) {
        testWidgets('$name fits 320px with scale=$scale dark=$dark', (
          tester,
        ) async {
          final f = _fixture(name);
          addTearDown(f.api.dispose);
          final alerts = CommuterNotifications(
            api: f.api,
            openInbox: () {},
            showForegroundNotice: () {},
          );
          addTearDown(alerts.dispose);
          await tester.binding.setSurfaceSize(const Size(320, 640));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: CommuterNotificationsScope(
                  notifications: alerts,
                  child: child!,
                ),
              ),
              home: _screen(name, f),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (name == 'trip-details' || name == 'trip-cancelled') {
            expect(find.textContaining('Circle to Madina'), findsWidgets);
          }
          for (final scroll in find.byType(Scrollable).evaluate().toList()) {
            final state = (scroll as StatefulElement).state as ScrollableState;
            state.position.jumpTo(state.position.maxScrollExtent);
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(f.requests.every((r) => r.method == 'GET'), isTrue);
          expect(find.textContaining('private-period-id'), findsNothing);
          expect(find.textContaining('private-purchase-id'), findsNothing);
        });
      }
    }
  }

  testWidgets(
    'verified phone starts with status, not an unsolicited change form',
    (tester) async {
      final f = _fixture('phone');
      addTearDown(f.api.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: PhoneVerificationPage(client: f.api),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text('Change phone number'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(f.requests.every((r) => r.method == 'GET'), isTrue);
    },
  );

  testWidgets(
    'reopening a paid offer from the inbox shows it as paid, not a blank form',
    (tester) async {
      final f = _fixture('paid');
      addTearDown(f.api.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: StandbyPage(client: f.api, applicationId: 'application'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Your subscription is paid'), findsOneWidget);
      expect(find.text('View my subscription'), findsOneWidget);
      expect(find.text('Choose a route'), findsNothing);
      // The rider can still start a new request from here.
      await tester.ensureVisible(find.text('Request another commute'));
      await tester.tap(find.text('Request another commute'));
      await tester.pumpAndSettle();
      expect(find.text('Your subscription is paid'), findsNothing);
      expect(find.text('Choose a route'), findsOneWidget);
    },
  );

  testWidgets('waitlist withdrawal can be cancelled without a write', (
    tester,
  ) async {
    final f = _fixture('waitlist');
    addTearDown(f.api.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: StandbyPage(client: f.api),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Withdraw request'));
    await tester.tap(find.text('Withdraw request'));
    await tester.pumpAndSettle();
    expect(find.text('Withdraw your request?'), findsOneWidget);
    await tester.tap(find.text('Keep request'));
    await tester.pumpAndSettle();
    expect(f.requests.every((r) => r.method == 'GET'), isTrue);
  });

  // Real Flutter renders, opt-in only. The fixture never calls staging.
  const output = String.fromEnvironment('DESIGN_OUTPUT');
  if (output.isNotEmpty) {
    for (final dark in [false, true]) {
      for (final name in _pages) {
        testWidgets('render $name ${dark ? 'dark' : 'light'}', (tester) async {
          final f = _fixture(name);
          addTearDown(f.api.dispose);
          final alerts = CommuterNotifications(
            api: f.api,
            openInbox: () {},
            showForegroundNotice: () {},
          );
          addTearDown(alerts.dispose);
          await (FontLoader(
            'Inter',
          )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
          await (FontLoader('MaterialIcons')
                ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
              .load();
          await tester.binding.setSurfaceSize(const Size(390, 844));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          Widget boundary() => RepaintBoundary(
            key: const ValueKey('render'),
            child: CommuterNotificationsScope(
              notifications: alerts,
              child: _screen(name, f),
            ),
          );
          final isTab = [
            'profile',
            'wallet',
            'trips',
            'full-name',
          ].contains(name);
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              initialRoute: isTab ? '/' : '/preview',
              routes: {
                '/': (_) => isTab ? boundary() : const Scaffold(),
                '/preview': (_) => boundary(),
              },
            ),
          );
          await tester.pumpAndSettle();
          await expectLater(
            find.byKey(const ValueKey('render')),
            matchesGoldenFile('$output/$name-${dark ? 'dark' : 'light'}.png'),
          );
        });
      }
    }
  }
}
