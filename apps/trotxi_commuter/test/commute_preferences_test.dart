import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/commuter_preference.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'package:trotxi_commuter/core/repositories/commute_repository.dart';

void main() {
  late Dio dio;
  late TrotxiApiClient client;
  late List<Map<String, dynamic>> requests;
  late List<RequestOptions> writes;
  bool failed = false;
  final route = {
    'id': 'route',
    'name': 'New corridor',
    'acceptsRequests': true,
    'createdAt': '2026-01-01T00:00:00Z',
    'description': null,
  };
  Map<String, dynamic> request({
    String status = 'pending',
    bool paused = false,
  }) => {
    'id': 'request',
    'routeName': 'New corridor',
    'status': status,
    'paused': paused,
    'requestedDate': '2026-09-15',
    'effectiveDate': null,
    'decisionNote': 'Operations is reviewing availability',
  };
  setUp(() {
    requests = [];
    writes = [];
    failed = false;
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (failed) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
            return;
          }
          Object data;
          if (options.method == 'POST') {
            writes.add(options);
            if (options.path.endsWith('/withdraw')) {
              requests = [];
            } else {
              requests = [request()];
            }
            data = {'id': 'request'};
          } else if (options.path == '/routes') {
            data = [route];
          } else if (options.path == '/routes/route') {
            data = {
              ...route,
              'stops': [
                for (final (id, name, seq) in [
                  ('home', 'Home', 0),
                  ('office', 'Office', 4),
                  ('last', 'Last stop', 9),
                ])
                  {
                    'id': id,
                    'name': name,
                    'seq': seq,
                    'latitude': 5.6,
                    'longitude': -.1,
                    'createdAt': '2026-01-01T00:00:00Z',
                  },
              ],
            };
          } else {
            data = {'requests': requests};
          }
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: data),
          );
        },
      ),
    );
    client = TrotxiApiClient(dio: dio);
  });
  Future<void> page(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: CommutePreferencesPage(client: client),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> chooseRoute(WidgetTester tester) async {
    await tester.tap(find.text('Choose route'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New corridor'));
    await tester.pumpAndSettle();
    expect(
      find.text('Last stop'),
      findsNothing,
    ); // Cannot board at the final stop.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsNothing); // Only downstream destinations.
    await tester.tap(find.text('Office'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'submits route and stop IDs, default no-pause consent, and keeps pending status visible',
    (tester) async {
      await page(tester);
      await chooseRoute(tester);
      final send = find.text('Send request to operations');
      await tester.ensureVisible(send);
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(writes, hasLength(1));
      expect(writes.single.data, containsPair('routeId', 'route'));
      expect(writes.single.data, containsPair('pickupStopId', 'home'));
      expect(writes.single.data, containsPair('dropoffStopId', 'office'));
      expect(writes.single.data, containsPair('pauseIfWaitlisted', false));
      expect(writes.single.data, containsPair('morningDeparture', '06:30'));
      expect(find.text('New corridor — pending'), findsOneWidget);
      expect(find.text('Send request to operations'), findsNothing);
      expect(find.text('Preferences saved on this device.'), findsNothing);
    },
  );
  testWidgets(
    'paused waitlist shows preservation and does not offer withdrawal',
    (tester) async {
      requests = [request(status: 'waitlisted', paused: true)];
      await page(tester);
      expect(find.text('New corridor — waitlisted'), findsOneWidget);
      expect(
        find.textContaining('Rides and remaining paid time are preserved'),
        findsOneWidget,
      );
      expect(find.text('Withdraw request'), findsNothing);
      expect(writes, isEmpty);
    },
  );
  testWidgets('withdrawal requires confirmation and refreshes from API', (
    tester,
  ) async {
    requests = [request()];
    await page(tester);
    await tester.tap(find.text('Withdraw request'));
    await tester.pumpAndSettle();
    expect(writes, isEmpty);
    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();
    expect(writes.single.path, '/me/commute-requests/request/withdraw');
    expect(find.text('Choose route'), findsOneWidget);
  });
  testWidgets(
    'offline load displays retry and never claims a request was saved',
    (tester) async {
      failed = true;
      await page(tester);
      expect(find.textContaining('Connection unavailable'), findsOneWidget);
      expect(writes, isEmpty);
      failed = false;
      await tester.tap(find.text('Refresh requests'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Connection unavailable'), findsNothing);
    },
  );
  test('server decision conflicts are actionable', () {
    final options = RequestOptions(path: '/me/commute-requests');
    expect(
      commuteError(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 409,
            data: {'message': 'Resume before withdrawing'},
          ),
        ),
      ),
      'Resume before withdrawing',
    );
  });
}
