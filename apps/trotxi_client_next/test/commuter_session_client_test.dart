import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:trotxi_client_next/commuter_session_client.dart';
import 'package:trotxi_client_next/scoped_token_store.dart';
import 'package:trotxi_client_next/trotxi_client_next.dart';
import 'scoped_token_store_test.dart' show MemorySessionStorage, scope;

class Adapter implements HttpClientAdapter {
  Adapter(this.reply);
  final FutureOr<ResponseBody> Function(RequestOptions) reply;
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? body,
          Future<void>? cancel) async =>
      reply(o);
  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, Object body) =>
    ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: ['application/json']
    });
Map<String, Object?> account({String suffix = '1', String role = 'commuter'}) =>
    {
      'id': 'rider-$suffix',
      'displayName': 'Test rider',
      'role': role,
      'phone': null,
      'avatarUrl': null,
      'createdAt': '2026-01-01T00:00:00Z',
    };
Map<String, Object?> tokens({String suffix = '1', String role = 'commuter'}) =>
    {
      'accessToken': 'a-$suffix',
      'refreshToken': 'r-$suffix',
      'accessExpiresAt': '2026-01-01T01:00:00Z',
      'refreshExpiresAt': '2026-02-01T00:00:00Z',
      'account': account(suffix: suffix, role: role),
    };
Map<String, dynamic> bodyOf(RequestOptions o) =>
    (o.data is String ? jsonDecode(o.data as String) : o.data)
        as Map<String, dynamic>;

