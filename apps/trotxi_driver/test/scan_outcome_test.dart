import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/Presentations/Boarding/models/scan_result.dart';
import 'package:trotxi_driver/Presentations/Boarding/widgets/scan_outcome.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

ManifestRider _rider(String id, {String? name, bool standby = false}) =>
    ManifestRider(
      reservationId: 'res-$id',
      userId: id,
      name: name ?? 'Rider $id',
      avatarUrl: null,
      boarded: false,
      direction: 'morning',
      source: standby ? 'standby' : 'confirmation',
      noShow: false,
    );

RunDetail _detail() => RunDetail(
  run: DriverRun(
    id: 't1',
    routeId: 'r1',
    routeName: 'Madina → Circle',
    scheduledAt: DateTime.utc(2026, 10, 15, 7, 40),
    status: RunStatus.active,
    currentStopSeq: 3,
  ),
  riders: [_rider('u1'), _rider('u2', name: 'Ama Owusu'), _rider('u3')],
  stops: const ['Madina', 'Shiashie', 'Circle', 'Kaneshie'],
);

Future<void> _pump(WidgetTester tester, BoardingResult result) {
  tester.view.physicalSize = const Size(390 * 3, 700 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 396),
          child: ScanOutcome(
            result: result,
            data: _detail(),
            tone: Colors.green,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('an accepted pass shows the manifest position, not a seat', (
    tester,
  ) async {
    // The file prints "SEAT 12A". Trotros do not assign seats (#229), and the
    // number shown has to be the same "#2" the manifest list shows or a driver
    // checking one against the other sees two different numbers.
    await _pump(
      tester,
      const BoardingResult(
        outcome: BoardingOutcome.ok,
        riderName: 'Ama Owusu',
        riderId: 'u2',
        deducted: true,
      ),
    );
    await tester.pump();

    expect(find.text('#2'), findsOneWidget);
    expect(find.textContaining('SEAT'), findsNothing);
    expect(find.text('Ama Owusu'), findsOneWidget);
    expect(find.text('1 deducted'), findsOneWidget);
    expect(find.text('Boarded at Circle · Stop 3 of 4'), findsOneWidget);
  });

  testWidgets('a rider off the manifest still boards, without a position', (
    tester,
  ) async {
    // The panel renders around missing manifest data rather than waiting for
    // it: the boarding already happened.
    await _pump(
      tester,
      const BoardingResult(
        outcome: BoardingOutcome.ok,
        riderName: 'Kofi Mensah',
        riderId: 'unknown',
        deducted: true,
      ),
    );
    await tester.pump();

    expect(find.text('Kofi Mensah'), findsOneWidget);
    expect(find.textContaining('#'), findsNothing);
  });

  testWidgets('a refusal keeps its own wording, not a shared one', (
    tester,
  ) async {
    // A dead session and a forged pass are opposite instructions, and the file
    // draws one exception frame for both.
    await _pump(
      tester,
      const BoardingResult(outcome: BoardingOutcome.sessionExpired),
    );
    await tester.pump();

    expect(find.text('Signed out'), findsOneWidget);
    expect(find.textContaining('Their pass is fine'), findsOneWidget);
  });

  testWidgets('an already-boarded rider is not an error', (tester) async {
    await _pump(
      tester,
      const BoardingResult(outcome: BoardingOutcome.alreadyBoarded),
    );
    await tester.pump();

    expect(find.text('Already boarded'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
