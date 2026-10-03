import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/core/state/foreground_refresh.dart';
import 'package:trotxi_driver/core/state/config_controller.dart';
import 'package:trotxi_driver/data/config_repository.dart';
import 'package:trotxi_driver/data/position_queue.dart';
import 'package:trotxi_driver/data/position_publisher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trotxi_map/trotxi_map.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/data/route_map_repository.dart';
import 'package:trotxi_driver/Presentations/Run/widgets/run_map.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'support/replacement_client.dart';

class Config extends ConfigRepository {
  Config() : super(client: replacementClient());
  bool fail = false;
  @override
  Future<AppConfig> load() async {
    if (fail) throw StateError('offline');
    return const AppConfig(
      operations: OperationsContact(phone: '+233200000000'),
      mapStyle: TrotxiMapStyle.none,
    );
  }
}

class Maps implements RouteMapRepository {
  final reads = <String>[];
  @override
  Future<RouteShape> shapeFor(String id) async => const RouteShape(
    points: [],
    stops: [],
    source: RouteShapeSource.stops,
    runCount: null,
  );
  @override
  Future<VehicleFix?> vehicleOn(String id) async {
    reads.add(id);
    return VehicleFix(
      position: const LatLng(5.6, -0.2),
      recordedAt: DateTime.now(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class UnavailableCorridor extends Maps {
  final first = Completer<RouteShape>();
  int attempts = 0;
  @override
  Future<RouteShape> shapeFor(String id) {
    if (++attempts == 1) return first.future;
    return Future.error(const TrotxiException('Route unavailable'));
  }
}

class MarkerMap implements MapLibreMapController {
  @override
  final circles = <Circle>{};
  @override
  Future<Circle> addCircle(
    CircleOptions options, [
    Map<String, dynamic>? data,
  ]) async {
    final circle = Circle('vehicle', options, data);
    circles.add(circle);
    return circle;
  }

  @override
  Future<void> updateCircle(Circle circle, CircleOptions changes) async {}
  @override
  Future<void> removeCircle(Circle circle) async => circles.remove(circle);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class LocalPositions extends PositionPublisher {
  LocalPositions() : super(client: replacementClient());
  String? tripId = 'trip';
  Position? fix;
  @override
  String? get runId => tripId;
  @override
  Position? get localPosition => fix;
  void update(String? trip) {
    tripId = trip;
    fix = trip == null
        ? null
        : Position(
            latitude: 5.6,
            longitude: -0.2,
            timestamp: DateTime.now(),
            accuracy: 5,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
    notifyListeners();
  }
}

Map<String, dynamic> fix(String id, String time) => {
  'tripId': 'trip',
  'clientFixId': id,
  'capturedAt': time,
};

void main() {
  testWidgets(
    'route failures and retries preserve local GPS without a loaded corridor',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final maps = UnavailableCorridor();
      final positions = LocalPositions()..update('trip');
      final config = ConfigController(config: Config());
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<RouteMapRepository>.value(value: maps),
            ChangeNotifierProvider<PositionPublisher>.value(value: positions),
            ChangeNotifierProvider<ConfigController>.value(value: config),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: RunMap(routeId: 'route', runId: 'trip', isActive: true),
            ),
          ),
        ),
      );
      final controller = MarkerMap();
      tester.widget<TrotxiMapView>(find.byType(TrotxiMapView)).onStyleReloaded!(
        controller,
      );
      await tester.pump();
      expect(
        controller.circles.single.options.geometry,
        const LatLng(5.6, -0.2),
      );
      expect(find.text('Device GPS here now'), findsOneWidget);
      maps.first.completeError(const TrotxiException('Route unavailable'));
      await tester.pump();
      expect(controller.circles, hasLength(1));
      expect(find.text('Device GPS here now'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      expect(maps.attempts, greaterThan(1));
      expect(controller.circles, hasLength(1));
      expect(find.text('Device GPS here now'), findsOneWidget);
      expect(maps.reads, isEmpty);
      positions.update(null);
      await tester.pump();
      expect(controller.circles, isEmpty);
      expect(find.text('Device GPS here now'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      config.dispose();
      positions.dispose();
    },
  );

  testWidgets(
    'active map uses local GPS without read-back and clears it at trip or owner changes',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final maps = Maps();
      final positions = LocalPositions();
      final config = ConfigController(config: Config());
      Widget view(bool active) => MultiProvider(
        providers: [
          Provider<RouteMapRepository>.value(value: maps),
          ChangeNotifierProvider<PositionPublisher>.value(value: positions),
          ChangeNotifierProvider<ConfigController>.value(value: config),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: RunMap(routeId: 'route', runId: 'trip', isActive: active),
          ),
        ),
      );
      await tester.pumpWidget(view(true));
      await tester.pump();
      positions.update('trip');
      await tester.pump();
      expect(find.text('Device GPS here now'), findsOneWidget);
      expect(maps.reads, isEmpty);
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      expect(maps.reads, isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      positions.update('another-trip');
      await tester.pump();
      expect(
        find.text('Device GPS here now'),
        findsOneWidget,
        reason: 'Native GPS must not redraw a hidden map',
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text('Device GPS here now'), findsNothing);
      positions.update('trip');
      await tester.pump();
      expect(find.text('Device GPS here now'), findsOneWidget);
      positions.update(null);
      await tester.pump();
      expect(find.text('Device GPS here now'), findsNothing);
      positions.update('trip');
      await tester.pump();
      await tester.pumpWidget(view(false));
      await tester.pump(const Duration(seconds: 10));
      expect(maps.reads, isEmpty);
      expect(find.text('Device GPS here now'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      config.dispose();
      positions.dispose();
    },
  );
  testWidgets(
    'foreground polling stops in background, resumes immediately, and never overlaps',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      var reads = 0;
      Completer<void>? pending;
      final polling = ForegroundRefresh(() async {
        reads++;
        await pending?.future;
      });
      await tester.pump(const Duration(seconds: 5));
      expect(reads, 1);
      pending = Completer<void>();
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 15));
      expect(reads, 2);
      pending.complete();
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 15));
      expect(reads, 2);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(reads, 3);
      polling.dispose();
      await tester.pump(const Duration(seconds: 10));
      expect(reads, 3);
    },
  );
  test(
    'configuration failure keeps working contact details and a successful retry clears the error',
    () async {
      final repo = Config();
      final controller = ConfigController(config: repo);
      await controller.load();
      repo.fail = true;
      await controller.load();
      expect(controller.operations.phone, '+233200000000');
      expect(controller.error, isNotNull);
      repo.fail = false;
      await controller.load();
      expect(controller.error, isNull);
      controller.dispose();
    },
  );
  test(
    'GPS queue survives restart, sorts capture times and removes only acknowledged IDs',
    () async {
      final storage = MemorySessionStorage();
      final queue = PositionQueue(
        storage: storage,
        now: () => DateTime.utc(2026, 9, 19, 9),
      );
      await queue.bind('driver-a');
      await queue.add(fix('second', '2026-09-19T08:00:05Z'));
      await queue.add(fix('first', '2026-09-19T08:00:00Z'));
      final restarted = PositionQueue(
        storage: storage,
        now: () => DateTime.utc(2026, 9, 19, 9),
      );
      await restarted.bind('driver-a');
      expect(restarted.rows.map((r) => r['clientFixId']), ['first', 'second']);
      await restarted.acknowledge('first');
      final again = PositionQueue(
        storage: storage,
        now: () => DateTime.utc(2026, 9, 19, 9),
      );
      await again.bind('driver-a');
      expect(again.rows.single['clientFixId'], 'second');
      await again.bind('driver-b');
      expect(again.rows, isEmpty);
      expect(storage.values, isEmpty);
    },
  );
  test(
    'a full queue rejects new captures without evicting unsent positions; logout erases it',
    () async {
      final storage = MemorySessionStorage();
      final queue = PositionQueue(storage: storage, limit: 1);
      await queue.bind('driver');
      await queue.add(fix('first', '2026-09-19T08:00:00Z'));
      await expectLater(
        queue.add(fix('second', '2026-09-19T08:00:05Z')),
        throwsA(isA<PositionQueueFull>()),
      );
      expect(queue.rows.single['clientFixId'], 'first');
      await queue.bind(null);
      expect(queue.rows, isEmpty);
      expect(storage.values, isEmpty);
    },
  );
  test(
    'expired positions are erased on reopening, with a durable loss notice until acknowledged',
    () async {
      final storage = MemorySessionStorage();
      final queue = PositionQueue(storage: storage);
      await queue.bind('driver');
      await queue.add(fix('expired', '2026-09-17T08:00:00Z'));
      final restarted = PositionQueue(
        storage: storage,
        now: () => DateTime.utc(2026, 9, 19),
      );
      await restarted.bind('driver');
      expect(restarted.rows, isEmpty);
      expect(restarted.expiredFixes, 1);
      expect(storage.values.values.single, isNot(contains('capturedAt')));
      await restarted.acknowledgeExpiry();
      expect(storage.values, isEmpty);
    },
  );
}
