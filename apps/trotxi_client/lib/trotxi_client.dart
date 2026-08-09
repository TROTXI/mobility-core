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

/// Interface the app-side token storage must implement.
/// Keeps this package free of any dependency on flutter_secure_storage
/// or any specific storage implementation.
abstract class TokenStore {
  Future<String?> getRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearTokens();
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (response == null) {
      if (err.type == DioExceptionType.connectionError ||
          err.type == DioExceptionType.unknown) {
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
        return handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: const UnauthorizedException(),
        ));
      case 429:
        final retryAfter = _parseRetryAfter(response);
        return handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: RateLimitException(retryAfter),
        ));
      default:
        return handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: ApiException(
            response.statusCode ?? 0,
            response.statusMessage ?? 'Unknown error',
          ),
        ));
    }
  }

  Duration _parseRetryAfter(Response response) {
    final header = response.headers.value('retry-after');
    final seconds = int.tryParse(header ?? '') ?? 5;
    return Duration(seconds: seconds);
  }
}

/// Intercepts 401s, performs a single-flight token refresh, and retries
/// the original request. Must be added AFTER ErrorInterceptor so it runs
/// FIRST on the error path (Dio processes error interceptors in reverse
/// order of registration).
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._dio, this._plainDio, this._tokenStore);

  final Dio _dio;
  final Dio _plainDio;
  final TokenStore _tokenStore;

  Future<String>? _refreshing;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    try {
      final newAccessToken = await _refreshOnce();

      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccessToken';
      final response = await _dio.fetch(opts);
      return handler.resolve(response);
    } catch (e) {
      return handler.next(err);
    }
  }

  Future<String> _refreshOnce() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<String> _doRefresh() async {
    final rt = await _tokenStore.getRefreshToken();
    if (rt == null) throw const UnauthorizedException();
    final res =
        await _plainDio.post('/auth/refresh', data: {'refreshToken': rt});
    await _tokenStore.saveTokens(
      accessToken: res.data['accessToken'],
      refreshToken: res.data['refreshToken'],
    );
    return res.data['accessToken'];
  }
}

class TrotxiClientFactory {
  static TrotxiApiClient create({
    required String baseUrl,
    required TokenStore tokenStore,
  }) {
    final client = TrotxiApiClient(basePathOverride: baseUrl);
    final plainDio = Dio(BaseOptions(baseUrl: baseUrl));

    client.dio.interceptors.add(ErrorInterceptor());
    client.dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
    client.dio.interceptors.add(
      AuthInterceptor(client.dio, plainDio, tokenStore),
    );

    return client;
  }
}
