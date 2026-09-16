import 'package:test/test.dart';
import 'package:trotxi_api_client_next/trotxi_api_client_next.dart';


/// tests for RiderOwnApi
void main() {
  final instance = TrotxiApiClientNext().getRiderOwnApi();

  group(RiderOwnApi, () {
    // create Commute Request
    //
    //Future<CommuteRequestResponse> createCommuteRequest(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, CommuteRequestInput commuteRequestInput, { String xTrotxiPlatform }) async
    test('test createCommuteRequest', () async {
      // TODO
    });

    // create Purchase
    //
    //Future<PurchaseResponse> createPurchase(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, PurchaseInput purchaseInput, { String xTrotxiPlatform }) async
    test('test createPurchase', () async {
      // TODO
    });

    // decide Reservation
    //
    //Future<ReservationDecisionResultResponse> decideReservation(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, ReservationDecision reservationDecision, { String xTrotxiPlatform }) async
    test('test decideReservation', () async {
      // TODO
    });

    // get Membership
    //
    //Future<MembershipResponse> getMembership(String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getMembership', () async {
      // TODO
    });

    // get Purchase
    //
    //Future<PurchaseResponse> getPurchase(String id, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getPurchase', () async {
      // TODO
    });

    // issue Pass
    //
    //Future<PassResponse> issuePass(String id, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test issuePass', () async {
      // TODO
    });

    // list Commute Requests
    //
    //Future<CommuteRequestPage> listCommuteRequests(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String status, String xTrotxiPlatform }) async
    test('test listCommuteRequests', () async {
      // TODO
    });

    // list Purchases
    //
    //Future<PurchasePage> listPurchases(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, Date fromDate, Date toDate, String xTrotxiPlatform }) async
    test('test listPurchases', () async {
      // TODO
    });

    // list Reservations
    //
    //Future<ReservationPage> listReservations(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, Date fromDate, Date toDate, String xTrotxiPlatform }) async
    test('test listReservations', () async {
      // TODO
    });

    // withdraw Commute Request
    //
    //Future<CommuteRequestResponse> withdrawCommuteRequest(String id, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test withdrawCommuteRequest', () async {
      // TODO
    });

  });
}
