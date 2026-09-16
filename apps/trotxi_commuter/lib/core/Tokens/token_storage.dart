import 'package:trotxi_client_next/scoped_token_store.dart';

class TokenStorage extends ScopedTokenStore {
  TokenStorage({required String baseUrl, required String realm})
    : super(
        scope: SessionScope(baseUrl: baseUrl, realm: realm, app: 'commuter'),
      );
}
