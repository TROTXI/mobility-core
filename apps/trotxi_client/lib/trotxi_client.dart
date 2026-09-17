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
  const InvalidCredentialsException([
    String message = 'Check your details and try again.',
  ]) : super(message);
}

/// The server will not serve this build (HTTP 426). Per app and platform, so a
/// commuter release being too old says nothing about the driver app. Nothing
/// the rider can do in the app except update it.
class UpgradeRequiredException extends TrotxiException {
  const UpgradeRequiredException()
      : super('Please update the app to continue.');
}

class OfflineException extends TrotxiException {
  const OfflineException([String message = 'No internet connection.'])
      : super(message);
}

class ApiException extends TrotxiException {
  final int statusCode;

  /// Stable backend reason, so callers need not branch on translated prose.
  final String? code;
  const ApiException(this.statusCode, String message, {this.code})
      : super(message);
}

/// Interface for app-level storage of JWT tokens
/// Which application is calling, and which build of it.
///
/// The replacement contract validates this before it authorizes anything, so a
/// request without it is refused whoever sent it. It is transport, not an
/// argument every call site should have to remember.
class ClientMetadata {
  const ClientMetadata({required this.app, required this.build, this.platform})
      : assert(build > 0, 'A build number is a positive integer'),
        assert(
          app == 'ops' || app == 'worker' || platform != null,
          'commuter and driver builds ship on a platform and must say which',
        );

  /// `commuter`, `driver`, `ops` or `worker`.
  final String app;

  /// The build number of this release, which the server compares to its floor.
  final int build;

  /// `ios` or `android`. Absent for `ops` and `worker`, which have no store build.
  final String? platform;

  /// Runs in release builds too; constructor assertions are not a wire guard.
  void validate() {
    if (!const ['commuter', 'driver', 'ops', 'worker'].contains(app) ||
        build < 1 ||
        build > 999999999 ||
        ((app == 'ops' || app == 'worker')
            ? platform != null
            : !const ['ios', 'android'].contains(platform))) {
      throw ArgumentError('Invalid replacement client metadata');
    }
  }
}

/// Puts the metadata on every request. The server reads it before it reads the
/// token, so this has to run whether or not the caller is signed in.
class MetadataInterceptor extends Interceptor {
  MetadataInterceptor(this._metadata) {
    _metadata.validate();
  }
  final ClientMetadata _metadata;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // A request cannot accidentally retain headers from another app/platform.
    // Rebuild rather than remove/reinsert entries in Dio's custom equality
    // map: that sequence throws in the current Linux/Dart CI runtime.
    // Generated calls already supply these headers, so this is a real path.
    const owned = {'x-trotxi-client', 'x-trotxi-build', 'x-trotxi-platform'};
    options.headers = <String, dynamic>{
      for (final entry in options.headers.entries)
        if (!owned.contains(entry.key.toLowerCase())) entry.key: entry.value,
      'x-trotxi-client': _metadata.app,
      'x-trotxi-build': '${_metadata.build}',
      if (_metadata.platform != null) 'x-trotxi-platform': _metadata.platform,
    };
    handler.next(options);
  }
}

abstract class TokenStore {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearTokens();
}

/// Replacement app stores implement compare-and-write inside their storage
/// queue. A separate read then write can otherwise clobber a newer login that
/// arrives while the secure-storage read is completing.
abstract class ConditionalTokenStore implements TokenStore {
  Future<bool> saveTokensIfRefreshMatches({
    required String expectedRefreshToken,
    required String accessToken,
    required String refreshToken,
  });
  Future<bool> clearTokensIfRefreshMatches(String expectedRefreshToken);
}