void main() {
  const metadata = ClientMetadata(app: 'commuter', build: 31, platform: 'ios');
  late MemorySessionStorage storage;
  late ScopedTokenStore store;
  late TrotxiApiClientNext client;
  late CommuterSessionClient sessions;
  late List<RequestOptions> requests;
  late FutureOr<ResponseBody> Function(RequestOptions) reply;

  Future<Account> google([String proof = 'google-proof']) =>
      sessions.signInGoogle(obtainIdToken: () async => proof);

  setUp(() {
    storage = MemorySessionStorage();
    store = ScopedTokenStore(scope: scope(app: 'commuter'), storage: storage);
    client = TrotxiClientFactory.create(
        baseUrl: store.scope.baseUrl, tokenStore: store, metadata: metadata);
    requests = [];
    reply = (_) => json(200, {'data': tokens()});
    client.dio.httpClientAdapter = Adapter((o) {
      requests.add(o);
      return reply(o);
    });
    sessions =
        CommuterSessionClient(client: client, store: store, metadata: metadata);
  });

  test(
      'Google uses generated envelope and commuter metadata, without storing provider proof',
      () async {
    final result = await google();
    expect(result.id, 'rider-1');
    expect(requests.single.path, '/v1/auth/google');
    expect(bodyOf(requests.single), {'idToken': 'google-proof'});
    final headers = requests.single.headers
        .map((k, v) => MapEntry(k.toLowerCase(), v.toString()));
    expect(headers['x-trotxi-client'], 'commuter');
    expect(headers['x-trotxi-platform'], 'ios');
    expect(headers['x-trotxi-build'], '31');
    expect(await store.getRefreshToken(), 'r-1');
    expect(storage.values.values.single, isNot(contains('google-proof')));
  });

  test(
      'Apple forwards only the supplied proof fields and shares the session scope',
      () async {
    await sessions.signInApple(
        obtainCredential: () async => const AppleCredential(
            idToken: 'apple-proof',
            nonce: 'nonce',
            authorizationCode: 'code',
            displayName: 'Ama'));
    expect(requests.single.path, '/v1/auth/apple');
    expect(bodyOf(requests.single), {
      'idToken': 'apple-proof',
      'nonce': 'nonce',
      'authorizationCode': 'code',
      'displayName': 'Ama'
    });
    expect(await store.getAccessToken(), 'a-1');
    expect(storage.values.values.single, isNot(contains('apple-proof')));
  });

  test('wrong app or backend cannot share this store', () {
    expect(
        () => CommuterSessionClient(
            client: client,
            store: ScopedTokenStore(scope: scope()),
            metadata: metadata),
        throwsArgumentError);
    expect(
        () => CommuterSessionClient(
            client: client,
            store: ScopedTokenStore(
                scope: scope(app: 'commuter', url: 'https://other.test')),
            metadata: metadata),
        throwsArgumentError);
  });

  test('wrong-role and old flat tokens never create a commuter session',
      () async {
    reply = (_) => json(200, {'data': tokens(role: 'driver')});
    await expectLater(google(), throwsA(isA<ApiException>()));
    reply = (_) => json(200, tokens());
    await expectLater(google(), throwsA(isA<DioException>()));
    expect(await store.getAccessToken(), isNull);
  });

  test('provider cancellation and empty proof never reach the backend',
      () async {
    await expectLater(
        sessions.signInGoogle(
            obtainIdToken: () async => throw StateError('cancelled')),
        throwsStateError);
    await expectLater(google(' '), throwsA(isA<ApiException>()));
    expect(requests, isEmpty);
    expect(storage.writes, isEmpty);
  });

  for (final entry in <int, Matcher>{
    401: isA<InvalidCredentialsException>(),
    403: isA<ApiException>(),
    426: isA<UpgradeRequiredException>(),
    429: isA<RateLimitException>(),
    503: isA<ApiException>()
  }.entries) {
    test(
        'social sign-in ${entry.key} preserves existing credentials without refresh',
        () async {
      await store.saveTokens(accessToken: 'old-a', refreshToken: 'old-r');
      reply = (_) => json(entry.key, {
            'error': {'code': 'refused', 'message': 'Refused'}
          });
      await expectLater(google(), throwsA(entry.value));
      expect(await store.getRefreshToken(), 'old-r');
      expect(requests, hasLength(1));
    });
  }

  test('logout while native provider is open prevents even the token exchange',
      () async {
    final entered = Completer<void>();
    final proof = Completer<String>();
    final pending = sessions.signInGoogle(obtainIdToken: () {
      entered.complete();
      return proof.future;
    });
    final failure = expectLater(pending, throwsA(isA<ApiException>()));
    await entered.future;
    await sessions.signOut();
    proof.complete('late-proof');
    await failure;
    expect(requests, isEmpty);
    expect(await store.getAccessToken(), isNull);
  });

  test('late backend sign-in cannot overwrite the newer provider attempt',
      () async {
    final entered = Completer<void>();
    final first = Completer<ResponseBody>();
    reply = (o) {
      if (bodyOf(o)['idToken'] == 'first') {
        entered.complete();
        return first.future;
      }
      return json(200, {'data': tokens(suffix: '2')});
    };
    final pending = google('first');
    final failure = expectLater(pending, throwsA(isA<ApiException>()));
    await entered.future;
    expect((await google('second')).id, 'rider-2');
    first.complete(json(200, {'data': tokens()}));
    await failure;
    expect(await store.getRefreshToken(), 'r-2');
  });

  test('logout during OS write leaves no late identity installed', () async {
    storage.writeGate = Completer<void>();
    storage.writeEntered = Completer<void>();
    final pending = google();
    final failure = expectLater(pending, throwsA(isA<ApiException>()));
    await storage.writeEntered!.future;
    final logout = sessions.signOut();
    storage.writeGate!.complete();
    await failure;
    await logout;
    expect(await store.getAccessToken(), isNull);
  });

  test('failed OS write never announces an authenticated account', () async {
    storage.failWrite = true;
    await expectLater(google(), throwsStateError);
    expect(await store.getAccessToken(), isNull);
  });

  test(
      'restore without credentials makes no request; with credentials returns current account',
      () async {
    expect(await sessions.restore(), isNull);
    expect(requests, isEmpty);
    await google();
    reply = (_) => json(200, {'data': account()});
    expect((await sessions.restore())?.id, 'rider-1');
    expect(requests.last.path, '/v1/me');
  });

  test('offline hydration is not sign-out; rejected refresh is', () async {
    await google();
    reply = (o) => throw DioException(
        requestOptions: o, type: DioExceptionType.receiveTimeout);
    await expectLater(sessions.restore(), throwsA(isA<OfflineException>()));
    expect(await store.getAccessToken(), 'a-1');
    reply = (_) => json(401, {
          'error': {'code': 'unauthorized', 'message': 'Expired'}
        });
    expect(await sessions.restore(), isNull);
    expect(requests.last.path, '/v1/auth/refresh');
    expect(await store.getRefreshToken(), isNull);
  });

  test('late account hydration is discarded after a new sign-in', () async {
    await google();
    final entered = Completer<void>();
    final response = Completer<ResponseBody>();
    reply = (o) {
      if (o.path == '/v1/me') {
        entered.complete();
        return response.future;
      }
      return json(200, {'data': tokens(suffix: '2')});
    };
    final pending = sessions.restore();
    await entered.future;
    await google();
    response.complete(json(200, {'data': account()}));
    expect(await pending, isNull);
    expect(await store.getRefreshToken(), 'r-2');
  });

  test('logout failure cannot erase the next login or attach its bearer',
      () async {
    await google();
    final entered = Completer<void>();
    final response = Completer<ResponseBody>();
    reply = (o) {
      if (o.path == '/v1/auth/logout') {
        entered.complete();
        return response.future;
      }
      return json(200, {'data': tokens(suffix: '2')});
    };
    final logout = sessions.signOut();
    await entered.future;
    expect(await store.getAccessToken(), isNull);
    expect(bodyOf(requests.last), {'refreshToken': 'r-1'});
    expect(requests.last.headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('authorization')));
    await google();
    response.complete(json(401, {
      'error': {'code': 'unauthorized', 'message': 'Expired'}
    }));
    expect(await logout, isFalse);
    expect(await store.getRefreshToken(), 'r-2');
    expect(requests.where((o) => o.path == '/v1/auth/refresh'), isEmpty);
  });

  test('local deletion failure is surfaced before any remote logout', () async {
    await google();
    storage.failDelete = true;
    await expectLater(sessions.signOut(), throwsStateError);
    expect(await store.getRefreshToken(), 'r-1');
    expect(requests, hasLength(1));
  });
}
