import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for AuthApi
void main() {
  final instance = TrotxiApiClient().getAuthApi();

  group(AuthApi, () {
    // Sign in with a Google ID token (creates the account on first use)
    //
    //Future<AuthGooglePost200Response> authGooglePost(AuthGooglePostRequest authGooglePostRequest) async
    test('test authGooglePost', () async {
      // TODO
    });

    // Revoke a refresh token (idempotent)
    //
    //Future authLogoutPost(AuthRefreshPostRequest authRefreshPostRequest) async
    test('test authLogoutPost', () async {
      // TODO
    });

    // Exchange a refresh token for a new token pair (rotates the session)
    //
    //Future<AuthRefreshPost200Response> authRefreshPost(AuthRefreshPostRequest authRefreshPostRequest) async
    test('test authRefreshPost', () async {
      // TODO
    });

    // Get the currently authenticated user
    //
    //Future<MeGet200Response> meGet() async
    test('test meGet', () async {
      // TODO
    });

  });
}
