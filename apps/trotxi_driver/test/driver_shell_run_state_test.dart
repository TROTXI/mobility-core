import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/Presentations/Run/pages/run_page.dart';
import 'package:trotxi_driver/Presentations/Shell/pages/driver_shell.dart';
import 'package:trotxi_driver/Presentations/Shell/widgets/driver_nav.dart';
import 'package:trotxi_driver/core/state/config_controller.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/core/state/today_controller.dart';
import 'package:trotxi_driver/data/config_repository.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';
import 'package:trotxi_driver/data/position_publisher.dart';
import 'package:trotxi_driver/data/route_map_repository.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

class _Auth implements DriverAuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Client implements DriverApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Config implements ConfigRepository {
  @override
  Future<AppConfig> load() async => AppConfig.empty;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Maps implements RouteMapRepository {
  @override
  Future<RouteShape> shapeFor(String routeId) async => const RouteShape(
    points: [],
    stops: [],
    source: RouteShapeSource.stops,
    runCount: 0,
  );

  @override
  Future<VehicleFix?> vehicleOn(String runId) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Trips implements TripsRepository {
  DriverRun run = DriverRun(
    id: 'trip-1',
    routeId: 'route-1',
    routeName: 'Circle → Madina',
    scheduledAt: DateTime.utc(2026, 9, 13, 6, 30),
    status: RunStatus.scheduled,
  );

  @override
  Future<List<DriverRun>> myRuns({
    String? date,
    String? from,
    String? to,
  }) async => [run];

  @override
  Future<List<ManifestRider>> manifest(String runId) async => [];

  @override
  Future<List<DriverStop>> stopsFor(String routeId) async => const [
    DriverStop(seq: 0, name: 'Circle'),
    DriverStop(seq: 1, name: 'Madina'),
  ];

  @override
  Future<TripDetail> detail(String runId) async =>
      const TripDetail(stopCount: 2, vehicleRegistration: 'GT 4821-22');

  @override
  Future<DriverRun> start(String runId) async {
    run = DriverRun(
      id: run.id,
      routeId: run.routeId,
      routeName: run.routeName,
      scheduledAt: run.scheduledAt,
      status: RunStatus.active,
    );
    return run;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'accepted start enables Scan without waiting for Today to refresh',
    (tester) async {
      final trips = _Trips();
      final today = TodayController(
        trips: trips,
        now: () => DateTime.utc(2026, 9, 13, 5),
      );
      await today.load();
      expect(today.board.valueOrNull?.next?.status, RunStatus.scheduled);
      final positions = PositionPublisher(client: _Client());
      addTearDown(positions.dispose);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TripsRepository>.value(value: trips),
            ChangeNotifierProvider<TodayController>.value(value: today),
            ChangeNotifierProvider(create: (_) => AppThemeController()),
            ChangeNotifierProvider(
              create: (_) => ConfigController(config: _Config()),
            ),
            ChangeNotifierProvider<PositionPublisher>.value(value: positions),
            Provider<RouteMapRepository>.value(value: _Maps()),
            ChangeNotifierProvider(
              create: (_) => SessionController(auth: _Auth()),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DriverShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trip'));
      await tester.pumpAndSettle();
      expect(find.byType(RunPage), findsOneWidget);
      expect(tester.widget<DriverNav>(find.byType(DriverNav)).canScan, isFalse);

      final runContext = tester.element(find.byType(RunPage));
      final runController = Provider.of<RunController>(
        runContext,
        listen: false,
      );
      await runController.start();
      await tester.pumpAndSettle();

      // The Today board deliberately remains stale to reproduce the device
      // transition that exposed this bug during the acceptance walkthrough.
      expect(today.board.valueOrNull?.next?.status, RunStatus.scheduled);
      final nav = tester.widget<DriverNav>(find.byType(DriverNav));
      expect(nav.canScan, isTrue);
      expect(nav.tripHasAlert, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
