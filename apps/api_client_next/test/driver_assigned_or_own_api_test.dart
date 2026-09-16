import 'package:test/test.dart';
import 'package:trotxi_api_client_next/trotxi_api_client_next.dart';


/// tests for DriverAssignedOrOwnApi
void main() {
  final instance = TrotxiApiClientNext().getDriverAssignedOrOwnApi();

  group(DriverAssignedOrOwnApi, () {
    // board Rider
    //
    //Future<BoardingResultResponse> boardRider(String id, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, BoardingInput boardingInput, { String xTrotxiPlatform }) async
    test('test boardRider', () async {
      // TODO
    });

    // complete Trip
    //
    //Future<DriverTripResponse> completeTrip(String id, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test completeTrip', () async {
      // TODO
    });

    // get Manifest
    //
    //Future<ManifestResponse> getManifest(String id, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getManifest', () async {
      // TODO
    });

    // get Trip Summary
    //
    //Future<TripSummaryResponse> getTripSummary(String id, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getTripSummary', () async {
      // TODO
    });

    // list Driver Trips
    //
    //Future<DriverTripPage> listDriverTrips(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, Date fromDate, Date toDate, String routeId, String xTrotxiPlatform }) async
    test('test listDriverTrips', () async {
      // TODO
    });

    // mark No Show
    //
    //Future<BoardingResultResponse> markNoShow(String id, String reservationId, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test markNoShow', () async {
      // TODO
    });

    // record Arrival
    //
    //Future<DriverTripResponse> recordArrival(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, ArrivalInput arrivalInput, { String xTrotxiPlatform }) async
    test('test recordArrival', () async {
      // TODO
    });

    // record Position
    //
    //Future<PositionReceiptResponse> recordPosition(String id, String xTrotxiClient, int xTrotxiBuild, PositionInput positionInput, { String xTrotxiPlatform }) async
    test('test recordPosition', () async {
      // TODO
    });

    // start Trip
    //
    //Future<DriverTripResponse> startTrip(String id, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test startTrip', () async {
      // TODO
    });

  });
}
