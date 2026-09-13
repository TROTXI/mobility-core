import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/Presentations/Completion/pages/run_summary_page.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

const _at = '2026-09-13T06:30:00.000Z';

/// Exercise the real generated serializers and repository, without a network.
TripsRepository _repository(List<RequestOptions> requests) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        final Object data;
        switch (options.path) {
          case '/routes/route-1':
            data = {
              'id': 'route-1', 'name': 'Circle → Madina',
              'acceptsRequests': false, 'createdAt': _at,
              // Deliberately unsorted, zero-based and non-contiguous.
              'stops': [
                for (final (seq, name) in [
                  (7, 'Madina'),
                  (0, 'Circle'),
                  (2, 'Nima'),
                ])
                  {
                    'id': 'stop-$seq',
                    'name': name,
                    'seq': seq,
                    'latitude': 5.57,
                    'longitude': -0.21,
                    'createdAt': _at,
                  },
              ],
            };
          case '/trips/trip-1/arrive':
            data = {
              'id': 'trip-1',
              'routeId': 'route-1',
              'status': 'active',
              'scheduledAt': _at,
              'createdAt': _at,
              'currentStopSeq': (options.data as Map)['seq'],
            };
          case '/trips/trip-1':
            data = {
              'id': 'trip-1',
              'routeId': 'route-1',
              'status': 'completed',
              'scheduledAt': _at,
              'createdAt': _at,
              'stopCount': 3,
            };
          case '/boarding/manifest':
            data = {'tripId': 'trip-1', 'riders': []};
          case '/trips/trip-1/summary':
            data = {
              'tripId': 'trip-1',
              'boarded': 3,
              'notBoarded': 1,
              'byMethod': {'qr': 1, 'pin': 1, 'photo': 1},
              'stopCount': 3,
            };
          default:
            throw StateError(
              'Unexpected request ${options.method} ${options.path}',
            );
        }
        handler.resolve(
          Response(requestOptions: options, statusCode: 200, data: data),
        );
      },
    ),
  );
  return TripsRepository(
    client: TrotxiApiClient(dio: dio, interceptors: []),
  );
}

void main() {
  test(
    'route decoding retains real sequences and arrival sends them unchanged',
    () async {
      final requests = <RequestOptions>[];
      final repository = _repository(requests);
      final stops = await repository.stopsFor('route-1');
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
        requests.where((r) => r.path.endsWith('/arrive')).map((r) => r.data),
        [
          {'seq': 0},
          {'seq': 2},
          {'seq': 7},
        ],
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
        final repository = _repository([]);
        final controller = RunController(
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
        await tester.runAsync(controller.load);
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
