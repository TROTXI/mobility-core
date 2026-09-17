import 'dart:async';
import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:trotxi_client/commuter_data_client.dart';
import 'package:trotxi_client/commuter_trip_tracking.dart';
import 'package:trotxi_client/scoped_token_store.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'commuter_session_client_test.dart' show Adapter, json;
import 'scoped_token_store_test.dart' show MemorySessionStorage, scope;
import 'commute_selection_test.dart' show choice;
import 'commuter_data_client_test.dart' show page;

Map<String, Object?> tripJson({String id = 'trip'}) => {
      'id': id,
      'departureId': 'departure',
      'patternId': 'outbound',
      'serviceDate': '2026-09-16',
      'runNumber': 1,
      'routeId': 'corridor',
      'patternVersionId': 'operated-outbound',
      'direction': 'outbound',
      'scheduledAt': '2026-09-17T00:15:00Z',
      'status': 'active',
      'vehicleLabel': 'Bus A',
    };
Map<String, Object?> liveJson({String state = 'live', int age = 20}) => {
      'tripId': 'trip',
      'patternVersionId': 'operated-outbound',
      'geometryId': 'geometry',
      'riderPickupOccurrenceId': 'outbound-visit-2',
      'state': state,
      'position': {
        'location': {'latitude': 5.6, 'longitude': -.1},
        'capturedAt': '2001-01-01T00:00:00Z',
        'receivedAt': '2001-01-01T00:00:01Z',
        'ageSeconds': age
      },
      'etas': [
        for (final i in [1, 2])
          {
            'stopOccurrenceId': 'outbound-visit-$i',
            'durationSeconds': i * 180,
            'distanceMeters': i * 1200,
            'basis': i == 1 ? 'observed' : 'fallback'
          }
      ],
      'serverTime': '2001-01-01T00:00:20Z',
    };
Map<String, Object?> geometryJson() => {
      'id': 'geometry',
      'patternVersionId': 'operated-outbound',
      'points': [
        {'latitude': 5.6, 'longitude': -.1},
        {'latitude': 5.7, 'longitude': -.2}
      ],
      'stopDistances': [],
      'source': 'configured',
      'createdAt': '2026-01-01T00:00:00Z',
    };

