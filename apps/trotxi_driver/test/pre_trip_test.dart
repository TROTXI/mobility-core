import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/data/trips_repository.dart';
import 'package:trotxi_driver/Presentations/Run/widgets/pre_trip.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';

ManifestRider _rider({String id = 'r1', bool standby = false}) => ManifestRider(
  reservationId: id,
  name: 'Ama Owusu',
  avatarUrl: null,
  boarded: false,
  direction: 'morning',
  source: standby ? 'standby' : 'subscription',
  noShow: false,
);

RunDetail _detail({
  String? plate = 'GT 4821-22',
  List<DriverStop> stops = const [
    DriverStop(seq: 0, name: 'Madina'),
    DriverStop(seq: 1, name: 'Shiashie'),
    DriverStop(seq: 2, name: 'Circle'),
  ],
  int riders = 3,
  int standby = 1,
  DateTime? at,
}) => RunDetail(
  run: DriverRun(
    id: 't1',
    routeId: 'route-1',
    routeName: 'Madina → Circle',
    scheduledAt: at ?? DateTime.now().add(const Duration(minutes: 50)),
    status: RunStatus.scheduled,
  ),
  riders: [
    for (var i = 0; i < riders; i++) _rider(id: 'r$i', standby: i < standby),
  ],
  stops: stops,
  vehicleRegistration: plate,
);

Future<void> _pump(WidgetTester tester, RunDetail detail, {Brightness? b}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: b == Brightness.dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TripSummary(data: detail),
              const SizedBox(height: 12),
              ReadinessCard(data: detail),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('multi-hour lateness shows hours and minutes', (tester) async {
    await _pump(
      tester,
      _detail(
        at: DateTime.now().subtract(const Duration(hours: 14, minutes: 14)),
      ),
    );
    expect(find.text('14H 14MIN BEHIND SCHEDULE'), findsOneWidget);
    expect(find.textContaining('854 MIN'), findsNothing);
  });
  testWidgets('the check reports the run, not a fixed green', (tester) async {
    // The frames draw all three rows green. A pre-trip check that always says
    // ready is a decoration, and the morning it matters is the morning a van
    // was never assigned.
    await _pump(tester, _detail(plate: null));
    await tester.pump();

    expect(find.text('CHECK'), findsOneWidget);
    expect(find.text('READY'), findsNothing);
    expect(find.text('Not yet'), findsOneWidget);
  });

  testWidgets('a run with everything in place reads ready', (tester) async {
    await _pump(tester, _detail());
    await tester.pump();

    expect(find.text('READY'), findsOneWidget);
    expect(find.text('GT 4821-22'), findsOneWidget);
    // Once in the summary, once in the check.
    expect(find.text('3 stops'), findsNWidgets(2));
  });

  testWidgets('a departure already past is not still counted down to', (
    tester,
  ) async {
    // The common case at a depot, and the file draws only "DEPARTS IN 50 MIN".
    await _pump(
      tester,
      _detail(at: DateTime.now().subtract(const Duration(minutes: 7))),
    );
    await tester.pump();

    expect(find.textContaining('BEHIND SCHEDULE'), findsOneWidget);
    expect(find.textContaining('DEPARTS IN'), findsNothing);
  });

  testWidgets('confirmed total does not invent a standby breakdown', (
    tester,
  ) async {
    await _pump(tester, _detail(riders: 5, standby: 2));
    await tester.pump();

    expect(find.text('5 booked'), findsOneWidget);
    expect(find.textContaining('standby'), findsNothing);
    expect(find.text('5 riders'), findsNWidgets(2));
  });
}
