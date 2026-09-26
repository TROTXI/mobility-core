import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:trotxi_client/trotxi_client.dart';

const _fullBody = '{"data":{'
    '"reservation":{"id":"res_1","tripId":"trip_1","travelDate":"2026-09-26",'
    '"direction":"outbound","status":"reserved","pickupOccurrenceId":"occ_pickup",'
    '"dropoffOccurrenceId":"occ_dropoff","source":"confirmation",'
    '"createdAt":"2026-09-20T10:00:00.000Z","updatedAt":"2026-09-20T10:00:00.000Z",'
    '"version":1},'
    '"route":{"id":"route_1","name":"Adenta → Airport City"},'
    '"trip":{"id":"trip_1","scheduledAt":"2026-09-26T06:30:00.000Z",'
    '"status":"scheduled","vehicleLabel":"Trotxi Van 07","vehiclePlate":"GR 4821-26"},'
    '"pickupStop":{"occurrenceId":"occ_pickup","name":"Adenta pickup",'
    '"location":{"latitude":5.7,"longitude":-0.17},"ordinal":0},'
    '"dropoffStop":{"occurrenceId":"occ_dropoff","name":"Airport City",'
    '"location":{"latitude":5.6,"longitude":-0.18},"ordinal":5}'
    '}}';

const _unassignedBody = '{"data":{'
    '"reservation":{"id":"res_2","tripId":null,"travelDate":"2026-09-30",'
    '"direction":"return","status":"pending","pickupOccurrenceId":null,'
    '"dropoffOccurrenceId":null,"source":"default",'
    '"createdAt":"2026-09-20T10:00:00.000Z","updatedAt":"2026-09-20T10:00:00.000Z",'
    '"version":1},'
    '"route":null,"trip":null,"pickupStop":null,"dropoffStop":null'
    '}}';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.body);
  final String body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  // GET /v1/me/reservations/{id} isn't in the generated client (added to the
  // API after the last regen), so ReservationDetail.fromJson hand-parses it.
  // This pins that parsing against the live schema.
  test('getReservationDetail parses a fully assigned reservation', () async {
    final client = TrotxiApiClient(basePathOverride: 'https://example.test');
    client.dio.httpClientAdapter = _StubAdapter(_fullBody);

    final detail = await client.getReservationDetail(
      id: 'res_1',
      xTrotxiClient: 'commuter',
      xTrotxiBuild: 1,
      xTrotxiPlatform: 'android',
    );

    expect(detail.reservation.id, 'res_1');
    expect(detail.reservation.status, ReservationStatusEnum.reserved);
    expect(detail.route?.name, 'Adenta → Airport City');
    expect(detail.trip?.vehicleLabel, 'Trotxi Van 07');
    expect(detail.trip?.vehiclePlate, 'GR 4821-26');
    expect(detail.trip?.status, TripStatusEnum.scheduled);
    expect(detail.pickupStop?.name, 'Adenta pickup');
    expect(detail.pickupStop?.location.latitude, 5.7);
    expect(detail.dropoffStop?.ordinal, 5);
  });

  test('getReservationDetail handles a reservation with no trip yet', () async {
    final client = TrotxiApiClient(basePathOverride: 'https://example.test');
    client.dio.httpClientAdapter = _StubAdapter(_unassignedBody);

    final detail = await client.getReservationDetail(
      id: 'res_2',
      xTrotxiClient: 'commuter',
      xTrotxiBuild: 1,
      xTrotxiPlatform: 'android',
    );

    expect(detail.reservation.id, 'res_2');
    expect(detail.reservation.status, ReservationStatusEnum.pending);
    expect(detail.route, isNull);
    expect(detail.trip, isNull);
    expect(detail.pickupStop, isNull);
    expect(detail.dropoffStop, isNull);
  });
}
