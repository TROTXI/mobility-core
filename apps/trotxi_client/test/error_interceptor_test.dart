import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:trotxi_client/trotxi_client.dart';

void main() {
  late ErrorInterceptor interceptor;

  setUp(() {
    interceptor = ErrorInterceptor();
  });

  Object? runOnError(DioException err) {
    final result = <DioException>[];
    final passthrough = <DioException>[];
    interceptor.onError(
        err,
        _TestErrorInterceptorHandler(
          onReject: (e) => result.add(e),
          onNext: (e) => passthrough.add(e),
        ));
    if (result.isNotEmpty) return result.first.error;
    if (passthrough.isNotEmpty) return 'passthrough';
    return null;
  }

  test('a driver 403 is a suspension only when the server says so', () {
    Object? signIn(Map<String, dynamic> error) {
      final request = RequestOptions(path: '/v1/auth/driver');
      return runOnError(DioException(
          requestOptions: request,
          response: Response(
              requestOptions: request,
              statusCode: 403,
              data: {'error': error})));
    }

    expect(
        signIn({'code': 'driver_suspended', 'message': 'Suspended.'}),
        isA<AccountSuspendedException>());
    final expired = signIn({
      'code': 'temporary_pin_expired',
      'message': 'Your temporary PIN has expired. Ask Trotxi operations for a new one.'
    });
    expect(expired, isA<ApiException>());
    expect((expired as ApiException).code, 'temporary_pin_expired');
    expect(expired, isNot(isA<AccountSuspendedException>()));
  });

  test('a wrong current PIN on a PIN change is not an expired session', () {
    Object? change(String code) {
      final request = RequestOptions(path: '/v1/auth/driver/pin');
      return runOnError(DioException(
          requestOptions: request,
          response: Response(
              requestOptions: request,
              statusCode: 401,
              data: {
                'error': {'code': code, 'message': 'Current PIN is incorrect.'}
              })));
    }

    expect(change('invalid_driver_credentials'),
        isA<InvalidCredentialsException>());
    expect(change('unauthenticated'), isA<UnauthorizedException>());
  });

  test('cooldown is shared across paths, expires and resets on a new session',
      () {
    var epoch = 0;
    var now = DateTime.utc(2026, 9, 26);
    interceptor =
        ErrorInterceptor(sessionGeneration: () => epoch, now: () => now);
    final original = RequestOptions(path: '/v1/me');
    interceptor.onRequest(original, _RequestHandler());
    runOnError(DioException(
        requestOptions: original,
        response: Response(
            requestOptions: original,
            statusCode: 429,
            headers: Headers.fromMap({
              'retry-after': ['60']
            }))));
    final blocked = _RequestHandler();
    interceptor.onRequest(RequestOptions(path: '/v1/me/reservations'), blocked);
    expect(blocked.error?.error, isA<RateLimitException>());
    now = now.add(const Duration(seconds: 61));
    final resumed = _RequestHandler();
    interceptor.onRequest(original, resumed);
    expect(resumed.allowed, isTrue);
    runOnError(DioException(
        requestOptions: original,
        response: Response(
            requestOptions: original,
            statusCode: 429,
            headers: Headers.fromMap({
              'retry-after': ['60']
            }))));
    epoch++;
    final newSession = _RequestHandler();
    interceptor.onRequest(RequestOptions(path: '/v1/me'), newSession);
    expect(newSession.allowed, isTrue);
  });

  test('an old session refusal cannot impose a new session cooldown', () {
    var epoch = 0;
    interceptor = ErrorInterceptor(sessionGeneration: () => epoch);
    final old = RequestOptions(path: '/v1/me');
    interceptor.onRequest(old, _RequestHandler());
    epoch++;
    runOnError(DioException(
        requestOptions: old,
        response: Response(requestOptions: old, statusCode: 429)));
    final current = _RequestHandler();
    interceptor.onRequest(RequestOptions(path: '/v1/me'), current);
    expect(current.allowed, isTrue);
  });

  test('HTTP-date cooldown is honoured and negative delay is not accepted', () {
    final now = DateTime.utc(2026, 9, 26, 12);
    interceptor = ErrorInterceptor(now: () => now);
    final request = RequestOptions(path: '/v1/me');
    final error = runOnError(DioException(
        requestOptions: request,
        response: Response(
            requestOptions: request,
            statusCode: 429,
            headers: Headers.fromMap({
              'retry-after': ['Sat, 26 Sep 2026 12:00:30 GMT']
            })))) as RateLimitException;
    expect(error.retryAfter, const Duration(seconds: 30));
    final negative = runOnError(DioException(
        requestOptions: request,
        response: Response(
            requestOptions: request,
            statusCode: 429,
            headers: Headers.fromMap({
              'retry-after': ['-1']
            })))) as RateLimitException;
    expect(negative.retryAfter, const Duration(seconds: 5));
  });

  RequestOptions options() => RequestOptions(path: '/test');

  test('maps 401 to UnauthorizedException', () {
    final err = DioException(
      requestOptions: options(),
      response: Response(requestOptions: options(), statusCode: 401),
      type: DioExceptionType.badResponse,
    );

    final error = runOnError(err);
    expect(error, isA<UnauthorizedException>());
  });

  test(
    'keeps a structured business error code and message for app decisions',
    () {
      final request = RequestOptions(
        path: '/v1/me/reservations/seat/decisions',
      );
      final error = runOnError(
        DioException(
          requestOptions: request,
          response: Response(
            requestOptions: request,
            statusCode: 409,
            data: {
              'error': {
                'code': 'reservation_capacity',
                'message': 'This departure is full.',
              },
            },
          ),
        ),
      );
      expect(error, isA<ApiException>());
      expect((error as ApiException).code, 'reservation_capacity');
      expect(error.message, 'This departure is full.');
    },
  );

  test('Google rejection never tells a commuter to check a driver PIN', () {
    final request = RequestOptions(path: '/v1/auth/google');
    final error = runOnError(
      DioException(
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: 401,
          data: {
            'error': {
              'code': 'identity_rejected',
              'message': 'Google sign-in was refused.',
            },
          },
        ),
      ),
    );
    expect(error, isA<InvalidCredentialsException>());
    expect(
      (error as InvalidCredentialsException).message,
      'Google sign-in was refused.',
    );
  });

  test('social sign-in 403 is not assumed to be driver suspension', () {
    final request = RequestOptions(path: '/v1/auth/apple');
    final error = runOnError(
      DioException(
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: 403,
          data: {
            'error': {
              'code': 'identity_not_allowed',
              'message': 'This identity is not eligible.',
            },
          },
        ),
      ),
    );
    expect(error, isA<ApiException>());
    expect((error as ApiException).code, 'identity_not_allowed');
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
      (error as RateLimitException).retryAfter,
      const Duration(seconds: 12),
    );
  });

