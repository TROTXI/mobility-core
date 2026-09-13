import 'dart:async';
import 'package:dio/dio.dart';
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

  Future<void> fix({DateTime? timestamp, double latitude = 5.57}) async {
    await messenger.handlePlatformMessage(
      updates.name,
      const StandardMethodCodec().encodeSuccessEnvelope({
        'latitude': latitude,
        'longitude': -0.21,
        'timestamp': (timestamp ?? DateTime.now()).millisecondsSinceEpoch,
        'accuracy': 5.0,
        'altitude': 0.0,
        'heading': 0.0,
        'speed': 0.0,
        'speed_accuracy': 0.0,
      }),
      (_) {},
    );
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> reaches(PositionPublisher publisher, PositionSharing state) {
    if (publisher.state == state) return Future.value();
    final done = Completer<void>();
    void listen() {
      if (publisher.state == state && !done.isCompleted) done.complete();
    }

    publisher.addListener(listen);
    return done.future
        .timeout(const Duration(seconds: 3))
        .whenComplete(() => publisher.removeListener(listen));
  }

  TrotxiApiClient client(
    void Function(RequestOptions, RequestInterceptorHandler) handler,
  ) => TrotxiApiClient(
    dio: Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..interceptors.add(InterceptorsWrapper(onRequest: handler)),
    interceptors: [],
  );

  void accept(RequestOptions options, RequestInterceptorHandler handler) {
    handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'tripId': options.path.split('/')[2],
          'position': {
            'latitude': (options.data as Map)['latitude'],
            'longitude': (options.data as Map)['longitude'],
            'recordedAt': DateTime.now().toUtc().toIso8601String(),
          },
        },
      ),
    );
  }

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

  test(
    'permission and a native fix alone do not claim live; only an API acknowledgement does',
    () async {
      final request = Completer<(RequestOptions, RequestInterceptorHandler)>();
      final publisher = PositionPublisher(
        client: client((o, h) => request.complete((o, h))),
      );
      addTearDown(publisher.dispose);
      await publisher.start('trip-1');
      expect(publisher.state, PositionSharing.waiting);
      await fix();
      final (options, handler) = await request.future;
      expect(publisher.state, PositionSharing.waiting);
      accept(options, handler);
      await reaches(publisher, PositionSharing.live);
      expect(publisher.lastAcknowledgedAt, isNotNull);
    },
  );

  test(
    'a successful HTTP response without a matching receipt is not live',
    () async {
      final publisher = PositionPublisher(
        client: client((o, h) {
          h.resolve(
            Response(
              requestOptions: o,
              statusCode: 200,
              data: {
                'tripId': 'another-trip',
                'position': {
                  'latitude': 5.57,
                  'longitude': -0.21,
                  'recordedAt': DateTime.now().toUtc().toIso8601String(),
                },
              },
            ),
          );
        }),
      );
      addTearDown(publisher.dispose);
      await publisher.start('trip-1');
      await fix();
      await reaches(publisher, PositionSharing.failed);
      expect(publisher.lastAcknowledgedAt, isNull);
    },
  );

  test(
    'native stream error prevents an older in-flight receipt claiming live',
    () async {
      final request = Completer<(RequestOptions, RequestInterceptorHandler)>();
      final publisher = PositionPublisher(
        client: client((o, h) => request.complete((o, h))),
      );
      addTearDown(publisher.dispose);
      await publisher.start('trip-1');
      await fix();
      final (options, handler) = await request.future;
      await messenger.handlePlatformMessage(
        updates.name,
        const StandardMethodCodec().encodeErrorEnvelope(code: 'location_error'),
        (_) {},
      );
      expect(publisher.state, PositionSharing.stale);
      accept(options, handler);
      await Future<void>.delayed(Duration.zero);
      expect(publisher.state, PositionSharing.stale);
    },
  );

  test(
    'failed upload is not live or queued; a later successful fix recovers',
    () async {
      var fail = true;
      final publisher = PositionPublisher(
        client: client((o, h) {
          if (fail) {
            h.reject(
              DioException(
                requestOptions: o,
                type: DioExceptionType.connectionError,
              ),
            );
          } else {
            accept(o, h);
          }
        }),
      );
      addTearDown(publisher.dispose);
      await publisher.start('trip-1');
      await fix();
      await reaches(publisher, PositionSharing.failed);
      fail = false;
      await fix();
      await reaches(publisher, PositionSharing.live);
    },
  );

  test('acknowledged location expires without newer fixes', () async {
    final publisher = PositionPublisher(
      client: client(accept),
      freshFor: const Duration(milliseconds: 100),
    );
    addTearDown(publisher.dispose);
    await publisher.start('trip-1');
    await fix();
    await reaches(publisher, PositionSharing.live);
    await reaches(publisher, PositionSharing.stale);
  });

  test('old native fixes are not uploaded as a new current location', () async {
    var uploads = 0;
    final publisher = PositionPublisher(
      client: client((o, h) {
        uploads++;
        accept(o, h);
      }),
    );
    addTearDown(publisher.dispose);
    await publisher.start('trip-1');
    await fix(timestamp: DateTime.now().subtract(const Duration(minutes: 5)));
    expect(publisher.state, PositionSharing.stale);
    expect(uploads, 0);
  });

  test('late upload response after stop cannot restore live state', () async {
    final request = Completer<(RequestOptions, RequestInterceptorHandler)>();
    final publisher = PositionPublisher(
      client: client((o, h) => request.complete((o, h))),
    );
    addTearDown(publisher.dispose);
    await publisher.start('trip-1');
    await fix();
    final (options, handler) = await request.future;
    await publisher.stop();
    accept(options, handler);
    await Future<void>.delayed(Duration.zero);
    expect(publisher.state, PositionSharing.idle);
    expect(publisher.runId, isNull);
    expect(publisher.lastAcknowledgedAt, isNull);
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
