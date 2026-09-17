import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/core/state/driver_location_controller.dart';
import 'package:trotxi_driver/data/position_publisher.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

class _Client implements DriverApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Publisher extends PositionPublisher {
  _Publisher() : super(client: _Client());
  String? active;
  @override
  Future<PositionBlock?> start(String runId) async {
    active = runId;
    return null;
  }

  @override
  Future<void> stop() async {
    active = null;
  }
}

class _Trips implements TripsRepository {
  List<DriverRun> runs = [];
  Completer<List<DriverRun>>? pending;
  int reads = 0;
  Object? error;
  @override
  Future<List<DriverRun>> myRuns({
    String? date,
    String? from,
    String? to,
  }) async {
    expect(date, isNull); // An overnight active trip must not be filtered out.
    reads++;
    if (error != null) throw error!;
    return pending?.future ?? runs;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DriverRun _run([RunStatus status = RunStatus.active]) => DriverRun(
  id: 'trip-1',
  routeId: 'route-1',
  routeName: 'Circle → Madina',
  scheduledAt: DateTime.utc(2026, 9, 12),
  status: status,
);

Future<void> _tick() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Trips trips;
  late _Publisher publisher;
  late DriverLocationController controller;
  setUp(() {
    trips = _Trips();
    publisher = _Publisher();
    controller = DriverLocationController(trips: trips, publisher: publisher);
    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
  });
  tearDown(() {
    controller.dispose();
    publisher.dispose();
  });

  test('no session or only scheduled trips never starts sharing', () async {
    trips.runs = [_run(RunStatus.scheduled)];
    await controller.refresh();
    expect(trips.reads, 0);
    controller.setSessionReady(true);
    await _tick();
    expect(publisher.active, isNull);
  });

  test(
    'restored active trip shares without constructing a Trip page',
    () async {
      trips.runs = [_run()];
      controller.setSessionReady(true);
      await _tick();
      expect(publisher.active, 'trip-1');
      // Screen navigation has no ownership of this publisher.
      await controller.refresh();
      expect(publisher.active, 'trip-1');
      controller.observeRun(_run(RunStatus.completed));
      expect(publisher.active, isNull);
    },
  );

  test(
    'background pauses, foreground resumes, sign-out clears the trip',
    () async {
      trips.runs = [_run()];
      controller.setSessionReady(true);
      await _tick();
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(publisher.active, isNull);
      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(publisher.active, 'trip-1');
      await _tick();
      controller.setSessionReady(false);
      expect(publisher.active, isNull);
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(publisher.active, isNull);
    },
  );

  test('stale roster response cannot revive a completed trip', () async {
    controller.setSessionReady(true);
    await _tick();
    controller.observeRun(_run());
    trips.pending = Completer<List<DriverRun>>();
    final refresh = controller.refresh();
    controller.observeRun(_run(RunStatus.completed));
    trips.pending!.complete([_run()]);
    await refresh;
    expect(publisher.active, isNull);
  });

  test(
    'old account lifecycle response cannot start sharing for a new session',
    () async {
      controller.setSessionReady(true);
      await _tick();
      final report = controller.captureRunObserver();
      controller.setSessionReady(false);
      controller.setSessionReady(true);
      await _tick();
      report(_run());
      expect(publisher.active, isNull);
    },
  );

  test(
    'roster removal stops sharing, but a network error alone does not',
    () async {
      trips.runs = [_run()];
      controller.setSessionReady(true);
      await _tick();
      trips.error = const OfflineException();
      await controller.refresh();
      expect(publisher.active, 'trip-1');
      trips.error = null;
      trips.runs = [];
      await controller.refresh();
      expect(publisher.active, isNull);
    },
  );
}
