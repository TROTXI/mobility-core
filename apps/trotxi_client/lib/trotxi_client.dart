import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';
import 'package:trotxi_client/src/api.dart';
import 'package:trotxi_client/src/client_metadata.dart';
export 'package:trotxi_api_client/trotxi_api_client.dart';
// A request body for a discriminated union (the work requests in #232) is
// generated as a OneOf, so building one needs this type. Exported here so an
// app never imports the generated client's own dependencies directly.
export 'package:one_of/one_of.dart' show OneOf, OneOf2;
export 'package:trotxi_client/src/api.dart';
export 'package:trotxi_client/src/client_metadata.dart';
export 'package:trotxi_client/src/idempotency.dart';

class TrotxiException implements Exception {
  final String message;
  const TrotxiException(this.message);

  /// Without this a `debugPrint` of a caught failure reads
  /// "Instance of 'ApiException'", which says nothing about what went wrong.
  @override
  String toString() => '$runtimeType: $message';
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
/// account holder can do from the app, so the UI has to say so rather than
/// offering a retry that will never work.
class AccountSuspendedException extends TrotxiException {
  const AccountSuspendedException()
      : super('This account is suspended. Contact operations.');
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

/// The request reached the API but no response arrived inside the receive
/// budget. On the hosted staging API this is almost always a cold start, so
/// the copy says "try again" rather than blaming the connection. It extends
/// [OfflineException] so the screens that already branch on that type keep
/// showing their retry affordance.
class ServerTimeoutException extends OfflineException {
  const ServerTimeoutException()
      : super('The server is taking too long to respond. Please try again.');
}

/// This build is too old for the API (HTTP 426). Every `/v1` call carries an
/// `X-Trotxi-Build`, and the API refuses builds it no longer supports — so
/// there is nothing to retry and the only way forward is an app update.
class UnsupportedBuildException extends TrotxiException {
  const UnsupportedBuildException()
      : super('This version of the app is out of date. Please update.');
}

class ApiException extends TrotxiException {
  final int statusCode;

  /// The API's own `error.code` when it sent one (`client_metadata_required`,
  /// `client_upgrade_required`, ...). That string is usually the only thing
  /// that says *why* a 400 was a 400, so it is worth carrying.
  final String? code;

  const ApiException(this.statusCode, String message, {this.code})
      : super(message);

  @override
  String toString() =>
      'ApiException($statusCode${code == null ? '' : ' $code'}): $message';
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
class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final TokenStore _tokenStore;
  final TrotxiClientMetadata _metadata;

  /// The "whiteboard": null when no refresh is in progress. The first 401
  /// to arrive starts a refresh and writes its Future here; any 401 that
  /// arrives while this is non-null just awaits the same Future instead
  /// of starting a redundant refresh of its own.
  Future<String>? _refreshFuture;

  AuthInterceptor({
    required Dio dio,
    required TokenStore tokenStore,
    required TrotxiClientMetadata metadata,
  })  : _dio = dio,
        _tokenStore = tokenStore,
        _metadata = metadata;

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
    // Only attempt refresh on genuine HTTP 401 status codes
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Guard: Prevent infinite loops if the refresh call itself returns 401
    final requestPath = err.requestOptions.path;
    if (_isRefreshPath(requestPath)) {
      await _tokenStore.clearTokens();
      return handler.next(err);
    }

    // A 401 from a SIGN-IN route means the credentials were wrong, not that a
    // session expired. Refreshing makes no sense (there is no session yet), and
    // clearing tokens on the way past would sign out a driver who mistyped a
    // PIN while already signed in on the same handset.
    if (_isSignInPath(requestPath)) {
      return handler.next(err);
    }

    try {
      // Single-flight: if a refresh is already in progress, await that
      // one instead of starting a new one. First caller creates the
      // Future and stores it; every concurrent caller reuses it.
      final newAccessToken = await (_refreshFuture ??= _refreshTokens());

      // Clone and retry the original failed request with the new access token
      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      final clonedResponse = await _dio.fetch(requestOptions);
      return handler.resolve(clonedResponse);
    } catch (refreshError) {
      await _tokenStore.clearTokens();
      return handler.next(err);
    }
  }

  /// The route paths without the query string, so a path is matched on what
  /// it addresses rather than on a substring that a cursor could also carry.
  static String _routePath(String path) => Uri.tryParse(path)?.path ?? path;

  /// Whether a path is one of the sign-in routes, where a 401 is a rejected
  /// credential rather than an expired session.
  ///
  /// Matched exactly: `/v1/auth/driver/pin` is a *signed-in* PIN change, so a
  /// 401 there really is an expired session and must reach the refresh below.
  static bool _isSignInPath(String path) {
    final route = _routePath(path);
    return route.endsWith('/v1/auth/google') ||
        route.endsWith('/v1/auth/driver');
  }

  /// Whether a path is the refresh route itself, where a 401 means the
  /// refresh token is spent and there is nothing left to retry with.
  static bool _isRefreshPath(String path) =>
      _routePath(path).endsWith('/v1/auth/refresh');

