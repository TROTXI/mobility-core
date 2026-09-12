import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for IncidentsApi
void main() {
  final instance = TrotxiApiClient().getIncidentsApi();

  group(IncidentsApi, () {
    // My incident reports and what operations did with them (driver)
    //
    //Future<MeIncidentsGet200Response> meIncidentsGet() async
    test('test meIncidentsGet', () async {
      // TODO
    });

    // File an incident report (driver)
    //
    // The server attaches the vehicle from the named trip rather than trusting the app to send it. A report with no trip is accepted — a fault found in the yard is exactly the one worth filing.
    //
    //Future<MeIncidentsGet200ResponseIncidentsInner> meIncidentsPost(MeIncidentsPostRequest meIncidentsPostRequest) async
    test('test meIncidentsPost', () async {
      // TODO
    });

  });
}
