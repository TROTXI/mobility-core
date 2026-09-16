import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:trotxi_client_next/trotxi_client_next.dart' as wire;
import 'package:trotxi_client_next/scoped_token_store.dart';
import 'package:uuid/uuid.dart';

export 'package:trotxi_client_next/trotxi_client_next.dart'
    show
        TrotxiException,
        ApiException,
        OfflineException,
        UnauthorizedException,
        InvalidCredentialsException,
        CredentialLockedException,
        AccountSuspendedException,
        RateLimitException,
        UpgradeRequiredException,
        TokenStore,
        ClientMetadata;

/// App transport over the reviewed generated serializers. No legacy paths,
/// token import, or fallback backend. All repositories share this instance.
class DriverApi {
  DriverApi({
    required this.client,
    required this.store,
    required this.metadata,
  }) {
    final admission = InterceptorsWrapper(
      onRequest: (request, handler) {
        final generation = request.extra['driver.sessionGeneration'];
        // Runs after auth has read secure storage, before a request can leave.
        if (generation != null && generation != store.generation) {
          return handler.reject(
            DioException(
              requestOptions: request,
              error: const wire.UnauthorizedException(),
            ),
          );
        }
        handler.next(request);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 426 ||
            error.error is wire.UpgradeRequiredException) {
          upgradeRequired.value = true;
        }
        handler.next(error);
      },
    );
    // ErrorInterceptor rejects mapped failures terminally. Observe admission
    // before it, including a 426 returned by the isolated refresh request.
    final index = client.dio.interceptors.indexWhere(
      (i) => i is wire.ErrorInterceptor,
    );
    client.dio.interceptors.insert(
      index < 0 ? client.dio.interceptors.length : index,
      admission,
    );
  }

  final wire.TrotxiApiClientNext client;
  final ScopedTokenStore store;
  final wire.ClientMetadata metadata;
  final upgradeRequired = ValueNotifier(false);
  Dio get dio => client.dio;
  final Map<String, wire.DriverTrip> trips = {};
  final Map<String, String> routeNames = {};
  final Map<String, String> _pending = {};
  int? _generation;
  int get sessionGeneration => _sync();
  void ensureSession(int generation) => _check(generation);

  int _sync() {
    if (_generation != store.generation) {
      trips.clear();
      routeNames.clear();
      _pending.clear();
      _generation = store.generation;
    }
    return store.generation;
  }

  void _check(int generation) {
    if (generation != store.generation) {
      throw const wire.UnauthorizedException();
    }
  }

  T _decode<T>(Serializer<T> serializer, Object? data) {
    try {
      final result = client.serializers.deserializeWith(serializer, data);
      if (result != null) return result;
    } catch (_) {
      // Do not include server payloads (manifest photos, PINs, tokens) in logs.
    }
    throw const wire.ApiException(
      502,
      'The server returned an invalid response.',
    );
  }

  Future<T> get<T>(
    String path,
    Serializer<T> serializer, {
    Map<String, dynamic>? query,
  }) async {
    final generation = _sync();
    final Object? data;
    try {
      final response = await dio.get<Object?>(
        path,
        queryParameters: query,
        options: Options(extra: {'driver.sessionGeneration': generation}),
      );
      _check(generation);
      data = response.data;
    } on DioException catch (error) {
      throw unwrap(error);
    }
    // Decode outside the transport catch. T is generic, so newer analyzers
    // otherwise treat its return inside try as a potentially unawaited Future.
    return _decode(serializer, data);
  }

  /// Preserve a command's key across uncertain delivery in this session.
  /// No durable offline queue; a restart must reload authoritative state.
  Future<T> post<T>(
    String path,
    Serializer<T> serializer, {
    Map<String, dynamic>? body,
    String? ifMatch,
    bool command = true,
    CancelToken? cancelToken,
  }) async {
    final generation = _sync();
    final intent = jsonEncode([path, body, ifMatch]);
    final key = command
        ? _pending.putIfAbsent(intent, () => const Uuid().v4())
        : null;
    try {
      final response = await dio.post<Object?>(
        path,
        data: body,
        cancelToken: cancelToken,
        options: Options(
          extra: {'driver.sessionGeneration': generation},
          headers: {'Idempotency-Key': ?key, 'If-Match': ?ifMatch},
        ),
      );
      _check(generation);
      final result = _decode(serializer, response.data);
      _pending.remove(intent);
      return result;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (generation == store.generation &&
          status != null &&
          status >= 400 &&
          status < 500 &&
          status != 429) {
        _pending.remove(intent);
      }
      throw unwrap(error);
    }
  }

  /// Follow every page with the same filters. A repeated cursor is a protocol
  /// error, never a successful partial list or an infinite request loop.
  Future<List<T>> pages<P, T>(
    String path,
    Serializer<P> serializer,
    List<T> Function(P) rows,
    String? Function(P) next, {
    Map<String, dynamic> query = const {},
  }) async {
    final generation = _sync();
    final result = <T>[];
    final seen = <String>{};
    String? cursor;
    do {
      _check(generation);
      final page = await get(
        path,
        serializer,
        query: {...query, 'limit': 200, 'cursor': ?cursor},
      );
      result.addAll(rows(page));
      cursor = next(page);
      if (cursor != null && !seen.add(cursor)) {
        throw const wire.ApiException(
          502,
          'The server repeated a page cursor.',
        );
      }
    } while (cursor != null);
    _check(generation);
    return result;
  }

  Future<List<wire.DriverTrip>> assigned({
    String? from,
    String? to,
    String? routeId,
  }) async {
    final generation = _sync();
    final result = await pages(
      '/v1/driver/trips',
      wire.DriverTripPage.serializer,
      (p) => p.data.toList(),
      (p) => p.page.nextCursor,
      query: {'fromDate': ?from, 'toDate': ?to, 'routeId': ?routeId},
    );
    _check(generation);
    for (final trip in result) {
      trips[trip.id] = trip;
    }
    return result;
  }

  Future<wire.DriverTrip> trip(String id, {bool refresh = false}) async {
    final generation = _sync();
    final cached = trips[id];
    if (cached != null && !refresh) return cached;
    // The driver detail GET is deferred. A known trip's stored service date
    // is stable, even after a midnight delay or corridor archival. Only a cold
    // lookup needs the public catalogue to discover that date.
    var date = cached?.serviceDate.toString();
    var route = cached?.routeId;
    if (date == null) {
      final public = (await get(
        '/v1/trips/${Uri.encodeComponent(id)}',
        wire.TripResponse.serializer,
      )).data;
      date = public.serviceDate.toString();
      route = public.routeId;
    }
    _check(generation);
    final rows = await assigned(from: date, to: date, routeId: route);
    _check(generation);
    for (final row in rows) {
      if (row.id == id) return row;
    }
    trips.remove(id);
    throw const wire.ApiException(
      404,
      'This run is no longer assigned to you.',
    );
  }

  Future<String> routeName(String id) async {
    final generation = _sync();
    if (routeNames.containsKey(id)) return routeNames[id]!;
    final route = (await get(
      '/v1/routes/${Uri.encodeComponent(id)}',
      wire.RouteResponse.serializer,
    )).data;
    _check(generation);
    return routeNames[id] = route.name;
  }

  static Object unwrap(DioException error) =>
      error.error is wire.TrotxiException
      ? error.error!
      : const wire.ApiException(
          0,
          'Unable to complete the request. Please retry.',
        );
}
