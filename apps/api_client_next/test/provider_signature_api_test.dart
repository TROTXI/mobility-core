import 'package:test/test.dart';
import 'package:trotxi_api_client_next/trotxi_api_client_next.dart';


/// tests for ProviderSignatureApi
void main() {
  final instance = TrotxiApiClientNext().getProviderSignatureApi();

  group(ProviderSignatureApi, () {
    // receive Paystack Webhook
    //
    //Future<WebhookAck> receivePaystackWebhook(String xPaystackSignature, ReceivePaystackWebhookRequest receivePaystackWebhookRequest) async
    test('test receivePaystackWebhook', () async {
      // TODO
    });

  });
}
