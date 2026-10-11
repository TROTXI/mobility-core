import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/commuter_trip_tracking.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/Features/Home/widgets/Trips/confirm_ride_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/ride_journey_cards.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'figma_home_test.dart'
    show reservation, homeFixture, mountHome, membership;
import 'trip_tracking_test.dart' show tripRow, liveRow;
import 'replacement_fixture.dart';

Map<String, Object?> journeyDetail({
  String status = 'pending',
  String tripStatus = 'scheduled',
}) => {
  'reservation': {
    ...reservation(status: status, days: 1),
    'direction': 'return',
  },
  'route': {'id': 'route', 'name': 'Adenta to Airport City'},
  'trip': {
    'id': 'trip',
    'scheduledAt': '2030-10-12T06:30:00Z',
    'status': tripStatus,
    'vehicleLabel': 'Toyota Hiace',
    'vehiclePlate': 'GT 1234-20',
  },
  'pickupStop': {
    'occurrenceId': 'pickup',
    'name': 'Adenta',
    'ordinal': 1,
    'location': {'latitude': 5.7, 'longitude': -.1},
  },
  'dropoffStop': {
    'occurrenceId': 'dropoff',
    'name': 'Airport City',
    'ordinal': 3,
    'location': {'latitude': 5.6, 'longitude': -.2},
  },
};