  /// Performs the actual refresh call. Only ever invoked once per batch of
  /// concurrent 401s, via the `_refreshFuture ??=` guard in onError.
  Future<String> _refreshTokens() async {
    try {
      final refreshToken = await _tokenStore.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw StateError('No refresh token available');
      }

      // An isolated client for the refresh call: it must not pick up this
      // interceptor, or a 401 here would recurse back into a refresh.
      final refreshClient = TrotxiApiClient(
        basePathOverride: _dio.options.baseUrl,
      );
      refreshClient.dio.options.connectTimeout = _dio.options.connectTimeout;
      refreshClient.dio.options.receiveTimeout = _dio.options.receiveTimeout;

      // Construct the generated built_value request model
      final refreshRequest = RefreshInput(
        (b) => b..refreshToken = refreshToken,
      );

      // POST /v1/auth/refresh. Like every /v1 route it wants the client
      // metadata headers; without them the API answers 400, not 401, so the
      // session would look unrecoverable when it is merely unidentified.
      final response = await refreshClient.getPublicApi().refreshSession(
            xTrotxiClient: _metadata.client,
            xTrotxiBuild: _metadata.build,
            xTrotxiPlatform: _metadata.platform,
            refreshInput: refreshRequest,
          );

      final tokens = response.data?.data;
      final newAccessToken = tokens?.accessToken;
      final newRefreshToken = tokens?.refreshToken;

      if (newAccessToken == null || newRefreshToken == null) {
        throw StateError('Refresh response missing tokens');
      }

      // Store new credentials
      await _tokenStore.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

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
    final response = err.response;

    if (response == null) {
      if (err.type == DioExceptionType.receiveTimeout ||
          err.type == DioExceptionType.sendTimeout) {
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const ServerTimeoutException(),
          ),
        );
      }
      if (err.type == DioExceptionType.connectionError ||
          err.type == DioExceptionType.unknown ||
          err.type == DioExceptionType.connectionTimeout) {
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
                ? _rejectedCredentialsFor(err.requestOptions.path)
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
      case 426:
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const UnsupportedBuildException(),
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

    final failure = _errorBody(response);
    return handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: ApiException(
          response.statusCode ?? 0,
          failure?.message ?? response.statusMessage ?? 'Unknown error',
          code: failure?.code,
        ),
      ),
    );
  }

  /// The API answers every failure with
  /// `{"error": {"code": ..., "message": ..., "requestId": ...}}`.
  ///
  /// Dio hands that back as already-decoded JSON, or as a String when the
  /// response had no JSON content type. Either way it is far more useful than
  /// the bare status line, so it is worth the defensive unpacking — a body
  /// that is shaped differently (a proxy's HTML error page, say) just yields
  /// null and the caller falls back to the status message.
  _ApiFailure? _errorBody(Response response) {
    var body = response.data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } catch (_) {
        return null;
      }
    }
    if (body is! Map) return null;
    final error = body['error'];
    if (error is! Map) return null;
    final code = error['code'];
    final message = error['message'];
    return _ApiFailure(
      code: code is String ? code : null,
      message: message is String ? message : null,
    );
  }

  /// Which credential the rider or driver actually got wrong, so the sign-in
  /// screen can name it instead of guessing "driver code or PIN" at someone
  /// who tapped Sign in with Google.
  InvalidCredentialsException _rejectedCredentialsFor(String path) {
    return AuthInterceptor._routePath(path).endsWith('/v1/auth/google')
        ? const InvalidCredentialsException(
            'Google could not sign you in. Please try again.',
          )
        : const InvalidCredentialsException('Invalid driver code or PIN.');
  }

  Duration _parseRetryAfter(Response response) {
    final header = response.headers.value('retry-after');
    final seconds = int.tryParse(header ?? '') ?? 5;
    return Duration(seconds: seconds);
  }
}

/// The `error` object the API sends alongside a failing status.
class _ApiFailure {
  const _ApiFailure({this.code, this.message});
  final String? code;
  final String? message;
}

/// 3. Factory: Assembles the client with correct interceptor order
class TrotxiClientFactory {
  /// The generated client defaults to a 3s receive timeout, which is shorter
  /// than a cold start on the hosted API — a first call after an idle period
  /// would surface as "no internet connection" to the user. These are the
  /// budgets the app actually waits for.
  ///
  /// The receive budget covers a cold start on the free Render tier, which
  /// spins the service down when idle and can take the better part of a
  /// minute to answer the request that wakes it. Warm responses land in well
  /// under a second, so this ceiling only ever costs the first caller.
  static const _connectTimeout = Duration(seconds: 15);
  static const _receiveTimeout = Duration(seconds: 60);

  static TrotxiApiClient create({
    required String baseUrl,
    required TokenStore tokenStore,
    required TrotxiClientMetadata metadata,
  }) {
    final client = TrotxiApiClient(basePathOverride: baseUrl);
    client.dio.options.connectTimeout = _connectTimeout;
    client.dio.options.receiveTimeout = _receiveTimeout;

    // CRITICAL: AuthInterceptor MUST come BEFORE ErrorInterceptor.
    // Otherwise ErrorInterceptor transforms 401s to UnauthorizedException
    // before AuthInterceptor can trigger the refresh flow.
    client.dio.interceptors.add(AuthInterceptor(
      dio: client.dio,
      tokenStore: tokenStore,
      metadata: metadata,
    ));

    client.dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
    client.dio.interceptors.add(ErrorInterceptor());

    return client;
  }
}
