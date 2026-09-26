import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for SignedInCatalogApi
void main() {
  final instance = TrotxiApiClient().getSignedInCatalogApi();

  group(SignedInCatalogApi, () {
    // get Trip
    //
    //Future<TripResponse> getTrip(String id, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getTrip', () async {
      // TODO
    });

    // list Trips
    //
    //Future<TripPage> listTrips(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, Date fromDate, Date toDate, String routeId, String xTrotxiPlatform }) async
    test('test listTrips', () async {
      // TODO
    });

  });
}
