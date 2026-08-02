import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for BoardingApi
void main() {
  final instance = TrotxiApiClient().getBoardingApi();

  group(BoardingApi, () {
    // A trip's manifest — confirmed riders with name + photo (assigned driver only)
    //
    //Future<BoardingManifestGet200Response> boardingManifestGet(String tripId) async
    test('test boardingManifestGet', () async {
      // TODO
    });

    // Verify a scanned rider pass (driver only) and record the scan
    //
    //Future<BoardingScanPost200Response> boardingScanPost(BoardingScanPostRequest boardingScanPostRequest) async
    test('test boardingScanPost', () async {
      // TODO
    });

    // Board a rider via their daily 4-digit PIN (driver only)
    //
    //Future<BoardingVerifyPinPost200Response> boardingVerifyPinPost(BoardingVerifyPinPostRequest boardingVerifyPinPostRequest) async
    test('test boardingVerifyPinPost', () async {
      // TODO
    });

    // Issue the rider a short-lived boarding pass (render as a QR)
    //
    //Future<MePassGet200Response> mePassGet() async
    test('test mePassGet', () async {
      // TODO
    });

  });
}
