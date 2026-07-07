import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for SystemApi
void main() {
  final instance = TrotxiApiClient().getSystemApi();

  group(SystemApi, () {
    // Liveness probe
    //
    //Future<HealthzGet200Response> healthzGet() async
    test('test healthzGet', () async {
      // TODO
    });

    // Readiness probe (pings backing services)
    //
    //Future<ReadyzGet200Response> readyzGet() async
    test('test readyzGet', () async {
      // TODO
    });

    // Service metadata and useful links
    //
    //Future<Get200Response> rootGet() async
    test('test rootGet', () async {
      // TODO
    });

    // Build version and commit
    //
    //Future<VersionGet200Response> versionGet() async
    test('test versionGet', () async {
      // TODO
    });

  });
}
