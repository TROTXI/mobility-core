import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';

import 'auth_result.dart';

/// Key used to tag requests that must never trigger AuthInterceptor's
/// refresh-and-retry logic — the three auth endpoints themselves. Without
/// this, a /auth/refresh call that itself gets a 401 (expired/revoked
/// refresh token) would cause AuthInterceptor to try refreshing again,
/// deadlocking on the in-flight refresh that is the very call failing.
const skipAuthInterceptorKey = 'skipAuth';

/// Simple value holder for a token pair returned by the auth endpoints.
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}

/// Thrown when the client is asked to do something that requires a
/// signed-in user (e.g. logout) but no refresh token is stored.
class NotAuthenticatedException implements Exception {
  const NotAuthenticatedException([this.message = 'No stored session.']);
  final String message;

  @override
  String toString() => 'NotAuthenticatedException: $message';
}

/// Wraps the generated [TrotxiApiClient]'s auth endpoints and owns:
/// - persistence of the token pair in secure storage
/// - pushing the access token into the client's built-in
///   BearerAuthInterceptor via setBearerAuth, so every other generated
///   API call (wallet, payments, ...) gets it automatically
///
/// This is the class the rest of the app (and AuthInterceptor) should
/// talk to instead of calling client.getAuthApi() directly.
class AuthenticationClient {
  AuthenticationClient({
    required TrotxiApiClient client,
    FlutterSecureStorage? secureStorage,
  })  : _client = client,
        _authApi = client.getAuthApi(),
        _storage = secureStorage ?? const FlutterSecureStorage();

  final TrotxiApiClient _client;
  final AuthApi _authApi;
  final FlutterSecureStorage _storage;

  /// Name registered with setBearerAuth/removeBearerAuth. Must match the
  /// `name` in the generated api's `secure` metadata — confirmed against
  /// meGet's `{'type': 'http', 'scheme': 'bearer', 'name': 'bearerAuth'}`.
  static const _bearerAuthName = 'bearerAuth';

  static const _accessTokenKey = 'trotxi.auth.accessToken';
  static const _refreshTokenKey = 'trotxi.auth.refreshToken';

  /// Sign in with a Google ID token. Persists the returned token pair,
  /// pushes the access token into the client's bearer interceptor, and
  /// returns the user included in the response (no separate `/me` round
  /// trip needed — auth_google_post200_response.dart nests a
  /// MeGet200Response).
  ///
  /// Returns an [AuthResult] rather than throwing — [AuthFailure] covers
  /// the 401/429/503/network cases documented in auth.md. This method
  /// never returns [AuthCancelled] itself — cancellation happens one
  /// layer up, in GoogleAuthOrchestrator, before this is even called.
  Future<AuthResult> signInWithGoogle(String googleIdToken) async {
    try {
      final response = await _authApi.authGooglePost(
        authGooglePostRequest: AuthGooglePostRequest(
          (b) => b..idToken = googleIdToken,
        ),
        extra: const {skipAuthInterceptorKey: true},
      );

      final data = response.data;
      if (data == null) {
        return const AuthFailure(AuthFailureReason.unknown);
      }

      await _applyTokens(AuthTokens(
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
      ));

      return AuthSuccess(data.user);
    } on DioException catch (e) {
      return AuthFailure.fromDioException(e);
    }
  }

  /// Exchanges the stored refresh token for a new pair, persisting the
  /// result and updating the bearer interceptor. Throws
  /// [NotAuthenticatedException] if nothing is stored, or [DioException]
  /// if the request fails (e.g. 401 = refresh token expired/revoked).
  ///
  /// This is the method AuthInterceptor's 401 handler calls. It's tagged
  /// with skipAuthInterceptorKey so a failure here can't recursively
  /// trigger another refresh attempt.
  Future<AuthTokens> refreshSession() async {
    final storedRefreshToken = await _storage.read(key: _refreshTokenKey);
    if (storedRefreshToken == null) {
      throw const NotAuthenticatedException();
    }

    final response = await _authApi.authRefreshPost(
      authRefreshPostRequest: AuthRefreshPostRequest(
        (b) => b..refreshToken = storedRefreshToken,
      ),
      extra: const {skipAuthInterceptorKey: true},
    );

    final data = response.data;
    if (data == null) {
      throw StateError('authRefreshPost returned no data');
    }

    final tokens = AuthTokens(
      accessToken: data.accessToken,
      refreshToken: data.refreshToken,
    );

    await _applyTokens(tokens);
    return tokens;
  }

  /// Revokes the stored refresh token server-side and clears local
  /// storage + the bearer interceptor. Safe to call even with no
  /// session (endpoint is idempotent) — still clears local state either way.
  Future<void> logout() async {
    final storedRefreshToken = await _storage.read(key: _refreshTokenKey);

    if (storedRefreshToken != null) {
      try {
        await _authApi.authLogoutPost(
          authRefreshPostRequest: AuthRefreshPostRequest(
            (b) => b..refreshToken = storedRefreshToken,
          ),
          extra: const {skipAuthInterceptorKey: true},
        );
      } on DioException {
        // Endpoint is documented idempotent/best-effort server-side;
        // still clear local state below regardless of network outcome.
      }
    }

    await _clearTokens();
  }

  /// Fetches the current user. The client's built-in BearerAuthInterceptor
  /// attaches the token automatically (meGet has `secure: [bearerAuth]`
  /// per the generated api) — nothing to do here beyond the call itself.
  Future<MeGet200Response> getCurrentUser() async {
    final response = await _authApi.meGet();
    final data = response.data;
    if (data == null) {
      throw StateError('meGet returned no data');
    }
    return data;
  }

  Future<bool> hasStoredSession() async {
    return await _storage.read(key: _refreshTokenKey) != null;
  }

  /// Persists tokens to secure storage AND pushes the access token into
  /// the client's BearerAuthInterceptor. Both need to happen together —
  /// storage alone doesn't affect outgoing requests until the interceptor
  /// also knows about it.
  Future<void> _applyTokens(AuthTokens tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
    _client.setBearerAuth(_bearerAuthName, tokens.accessToken);
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    _client.removeBearerAuth(_bearerAuthName);
  }
}