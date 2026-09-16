import 'package:test/test.dart';
import 'package:trotxi_api_client_next/trotxi_api_client_next.dart';


/// tests for LiveEligibleApi
void main() {
  final instance = TrotxiApiClientNext().getLiveEligibleApi();

  group(LiveEligibleApi, () {
    // get Live Trip
    //
    //Future<LiveTripResponse> getLiveTrip(String id, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getLiveTrip', () async {
      // TODO
    });

  });
}
