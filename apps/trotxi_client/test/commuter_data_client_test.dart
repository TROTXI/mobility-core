import 'dart:async';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:trotxi_client/commuter_data_client.dart';
import 'package:trotxi_client/scoped_token_store.dart';
import 'package:trotxi_client/trotxi_client.dart';

import 'commuter_session_client_test.dart' show Adapter, json, account, bodyOf;
import 'scoped_token_store_test.dart' show MemorySessionStorage, scope;
import 'commute_selection_test.dart' show choice;

const stamp = '2026-09-16T06:00:00Z';
Map<String, Object?> reservation(String id, {String direction = 'outbound'}) =>
    {
      'id': id,
      'tripId': 'trip-$id',
      'travelDate': '2026-09-16',
      'direction': direction,
      'status': 'reserved',
      'source': 'confirmation',
      'pickupOccurrenceId': 'occurrence-home',
      'dropoffOccurrenceId': 'occurrence-office',
      'createdAt': stamp,
      'updatedAt': stamp,
      'version': 1,
    };
Map<String, Object?> leg(String direction) => {
      'direction': direction,
      'scheduleId': 'schedule-$direction',
      'patternVersionId': 'version-$direction',
      'pickupOccurrenceId': '$direction-first-visit',
      'dropoffOccurrenceId': '$direction-second-visit',
    };
Map<String, Object?> commuteInput({String note = 'Moving home'}) => {
      'routeId': 'new-route',
      'legs': [leg('outbound'), leg('return')],
      'requestedDate': '2026-09-21',
      'pauseIfWaitlisted': false,
      'note': note,
    };
Map<String, Object?> commute(
        {String id = 'request', String status = 'submitted'}) =>
    {
      'id': id,
      'status': status,
      'requested': commuteInput(),
      'effectiveDate': null,
      'paused': false,
      'decisionNote': null,
      'createdAt': stamp,
      'updatedAt': stamp,
      'version': 1,
    };
Map<String, Object?> page(List<Object?> data, [String? next]) => {
      'data': data,
      'page': {'nextCursor': next},
    };
Map<String, Object?> pass({String id = 'seat'}) => {
      'reservationId': id,
      'tripId': 'trip',
      'qrToken': 'test-only-proof',
      'expiresAt': '2026-09-16T06:01:00Z',
      'boardingCode': 'A3BC',
    };

