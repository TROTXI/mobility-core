import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for PaymentsApi
void main() {
  final instance = TrotxiApiClient().getPaymentsApi();

  group(PaymentsApi, () {
    // Start a Paystack checkout for the platform membership fee
    //
    //Future<PaymentsSubscribePost200Response> paymentsSubscribePost(PaymentsSubscribePostRequest paymentsSubscribePostRequest) async
    test('test paymentsSubscribePost', () async {
      // TODO
    });

    // Start a Paystack checkout to load ride tokens (pesewas) into the wallet
    //
    //Future<PaymentsSubscribePost200Response> paymentsTopupPost(PaymentsTopupPostRequest paymentsTopupPostRequest) async
    test('test paymentsTopupPost', () async {
      // TODO
    });

    // Paystack payment webhook (signature-verified)
    //
    //Future<WebhooksPaystackPost200Response> webhooksPaystackPost() async
    test('test webhooksPaystackPost', () async {
      // TODO
    });

  });
}
