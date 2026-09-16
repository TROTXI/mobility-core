import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:trotxi_client_next/trotxi_client_next.dart';

class _Store implements TokenStore {
  String? access = 'old-access';
  String? refresh = 'old-refresh';
  int clears = 0;
  int saves = 0;
  int reads = 0;
  final fourReads = Completer<void>();

  @override
  Future<String?> getAccessToken() async {
    if (++reads == 4) fourReads.complete();
    return access;
  }

  @override
  Future<String?> getRefreshToken() async => refresh;

  @override
  Future<void> clearTokens() async {
    clears++;
    access = refresh = null;
  }

  @override
  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
    saves++;
    access = accessToken;
    refresh = refreshToken;
  }
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions) respond;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      respond(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, [Object body = const {}]) =>
    ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: ['application/json']
    });

ResponseBody _rotated() => _json(200, {
      'data': {
        'accessToken': 'new-access',
        'refreshToken': 'new-refresh',
        'accessExpiresAt': '2026-01-01T00:15:00Z',
        'refreshExpiresAt': '2026-02-01T00:00:00Z',
        'account': {
          'id': '00000000-0000-4000-8000-000000000000',
          'role': 'commuter',
          'displayName': 'Test rider',
          'phone': null,
          'avatarUrl': null,
          'createdAt': '2026-01-01T00:00:00Z',
        },
      },
    });

Future<DioException> _failure(Future<Response<dynamic>> request) async {
  try {
    await request.timeout(const Duration(seconds: 2));
    fail('Expected a request failure');
  } on DioException catch (error) {
    return error;
  }
}

