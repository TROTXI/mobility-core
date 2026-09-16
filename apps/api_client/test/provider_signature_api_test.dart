import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for ProviderSignatureApi
void main() {
  final instance = TrotxiApiClient().getProviderSignatureApi();

  group(ProviderSignatureApi, () {
    // receive Paystack Webhook
    //
    //Future<WebhookAck> receivePaystackWebhook(String xPaystackSignature, ReceivePaystackWebhookRequest receivePaystackWebhookRequest) async
    test('test receivePaystackWebhook', () async {
      // TODO
    });

  });
}
