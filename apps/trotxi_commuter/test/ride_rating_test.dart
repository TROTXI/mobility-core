import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/Features/Home/pages/home_page_provider.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/ride_rating_card.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/trip_details_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/trip_status.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'package:trotxi_commuter/main.dart';
import 'replacement_fixture.dart';

Map<String, Object?> ratedSeat(
  String? tripStatus, {
  String status = 'boarded',
}) => {
  'id': 'seat',
  'tripId': 'trip',
  'tripStatus': tripStatus,
  'travelDate': DateTime.now().toUtc().toIso8601String().substring(0, 10),
  'direction': 'outbound',
  'status': status,
  'source': 'confirmation',
  'createdAt': timestamp,
  'updatedAt': timestamp,
  'version': 1,
  'pickupOccurrenceId': null,
  'dropoffOccurrenceId': null,
};

void main() {
  Fixture fixture() {
    final f = Fixture();
    f.transport.dio.interceptors.removeWhere((i) => i is wire.AuthInterceptor);
    addTearDown(f.api.dispose);
    return f;
  }

  Future<void> show(
    WidgetTester tester,
    Fixture f, {
    int? saved,
    bool dark = false,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: RideRatingCard(
              client: f.api,
              reservationId: 'seat',
              initialStars: saved,
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets('screen readers can select stars until a rating is saved', (
    tester,
  ) async {
    final f = fixture();
    final semantics = tester.ensureSemantics();
    await show(tester, f);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('4 stars'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
  });

  testWidgets('stars need explicit submit, save once and show confirmation', (
    tester,
  ) async {
    final f = fixture();
    final response = Completer<ResponseBody>();
    f.reply = (r) => response.future;
    await show(tester, f);
    await tester.tap(find.text('☆').at(3));
    await tester.pump();
    expect(f.requests, isEmpty);
    expect(find.text('★'), findsNWidgets(4));
    await tester.tap(find.text('Submit rating'));
    await tester.pump();
    expect(find.text('Saving rating…'), findsOneWidget);
    response.complete(
      jsonResponse({
        'data': {'stars': 4, 'ratedAt': timestamp},
      }),
    );
    await tester.pumpAndSettle();
    expect(f.requests, hasLength(1));
    expect(f.requests.single.path, '/v1/me/reservations/seat/rating');
    expect(bodyOf(f.requests.single), {'stars': 4});
    expect(
      f.requests.single.headers['Idempotency-Key'] ??
          f.requests.single.headers['idempotency-key'],
      isNotEmpty,
    );
    expect(
      find.text('Thank you. You rated this ride 4 out of 5.'),
      findsOneWidget,
    );
    expect(find.text('Submit rating'), findsNothing);
    await tester.tap(find.text('☆'));
    await tester.pump();
    expect(f.requests, hasLength(1));
  });

  testWidgets(
    'failed save preserves selection and permits retry without false success',
    (tester) async {
      final f = fixture();
      var fail = true;
      f.reply = (r) => fail
          ? jsonResponse({
              'error': {
                'code': 'temporarily_unavailable',
                'message': 'Please try again.',
              },
            }, 503)
          : jsonResponse({
              'data': {'stars': 3, 'ratedAt': timestamp},
            });
      await show(tester, f);
      await tester.tap(find.text('☆').at(2));
      await tester.pump();
      await tester.tap(find.text('Submit rating'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Thank you.'), findsNothing);
      expect(find.text('★'), findsNWidgets(3));
      fail = false;
      await tester.tap(find.text('Submit rating'));
      await tester.pumpAndSettle();
      expect(
        find.text('Thank you. You rated this ride 3 out of 5.'),
        findsOneWidget,
      );
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'persisted rating is read-only and accessible at large text ($dark)',
      (tester) async {
        final f = fixture();
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final semantics = tester.ensureSemantics();
        await show(tester, f, saved: 5, dark: dark);
        expect(find.bySemanticsLabel('5 stars'), findsOneWidget);
        expect(find.text('★'), findsNWidgets(5));
        expect(find.text('Submit rating'), findsNothing);
        expect(f.requests, isEmpty);
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }

  for (final state in ['scheduled', 'active', 'completed', 'cancelled']) {
    testWidgets(
      'trip details offer rating only after actual completion ($state)',
      (tester) async {
        final f = fixture();
        f.reply = (_) => jsonResponse({
          'data': {
            'reservation': ratedSeat(state),
            'rating': null,
            'route': {'id': 'route', 'name': 'Circle to Madina'},
            'trip': {'id': 'trip', 'scheduledAt': timestamp, 'status': state},
            'pickupStop': null,
            'dropoffStop': null,
          },
        });
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: TripDetailsPage(client: f.api, reservationId: 'seat'),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byType(RideRatingCard),
          state == 'completed' ? findsOneWidget : findsNothing,
        );
        if (state == 'active') expect(find.text('ON BOARD'), findsOneWidget);
      },
    );
  }

  test('boarded alone is not completed, including on older servers', () {
    expect(
      tripOutcomeOf(wire.ReservationStatusEnum.boarded),
      TripOutcome.boarded,
    );
    expect(
      tripOutcomeOf(wire.ReservationStatusEnum.boarded, tripStatus: 'active'),
      TripOutcome.boarded,
    );
    expect(
      tripOutcomeOf(
        wire.ReservationStatusEnum.boarded,
        tripStatus: 'completed',
      ),
      TripOutcome.completed,
    );
    expect(
      tripOutcomeOf(wire.ReservationStatusEnum.noShow, tripStatus: 'completed'),
      TripOutcome.missed,
    );
  });

  test(
    'Home distinguishes a completed trip from a boarded active trip',
    () async {
      final f = fixture();
      var status = 'active';
      f.reply = (_) => jsonResponse(page([ratedSeat(status)]));
      final container = ProviderContainer(
        overrides: [trotxiClientProvider.overrideWithValue(f.api)],
      );
      addTearDown(container.dispose);
      expect(
        await container.read(rideLifecycleProvider.future),
        isA<RideBoarded>(),
      );
      status = 'completed';
      container.invalidate(rideLifecycleProvider);
      expect(
        await container.read(rideLifecycleProvider.future),
        isA<RideCompleted>(),
      );
    },
  );
}
