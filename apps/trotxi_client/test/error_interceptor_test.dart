import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:trotxi_client/trotxi_client.dart';

void main() {
  late ErrorInterceptor interceptor;

  setUp(() {
    interceptor = ErrorInterceptor();
  });

  RequestOptions options() => RequestOptions(path: '/test');

  /// Runs the interceptor and captures whichever error it rejects with,
  /// or 'passthrough' if it calls handler.next() instead.
  Object? runOnError(DioException err) {
    final result = <DioException>[];
    final passthrough = <DioException>[];

    final testHandler = _TestErrorInterceptorHandler(
      onReject: (e) => result.add(e),
      onNext: (e) => passthrough.add(e),
    );

    interceptor.onError(err, testHandler);

    if (result.isNotEmpty) return result.first.error;
    if (passthrough.isNotEmpty) return 'passthrough';
    return null;
  }

  test('maps 401 to UnauthorizedException', () {
    final err = DioException(
      requestOptions: options(),
      response: Response(
        requestOptions: options(),
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );

    final error = runOnError(err);
    expect(error, isA<UnauthorizedException>());
  });

  test('maps 429 to RateLimitException with Retry-After parsed', () {
    final err = DioException(
      requestOptions: options(),
      response: Response(
        requestOptions: options(),
        statusCode: 429,
        headers: Headers.fromMap({
          'retry-after': ['12'],
        }),
      ),
      type: DioExceptionType.badResponse,
    );

    final error = runOnError(err);
    expect(error, isA<RateLimitException>());
    expect(
        (error as RateLimitException).retryAfter, const Duration(seconds: 12));
  });

 


  test('maps connectionError to OfflineException', () {
    final err = DioException(
      requestOptions: options(),
      type: DioExceptionType.connectionError,
    );

    final error = runOnError(err);
    expect(error, isA<OfflineException>());
  });

  test('maps unknown type with no response to OfflineException', () {
    final err = DioException(
      requestOptions: options(),
      type: DioExceptionType.unknown,
    );

    final error = runOnError(err);
    expect(error, isA<OfflineException>());
  });

  test('maps other status codes (e.g. 500) to ApiException', () {
    final err = DioException(
      requestOptions: options(),
      response: Response(
        requestOptions: options(),
        statusCode: 500,
        statusMessage: 'Internal Server Error',
      ),
      type: DioExceptionType.badResponse,
    );

    final error = runOnError(err);
    expect(error, isA<ApiException>());
    expect((error as ApiException).statusCode, 500);
  });

  test(
      'passes through when response is null and type is not connection-related',
      () {
    final err = DioException(
      requestOptions: options(),
      type: DioExceptionType.cancel,
    );

    final error = runOnError(err);
    expect(error, 'passthrough');
  });
}

/// Minimal fake handler so we can inspect what ErrorInterceptor does
/// without depending on Dio's internal handler completion machinery.
class _TestErrorInterceptorHandler extends ErrorInterceptorHandler {
  _TestErrorInterceptorHandler({
    required this.onReject,
    required this.onNext,
  });

  final void Function(DioException) onReject;
  final void Function(DioException) onNext;

  @override
  void reject(DioException err, [bool callFollowingErrorInterceptor = false]) {
    onReject(err);
  }

  @override
  void next(DioException err) {
    onNext(err);
  }
}
