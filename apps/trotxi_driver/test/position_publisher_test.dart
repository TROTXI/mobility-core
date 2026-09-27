import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/data/position_publisher.dart';
import 'package:trotxi_driver/data/position_queue.dart';
import 'support/replacement_client.dart';

class _UnusedClient implements DriverApi {
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
  DateTime? nativeTimestamp;

  Future<void> fix({
    DateTime? timestamp,
    double latitude = 5.57,
    double accuracy = 5,
  }) async {
    await messenger.handlePlatformMessage(
      updates.name,
      const StandardMethodCodec().encodeSuccessEnvelope({
        'latitude': latitude,
        'longitude': -0.21,
        'timestamp': (timestamp ?? DateTime.now()).millisecondsSinceEpoch,
        'accuracy': accuracy,
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

  DriverApi client(
    void Function(RequestOptions, RequestInterceptorHandler) handler, {
    DateTime Function()? now,
  }) => replacementClient(
    now: now,
    dio: Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..interceptors.add(InterceptorsWrapper(onRequest: handler)),
  );

  void accept(RequestOptions options, RequestInterceptorHandler handler) {
    handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 200,
        data: positionReceipt(options),
      ),
    );
  }

  setUp(() {
    calls = [];
    services = true;
    permission = LocationPermission.whileInUse;
    pending = null;
    nativeTimestamp = null;
    messenger.setMockMethodCallHandler(location, (call) async {
      calls.add(call.method);
      switch (call.method) {
        case 'isLocationServiceEnabled':
          return services;
        case 'checkPermission':
          return pending?.future ?? permission.index;
        case 'getCurrentPosition':
          return {
            'latitude': 5.57,
            'longitude': -0.21,
            'timestamp':
                (nativeTimestamp ?? DateTime.now()).millisecondsSinceEpoch,
            'accuracy': 5.0,
            'altitude': 0.0,
            'heading': 0.0,
            'speed': 0.0,
            'speed_accuracy': 0.0,
          };
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
    'a fresh stationary reading is captured without 25 metres of movement',
    () async {
      var now = DateTime.now().subtract(const Duration(seconds: 20));
      final bodies = <Map>[];
      final secondDelivery = Completer<void>();
      final publisher = PositionPublisher(
        client: client((o, h) {
          bodies.add(Map.from(o.data as Map));
          accept(o, h);
          if (bodies.length == 2) secondDelivery.complete();
        }),
        now: () => now,
      );
      addTearDown(publisher.dispose);
      await publisher.start('trip-1');
      await fix(timestamp: now);
      await reaches(publisher, PositionSharing.live);
      now = now.add(const Duration(seconds: 5));
      nativeTimestamp = now;
      await publisher.captureNow();
      await secondDelivery.future.timeout(const Duration(seconds: 2));
      expect(calls, contains('getCurrentPosition'));
      expect(publisher.queueError, isNull);
      expect(publisher.state, PositionSharing.live);
      expect(bodies.length, 2);
      expect(bodies[0]['latitude'], bodies[1]['latitude']);
      expect(bodies[0]['capturedAt'], isNot(bodies[1]['capturedAt']));
      expect(bodies[0]['clientFixId'], isNot(bodies[1]['clientFixId']));
    },
  );

  test(
    'completion is refused with unsent GPS, then succeeds after retry with the same fix ID',
    () async {
      var offline = true;
      final ids = <String>[];
      final publisher = PositionPublisher(
        client: client((o, h) {
          ids.add((o.data as Map)['clientFixId'] as String);
          if (offline) {
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
      await expectLater(
        publisher.flushBeforeComplete('trip-1'),
        throwsA(isA<ApiException>()),
      );
      expect(publisher.queuedFixes, 1);
      offline = false;
      await publisher.flushBeforeComplete('trip-1');
      expect(publisher.queuedFixes, 0);
      expect(ids.length, greaterThanOrEqualTo(3));
      expect(ids.toSet().length, 1);
    },
  );

  test(
    'a permanently refused fix does not starve later fixes or disappear silently',
    () async {
      final queue = PositionQueue();
      final now = DateTime.now();
      for (final id in ['refused', 'valid']) {
        await queue.add({
          'tripId': 'trip-1',
          'clientFixId': id,
          'capturedAt': now.toUtc().toIso8601String(),
          'accuracyMeters': 5.0,
          'latitude': 5.57,
          'longitude': -0.21,
        });
      }
      final publisher = PositionPublisher(
        queue: queue,
        client: client((o, h) {
          if ((o.data as Map)['clientFixId'] == 'refused') {
            h.reject(
              DioException(
                requestOptions: o,
                response: Response(
                  requestOptions: o,
                  statusCode: 409,
                  data: {
                    'error': {
                      'code': 'capture_before_start',
                      'message': 'This fix predates the start of the run.',
                    },
                  },
                ),
              ),
              true,
            );
          } else {
            accept(o, h);
          }
        }),
      );
      addTearDown(publisher.dispose);
      await publisher.start('trip-1');
      await reaches(publisher, PositionSharing.live);
      expect(queue.rows.map((row) => row['clientFixId']), ['refused']);
      expect(publisher.rejectedFixes, 1);
      await expectLater(
        publisher.flushBeforeComplete('trip-1'),
        throwsA(isA<ApiException>()),
      );
      await publisher.acknowledgeRejections();
      await publisher.flushBeforeComplete('trip-1');
      expect(queue.rows, isEmpty);
    },
  );

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
    'an acknowledged imprecise fix reports weak GPS with its accuracy',
    () async {
      final publisher = PositionPublisher(client: client(accept));
      addTearDown(publisher.dispose);
      await publisher.start('trip-1');
      await fix(accuracy: 65);
      await reaches(publisher, PositionSharing.weak);
      expect(publisher.lastAcknowledgedAt, isNotNull);
      expect(publisher.lastAccuracyMeters, 65);
    },
  );

  test(
    'a stored fix rejected for live projection never claims location sharing is live',
    () async {
      final publisher = PositionPublisher(
        client: client(
          (o, h) => h.resolve(
            Response(
              requestOptions: o,
              statusCode: 200,
              data: positionReceipt(o, accepted: false),
            ),
          ),
        ),
      );
      addTearDown(publisher.dispose);
      await publisher.start('trip-1');
      await fix();
      await reaches(publisher, PositionSharing.stale);
      expect(publisher.lastAcknowledgedAt, isNull);
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
                'data': {
                  ...positionReceipt(o)['data'] as Map,
                  'clientFixId': 'different-fix',
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
    'failed upload stays queued and retry recovers without changing its identity',
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
      expect(publisher.queuedFixes, 1);
      fail = false;
      await publisher.retry();
      await reaches(publisher, PositionSharing.live);
      expect(publisher.queuedFixes, 0);
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

  test(
    'retry replaces the native stream instead of becoming a no-op',
    () async {
      final publisher = PositionPublisher(client: _UnusedClient());
      addTearDown(publisher.dispose);
      await publisher.start('trip-1');
      expect(calls.where((call) => call == 'listen').length, 1);

      await publisher.retry();

      expect(calls.where((call) => call == 'cancel').length, 1);
      expect(calls.where((call) => call == 'listen').length, 2);
      expect(publisher.runId, 'trip-1');
      expect(publisher.state, PositionSharing.waiting);
    },
  );

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

  test(
    'locking during a pending start does not create a background service',
    () async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      pending = Completer<int>();
      final publisher = PositionPublisher(client: _UnusedClient());
      addTearDown(publisher.dispose);
      addTearDown(
        () => binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed),
      );
      final starting = publisher.start('trip-1');
      await Future<void>.delayed(Duration.zero);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      pending!.complete(LocationPermission.whileInUse.index);
      expect(await starting, PositionBlock.notRequested);
      expect(calls, isNot(contains('listen')));
    },
  );

  for (final refusal in [
    (404, 'not_found'),
    (409, 'trip_not_active'),
    (409, 'collection_session_expired'),
  ]) {
    test(
      'server ${refusal.$2} stops collection without silently restarting',
      () async {
        final publisher = PositionPublisher(
          client: client((o, h) {
            h.reject(
              DioException(
                requestOptions: o,
                response: Response(
                  requestOptions: o,
                  statusCode: refusal.$1,
                  data: {
                    'error': {
                      'code': refusal.$2,
                      'message': 'Tracking refused.',
                    },
                  },
                ),
              ),
              true,
            );
          }),
        );
        addTearDown(publisher.dispose);
        await publisher.start('trip-1');
        final stopped = reaches(publisher, PositionSharing.idle);
        await fix();
        await stopped;
        expect(publisher.isPublishing, isFalse);
        expect(publisher.queue.rows, hasLength(1));
        expect(await publisher.start('trip-1'), PositionBlock.unavailable);
        expect(publisher.isPublishing, isFalse);
      },
    );
  }

  for (final status in [404, 429]) {
    test(
      'owner switch clears GPS $status suppression for the same run',
      () async {
        var now = DateTime.now();
        var requests = 0;
        final api = client((o, h) {
          if (++requests > 1) return accept(o, h);
          h.reject(
            DioException(
              requestOptions: o,
              response: Response(
                requestOptions: o,
                statusCode: status,
                headers: Headers.fromMap({
                  'retry-after': ['120'],
                }),
                data: {
                  'error': {
                    'code': status == 404 ? 'not_found' : 'rate_limited',
                    'message': 'Refused.',
                  },
                },
              ),
            ),
            true,
          );
        }, now: () => now);
        final publisher = PositionPublisher(client: api, now: () => now);
        addTearDown(publisher.dispose);
        await api.store.saveTokens(
          accessToken: 'driver-a',
          refreshToken: 'refresh-a',
        );
        await publisher.bindOwner('driver-a');
        await publisher.start('trip-1');
        final refused = reaches(
          publisher,
          status == 404 ? PositionSharing.idle : PositionSharing.failed,
        );
        await fix(timestamp: now);
        await refused;
        if (status == 404) {
          await publisher.bindOwner('driver-a');
          expect(
            await publisher.start('trip-1'),
            PositionBlock.unavailable,
            reason: 'rebinding the same owner must not bypass a refusal',
          );
        }
        await api.store.clearTokens();
        await publisher.bindOwner(null);
        await api.store.saveTokens(
          accessToken: 'driver-b',
          refreshToken: 'refresh-b',
        );
        await publisher.bindOwner('driver-b');
        expect(publisher.queue.rows, isEmpty);
        expect(await publisher.start('trip-1'), isNull);
        now = now.add(const Duration(seconds: 6));
        final live = reaches(publisher, PositionSharing.live);
        await fix(timestamp: now);
        await live;
        expect(
          requests,
          2,
          reason: 'A cooldown must not suppress B before its 120s expiry',
        );
        expect(publisher.queue.rows, isEmpty);
      },
    );
  }

  test(
    'screen-lock lifecycle keeps fresh fixes uploading until stop',
    () async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      addTearDown(
        () => binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed),
      );
      final publisher = PositionPublisher(client: client(accept));
      addTearDown(publisher.dispose);
      await publisher.start('trip-1');
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      final live = reaches(publisher, PositionSharing.live);
      await fix();
      await live;
      expect(publisher.isPublishing, isTrue);
      expect(publisher.queue.rows, isEmpty);
      await publisher.stop();
      expect(calls.last, 'cancel');
      expect(publisher.isPublishing, isFalse);
    },
  );

  test(
    'GPS honours Retry-After while keeping offline fixes and their IDs',
    () async {
      var now = DateTime.now();
      var requests = 0;
      final publisher = PositionPublisher(
        now: () => now,
        client: client((o, h) {
          requests++;
          if (requests > 1) return accept(o, h);
          h.reject(
            DioException(
              requestOptions: o,
              response: Response(
                requestOptions: o,
                statusCode: 429,
                headers: Headers.fromMap({
                  'retry-after': ['120'],
                }),
                data: {
                  'error': {'code': 'rate_limited', 'message': 'Wait.'},
                },
              ),
            ),
            true,
          );
        }, now: () => now),
      );
      addTearDown(publisher.dispose);
      await publisher.start('trip-1');
      final limited = reaches(publisher, PositionSharing.failed);
      await fix(timestamp: now);
      await limited;
      final firstId = publisher.queue.rows.single['clientFixId'];
      now = now.add(const Duration(seconds: 6));
      await fix(timestamp: now);
      await Future<void>.delayed(Duration.zero);
      expect(requests, 1);
      expect(publisher.queue.rows, hasLength(2));
      expect(publisher.queue.rows.first['clientFixId'], firstId);
      now = now.add(const Duration(seconds: 120));
      final recovered = reaches(publisher, PositionSharing.live);
      await fix(timestamp: now);
      await recovered;
      expect(requests, 4);
      expect(publisher.queue.rows, isEmpty);
    },
  );
}
