import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for ReservationsApi
void main() {
  final instance = TrotxiApiClient().getReservationsApi();

  group(ReservationsApi, () {
    // List the rider's reservations (newest travel day first)
    //
    //Future<MeReservationsGet200Response> meReservationsGet({ String from }) async
    test('test meReservationsGet', () async {
      // TODO
    });

    // Confirm or decline the daily ride (upsert per day + direction)
    //
    //Future<MeReservationsGet200ResponseReservationsInner> meReservationsPost(MeReservationsPostRequest meReservationsPostRequest) async
    test('test meReservationsPost', () async {
      // TODO
    });

  });
}
