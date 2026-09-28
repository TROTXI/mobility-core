// Today (frames 14 to 18). The states matter more than the list: nothing
// assigned and everything finished look alike in a naive build and read
// completely differently to a driver at the start of a shift.

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:trotxi_driver/core/state/loadable.dart';
import 'package:trotxi_driver/core/state/today_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

DriverRun _run(
  String id, {
  RunStatus status = RunStatus.scheduled,
  int hour = 6,
  DateTime? at,
}) {
  final now = DateTime.now().toUtc();
  return DriverRun(
    id: id,
    routeId: 'r1',
    routeName: 'Circle ⇄ Madina',
    scheduledAt: at ?? DateTime.utc(now.year, now.month, now.day, hour, 30),
    status: status,
  );
}

class _StubTrips implements TripsRepository {
  _StubTrips(this.runs);

  List<DriverRun> runs;
  String? lastDate;
  String? lastFrom;
  String? lastTo;
  bool filterDates = false;
  int manifestCalls = 0;
  int stopsCalls = 0;
  List<ManifestRider> riders = const [];
  List<DriverStop> stops = const [];
  Object? failWith;
  Future<List<DriverRun>>? pendingRuns;
  final started = <String>[];
  final completed = <String>[];

  @override
  Future<List<DriverRun>> myRuns({
    String? date,
    String? from,
    String? to,
  }) async {
    lastDate = date;
    lastFrom = from;
    lastTo = to;
    if (failWith != null) throw failWith!;
    final result = pendingRuns == null ? runs : await pendingRuns!;
    if (!filterDates) return result;
    return result.where((run) {
      final day = CorridorTime.day(run.scheduledAt);
      return day.compareTo(date ?? from!) >= 0 &&
          day.compareTo(date ?? to!) <= 0;
    }).toList();
  }

  @override
  Future<DriverRun> start(String runId) async {
    started.add(runId);
    runs = runs
        .map((r) => r.id == runId ? _run(r.id, status: RunStatus.active) : r)
        .toList();
    return runs.firstWhere((r) => r.id == runId);
  }

  @override
  Future<DriverRun> complete(String runId) async {
    completed.add(runId);
    runs = runs
        .map((r) => r.id == runId ? _run(r.id, status: RunStatus.completed) : r)
        .toList();
    return runs.firstWhere((r) => r.id == runId);
  }

  @override
  Future<List<ManifestRider>> manifest(String runId) async {
    manifestCalls++;
    return riders;
  }

