import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only: prints every request and response, INCLUDING access/refresh
/// tokens, the Authorization header and OTP codes, so a failing call can be
/// replayed by hand against the Swagger docs. Does nothing in release builds.
/// Remove before sharing logs or screenshots.
class ApiDebugInterceptor extends Interceptor {
  static String _json(Object? value) {
    try {
      return jsonEncode(value);
    } catch (_) {
      return '$value';
    }
  }

  static void _log(String line) => debugPrint('[api] $line');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _log('--> ${options.method} ${options.uri}');
      _log('    headers: ${_json(options.headers)}');
      if (options.data != null) _log('    body: ${_json(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _log(
        '<-- ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}',
      );
      _log('    body: ${_json(response.data)}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _log(
        '<-- ERROR ${err.response?.statusCode} ${err.requestOptions.method} '
        '${err.requestOptions.uri} (${err.type.name})',
      );
      _log('    body: ${_json(err.response?.data)}');
      if (err.response == null) _log('    cause: ${err.error ?? err.message}');
    }
    handler.next(err);
  }
}
