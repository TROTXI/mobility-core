import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for FlagsApi
void main() {
  final instance = TrotxiApiClient().getFlagsApi();

  group(FlagsApi, () {
    // Feature flags + minimum supported app version (fetched on launch)
    //
    //Future<FlagsGet200Response> flagsGet() async
    test('test flagsGet', () async {
      // TODO
    });

  });
}
