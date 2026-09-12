import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for WorkApi
void main() {
  final instance = TrotxiApiClient().getWorkApi();

  group(WorkApi, () {
    // My requests and what operations decided
    //
    //Future<MeWorkRequestsGet200Response> meWorkRequestsGet() async
    test('test meWorkRequestsGet', () async {
      // TODO
    });

    // Take back a request operations has not answered yet
    //
    //Future<MeWorkRequestsGet200ResponseRequestsInner> meWorkRequestsIdWithdrawPost(String id) async
    test('test meWorkRequestsIdWithdrawPost', () async {
      // TODO
    });

    // Ask operations for a route change or leave
    //
    // A proposal, not an edit. Nothing about the driver’s published assignment changes when this succeeds, or when it is later approved.
    //
    //Future<MeWorkRequestsGet200ResponseRequestsInner> meWorkRequestsPost(MeWorkRequestsPostRequest meWorkRequestsPostRequest) async
    test('test meWorkRequestsPost', () async {
      // TODO
    });

    // Routes operations will accept reassignment requests for
    //
    // Not every corridor. A route appears only once operations opens it, so a driver never asks for something that could only ever be declined.
    //
    //Future<MeWorkRoutesGet200Response> meWorkRoutesGet() async
    test('test meWorkRoutesGet', () async {
      // TODO
    });

  });
}
