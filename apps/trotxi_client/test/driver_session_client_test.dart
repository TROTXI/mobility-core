import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:trotxi_client/driver_session_client.dart';
import 'package:trotxi_client/scoped_token_store.dart';
import 'package:trotxi_client/trotxi_client.dart';

import 'scoped_token_store_test.dart' show MemorySessionStorage, scope;

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
          Future<void>? cancelFuture) async =>
      respond(options);
  @override
  void close({bool force = false}) {}
}

class _RaceStore extends ScopedTokenStore {
  _RaceStore() : super(scope: scope(), storage: MemorySessionStorage());
  bool replaceBeforeRotation = false;
  bool replaceBeforeClear = false;
  int conditionalWrites = 0;
  int conditionalClears = 0;

  @override
  Future<bool> saveTokensIfRefreshMatches({
    required String expectedRefreshToken,
    required String accessToken,
    required String refreshToken,
  }) async {
    conditionalWrites++;
    if (replaceBeforeRotation) {
      replaceBeforeRotation = false;
      await saveTokens(accessToken: 'other-a', refreshToken: 'other-r');
    }
    return super.saveTokensIfRefreshMatches(
        expectedRefreshToken: expectedRefreshToken,
        accessToken: accessToken,
        refreshToken: refreshToken);
  }

  @override
  Future<bool> clearTokensIfRefreshMatches(String expectedRefreshToken) async {
    conditionalClears++;
    if (replaceBeforeClear) {
      replaceBeforeClear = false;
      await saveTokens(accessToken: 'other-a', refreshToken: 'other-r');
    }
    return super.clearTokensIfRefreshMatches(expectedRefreshToken);
  }
}

ResponseBody json(int status, [Object body = const {}]) =>
    ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: ['application/json']
    });

Map<String, Object?> account(
        {String id = 'account-1', String role = 'driver'}) =>
    {
      'id': id,
      'role': role,
      'displayName': 'Test driver',
      'phone': null,
      'avatarUrl': null,
      'createdAt': '2026-01-01T00:00:00Z',
    };
Map<String, Object?> tokens({String suffix = '1', String role = 'driver'}) => {
      'accessToken': 'access-$suffix',
      'refreshToken': 'refresh-$suffix',
      'accessExpiresAt': '2026-01-01T01:00:00Z',
      'refreshExpiresAt': '2026-02-01T00:00:00Z',
      'account': account(id: 'account-$suffix', role: role),
      'driver': {'id': 'fleet-$suffix', 'name': 'Test driver'},
      'mustChangePin': false,
    };
Map<String, Object?> driverSelf({Object? credential = const {
  'driverCode': 'DR-7Q4M',
  'status': 'active',
  'mustChangePin': true,
}}) =>
    {
      'id': 'fleet-1',
      'name': 'Kwame Mensah',
      'phone': null,
      'licenseNumber': null,
      'credential': credential,
    };
Map<String, dynamic> bodyOf(RequestOptions options) =>
    (options.data is String ? jsonDecode(options.data as String) : options.data)
        as Map<String, dynamic>;