void main() {
  late _Store store;
  late Dio dio;
  int refreshes = 0;
  int requests = 0;

  void serve(FutureOr<ResponseBody> Function(RequestOptions) respond) {
    dio.httpClientAdapter = _Adapter((options) {
      if (options.path == '/v1/auth/refresh') {
        refreshes++;
      } else {
        requests++;
      }
      return respond(options);
    });
  }

  setUp(() {
    store = _Store();
    dio = TrotxiClientFactory.create(
      baseUrl: 'https://unit.test',
      tokenStore: store,
      metadata: const ClientMetadata(
        app: 'commuter',
        build: 9,
        platform: 'ios',
      ),
    ).dio;
    refreshes = requests = 0;
  });

  tearDown(() => dio.close(force: true));

  test(
      'refreshes and retries with rotated tokens through the real interceptor chain',
      () async {
    serve((o) => o.path == '/v1/auth/refresh'
        ? _rotated()
        : _json(o.headers['Authorization'] == 'Bearer new-access' ? 200 : 401));
    expect((await dio.get('/me')).statusCode, 200);
    expect(refreshes, 1);
    expect(requests, 2);
    expect(store.access, 'new-access');
    expect(store.saves, 1);
    expect(store.clears, 0);
  });

  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout
  ]) {
    test('refresh $type preserves the session and surfaces offline, not 401',
        () async {
      serve((o) {
        if (o.path == '/v1/auth/refresh')
          throw DioException(requestOptions: o, type: type);
        return _json(401);
      });
      expect((await _failure(dio.get('/me'))).error, isA<OfflineException>());
      expect(store.access, 'old-access');
      expect(store.refresh, 'old-refresh');
      expect(store.clears, 0);
      expect(requests, 1);
    });
  }

  for (final status in [403, 500, 503]) {
    test('refresh HTTP $status preserves tokens and the server error',
        () async {
      serve((o) => _json(o.path == '/v1/auth/refresh' ? status : 401));
      expect((await _failure(dio.get('/me'))).error,
          isA<ApiException>().having((e) => e.statusCode, 'status', status));
      expect(store.clears, 0);
      expect(store.access, 'old-access');
    });
  }

  test('refresh rejection clears tokens once and reports unauthorized',
      () async {
    serve((o) => _json(401));
    expect(
        (await _failure(dio.get('/me'))).error, isA<UnauthorizedException>());
    expect(refreshes, 1);
    expect(requests, 1);
    expect(store.clears, 1);
    expect(store.access, isNull);
  });

  for (final failure in ['connection', 'timeout', '500', '401']) {
    test(
        'successful refresh followed by retry $failure keeps new tokens and terminates',
        () async {
      serve((o) {
        if (o.path == '/v1/auth/refresh') return _rotated();
        if (o.headers['Authorization'] == 'Bearer old-access')
          return _json(401);
        if (failure == 'connection' || failure == 'timeout') {
          throw DioException(
              requestOptions: o,
              type: failure == 'connection'
                  ? DioExceptionType.connectionError
                  : DioExceptionType.receiveTimeout);
        }
        return _json(int.parse(failure));
      });
      final error = await _failure(dio.get('/me'));
      expect(
          error.error,
          failure == '500'
              ? isA<ApiException>().having((e) => e.statusCode, 'status', 500)
              : failure == '401'
                  ? isA<UnauthorizedException>()
                  : isA<OfflineException>());
      expect(refreshes, 1);
      expect(requests, 2);
      expect(store.saves, 1);
      expect(store.clears, 0);
      expect(store.access, 'new-access');
      expect(store.refresh, 'new-refresh');
    });
  }

  for (final result in ['success', '401', '503', 'timeout']) {
    test('concurrent 401s share one refresh ($result)', () async {
      final bothRequests = Completer<void>();
      final releaseRefresh = Completer<void>();
      var initial = 0;
      serve((o) async {
        if (o.path == '/v1/auth/refresh') {
          await releaseRefresh.future;
          if (result == 'timeout')
            throw DioException(
                requestOptions: o, type: DioExceptionType.receiveTimeout);
          return result == 'success' ? _rotated() : _json(int.parse(result));
        }
        if (o.headers['Authorization'] == 'Bearer new-access')
          return _json(200);
        if (++initial == 2) bothRequests.complete();
        await bothRequests.future;
        return _json(401);
      });
      final pending = result == 'success'
          ? Future.wait([dio.get('/one'), dio.get('/two')])
          : Future.wait([_failure(dio.get('/one')), _failure(dio.get('/two'))]);
      await store.fourReads.future.timeout(const Duration(seconds: 2));
      // Both handlers have read storage and can join the still-pending refresh.
      await Future<void>.delayed(Duration.zero);
      releaseRefresh.complete();
      await pending.timeout(const Duration(seconds: 2));
      expect(refreshes, 1);
      expect(store.clears, result == '401' ? 1 : 0);
      expect(store.saves, result == 'success' ? 1 : 0);
    });
  }

  test('a delayed old-token 401 reuses an already rotated token', () async {
    final bothSent = Completer<void>();
    final releaseLate = Completer<void>();
    var initial = 0;
    serve((o) async {
      if (o.path == '/v1/auth/refresh') return _rotated();
      if (o.headers['Authorization'] == 'Bearer new-access') return _json(200);
      if (++initial == 2) bothSent.complete();
      await bothSent.future;
      if (o.path == '/late') await releaseLate.future;
      return _json(401);
    });
    final fast = dio.get('/fast');
    final late = dio.get('/late');
    await fast.timeout(const Duration(seconds: 2));
    releaseLate.complete();
    await late.timeout(const Duration(seconds: 2));
    expect(refreshes, 1);
    expect(store.clears, 0);
  });

  test('a subsequent request can refresh after a transient refresh failure',
      () async {
    serve((o) {
      if (o.path == '/v1/auth/refresh')
        return refreshes == 1 ? _json(503) : _rotated();
      return _json(
          o.headers['Authorization'] == 'Bearer new-access' ? 200 : 401);
    });
    await _failure(dio.get('/me'));
    expect((await dio.get('/me')).statusCode, 200);
    expect(refreshes, 2);
    expect(store.clears, 0);
  });

  for (final path in ['/v1/auth/driver', '/v1/auth/google', '/v1/auth/apple']) {
    test('sign-in rejection at $path never refreshes or clears tokens',
        () async {
      serve((o) => _json(401));
      expect((await _failure(dio.post(path))).error,
          isA<InvalidCredentialsException>());
      expect(refreshes, 0);
      expect(store.clears, 0);
    });
  }

  test('a path merely containing refresh is not a refresh-token rejection',
      () async {
    serve((o) => o.path == '/v1/auth/refresh'
        ? _rotated()
        : _json(o.headers['Authorization'] == 'Bearer new-access' ? 200 : 401));
    expect((await dio.get('/refresh-view')).statusCode, 200);
    expect(refreshes, 1);
    expect(store.clears, 0);
  });

  test('malformed successful refresh preserves the existing session', () async {
    serve((o) => _json(o.path == '/v1/auth/refresh' ? 200 : 401));
    expect((await _failure(dio.get('/me'))).error, isA<ApiException>());
    expect(store.clears, 0);
    expect(store.saves, 0);
  });

  test('a delayed 401 cannot replay an old operation under a different login',
      () async {
    serve((o) {
      store.access = 'another-login';
      store.refresh = 'another-refresh';
      return _json(401);
    });
    expect((await _failure(dio.get('/me'))).error, isA<ApiException>());
    expect(requests, 1);
    expect(refreshes, 0);
    expect(store.access, 'another-login');
    expect(store.clears, 0);
  });

  test(
      'missing refresh credentials terminate without claiming server rejection',
      () async {
    store.refresh = null;
    serve((o) => _json(401));
    expect((await _failure(dio.get('/me'))).error, isA<ApiException>());
    expect(refreshes, 0);
    expect(store.clears, 0);
  });

  test('refresh cancellation preserves tokens and remains cancellation',
      () async {
    serve((o) {
      if (o.path == '/v1/auth/refresh') {
        throw DioException(requestOptions: o, type: DioExceptionType.cancel);
      }
      return _json(401);
    });
    expect((await _failure(dio.get('/me'))).type, DioExceptionType.cancel);
    expect(store.clears, 0);
  });

  test('direct refresh rejection does not recurse', () async {
    serve((o) => _json(401));
    expect(
        (await _failure(dio
                .post('/v1/auth/refresh', data: {'refreshToken': 'old-refresh'})))
            .error,
        isA<UnauthorizedException>());
    expect(refreshes, 1);
    expect(store.clears, 1);
  });

  test(
      'direct refresh rejection for another token leaves the current session alone',
      () async {
    serve((o) => _json(401));
    await _failure(
        dio.post('/v1/auth/refresh', data: {'refreshToken': 'a-replaced-token'}));
    expect(refreshes, 1);
    expect(store.clears, 0);
    expect(store.access, 'old-access');
  });

  for (final status in [200, 401]) {
    test('in-flight refresh $status cannot overwrite or clear a newer login',
        () async {
      serve((o) {
        if (o.path != '/v1/auth/refresh') return _json(401);
        store.access = 'another-login';
        store.refresh = 'another-refresh';
        return status == 200 ? _rotated() : _json(401);
      });
      await _failure(dio.get('/me'));
      expect(store.access, 'another-login');
      expect(store.refresh, 'another-refresh');
      expect(store.clears, 0);
      expect(store.saves, 0);
    });
  }
}