void main() {
  const metadata =
      ClientMetadata(app: 'commuter', build: 31, platform: 'android');
  late ScopedTokenStore store;
  late TrotxiApiClient client;
  late CommuterDataClient data;
  late List<RequestOptions> requests;
  late FutureOr<ResponseBody> Function(RequestOptions) reply;
  late int upgradeRequests;
  final from = Date(2026, 9, 16), to = Date(2026, 9, 22);
  CommuteRequestInput input({String note = 'Moving home'}) =>
      client.serializers.deserializeWith(
          CommuteRequestInput.serializer, commuteInput(note: note))!;

  setUp(() async {
    store = ScopedTokenStore(
        scope: scope(app: 'commuter'), storage: MemorySessionStorage());
    await store.saveTokens(accessToken: 'rider-a', refreshToken: 'refresh-a');
    client = TrotxiClientFactory.create(
        baseUrl: store.scope.baseUrl, tokenStore: store, metadata: metadata);
    requests = [];
    upgradeRequests = 0;
    reply = (_) => json(200, {'data': account()});
    client.dio.httpClientAdapter = Adapter((o) {
      requests.add(o);
      return reply(o);
    });
    data = CommuterDataClient(
        client: client,
        store: store,
        metadata: metadata,
        onUpgradeRequired: () => upgradeRequests++);
  });
  tearDown(() => data.dispose());

  test('profile retry retains its intent key after an uncertain response',
      () async {
    reply = (o) => throw DioException(
        requestOptions: o, type: DioExceptionType.receiveTimeout);
    await expectLater(
        data.updateAccount('New name'), throwsA(isA<OfflineException>()));
    final key = requests.single.headers['Idempotency-Key'];
    reply = (_) => json(200, {'data': account()});
    await data.updateAccount('New name');
    expect(requests.last.method, 'PATCH');
    expect(requests.last.path, '/v1/me');
    expect(bodyOf(requests.last), {'displayName': 'New name'});
    expect(requests.last.headers['Idempotency-Key'], key);
  });

  Session session(bool current) => Session((b) => b
    ..id = current ? 'this-session' : 'other-session'
    ..current = current
    ..createdAt = DateTime.parse(stamp)
    ..expiresAt = DateTime.utc(2030));

  test(
      'session discovery follows pages and revoking another device keeps this login',
      () async {
    reply = (o) => o.method == 'GET'
        ? json(
            200,
            page([
              client.serializers.serializeWith(Session.serializer,
                  session(o.queryParameters['cursor'] == null))
            ], o.queryParameters['cursor'] == null ? 'next' : null))
        : json(204, null);
    final sessions = await data.sessions();
    expect(sessions.map((s) => s.id), ['this-session', 'other-session']);
    await data.revokeSession(sessions.last);
    expect(requests.last.path, '/v1/me/sessions/other-session');
    expect(requests.last.method, 'DELETE');
    expect(await store.getAccessToken(), 'rider-a');
  });

  for (final erase in [false, true]) {
    Future<void> action() =>
        erase ? data.eraseAccount() : data.revokeSession(session(true));
    test(
        '${erase ? 'erasure' : 'current revocation'} clears only after an exact acknowledgement',
        () async {
      var clears = 0;
      store.onCleared = () => clears++;
      reply = (_) => json(200, null);
      await expectLater(
          action(),
          throwsA(
              isA<ApiException>().having((e) => e.statusCode, 'status', 502)));
      expect(await store.getAccessToken(), 'rider-a');
      final key = requests.single.headers['Idempotency-Key'];
      reply = (_) => json(204, null);
      await action();
      expect(requests.last.headers['Idempotency-Key'], key);
      expect(await store.getAccessToken(), isNull);
      expect(clears, 1);
    });

    test(
        'late ${erase ? 'erasure' : 'revocation'} response never clears a new rider',
        () async {
      final entered = Completer<void>(), release = Completer<void>();
      reply = (_) async {
        entered.complete();
        await release.future;
        return json(204, null);
      };
      final pending = action();
      final assertion =
          expectLater(pending, throwsA(isA<UnauthorizedException>()));
      await entered.future;
      await store.saveTokens(
          accessToken: 'new-rider', refreshToken: 'new-refresh');
      release.complete();
      await assertion;
      expect(await store.getAccessToken(), 'new-rider');
    });

    test(
        'acknowledged ${erase ? 'erasure' : 'revocation'} reports local storage failure honestly',
        () async {
      (store.storage as MemorySessionStorage).failDelete = true;
      reply = (_) => json(204, null);
      await expectLater(
          action(),
          throwsA(isA<ApiException>().having((e) => e.code, 'code',
              '${erase ? 'erasure' : 'revocation'}_accepted_local_clear_failed')));
      expect(await store.getAccessToken(), 'rider-a');
    });
  }

  test('catalog reads preserve schedule version and all route pages', () async {
    final c = choice();
    reply = (o) {
      switch (o.path) {
        case '/v1/routes':
          return json(
              200,
              page(
                  [client.serializers.serializeWith(Route.serializer, c.route)],
                  o.queryParameters['cursor'] == null ? 'next-route' : null));
        case '/v1/routes/corridor/schedules':
          return json(
              200,
              page([
                client.serializers
                    .serializeWith(Schedule.serializer, c.schedule)
              ]));
        case '/v1/route-patterns/outbound':
          return json(200, {
            'data':
                client.serializers.serializeWith(Pattern.serializer, c.pattern)
          });
        case '/v1/route-patterns/outbound/versions/operated-outbound':
          return json(200, {
            'data': client.serializers
                .serializeWith(PatternVersion.serializer, c.version)
          });
        default:
          return json(404, {
            'error': {'code': 'not_found', 'message': 'Missing'}
          });
      }
    };
    expect(await data.routes(), hasLength(2));
    final schedules = await data.schedules('corridor');
    expect(schedules.single.patternVersionId, 'operated-outbound');
    final pattern = await data.pattern('outbound');
    final version = await data.patternVersion(
        pattern.id, schedules.single.patternVersionId);
    expect(version.id, isNot(pattern.publishedVersionId));
    expect(version.stops.map((s) => s.id),
        ['outbound-visit-0', 'outbound-visit-1', 'outbound-visit-2']);
    expect(requests, hasLength(5));
  });

  test('purchase discovery is paginated with dates and keeps unresolved state',
      () async {
    Map<String, Object?> purchase(String id) => {
          'id': id,
          'plan': 'monthly',
          'state': 'awaiting_payment',
          'collectionState': 'unknown',
          'price': {'amountMinor': 26400, 'currency': 'GHS'},
          'appliedCredit': {'amountMinor': 1980, 'currency': 'GHS'},
          'cashDue': {'amountMinor': 24420, 'currency': 'GHS'},
          'checkout': null,
          'billingPeriodId': null,
          'failureCode': null,
          'createdAt': stamp,
        };
    reply = (o) => json(
        200,
        o.path.endsWith('/purchase-one')
            ? {'data': purchase('purchase-one')}
            : page([
                purchase(o.queryParameters['cursor'] == null
                    ? 'purchase-one'
                    : 'purchase-two')
              ], o.queryParameters['cursor'] == null ? 'next' : null));
    final rows = await data.purchases(from: from, to: to);
    expect(rows.map((r) => r.id), ['purchase-one', 'purchase-two']);
    for (final r in requests) {
      expect(r.queryParameters['fromDate'], '2026-09-16');
      expect(r.queryParameters['toDate'], '2026-09-22');
    }
    final row = await data.purchase(rows.first.id);
    expect(row.state, PurchaseStateEnum.awaitingPayment);
    expect(row.collectionState, PurchaseCollectionStateEnum.unknown);
    expect(row.cashDue.amountMinor, 24420);
    expect(row.billingPeriodId, isNull);
  });

  test(
      'trip read preserves the service date of a departure delayed past midnight',
      () async {
    reply = (_) => json(200, {
          'data': {
            'id': 'trip',
            'departureId': 'departure',
            'patternId': 'return',
            'serviceDate': '2026-09-16',
            'runNumber': 1,
            'routeId': 'corridor',
            'patternVersionId': 'operated-return',
            'direction': 'return',
            'scheduledAt': '2026-09-17T00:15:00Z',
            'status': 'scheduled',
            'vehicleLabel': null,
          }
        });
    final trip = await data.trip('trip');
    expect(requests.single.path, '/v1/trips/trip');
    expect(trip.serviceDate, Date(2026, 9, 16));
    expect(trip.scheduledAt.day, 17);
    expect(trip.direction, TripDirectionEnum.return_);
    expect(trip.vehicleLabel, isNull);
  });

  test('reservation decision and withdrawal send the reviewed commands',
      () async {
    reply = (o) => json(200, {
          'data': o.path.endsWith('/withdraw')
              ? commute(status: 'cancelled')
              : {'reservation': reservation('seat'), 'pass': null}
        });
    final result = await data.decideReservation(ReservationDecision((b) => b
      ..travelDate = from
      ..direction = ReservationDecisionDirectionEnum.outbound
      ..decision = ReservationDecisionDecisionEnum.confirm
      ..tripId = 'trip-seat'));
    expect(result.reservation.id, 'seat');
    expect(result.pass, isNull);
    expect(requests.single.path, '/v1/me/reservation-decisions');
    expect(bodyOf(requests.single), {
      'travelDate': '2026-09-16',
      'direction': 'outbound',
      'decision': 'confirm',
      'tripId': 'trip-seat'
    });
    final cancelled = await data.withdrawCommute('request');
    expect(requests.last.path, '/v1/me/commute-requests/request/withdraw');
    expect(cancelled.status, CommuteRequestStatusEnum.cancelled);
    expect(requests.last.headers['Idempotency-Key'],
        isNot(requests.first.headers['Idempotency-Key']));
  });

  test('rejects a backend/app scope mismatch before accessing storage', () {
    expect(
        () => CommuterDataClient(
            client: client,
            store: ScopedTokenStore(scope: scope()),
            metadata: metadata),
        throwsArgumentError);
    expect(
        () => CommuterDataClient(
            client: client,
            store: ScopedTokenStore(
                scope: scope(app: 'commuter', url: 'https://other.test')),
            metadata: metadata),
        throwsArgumentError);
  });

  test(
      'reservation pages keep both explicit dates and directions, with factory metadata',
      () async {
    reply = (o) => json(
        200,
        o.queryParameters['cursor'] == null
            ? page([reservation('one')], 'next-1')
            : page([reservation('two', direction: 'return')]));
    final rows = await data.reservations(from: from, to: to);
    expect(rows.map((r) => r.id), ['one', 'two']);
    expect(rows.map((r) => r.direction.name), ['outbound', 'return_']);
    expect(rows.first.pickupOccurrenceId, 'occurrence-home');
    expect(rows.first.travelDate, from);
    expect(requests, hasLength(2));
    for (final r in requests) {
      expect(r.path, '/v1/me/reservations');
      expect(r.queryParameters['fromDate'], '2026-09-16');
      expect(r.queryParameters['toDate'], '2026-09-22');
      expect(r.queryParameters['limit'], 200);
      final headers =
          r.headers.map((k, v) => MapEntry(k.toLowerCase(), v.toString()));
      expect(headers['authorization'], 'Bearer rider-a');
      expect(headers['x-trotxi-client'], 'commuter');
      expect(headers['x-trotxi-platform'], 'android');
      expect(headers['x-trotxi-build'], '31');
    }
    expect(() => rows.clear(), throwsUnsupportedError);
  });

  test(
      'commute status filter survives every page and paused is not inferred from status',
      () async {
    reply = (o) => json(
        200,
        page([
          {
            ...commute(
                id: o.queryParameters['cursor'] == null ? 'one' : 'two',
                status: 'waitlisted'),
            'paused': true
          }
        ], o.queryParameters['cursor'] == null ? 'next' : null));
    final rows =
        await data.commuteRequests(status: CommuteRequestStatusEnum.waitlisted);
    expect(rows, hasLength(2));
    expect(rows.every((r) => r.paused), isTrue);
    expect(requests.map((r) => r.queryParameters['status']),
        ['waitlisted', 'waitlisted']);
    expect(rows.first.requested.pauseIfWaitlisted, isFalse);
  });

  test('repeated cursor fails instead of returning a partial list or looping',
      () async {
    reply = (_) => json(200, page([], 'same'));
    await expectLater(
        data.reservations(from: from, to: to),
        throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'status', 502)));
    expect(requests, hasLength(2));
  });

  test(
      'legacy or malformed envelopes fail, never masquerade as empty account data',
      () async {
    for (final body in [
      account(),
      {
        'data': {'id': 'one'}
      },
      {'data': null}
    ]) {
      reply = (_) => json(200, body);
      await expectLater(
          data.account(),
          throwsA(
              isA<ApiException>().having((e) => e.statusCode, 'status', 502)));
    }
  });

  test('late old-session response cannot populate the new rider screen',
      () async {
    final entered = Completer<void>(), release = Completer<void>();
    reply = (_) async {
      entered.complete();
      await release.future;
      return json(200, {'data': account()});
    };
    final old = data.account();
    final assertion = expectLater(old, throwsA(isA<UnauthorizedException>()));
    await entered.future;
    await store.saveTokens(accessToken: 'rider-b', refreshToken: 'refresh-b');
    release.complete();
    await assertion;
    expect(await store.getAccessToken(), 'rider-b');
  });

  test('session switch between pages aborts the entire list', () async {
    reply = (_) async {
      await store.saveTokens(accessToken: 'rider-b', refreshToken: 'refresh-b');
      return json(200, page([reservation('one')], 'next'));
    };
    await expectLater(data.reservations(from: from, to: to),
        throwsA(isA<UnauthorizedException>()));
    expect(requests, hasLength(1));
  });

  for (final action in ['logout', 'dispose']) {
    test('$action while queued prevents the request from leaving', () async {
      final entered = Completer<void>(), release = Completer<void>();
      // Between auth storage reads and data admission, not a fake HTTP reply.
      client.dio.interceptors.insert(2,
          InterceptorsWrapper(onRequest: (o, h) async {
        entered.complete();
        await release.future;
        h.next(o);
      }));
      final pending = data.submitCommute(input());
      final assertion =
          expectLater(pending, throwsA(isA<UnauthorizedException>()));
      await entered.future;
      if (action == 'dispose') {
        data.dispose();
      } else {
        await store.clearTokens();
      }
      release.complete();
      await assertion;
      expect(requests, isEmpty);
    });
  }

  test(
      'commute request sends explicit schedule/version/occurrence legs and pause consent',
      () async {
    reply = (_) => json(201, {'data': commute()});
    final row = await data.submitCommute(input());
    expect(row.status, CommuteRequestStatusEnum.submitted);
    expect(requests.single.path, '/v1/me/commute-requests');
    expect(bodyOf(requests.single), commuteInput());
    expect(requests.single.headers['Idempotency-Key'],
        matches(RegExp(r'^[0-9a-f-]{36}$')));
  });

  test(
      'uncertain command keeps its key; success and changed intent use new keys',
      () async {
    reply = (o) => throw DioException(
        requestOptions: o, type: DioExceptionType.receiveTimeout);
    await expectLater(
        data.submitCommute(input()), throwsA(isA<OfflineException>()));
    final key = requests.single.headers['Idempotency-Key'];
    reply = (_) => json(201, {'data': commute()});
    await data.submitCommute(input());
    expect(requests.last.headers['Idempotency-Key'], key);
    await data.submitCommute(input());
    expect(requests.last.headers['Idempotency-Key'], isNot(key));
    await data.submitCommute(input(note: 'Other move'));
    expect(requests.last.headers['Idempotency-Key'],
        isNot(requests[2].headers['Idempotency-Key']));
  });

  test('malformed success keeps its key and does not report offline', () async {
    reply = (_) => json(201, {
          'data': {'id': 'created'}
        });
    await expectLater(
        data.submitCommute(input()),
        throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'status', 502)));
    final key = requests.single.headers['Idempotency-Key'];
    reply = (_) => json(201, {'data': commute()});
    await data.submitCommute(input());
    expect(requests.last.headers['Idempotency-Key'], key);
  });

  test('keys never cross a local identity change', () async {
    reply = (o) => throw DioException(
        requestOptions: o, type: DioExceptionType.connectionError);
    await expectLater(
        data.submitCommute(input()), throwsA(isA<OfflineException>()));
    final key = requests.single.headers['Idempotency-Key'];
    await store.saveTokens(accessToken: 'rider-b', refreshToken: 'refresh-b');
    reply = (_) => json(201, {'data': commute()});
    await data.submitCommute(input());
    expect(requests.last.headers['Idempotency-Key'], isNot(key));
    expect(requests.last.headers['Authorization'], 'Bearer rider-b');
  });

  test(
      'business refusal preserves stable code; 426 triggers upgrade without erasing credentials',
      () async {
    reply = (_) => json(409, {
          'error': {'code': 'rides_unavailable', 'message': 'No funded rides.'}
        });
    await expectLater(
        data.submitCommute(input()),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'rides_unavailable')));
    reply = (_) => json(426, {
          'error': {'code': 'upgrade_required', 'message': 'Update.'}
        });
    await expectLater(data.account(), throwsA(isA<UpgradeRequiredException>()));
    expect(upgradeRequests, 1);
    expect(await store.getAccessToken(), 'rider-a');
    expect(requests.any((r) => r.path.contains('/auth/refresh')), isFalse);
  });

  test(
      'pass is a reservation command with authoritative expiry, not a user-wide GET',
      () async {
    reply = (_) => json(200, {'data': pass()});
    final result = await data.issuePass('seat');
    expect(requests.single.path, '/v1/me/reservations/seat/pass');
    expect(requests.single.method, 'POST');
    expect(result.reservationId, 'seat');
    expect(result.expiresAt, DateTime.parse('2026-09-16T06:01:00Z'));
    expect(result.boardingCode, 'A3BC');
    reply = (_) => json(200, {'data': pass(id: 'other-seat')});
    await expectLater(data.issuePass('seat'), throwsA(isA<ApiException>()));
    final key = requests.last.headers['Idempotency-Key'];
    reply = (_) => json(200, {'data': pass()});
    await data.issuePass('seat');
    expect(requests.last.headers['Idempotency-Key'], key);
  });

  test('membership keeps monetary credit separate from rides and access blocks',
      () async {
    reply = (_) => json(200, {
          'data': {
            'membership': {'id': 'member', 'lifecycle': 'open'},
            'coverage': {
              'id': 'period',
              'startsAt': stamp,
              'endsAt': null,
              'state': 'open',
              'paused': true,
              'renewalMode': 'manual'
            },
            'lastCoverageEndedAt': null,
            'commute': null,
            'access': {
              'canReserve': false,
              'blocks': [
                {'kind': 'paused', 'scope': 'period', 'periodId': 'period'},
                {'kind': 'dispute', 'scope': 'period', 'periodId': 'period'},
              ]
            },
            'entitlements': {
              'remainingRides': 12,
              'credit': {'amountMinor': 1980, 'currency': 'GHS'},
              'heldCredit': {'amountMinor': 100, 'currency': 'GHS'},
              'availableCredit': {'amountMinor': 1880, 'currency': 'GHS'}
            }
          }
        });
    final member = await data.membership();
    expect(member.entitlements.remainingRides, 12);
    expect(member.entitlements.credit.amountMinor, 1980);
    expect(member.entitlements.availableCredit.amountMinor, 1880);
    expect(member.coverage!.paused, isTrue);
    expect(member.coverage!.state, MembershipCoverageStateEnum.open);
    expect(member.coverage!.endsAt, isNull);
    expect(member.access.canReserve, isFalse);
    expect(member.access.blocks.map((b) => b.kind),
        [AccessBlockKindEnum.paused, AccessBlockKindEnum.dispute]);
  });
}
