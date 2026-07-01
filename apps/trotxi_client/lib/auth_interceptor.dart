import 'package:dio/dio.dart';

import 'authentication_client.dart';

/// Handles 401s by refreshing the session once and retrying the original
/// request. Does NOT attach the bearer token itself — TrotxiApiClient's
/// built-in BearerAuthInterceptor already does that (see bearer_auth.dart);
/// AuthenticationClient keeps it in sync via client.setBearerAuth.
///
/// Must be added to client.dio AFTER ErrorInterceptor (interceptors run
/// onError in reverse of insertion order — last added sees the raw
/// DioException first). If AuthInterceptor runs first, a 401 can be
/// silently resolved via refresh+retry before ErrorInterceptor ever turns
/// it into UnauthorizedException. If ErrorInterceptor ran first instead,
/// AuthInterceptor would only ever see the already-wrapped
/// UnauthorizedException, not the original response — breaking the
/// statusCode check below.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authClient, this._dio);

  final AuthenticationClient _authClient;
  final Dio _dio;

  /// Non-null while a refresh is in flight. Concurrent 401s await this
  /// instead of each starting their own refresh — load-bearing under
  /// token rotation (auth.md: /auth/refresh always returns a new refresh
  /// token and invalidates the old one). Without this, two simultaneous
  /// refreshes would race: the second arrives with a refresh token the
  /// first has already rotated away, and gets rejected for no reason.
  Future<AuthTokens>? _refreshing;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;

    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = requestOptions.extra['retriedAfterRefresh'] == true;
    // Set by AuthenticationClient on the three auth endpoints themselves —
    // without this check, a failing /auth/refresh call would recurse into
    // itself via _refreshOnce below.
    final isAuthEndpoint = requestOptions.extra[skipAuthInterceptorKey] == true;

    if (!isUnauthorized || alreadyRetried || isAuthEndpoint) {
      return handler.next(err);
    }

    try {
      await _refreshOnce();

      final retryOptions = requestOptions
        ..extra['retriedAfterRefresh'] = true;
      // No need to set the Authorization header manually here —
      // re-running through dio.fetch sends this back through
      // BearerAuthInterceptor's onRequest, which reads the now-updated
      // token from TrotxiApiClient's tokens map.

      final response = await _dio.fetch(retryOptions);
      return handler.resolve(response);
    } on NotAuthenticatedException {
      // No stored session to refresh with — let the original 401 through
      // so the app can route to sign-in.
      return handler.next(err);
    } catch (_) {
      // Refresh itself failed (expired/revoked refresh token, network
      // error, etc). Surface the original error; the app should treat
      // this as "session is gone, sign in again."
      return handler.next(err);
    }
  }

  Future<AuthTokens> _refreshOnce() {
    return _refreshing ??= _authClient.refreshSession().whenComplete(() {
      _refreshing = null;
    });
  }
}