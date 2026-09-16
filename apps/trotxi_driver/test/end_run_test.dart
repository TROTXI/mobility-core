import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/Presentations/Completion/pages/end_run_page.dart';
import 'package:trotxi_driver/Presentations/Completion/pages/run_summary_page.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

DriverRun _run(RunStatus status) => DriverRun(
  id: 'trip-1',
  routeId: 'route-1',
  routeName: 'Circle → Madina',
  scheduledAt: DateTime.utc(2026, 9, 13),
  status: status,
);

class _Trips implements TripsRepository {
  bool failCompletion = true;
  bool failRefresh = false;
  @override
  Future<DriverRun> complete(String runId) async {
    if (failCompletion) throw const OfflineException();
    return _run(RunStatus.completed);
  }

  @override
  Future<List<ManifestRider>> manifest(String runId) async => [];
  @override
  Future<List<DriverStop>> stopsFor(String routeId) async => [
    const DriverStop(seq: 0, name: 'Circle'),
  ];
  @override
  Future<TripDetail> detail(String runId) async {
    if (failRefresh) throw const OfflineException();
    return const TripDetail(stopCount: 1);
  }

  @override
  Future<RunSummary> summary(String runId) async => const RunSummary(
    boarded: 0,
    notBoarded: 0,
    byQr: 0,
    byPin: 0,
    byPhoto: 0,
    stopCount: 1,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('completion failure returns false and retains the active run', () async {
    final trips = _Trips();
    final controller = RunController(trips: trips, run: _run(RunStatus.active));
    await controller.load();
    expect(await controller.complete(), isFalse);
    expect(controller.detail.valueOrNull?.run.status, RunStatus.active);
    controller.dispose();
  });

  test(
    'accepted completion survives a failed subsequent detail refresh',
    () async {
      final trips = _Trips()..failCompletion = false;
      final controller = RunController(
        trips: trips,
        run: _run(RunStatus.active),
      );
      await controller.load();
      trips.failRefresh = true;
      expect(await controller.complete(), isTrue);
      expect(controller.detail.valueOrNull?.run.status, RunStatus.completed);
      controller.dispose();
    },
  );

  testWidgets(
    'failed completion stays on checklist and a successful retry opens summary',
    (tester) async {
      final trips = _Trips();
      final controller = RunController(
        trips: trips,
        run: _run(RunStatus.active),
      );
      await controller.load();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TripsRepository>.value(value: trips),
            ChangeNotifierProvider<RunController>.value(value: controller),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const EndRunPage(),
          ),
        ),
      );
      for (final text in [
        'Vehicle safely parked',
        'All passengers exited',
        'No items left onboard',
        'Trip records reviewed',
      ]) {
        await tester.scrollUntilVisible(find.text(text), 200);
        await tester.tap(find.text(text));
        await tester.pump();
      }
      await tester.scrollUntilVisible(find.text('END TRIP'), 200);
      await tester.tap(find.text('END TRIP'));
      await tester.pumpAndSettle();
      expect(find.byType(EndRunPage), findsOneWidget);
      expect(find.byType(RunSummaryPage), findsNothing);
      expect(find.text('No internet connection.'), findsOneWidget);
      // Let the error snackbar clear the bottom action before retrying.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      trips.failCompletion = false;
      await tester.tap(find.text('END TRIP'));
      await tester.pumpAndSettle();
      expect(find.byType(RunSummaryPage), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );
}
