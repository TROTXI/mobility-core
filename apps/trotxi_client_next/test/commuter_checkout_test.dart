import 'dart:async';
import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:trotxi_client_next/commuter_checkout.dart';
import 'package:trotxi_client_next/commuter_data_client.dart';
import 'package:trotxi_client_next/scoped_token_store.dart';
import 'package:trotxi_client_next/trotxi_client_next.dart';
import 'commuter_session_client_test.dart' show Adapter, json, account, bodyOf;
import 'commuter_data_client_test.dart' show page, leg, stamp;
import 'scoped_token_store_test.dart' show MemorySessionStorage, scope;

Map<String, Object?> purchaseJson(
        {String id = 'purchase',
        String state = 'awaiting_payment',
        String collection = 'pending',
        String? url = 'https://checkout.paystack.com/test-only',
        String? expiresAt}) =>
    {
      'id': id,
      'plan': 'monthly',
      'state': state,
      'collectionState': collection,
      'price': {'amountMinor': 26400, 'currency': 'GHS'},
      'appliedCredit': {'amountMinor': 1980, 'currency': 'GHS'},
      'cashDue': {'amountMinor': 24420, 'currency': 'GHS'},
      'checkout': url == null ? null : {'url': url, 'expiresAt': expiresAt},
      'billingPeriodId': state == 'fulfilled' ? 'period' : null,
      'failureCode': null,
      'createdAt': '2025-01-01T00:00:00Z',
    };

