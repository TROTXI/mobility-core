import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Home/pages/home_page_provider.dart';
import 'package:trotxi_commuter/main.dart';
import 'replacement_fixture.dart';

void main() {
  for (final detailAvailable in [true, false]) {
    test(
      'home uses actual departure detail, with an honest fallback ($detailAvailable)',
      () async {
        final fixture = Fixture();
        addTearDown(fixture.api.dispose);
        await fixture.signedIn();
        final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
        final seat = {
          'id': 'reserved',
          'tripId': 'trip',
          'travelDate': today,
          'direction': 'outbound',
          'status': 'reserved',
          'source': 'confirmation',
          'pickupOccurrenceId': 'pickup',
          'dropoffOccurrenceId': 'dropoff',
          'createdAt': timestamp,
          'updatedAt': timestamp,
          'version': 1,
        };
        fixture.reply = (request) {
          if (request.path == '/v1/me/reservations')
            return jsonResponse(page([seat]));
          if (request.path == '/v1/me/reservations/reserved' &&
              detailAvailable) {
            return jsonResponse({
              'data': {
                'reservation': seat,
                'route': {'id': 'route', 'name': 'Actual route'},
                'trip': {
                  'id': 'trip',
                  'scheduledAt': '2026-10-19T07:15:00Z',
                  'status': 'scheduled',
                },
                'pickupStop': null,
                'dropoffStop': null,
              },
            });
          }
          return jsonResponse({
            'error': {'code': 'unavailable', 'message': 'Try again.'},
          }, 503);
        };
        final container = ProviderContainer(
          overrides: [trotxiClientProvider.overrideWithValue(fixture.api)],
        );
        addTearDown(container.dispose);
        final state =
            await container.read(rideLifecycleProvider.future) as RideReserved;
        expect(state.tripId, 'trip');
        expect(
          state.detail?.route?.name,
          detailAvailable ? 'Actual route' : null,
        );
        expect(
          state.detail?.trip?.scheduledAt,
          detailAvailable ? DateTime.utc(2026, 10, 19, 7, 15) : null,
        );
        expect(state.etaPhase.eta, isNull);
        expect(
          fixture.requests.map((r) => r.path),
          contains('/v1/me/reservations/reserved'),
        );
      },
    );
  }
}
