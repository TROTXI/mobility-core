import 'package:dio/dio.dart';
import 'package:trotxi_client_next/trotxi_client_next.dart' as wire;
import 'package:trotxi_client_next/scoped_token_store.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';

class MemorySessionStorage implements SessionStorage {
  final values = <String, String>{};
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

DriverApi replacementClient({Dio? dio, bool authenticate = true}) {
  final store = ScopedTokenStore(
    scope: SessionScope(
      baseUrl: 'http://localhost',
      app: 'driver',
      realm: 'test',
    ),
    storage: MemorySessionStorage(),
  );
  final metadata = wire.ClientMetadata(
    app: 'driver',
    build: 1,
    platform: 'android',
  );
  final client = wire.TrotxiClientFactory.create(
    baseUrl: 'http://localhost',
    tokenStore: store,
    metadata: metadata,
  );
  if (!authenticate) {
    // Repository/widget tests exercise serializers, not the OS session queue
    // across Flutter's fake clock. Session integration is tested separately.
    client.dio.interceptors.removeWhere((i) => i is wire.AuthInterceptor);
  }
  if (dio != null) {
    client.dio.httpClientAdapter = dio.httpClientAdapter;
    client.dio.interceptors.addAll(dio.interceptors);
  }
  return DriverApi(client: client, store: store, metadata: metadata);
}

Map<String, Object?> positionReceipt(
  RequestOptions options, {
  bool accepted = true,
}) {
  final body = options.data as Map;
  return {
    'data': {
      'clientFixId': body['clientFixId'],
      'capturedAt': body['capturedAt'],
      'effectiveCapturedAt': body['capturedAt'],
      'receivedAt': DateTime.now().toUtc().toIso8601String(),
      'acceptedForLive': accepted,
      'clockAdjusted': false,
    },
  };
}
