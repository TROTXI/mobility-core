import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/reservation_trips_tab.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/trip_details_page.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'replacement_fixture.dart';

Map<String, Object?> seat(
  String id,
  String day,
  String direction,
  String status,
) => {
  'id': id,
  'tripId': 'trip-$id',
  'travelDate': day,
  'direction': direction,
  'status': status,
  'pickupOccurrenceId': 'pickup',
  'dropoffOccurrenceId': 'dropoff',
  'source': 'confirmation',
  'createdAt': timestamp,
  'updatedAt': timestamp,
  'version': 1,
};

void main() {
  testWidgets('reservation detail uses the generated API and Ghana time', (
    tester,
  ) async {
    final fixture = Fixture();
    await fixture.signedIn();
    fixture.reply = (request) => request.path == '/v1/me/reservations/seat-1'
        ? jsonResponse({
            'data': {
              'reservation': seat(
                'seat-1',
                '2026-09-16',
                'outbound',
                'reserved',
              ),
              'route': {'id': 'route-1', 'name': 'Circle to Madina'},
              'trip': {
                'id': 'trip-1',
                'scheduledAt': '2026-09-17T00:15:00Z',
                'status': 'active',
                'vehicleLabel': 'Bus A',
                'vehiclePlate': 'GT 1234-26',
              },
              'pickupStop': null,
              'dropoffStop': null,
            },
          })
        : jsonResponse({
            'error': {'code': 'not_found', 'message': 'No fixture'},
          }, 404);
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: TripDetailsPage(client: fixture.api, reservationId: 'seat-1'),
        ),
      );
      for (
        var i = 0;
        i < 100 && find.text('Circle to Madina').evaluate().isEmpty;
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
      }
    });
    expect(find.text('Circle to Madina'), findsOneWidget);
    expect(find.text('12:15 AM'), findsOneWidget);
    expect(find.textContaining('Trip ID'), findsNothing);
    expect(fixture.requests.single.path, '/v1/me/reservations/seat-1');
    await tester.pumpWidget(const SizedBox.shrink());
    fixture.api.dispose();
  });

  testWidgets('upcoming follows all pages; completed today moves to history', (
    tester,
  ) async {
    final fixture = Fixture();
    await fixture.signedIn();
    final today = DateTime.now().toUtc();
    final todayText = DateFormat('yyyy-MM-dd').format(today);
    final tomorrowText = DateFormat(
      'yyyy-MM-dd',
    ).format(today.add(const Duration(days: 1)));
    final yesterdayText = DateFormat(
      'yyyy-MM-dd',
    ).format(today.subtract(const Duration(days: 1)));
    fixture.reply = (request) {
      if (request.path != '/v1/me/reservations') {
        return jsonResponse({
          'error': {'code': 'not_found', 'message': 'No fixture'},
        }, 404);
      }
      if (request.queryParameters['fromDate'] == todayText) {
        return jsonResponse(
          request.queryParameters['cursor'] == null
              ? page([
                  seat('outbound', tomorrowText, 'outbound', 'reserved'),
                ], 'next')
              : page([seat('return', tomorrowText, 'return', 'pending')]),
        );
      }
      return jsonResponse(
        page([
          seat('completed', todayText, 'outbound', 'boarded'),
          seat('past', yesterdayText, 'return', 'reserved'),
        ]),
      );
    };
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ReservationTripsTab(client: fixture.api),
        ),
      );
      for (
        var i = 0;
        i < 100 && find.text('Next trip').evaluate().isEmpty;
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
      }
    });
    expect(find.text('Next trip'), findsOneWidget);
    expect(find.text('Evening commute'), findsOneWidget);
    expect(find.text('Completed'), findsNothing);
    final upcoming = fixture.requests
        .where(
          (r) =>
              r.path == '/v1/me/reservations' &&
              r.queryParameters['fromDate'] == todayText,
        )
        .toList();
    expect(upcoming, hasLength(2));
    expect(upcoming.last.queryParameters['cursor'], 'next');
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
    expect(
      fixture.requests.where(
        (r) =>
            r.path == '/v1/me/reservations' &&
            r.queryParameters['toDate'] == todayText,
      ),
      isNotEmpty,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    fixture.api.dispose();
  });
}