<<<<<<< HEAD
  test('carries the API error code and message onto ApiException', () {
    final err = DioException(
      requestOptions: options(),
      response: Response(
        requestOptions: options(),
        statusCode: 400,
        statusMessage: 'Bad Request',
        data: {
          'error': {
            'code': 'client_metadata_required',
            'message': 'Supply the appropriate client, build and platform '
                'metadata.',
            'requestId': '1d75a5ec',
          },
        },
      ),
      type: DioExceptionType.badResponse,
    );

    final error = runOnError(err);
    expect(error, isA<ApiException>());
    final api = error as ApiException;
    expect(api.statusCode, 400);
    expect(api.code, 'client_metadata_required');
    expect(api.message, startsWith('Supply the appropriate client'));
    expect(api.toString(), contains('client_metadata_required'));
  });

  test('parses the error body when it arrives as an undecoded String', () {
    final err = DioException(
      requestOptions: options(),
      response: Response(
        requestOptions: options(),
        statusCode: 404,
        data: '{"error":{"code":"not_found","message":"No such route."}}',
      ),
      type: DioExceptionType.badResponse,
    );

    final api = runOnError(err) as ApiException;
    expect(api.code, 'not_found');
    expect(api.message, 'No such route.');
  });

  test('falls back to the status message when the body is not our shape', () {
    final err = DioException(
      requestOptions: options(),
      response: Response(
        requestOptions: options(),
        statusCode: 502,
        statusMessage: 'Bad Gateway',
        data: '<html>proxy blew up</html>',
      ),
      type: DioExceptionType.badResponse,
    );

    final api = runOnError(err) as ApiException;
    expect(api.statusCode, 502);
    expect(api.code, isNull);
    expect(api.message, 'Bad Gateway');
  });

=======
>>>>>>> origin/main
  test('maps connectionError to OfflineException', () {
    final err = DioException(
      requestOptions: options(),
      type: DioExceptionType.connectionError,
    );

    final error = runOnError(err);
    expect(error, isA<OfflineException>());
  });

  test('maps receiveTimeout to ServerTimeoutException', () {
    final err = DioException(
      requestOptions: options(),
      type: DioExceptionType.receiveTimeout,
    );

    final error = runOnError(err);
    expect(error, isA<ServerTimeoutException>());
  });

  test('maps sendTimeout to ServerTimeoutException', () {
    final err = DioException(
      requestOptions: options(),
      type: DioExceptionType.sendTimeout,
    );

    final error = runOnError(err);
    expect(error, isA<ServerTimeoutException>());
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
    },
  );
}

class _RequestHandler extends RequestInterceptorHandler {
  bool allowed = false;
  DioException? error;
  @override
  void next(RequestOptions options) {
    allowed = true;
  }

  @override
  void reject(DioException err, [bool callFollowingErrorInterceptor = false]) {
    error = err;
  }
}

/// Minimal fake handler so we can inspect what ErrorInterceptor does
/// without depending on Dio's internal handler completion machinery.
class _TestErrorInterceptorHandler extends ErrorInterceptorHandler {
  _TestErrorInterceptorHandler({required this.onReject, required this.onNext});

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
