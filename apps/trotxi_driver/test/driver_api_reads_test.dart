import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'support/replacement_client.dart';

void main() {
  test(
    'matching driver reads share transport but completed responses are fresh',
    () async {
      var calls = 0;
      final gate = Completer<void>();
      final started = Completer<void>();
      final api = replacementClient(
        authenticate: false,
        dio: Dio()
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (request, handler) async {
                calls++;
                if (!started.isCompleted) started.complete();
                await gate.future;
                handler.resolve(
                  Response(
                    requestOptions: request,
                    statusCode: 200,
                    data: {
                      'data': {
                        'id': 'geometry',
                        'patternVersionId': 'version',
                        'points': [
                          {'latitude': 5.6, 'longitude': -.1},
                          {'latitude': 5.7, 'longitude': -.2},
                        ],
                        'stopDistances': [],
                        'source': 'configured',
                        'createdAt': '2026-01-01T00:00:00Z',
                      },
                    },
                  ),
                );
              },
            ),
          ),
      );
      final first = api.get(
        '/v1/route-geometries/geometry',
        wire.GeometryResponse.serializer,
      );
      final second = api.get(
        '/v1/route-geometries/geometry',
        wire.GeometryResponse.serializer,
      );
      await started.future;
      expect(calls, 1);
      gate.complete();
      expect((await first).data.id, 'geometry');
      expect((await second).data.id, 'geometry');
      await api.get(
        '/v1/route-geometries/geometry',
        wire.GeometryResponse.serializer,
      );
      expect(calls, 2);
    },
  );

  test('a shared driver read cannot return after account change', () async {
    final gate = Completer<void>();
    final api = replacementClient(
      authenticate: false,
      dio: Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) async {
              await gate.future;
              handler.resolve(
                Response(requestOptions: request, statusCode: 200, data: {}),
              );
            },
          ),
        ),
    );
    final first = api.get(
      '/v1/route-geometries/geometry',
      wire.GeometryResponse.serializer,
    );
    final second = api.get(
      '/v1/route-geometries/geometry',
      wire.GeometryResponse.serializer,
    );
    final a = expectLater(first, throwsA(isA<UnauthorizedException>()));
    final b = expectLater(second, throwsA(isA<UnauthorizedException>()));
    await Future<void>.delayed(Duration.zero);
    await api.store.saveTokens(
      accessToken: 'new-driver',
      refreshToken: 'new-refresh',
    );
    gate.complete();
    await Future.wait([a, b]);
  });
}