void main() {
  late ScopedTokenStore store;
  late TrotxiApiClient client;
  late CommuterDataClient data;
  late CommuterTripTracking tracking;
  late List<RequestOptions> requests;
  late FutureOr<ResponseBody> Function(RequestOptions) reply;
  ResponseBody normal(RequestOptions o) {
    final c = choice();
    if (o.path.endsWith('/live')) return json(200, {'data': liveJson()});
    if (o.path == '/v1/trips/trip') return json(200, {'data': tripJson()});
    if (o.path == '/v1/route-geometries/geometry')
      return json(200, {'data': geometryJson()});
    if (o.path == '/v1/routes/corridor')
      return json(200, {
        'data': client.serializers.serializeWith(Route.serializer, c.route)
      });
    if (o.path == '/v1/route-patterns/outbound')
      return json(200, {
        'data': client.serializers.serializeWith(Pattern.serializer, c.pattern)
      });
    if (o.path == '/v1/route-patterns/outbound/versions/operated-outbound')
      return json(200, {
        'data': client.serializers
            .serializeWith(PatternVersion.serializer, c.version)
      });
    throw StateError('Unexpected ${o.path}');
  }

  setUp(() async {
    store = ScopedTokenStore(
        scope: scope(app: 'commuter'), storage: MemorySessionStorage());
    await store.saveTokens(accessToken: 'rider-a', refreshToken: 'refresh-a');
    const metadata =
        ClientMetadata(app: 'commuter', build: 31, platform: 'android');
    client = TrotxiClientFactory.create(
        baseUrl: store.scope.baseUrl, tokenStore: store, metadata: metadata);
    requests = [];
    reply = normal;
    client.dio.httpClientAdapter = Adapter((o) {
      requests.add(o);
      return reply(o);
    });
    data = CommuterDataClient(client: client, store: store, metadata: metadata);
    tracking = CommuterTripTracking(data, 'trip');
  });
  tearDown(() {
    tracking.dispose();
    data.dispose();
  });

  test('trip pagination preserves the chosen service dates and route filter',
      () async {
    reply = (o) => json(
        200,
        page(
            [tripJson(id: o.queryParameters['cursor'] == null ? 'one' : 'two')],
            o.queryParameters['cursor'] == null ? 'next' : null));
    final trips = await data.trips(
        from: Date(2026, 9, 16), to: Date(2026, 9, 17), routeId: 'corridor');
    expect(trips.map((t) => t.id), ['one', 'two']);
    for (final r in requests) {
      expect(r.queryParameters['fromDate'].toString(), '2026-09-16');
      expect(r.queryParameters['toDate'].toString(), '2026-09-17');
      expect(r.queryParameters['routeId'], 'corridor');
    }
    expect(trips.first.serviceDate.toString(), '2026-09-16');
    expect(trips.first.scheduledAt.day,
        17); // Midnight delay preserves business day.
  });
  test(
      'live authorization precedes static reads; operated version and loop pickup are preserved',
      () async {
    final s = await tracking.load();
    expect(requests.first.path, '/v1/trips/trip/live');
    expect(requests.any((r) => r.path.contains('newest')), isFalse);
    expect(s.geometry!.patternVersionId, 'operated-outbound');
    expect(s.stops.first.stopId, s.stops.last.stopId);
    expect(s.pickupEta!.stopOccurrenceId, 'outbound-visit-2');
    expect(s.pickupEta!.durationSeconds, 360);
    expect(s.pickupEta!.basis, StopEtaBasisEnum.fallback);
  });
  test(
      'cached static data cannot bypass a later 404 or return the old position',
      () async {
    await tracking.load();
    requests.clear();
    reply = (_) => json(404, {
          'error': {'code': 'not_found', 'message': 'Not found'}
        });
    await expectLater(
        tracking.load(),
        throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'status', 404)));
    expect(requests.map((r) => r.path), ['/v1/trips/trip/live']);
  });
  test('trip stops resolve through explicit owner, not current route links',
      () async {
    reply = (o) {
      final c = choice();
      if (o.path == '/v1/routes/corridor') {
        return json(200, {
          'data': client.serializers.serializeWith(
              Route.serializer, c.route.rebuild((b) => b.patternIds.clear()))
        });
      }
      if (o.path == '/v1/route-patterns/outbound') {
        return json(200, {
          'data': client.serializers.serializeWith(Pattern.serializer,
              c.pattern.rebuild((b) => b.publishedVersionId = null))
        });
      }
      return normal(o);
    };
    final snapshot = await tracking.load();
    expect(snapshot.stops, hasLength(3));
    expect(snapshot.mapWarning, isNull);
    expect(snapshot.stopName('outbound-visit-2'), 'Home');
  });
  test('offline live read does not resolve to the previous successful snapshot',
      () async {
    await tracking.load();
    reply = (o) => throw DioException(
        requestOptions: o, type: DioExceptionType.connectionError);
    await expectLater(tracking.load(), throwsA(isA<OfflineException>()));
  });
  test('a non-current route label cannot hide the trip-owned stops', () async {
    reply = (o) => o.path == '/v1/routes/corridor'
        ? json(404, {
            'error': {'code': 'not_found', 'message': 'Not current'}
          })
        : normal(o);
    final snapshot = await tracking.load();
    expect(snapshot.stops, hasLength(3));
    expect(snapshot.routeName, isNull);
    expect(snapshot.hasPosition, isTrue);
  });
  test(
      'wrong trip or version in a live response is rejected before geometry reads',
      () async {
    for (final field in ['tripId', 'patternVersionId']) {
      requests.clear();
      reply = (o) => o.path.endsWith('/live')
          ? json(200, {
              'data': {...liveJson(), field: 'other'}
            })
          : normal(o);
      await expectLater(tracking.load(), throwsA(isA<ApiException>()));
      expect(requests.any((r) => r.path.contains('geometries')), isFalse);
    }
  });
  test(
      'wrong geometry ownership degrades explicitly without drawing another revision',
      () async {
    reply = (o) => o.path.contains('geometries')
        ? json(200, {
            'data': {...geometryJson(), 'patternVersionId': 'newest-outbound'}
          })
        : normal(o);
    final s = await tracking.load();
    expect(s.geometry, isNull);
    expect(s.hasPosition, isTrue);
    expect(s.mapWarning, contains('no substitute'));
    expect(s.etas, hasLength(2));
  });
  test(
      'missing version details keep occurrence IDs and never substitute latest version',
      () async {
    reply = (o) =>
        o.path.contains('/versions/') || o.path == '/v1/route-patterns/return'
            ? json(404, {
                'error': {'code': 'not_found', 'message': 'Not found'}
              })
            : normal(o);
    final s = await tracking.load();
    expect(s.stops, isEmpty);
    expect(s.pickupEta!.stopOccurrenceId, 'outbound-visit-2');
    expect(s.stopName('outbound-visit-2'), 'Your pickup');
    expect(requests.any((r) => r.path.contains('newest')), isFalse);
  });
  test(
      'age uses server duration plus monotonic elapsed, with exact 30/120 thresholds',
      () async {
    final loaded = await tracking.load();
    var elapsed = Duration.zero;
    final s = CommuterTripSnapshot(
        trip: loaded.trip, live: loaded.live, elapsed: () => elapsed);
    elapsed = const Duration(seconds: 10);
    expect(s.fresh, isTrue);
    elapsed = const Duration(milliseconds: 10001);
    expect(s.fresh, isFalse);
    elapsed = const Duration(seconds: 100);
    expect(s.etas, hasLength(2));
    elapsed = const Duration(milliseconds: 100001);
    expect(s.etas, isEmpty);
    expect(s.hasPosition, isTrue);
    expect(s.pickupEta, isNull);
  });
  test(
      'ended/not-started/awaiting-fix hide even an inconsistent supplied fix and predictions',
      () async {
    final loaded = await tracking.load();
    for (final state in ['ended', 'not_started', 'awaiting_fix']) {
      final s = CommuterTripSnapshot(
          trip: loaded.trip,
          live: client.serializers
              .deserializeWith(LiveTrip.serializer, liveJson(state: state))!,
          elapsed: () => Duration.zero);
      expect(s.hasPosition, isFalse);
      expect(s.age, isNull);
      expect(s.etas, isEmpty);
    }
  });
  test('a reached pickup is not replaced by the first upcoming stop', () async {
    final loaded = await tracking.load();
    final s = CommuterTripSnapshot(
        trip: loaded.trip,
        live: loaded.live
            .rebuild((b) => b.riderPickupOccurrenceId = 'outbound-visit-0'),
        elapsed: () => Duration.zero);
    expect(s.etas, isNotEmpty);
    expect(s.pickupEta, isNull);
  });
  test('background invalidation stops the pending read chain before more HTTP',
      () async {
    final entered = Completer<void>(), release = Completer<void>();
    reply = (o) async {
      entered.complete();
      await release.future;
      return normal(o);
    };
    final pending = tracking.load();
    final assertion =
        expectLater(pending, throwsA(isA<UnauthorizedException>()));
    await entered.future;
    tracking.invalidate();
    release.complete();
    await assertion;
    expect(requests, hasLength(1));
  });
  test('new login cannot use a previous tracker or send with the new token',
      () async {
    await tracking.load();
    requests.clear();
    await store.saveTokens(accessToken: 'rider-b', refreshToken: 'refresh-b');
    await expectLater(tracking.load(), throwsA(isA<UnauthorizedException>()));
    expect(requests, isEmpty);
  });
  test('upgrade and rate limiting on supplementary geometry are not swallowed',
      () async {
    for (final code in [426, 429]) {
      reply = (o) => o.path.contains('geometries')
          ? json(code, {
              'error': {'code': 'limited', 'message': 'Stop'}
            })
          : normal(o);
      await expectLater(tracking.load(), throwsA(isA<TrotxiException>()));
    }
  });
}
