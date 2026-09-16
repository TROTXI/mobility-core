import 'package:trotxi_client_next/scoped_token_store.dart';

/// Explicitly scoped replacement credentials. There is no singleton with an
/// implicit backend, and no import of the old access_token/refresh_token keys.
class TokenStorage extends ScopedTokenStore {
  TokenStorage({required String baseUrl, required String realm})
    : super(
        scope: SessionScope(baseUrl: baseUrl, app: 'driver', realm: realm),
      );
}