void main() {
  const metadata =
      ClientMetadata(app: 'driver', build: 27, platform: 'android');
  late ScopedTokenStore store;
  late TrotxiApiClient client;
  late DriverSessionClient sessions;
  late List<RequestOptions> requests;
  late FutureOr<ResponseBody> Function(RequestOptions) respond;

  Future<DriverIdentity> signIn({String code = 'dr-test'}) =>
      sessions.signIn(code: code, pin: '938751', ownDevice: false);

  setUp(() {
    store = _RaceStore();
    client = TrotxiClientFactory.create(
        baseUrl: store.scope.baseUrl, tokenStore: store, metadata: metadata);
    requests = [];
    respond = (_) => json(200, {'data': tokens()});
    client.dio.httpClientAdapter = _Adapter((options) {
      requests.add(options);
      return respond(options);
    });
    sessions =
        DriverSessionClient(client: client, store: store, metadata: metadata);
  });

  test(
      'generated driver sign-in sends the new shape and persists before returning',
      () async {
    // Preserve the cause when a platform's transport/JSON decoder rejects a
    // synthetic response. ErrorInterceptor intentionally exposes only a safe
    // app error, which otherwise hides why this fixture failed in CI.
    Object? transportCause;
    StackTrace? transportStack;
    client.dio.interceptors.insert(
        client.dio.interceptors.indexWhere((i) => i is ErrorInterceptor),
        InterceptorsWrapper(onError: (error, handler) {
      transportCause = error.error;
      transportStack = error.error is Error
          ? (error.error as Error).stackTrace
          : error.stackTrace;
      handler.next(error);
    }));
    final DriverIdentity driver;
    try {
      driver = await signIn();
    } catch (error) {
      fail(
          'Synthetic sign-in failed: $error; transport cause: $transportCause\n$transportStack');
    }
    expect(requests.single.path, '/v1/auth/driver');
    expect(bodyOf(requests.single),
        {'code': 'dr-test', 'pin': '938751', 'ownDevice': false});
    final headers = requests.single.headers
        .map((k, v) => MapEntry(k.toLowerCase(), v.toString()));
    expect(headers['x-trotxi-client'], 'driver');
    expect(headers['x-trotxi-platform'], 'android');
    expect(headers['x-trotxi-build'], '27');
    expect(driver.accountId, 'account-1');
    expect(driver.fleetDriverId, 'fleet-1');
    expect(driver.code, 'DR-TEST');
    expect(await store.getAccessToken(), 'access-1');
    expect(await store.getRefreshToken(), 'refresh-1');
  });

  test('own-device choice is sent, never guessed or defaulted to long lived',
      () async {
    await sessions.signIn(code: 'DR-TEST', pin: '938751', ownDevice: true);
    expect(bodyOf(requests.single)['ownDevice'], isTrue);
  });

  test('session client refuses a different app or endpoint', () {
    final wrongStore =
        ScopedTokenStore(scope: scope(url: 'https://other.test'));
    expect(
        () => DriverSessionClient(
            client: client, store: wrongStore, metadata: metadata),
        throwsArgumentError);
    expect(
        () => DriverSessionClient(
            client: client,
            store: store,
            metadata: const ClientMetadata(
                app: 'commuter', build: 1, platform: 'ios')),
        throwsArgumentError);
  });

  test('wrong-role response and old flat envelope cannot create a session',
      () async {
    respond = (_) => json(200, {'data': tokens(role: 'commuter')});
    await expectLater(signIn(), throwsA(isA<ApiException>()));
    expect(await store.getAccessToken(), isNull);
    respond = (_) => json(200, tokens());
    await expectLater(signIn(), throwsA(isA<DioException>()));
    expect(await store.getAccessToken(), isNull);
  });

  for (final entry in <int, Matcher>{
    401: isA<InvalidCredentialsException>(),
    403: isA<AccountSuspendedException>(),
    423: isA<CredentialLockedException>(),
    426: isA<UpgradeRequiredException>(),
    503: isA<ApiException>(),
  }.entries) {
    final status = entry.key;
    final matcher = entry.value;
    test(
        'sign-in $status preserves stored credentials and exposes its real failure',
        () async {
      await store.saveTokens(
          accessToken: 'existing-a', refreshToken: 'existing-r');
      respond = (_) => json(status, {
            'error': {
              'code': 'rejected',
              'message': 'Refused',
              'requestId': 'r'
            }
          });
      await expectLater(signIn(), throwsA(matcher));
      expect(await store.getAccessToken(), 'existing-a');
      expect(requests, hasLength(1)); // No auth refresh of a failed sign-in.
    });
  }

  test('restore reads the fleet record, so the driver code survives a restart',
      () async {
    await signIn();
    respond = (o) => json(
        200,
        {'data': o.path == '/v1/driver/me' ? driverSelf() : account()});
    final restored = await sessions.restore();
    expect(requests.map((r) => r.path),
        contains('/v1/driver/me'), reason: 'the account read has no fleet');
    expect(restored?.accountId, 'account-1');
    expect(restored?.fleetDriverId, 'fleet-1');
    expect(restored?.code, 'DR-7Q4M');
    expect(restored?.mustChangePin, isTrue);
    expect(restored?.name, 'Kwame Mensah');
  });

  test('a fleet read that fails keeps the session on account identity',
      () async {
    await signIn();
    respond = (o) => o.path == '/v1/driver/me'
        ? json(503, {
            'error': {
              'code': 'unavailable',
              'message': 'Down',
              'requestId': 'r'
            }
          })
        : json(200, {'data': account()});
    final restored = await sessions.restore();
    expect(restored, isNotNull,
        reason: 'a fleet outage must not sign a driver out mid-shift');
    expect(restored?.accountId, 'account-1');
    expect(restored?.name, 'Test driver');
    expect(restored?.code, isNull);
  });

  test('a driver with no credential never borrows the account UUID as a code',
      () async {
    await signIn();
    respond = (o) => json(
        200,
        {
          'data': o.path == '/v1/driver/me'
              ? driverSelf(credential: null)
              : account()
        });
    final restored = await sessions.restore();
    expect(restored?.fleetDriverId, 'fleet-1');
    expect(restored?.code, isNull);
    expect(restored?.mustChangePin, isNull);
  });

  test('empty scope restores without network', () async {
    expect(await sessions.restore(), isNull);
    expect(requests, isEmpty);
  });

  test('offline restore is not silently interpreted as signed out', () async {
    await signIn();
    respond = (o) => throw DioException(
        requestOptions: o, type: DioExceptionType.receiveTimeout);
    await expectLater(sessions.restore(), throwsA(isA<OfflineException>()));
    expect(await store.getAccessToken(), 'access-1');
  });

  test(
      'rejected refresh during restore clears this session and returns signed out',
      () async {
    await signIn();
    respond = (_) => json(401, {
          'error': {
            'code': 'unauthorized',
            'message': 'Expired',
            'requestId': 'r'
          }
        });
    expect(await sessions.restore(), isNull);
    expect(requests.map((r) => r.path),
        ['/v1/auth/driver', '/v1/me', '/v1/auth/refresh']);
    expect(await store.getRefreshToken(), isNull);
  });

  test('late sign-in cannot restore a session after explicit sign-out',
      () async {
    final response = Completer<ResponseBody>();
    final entered = Completer<void>();
    respond = (_) {
      entered.complete();
      return response.future;
    };
    final pending = signIn();
    final failure = expectLater(pending, throwsA(isA<ApiException>()));
    await entered.future;
    expect(await sessions.signOut(), isTrue);
    response.complete(json(200, {'data': tokens()}));
    await failure;
    expect(await store.getAccessToken(), isNull);
  });

  test('late first sign-in cannot overwrite the newer successful attempt',
      () async {
    final firstResponse = Completer<ResponseBody>();
    final entered = Completer<void>();
    respond = (o) {
      if (bodyOf(o)['code'] == 'first') {
        entered.complete();
        return firstResponse.future;
      }
      return json(200, {'data': tokens(suffix: '2')});
    };
    final first = signIn(code: 'first');
    final failure = expectLater(first, throwsA(isA<ApiException>()));
    await entered.future;
    final latest = await signIn(code: 'second');
    firstResponse.complete(json(200, {'data': tokens()}));
    await failure;
    expect(latest.accountId, 'account-2');
    expect(await store.getRefreshToken(), 'refresh-2');
  });

  test(
      'logout clears before network; a delayed refusal cannot clear the next login',
      () async {
    await signIn();
    final logoutResponse = Completer<ResponseBody>();
    final entered = Completer<void>();
    respond = (o) {
      if (o.path == '/v1/auth/logout') {
        entered.complete();
        return logoutResponse.future;
      }
      return json(200, {'data': tokens(suffix: '2')});
    };
    final logout = sessions.signOut();
    await entered.future;
    expect(await store.getAccessToken(), isNull);
    final outgoing = requests.last;
    expect(bodyOf(outgoing), {'refreshToken': 'refresh-1'});
    expect(outgoing.headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('authorization')));
    await signIn(code: 'second');
    logoutResponse.complete(json(401));
    expect(await logout, isFalse); // No false claim of remote revocation.
    expect(await store.getAccessToken(), 'access-2');
    expect(requests.where((r) => r.path == '/v1/auth/refresh'), isEmpty);
  });

  test('restore cannot publish the old identity after logout and new sign-in',
      () async {
    await signIn();
    final me = Completer<ResponseBody>();
    final entered = Completer<void>();
    respond = (o) {
      if (o.path == '/v1/me') {
        entered.complete();
        return me.future;
      }
      if (o.path == '/v1/auth/logout') return json(204);
      return json(200, {'data': tokens(suffix: '2')});
    };
    final pending = sessions.restore();
    await entered.future;
    await sessions.signOut();
    await signIn(code: 'second');
    me.complete(json(200, {'data': account()}));
    expect(await pending, isNull);
    expect(await store.getAccessToken(), 'access-2');
  });

  test('logout can discard corrupt storage without claiming remote revocation',
      () async {
    final storage = store.storage as MemorySessionStorage;
    storage.values[store.scope.storageKey] = 'unreadable';
    expect(await sessions.signOut(), isFalse);
    expect(await store.getAccessToken(), isNull);
    expect(requests, isEmpty);
  });

  test('logout cancels sign-in even before the initial storage turn begins',
      () async {
    final pending = signIn();
    final failure = expectLater(pending, throwsA(isA<ApiException>()));
    await sessions.signOut();
    await failure;
    expect(await store.getAccessToken(), isNull);
    expect(requests, isEmpty);
  });

  test(
      'logout during an OS write cannot return or keep that signed-in identity',
      () async {
    final storage = store.storage as MemorySessionStorage;
    storage.writeGate = Completer<void>();
    storage.writeEntered = Completer<void>();
    final pending = signIn();
    final failure = expectLater(pending, throwsA(isA<ApiException>()));
    await storage.writeEntered!.future;
    final logout = sessions.signOut();
    storage.writeGate!.complete();
    await failure;
    await logout;
    expect(await store.getAccessToken(), isNull);
  });

  test(
      'new sign-in during an OS write snapshots after the old attempt is discarded',
      () async {
    final storage = store.storage as MemorySessionStorage;
    storage.writeGate = Completer<void>();
    storage.writeEntered = Completer<void>();
    respond = (o) => json(200,
        {'data': tokens(suffix: bodyOf(o)['code'] == 'first' ? '1' : '2')});
    final first = signIn(code: 'first');
    final failure = expectLater(first, throwsA(isA<ApiException>()));
    await storage.writeEntered!.future;
    final second = signIn(code: 'second');
    storage.writeGate!.complete();
    await failure;
    expect((await second).accountId, 'account-2');
    expect(await store.getAccessToken(), 'access-2');
  });

  test('real refresh rotates atomically without invalidating restored identity',
      () async {
    await signIn();
    final generation = store.generation;
    respond = (o) {
      if (o.path == '/v1/auth/refresh') {
        final rotated = tokens(suffix: '2')
          ..remove('driver')
          ..remove('mustChangePin');
        rotated['account'] = account();
        return json(200, {'data': rotated});
      }
      return o.headers['Authorization'] == 'Bearer access-2'
          ? json(200, {'data': account()})
          : json(401);
    };
    expect((await sessions.restore())?.accountId, 'account-1');
    expect(store.generation, generation);
    expect((store as _RaceStore).conditionalWrites, 1);
    expect(await store.getRefreshToken(), 'refresh-2');
  });

  for (final status in [200, 401]) {
    test(
        'refresh $status uses conditional storage at the final write/clear boundary',
        () async {
      await signIn();
      final observed = store as _RaceStore;
      observed.replaceBeforeRotation = status == 200;
      observed.replaceBeforeClear = status == 401;
      respond = (o) {
        if (o.path == '/v1/auth/refresh' && status == 200) {
          final rotated = tokens(suffix: '2')
            ..remove('driver')
            ..remove('mustChangePin');
          rotated['account'] = account();
          return json(200, {'data': rotated});
        }
        return json(401);
      };
      await expectLater(sessions.restore(), throwsA(isA<TrotxiException>()));
      expect(await store.getAccessToken(), 'other-a');
      expect(await store.getRefreshToken(), 'other-r');
      expect(observed.conditionalWrites, status == 200 ? 1 : 0);
      expect(observed.conditionalClears, status == 401 ? 1 : 0);
      expect(requests.where((r) => r.path == '/v1/me'), hasLength(1));
    });
  }

  test('PIN change uses supplied retry identity and replacement body only',
      () async {
    await signIn();
    respond = (_) => json(204);
    for (var i = 0; i < 2; i++) {
      await sessions.changePin(
          currentPin: '938751',
          newPin: '579241',
          idempotencyKey: 'action-pin-1');
    }
    final changes =
        requests.where((r) => r.path == '/v1/auth/driver/pin').toList();
    expect(changes, hasLength(2));
    for (final change in changes) {
      final headers =
          change.headers.map((k, v) => MapEntry(k.toLowerCase(), v));
      expect(headers['idempotency-key'], 'action-pin-1');
      expect(bodyOf(change), {'currentPin': '938751', 'newPin': '579241'});
    }
    final storage = store.storage as MemorySessionStorage;
    expect(storage.values.values.join(), isNot(contains('938751')));
    expect(storage.values.values.join(), isNot(contains('579241')));
  });
}
