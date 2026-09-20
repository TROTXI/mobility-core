import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/data/trips_repository.dart';
import 'package:trotxi_driver/data/route_map_repository.dart';
import 'package:trotxi_driver/data/incidents_repository.dart';
import 'package:trotxi_driver/data/work_repository.dart';
import 'package:trotxi_driver/data/config_repository.dart';
import 'package:trotxi_driver/Presentations/Boarding/models/scan_result.dart';
import 'support/replacement_client.dart';

const at = '2026-09-13T06:30:00Z';
const point = {'latitude': 5.57, 'longitude': -0.21};
Map<String, Object?> stop(String id, int ordinal) => {
  'id': id,
  'stopId': 'same-physical-stop',
  'ordinal': ordinal,
  'name': id,
  'location': point,
};
Map<String, Object?> trip({
  String id = 'trip-1',
  String direction = 'outbound',
}) => {
  'id': id,
  'departureId': 'departure-1',
  'patternId': direction == 'outbound' ? 'pattern-out' : 'pattern-return',
  'serviceDate': '2026-09-13',
  'runNumber': 1,
  'routeId': 'route-1',
  'patternVersionId': 'version-old',
  'direction': direction,
  'scheduledAt': at,
  'status': 'active',
  'vehicleLabel': 'Bus 1',
  'startedAt': at,
  'completedAt': null,
  'currentStopOccurrenceId': null,
  'stops': [stop('$id-first', 0), stop('$id-repeat', 4)],
  'version': 3,
  'editToken': '"trip:3"',
};
Map<String, Object?> route() => {
  'id': 'route-1',
  'name': 'Circle loop',
  'description': null,
  'patternIds': ['pattern-out', 'pattern-return'],
  'acceptsDriverRequests': true,
  'archived': false,
  'editToken': '"route:1"',
  'createdAt': at,
  'updatedAt': at,
  'version': 1,
};
Map<String, Object?> page(List<Object?> rows, [String? next]) => {
  'data': rows,
  'page': {'nextCursor': next},
};
Map<String, Object?> incident(String id) => {
  'id': id,
  'tripId': 'trip-1',
  'vehicleId': 'vehicle-1',
  'category': 'passenger_safety',
  'note': 'Needs help',
  'location': point,
  'status': 'open',
  'resolution': null,
  'createdAt': at,
};
Map<String, Object?> boarding(
  String reservation, {
  bool replay = false,
  String status = 'boarded',
}) => {
  'data': {
    'reservationId': reservation,
    'status': status,
    'alreadyApplied': replay,
    'chargedRides': replay ? 0 : 1,
  },
};
Map<String, Object?> bootstrap({
  String app = 'driver',
  String platform = 'android',
  int floor = 1,
}) => {
  'serverTime': at,
  'applications': [
    {
      'app': app,
      'platform': platform,
      'minSupportedBuild': floor,
      'apiMajor': 1,
      'storeUrl': null,
    },
  ],
  'operations': {
    'phone': '+233200000000',
    'whatsapp': null,
    'email': null,
    'hours': 'Service hours',
  },
  'mapTiles': {
    'url': null,
    'styleUrl': 'https://tiles.example.test/light.json',
    'darkStyleUrl': null,
    'attribution': 'Map attribution',
  },
  'flags': [],
};

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
void seedTrip(
  DriverApi api, {
  String id = 'trip-1',
  String direction = 'outbound',
}) {
  // Establish the same cache epoch as a completed assigned-list read.
  api.sessionGeneration;
  api.trips[id] = api.client.serializers.deserializeWith(
    wire.DriverTrip.serializer,
    trip(id: id, direction: direction),
  )!;
}

