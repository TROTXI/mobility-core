import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_diagnostics/diagnostics.dart';
import 'package:trotxi_diagnostics/firebase_diagnostics.dart';
import 'package:trotxi_diagnostics/timing_interceptor.dart';

class Sink implements DiagnosticsSink {
  final errors = <(String, String, ErrorSource, bool)>[];
  final timings = <(Operation, int, Outcome)>[];
  Future<void> Function()? fail;
  @override
  Future<void> error(String category, StackTrace stack, ErrorSource source,
      {required bool fatal}) {
    errors.add((category, stack.toString(), source, fatal));
    return fail?.call() ?? Future.value();
  }

  @override
  Future<void> timing(Operation op, int ms, Outcome outcome) {
    timings.add((op, ms, outcome));
    return fail?.call() ?? Future.value();
  }
}

class Controls implements DiagnosticControls {
  String? policy;
  String? failure;
  String? hang;
  bool reports = false;
  final calls = <String>[];
  Future<void> call(String name) async {
    calls.add(name);
    if (name == failure) throw StateError('provider failed');
    if (name == hang) await Completer<void>().future;
  }

  @override
  Future<void> disableCrashUploads() => call('disable');
  @override
  Future<void> deleteReports() => call('delete');
  @override
  Future<bool> hasReports() async {
    await call('check');
    return reports;
  }

  @override
  Future<void> sendReports() => call('send');
  @override
  Future<void> performance(bool enabled) => call('performance:$enabled');
  @override
  Future<String?> readPolicy() async {
    await call('read');
    return policy;
  }

  @override
  Future<void> writePolicy(String value) async {
    await call('write');
    policy = value;
  }
}

class PrivateError implements Exception {
  @override
  String toString() => throw StateError('must not inspect exception text');
}

class ObservedErrorHandler extends ErrorInterceptorHandler {
  Future<void> observe() => future.then<void>((_) {}, onError: (Object _) {});
}

Future<void> drain() => Future<void>.delayed(Duration.zero);

