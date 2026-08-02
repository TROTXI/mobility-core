import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for AdminApi
void main() {
  final instance = TrotxiApiClient().getAdminApi();

  group(AdminApi, () {
    // Prompt a day's route subscribers to confirm (seed pending + push)
    //
    //Future<AdminAskDispatchPost200Response> adminAskDispatchPost(AdminAskDispatchPostRequest adminAskDispatchPostRequest) async
    test('test adminAskDispatchPost', () async {
      // TODO
    });

    // Month-end: convert every active rider's unused rides to Ride Credits
    //
    //Future<AdminConvertCreditsPost200Response> adminConvertCreditsPost() async
    test('test adminConvertCreditsPost', () async {
      // TODO
    });

    // List all drivers
    //
    //Future<BuiltList<AdminDriversGet200ResponseInner>> adminDriversGet() async
    test('test adminDriversGet', () async {
      // TODO
    });

    // Update a driver
    //
    //Future<AdminDriversGet200ResponseInner> adminDriversIdPatch(String id, AdminDriversIdPatchRequest adminDriversIdPatchRequest) async
    test('test adminDriversIdPatch', () async {
      // TODO
    });

    // Create a driver
    //
    //Future<AdminDriversGet200ResponseInner> adminDriversPost(AdminDriversPostRequest adminDriversPostRequest) async
    test('test adminDriversPost', () async {
      // TODO
    });

    // List all feature flags
    //
    //Future<BuiltList<AdminFlagsGet200ResponseInner>> adminFlagsGet() async
    test('test adminFlagsGet', () async {
      // TODO
    });

    // Create or update a feature flag
    //
    //Future<AdminFlagsGet200ResponseInner> adminFlagsKeyPut(String key, AdminFlagsKeyPutRequest adminFlagsKeyPutRequest) async
    test('test adminFlagsKeyPut', () async {
      // TODO
    });

    // List the minimum supported app version per platform
    //
    //Future<BuiltList<AdminMinVersionsGet200ResponseInner>> adminMinVersionsGet() async
    test('test adminMinVersionsGet', () async {
      // TODO
    });

    // Set the minimum supported app version for a platform
    //
    //Future<AdminMinVersionsGet200ResponseInner> adminMinVersionsPlatformPut(String platform, AdminMinVersionsPlatformPutRequest adminMinVersionsPlatformPutRequest) async
    test('test adminMinVersionsPlatformPut', () async {
      // TODO
    });

    // Cutoff default-yes: flip still-pending reservations to reserved
    //
    //Future<AdminResolveDefaultsPost200Response> adminResolveDefaultsPost(AdminAskDispatchPostRequest adminAskDispatchPostRequest) async
    test('test adminResolveDefaultsPost', () async {
      // TODO
    });

    // Cutoff: deduct confirmed-but-unboarded seats as no-shows
    //
    //Future<AdminResolveNoShowsPost200Response> adminResolveNoShowsPost(AdminAskDispatchPostRequest adminAskDispatchPostRequest) async
    test('test adminResolveNoShowsPost', () async {
      // TODO
    });

    // List all routes
    //
    //Future<BuiltList<RoutesGet200ResponseInner>> adminRoutesGet() async
    test('test adminRoutesGet', () async {
      // TODO
    });

    // Update a route
    //
    //Future<RoutesGet200ResponseInner> adminRoutesIdPatch(String id, AdminRoutesIdPatchRequest adminRoutesIdPatchRequest) async
    test('test adminRoutesIdPatch', () async {
      // TODO
    });

    // Attach a stop to a route at a sequence position
    //
    //Future<AdminRoutesIdStopsPost200Response> adminRoutesIdStopsPost(String id, AdminRoutesIdStopsPostRequest adminRoutesIdStopsPostRequest) async
    test('test adminRoutesIdStopsPost', () async {
      // TODO
    });

    // Create a route
    //
    //Future<RoutesGet200ResponseInner> adminRoutesPost(AdminRoutesPostRequest adminRoutesPostRequest) async
    test('test adminRoutesPost', () async {
      // TODO
    });

    // List all stops
    //
    //Future<BuiltList<AdminStopsGet200ResponseInner>> adminStopsGet() async
    test('test adminStopsGet', () async {
      // TODO
    });

    // Update a stop
    //
    //Future<AdminStopsGet200ResponseInner> adminStopsIdPatch(String id, AdminStopsIdPatchRequest adminStopsIdPatchRequest) async
    test('test adminStopsIdPatch', () async {
      // TODO
    });

    // Create a stop
    //
    //Future<AdminStopsGet200ResponseInner> adminStopsPost(AdminStopsPostRequest adminStopsPostRequest) async
    test('test adminStopsPost', () async {
      // TODO
    });

    // List trips, filterable by route, status, and UTC day
    //
    //Future<BuiltList<TripsGet200ResponseTripsInner>> adminTripsGet({ String routeId, String status, String date }) async
    test('test adminTripsGet', () async {
      // TODO
    });

    // Assign a vehicle and/or driver to a trip
    //
    //Future<TripsGet200ResponseTripsInner> adminTripsIdAssignmentPut(String id, AdminTripsIdAssignmentPutRequest adminTripsIdAssignmentPutRequest) async
    test('test adminTripsIdAssignmentPut', () async {
      // TODO
    });

    // Update a trip (status / schedule)
    //
    //Future<TripsGet200ResponseTripsInner> adminTripsIdPatch(String id, AdminTripsIdPatchRequest adminTripsIdPatchRequest) async
    test('test adminTripsIdPatch', () async {
      // TODO
    });

    // Create a trip
    //
    //Future<TripsGet200ResponseTripsInner> adminTripsPost(AdminTripsPostRequest adminTripsPostRequest) async
    test('test adminTripsPost', () async {
      // TODO
    });

    // Change a user's role (commuter | driver | admin)
    //
    //Future<AdminUsersIdRolePatch200Response> adminUsersIdRolePatch(String id, AdminUsersIdRolePatchRequest adminUsersIdRolePatchRequest) async
    test('test adminUsersIdRolePatch', () async {
      // TODO
    });

    // List all vehicles
    //
    //Future<BuiltList<AdminVehiclesGet200ResponseInner>> adminVehiclesGet() async
    test('test adminVehiclesGet', () async {
      // TODO
    });

    // Update a vehicle
    //
    //Future<AdminVehiclesGet200ResponseInner> adminVehiclesIdPatch(String id, AdminVehiclesIdPatchRequest adminVehiclesIdPatchRequest) async
    test('test adminVehiclesIdPatch', () async {
      // TODO
    });

    // Create a vehicle
    //
    //Future<AdminVehiclesGet200ResponseInner> adminVehiclesPost(AdminVehiclesPostRequest adminVehiclesPostRequest) async
    test('test adminVehiclesPost', () async {
      // TODO
    });

  });
}
