import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for DriverOwnApi
void main() {
  final instance = TrotxiApiClient().getDriverOwnApi();

  group(DriverOwnApi, () {
    // change Driver Pin
    //
    //Future changeDriverPin(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, PinChange pinChange, { String xTrotxiPlatform }) async
    test('test changeDriverPin', () async {
      // TODO
    });

    // create Driver Request
    //
    //Future<WorkRequestResponse> createDriverRequest(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, WorkRequestInput workRequestInput, { String xTrotxiPlatform }) async
    test('test createDriverRequest', () async {
      // TODO
    });

    // get Driver Self
    //
    //Future<DriverSelfResponse> getDriverSelf(String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getDriverSelf', () async {
      // TODO
    });

    // list Driver Available Routes
    //
    //Future<RoutePage> listDriverAvailableRoutes(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listDriverAvailableRoutes', () async {
      // TODO
    });

    // list Driver Incidents
    //
    //Future<IncidentPage> listDriverIncidents(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String status, String xTrotxiPlatform }) async
    test('test listDriverIncidents', () async {
      // TODO
    });

    // list Driver Requests
    //
    //Future<WorkRequestPage> listDriverRequests(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String status, String xTrotxiPlatform }) async
    test('test listDriverRequests', () async {
      // TODO
    });

    // report Incident
    //
    //Future<IncidentResponse> reportIncident(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, IncidentInput incidentInput, { String xTrotxiPlatform }) async
    test('test reportIncident', () async {
      // TODO
    });

    // withdraw Driver Request
    //
    //Future<WorkRequestResponse> withdrawDriverRequest(String id, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test withdrawDriverRequest', () async {
      // TODO
    });

  });
}
