import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/data/position_publisher.dart';

class _UnusedClient implements TrotxiApiClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const location = MethodChannel('flutter.baseflow.com/geolocator');
  const updates = MethodChannel('flutter.baseflow.com/geolocator_updates');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<String> calls;
  late bool services;
  late LocationPermission permission;
  Completer<int>? pending;

  setUp(() {
    calls = [];
    services = true;
    permission = LocationPermission.whileInUse;
    pending = null;
    messenger.setMockMethodCallHandler(location, (call) async {
      calls.add(call.method);
      switch (call.method) {
        case 'isLocationServiceEnabled':
          return services;
        case 'checkPermission':
          return pending?.future ?? permission.index;
        default:
          throw StateError('Unexpected native method ${call.method}');
      }
    });
    messenger.setMockMethodCallHandler(updates, (call) async {
      calls.add(call.method);
      return null;
    });
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(location, null);
    messenger.setMockMethodCallHandler(updates, null);
  });

  test('starts only with location access and stops its stream', () async {
    final publisher = PositionPublisher(client: _UnusedClient());
    expect(await publisher.start('trip-1'), isNull);
    await Future<void>.delayed(Duration.zero);
    expect(publisher.runId, 'trip-1');
    expect(calls, ['isLocationServiceEnabled', 'checkPermission', 'listen']);
    await publisher.stop();
    expect(publisher.isPublishing, isFalse);
    expect(publisher.runId, isNull);
    expect(calls.last, 'cancel');
  });

  test('denial never prompts or opens a stream', () async {
    permission = LocationPermission.denied;
    final publisher = PositionPublisher(client: _UnusedClient());
    expect(await publisher.start('trip-1'), PositionBlock.denied);
    expect(calls, ['isLocationServiceEnabled', 'checkPermission']);
    expect(publisher.isPublishing, isFalse);
  });

  test('disabled services never open a stream', () async {
    services = false;
    final publisher = PositionPublisher(client: _UnusedClient());
    expect(await publisher.start('trip-1'), PositionBlock.servicesOff);
    expect(calls, ['isLocationServiceEnabled']);
  });

  test(
    'stop while permission check is pending prevents a late stream',
    () async {
      pending = Completer<int>();
      final publisher = PositionPublisher(client: _UnusedClient());
      final starting = publisher.start('trip-1');
      await Future<void>.delayed(Duration.zero);
      expect(calls, contains('checkPermission'));
      await publisher.stop();
      pending!.complete(LocationPermission.whileInUse.index);
      expect(await starting, PositionBlock.notRequested);
      expect(publisher.isPublishing, isFalse);
      expect(publisher.runId, isNull);
      expect(calls, isNot(contains('listen')));
    },
  );
}
