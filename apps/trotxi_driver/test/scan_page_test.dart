import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Boarding/models/scan_result.dart';
import 'package:trotxi_driver/Presentations/Boarding/pages/scan_page.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

class _Trips implements TripsRepository {
  String? scannedPass;
  String? scannedRunId;
  int manifestReads = 0;

  @override
  Future<List<ManifestRider>> manifest(String runId) async {
    manifestReads++;
    return [
      ManifestRider(
        reservationId: 'reservation-1',
        name: 'Ama Owusu',
        avatarUrl: 'https://images.example.test/riders/rider-1.jpg',
        boarded: manifestReads > 1,
        direction: 'morning',
        source: 'confirmation',
        noShow: false,
      ),
    ];
  }

  @override
  Future<List<DriverStop>> stopsFor(String routeId) async => const [
    DriverStop(seq: 0, name: 'Circle'),
    DriverStop(seq: 1, name: 'Madina'),
  ];

  @override
  Future<TripDetail> detail(String runId) async =>
      const TripDetail(stopCount: 2, vehicleRegistration: 'GT 4821-22');

  @override
  Future<BoardingResult> scan({
    required String pass,
    required String runId,
  }) async {
    scannedPass = pass;
    scannedRunId = runId;
    return const BoardingResult(
      outcome: BoardingOutcome.ok,
      riderName: 'Ama Owusu',
      reservationId: 'rider-1',
      deducted: true,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('decoded QR boards its rider and refreshes the manifest', (
    tester,
  ) async {
    final trips = _Trips();
    final controller = RunController(
      trips: trips,
      run: DriverRun(
        id: 'trip-1',
        routeId: 'route-1',
        routeName: 'Circle → Madina',
        scheduledAt: DateTime.utc(2026, 9, 13, 6, 30),
        status: RunStatus.active,
        currentStopSeq: 0,
      ),
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
          home: Scaffold(
            body: ScanPage(
              runId: 'trip-1',
              scannerBuilder: (_, onCode) => Center(
                child: ElevatedButton(
                  onPressed: () => onCode('signed-pass-123'),
                  child: const Text('Emit QR'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Emit QR'));
    await tester.pumpAndSettle();

    expect(trips.scannedPass, 'signed-pass-123');
    expect(trips.scannedRunId, 'trip-1');
    expect(trips.manifestReads, 2);
    expect(controller.detail.valueOrNull?.boarded, 1);
    expect(find.text('Ama Owusu'), findsOneWidget);
    expect(find.text('PASS ACCEPTED · BOARDED'), findsOneWidget);
    expect(find.text('Boarded at Circle · Stop 1 of 2'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
