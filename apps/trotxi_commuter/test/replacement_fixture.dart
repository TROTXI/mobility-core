import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:trotxi_client_next/scoped_token_store.dart';
import 'package:trotxi_client_next/trotxi_client_next.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';

class MemoryStorage implements SessionStorage {
  final values = <String, String>{};
  bool failDelete = false;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    if (failDelete) throw StateError('Storage unavailable');
    values.remove(key);
  }
}

class TestAdapter implements HttpClientAdapter {
  TestAdapter(this.reply);
  final FutureOr<ResponseBody> Function(RequestOptions) reply;
  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<Uint8List>? body,
    Future<void>? cancel,
  ) async => reply(o);
  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Object? body, [int status = 200]) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
Map<String, dynamic> bodyOf(RequestOptions o) =>
    (o.data is String ? jsonDecode(o.data as String) : o.data)
        as Map<String, dynamic>;
Map<String, Object?> page(List<Object?> rows, [String? next]) => {
  'data': rows,
  'page': {'nextCursor': next},
};
const timestamp = '2026-09-16T06:00:00Z';
Map<String, Object?> account([String name = 'Ama']) => {
  'id': 'rider-$name',
  'displayName': name,
  'role': 'commuter',
  'phone': null,
  'avatarUrl': null,
  'createdAt': timestamp,
};
Map<String, Object?> flags({int floor = 1}) => {
  'serverTime': timestamp,
  'applications': [
    {
      'app': 'commuter',
      'platform': 'ios',
      'minSupportedBuild': floor,
      'storeUrl': null,
      'apiMajor': 1,
    },
  ],
  'operations': {'phone': null, 'whatsapp': null, 'email': null, 'hours': null},
  'mapTiles': {
    'url': null,
    'styleUrl': null,
    'darkStyleUrl': null,
    'attribution': '',
  },
  'flags': [],
};
Map<String, Object?> tokens([String name = 'Ama']) => {
  'data': {
    'accessToken': 'access-$name',
    'refreshToken': 'refresh-$name',
    'account': account(name),
    'accessExpiresAt': '2030-01-01T00:00:00Z',
    'refreshExpiresAt': '2030-02-01T00:00:00Z',
  },
};

class Fixture {
  Fixture() {
    transport = wire.TrotxiClientFactory.create(
      baseUrl: store.scope.baseUrl,
      tokenStore: store,
      metadata: metadata,
    );
    transport.dio.httpClientAdapter = TestAdapter((o) {
      requests.add(o);
      return reply(o);
    });
    api = CommuterApi(client: transport, store: store, metadata: metadata);
  }
  static const metadata = wire.ClientMetadata(
    app: 'commuter',
    build: 31,
    platform: 'ios',
  );
  final storage = MemoryStorage();
  late final store = ScopedTokenStore(
    scope: SessionScope(
      baseUrl: 'http://localhost:3001',
      realm: 'test-only',
      app: 'commuter',
    ),
    storage: storage,
  );
  late final wire.TrotxiApiClientNext transport;
  late final CommuterApi api;
  final requests = <RequestOptions>[];
  FutureOr<ResponseBody> Function(RequestOptions) reply = (o) {
    if (o.path == '/flags') return jsonResponse(flags());
    if (o.path == '/v1/me') return jsonResponse({'data': account()});
    if (o.path == '/v1/me/reservations') return jsonResponse(page([]));
    return jsonResponse({
      'error': {
        'code': 'not_found',
        'message': 'No fixture for this endpoint.',
      },
    }, 404);
  };
  Future<void> signedIn() =>
      store.saveTokens(accessToken: 'access-Ama', refreshToken: 'refresh-Ama');
}
