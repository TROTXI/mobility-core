import 'package:dio/dio.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';
export 'package:trotxi_api_client/trotxi_api_client.dart';

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
class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final TokenStore _tokenStore;

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
    // Only attempt refresh on genuine HTTP 401 status codes
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Guard: Prevent infinite loops if the refresh call itself returns 401
    final requestPath = err.requestOptions.path;
    if (requestPath.contains('auth/refresh') ||
        requestPath.contains('refresh')) {
      await _tokenStore.clearTokens();
      return handler.next(err);
    }

    try {
      final refreshToken = await _tokenStore.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _tokenStore.clearTokens();
        return handler.next(err);
      }

      // Instantiate a isolated client for the refresh call
      final refreshClient = TrotxiApiClient(
        basePathOverride: _dio.options.baseUrl,
      );

      // Construct the generated built_value request model
      final refreshRequest = AuthRefreshPostRequest(
        (b) => b..refreshToken = refreshToken,
      );

      // Call the generated AuthApi endpoint
      final response = await refreshClient
          .getAuthApi()
          .authRefreshPost(authRefreshPostRequest: refreshRequest);

      final newAccessToken = response.data?.accessToken;
      final newRefreshToken = response.data?.refreshToken;

      if (newAccessToken == null || newRefreshToken == null) {
        await _tokenStore.clearTokens();
        return handler.next(err);
      }

      // Store new credentials
      await _tokenStore.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

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
}

/// 2. ErrorInterceptor: Maps raw DioExceptions to typed Domain Exceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (response == null) {
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

    switch (response.statusCode) {
      case 401:
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const UnauthorizedException(),
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
