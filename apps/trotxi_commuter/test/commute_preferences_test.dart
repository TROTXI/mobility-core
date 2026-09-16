import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/commuter_preference.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'package:trotxi_commuter/core/repositories/commute_repository.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'replacement_fixture.dart';

void main() {
  late Fixture f;
  late List<Map<String, Object?>> requests;
  late List<RequestOptions> writes;
  bool failed = false;
  Map<String, Object?> route() => {
    'id': 'route',
    'name': 'New corridor',
    'description': null,
    // These published schedule owners are not in today's route projection.
    'patternIds': <String>[],
    'acceptsDriverRequests': false,
    'archived': false,
    'editToken': 'route:1',
    'createdAt': timestamp,
    'updatedAt': timestamp,
    'version': 1,
  };
  Map<String, Object?> schedule(String dir) => {
    'id': 'schedule-$dir',
    'departureId': 'departure-$dir',
    'patternId': dir,
    'patternVersionId': 'version-$dir',
    'serviceWindow': dir == 'outbound' ? 'morning' : 'evening',
    'localDeparture': dir == 'outbound' ? '06:30' : '17:30',
    'timeZone': 'Africa/Accra',
    'weekdays': [1, 2, 3, 4, 5],
    'effectiveFrom': '2026-01-01',
    'effectiveTo': null,
    'createdAt': timestamp,
    'updatedAt': timestamp,
    'version': 1,
  };
  Map<String, Object?> version(String dir) => {
    'id': 'version-$dir',
    'patternId': dir,
    'revision': 1,
    'state': 'retired',
    'effectiveFrom': timestamp,
    'effectiveTo': null,
    'geometryId': null,
    'editToken': 'v:1',
    'createdAt': timestamp,
    'updatedAt': timestamp,
    'version': 1,
    'stops': [
      for (var i = 0; i < 3; i++)
        {
          'id': '$dir-visit-$i',
          'stopId': i == 1 ? 'office' : 'physical-home',
          'ordinal': i * 10,
          'name': i == 1 ? 'Office' : 'Home',
          'location': {'latitude': 5.6, 'longitude': -.1},
        },
    ],
  };
  Map<String, Object?> request({
    String status = 'submitted',
    bool paused = false,
    Map<String, dynamic>? input,
  }) => {
    'id': 'request',
    'status': status,
    'paused': paused,
    'effectiveDate': null,
    'requested':
        input ??
        {
          'routeId': 'route',
          'legs': [
            for (final dir in ['outbound', 'return'])
              {
                'direction': dir,
                'scheduleId': 'schedule-$dir',
                'patternVersionId': 'version-$dir',
                'pickupOccurrenceId': '$dir-visit-0',
                'dropoffOccurrenceId': '$dir-visit-1',
              },
          ],
          'requestedDate': '2026-09-21',
          'pauseIfWaitlisted': paused,
        },
    'decisionNote': 'Operations is reviewing availability',
    'createdAt': timestamp,
    'updatedAt': timestamp,
    'version': 1,
  };

  setUp(() {
    f = Fixture();
    // These widget cases exercise the real generated contract, not the OS
    // session queue across fake clocks. Root/session tests retain real auth.
    f.transport.dio.interceptors.removeWhere((i) => i is wire.AuthInterceptor);
    requests = [];
    writes = [];
    failed = false;
    f.reply = (o) {
      if (failed) {
        throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
        );
      }
      if (o.method == 'POST') {
        writes.add(o);
        requests = [
          request(
            status: o.path.endsWith('/withdraw') ? 'cancelled' : 'submitted',
            input: o.path.endsWith('/withdraw') ? null : bodyOf(o),
          ),
        ];
        return jsonResponse({
          'data': requests.single,
        }, o.path.endsWith('/withdraw') ? 200 : 201);
      }
      if (o.path == '/v1/me/commute-requests') {
        return jsonResponse(page(requests));
      }
      if (o.path == '/v1/routes') return jsonResponse(page([route()]));
      if (o.path == '/v1/routes/route/schedules') {
        return jsonResponse(page([schedule('outbound'), schedule('return')]));
      }
      for (final dir in ['outbound', 'return']) {
        if (o.path == '/v1/route-patterns/$dir') {
          return jsonResponse({
            'data': {
              'id': dir,
              'routeId': 'route',
              'direction': dir,
              'publishedVersionId': 'newer-$dir',
              'createdAt': timestamp,
              'updatedAt': timestamp,
              'version': 1,
            },
          });
        }
        if (o.path == '/v1/route-patterns/$dir/versions/version-$dir') {
          return jsonResponse({'data': version(dir)});
        }
      }
      return jsonResponse({
        'error': {'code': 'not_found', 'message': 'No such version'},
      }, 404);
    };
  });
  Future<void> pumpPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: CommutePreferencesPage(client: f.api),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester) async {
    await tester.tap(find.text('Choose route'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New corridor'));
    await tester.pumpAndSettle();
    expect(find.text('Choose outbound departure'), findsOneWidget);
    await tester.tap(find.text('06:30 · Africa/Accra'));
    await tester.pumpAndSettle();
    expect(
      find.text('Home'),
      findsOneWidget,
    ); // Last loop visit cannot be pickup.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Office'));
    await tester.pumpAndSettle();
    expect(find.text('Choose return departure'), findsOneWidget);
    await tester.tap(find.text('17:30 · Africa/Accra'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Office'));
    await tester.pumpAndSettle();
    expect(find.text('Office'), findsNothing); // Only downstream occurrences.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'sends two scheduled occurrence legs, not physical IDs or arbitrary times',
    (tester) async {
      await pumpPage(tester);
      await choose(tester);
      final send = find.text('Send request to operations');
      await tester.ensureVisible(send);
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(writes, hasLength(1));
      final body = bodyOf(writes.single);
      expect(writes.single.path, '/v1/me/commute-requests');
      expect(body['pauseIfWaitlisted'], isFalse);
      expect(body.containsKey('morningDeparture'), isFalse);
      expect(body['legs'], [
        {
          'direction': 'outbound',
          'scheduleId': 'schedule-outbound',
          'patternVersionId': 'version-outbound',
          'pickupOccurrenceId': 'outbound-visit-0',
          'dropoffOccurrenceId': 'outbound-visit-1',
        },
        {
          'direction': 'return',
          'scheduleId': 'schedule-return',
          'patternVersionId': 'version-return',
          'pickupOccurrenceId': 'return-visit-1',
          'dropoffOccurrenceId': 'return-visit-2',
        },
      ]);
      expect(find.text('New corridor — submitted'), findsOneWidget);
      expect(find.text('Send request to operations'), findsNothing);
    },
  );

  testWidgets('paused waitlist shows preservation and no withdrawal', (
    tester,
  ) async {
    requests = [request(status: 'waitlisted', paused: true)];
    await pumpPage(tester);
    expect(find.text('New corridor — waitlisted'), findsOneWidget);
    expect(
      find.textContaining('Rides and remaining paid time are preserved'),
      findsOneWidget,
    );
    expect(find.text('Withdraw request'), findsNothing);
    expect(writes, isEmpty);
  });

  testWidgets('withdrawal requires confirmation and reloads retained history', (
    tester,
  ) async {
    requests = [request()];
    await pumpPage(tester);
    await tester.tap(find.text('Withdraw request'));
    await tester.pumpAndSettle();
    expect(writes, isEmpty);
    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();
    expect(writes.single.path, '/v1/me/commute-requests/request/withdraw');
    expect(find.text('New corridor — cancelled'), findsOneWidget);
    expect(find.text('Choose route'), findsOneWidget);
  });

  testWidgets('offline load shows refresh and never claims local success', (
    tester,
  ) async {
    failed = true;
    await pumpPage(tester);
    expect(find.textContaining('Connection unavailable'), findsOneWidget);
    expect(writes, isEmpty);
    failed = false;
    await tester.tap(find.text('Refresh requests'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Connection unavailable'), findsNothing);
  });

  test('replacement decision conflicts keep the server message', () {
    expect(
      commuteError(const ApiException(409, 'Resume before withdrawing')),
      'Resume before withdrawing',
    );
  });
}
