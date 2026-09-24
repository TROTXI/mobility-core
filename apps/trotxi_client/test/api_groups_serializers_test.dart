import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:trotxi_client/trotxi_client.dart';

const _body = '{"data":{"id":"u_1","displayName":"Fosu Adom","phone":null,'
    '"avatarUrl":null,"role":"commuter",'
    '"createdAt":"2026-09-20T10:00:00.000Z"}}';

class _StubAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      _body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  // The groups in TrotxiApiClientGroups must be handed the client's own
  // `serializers`, not the plugin-less top-level of the same name that the
  // generated client also exports. With the wrong one every response fails
  // with "_Map<String, dynamic> is not a subtype of Iterable<Object?>".
  test('extension API groups deserialize responses', () async {
    final client = TrotxiApiClient(basePathOverride: 'https://example.test');
    client.dio.httpClientAdapter = _StubAdapter();

    final response = await client.getSelfApi().getAccount(
      xTrotxiClient: 'commuter',
      xTrotxiBuild: 1,
      xTrotxiPlatform: 'android',
    );

    expect(response.data?.data.displayName, 'Fosu Adom');
  });
}
