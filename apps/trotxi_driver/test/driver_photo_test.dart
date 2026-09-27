import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/data/profile_repository.dart';

import 'support/replacement_client.dart';

class Adapter implements HttpClientAdapter {
  Adapter(this.reply);
  final FutureOr<(int, Object?)> Function(RequestOptions) reply;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<Uint8List>? body,
    Future<void>? cancel,
  ) async {
    requests.add(o);
    final (status, data) = await reply(o);
    return ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

DriverApi withAdapter(Adapter adapter) =>
    replacementClient(dio: Dio()..httpClientAdapter = adapter);

Map<String, Object?> account({String? avatarUrl}) => {
  'data': {
    'id': 'user-1',
    'displayName': 'Kwame Mensah',
    'email': null,
    'phone': null,
    'avatarUrl': avatarUrl,
    'role': 'driver',
    'createdAt': '2026-09-13T06:30:00Z',
  },
};

final bytes = Uint8List.fromList(List<int>.generate(64, (i) => i));

void main() {
  test('an account with no photo reports one rather than failing', () async {
    final adapter = Adapter((_) => (200, account()));
    final photo = await DriverProfileRepository(withAdapter(adapter)).account();

    expect(photo.avatarUrl, isNull);
    expect(adapter.requests.single.path, '/v1/me');
  });

  test('uploading sends the file as multipart and returns the signed URL', () async {
    final adapter = Adapter(
      (_) => (200, {
        'data': {
          'url': 'https://example.test/signed',
          'expiresAt': '2026-09-13T06:35:00Z',
        },
      }),
    );
    final url = await DriverProfileRepository(withAdapter(adapter)).uploadPhoto(
      bytes,
      contentType: 'image/jpeg',
      filename: 'driver.jpg',
    );

    expect(url, 'https://example.test/signed');
    final sent = adapter.requests.single;
    expect(sent.method, 'PUT');
    expect(sent.path, '/v1/me/avatar');
    expect(sent.data, isA<FormData>());
    expect((sent.data as FormData).files.single.key, 'file');
    expect(
      sent.headers['Idempotency-Key'],
      isNotNull,
      reason: 'an uncertain upload has to be retryable as the same upload',
    );
  });

  test('the same picture retried keeps its key, a different one does not', () async {
    var attempt = 0;
    final adapter = Adapter((_) {
      attempt++;
      if (attempt == 1) return (503, {'error': {'code': 'unavailable'}});
      return (200, {
        'data': {
          'url': 'https://example.test/signed',
          'expiresAt': '2026-09-13T06:35:00Z',
        },
      });
    });
    final repository = DriverProfileRepository(withAdapter(adapter));

    await expectLater(
      repository.uploadPhoto(
        bytes,
        contentType: 'image/jpeg',
        filename: 'driver.jpg',
      ),
      throwsA(isA<wire.TrotxiException>()),
    );
    await repository.uploadPhoto(
      bytes,
      contentType: 'image/jpeg',
      filename: 'driver.jpg',
    );
    final keys = adapter.requests
        .map((r) => r.headers['Idempotency-Key'])
        .toList();
    expect(
      keys[0],
      keys[1],
      reason: 'a retry of the same bytes must not become a second upload',
    );

    final other = Uint8List.fromList(List<int>.generate(64, (i) => 64 - i));
    await repository.uploadPhoto(
      other,
      contentType: 'image/png',
      filename: 'other.png',
    );
    expect(adapter.requests.last.headers['Idempotency-Key'], isNot(keys[0]));
  });
}