void main() {
  const output = String.fromEnvironment('JOURNEY_OUTPUT');
  Fixture fixture({
    String status = 'pending',
    String tripStatus = 'scheduled',
  }) {
    final f = Fixture();
    f.transport.dio.interceptors.removeWhere((i) => i is wire.AuthInterceptor);
    f.reply = (_) => jsonResponse({
      'data': journeyDetail(status: status, tripStatus: tripStatus),
    });
    addTearDown(f.api.dispose);
    return f;
  }

  Future<void> open(
    WidgetTester tester,
    Widget page, {
    bool dark = false,
    double scale = 1,
    double width = 390,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 844));
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
        home: RepaintBoundary(
          key: const ValueKey('journey-render'),
          child: page,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'review is read-only and confirmation uses the reviewed day and return leg',
    (tester) async {
      final f = fixture();
      final response = Completer<ResponseBody>();
      final reply = f.reply;
      f.reply = (r) => r.method == 'POST' ? response.future : reply(r);
      await open(tester, ConfirmRidePage(client: f.api, reservationId: 'seat'));
      expect(f.requests.where((r) => r.method == 'POST'), isEmpty);
      await tester.ensureVisible(find.text('Confirm ride'));
      await tester.tap(find.text('Confirm ride'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Confirming…'), findsOneWidget);
      response.complete(
        jsonResponse({
          'error': {
            'code': 'service_started',
            'message': 'This departure is no longer changeable.',
          },
        }, 409),
      );
      await tester.pumpAndSettle();
      final post = f.requests.singleWhere((r) => r.method == 'POST');
      expect(bodyOf(post)['direction'], 'return');
      expect(bodyOf(post)['travelDate'], reservation(days: 1)['travelDate']);
      expect(bodyOf(post)['decision'], 'confirm');
      expect(
        find.text('This departure is no longer changeable.'),
        findsOneWidget,
      );
      expect(find.text('Confirm ride'), findsOneWidget);
    },
  );

  for (final status in ['reserved', 'boarded', 'operator_cancelled']) {
    testWidgets('$status cannot be confirmed again from the review page', (
      tester,
    ) async {
      final f = fixture(status: status);
      await open(tester, ConfirmRidePage(client: f.api, reservationId: 'seat'));
      expect(find.text('Confirm ride'), findsNothing);
      expect(f.requests.where((r) => r.method == 'POST'), isEmpty);
    });
  }

  for (final outcome in ['reserved', 'unseated']) {
    testWidgets(
      'successful $outcome response returns from confirmation without a false success claim',
      (tester) async {
        final f = fixture();
        final original = f.reply;
        f.reply = (r) => r.method == 'POST'
            ? jsonResponse({
                'data': {
                  'reservation': {
                    ...reservation(status: outcome, days: 1),
                    'direction': 'return',
                  },
                  'pass': null,
                },
              })
            : original(r);
        await open(
          tester,
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ConfirmRidePage(client: f.api, reservationId: 'seat'),
                  ),
                ),
                child: const Text('Review next ride'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Review next ride'));
        await tester.pumpAndSettle();
        expect(find.byType(BackButton), findsOneWidget);
        await tester.ensureVisible(find.text('Confirm ride'));
        await tester.tap(find.text('Confirm ride'));
        await tester.pumpAndSettle();
        expect(find.text('Review next ride'), findsOneWidget);
        expect(find.byType(ConfirmRidePage), findsNothing);
        if (outcome == 'unseated') {
          expect(
            find.text('No seat is available for this ride.'),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
        expect(f.requests.where((r) => r.method == 'POST'), hasLength(1));
      },
    );
  }

  testWidgets(
    'Home completion refreshes the ride balance without leaving the screen',
    (tester) async {
      final f = homeFixture();
      addTearDown(f.api.dispose);
      final original = f.reply;
      var completed = false;
      f.reply = (r) {
        final seat = {
          ...reservation(status: completed ? 'boarded' : 'reserved'),
          'tripStatus': completed ? 'completed' : 'scheduled',
        };
        if (r.path == '/v1/me/reservations') return jsonResponse(page([seat]));
        if (r.path == '/v1/me/reservations/seat') {
          return jsonResponse({
            'data': {
              ...journeyDetail(
                status: completed ? 'boarded' : 'reserved',
                tripStatus: completed ? 'completed' : 'scheduled',
              ),
              'reservation': seat,
            },
          });
        }
        if (r.path == '/v1/me/membership') {
          return jsonResponse({
            'data': {
              ...membership(),
              'entitlements': {
                ...membership()['entitlements'] as Map<String, Object?>,
                'remainingRides': completed ? 11 : 12,
              },
            },
          });
        }
        return original(r);
      };
      await mountHome(tester, f);
      expect(find.text('12 rides remaining'), findsOneWidget);
      completed = true;
      await tester.pump(const Duration(seconds: 31));
      await tester.pumpAndSettle();
      expect(find.text('TRIP COMPLETED'), findsOneWidget);
      expect(find.text('11 rides'), findsOneWidget);
      expect(find.text('12 rides'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'completed Home connects summary, feedback and navigation dark=$dark',
      (tester) async {
        final f = homeFixture();
        addTearDown(f.api.dispose);
        final original = f.reply;
        final seat = {
          ...reservation(status: 'boarded'),
          'tripStatus': 'completed',
        };
        f.reply = (r) {
          if (r.path == '/v1/me/reservations') {
            return jsonResponse(page([seat]));
          }
          if (r.path == '/v1/me/reservations/seat') {
            return jsonResponse({
              'data': {
                ...journeyDetail(status: 'boarded', tripStatus: 'completed'),
                'reservation': seat,
              },
            });
          }
          return original(r);
        };
        if (output.isNotEmpty) {
          await (FontLoader(
            'Inter',
          )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
          await (FontLoader('MaterialIcons')
                ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
              .load();
        }
        await mountHome(tester, f, dark: dark);
        expect(find.text("You've arrived, Kofi"), findsOneWidget);
        expect(find.text('TRIP COMPLETED'), findsOneWidget);
        expect(find.text('How was your ride?'), findsOneWidget);
        expect(find.text('11 rides'), findsNothing);
        expect(tester.takeException(), isNull);
        if (output.isNotEmpty) {
          await expectLater(
            find.byKey(const ValueKey('figma-home-render')),
            matchesGoldenFile(
              '$output/completed-home-${dark ? 'dark' : 'light'}.png',
            ),
          );
        }
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      for (final name in [
        'confirmation',
        'approaching',
        'in-trip',
        'completed',
      ]) {
        testWidgets('$name fits narrow screens dark=$dark scale=$scale', (
          tester,
        ) async {
          final f = fixture();
          final detail = f.transport.serializers.deserializeWith(
            wire.ReservationDetail.serializer,
            journeyDetail(
              status: name == 'completed' ? 'boarded' : 'reserved',
              tripStatus: name == 'completed' ? 'completed' : 'active',
            ),
          )!;
          final snapshot = CommuterTripSnapshot(
            trip: f.transport.serializers.deserializeWith(
              wire.Trip.serializer,
              tripRow('trip'),
            )!,
            live: f.transport.serializers.deserializeWith(
              wire.LiveTrip.serializer,
              liveRow(age: 1),
            )!,
            elapsed: () => Duration.zero,
            stops: [
              for (final row in [detail.pickupStop!, detail.dropoffStop!])
                wire.StopOccurrence(
                  (b) => b
                    ..id = row.occurrenceId
                    ..stopId = 'stop'
                    ..ordinal = row.ordinal
                    ..name = row.name
                    ..location.replace(row.location),
                ),
            ],
          );
          final content = switch (name) {
            'confirmation' => ConfirmRidePage(
              client: f.api,
              reservationId: 'seat',
            ),
            'completed' => Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: CompletedRideSummary(
                  detail: detail,
                  onDetails: () {},
                  remainingRides: 11,
                ),
              ),
            ),
            _ => Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: LiveRideJourney(
                  boarded: name == 'in-trip',
                  detail: detail,
                  snapshot: snapshot,
                  map: const ColoredBox(
                    color: Color(0xFF12251C),
                    child: Center(child: Text('Map test surface')),
                  ),
                  onBoardingPass: () {},
                  onExpand: () {},
                ),
              ),
            ),
          };
          await open(tester, content, dark: dark, scale: scale, width: 320);
          expect(tester.takeException(), isNull);
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -1400),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text('2 of 4 stops completed'), findsNothing);
          expect(find.text('Your van is here'), findsNothing);
          const output = String.fromEnvironment('JOURNEY_OUTPUT');
          if (output.isNotEmpty && scale == 1) {
            await (FontLoader(
              'Inter',
            )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
            await open(tester, content, dark: dark);
            await expectLater(
              find.byKey(const ValueKey('journey-render')),
              matchesGoldenFile('$output/$name-${dark ? 'dark' : 'light'}.png'),
            );
          }
        });
      }
    }
  }

  testWidgets(
    'stale pickup estimates are not presented as approaching or arrived',
    (tester) async {
      final f = fixture();
      final snapshot = CommuterTripSnapshot(
        trip: f.transport.serializers.deserializeWith(
          wire.Trip.serializer,
          tripRow('trip'),
        )!,
        live: f.transport.serializers.deserializeWith(
          wire.LiveTrip.serializer,
          liveRow(age: 121),
        )!,
        elapsed: () => Duration.zero,
      );
      await open(
        tester,
        Scaffold(
          body: LiveRideJourney(
            boarded: false,
            detail: null,
            snapshot: snapshot,
            map: null,
            onBoardingPass: () {},
            onExpand: () {},
          ),
        ),
      );
      expect(find.text('VEHICLE APPROACHING'), findsNothing);
      expect(find.text('Your seat is reserved'), findsOneWidget);
      expect(find.textContaining('updates are delayed'), findsOneWidget);
    },
  );
}