void main() {
  test('disabled by default, without touching the provider', () async {
    final sink = Sink();
    final diagnostics = MobileDiagnostics(sink);
    diagnostics.report(PrivateError(), StackTrace.empty, ErrorSource.zone);
    diagnostics.recordTiming(
        Operation.decideRide, Duration.zero, Outcome.success);
    await drain();
    expect(sink.errors, isEmpty);
    expect(sink.timings, isEmpty);
  });

  test(
      'errors omit original message, account data, HTTP data and absolute paths',
      () async {
    final sink = Sink();
    final diagnostics = MobileDiagnostics(sink, enabled: true);
    final stack = StackTrace.fromString(
        '''#0 Session.confirm (package:trotxi_client/session.dart:12:4)
#1 _invoke (dart:async/zone.dart:123:4)
#2 secrets (/Users/person/private.dart:12:3)
#3 request (https://example.com/path?token=SECRET:1:2)
email=private@example.com coordinates=5.1,-0.2 payment=REF-PRIVATE''');
    diagnostics.report(PrivateError(), stack, ErrorSource.zone, fatal: true);
    await drain();
    expect(sink.errors.single.$1, 'unhandled_error');
    expect(sink.errors.single.$2,
        '#0 Session.confirm (package:trotxi_client/session.dart:12:4)\n#1 _invoke (dart:async/zone.dart:123:4)');
    expect(sink.errors.single.$3, ErrorSource.zone);
    expect(sink.errors.single.$4, isTrue);
    final dio = DioException(
        requestOptions: RequestOptions(
            path: '/private',
            data: {'password': 'secret'},
            headers: {'Authorization': 'Bearer secret'}),
        type: DioExceptionType.badResponse,
        message: 'private payment ref');
    diagnostics.report(dio, StackTrace.empty, ErrorSource.framework);
    await drain();
    expect(sink.errors.last.$1, 'network_badResponse');
  });

  test('AOT addresses and build ID survive without arbitrary frame text', () {
    final stack = safeStack(StackTrace.fromString(
            """build_id: '77d1b910140a2d66b93594aea59469cf'
isolate_dso_base: 75f178181000, vm_dso_base: 75f178181000
isolate_instructions: 75f17818f000, vm_instructions: 75f178183000
    #00 abs 000075f17833027b virt 00000000001af27b _kDartIsolateSnapshotInstructions+0x1a127b
    #01 abs 000075f17833027b SECRET
"""))
        .toString();
    expect(stack, contains('build_id:'));
    expect(stack, contains('_kDartIsolateSnapshotInstructions'));
    expect(stack, isNot(contains('SECRET')));
    expect(
        safeStack(StackTrace.fromString(
                List.filled(500, '#0 run (package:app/main.dart:1:2)')
                    .join('\n')))
            .toString()
            .split('\n'),
        hasLength(40));
  });

  test('sync failure, async failure and late failure never escape', () async {
    final sink = Sink();
    final diagnostics = MobileDiagnostics(sink,
        enabled: true, timeout: const Duration(milliseconds: 1));
    sink.fail = () => throw StateError('sync');
    diagnostics.report(
        StateError('sensitive'), StackTrace.empty, ErrorSource.zone);
    await drain();
    sink.fail = () => Future.error(StateError('async'));
    diagnostics.report(
        StateError('sensitive'), StackTrace.empty, ErrorSource.zone);
    await drain();
    final late = Completer<void>();
    sink.fail = () => late.future;
    diagnostics.report(
        StateError('sensitive'), StackTrace.empty, ErrorSource.zone);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    late.completeError(StateError('late'));
    await drain();
    expect(sink.errors, hasLength(3));
  });

  test('concurrency and session budgets bound provider work', () async {
    final sink = Sink()..fail = () => Completer<void>().future;
    final diagnostics = MobileDiagnostics(sink,
        enabled: true, timeout: const Duration(milliseconds: 1));
    for (var i = 0; i < 100; i++) {
      diagnostics.report(
          StateError('private'), StackTrace.empty, ErrorSource.zone);
    }
    expect(sink.errors, hasLength(4));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    sink.fail = null;
    for (var i = 0; i < 40; i++) {
      diagnostics.report(
          StateError('private'), StackTrace.empty, ErrorSource.zone);
      await drain();
    }
    expect(sink.errors, hasLength(20));
    for (var i = 0; i < 120; i++) {
      diagnostics.recordTiming(
          Operation.trackBus, const Duration(days: 1), Outcome.success);
      await drain();
    }
    expect(sink.timings, hasLength(100));
    expect(sink.timings.first.$2, 300000);
  });

  test('first approved release deletes old reports before accepting new ones',
      () async {
    final controls = Controls()..reports = true;
    expect(
        await prepareDiagnostics(controls,
            release: true, scope: 'staging:project'),
        isFalse);
    expect(controls.calls,
        ['disable', 'performance:false', 'read', 'check', 'delete', 'write']);
    controls.calls.clear();
    controls.reports = false;
    expect(
        await prepareDiagnostics(controls,
            release: true, scope: 'staging:project'),
        isTrue);
    expect(controls.calls, [
      'disable',
      'performance:false',
      'read',
      'check',
      'write',
      'performance:true'
    ]);
    controls.calls.clear();
    expect(
        await prepareDiagnostics(controls,
            release: true, scope: 'staging:project'),
        isTrue);
    expect(controls.calls,
        ['disable', 'performance:false', 'read', 'send', 'performance:true']);
  });

  test('interrupted native cleanup cannot authorize legacy uploads', () async {
    final controls = Controls()..reports = true;
    await prepareDiagnostics(controls, release: true, scope: 'staging:project');
    controls.calls.clear();
    controls.reports = true;
    expect(
        await prepareDiagnostics(controls,
            release: true, scope: 'staging:project'),
        isFalse);
    expect(controls.calls,
        ['disable', 'performance:false', 'read', 'check', 'delete', 'write']);
    expect(controls.policy, endsWith(':pending'));
    controls.calls.clear();
    controls.failure = 'check';
    expect(
        await prepareDiagnostics(controls,
            release: true, scope: 'staging:project'),
        isFalse);
    expect(controls.calls, isNot(contains('send')));
  });

  test('debug and project transitions discard queued reports, never send them',
      () async {
    final controls = Controls();
    await prepareDiagnostics(controls, release: true, scope: 'staging:project');
    controls.calls.clear();
    expect(
        await prepareDiagnostics(controls,
            release: false, scope: 'staging:project'),
        isFalse);
    expect(controls.calls,
        ['disable', 'performance:false', 'read', 'delete', 'write']);
    controls.calls.clear();
    controls.reports = true;
    await prepareDiagnostics(controls, release: true, scope: 'staging:project');
    expect(controls.calls, contains('delete'));
    expect(controls.calls, isNot(contains('send')));
    controls.calls.clear();
    await prepareDiagnostics(controls,
        release: true, scope: 'production:other');
    expect(controls.calls, contains('delete'));
    expect(controls.calls, isNot(contains('send')));
  });

  for (final failure in [
    'disable',
    'performance:false',
    'read',
    'check',
    'delete',
    'write'
  ]) {
    test('setup fails closed at $failure', () async {
      final controls = Controls()
        ..failure = failure
        ..reports = true;
      expect(
          await prepareDiagnostics(controls,
              release: true, scope: 'staging:project'),
          isFalse);
      expect(controls.calls, isNot(contains('send')));
      expect(controls.calls, isNot(contains('performance:true')));
    });
  }
  test('hung setup times out without enabling or uploading later', () async {
    final controls = Controls()
      ..hang = 'delete'
      ..reports = true;
    expect(
        await prepareDiagnostics(controls,
            release: true,
            scope: 'staging:project',
            timeout: const Duration(milliseconds: 1)),
        isFalse);
    expect(controls.calls, isNot(contains('write')));
    expect(controls.calls, isNot(contains('send')));
  });

  test('timing allowlist sends only operation, duration and outcome', () async {
    final sink = Sink();
    final diagnostics = MobileDiagnostics(sink, enabled: true);
    final interceptor = DiagnosticTimingInterceptor(diagnostics,
        apiOrigin: 'https://api.test', sample: () => 0);
    final options = RequestOptions(
        baseUrl: 'https://api.test',
        path: '/v1/driver/trips/private-trip/positions?token=secret',
        method: 'POST',
        data: {'latitude': 5.1, 'longitude': -0.2},
        headers: {'Authorization': 'Bearer secret'});
    final request = RequestInterceptorHandler();
    interceptor.onRequest(options, request);
    expect(request.isCompleted, isTrue);
    final response = ResponseInterceptorHandler();
    interceptor.onResponse(
        Response(requestOptions: options, statusCode: 200, data: 'private'),
        response);
    expect(response.isCompleted, isTrue);
    await drain();
    expect(sink.timings.single.$1, Operation.uploadPosition);
    expect(sink.timings.single.$3, Outcome.success);
  });

  test('unknown paths, external hosts and unsampled requests are excluded',
      () async {
    final sink = Sink();
    final diagnostics = MobileDiagnostics(sink, enabled: true);
    var sample = 0.0;
    final interceptor = DiagnosticTimingInterceptor(diagnostics,
        apiOrigin: 'https://api.test', sample: () => sample);
    for (final path in [
      '/v1/me/profile',
      '/v1/auth/login',
      'https://evil.test/v1/me/reservations'
    ]) {
      final options = RequestOptions(baseUrl: 'https://api.test', path: path);
      interceptor.onRequest(options, RequestInterceptorHandler());
      interceptor.onResponse(Response(requestOptions: options, statusCode: 200),
          ResponseInterceptorHandler());
    }
    sample = 0.1;
    final options = RequestOptions(
        baseUrl: 'https://api.test', path: '/v1/me/reservations');
    interceptor.onRequest(options, RequestInterceptorHandler());
    interceptor.onResponse(Response(requestOptions: options, statusCode: 200),
        ResponseInterceptorHandler());
    await drain();
    expect(sink.timings, isEmpty);
  });

  test('all allowed operations have fixed names, with bounded in-flight state',
      () async {
    final sink = Sink();
    final diagnostics = MobileDiagnostics(sink, enabled: true);
    final interceptor = DiagnosticTimingInterceptor(diagnostics,
        apiOrigin: 'https://api.test', sample: () => 0);
    for (final (path, method, operation) in [
      ('/v1/me/reservations', 'GET', Operation.loadReservations),
      ('/v1/me/membership', 'GET', Operation.loadMembership),
      ('/v1/me/reservation-decisions', 'POST', Operation.decideRide),
      ('/v1/trips/private/live', 'GET', Operation.trackBus),
      ('/v1/driver/trips/private/positions', 'POST', Operation.uploadPosition),
    ]) {
      final options = RequestOptions(
          baseUrl: 'https://api.test', path: path, method: method);
      interceptor.onRequest(options, RequestInterceptorHandler());
      interceptor.onResponse(Response(requestOptions: options, statusCode: 200),
          ResponseInterceptorHandler());
      await drain();
      expect(sink.timings.last.$1, operation);
    }
    sink.timings.clear();
    final requests = List.generate(
        50,
        (_) => RequestOptions(
            baseUrl: 'https://api.test', path: '/v1/me/reservations'));
    for (final request in requests) {
      interceptor.onRequest(request, RequestInterceptorHandler());
    }
    for (final request in requests) {
      interceptor.onResponse(Response(requestOptions: request, statusCode: 200),
          ResponseInterceptorHandler());
      await drain();
    }
    expect(sink.timings, hasLength(32));
  });

  test('failed upload or performance enable is contained', () async {
    for (final failed in ['send', 'performance:true']) {
      final controls = Controls();
      await prepareDiagnostics(controls,
          release: true, scope: 'staging:project');
      await prepareDiagnostics(controls,
          release: true, scope: 'staging:project');
      controls.calls.clear();
      controls.failure = failed;
      expect(
          await prepareDiagnostics(controls,
              release: true, scope: 'staging:project'),
          isFalse);
      expect(controls.calls.last, failed);
    }
  });

  test('disabling reporting suppresses in-flight measurements', () async {
    final sink = Sink();
    final diagnostics = MobileDiagnostics(sink, enabled: true);
    final interceptor = DiagnosticTimingInterceptor(diagnostics,
        apiOrigin: 'https://api.test', sample: () => 0);
    final options = RequestOptions(
        baseUrl: 'https://api.test', path: '/v1/me/reservations');
    interceptor.onRequest(options, RequestInterceptorHandler());
    diagnostics.enabled = false;
    interceptor.onResponse(Response(requestOptions: options, statusCode: 200),
        ResponseInterceptorHandler());
    await drain();
    expect(sink.timings, isEmpty);
  });

  test('failed requests advance even while provider is hung', () async {
    final sink = Sink()..fail = () => Completer<void>().future;
    final diagnostics = MobileDiagnostics(sink,
        enabled: true, timeout: const Duration(milliseconds: 1));
    final interceptor = DiagnosticTimingInterceptor(diagnostics,
        apiOrigin: 'https://api.test', sample: () => 0);
    final options = RequestOptions(
        baseUrl: 'https://api.test',
        path: '/v1/me/reservation-decisions',
        method: 'POST');
    interceptor.onRequest(options, RequestInterceptorHandler());
    final handler = ObservedErrorHandler();
    final completion = handler.observe();
    interceptor.onError(
        DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 409)),
        handler);
    expect(handler.isCompleted, isTrue);
    // Consume the intentionally forwarded transport error.
    await completion;
    expect(sink.timings.single.$3, Outcome.rejected);
    await Future<void>.delayed(const Duration(milliseconds: 5));
  });
}
