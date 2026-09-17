import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'support/replacement_client.dart';
import 'package:trotxi_driver/Presentations/Completion/pages/run_summary_page.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

const _at = '2026-09-13T06:30:00.000Z';

/// Exercise the replacement serializers and repository, without a network.
TripsRepository _repository(
  List<RequestOptions> requests, {
  bool authenticate = true,
}) {
  String? current;
  var version = 1;
  Map<String, Object?> trip() => {
    'id': 'trip-1',
    'departureId': 'departure-1',
    'patternId': 'pattern-out',
    'serviceDate': '2026-09-13',
    'runNumber': 1,
    'routeId': 'route-1',
    'patternVersionId': 'version-1',
    'direction': 'outbound',
    'scheduledAt': _at,
    'status': 'completed',
    'vehicleLabel': 'Bus 1',
    'startedAt': _at,
    'completedAt': _at,
    'currentStopOccurrenceId': current,
    'version': version,
    'editToken': '"trip:$version"',
    'stops': [
      for (final (seq, name) in [(7, 'Madina'), (0, 'Circle'), (2, 'Nima')])
        {
          'id': 'occurrence-$seq',
          'stopId': 'stop-$seq',
          'name': name,
          'ordinal': seq,
          'location': {'latitude': 5.57, 'longitude': -0.21},
        },
    ],
  };
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) {
        requests.add(o);
        final Object data;
        switch (o.path) {
          case '/v1/routes/route-1':
            data = {
              'data': {
                'id': 'route-1',
                'name': 'Circle → Madina',
                'description': null,
                'patternIds': ['pattern-1'],
                'acceptsDriverRequests': false,
                'archived': false,
                'createdAt': _at,
                'updatedAt': _at,
                'version': 1,
                'editToken': '"route:1"',
              },
            };
          case '/v1/trips/trip-1':
            data = {'data': trip()};
          case '/v1/driver/trips':
            data = {
              'data': [trip()],
              'page': {'nextCursor': null},
            };
          case '/v1/driver/trips/trip-1/arrivals':
            current = (o.data as Map)['stopOccurrenceId'] as String;
            version++;
            data = {'data': trip()};
          case '/v1/driver/trips/trip-1/manifest':
            data = {
              'data': {
                'tripId': 'trip-1',
                'revision': '1',
                'generatedAt': _at,
                'expiresAt': _at,
                'complete': true,
                'riders': [],
              },
            };
          case '/v1/driver/trips/trip-1/summary':
            data = {
              'data': {
                'tripId': 'trip-1',
                'status': 'completed',
                'boarded': 3,
                'noShows': 1,
                'unseated': 0,
                'scanned': 1,
                'codeVerified': 1,
                'photoVerified': 1,
              },
            };
          default:
            throw StateError('Unexpected request ${o.method} ${o.path}');
        }
        h.resolve(Response(requestOptions: o, statusCode: 200, data: data));
      },
    ),
  );
  return TripsRepository(
    client: replacementClient(dio: dio, authenticate: authenticate),
  );
}

void main() {
  test(
    'trip stop ordinals stay ordered and arrival sends occurrence IDs with edit tokens',
    () async {
      final requests = <RequestOptions>[];
      final repository = _repository(requests);
      final stops = await repository.stopsFor('trip-1');
      expect(stops.map((s) => s.seq), [0, 2, 7]);
      expect(stops.map((s) => s.name), ['Circle', 'Nima', 'Madina']);
      for (final (index, stop) in stops.indexed) {
        final run = await repository.arriveAtStop('trip-1', stop.seq);
        final detail = RunDetail(run: run, riders: const [], stops: stops);
        expect(run.currentStopSeq, stop.seq);
        expect(detail.currentStopNumber, index + 1);
        expect(detail.currentStopName, stop.name);
      }
      expect(
        requests.where((r) => r.path.endsWith('/arrivals')).map((r) => r.data),
        [
          {'stopOccurrenceId': 'occurrence-0', 'correction': false},
          {'stopOccurrenceId': 'occurrence-2', 'correction': false},
          {'stopOccurrenceId': 'occurrence-7', 'correction': false},
        ],
      );
      expect(
        requests
            .where((r) => r.path.endsWith('/arrivals'))
            .map((r) => r.headers['If-Match']),
        ['"trip:1"', '"trip:2"', '"trip:3"'],
      );
    },
  );

  test('summary preserves every boarding method returned by the API', () async {
    final summary = await _repository([]).summary('trip-1');
    expect(summary.byQr, 1);
    expect(summary.byPin, 1);
    expect(summary.byPhoto, 1);
    expect(summary.byQr + summary.byPin + summary.byPhoto, summary.boarded);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'summary includes manifest boardings in $brightness without claiming a final GPS save',
      (tester) async {
        late TripsRepository repository;
        late RunController controller;
        await tester.runAsync(() async {
          repository = _repository([], authenticate: false);
          controller = RunController(
            trips: repository,
            run: DriverRun(
              id: 'trip-1',
              routeId: 'route-1',
              routeName: 'Circle → Madina',
              scheduledAt: DateTime.parse(_at),
              status: RunStatus.completed,
              currentStopSeq: 7,
            ),
          );
          await controller.load();
        });
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<TripsRepository>.value(value: repository),
              ChangeNotifierProvider<RunController>.value(value: controller),
            ],
            child: MaterialApp(
              theme: brightness == Brightness.dark
                  ? AppTheme.darkTheme
                  : AppTheme.lightTheme,
              home: const RunSummaryPage(),
            ),
          ),
        );
        await tester.runAsync(() async {
          // Allow the generated client's asynchronous response decoding to
          // complete outside the widget test's fake clock.
          await Future<void>.delayed(const Duration(milliseconds: 20));
        });
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.textContaining('from manifest'),
          200,
        );
        expect(
          find.text('1 scanned · 1 by code · 1 from manifest'),
          findsOneWidget,
        );
        expect(find.textContaining('final position'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        controller.dispose();
      },
    );
  }
}
