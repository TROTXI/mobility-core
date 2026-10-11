import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/Features/Home/pages/home_page_provider.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/home_tab.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'package:trotxi_commuter/main.dart';
import 'replacement_fixture.dart';

Map<String, Object?> seat([bool returning = false]) => {
  'id': returning ? 'return-seat' : 'reserved',
  'tripId': returning ? 'return-trip' : 'trip',
  'travelDate': DateTime.now().toUtc().toIso8601String().substring(0, 10),
  'direction': returning ? 'return' : 'outbound',
  'status': 'reserved',
  'source': 'confirmation',
  'pickupOccurrenceId': 'pickup',
  'dropoffOccurrenceId': 'dropoff',
  'createdAt': timestamp,
  'updatedAt': timestamp,
  'version': 1,
};

ResponseBody detailResponse([bool returning = false]) => jsonResponse({
  'data': {
    'reservation': seat(returning),
    'route': {
      'id': 'route',
      'name': returning ? 'Return route' : 'Actual route',
    },
    'trip': {
      'id': returning ? 'return-trip' : 'trip',
      'scheduledAt': '2026-10-19T07:15:00Z',
      'status': 'scheduled',
    },
    'pickupStop': null,
    'dropoffStop': null,
  },
});

void main() {
  for (final detailAvailable in [true, false]) {
    testWidgets(
      'confirmed seat remains visible while optional detail stalls ($detailAvailable)',
      (tester) async {
        final fixture = Fixture();
        addTearDown(fixture.api.dispose);
        fixture.transport.dio.interceptors.removeWhere(
          (i) => i is wire.AuthInterceptor,
        );
        final detail = Completer<ResponseBody>();
        fixture.reply = (request) {
          if (request.path == '/v1/me/reservations') {
            return jsonResponse(page([seat()]));
          }
          if (request.path == '/v1/me/reservations/reserved') {
            return detail.future;
          }
          throw StateError('Unexpected request: ${request.path}');
        };
        await tester.pumpWidget(
          ProviderScope(
            overrides: [trotxiClientProvider.overrideWithValue(fixture.api)],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: HomeTab(
                client: fixture.api,
                userData: wire.Account(
                  (b) => b
                    ..id = 'rider'
                    ..displayName = 'Ama'
                    ..role = wire.AccountRoleEnum.commuter
                    ..createdAt = DateTime.utc(2026),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(detail.isCompleted, isFalse);
        expect(
          fixture.requests.map((r) => r.path),
          contains('/v1/me/reservations/reserved'),
        );
        expect(
          find.text('Your seat is confirmed for this departure.'),
          findsOneWidget,
        );
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Actual route'), findsNothing);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(HomeTab)),
        );
        final state =
            container.read(rideLifecycleProvider).requireValue as RideReserved;
        expect(state.tripId, 'trip');
        expect(state.etaPhase.eta, isNull);
        detail.complete(
          detailAvailable
              ? detailResponse()
              : jsonResponse({
                  'error': {'code': 'unavailable', 'message': 'Try again.'},
                }, 503),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Your seat is confirmed for this departure.'),
          findsOneWidget,
        );
        expect(
          find.text('Actual route'),
          detailAvailable ? findsNWidgets(2) : findsNothing,
        );
        expect(
          container
              .read(homeReservationDetailProvider)
              .asData
              ?.value
              ?.trip
              ?.scheduledAt,
          detailAvailable ? DateTime.utc(2026, 10, 19, 7, 15) : null,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  test('late detail cannot overwrite a newly selected direction', () async {
    final fixture = Fixture();
    addTearDown(fixture.api.dispose);
    await fixture.signedIn();
    final outbound = Completer<ResponseBody>();
    final returning = Completer<ResponseBody>();
    final outboundStarted = Completer<void>();
    final returnStarted = Completer<void>();
    fixture.reply = (request) {
      if (request.path == '/v1/me/reservations') {
        return jsonResponse(page([seat(), seat(true)]));
      }
      if (request.path == '/v1/me/reservations/reserved') {
        outboundStarted.complete();
        return outbound.future;
      }
      if (request.path == '/v1/me/reservations/return-seat') {
        returnStarted.complete();
        return returning.future;
      }
      throw StateError('Unexpected request: ${request.path}');
    };
    final container = ProviderContainer(
      overrides: [trotxiClientProvider.overrideWithValue(fixture.api)],
    );
    addTearDown(container.dispose);
    container.listen(homeReservationDetailProvider, (_, _) {});
    await outboundStarted.future;
    expect(
      (container.read(rideLifecycleProvider).requireValue as RideReserved)
          .tripId,
      'trip',
    );
    container
        .read(selectedDirectionProvider.notifier)
        .select(CommuteDirection.returning);
    await returnStarted.future;
    returning.complete(detailResponse(true));
    expect(
      (await container.read(homeReservationDetailProvider.future))?.route?.name,
      'Return route',
    );
    outbound.complete(detailResponse());
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(homeReservationDetailProvider).requireValue?.route?.name,
      'Return route',
    );
    expect(
      (container.read(rideLifecycleProvider).requireValue as RideReserved)
          .tripId,
      'return-trip',
    );
  });
}
