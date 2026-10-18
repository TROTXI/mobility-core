import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum ErrorSource { framework, platform, zone }

enum Operation {
  loadReservations,
  loadMembership,
  decideRide,
  trackBus,
  uploadPosition
}

enum Outcome { success, rejected, serverError, networkError, cancelled }

/// The only application data a reporting provider may receive.
abstract interface class DiagnosticsSink {
  Future<void> error(String category, StackTrace stack, ErrorSource source,
      {required bool fatal});
  Future<void> timing(Operation operation, int milliseconds, Outcome outcome);
}

String errorCategory(Object error) => switch (error) {
      DioException e => 'network_${e.type.name}',
      FlutterError() => 'flutter_framework',
      FormatException() => 'invalid_format',
      StateError() => 'invalid_state',
      RangeError() => 'out_of_range',
      ArgumentError() => 'invalid_argument',
      TypeError() => 'type_error',
      _ => 'unhandled_error',
    };

/// Keep source locations, not exception text, absolute paths or URL data.
/// Strictly validated AOT addresses/build IDs remain for symbolication.
StackTrace safeStack(StackTrace stack) {
  final frames = <String>[];
  final source = RegExp(
    r'^#\d+\s+([A-Za-z0-9_.$<> =-]+)\s+\(((?:package:[A-Za-z0-9_/.-]+\.dart|dart:[A-Za-z0-9_/.-]+):\d+:\d+)\)$',
  );
  final aot = RegExp(
      r'^\s*#\d+ abs [0-9a-f]+(?: virt [0-9a-f]+)?(?: _kDart(?:Isolate|Vm)SnapshotInstructions\+0x[0-9a-f]+)?$');
  final build = RegExp(r"^build_id: '[0-9a-f]+'$");
  final bases = RegExp(
      r'^(?:isolate_dso_base: [0-9a-f]+, vm_dso_base: [0-9a-f]+|isolate_instructions: [0-9a-f]+, vm_instructions: [0-9a-f]+)$');
  for (final line in stack.toString().split('\n').take(100)) {
    final match = source.firstMatch(line);
    if (match != null) {
      frames.add('#${frames.length} ${match[1]!.trim()} (${match[2]})');
    } else if (aot.hasMatch(line) ||
        build.hasMatch(line) ||
        bases.hasMatch(line)) {
      frames.add(line);
    }
    if (frames.length >= 40) break;
  }
  return StackTrace.fromString(frames.join('\n'));
}

/// Disabled by default. A caller must supply and enable an approved sink.
/// Budgets and a concurrency cap bound unavailable providers; provider errors
/// never enter application error handlers or delay a request.
class MobileDiagnostics {
  MobileDiagnostics(this.sink,
      {this.enabled = false, this.timeout = const Duration(seconds: 3)});

  final DiagnosticsSink sink;
  final Duration timeout;
  bool enabled;
  int _errors = 0;
  int _timings = 0;
  int _pending = 0;

  void report(Object error, StackTrace stack, ErrorSource source,
      {bool fatal = false}) {
    if (!enabled || _errors >= 20 || _pending >= 4) return;
    _errors++;
    // Do not evaluate error.toString(), context or informationCollector.
    _dispatch(() => sink.error(errorCategory(error), safeStack(stack), source,
        fatal: fatal));
  }

  void recordTiming(Operation operation, Duration elapsed, Outcome outcome) {
    if (!enabled || _timings >= 100 || _pending >= 4) return;
    _timings++;
    _dispatch(() => sink.timing(
        operation, elapsed.inMilliseconds.clamp(0, 300000), outcome));
  }

  void _dispatch(Future<void> Function() action) {
    _pending++;
    unawaited(() async {
      try {
        await Future<void>.sync(action).timeout(timeout);
      } catch (_) {
        // Optional diagnostics must never recursively report their own errors.
      } finally {
        _pending--;
      }
    }());
  }
}
