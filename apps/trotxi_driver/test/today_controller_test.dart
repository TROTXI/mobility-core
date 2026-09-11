// Today (frames 14 to 18). The states matter more than the list: nothing
// assigned and everything finished look alike in a naive build and read
// completely differently to a driver at the start of a shift.

import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/core/state/loadable.dart';
import 'package:trotxi_driver/core/state/today_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

DriverRun _run(String id, {RunStatus status = RunStatus.scheduled, int hour = 6}) {
  final now = DateTime.now();
  return DriverRun(
    id: id,
    routeId: 'r1',
    routeName: 'Circle ⇄ Madina',
    scheduledAt: DateTime(now.year, now.month, now.day, hour, 30),
    status: status,
  );
}

class _StubTrips implements TripsRepository {
  _StubTrips(this.runs);

  List<DriverRun> runs;
  String? lastDate;
  Object? failWith;
  final started = <String>[];
  final completed = <String>[];

  @override
  Future<List<DriverRun>> myRuns({String? date}) async {
    lastDate = date;
    if (failWith != null) throw failWith!;
    return runs;
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('an empty day is "nothing assigned", not "all done"', () async {
    final controller = TodayController(trips: _StubTrips([]));
    await controller.load();

    final board = controller.board.valueOrNull!;
    expect(board.isEmpty, isTrue);
    expect(board.isDayDone, isFalse);
  });

  test('a day of finished runs is "all done", not "nothing assigned"', () async {
    final controller = TodayController(
      trips: _StubTrips([_run('t1', status: RunStatus.completed)]),
    );
    await controller.load();

    final board = controller.board.valueOrNull!;
    expect(board.isDayDone, isTrue);
    expect(board.isEmpty, isFalse);
    expect(board.completed, hasLength(1));
  });

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

  test('asks for the UTC day, because that is what the API filters on', () async {
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

    expect(trips.lastDate, '2026-09-10');
  });
}
