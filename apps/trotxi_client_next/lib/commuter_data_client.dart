import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'scoped_token_store.dart';
import 'trotxi_client_next.dart';

/// Commuter data over the generated replacement contract. All reads are
/// session-bound; an old screen cannot consume a new rider's response or send
/// a queued command with that rider's bearer. Native sign-in lives separately
/// in CommuterSessionClient. Neither boundary imports legacy credentials.
class CommuterDataClient {
  CommuterDataClient({
    required this.client,
    required this.store,
    required this.metadata,
    this.onUpgradeRequired,
  }) {
    metadata.validate();
    final scope = SessionScope(
        baseUrl: client.dio.options.baseUrl,
        app: metadata.app,
        realm: store.scope.realm);
    if (metadata.app != 'commuter' ||
        scope.storageKey != store.scope.storageKey) {
      throw ArgumentError('Commuter data client and storage scopes differ');
    }
    _admission = InterceptorsWrapper(onRequest: (request, handler) {
      final generation = request.extra[_generationKey];
      // Auth has finished reading secure storage before this interceptor.
      if (generation != null && (_disposed || generation != store.generation)) {
        return handler.reject(DioException(
            requestOptions: request, error: const UnauthorizedException()));
      }
      handler.next(request);
    }, onError: (error, handler) {
      if (!_disposed &&
          (error.response?.statusCode == 426 ||
              error.error is UpgradeRequiredException)) {
        onUpgradeRequired?.call();
      }
      handler.next(error);
    });
    final index =
        client.dio.interceptors.indexWhere((i) => i is ErrorInterceptor);
    client.dio.interceptors
        .insert(index < 0 ? client.dio.interceptors.length : index, _admission);
  }

  final TrotxiApiClientNext client;
  final ScopedTokenStore store;
  final ClientMetadata metadata;
  final void Function()? onUpgradeRequired;
  late final Interceptor _admission;
  static const _generationKey = 'commuter.sessionGeneration';
  final _pending = <String, String>{};
  int? _generation;
  bool _disposed = false;
  int _activeReads = 0;

  int get sessionGeneration {
    if (_disposed) throw StateError('Commuter data client is disposed');
    if (_generation != store.generation) {
      _pending.clear();
      _generation = store.generation;
    }
    return store.generation;
  }

  void ensureSession(int generation) {
    if (_disposed || generation != store.generation) {
      throw const UnauthorizedException();
    }
  }

  void dispose() {
    _disposed = true;
    _pending.clear();
    if (_activeReads == 0) client.dio.interceptors.remove(_admission);
    // A queued request must still pass admission after disposal. Keep that
    // guard installed until all requests started by this boundary settle.
    // The transport is shared with sign-in/logout. Do not close its adapter.
  }

  Object _failure(DioException error) {
    if (error.error is TrotxiException) return error.error!;
    // In particular, serializer failures are NOT a connectivity failure.
    return const ApiException(502, 'The server returned an invalid response.');
  }

  Future<T> _read<T>(
      Future<Response<T>> Function(Map<String, dynamic> extra) send) async {
    final generation = sessionGeneration;
    final T? data;
    _activeReads++;
    try {
      data = (await send({_generationKey: generation})).data;
    } on DioException catch (error) {
      ensureSession(generation);
      throw _failure(error);
    } finally {
      _activeReads--;
      if (_disposed && _activeReads == 0) {
        client.dio.interceptors.remove(_admission);
      }
    }
    ensureSession(generation);
    if (data == null) {
      throw const ApiException(502, 'The server returned an empty response.');
    }
    return data;
  }

  /// Same in-flight intent keeps its UUID after uncertain delivery (including
  /// malformed success responses). Success or definitive refusal releases it.
  /// This is not a durable offline queue: after restart, reload server state.
  Future<T> _command<T>(String operation, Object? input,
      Future<Response<T>> Function(String key, Map<String, dynamic> extra) send,
      {void Function(T)? validate}) async {
    final generation = sessionGeneration;
    final intent = jsonEncode([operation, input]);
    final key = _pending.putIfAbsent(intent, () => const Uuid().v4());
    final T data;
    try {
      data = await _read((extra) => send(key, extra));
      ensureSession(generation);
      validate?.call(data);
      if (_pending[intent] == key) _pending.remove(intent);
    } on DioException catch (error) {
      // _read unwraps transport failures, so normally the typed branch below
      // handles them. Keep this path for a synchronous generated-call failure.
      ensureSession(generation);
      throw _failure(error);
    } on ApiException catch (error) {
      ensureSession(generation);
      if (error.statusCode >= 400 &&
          error.statusCode < 500 &&
          error.statusCode != 429 &&
          _pending[intent] == key) {
        _pending.remove(intent);
      }
      rethrow;
    }
    return data;
  }

