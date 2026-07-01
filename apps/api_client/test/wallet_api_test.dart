import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for WalletApi
void main() {
  final instance = TrotxiApiClient().getWalletApi();

  group(WalletApi, () {
    // Get the authenticated rider token balance (pesewas)
    //
    //Future<MeBalanceGet200Response> meBalanceGet() async
    test('test meBalanceGet', () async {
      // TODO
    });

  });
}
