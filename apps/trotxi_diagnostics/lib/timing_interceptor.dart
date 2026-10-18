import 'dart:math';

import 'package:dio/dio.dart';

import 'diagnostics.dart';

/// A completed-request measurement, not an HTTP metric. URLs, query strings,
/// headers and payloads are used only locally and never passed to the sink.
class DiagnosticTimingInterceptor extends Interceptor {
  DiagnosticTimingInterceptor(this.diagnostics,
      {required this.apiOrigin, double Function()? sample})
      : _sample = sample ?? Random().nextDouble;

  final MobileDiagnostics diagnostics;
  final String apiOrigin;
  final double Function() _sample;
  final _running = <RequestOptions, (Operation, Stopwatch)>{};

  Operation? _operation(RequestOptions options) {
    final uri = options.uri;
    if (uri.origin != apiOrigin) return null;
    final path = uri.path;
    if (options.method == 'GET') {
      if (path == '/v1/me/reservations') return Operation.loadReservations;
      if (path == '/v1/me/membership') return Operation.loadMembership;
      if (RegExp(r'^/v1/trips/[^/]+/live$').hasMatch(path))
        return Operation.trackBus;
    }
    if (options.method == 'POST') {
      if (path == '/v1/me/reservation-decisions') return Operation.decideRide;
      if (RegExp(r'^/v1/driver/trips/[^/]+/positions$').hasMatch(path))
        return Operation.uploadPosition;
    }
    return null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      if (diagnostics.enabled && _running.length < 32 && _sample() < 0.1) {
        final operation = _operation(options);
        if (operation != null)
          _running[options] = (operation, Stopwatch()..start());
      }
    } catch (_) {/* Diagnostics must never block transport. */}
    handler.next(options);
  }

  Outcome _status(int? status) => status == null
      ? Outcome.networkError
      : status >= 500
          ? Outcome.serverError
          : status >= 400
              ? Outcome.rejected
              : Outcome.success;

  void _finish(RequestOptions options, Outcome outcome) {
    final running = _running.remove(options);
    if (running != null) {
      running.$2.stop();
      diagnostics.recordTiming(running.$1, running.$2.elapsed, outcome);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _finish(response.requestOptions, _status(response.statusCode));
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    _finish(
        error.requestOptions,
        error.type == DioExceptionType.cancel
            ? Outcome.cancelled
            : _status(error.response?.statusCode));
    handler.next(error);
  }
}
