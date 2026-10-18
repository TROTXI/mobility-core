import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'diagnostics.dart';

abstract interface class DiagnosticControls {
  Future<void> disableCrashUploads();
  Future<void> deleteReports();
  Future<bool> hasReports();
  Future<void> sendReports();
  Future<void> performance(bool enabled);
  Future<String?> readPolicy();
  Future<void> writePolicy(String policy);
}

/// Automatic crash uploads remain OFF, including on native cold starts.
/// A policy/project/build-mode transition discards legacy queued reports.
/// A later clean launch confirms the queue is empty before approving uploads.
/// Subsequent release starts explicitly upload the previous session's reports.
/// A failed cleanup/storage/provider operation fails closed.
Future<bool> prepareDiagnostics(
  DiagnosticControls controls, {
  required bool release,
  required String scope,
  Duration timeout = const Duration(seconds: 3),
}) async {
  Future<T> step<T>(Future<T> Function() call) =>
      Future<T>.sync(call).timeout(timeout);
  try {
    await step(controls.disableCrashUploads);
    await step(() => controls.performance(false));
    final policy =
        'safe-diagnostics-v1:$scope:${release ? 'release' : 'debug'}';
    final previous = await step(controls.readPolicy);
    if (!release) {
      await step(controls.deleteReports);
      await step(() => controls.writePolicy('$policy:pending'));
      return false;
    }
    if (previous != policy) {
      // Native deleteUnsentReports acknowledges scheduling, not completion.
      // Do not authorize uploads until a later launch observes an empty queue.
      if (await step(controls.hasReports)) {
        await step(controls.deleteReports);
        await step(() => controls.writePolicy('$policy:pending'));
        return false;
      }
      await step(() => controls.writePolicy(policy));
    } else {
      await step(controls.sendReports);
    }
    await step(() => controls.performance(true));
    return true;
  } catch (_) {
    return false;
  }
}

/// Only call after environment validation and successful Firebase init.
/// Setup is asynchronous and never delays app startup.
MobileDiagnostics startFirebaseDiagnostics(
    {required bool release, required String scope}) {
  final provider = _FirebaseProvider();
  final diagnostics = MobileDiagnostics(provider);
  unawaited(prepareDiagnostics(provider, release: release, scope: scope)
      .then((ready) {
    diagnostics.enabled = ready;
  }));
  return diagnostics;
}

class _FirebaseProvider implements DiagnosticsSink, DiagnosticControls {
  final _crashes = FirebaseCrashlytics.instance;
  final _performance = FirebasePerformance.instance;
  final _storage = const FlutterSecureStorage();
  static const _policyKey = 'trotxi.diagnostics.policy';

  @override
  Future<void> disableCrashUploads() =>
      _crashes.setCrashlyticsCollectionEnabled(false);
  @override
  Future<void> deleteReports() => _crashes.deleteUnsentReports();
  @override
  Future<bool> hasReports() => _crashes.checkForUnsentReports();
  @override
  Future<void> sendReports() => _crashes.sendUnsentReports();
  @override
  Future<void> performance(bool enabled) =>
      _performance.setPerformanceCollectionEnabled(enabled);
  @override
  Future<String?> readPolicy() => _storage.read(key: _policyKey);
  @override
  Future<void> writePolicy(String policy) =>
      _storage.write(key: _policyKey, value: policy);

  @override
  Future<void> error(String category, StackTrace stack, ErrorSource source,
          {required bool fatal}) =>
      _crashes.recordError(category, stack,
          reason: source.name, fatal: fatal, printDetails: false);

  @override
  Future<void> timing(
      Operation operation, int milliseconds, Outcome outcome) async {
    final trace = _performance.newTrace('operation_${operation.name}');
    await trace.start();
    // Completed-request measurement. Use duration_ms in Firebase; the trace's
    // own duration is emission overhead, not the measured request latency.
    trace.setMetric('duration_ms', milliseconds);
    trace.putAttribute('outcome', outcome.name);
    await trace.stop();
  }
}