void main() {
  test(
    'driver rows expose the actual plate and assignment change time',
    () async {
      final api = withAdapter(
        Adapter(
          (o) => o.path == '/v1/driver/trips'
              ? (
                  200,
                  {
                    'data': [
                      {
                        ...trip(),
                        'vehiclePlate': 'GT 1234-26',
                        'assignmentChangedAt': at,
                      },
                    ],
                    'page': {'nextCursor': null},
                  },
                )
              : (200, {'data': route()}),
        ),
      );
      final runs = await TripsRepository(client: api).myRuns();
      expect(runs.single.vehicleRegistration, 'GT 1234-26');
      expect(runs.single.assignmentChangedAt, DateTime.parse(at));
    },
  );

  test(
    'cached public configuration is scoped and survives repository restart',
    () async {
      final api = withAdapter(Adapter((_) => (200, bootstrap())));
      await ConfigRepository(client: api).load();
      expect(
        (await ConfigRepository(client: api).cached())!.operations.phone,
        '+233200000000',
      );
    },
  );
  for (final code in ['boarding_ineligible', 'insufficient_rides']) {
    test(
      '$code preserves the refusal without claiming the seat is absent',
      () async {
        final repo = TripsRepository(
          client: withAdapter(
            Adapter(
              (_) => (
                409,
                {
                  'error': {
                    'code': code,
                    'message': 'This reservation cannot be charged.',
                  },
                },
              ),
            ),
          ),
        );
        final result = await repo.scan(pass: 'proof', runId: 'trip-1');
        expect(result.outcome, BoardingOutcome.failed);
        expect(result.isAccepted, isFalse);
        expect(result.detail, 'This reservation cannot be charged.');
        expect(result.title, isNot('No reservation found'));
      },
    );
  }

  test(
    'known assigned trips refresh without the public archived-route catalogue',
    () async {
      final adapter = Adapter(
        (o) => o.path == '/v1/driver/trips'
            ? (200, page([trip()..['scheduledAt'] = '2026-09-14T00:15:00Z']))
            : (
                404,
                {
                  'error': {'code': 'not_found', 'message': 'Not found'},
                },
              ),
      );
      final api = withAdapter(adapter);
      seedTrip(api);
      final refreshed = await api.trip('trip-1', refresh: true);
      expect(refreshed.scheduledAt.day, 14);
      expect(refreshed.serviceDate.toString(), '2026-09-13');
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.path, '/v1/driver/trips');
      expect(adapter.requests.single.queryParameters, {
        'fromDate': '2026-09-13',
        'toDate': '2026-09-13',
        'routeId': 'route-1',
        'limit': 200,
      });
    },
  );

  test(
    'assigned pages preserve both date filters, metadata and all rows',
    () async {
      final adapter = Adapter(
        (o) => o.path == '/v1/routes/route-1'
            ? (200, {'data': route()})
            : (
                200,
                o.queryParameters['cursor'] == null
                    ? page([trip()], 'next')
                    : page([trip(id: 'trip-2', direction: 'return')]),
              ),
      );
      final api = withAdapter(adapter);
      final rows = await TripsRepository(
        client: api,
      ).myRuns(date: '2026-09-13');
      expect(rows.map((r) => r.id), ['trip-1', 'trip-2']);
      expect(rows.map((r) => r.direction), ['outbound', 'return_']);
      final reads = adapter.requests
          .where((r) => r.path == '/v1/driver/trips')
          .toList();
      expect(reads, hasLength(2));
      for (final read in reads) {
        expect(read.queryParameters['fromDate'], '2026-09-13');
        expect(read.queryParameters['toDate'], '2026-09-13');
        expect(read.headers['x-trotxi-client'], 'driver');
        expect(read.headers['x-trotxi-platform'], 'android');
        expect(read.headers['x-trotxi-build'].toString(), '1');
      }
    },
  );

  test(
    'a repeated page cursor fails rather than returning a partial list',
    () async {
      final adapter = Adapter((_) => (200, page([incident('i1')], 'repeated')));
      await expectLater(
        IncidentsRepository(client: withAdapter(adapter)).mine(),
        throwsA(isA<ApiException>()),
      );
      expect(adapter.requests, hasLength(2));
    },
  );

  test(
    'an uncertain incident retries the same key; a new successful intent gets a fresh key',
    () async {
      var first = true;
      final adapter = Adapter((o) {
        if (first) {
          first = false;
          throw DioException(
            requestOptions: o,
            type: DioExceptionType.receiveTimeout,
          );
        }
        return (201, {'data': incident('i1')});
      });
      final api = withAdapter(adapter);
      final repo = IncidentsRepository(client: api);
      Future<DriverIncident> send() => repo.file(
        category: IncidentCategory.passengerSafety,
        tripId: 'trip-1',
        note: ' Needs help ',
        lat: 5.57,
        lng: -0.21,
      );
      await expectLater(send(), throwsA(isA<OfflineException>()));
      expect((await send()).category, IncidentCategory.passengerSafety);
      await send();
      final keys = adapter.requests
          .map((r) => r.headers['Idempotency-Key'])
          .toList();
      expect(keys[0], isNotNull);
      expect(keys[1], keys[0]);
      expect(keys[2], isNot(keys[0]));
      expect(adapter.requests.first.data, {
        'category': 'passenger_safety',
        'tripId': 'trip-1',
        'note': 'Needs help',
        'location': point,
      });
    },
  );

  test(
    'arrival uses this trip occurrence, preserves stale token and does not auto-retry 412',
    () async {
      final adapter = Adapter(
        (_) => (
          412,
          {
            'error': {'code': 'precondition_failed', 'message': 'Reload'},
          },
        ),
      );
      final api = withAdapter(adapter);
      seedTrip(api);
      seedTrip(api, id: 'trip-return', direction: 'return');
      final repo = TripsRepository(client: api);
      final stops = await repo.stopsFor('trip-return');
      expect(stops.map((s) => s.occurrenceId), [
        'trip-return-first',
        'trip-return-repeat',
      ]);
      await expectLater(
        repo.arriveAtStop('trip-return', 4),
        throwsA(isA<ApiException>()),
      );
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.data, {
        'stopOccurrenceId': 'trip-return-repeat',
        'correction': false,
      });
      expect(adapter.requests.single.headers['If-Match'], '"trip:3"');
      expect(api.trips['trip-return']!.editToken, '"trip:3"');
    },
  );

  test(
    'manifest and photo/no-show results are reservation keyed; no-show riders stay visible',
    () async {
      final adapter = Adapter((o) {
        if (o.path.endsWith('/manifest')) {
          return (
            200,
            {
              'data': {
                'tripId': 'trip-1',
                'revision': '1',
                'generatedAt': at,
                'expiresAt': at,
                'complete': true,
                'riders': [
                  for (final status in [
                    'reserved',
                    'no_show',
                    'operator_cancelled',
                  ])
                    {
                      'reservationId': 'seat-$status',
                      'displayName': status,
                      'avatarUrl': null,
                      'status': status,
                      'pickupOccurrenceId': 'trip-1-first',
                      'dropoffOccurrenceId': 'trip-1-repeat',
                    },
                ],
              },
            },
          );
        }
        return (200, boarding('seat-no_show', replay: true));
      });
      final api = withAdapter(adapter);
      seedTrip(api, direction: 'return');
      final repo = TripsRepository(client: api);
      final rows = await repo.manifest('trip-1');
      expect(rows.map((r) => r.reservationId), [
        'seat-reserved',
        'seat-no_show',
      ]);
      expect(rows.last.noShow, isTrue);
      expect(rows.first.directionLabel, 'Return');
      expect(rows.first.source, isNull);
      final result = await repo.boardFromManifest('seat-no_show');
      expect(result.reservationId, 'seat-no_show');
      expect(result.outcome, BoardingOutcome.alreadyBoarded);
      expect(adapter.requests.last.data, {
        'kind': 'photo',
        'reservationId': 'seat-no_show',
      });
      expect(
        await repo.markNoShow('seat-no_show'),
        NoShowResult.alreadyBoarded,
      );
      expect(
        adapter.requests.last.path,
        '/v1/driver/trips/trip-1/reservations/seat-no_show/no-show',
      );
    },
  );

  test(
    'code and QR retain their distinct proofs and accept only server reservation identity',
    () async {
      final adapter = Adapter((_) => (200, boarding('server-seat')));
      final repo = TripsRepository(client: withAdapter(adapter));
      final code = await repo.boardByCodeOnRun(runId: 'trip-1', code: 'abcd');
      final qr = await repo.scan(runId: 'trip-1', pass: 'signed-pass');
      expect(code.reservationId, 'server-seat');
      expect(qr.reservationId, 'server-seat');
      expect(adapter.requests.map((r) => r.data), [
        {'kind': 'code', 'code': 'ABCD'},
        {'kind': 'qr', 'token': 'signed-pass'},
      ]);
    },
  );

  test(
    'route change and leave unions decode without restoring legacy flat fields',
    () async {
      final adapter = Adapter(
        (o) => (
          201,
          {
            'data': {
              'id': 'request-1',
              'request': o.data,
              'status': 'pending',
              'decisionNote': null,
              'createdAt': at,
              'updatedAt': at,
              'version': 1,
            },
          },
        ),
      );
      final repo = WorkRepository(client: withAdapter(adapter));
      final route = await repo.requestRouteChange(
        routeId: 'route-1',
        fromDate: '2026-09-20',
      );
      final leave = await repo.requestLeave(
        fromDate: '2026-09-21',
        toDate: '2026-09-23',
        note: ' Leave ',
      );
      expect(route.kind, RequestKind.routeChange);
      expect(route.routeId, 'route-1');
      expect(route.fromDate, '2026-09-20');
      expect(route.decidedAt, isNull);
      expect(leave.kind, RequestKind.leave);
      expect(leave.toDate, '2026-09-23');
      expect(leave.note, 'Leave');
      expect(leave.status, RequestStatus.pending);
    },
  );

  test(
    'route geometry is pinned to the assigned version, not the newest published revision',
    () async {
      final adapter = Adapter((o) {
        if (o.path == '/v1/routes/route-1') {
          return (
            404,
            {
              'error': {'code': 'not_found', 'message': 'Not current'},
            },
          );
        }
        if (o.path == '/v1/route-patterns/pattern-out') {
          return (
            200,
            {
              'data': {
                'id': 'pattern-out',
                'routeId': 'route-1',
                'direction': 'outbound',
                'publishedVersionId': 'version-new',
                'createdAt': at,
                'updatedAt': at,
                'version': 2,
              },
            },
          );
        }
        if (o.path == '/v1/route-patterns/pattern-out/versions/version-old') {
          return (
            200,
            {
              'data': {
                'id': 'version-old',
                'patternId': 'pattern-out',
                'revision': 1,
                'state': 'retired',
                'effectiveFrom': at,
                'effectiveTo': null,
                'stops': trip()['stops'],
                'geometryId': 'geometry-old',
                'editToken': '"version:1"',
                'createdAt': at,
                'updatedAt': at,
                'version': 1,
              },
            },
          );
        }
        if (o.path == '/v1/route-geometries/geometry-old') {
          return (
            200,
            {
              'data': {
                'id': 'geometry-old',
                'patternVersionId': 'version-old',
                'points': [
                  point,
                  {'latitude': 5.58, 'longitude': -0.20},
                ],
                'stopDistances': [],
                'source': 'configured',
                'createdAt': at,
              },
            },
          );
        }
        throw StateError('Unexpected ${o.path}');
      });
      final api = withAdapter(adapter);
      seedTrip(api);
      final shape = await RouteMapRepository(client: api).shapeFor('trip-1');
      expect(shape.source, RouteShapeSource.manual);
      expect(shape.followsRoads, isTrue);
      expect(shape.points, hasLength(2));
      expect(shape.runCount, isNull);
      expect(
        adapter.requests.any((r) => r.path.contains('version-new')),
        isFalse,
      );
      expect(shape.stops.map((s) => s.id), ['trip-1-first', 'trip-1-repeat']);
      expect(
        adapter.requests.any((r) => r.path == '/v1/routes/route-1'),
        isFalse,
      );
    },
  );

  for (final age in [30, 121]) {
    test(
      'live receipt age $age controls ETA availability, with occurrence identity and provenance',
      () async {
        final adapter = Adapter(
          (_) => (
            200,
            {
              'data': {
                'tripId': 'trip-1',
                'patternVersionId': 'version-old',
                'geometryId': null,
                'riderPickupOccurrenceId': null,
                'state': age > 30 ? 'stale' : 'live',
                'position': {
                  'location': point,
                  'capturedAt': at,
                  'receivedAt': at,
                  'ageSeconds': age,
                },
                'etas': [
                  {
                    'stopOccurrenceId': 'trip-1-repeat',
                    'durationSeconds': 90,
                    'distanceMeters': 400,
                    'basis': 'fallback',
                  },
                ],
                'serverTime': at,
              },
            },
          ),
        );
        final api = withAdapter(adapter);
        seedTrip(api);
        final fix = await RouteMapRepository(client: api).vehicleOn('trip-1');
        expect(fix, isNotNull);
        expect(fix!.age.inSeconds, age);
        expect(fix.receivedAt, DateTime.parse(at));
        if (age > 120) {
          expect(fix.etas, isEmpty);
        } else {
          expect(fix.etas.single.seq, 4);
          expect(fix.etas.single.summary, contains('fallback'));
        }
      },
    );
  }

  test('configuration floor applies only to this app and platform', () async {
    var body = bootstrap(app: 'commuter', floor: 9);
    final api = withAdapter(Adapter((_) => (200, body)));
    final repo = ConfigRepository(client: api);
    await repo.load();
    expect(api.upgradeRequired.value, isFalse);
    body = bootstrap(platform: 'ios', floor: 9);
    await repo.load();
    expect(api.upgradeRequired.value, isFalse);
    body = bootstrap(floor: 2);
    final config = await repo.load();
    expect(api.upgradeRequired.value, isTrue);
    expect(config.operations.phone, '+233200000000');
  });

  test(
    '426 blocks the app without refreshing or clearing its session',
    () async {
      final adapter = Adapter(
        (_) => (
          426,
          {
            'error': {'code': 'upgrade_required', 'message': 'Update'},
          },
        ),
      );
      final api = withAdapter(adapter);
      await api.store.saveTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
      );
      await expectLater(
        TripsRepository(client: api).myRuns(),
        throwsA(isA<UpgradeRequiredException>()),
      );
      expect(api.upgradeRequired.value, isTrue);
      expect(adapter.requests, hasLength(1));
      expect(await api.store.getRefreshToken(), 'refresh');
    },
  );

  test(
    'a delayed previous-session response cannot populate the next session trip cache',
    () async {
      final entered = Completer<void>();
      final release = Completer<void>();
      final api = withAdapter(
        Adapter((_) async {
          entered.complete();
          await release.future;
          return (200, page([trip()]));
        }),
      );
      final pending = api.assigned();
      final checked = expectLater(
        pending,
        throwsA(isA<UnauthorizedException>()),
      );
      await entered.future;
      await api.store.saveTokens(
        accessToken: 'new',
        refreshToken: 'new-refresh',
      );
      release.complete();
      await checked;
      expect(api.trips, isEmpty);
    },
  );

  test(
    'legacy flat responses fail closed instead of becoming empty successful lists',
    () async {
      final api = withAdapter(Adapter((_) => (200, [trip()])));
      await expectLater(api.assigned(), throwsA(isA<ApiException>()));
    },
  );

  test('426 during token refresh reaches the admission gate too', () async {
    final adapter = Adapter(
      (o) => o.path == '/v1/auth/refresh'
          ? (
              426,
              {
                'error': {'code': 'upgrade_required', 'message': 'Update'},
              },
            )
          : (
              401,
              {
                'error': {'code': 'unauthorized', 'message': 'Expired'},
              },
            ),
    );
    final api = withAdapter(adapter);
    await api.store.saveTokens(accessToken: 'access', refreshToken: 'refresh');
    await expectLater(api.assigned(), throwsA(isA<UpgradeRequiredException>()));
    expect(api.upgradeRequired.value, isTrue);
    expect(adapter.requests.map((r) => r.path), [
      '/v1/driver/trips',
      '/v1/auth/refresh',
    ]);
    expect(await api.store.getRefreshToken(), 'refresh');
  });

  test(
    'an identity switch during request admission prevents transmission under the new login',
    () async {
      final adapter = Adapter((_) => (200, page([trip()])));
      final api = withAdapter(adapter);
      final pending = api.assigned();
      final checked = expectLater(
        pending,
        throwsA(isA<UnauthorizedException>()),
      );
      await api.store.saveTokens(
        accessToken: 'new',
        refreshToken: 'new-refresh',
      );
      await checked;
      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'a background roster refresh cannot substitute the edit token the driver actually saw',
    () async {
      final adapter = Adapter(
        (_) => (
          412,
          {
            'error': {'code': 'precondition_failed', 'message': 'Reload'},
          },
        ),
      );
      final api = withAdapter(adapter);
      seedTrip(api);
      await expectLater(
        TripsRepository(
          client: api,
        ).arriveAtStop('trip-1', 0, editToken: '"trip:2"'),
        throwsA(isA<ApiException>()),
      );
      expect(adapter.requests.single.headers['If-Match'], '"trip:2"');
      expect((adapter.requests.single.data as Map)['correction'], isFalse);
    },
  );
}
