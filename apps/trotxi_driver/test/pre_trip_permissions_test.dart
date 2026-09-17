import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/Presentations/Readiness/pages/device_readiness_page.dart';
import 'package:trotxi_driver/Presentations/Run/pages/run_page.dart';
import 'package:trotxi_driver/Presentations/Today/pages/today_page.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/state/today_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

class _UnusedClient implements DriverApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Trips implements TripsRepository {
  final run = DriverRun(
    id: 'trip-1',
    routeId: 'route-1',
    routeName: 'Madina → Circle',
    scheduledAt: DateTime.now().add(const Duration(hours: 1)),
    status: RunStatus.scheduled,
  );
  int starts = 0;
  @override
  Future<List<DriverRun>> myRuns({
    String? date,
    String? from,
    String? to,
  }) async => [run];
  @override
  Future<List<ManifestRider>> manifest(String runId) async => [];
  @override
  Future<List<DriverStop>> stopsFor(String routeId) async => [
    DriverStop(seq: 0, name: 'Madina'),
    DriverStop(seq: 1, name: 'Circle'),
  ];
  @override
  Future<TripDetail> detail(String runId) async =>
      const TripDetail(stopCount: 2);
  @override
  Future<DriverRun> start(String runId) async {
    starts++;
    // Exercise the real controller's offline recovery after it reaches the API
    // boundary. This test does not launch the unrelated native map renderer.
    throw const OfflineException();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'Today cannot bypass readiness; location gates the actual start call',
    (tester) async {
      const permissions = MethodChannel(
        'flutter.baseflow.com/permissions/methods',
      );
      const location = MethodChannel('flutter.baseflow.com/geolocator');
      var locationAllowed = false;
      var servicesEnabled = true;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(permissions, (call) async {
        expect(call.method, 'checkPermissionStatus'); // Opening never prompts.
        return call.arguments == Permission.locationWhenInUse.value &&
                locationAllowed
            ? PermissionStatus.granted.index
            : PermissionStatus.denied.index;
      });
      messenger.setMockMethodCallHandler(location, (call) async {
        expect(call.method, 'isLocationServiceEnabled');
        return servicesEnabled;
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(permissions, null);
        messenger.setMockMethodCallHandler(location, null);
      });
      final trips = _Trips();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TripsRepository>.value(value: trips),
            Provider<DriverApi>.value(value: _UnusedClient()),
            ChangeNotifierProvider(
              create: (_) => TodayController(trips: trips),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: TodayPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start trip'));
      await tester.pumpAndSettle();
      expect(find.byType(RunPage), findsOneWidget);
      expect(trips.starts, 0);
      await tester.scrollUntilVisible(
        find.text('Start trip'),
        250,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Start trip'));
      await tester.pumpAndSettle();
      expect(find.byType(DeviceReadinessPage), findsOneWidget);
      expect(trips.starts, 0);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Start trip'),
            )
            .onPressed,
        isNull,
      );
      locationAllowed = true;
      servicesEnabled = false;
      await tester.ensureVisible(find.text('Check again'));
      await tester.tap(find.text('Check again'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Start trip'),
            )
            .onPressed,
        isNull,
      );
      expect(trips.starts, 0);
      servicesEnabled = true;
      await tester.ensureVisible(find.text('Check again'));
      await tester.tap(find.text('Check again'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Start with code boarding'));
      await tester.tap(find.text('Start with code boarding'));
      await tester.pumpAndSettle();
      expect(trips.starts, 1);
      expect(find.byType(DeviceReadinessPage), findsNothing);
      expect(find.byType(RunPage), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
