import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';
export 'package:trotxi_api_client/trotxi_api_client.dart';
// A request body for a discriminated union (the work requests in #232) is
// generated as a OneOf, so building one needs this type. Exported here so an
// app never imports the generated client's own dependencies directly.
export 'package:one_of/one_of.dart' show OneOf, OneOf2;

class TrotxiException implements Exception {
  final String message;
  const TrotxiException(this.message);
}

class UnauthorizedException extends TrotxiException {
  const UnauthorizedException()
      : super('Session expired. Please log in again.');
}

class RateLimitException extends TrotxiException {
  final Duration retryAfter;
  const RateLimitException(this.retryAfter)
      : super('Too many requests. Please try again shortly.');
}

/// Too many wrong PINs on a driver credential (HTTP 423). Distinct from a
/// rate limit: the lock is on the credential, not the caller, so waiting on a
/// different handset does not help and the driver needs operations.
class CredentialLockedException extends TrotxiException {
  final Duration retryAfter;
  const CredentialLockedException(this.retryAfter)
      : super('Too many incorrect PINs. Try again later or call operations.');
}

/// Operations has suspended this account (HTTP 403 on sign-in). Nothing the
/// driver can do from the app, so the UI has to say so rather than offering a
/// retry that will never work.
class AccountSuspendedException extends TrotxiException {
  const AccountSuspendedException()
      : super('This driver account is suspended. Contact operations.');
}

/// Wrong credentials on a sign-in attempt (HTTP 401 on an /auth/ route).
/// Separate from [UnauthorizedException], which means a session that HAD been
/// valid has expired: telling a driver "please log in again" while they are
/// staring at the log-in screen is the wrong sentence.
class InvalidCredentialsException extends TrotxiException {
  const InvalidCredentialsException(
      [String message = 'Check your details and try again.'])
      : super(message);
}

class OfflineException extends TrotxiException {
  const OfflineException([String message = 'No internet connection.'])
      : super(message);
}

class ApiException extends TrotxiException {
  final int statusCode;
  const ApiException(this.statusCode, String message) : super(message);
}

/// Interface for app-level storage of JWT tokens
abstract class TokenStore {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearTokens();
}

/// 1. AuthInterceptor: Handles Bearer injection & Automatic 401 Token Refresh
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStore _tokenStore;
  static const _retried = 'trotxi.auth.retried';

  /// The "whiteboard": null when no refresh is in progress. The first 401
  /// to arrive starts a refresh and writes its Future here; any 401 that
  /// arrives while this is non-null just awaits the same Future instead
  /// of starting a redundant refresh of its own.
  Future<String>? _refreshFuture;
  String? _rotatedFrom;
  String? _rotatedTo;

  AuthInterceptor({
    required Dio dio,
    required TokenStore tokenStore,
  })  : _dio = dio,
        _tokenStore = tokenStore;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenStore.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // A retry re-enters this interceptor. Never refresh twice for one request,
    // or queue onError while awaiting a retry that needs that same queue.
    if (err.response?.statusCode != 401 ||
        err.requestOptions.extra[_retried] == true) {
      return handler.next(err);
    }

    // Guard: Prevent infinite loops if the refresh call itself returns 401
    final requestPath = err.requestOptions.path;
    if (Uri.parse(requestPath).path == '/auth/refresh') {
      Object? payload = err.requestOptions.data;
      if (payload is String) {
        try {
          payload = jsonDecode(payload);
        } on FormatException {
          payload = null;
        }
      }
      if (payload is Map &&
          payload['refreshToken'] != null &&
          await _tokenStore.getRefreshToken() == payload['refreshToken']) {
        await _tokenStore.clearTokens();
      }
      return handler.next(err);
    }

    // A 401 from a SIGN-IN route means the credentials were wrong, not that a
    // session expired. Refreshing makes no sense (there is no session yet), and
    // clearing tokens on the way past would sign out a driver who mistyped a
    // PIN while already signed in on the same handset.
    if (_isSignInPath(requestPath)) {
      return handler.next(err);
    }

    late final String newAccessToken;
    try {
      final currentToken = await _tokenStore.getAccessToken();
      // A delayed 401 may belong to a token another request already rotated.
      if (_refreshFuture != null) {
        newAccessToken = await _refreshFuture!;
      } else if (currentToken != null &&
          currentToken.isNotEmpty &&
          err.requestOptions.headers['Authorization'] !=
              'Bearer $currentToken') {
        // Do not replay an old session's operation under an unrelated new login.
        if (currentToken != _rotatedTo ||
            err.requestOptions.headers['Authorization'] !=
                'Bearer $_rotatedFrom') {
          throw StateError('Session changed while the request was in flight');
        }
        newAccessToken = currentToken;
      } else {
        newAccessToken =
            await (_refreshFuture ??= _refreshTokens(currentToken));
      }
    } on DioException catch (refreshError) {
      // Surface the refresh timeout/5xx, not the original access-token 401.
      return handler.next(refreshError);
    } catch (error, stackTrace) {
      // Missing/malformed tokens or storage failures aren't proof of revocation.
      return handler.next(DioException(
        requestOptions: err.requestOptions,
        error: const ApiException(
            0, 'Unable to restore the session. Please retry.'),
        stackTrace: stackTrace,
      ));
    }

    final retry = err.requestOptions.copyWith(
      headers: {
        ...err.requestOptions.headers,
        'Authorization': 'Bearer $newAccessToken'
      },
      extra: {...err.requestOptions.extra, _retried: true},
      data: err.requestOptions.data is FormData
          ? (err.requestOptions.data as FormData).clone()
          : err.requestOptions.data,
    );
    try {
      return handler.resolve(await _dio.fetch(retry));
    } on DioException catch (retryError) {
      // Keep newly saved tokens even if the retried operation fails.
      return handler.next(retryError);
    }
  }

  /// Whether a path is one of the sign-in routes, where a 401 is a rejected
  /// credential rather than an expired session.
  static bool _isSignInPath(String path) {
    return path.contains('auth/driver') ||
        path.contains('auth/google') ||
        path.contains('auth/apple');
  }

  /// Performs the actual refresh call. Only ever invoked once per batch of
  /// concurrent 401s, via the `_refreshFuture ??=` guard in onError.
  Future<String> _refreshTokens(String? previousAccessToken) async {
    try {
      final refreshToken = await _tokenStore.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw StateError('No refresh token available');
      }

      // Instantiate a isolated client for the refresh call
      final refreshClient = TrotxiApiClient(
        // Keep configured transport/TLS/timeouts, but do not recurse through
        // auth or map away the refresh endpoint's HTTP status.
        dio: _dio.clone(interceptors: Interceptors()),
        interceptors: [],
      );

      // Construct the generated built_value request model
      final refreshRequest = AuthRefreshPostRequest(
        (b) => b..refreshToken = refreshToken,
      );

      // Call the generated AuthApi endpoint
      late final Response<AuthRefreshPost200Response> response;
      try {
        response = await refreshClient.getAuthApi().authRefreshPost(
              authRefreshPostRequest: refreshRequest,
            );
      } on DioException catch (error) {
        // One clear per shared refresh, only on authoritative rejection. Do not
        // clear a newer login that replaced this credential while we waited.
        if (error.response?.statusCode == 401 &&
            await _tokenStore.getRefreshToken() == refreshToken) {
          await _tokenStore.clearTokens();
        }
        rethrow;
      }

      final newAccessToken = response.data?.accessToken;
      final newRefreshToken = response.data?.refreshToken;

      if (newAccessToken == null ||
          newAccessToken.isEmpty ||
          newRefreshToken == null ||
          newRefreshToken.isEmpty) {
        throw StateError('Refresh response missing tokens');
      }

      if (await _tokenStore.getRefreshToken() != refreshToken) {
        throw StateError('Session changed while refreshing');
      }
      // Store new credentials
      await _tokenStore.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      _rotatedFrom = previousAccessToken;
      _rotatedTo = newAccessToken;

      return newAccessToken;
    } finally {
      // Reset the whiteboard once this refresh settles (success or
      // failure), so the *next* distinct expiry event starts fresh
      // instead of reusing a completed/failed Future.
      _refreshFuture = null;
    }
  }
}

