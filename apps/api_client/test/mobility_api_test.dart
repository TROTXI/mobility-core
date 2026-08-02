import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for MobilityApi
void main() {
  final instance = TrotxiApiClient().getMobilityApi();

  group(MobilityApi, () {
    // List all routes
    //
    //Future<BuiltList<RoutesGet200ResponseInner>> routesGet() async
    test('test routesGet', () async {
      // TODO
    });

    // Get a route with its stops in order
    //
    //Future<RoutesIdGet200Response> routesIdGet(String id) async
    test('test routesIdGet', () async {
      // TODO
    });

    // List trips, optionally filtered by route
    //
    //Future<TripsGet200Response> tripsGet({ String routeId }) async
    test('test tripsGet', () async {
      // TODO
    });

    // Get a trip by id
    //
    //Future<TripsGet200ResponseTripsInner> tripsIdGet(String id) async
    test('test tripsIdGet', () async {
      // TODO
    });

    // Get a trip's latest position with a deterministic ETA to each upcoming stop
    //
    //Future<TripsIdPositionGet200Response> tripsIdPositionGet(String id) async
    test('test tripsIdPositionGet', () async {
      // TODO
    });

    // Report a GPS fix for a trip (assigned driver only)
    //
    //Future<TripsIdPositionPost200Response> tripsIdPositionPost(String id, TripsIdPositionPostRequest tripsIdPositionPostRequest) async
    test('test tripsIdPositionPost', () async {
      // TODO
    });

  });
}
