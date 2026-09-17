import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for LiveEligibleApi
void main() {
  final instance = TrotxiApiClient().getLiveEligibleApi();

  group(LiveEligibleApi, () {
    // get Live Trip
    //
    //Future<LiveTripResponse> getLiveTrip(String id, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getLiveTrip', () async {
      // TODO
    });

  });
}