/// 1. AuthInterceptor: Handles Bearer injection & Automatic 401 Token Refresh
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStore _tokenStore;
  final ClientMetadata _metadata;
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
    required ClientMetadata metadata,
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
    // A retry re-enters this interceptor. Never refresh twice for one request,
    // or queue onError while awaiting a retry that needs that same queue.
    if (err.response?.statusCode != 401 ||
        err.requestOptions.extra[_retried] == true) {
      return handler.next(err);
    }

    // Guard: Prevent infinite loops if the refresh call itself returns 401
    final requestPath = err.requestOptions.path;
    if (Uri.parse(requestPath).path == '/v1/auth/refresh') {
      Object? payload = err.requestOptions.data;
      if (payload is String) {
        try {
          payload = jsonDecode(payload);
        } on FormatException {
          payload = null;
        }
      }
      if (payload is Map && payload['refreshToken'] is String) {
        await _clearIfCurrent(payload['refreshToken'] as String);
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
        newAccessToken = await (_refreshFuture ??= _refreshTokens(
          currentToken,
        ));
      }
    } on DioException catch (refreshError) {
      // Surface the refresh timeout/5xx, not the original access-token 401.
      return handler.next(refreshError);
    } catch (error, stackTrace) {
      // Missing/malformed tokens or storage failures aren't proof of revocation.
      return handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: const ApiException(
            0,
            'Unable to restore the session. Please retry.',
          ),
          stackTrace: stackTrace,
        ),
      );
    }

    final retry = err.requestOptions.copyWith(
      headers: {
        ...err.requestOptions.headers,
        'Authorization': 'Bearer $newAccessToken',
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
    return const {
      '/v1/auth/driver',
      '/v1/auth/google',
      '/v1/auth/apple',
    }.contains(Uri.parse(path).path);
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

      final refreshRequest = RefreshInput(
        (b) => b..refreshToken = refreshToken,
      );

      // This client carries no interceptors, so the metadata the server checks
      // before it authorizes anything has to be passed explicitly here.
      late final Response<TokensResponse> response;
      try {
        response = await refreshClient.getPublicApi().refreshSession(
              refreshInput: refreshRequest,
              xTrotxiClient: _metadata.app,
              xTrotxiBuild: _metadata.build,
              xTrotxiPlatform: _metadata.platform,
            );
      } on DioException catch (error) {
        // One clear per shared refresh, only on authoritative rejection. Do not
        // clear a newer login that replaced this credential while we waited.
        if (error.response?.statusCode == 401) {
          await _clearIfCurrent(refreshToken);
        }
        rethrow;
      }

      final tokens = response.data?.data;
      final newAccessToken = tokens?.accessToken;
      final newRefreshToken = tokens?.refreshToken;

      if (newAccessToken == null ||
          newAccessToken.isEmpty ||
          newRefreshToken == null ||
          newRefreshToken.isEmpty) {
        throw StateError('Refresh response missing tokens');
      }

      final store = _tokenStore;
      if (store is ConditionalTokenStore) {
        final saved = await store.saveTokensIfRefreshMatches(
          expectedRefreshToken: refreshToken,
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        if (!saved) throw StateError('Session changed while refreshing');
      } else {
        if (await store.getRefreshToken() != refreshToken) {
          throw StateError('Session changed while refreshing');
        }
        await store.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
      }
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

  Future<void> _clearIfCurrent(String refreshToken) async {
    final store = _tokenStore;
    if (store is ConditionalTokenStore) {
      await store.clearTokensIfRefreshMatches(refreshToken);
    } else if (await store.getRefreshToken() == refreshToken) {
      await store.clearTokens();
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
                ? InvalidCredentialsException(
                    _messageOf(response) ??
                        (Uri.parse(err.requestOptions.path).path ==
                                '/v1/auth/driver'
                            ? 'Invalid driver code or PIN.'
                            : 'Unable to sign in. Please try again.'),
                  )
                : const UnauthorizedException(),
          ),
        );
      case 403:
        if (Uri.parse(err.requestOptions.path).path == '/v1/auth/driver') {
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
            error: const UpgradeRequiredException(),
            response: response,
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
          _messageOf(response) ?? response.statusMessage ?? 'Unknown error',
          code: _fieldOf(response, 'code'),
        ),
        response: response,
      ),
    );
  }

  /// Every refusal carries `{ error: { code, message, requestId } }`, and the
  /// message is written to be shown. Falling back to the status line loses
  /// that, so read the envelope first.
  static String? _messageOf(Response response) {
    return _fieldOf(response, 'message');
  }

  static String? _fieldOf(Response response, String field) {
    Object? body = response.data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } on FormatException {
        return null;
      }
    }
    if (body is! Map) return null;
    final error = body['error'];
    if (error is! Map) return null;
    final message = error[field];
    return message is String && message.isNotEmpty ? message : null;
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
    required ClientMetadata metadata,
  }) {
    metadata.validate();
    final client = TrotxiApiClient(basePathOverride: baseUrl);

    // Metadata first: the server validates it before it authorizes anything,
    // so a request that reaches auth without it has already been refused.
    client.dio.interceptors.add(MetadataInterceptor(metadata));

    // CRITICAL: AuthInterceptor MUST come BEFORE ErrorInterceptor.
    // Otherwise ErrorInterceptor transforms 401s to UnauthorizedException
    // before AuthInterceptor can trigger the refresh flow.
    client.dio.interceptors.add(
      AuthInterceptor(
        dio: client.dio,
        tokenStore: tokenStore,
        metadata: metadata,
      ),
    );
    client.dio.interceptors.add(ErrorInterceptor());

    return client;
  }
}