  @override
  Future<List<DriverStop>> stopsFor(String routeId) async {
    stopsCalls++;
    return stops;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ManifestRider _rider({
  bool boarded = false,
  String direction = 'morning',
  String source = 'confirmation',
}) => ManifestRider(
  reservationId: 'r',
  name: 'Ama Owusu',
  avatarUrl: null,
  boarded: boarded,
  direction: direction,
  source: source,
  noShow: false,
);

void main() {
  test(
    'reset invalidates an in-flight board load from the previous identity',
    () async {
      final delayed = Completer<List<DriverRun>>();
      final trips = _StubTrips([])..pendingRuns = delayed.future;
      final controller = TodayController(trips: trips);
      final loading = controller.load();
      controller.reset();
      delayed.complete([_run('previous-driver-trip')]);
      await loading;
      expect(controller.board.valueOrNull, isNull);
      controller.dispose();
    },
  );
  test('an empty day is "nothing assigned", not "all done"', () async {
    final controller = TodayController(trips: _StubTrips([]));
    await controller.load();

    final board = controller.board.valueOrNull!;
    expect(board.isEmpty, isTrue);
    expect(board.isDayDone, isFalse);
  });

  test(
    'a day of finished runs is "all done", not "nothing assigned"',
    () async {
      final controller = TodayController(
        trips: _StubTrips([_run('t1', status: RunStatus.completed)]),
      );
      await controller.load();

      final board = controller.board.valueOrNull!;
      expect(board.isDayDone, isTrue);
      expect(board.isEmpty, isFalse);
      expect(board.completed, hasLength(1));
    },
  );

  test('the soonest scheduled run is next, the rest are later', () async {
    final controller = TodayController(
      trips: _StubTrips([_run('morning', hour: 6), _run('evening', hour: 17)]),
    );
    await controller.load();

    final board = controller.board.valueOrNull!;
    expect(board.next?.id, 'morning');
    expect(board.later.map((r) => r.id), ['evening']);
  });

  test('nothing is offered as "next" while a run is under way', () async {
    // Two start buttons side by side at the kerb is how the wrong one gets
    // tapped. The next action is to finish what is running.
    final controller = TodayController(
      trips: _StubTrips([
        _run('morning', status: RunStatus.active, hour: 6),
        _run('evening', hour: 17),
      ]),
    );
    await controller.load();

    final board = controller.board.valueOrNull!;
    expect(board.active?.id, 'morning');
    expect(board.next, isNull);
    expect(board.later.map((r) => r.id), ['evening']);
  });

  test('starting a run moves it to active and reloads the day', () async {
    final trips = _StubTrips([_run('morning')]);
    final controller = TodayController(trips: trips);
    await controller.load();

    await controller.start('morning');

    expect(trips.started, ['morning']);
    expect(controller.board.valueOrNull?.active?.id, 'morning');
    expect(controller.board.valueOrNull?.next, isNull);
  });

  test('completing a run moves it to done', () async {
    final trips = _StubTrips([_run('morning', status: RunStatus.active)]);
    final controller = TodayController(trips: trips);
    await controller.load();

    await controller.complete('morning');

    expect(trips.completed, ['morning']);
    expect(controller.board.valueOrNull?.isDayDone, isTrue);
  });

  test('a refresh failure keeps the day on screen', () async {
    // A driver mid-shift is reading this to decide what to do next. Losing it
    // because the depot's signal dipped is worse than showing it stale.
    final trips = _StubTrips([_run('morning')]);
    final controller = TodayController(trips: trips);
    await controller.load();

    trips.failWith = const OfflineException();
    await controller.load();

    expect(controller.board, isA<Failure<TodayBoard>>());
    expect(controller.board.valueOrNull?.next?.id, 'morning');
  });

  test('only the run being changed reports busy', () async {
    // The whole screen going blank under a driver mid-tap is how they lose
    // track of which run they were on.
    final controller = TodayController(trips: _StubTrips([_run('morning')]));
    await controller.load();
    expect(controller.busyRunId, isNull);

    final pending = controller.start('morning');
    expect(controller.busyRunId, 'morning');
    await pending;
    expect(controller.busyRunId, isNull);
  });

  test('asks for yesterday through today in the corridor UTC clock', () async {
    // A local date silently returns nothing whenever the device is not on UTC,
    // and it looks exactly like "no trips assigned" rather than like a bug.
    // Ghana is UTC, so in the field these are the same day anyway.
    final trips = _StubTrips([]);
    final controller = TodayController(
      trips: trips,
      // 23:30 in a UTC-7 zone, which is already the NEXT day in UTC.
      now: () => DateTime.utc(2026, 9, 10, 6, 30).toLocal(),
    );
    await controller.load();

    expect(trips.lastDate, isNull);
    expect(trips.lastFrom, '2026-09-09');
    expect(trips.lastTo, '2026-09-10');
  });

  test(
    'cold load recovers an active run across midnight, not old assignments',
    () async {
      final yesterday = DateTime.utc(2026, 9, 16, 23, 30);
      final trips = _StubTrips([
        _run('running', status: RunStatus.active, at: yesterday),
        _run('old-scheduled', at: yesterday),
        _run('old-completed', status: RunStatus.completed, at: yesterday),
        _run('old-cancelled', status: RunStatus.cancelled, at: yesterday),
        _run('today', at: DateTime.utc(2026, 9, 17, 6)),
      ])..filterDates = true;
      final controller = TodayController(
        trips: trips,
        now: () => DateTime.utc(2026, 9, 17, 0, 10),
      );
      await controller.load();
      final board = controller.board.valueOrNull!;
      expect(board.active?.id, 'running');
      expect(board.next, isNull);
      expect(board.later.map((r) => r.id), ['today']);
      expect(board.completed, isEmpty);

      // After that same historical run finishes, today's assignment takes over.
      trips.runs[0] = _run(
        'running',
        status: RunStatus.completed,
        at: yesterday,
      );
      await controller.load();
      expect(controller.board.valueOrNull?.active, isNull);
      expect(controller.board.valueOrNull?.next?.id, 'today');
      expect(controller.board.valueOrNull?.completed, isEmpty);
      controller.dispose();
    },
  );

  test('run times render in the corridor clock, not the device clock', () async {
    // Runs are grouped by UTC day by the API. Rendering in device-local time
    // lets one day straddle two local days, which showed up as a 06:30 run
    // labelled 23:30 and sorting ahead of the 17:30 one. Ghana is UTC+0 with no
    // DST, so in the field this IS the driver's wall clock.
    final morning = DateTime.utc(2026, 9, 10, 6, 30);
    final evening = DateTime.utc(2026, 9, 10, 17, 30);

    expect(CorridorTime.hhmm(morning), '06:30');
    expect(CorridorTime.hhmm(evening), '17:30');
    // Same instants expressed in another zone still read as the corridor's.
    expect(CorridorTime.hhmm(morning.toLocal()), '06:30');
    expect(CorridorTime.day(evening.toLocal()), '2026-09-10');
  });

  test('counts are fetched for the leading run only', () async {
    // The card shows riders and stops, which cost a manifest and a route read
    // each. Doing that for every run would mean four round trips to render a
    // screen where three of the cards are one line of text.
    final trips =
        _StubTrips([
            _run('morning', hour: 6),
            _run('evening', hour: 17),
            _run('night', hour: 21),
          ])
          ..riders = [_rider(), _rider(direction: 'evening')]
          ..stops = [
            DriverStop(seq: 0, name: 'Circle'),
            DriverStop(seq: 1, name: 'Madina'),
          ];
    final controller = TodayController(trips: trips);

    await controller.load();

    expect(trips.manifestCalls, 1);
    expect(trips.stopsCalls, 1);
    expect(controller.board.valueOrNull?.headline?.riders, 2);
    expect(controller.board.valueOrNull?.headline?.morning, 1);
    expect(controller.board.valueOrNull?.headline?.stops, 2);
  });

  test('a manifest that will not load does not take Today down', () async {
    // A driver needs to see the assignment far more than its headcount.
    final trips = _StubTrips([_run('morning')]);
    final controller = TodayController(trips: trips);
    trips.riders = const [];

    await controller.load();

    expect(controller.board.valueOrNull?.next?.id, 'morning');
  });
}