void main() {
  late MemorySessionStorage storage;
  late ScopedTokenStore store;
  late TrotxiApiClientNext client;
  late CommuterDataClient data;
  late List<RequestOptions> sent;
  late List<Map<String, Object?>> rows;
  late FutureOr<ResponseBody> Function(RequestOptions) replyPost;
  late String accountSuffix;
  PurchaseInput input() =>
      client.serializers.deserializeWith(PurchaseInput.serializer, {
        'plan': 'monthly',
        'routeId': 'route',
        'legs': [leg('outbound'), leg('return')],
        'useCredit': true,
      })!;
  setUp(() async {
    storage = MemorySessionStorage();
    store = ScopedTokenStore(scope: scope(app: 'commuter'), storage: storage);
    await store.saveTokens(accessToken: 'a', refreshToken: 'r');
    const metadata =
        ClientMetadata(app: 'commuter', build: 31, platform: 'android');
    client = TrotxiClientFactory.create(
        baseUrl: store.scope.baseUrl, tokenStore: store, metadata: metadata);
    sent = [];
    rows = [];
    accountSuffix = '1';
    replyPost = (_) => json(201, {'data': purchaseJson()});
    client.dio.httpClientAdapter = Adapter((o) {
      sent.add(o);
      if (o.path == '/v1/me')
        return json(200, {'data': account(suffix: accountSuffix)});
      if (o.method == 'POST') return replyPost(o);
      if (o.path == '/v1/me/purchases') return json(200, page(rows));
      return json(200, {
        'data': rows.firstWhere((p) => o.path.endsWith('/${p['id']}'),
            orElse: () => purchaseJson())
      });
    });
    data = CommuterDataClient(client: client, store: store, metadata: metadata);
  });
  tearDown(() => data.dispose());
  List<RequestOptions> getPosts() =>
      sent.where((o) => o.method == 'POST').toList();

  test(
      'persist before POST; a recreated controller retries exactly the same key and body',
      () async {
    final checkout = await CommuterCheckout.open(data);
    replyPost = (o) {
      expect(storage.values[checkout.storageKey],
          contains(o.headers['Idempotency-Key']));
      throw DioException(
          requestOptions: o, type: DioExceptionType.receiveTimeout);
    };
    await expectLater(
        checkout.start(input()), throwsA(isA<OfflineException>()));
    final first = getPosts().single;
    checkout.dispose();
    final restarted = await CommuterCheckout.open(data);
    await restarted.recover();
    expect(getPosts(), hasLength(1)); // Recovery itself does not charge/create.
    replyPost = (_) => json(201, {'data': purchaseJson()});
    await restarted.retry();
    expect(getPosts().last.headers['Idempotency-Key'],
        first.headers['Idempotency-Key']);
    expect(bodyOf(getPosts().last), bodyOf(first));
    expect(restarted.intent!.purchaseId, 'purchase');
    expect(storage.values[restarted.storageKey],
        isNot(contains('checkout.paystack')));
  });

  test(
      'a failed secure write sends no purchase and can be retried after repair',
      () async {
    final checkout = await CommuterCheckout.open(data);
    storage.failWrite = true;
    await expectLater(checkout.start(input()), throwsStateError);
    expect(getPosts(), isEmpty);
    storage.failWrite = false;
    await checkout.start(input());
    expect(getPosts(), hasLength(1));
  });

  test('201 without a provider link keeps a replayable intent', () async {
    replyPost = (_) => json(201, {'data': purchaseJson(url: null)});
    final checkout = await CommuterCheckout.open(data);
    final p = await checkout.start(input());
    expect(p.checkout, isNull);
    final key = checkout.intent!.key;
    replyPost = (_) => json(201, {'data': purchaseJson()});
    final withLink = await checkout.retry();
    expect(checkout.intent!.key, key);
    expect(withLink.checkout, isNotNull);
  });

  test(
      'server history finds an old unresolved purchase with no local journal and blocks a new one',
      () async {
    rows = [purchaseJson()]; // Older than the former 90-day window.
    final checkout = await CommuterCheckout.open(data);
    await checkout.recover();
    expect(checkout.purchases.single.createdAt, DateTime.utc(2025));
    expect(sent.last.queryParameters.containsKey('fromDate'), isFalse);
    expect(sent.last.queryParameters.containsKey('toDate'), isFalse);
    await expectLater(
        checkout.start(input()),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'purchase_unresolved')));
    expect(getPosts(), isEmpty);
  });

  test('two controllers cannot overwrite the same saved intent', () async {
    final a = await CommuterCheckout.open(data),
        b = await CommuterCheckout.open(data);
    final gate = Completer<void>(), entered = Completer<void>();
    replyPost = (_) async {
      entered.complete();
      await gate.future;
      return json(201, {'data': purchaseJson()});
    };
    final first = a.start(input());
    await entered.future;
    final second = b.start(input());
    final secondCheck = expectLater(
        second,
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'purchase_unresolved')));
    gate.complete();
    await first;
    await secondCheck;
    expect(getPosts(), hasLength(1));
  });

  test(
      'only a server terminal state clears saved intent; successful collection alone does not',
      () async {
    final checkout = await CommuterCheckout.open(data);
    await checkout.start(input());
    rows = [purchaseJson(state: 'processing', collection: 'successful')];
    await checkout.recover();
    expect(checkout.intent, isNotNull);
    rows = [purchaseJson(state: 'fulfilled', collection: 'successful')];
    await checkout.recover();
    expect(checkout.intent, isNull);
    expect(storage.values.containsKey(checkout.storageKey), isFalse);
    expect(getPosts(), hasLength(1));
  });

  test('expired retry key is retained and never silently replaced', () async {
    final checkout = await CommuterCheckout.open(data);
    await checkout.start(input());
    final key = checkout.intent!.key;
    replyPost = (_) => json(409, {
          'error': {'code': 'idempotency_expired', 'message': 'Expired'}
        });
    await expectLater(checkout.retry(), throwsA(isA<ApiException>()));
    expect(checkout.intent!.key, key);
    expect(getPosts().last.headers['Idempotency-Key'], key);
  });

  test(
      'new login cannot send an old controller command; accounts have separate journal namespaces',
      () async {
    final checkout = await CommuterCheckout.open(data);
    await checkout.start(input());
    await store.saveTokens(accessToken: 'b', refreshToken: 's');
    accountSuffix = '2';
    await expectLater(checkout.retry(), throwsA(isA<UnauthorizedException>()));
    expect(getPosts(), hasLength(1));
    final next = await CommuterCheckout.open(data);
    await next.recover();
    expect(next.storageKey, isNot(checkout.storageKey));
    expect(next.intent, isNull);
    expect(storage.values.containsKey(checkout.storageKey), isTrue);
    final other = ScopedTokenStore(
        scope: scope(app: 'commuter', realm: 'other-db'), storage: storage);
    expect(checkout.storageKey.startsWith(other.scope.storageKey), isFalse);
  });

  test(
      'a late response after logout does not announce or overwrite the new session',
      () async {
    final checkout = await CommuterCheckout.open(data);
    final gate = Completer<void>(), entered = Completer<void>();
    replyPost = (_) async {
      entered.complete();
      await gate.future;
      return json(201, {'data': purchaseJson()});
    };
    final pending = checkout.start(input());
    final assertion =
        expectLater(pending, throwsA(isA<UnauthorizedException>()));
    await entered.future;
    await store.clearTokens();
    gate.complete();
    await assertion;
    expect(checkout.intent!.purchaseId,
        isNull); // Original key/input still recoverable after sign-in.
    expect(await store.getAccessToken(), isNull);
  });

  test('corrupt intent fails closed without overwriting it or POSTing',
      () async {
    final checkout = await CommuterCheckout.open(data);
    storage.values[checkout.storageKey] = '{bad';
    await expectLater(checkout.start(input()), throwsA(isA<ApiException>()));
    expect(storage.values[checkout.storageKey], '{bad');
    expect(getPosts(), isEmpty);
  });

  test('erasure cleanup leaves unrelated records alone', () async {
    final checkout = await CommuterCheckout.open(data);
    await checkout.start(input());
    storage.values['unrelated'] = 'retained';
    await CommuterCheckout.clearErasedAccount(data, account()['id'] as String);
    expect(storage.values.containsKey(checkout.storageKey), isFalse);
    expect(storage.values['unrelated'], 'retained');
    expect(await store.getAccessToken(), 'a');
  });

  test('erasure waits for an old journal write before removing it', () async {
    final checkout = await CommuterCheckout.open(data);
    storage.writeEntered = Completer<void>();
    storage.writeGate = Completer<void>();
    final starting = checkout.start(input());
    final rejected =
        expectLater(starting, throwsA(isA<UnauthorizedException>()));
    await storage.writeEntered!.future;
    await store.clearTokens();
    var erased = false;
    final clearing =
        CommuterCheckout.clearErasedAccount(data, account()['id'] as String)
            .then((_) => erased = true);
    await Future<void>.delayed(Duration.zero);
    expect(erased, isFalse);
    storage.writeGate!.complete();
    await rejected;
    await clearing;
    expect(storage.values.containsKey(checkout.storageKey), isFalse);
    expect(getPosts(), isEmpty);
  });

  test(
      'Paystack link guard refuses wrong hosts, credentials, ports, schemes, expired and nonpayable states',
      () {
    Purchase p(Map<String, Object?> raw) =>
        client.serializers.deserializeWith(Purchase.serializer, raw)!;
    final now = DateTime.parse(stamp);
    expect(paystackCheckoutUri(p(purchaseJson()), now)!.host,
        'checkout.paystack.com');
    for (final url in [
      'http://checkout.paystack.com/x',
      'https://checkout.paystack.com.attacker.test/x',
      'https://attacker.test/x',
      'https://a@checkout.paystack.com/x',
      'https://checkout.paystack.com:444/x',
      'javascript:alert(1)',
      'https://checkout.paystack.com/x#forged'
    ]) {
      expect(paystackCheckoutUri(p(purchaseJson(url: url)), now), isNull,
          reason: url);
    }
    expect(paystackCheckoutUri(p(purchaseJson(expiresAt: stamp)), now), isNull);
    for (final state in [
      'fulfilled',
      'processing',
      'failed',
      'cancelled',
      'review_required'
    ]) {
      expect(paystackCheckoutUri(p(purchaseJson(state: state)), now), isNull);
    }
    expect(paystackCheckoutUri(p(purchaseJson(collection: 'successful')), now),
        isNull);
  });
}