  Future<List<T>> _pages<P, T>(
    Future<Response<P>> Function(String? cursor, Map<String, dynamic> extra)
        send,
    Iterable<T> Function(P page) rows,
    String? Function(P page) next,
  ) async {
    final generation = sessionGeneration;
    final result = <T>[];
    final seen = <String>{};
    String? cursor;
    do {
      ensureSession(generation);
      final page = await _read((extra) => send(cursor, extra));
      ensureSession(generation);
      result.addAll(rows(page));
      cursor = next(page);
      if (cursor != null && !seen.add(cursor)) {
        throw const ApiException(502, 'The server repeated a page cursor.');
      }
    } while (cursor != null);
    return List.unmodifiable(result);
  }

  Future<Account> account() async =>
      (await _read((extra) => client.getSelfApi().getAccount(
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              extra: extra)))
          .data;

  Future<Account> updateAccount(String displayName) async => (await _command(
          'updateAccount',
          displayName,
          (key, extra) => client.getSelfApi().updateAccount(
              idempotencyKey: key,
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              profileUpdate: ProfileUpdate((b) => b.displayName = displayName),
              extra: extra)))
      .data;

  Future<List<Session>> sessions() => _pages(
      (cursor, extra) => client.getSelfApi().listSessions(
          xTrotxiClient: metadata.app,
          xTrotxiBuild: metadata.build,
          limit: 200,
          cursor: cursor,
          extra: extra),
      (page) => page.data,
      (page) => page.page.nextCursor);

  Future<Response<bool>> _ack(Future<Response<void>> request) async {
    final response = await request;
    if (response.statusCode != 204) {
      throw const ApiException(
          502, 'The server did not acknowledge the request.');
    }
    return Response(
        requestOptions: response.requestOptions, statusCode: 204, data: true);
  }

  Future<void> revokeSession(Session session) async {
    final generation = sessionGeneration;
    await _command(
        'revokeSession',
        session.id,
        (key, extra) => _ack(client.getSelfApi().revokeSession(
            id: session.id,
            idempotencyKey: key,
            xTrotxiClient: metadata.app,
            xTrotxiBuild: metadata.build,
            extra: extra)));
    if (session.current)
      await _clearAcknowledgedSession(generation, 'revocation');
  }

  /// 204 acknowledges account erasure and queued external cleanup. It does
  /// not prove that every private object/backup has already been removed.
  Future<void> eraseAccount() async {
    final generation = sessionGeneration;
    await _command(
        'eraseAccount',
        null,
        (key, extra) => _ack(client.getSelfApi().eraseAccount(
            idempotencyKey: key,
            xTrotxiClient: metadata.app,
            xTrotxiBuild: metadata.build,
            extra: extra)));
    await _clearAcknowledgedSession(generation, 'erasure');
  }

  Future<void> _clearAcknowledgedSession(
      int generation, String operation) async {
    try {
      await store.clearTokensIfGenerationMatches(generation);
    } catch (_) {
      // The server already accepted the command. Do not describe an OS
      // keystore failure as a failed erasure/revocation or undo that fact.
      throw ApiException(0,
          'The server accepted $operation, but this device could not clear its session. Please sign out again.',
          code: '${operation}_accepted_local_clear_failed');
    }
  }

  Future<Membership> membership() async =>
      (await _read((extra) => client.getRiderOwnApi().getMembership(
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              extra: extra)))
          .data;

  /// Date bounds are mandatory. The backend's default window is not the
  /// app's "today", and the phone's timezone must not select a direction.
  Future<List<Reservation>> reservations(
          {required Date from, required Date to}) =>
      _pages(
          (cursor, extra) => client.getRiderOwnApi().listReservations(
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              fromDate: from,
              toDate: to,
              limit: 200,
              cursor: cursor,
              extra: extra),
          (page) => page.data,
          (page) => page.page.nextCursor);

  Future<List<CommuteRequest>> commuteRequests(
          {CommuteRequestStatusEnum? status}) =>
      _pages(
          (cursor, extra) => client.getRiderOwnApi().listCommuteRequests(
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              status: status?.name,
              limit: 200,
              cursor: cursor,
              extra: extra),
          (page) => page.data,
          (page) => page.page.nextCursor);

  /// Both omitted means all purchase history, including unresolved attempts
  /// older than a display window. The purchase service has no default cutoff.
  Future<List<Purchase>> purchases({Date? from, Date? to}) => _pages(
      (cursor, extra) => client.getRiderOwnApi().listPurchases(
          xTrotxiClient: metadata.app,
          xTrotxiBuild: metadata.build,
          fromDate: from,
          toDate: to,
          limit: 200,
          cursor: cursor,
          extra: extra),
      (page) => page.data,
      (page) => page.page.nextCursor);