/// 2. ErrorInterceptor: Maps raw DioExceptions to typed Domain Exceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // A retry through the shared Dio has already crossed this mapper once.
    if (err.error is TrotxiException) return handler.next(err);
    final response = err.response;

    if (response == null) {
      if (err.type == DioExceptionType.connectionError ||
          err.type == DioExceptionType.unknown ||
          err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.sendTimeout ||
          err.type == DioExceptionType.receiveTimeout) {
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const OfflineException(),
          ),
        );
      }
      return handler.next(err);
    }

    final isSignIn = AuthInterceptor._isSignInPath(err.requestOptions.path);

    switch (response.statusCode) {
      case 401:
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: isSignIn
                ? const InvalidCredentialsException(
                    'Invalid driver code or PIN.')
                : const UnauthorizedException(),
          ),
        );
      case 403:
        if (isSignIn) {
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: const AccountSuspendedException(),
            ),
          );
        }
        break;
      case 423:
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: CredentialLockedException(_parseRetryAfter(response)),
          ),
        );
      case 429:
        final retryAfter = _parseRetryAfter(response);
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: RateLimitException(retryAfter),
          ),
        );
      default:
        break;
    }

    return handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: ApiException(
          response.statusCode ?? 0,
          response.statusMessage ?? 'Unknown error',
        ),
      ),
    );
  }

  Duration _parseRetryAfter(Response response) {
    final header = response.headers.value('retry-after');
    final seconds = int.tryParse(header ?? '') ?? 5;
    return Duration(seconds: seconds);
  }
}

/// 3. Factory: Assembles the client with correct interceptor order
class TrotxiClientFactory {
  static TrotxiApiClient create({
    required String baseUrl,
    required TokenStore tokenStore,
  }) {
    final client = TrotxiApiClient(basePathOverride: baseUrl);

    // CRITICAL: AuthInterceptor MUST come BEFORE ErrorInterceptor.
    // Otherwise ErrorInterceptor transforms 401s to UnauthorizedException
    // before AuthInterceptor can trigger the refresh flow.
    client.dio.interceptors.add(
      AuthInterceptor(
        dio: client.dio,
        tokenStore: tokenStore,
      ),
    );
    client.dio.interceptors.add(ErrorInterceptor());

    return client;
  }
}
