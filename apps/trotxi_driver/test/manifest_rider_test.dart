import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

ManifestRider _rider({
  String id = 'r1',
  bool boarded = false,
  bool noShow = false,
  String source = 'confirmation',
  String direction = 'morning',
}) => ManifestRider(
  reservationId: id,
  userId: 'u-$id',
  name: 'Ama Owusu',
  avatarUrl: null,
  boarded: boarded,
  direction: direction,
  source: source,
  noShow: noShow,
);

DriverRun _run({int? currentStopSeq, DateTime? changedAt}) => DriverRun(
  id: 't1',
  routeId: 'route-1',
  routeName: 'Circle to Madina',
  scheduledAt: DateTime.utc(2026, 10, 15, 6, 30),
  status: RunStatus.active,
  currentStopSeq: currentStopSeq,
  assignmentChangedAt: changedAt,
);

void main() {
  group('what the boarding counter counts against (#230)', () {
    test('uses the van’s seat ceiling when the API gives one', () {
      final detail = RunDetail(
        run: _run(),
        riders: [
          _rider(),
          _rider(id: 'r2', boarded: true),
        ],
        stops: const [
          DriverStop(seq: 0, name: 'A'),
          DriverStop(seq: 1, name: 'B'),
        ],
        capacity: 15,
      );

      expect(detail.ceiling, 15);
      expect(detail.hasCapacity, isTrue);
    });

    test('falls back to confirmed riders when no vehicle is assigned', () {
      // Not a lesser answer: a run with no van has no ceiling to show, and
      // "1 of 2 confirmed" is still the number that matters at a kerb.
      final detail = RunDetail(
        run: _run(),
        riders: [
          _rider(),
          _rider(id: 'r2', boarded: true),
        ],
        stops: const [
          DriverStop(seq: 0, name: 'A'),
          DriverStop(seq: 1, name: 'B'),
        ],
      );

      expect(detail.ceiling, 2);
      expect(detail.hasCapacity, isFalse);
    });
  });

  group('who is still waiting (#227)', () {
    test('a no-show is not waiting, but stays on the manifest', () {
      final detail = RunDetail(
        run: _run(),
        riders: [
          _rider(),
          _rider(id: 'r2', boarded: true),
          _rider(id: 'r3', noShow: true),
        ],
        stops: const [DriverStop(seq: 0, name: 'A')],
      );

      expect(detail.riders, hasLength(3));
      expect(detail.waiting.map((r) => r.reservationId), ['r1']);
      expect(detail.boarded, 1);
    });
  });

  group('the standby share (#230)', () {
    test('counts seats filled from the pool', () {
      final detail = RunDetail(
        run: _run(),
        riders: [
          _rider(),
          _rider(id: 'r2', source: 'standby'),
          _rider(id: 'r3', source: 'default'),
        ],
        stops: const [DriverStop(seq: 0, name: 'A')],
      );

      expect(detail.standby, 1);
    });
  });

  group('stop progress (#230)', () {
    test('is unknown before the driver reports an arrival', () {
      final detail = RunDetail(
        run: _run(),
        riders: const [],
        stops: const [
          DriverStop(seq: 0, name: 'Circle'),
          DriverStop(seq: 2, name: 'Nima'),
          DriverStop(seq: 7, name: 'Madina'),
        ],
      );

      // Null rather than 1. The API does not guess from GPS, and neither does
      // the screen: "Stop 1 of 3" before anyone said so is invented.
      expect(detail.currentStopSeq, isNull);
      expect(detail.currentStopName, isNull);
    });

    test('names the stop the driver reported', () {
      final detail = RunDetail(
        run: _run(currentStopSeq: 2),
        riders: const [],
        stops: const [
          DriverStop(seq: 0, name: 'Circle'),
          DriverStop(seq: 2, name: 'Nima'),
          DriverStop(seq: 7, name: 'Madina'),
        ],
      );

      expect(detail.currentStopName, 'Nima');
      expect(detail.currentStopNumber, 2);
    });

    test('survives a seq outside the stop list', () {
      // A vehicle swap or a route edit mid-run can leave the two disagreeing,
      // and a range error would take the whole screen down with it.
      final detail = RunDetail(
        run: _run(currentStopSeq: 9),
        riders: const [],
        stops: const [
          DriverStop(seq: 0, name: 'Circle'),
          DriverStop(seq: 2, name: 'Nima'),
        ],
      );

      expect(detail.currentStopName, isNull);
      expect(detail.currentStopNumber, isNull);
    });
    for (final firstSeq in [0, 1, 10]) {
      test('first and last stops use real sequence starting at $firstSeq', () {
        final stops = [
          DriverStop(seq: firstSeq, name: 'Circle'),
          DriverStop(seq: firstSeq + 5, name: 'Madina'),
        ];
        final first = RunDetail(
          run: _run(currentStopSeq: firstSeq),
          riders: const [],
          stops: stops,
        );
        final last = RunDetail(
          run: _run(currentStopSeq: firstSeq + 5),
          riders: const [],
          stops: stops,
        );
        expect(first.currentStopName, 'Circle');
        expect(first.currentStopNumber, 1);
        expect(last.currentStopName, 'Madina');
        expect(last.currentStopNumber, 2);
      });
    }
  });

  group('the CHANGED badge (#233)', () {
    test('is off on a run nobody has touched', () {
      expect(_run().wasRecentlyChanged, isFalse);
    });

    test('is on just after operations moves a run', () {
      final run = _run(
        changedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      expect(run.wasRecentlyChanged, isTrue);
    });

    test('clears once the change is old news', () {
      // A badge that never clears is one a driver stops reading, which would
      // cost them the one that matters.
      final run = _run(
        changedAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      expect(run.wasRecentlyChanged, isFalse);
    });
  });
}
