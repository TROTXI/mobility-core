import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'replacement_fixture.dart';

/// A one-pixel PNG. Real bytes rather than a placeholder string, because the
/// server reads the file's own header to decide what it is and refuses a
/// declaration that does not match.
final _png = Uint8List.fromList(base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
));

void main() {
  test('an upload sends the picture as multipart and returns the signed url', () async {
    final fixture = Fixture();
    await fixture.signedIn();
    fixture.reply = (o) {
      if (o.path == '/v1/me/avatar' && o.method == 'PUT') {
        return jsonResponse({
          'data': {
            'url': 'https://r2.example/avatars/ama.png?signature=abc',
            'expiresAt': '2026-09-17T08:05:00.000Z',
          },
        });
      }
      return jsonResponse({'error': {'code': 'not_found', 'message': 'x'}}, 404);
    };

    final avatar = await fixture.api.uploadAvatar(_png, contentType: 'image/png');
    expect(avatar.url, contains('signature=abc'));

    final sent = fixture.requests.single;
    expect(sent.method, 'PUT');
    expect(sent.data, isA<FormData>());
    final form = sent.data as FormData;
    expect(form.files.single.key, 'file');
    expect(form.files.single.value.contentType?.mimeType, 'image/png');
    // Every mutation carries one, and the header is what makes a retry safe.
    expect(sent.headers['Idempotency-Key'], isNotNull);
    expect(sent.headers['X-Trotxi-Client'], 'commuter');
    expect(sent.headers['X-Trotxi-Platform'], 'ios');
  });

  test('the same picture retries under one key; a different one gets its own', () async {
    final fixture = Fixture();
    await fixture.signedIn();
    var attempt = 0;
    fixture.reply = (o) {
      attempt++;
      // First attempt fails the way a flaky connection does, so the retry has
      // to reuse the key or the server would take the same photo twice.
      if (attempt == 1) return jsonResponse({'error': {'code': 'unavailable', 'message': 'x'}}, 503);
      return jsonResponse({
        'data': {'url': 'https://r2.example/a.png', 'expiresAt': '2026-09-17T08:05:00.000Z'},
      });
    };

    await expectLater(
      fixture.api.uploadAvatar(_png, contentType: 'image/png'),
      throwsA(isA<TrotxiException>()),
    );
    await fixture.api.uploadAvatar(_png, contentType: 'image/png');
    final keys = fixture.requests.map((r) => r.headers['Idempotency-Key']).toList();
    expect(keys.first, keys.last, reason: 'the same photo is one upload, however often it is sent');

    final other = Uint8List.fromList([..._png, 0]);
    await fixture.api.uploadAvatar(other, contentType: 'image/png');
    expect(fixture.requests.last.headers['Idempotency-Key'], isNot(keys.first),
        reason: 'a different photo is a different upload');
  });

  test('a refused file surfaces the server code rather than a generic failure', () async {
    for (final status in [413, 415]) {
      final fixture = Fixture();
      await fixture.signedIn();
      fixture.reply = (o) => jsonResponse({
            'error': {'code': status == 413 ? 'too_large' : 'unsupported_media_type', 'message': 'x'},
          }, status);
      await expectLater(
        fixture.api.uploadAvatar(_png, contentType: 'image/png'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', status)),
      );
    }
  });
}
