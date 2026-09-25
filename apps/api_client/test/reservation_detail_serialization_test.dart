import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';

void main() {
  final reservation = <String, Object?>{
    'id': 'f30ac778-53dd-4a83-a2d7-43f2417d326c',
    'tripId': '9d2d4954-746c-4a7b-8fe2-14af2498c488',
    'travelDate': '2026-09-25',
    'direction': 'outbound',
    'status': 'reserved',
    'pickupOccurrenceId': 'pickup-1',
    'dropoffOccurrenceId': 'dropoff-1',
    'source': 'confirmation',
    'createdAt': '2026-09-24T12:00:00.000Z',
    'updatedAt': '2026-09-24T12:00:00.000Z',
    'version': 1,
  };

  test('assigned reservation detail exposes the trip and stop snapshots', () {
    final detail = standardSerializers.deserializeWith(
      ReservationDetailResponse.serializer,
      {
        'data': {
          'reservation': reservation,
          'route': {'id': 'route-1', 'name': 'Circle–Madina'},
          'trip': {
            'id': '9d2d4954-746c-4a7b-8fe2-14af2498c488',
            'scheduledAt': '2026-09-25T06:30:00.000Z',
            'status': 'scheduled',
            'vehicleLabel': 'Bus 1',
            'vehiclePlate': 'GR 1234-26',
          },
          'pickupStop': {
            'occurrenceId': 'pickup-1',
            'name': 'Circle',
            'location': {'latitude': 5.57, 'longitude': -0.21},
            'ordinal': 0,
          },
          'dropoffStop': {
            'occurrenceId': 'dropoff-1',
            'name': 'Madina',
            'location': {'latitude': 5.67, 'longitude': -0.16},
            'ordinal': 1,
          },
        },
      },
    )!;

    expect(detail.data.route?.name, 'Circle–Madina');
    expect(detail.data.trip?.vehiclePlate, 'GR 1234-26');
    expect(detail.data.trip?.status, ReservationDetailTripStatusEnum.scheduled);
    expect(detail.data.pickupStop?.name, 'Circle');
    expect(detail.data.dropoffStop?.ordinal, 1);
  });

  test('unassigned reservation detail accepts null trip and stop data', () {
    final detail = standardSerializers.deserializeWith(
      ReservationDetailResponse.serializer,
      {
        'data': {
          'reservation': {
            ...reservation,
            'tripId': null,
            'status': 'pending',
            'pickupOccurrenceId': null,
            'dropoffOccurrenceId': null,
          },
          'route': null,
          'trip': null,
          'pickupStop': null,
          'dropoffStop': null,
        },
      },
    )!;

    expect(detail.data.reservation.status, ReservationStatusEnum.pending);
    expect(detail.data.trip, isNull);
    expect(detail.data.pickupStop, isNull);
  });
}
