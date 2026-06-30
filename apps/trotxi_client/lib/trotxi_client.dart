import 'package:dio/dio.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';
export 'package:trotxi_api_client/trotxi_api_client.dart';

// ── Exceptions ────────────────────────────────────────────────────────────────
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

// ── Error Interceptor ─────────────────────────────────────────────────────────

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const OfflineException(),
        ),
      );
    }

    if (response == null) return handler.next(err);

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

// ── Client Factory ────────────────────────────────────────────────────────────

class TrotxiClientFactory {
  static TrotxiApiClient create({required String baseUrl}) {
    final client = TrotxiApiClient(basePathOverride: baseUrl);
    client.dio.interceptors.add(ErrorInterceptor());
    return client;
  }
}
