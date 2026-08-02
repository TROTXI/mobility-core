import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for RidesApi
void main() {
  final instance = TrotxiApiClient().getRidesApi();

  group(RidesApi, () {
    // Remaining ride entitlement + Ride Credit balance
    //
    //Future<MeRidesGet200Response> meRidesGet() async
    test('test meRidesGet', () async {
      // TODO
    });

  });
}