  /// The caller must persist this key BEFORE sending; never auto-generate a
  /// new key when the result is uncertain or a provider URL is not yet ready.
  Future<Purchase> createPurchase(PurchaseInput input,
          {required String key}) async =>
      (await _read((extra) => client.getRiderOwnApi().createPurchase(
                idempotencyKey: key,
                xTrotxiClient: metadata.app,
                xTrotxiBuild: metadata.build,
                purchaseInput: input,
                extra: extra,
              )))
          .data;

  Future<Purchase> purchase(String id) async =>
      (await _read((extra) => client.getRiderOwnApi().getPurchase(
              id: id,
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              extra: extra)))
          .data;

  Future<List<Route>> routes() => _pages(
      (cursor, extra) => client.getPublicApi().listRoutes(
          xTrotxiClient: metadata.app,
          xTrotxiBuild: metadata.build,
          limit: 200,
          cursor: cursor,
          extra: extra),
      (page) => page.data,
      (page) => page.page.nextCursor);

  Future<List<Schedule>> schedules(String routeId) => _pages(
      (cursor, extra) => client.getPublicApi().listRouteSchedules(
          id: routeId,
          xTrotxiClient: metadata.app,
          xTrotxiBuild: metadata.build,
          limit: 200,
          cursor: cursor,
          extra: extra),
      (page) => page.data,
      (page) => page.page.nextCursor);

  Future<Pattern> pattern(String id) async =>
      (await _read((extra) => client.getPublicApi().getPattern(
              id: id,
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              extra: extra)))
          .data;

  Future<PatternVersion> patternVersion(
          String patternId, String versionId) async =>
      (await _read((extra) => client.getPublicApi().getPatternVersion(
              id: patternId,
              versionId: versionId,
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              extra: extra)))
          .data;

  Future<List<Trip>> trips(
          {required Date from, required Date to, String? routeId}) =>
      _pages(
          (cursor, extra) => client.getSignedInCatalogApi().listTrips(
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              fromDate: from,
              toDate: to,
              routeId: routeId,
              limit: 200,
              cursor: cursor,
              extra: extra),
          (page) => page.data,
          (page) => page.page.nextCursor);

  Future<Route> route(String id) async =>
      (await _read((extra) => client.getPublicApi().getRoute(
              id: id,
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              extra: extra)))
          .data;

  Future<Geometry> geometry(String id) async =>
      (await _read((extra) => client.getPublicApi().getGeometry(
              id: id,
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              extra: extra)))
          .data;

  /// Never substitute a cached location for a fresh authorization decision.
  Future<LiveTrip> liveTrip(String id) async =>
      (await _read((extra) => client.getLiveEligibleApi().getLiveTrip(
              id: id,
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              extra: extra)))
          .data;

  Future<Trip> trip(String id) async =>
      (await _read((extra) => client.getSignedInCatalogApi().getTrip(
              id: id,
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              extra: extra)))
          .data;

  Future<CommuteRequest> submitCommute(CommuteRequestInput input) async =>
      (await _command(
              'createCommuteRequest',
              client.serializers
                  .serializeWith(CommuteRequestInput.serializer, input),
              (key, extra) => client.getRiderOwnApi().createCommuteRequest(
                  idempotencyKey: key,
                  xTrotxiClient: metadata.app,
                  xTrotxiBuild: metadata.build,
                  commuteRequestInput: input,
                  extra: extra)))
          .data;

  Future<CommuteRequest> withdrawCommute(String id) async => (await _command(
          'withdrawCommuteRequest',
          id,
          (key, extra) => client.getRiderOwnApi().withdrawCommuteRequest(
              id: id,
              idempotencyKey: key,
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              extra: extra)))
      .data;

  Future<ReservationDecisionResult> decideReservation(
          ReservationDecision input) async =>
      (await _command(
              'decideReservation',
              client.serializers
                  .serializeWith(ReservationDecision.serializer, input),
              (key, extra) => client.getRiderOwnApi().decideReservation(
                  idempotencyKey: key,
                  xTrotxiClient: metadata.app,
                  xTrotxiBuild: metadata.build,
                  reservationDecision: input,
                  extra: extra)))
          .data;

  /// Pass identity is the reservation, never the user or just the trip.
  Future<Pass> issuePass(String reservationId) async {
    final pass = (await _command(
            'issuePass',
            reservationId,
            (key, extra) => client.getRiderOwnApi().issuePass(
                id: reservationId,
                idempotencyKey: key,
                xTrotxiClient: metadata.app,
                xTrotxiBuild: metadata.build,
                extra: extra), validate: (response) {
      if (response.data.reservationId != reservationId) {
        throw const ApiException(
            502, 'The server returned a pass for a different reservation.');
      }
    }))
        .data;
    return pass;
  }
}
