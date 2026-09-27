import { test } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { setup } from './helpers/financial-fixture.js';
import { FinancialFoundation } from '../src/payments/foundation.js';
import { MembershipService } from '../src/membership/service.js';
import { Pricing } from '../src/payments/pricing.js';
import { Purchases } from '../src/payments/purchases.js';
import { createTransportApp } from '../src/http/app.js';

type Response = { statusCode: number; body: string; json(): any };
function expectStatus(response: Response, code: number) {
  assert.equal(response.statusCode, code, response.body);
  return response.json().data;
}

/** A rider, an admin and a corridor, priced from the database rather than a stub. */
async function fixture(t: TestContext, target = true) {
  const f = await setup(t);
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [f.adminId]);
  const admin = { userId: f.adminId, sessionId: f.adminId };
  const pricing = new Pricing({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 11),
  });
  const membership = new MembershipService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 11),
    fareForSelection: pricing.fareForSelection,
  });
  const financial = new FinancialFoundation({
    ...f.dependencies,
    // The real seam: checkout prices itself from app.route_fares and
    // app.plan_pricing, with no quote stub in sight.
    quote: pricing.quote,
    assertCheckoutAllowed: membership.assertCheckoutAllowed,
    assertPeriodCanClose: membership.assertPeriodCanClose,
    materializeAssignment: membership.materializeAssignment,
  });
  let initialized = 0;
  const purchases = new Purchases({
    pool: f.runtime,
    financial,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 11),
    initializeCheckout: target
      ? async (request) => {
          initialized += 1;
          return {
            authorizationUrl: `https://checkout.example/pay/${request.reference}`,
            expiresAt: new Date(Date.now() + 3600_000),
          };
        }
      : undefined,
  });
  const app = await createTransportApp({
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 11),
    authorizeSession: f.dependencies.authorizeSession,
    coordinateReservations: membership.coordinateReservations,
    membership,
    pricing,
    purchases,
    verifyAccess: async (header) =>
      ({ 'Bearer rider': f.actor, 'Bearer other': f.other, 'Bearer ops': admin })[
        header as string
      ] ?? null,
    minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
  });
  t.after(() => app.close());
  const call = (
    method: 'GET' | 'POST' | 'PATCH',
    url: string,
    options: {
      who?: string;
      client?: 'commuter' | 'ops';
      payload?: unknown;
      key?: string;
      match?: string;
    } = {},
  ) =>
    app.inject({
      method,
      url,
      headers: {
        authorization: `Bearer ${options.who ?? 'rider'}`,
        'x-trotxi-client':
          options.client ?? ((options.who ?? 'rider') === 'ops' ? 'ops' : 'commuter'),
        'x-trotxi-build': '1',
        ...((options.client ?? ((options.who ?? 'rider') === 'ops' ? 'ops' : 'commuter')) === 'ops'
          ? {}
          : { 'x-trotxi-platform': 'android' }),
        ...(method === 'GET' ? {} : { 'idempotency-key': options.key ?? randomUUID() }),
        ...(options.match ? { 'if-match': options.match } : {}),
      },
      ...(options.payload === undefined ? {} : { payload: options.payload as never }),
    }) as Promise<Response>;
  /** Publish a fare, because a corridor with no fare cannot be bought. */
  const publishFare = (amount: number, effectiveFrom = new Date(Date.now() - 86400000)) =>
    call('POST', `/v1/ops/routes/${f.input.routeId}/fares`, {
      who: 'ops',
      payload: {
        amount: { amountMinor: amount, currency: 'GHS' },
        effectiveFrom: effectiveFrom.toISOString(),
      },
    });
  return {
    ...f,
    admin,
    app,
    pricing,
    purchases,
    financial,
    membership,
    call,
    publishFare,
    initialized: () => initialized,
  };
}

test('QUOTE-01 preview matches checkout without creating financial state or calling the provider', async (t) => {
  const f = await fixture(t);
  expectStatus(await f.publishFare(600), 201);
  await f.grant(1000);
  const snapshot = async () =>
    (
      await f.owner.query(`SELECT
    (SELECT count(*) FROM app.memberships)::int memberships,
    (SELECT count(*) FROM app.purchases)::int purchases,
    (SELECT count(*) FROM app.credit_holds)::int holds,
    (SELECT count(*) FROM app.payment_attempts)::int attempts`)
    ).rows[0];
  const before = await snapshot();
  const quote = expectStatus(
    await f.call('POST', '/v1/me/purchase-quotes', {
      payload: { routeId: f.input.routeId, plan: 'monthly', useCredit: true },
    }),
    200,
  );
  assert.equal(quote.price.amountMinor, 26400);
  assert.equal(quote.appliedCredit.amountMinor, 1000);
  assert.equal(quote.cashDue.amountMinor, 25400);
  assert.equal(quote.binding, false);
  assert.equal(quote.renewalMode, 'manual');
  assert.equal(quote.ridesGranted, 44);
  assert.equal(f.initialized(), 0);
  assert.deepEqual(await snapshot(), before);
  const purchase = expectStatus(
    await f.call('POST', '/v1/me/purchases', { payload: f.input }),
    201,
  );
  for (const field of ['price', 'appliedCredit', 'cashDue'])
    assert.deepEqual(quote[field], purchase[field]);
  const held = expectStatus(
    await f.call('POST', '/v1/me/purchase-quotes', {
      payload: { routeId: f.input.routeId, plan: 'monthly', useCredit: true },
    }),
    200,
  );
  assert.equal(held.availableCredit.amountMinor, 0);
});

test('QUOTE-02 preview isolates riders and enforces minimum cash, role and current route', async (t) => {
  const f = await fixture(t);
  const payload = { routeId: f.input.routeId, plan: 'monthly', useCredit: true };
  assert.equal((await f.call('POST', '/v1/me/purchase-quotes', { payload })).statusCode, 409);
  expectStatus(await f.publishFare(600), 201);
  await f.grant(50000);
  const q = expectStatus(await f.call('POST', '/v1/me/purchase-quotes', { payload }), 200);
  assert.equal(q.cashDue.amountMinor, 100);
  assert.equal(q.appliedCredit.amountMinor, 26300);
  const other = expectStatus(
    await f.call('POST', '/v1/me/purchase-quotes', { payload, who: 'other' }),
    200,
  );
  assert.equal(other.availableCredit.amountMinor, 0);
  assert.equal(
    (await f.call('POST', '/v1/me/purchase-quotes', { payload, who: 'ops', client: 'commuter' }))
      .statusCode,
    403,
  );
  assert.equal(
    (await f.call('POST', '/v1/me/purchase-quotes', { payload: { ...payload, price: 1 } }))
      .statusCode,
    400,
  );
  await f.owner.query('UPDATE app.routes SET archived_at=clock_timestamp() WHERE id=$1', [
    f.input.routeId,
  ]);
  assert.equal((await f.call('POST', '/v1/me/purchase-quotes', { payload })).statusCode, 404);
});

test('LEDGER-01 own history is paginated, scoped and carries the declared schemas', async (t) => {
  const f = await fixture(t);
  await f.grant(1000);
  await f.grant(2000);
  const first = await f.call('GET', '/v1/me/credit-entries?limit=1');
  assert.equal(first.statusCode, 200, first.body);
  assert.equal(first.json().data[0].currency, 'GHS');
  const cursor = encodeURIComponent(first.json().page.nextCursor);
  const second = await f.call('GET', `/v1/me/credit-entries?limit=1&cursor=${cursor}`);
  assert.equal(second.statusCode, 200, second.body);
  assert.notEqual(first.json().data[0].id, second.json().data[0].id);
  assert.equal(second.json().page.nextCursor, null);
  assert.equal(
    (await f.call('GET', `/v1/me/credit-entries?cursor=${cursor}`, { who: 'other' })).statusCode,
    400,
  );
  assert.equal((await f.call('GET', `/v1/me/ride-entries?cursor=${cursor}`)).statusCode, 400);
  assert.deepEqual(
    (await f.call('GET', '/v1/me/credit-entries', { who: 'other' })).json().data,
    [],
  );
  const purchase = await f.buy();
  await f.service.fulfill(f.settle(purchase));
  const rides = await f.call('GET', '/v1/me/ride-entries');
  assert.equal(rides.statusCode, 200, rides.body);
  assert.equal(rides.json().data.length, 1);
  assert.equal(rides.json().data[0].deltaRides, 44);
  assert.equal(rides.json().data[0].reason, 'allocation');
});
test('PRC-01 a corridor with no published fare cannot be bought', async (t) => {
  const f = await fixture(t);
  const refused = await f.call('POST', '/v1/me/purchases', { payload: f.input });
  assert.equal(refused.statusCode, 409, refused.body);
  assert.equal(refused.json().error.code, 'pricing_unavailable');
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.purchases')).rows[0].n,
    0,
    'nothing is created for a price that does not exist',
  );
});

test('PRC-02 checkout freezes the fare in force, and a later change does not reprice it', async (t) => {
  const f = await fixture(t);
  expectStatus(await f.publishFare(600), 201);
  const first = expectStatus(await f.call('POST', '/v1/me/purchases', { payload: f.input }), 201);
  assert.equal(first.price.amountMinor, 600 * 44);
  assert.equal(first.price.currency, 'GHS');
  assert.equal(
    first.cashDue.amountMinor,
    first.price.amountMinor - first.appliedCredit.amountMinor,
  );
  assert.equal(first.checkout.url.startsWith('https://checkout.example/pay/'), true);
  assert.equal(first.collectionState, 'pending');
  assert.equal(first.billingPeriodId, null);

  // A new fare closes the old one rather than overwriting it.
  expectStatus(await f.publishFare(900, new Date(Date.now() + 3600_000)), 201);
  const frozen = (
    await f.owner.query('SELECT fare_pesewas,price_pesewas FROM app.purchases WHERE id=$1', [
      first.id,
    ])
  ).rows[0];
  assert.equal(frozen.fare_pesewas, 600, 'the purchase keeps the fare it was priced at');
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.route_fares WHERE effective_to IS NULL'))
      .rows[0].n,
    1,
    'exactly one fare is open at a time',
  );
});

test('PRC-03 a repeated checkout key is one purchase and one provider call', async (t) => {
  const f = await fixture(t);
  expectStatus(await f.publishFare(600), 201);
  const key = randomUUID();
  const first = expectStatus(
    await f.call('POST', '/v1/me/purchases', { payload: f.input, key }),
    201,
  );
  const again = expectStatus(
    await f.call('POST', '/v1/me/purchases', { payload: f.input, key }),
    201,
  );
  assert.equal(again.id, first.id);
  assert.equal(again.checkout.url, first.checkout.url);
  assert.equal((await f.owner.query('SELECT count(*)::int n FROM app.purchases')).rows[0].n, 1);
  assert.equal(f.initialized(), 1, 'the provider is asked once, not once per retry');
  // The same key with different input is a conflict, not a second purchase.
  const conflict = await f.call('POST', '/v1/me/purchases', {
    payload: { ...f.input, useCredit: !f.input.useCredit },
    key,
  });
  assert.equal(conflict.statusCode, 409, conflict.body);
});

test('PRC-04 a purchase is visible to its owner and to ops, and to nobody else', async (t) => {
  const f = await fixture(t);
  expectStatus(await f.publishFare(600), 201);
  const mine = expectStatus(await f.call('POST', '/v1/me/purchases', { payload: f.input }), 201);

  const listed = expectStatus(await f.call('GET', '/v1/me/purchases'), 200);
  assert.deepEqual(
    listed.map((p: any) => p.id),
    [mine.id],
  );
  assert.equal('riderId' in listed[0], false, 'the rider view names no rider');
  assert.equal('attempts' in listed[0], false, 'and carries no provider history');

  assert.equal(
    expectStatus(await f.call('GET', '/v1/me/purchases', { who: 'other' }), 200).length,
    0,
    'another rider sees none of it',
  );
  assert.equal(
    (await f.call('GET', `/v1/me/purchases/${mine.id}`, { who: 'other' })).statusCode,
    404,
  );

  const opsView = expectStatus(
    await f.call('GET', `/v1/ops/purchases/${mine.id}`, { who: 'ops' }),
    200,
  );
  assert.equal(opsView.riderId, f.actor.userId);
  assert.equal(opsView.attempts.length, 1);
  assert.equal(opsView.attempts[0].environment, 'test');
  assert.equal(opsView.attempts[0].status, 'pending');
  assert.equal(opsView.attempts[0].providerTransactionId, null);
  // Client metadata is validated before authorization, so the refusal a rider
  // meets on an ops path depends on which claim they get wrong first.
  assert.equal(
    (await f.call('GET', `/v1/ops/purchases/${mine.id}`)).statusCode,
    400,
    'a commuter client has no business on an ops path',
  );
  assert.equal(
    (await f.call('GET', `/v1/ops/purchases/${mine.id}`, { client: 'ops' })).statusCode,
    403,
    'and a rider token is refused there whatever it claims to be',
  );
});

test('PRC-05 purchase list filters are real and bound to the cursor', async (t) => {
  const f = await fixture(t);
  expectStatus(await f.publishFare(600), 201);
  expectStatus(await f.call('POST', '/v1/me/purchases', { payload: f.input }), 201);
  const today = new Date().toISOString().slice(0, 10);
  assert.equal(
    expectStatus(await f.call('GET', `/v1/me/purchases?fromDate=${today}&toDate=${today}`), 200)
      .length,
    1,
  );
  assert.equal(
    expectStatus(await f.call('GET', '/v1/me/purchases?fromDate=2030-01-01&toDate=2030-01-02'), 200)
      .length,
    0,
    'a window that excludes it excludes it',
  );
  assert.equal((await f.call('GET', '/v1/me/purchases?fromDate=2026-02-30')).statusCode, 400);
  assert.equal(
    (await f.call('GET', '/v1/me/purchases?fromDate=2030-01-05&toDate=2030-01-01')).statusCode,
    400,
  );
  assert.equal((await f.call('GET', '/v1/me/purchases?state=fulfilled')).statusCode, 400);
});

test('PRC-06 plan pricing is edited under its own token and recorded', async (t) => {
  const f = await fixture(t);
  const listed = expectStatus(await f.call('GET', '/v1/ops/plan-pricing', { who: 'ops' }), 200);
  const monthly = listed.find((p: any) => p.plan === 'monthly');
  assert.partialDeepStrictEqual(monthly, { ridesPerPeriod: 44, priceMultiplierBp: 10000 });
  assert.match(monthly.editToken, /^"pricing:monthly:\d+"$/);

  assert.equal(
    (
      await f.call('PATCH', '/v1/ops/plan-pricing/monthly', {
        who: 'ops',
        payload: { ridesPerPeriod: 40 },
      })
    ).statusCode,
    428,
    'an edit without a token is refused',
  );
  const current = (
    await f.owner.query('SELECT version FROM app.plan_pricing WHERE plan=$1', ['monthly'])
  ).rows[0].version;
  const edited = expectStatus(
    await f.call('PATCH', '/v1/ops/plan-pricing/monthly', {
      who: 'ops',
      payload: { ridesPerPeriod: 40 },
      match: monthly.editToken,
    }),
    200,
  );
  assert.equal(edited.ridesPerPeriod, 40);
  assert.equal(edited.version, current + 1);
  assert.equal(
    (
      await f.call('PATCH', '/v1/ops/plan-pricing/monthly', {
        who: 'ops',
        payload: { ridesPerPeriod: 30 },
        match: `"pricing:monthly:${current}"`,
      })
    ).statusCode,
    412,
    'the stale token no longer works',
  );
  const events = (
    await f.owner.query('SELECT action,before_state,after_state FROM app.pricing_events')
  ).rows;
  assert.equal(events.length, 1);
  assert.equal(events[0].action, 'updatePlanPricing');
  assert.equal(events[0].before_state.ridesPerPeriod, 44);
  assert.equal(events[0].after_state.ridesPerPeriod, 40);
});

test('PRC-07 a pricing command replays instead of applying twice', async (t) => {
  const f = await fixture(t);
  const key = randomUUID();
  const payload = {
    amount: { amountMinor: 700, currency: 'GHS' },
    effectiveFrom: new Date(Date.now() - 3600_000).toISOString(),
  };
  const send = () =>
    f.call('POST', `/v1/ops/routes/${f.input.routeId}/fares`, { who: 'ops', payload, key });
  const first = expectStatus(await send(), 201);
  const replay = expectStatus(await send(), 201);
  assert.equal(replay.id, first.id);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.route_fares')).rows[0].n,
    1,
    'a replayed command publishes one fare',
  );
  const fares = expectStatus(
    await f.call('GET', `/v1/ops/routes/${f.input.routeId}/fares`, { who: 'ops' }),
    200,
  );
  assert.equal(fares.length, 1);
  assert.equal(fares[0].amount.amountMinor, 700);
  assert.equal(fares[0].effectiveTo, null);
});

test('PRC-08 a transfer is priced from the corridor, not from a stub', async (t) => {
  const f = await fixture(t);
  expectStatus(await f.publishFare(600), 201);
  const purchase = expectStatus(
    await f.call('POST', '/v1/me/purchases', { payload: f.input }),
    201,
  );
  const settled = (
    await f.owner.query('SELECT * FROM app.payment_attempts WHERE purchase_id=$1', [purchase.id])
  ).rows[0];
  assert.equal(
    await f.financial.fulfill({
      reference: settled.reference,
      environment: 'test',
      amountPesewas: settled.amount_pesewas,
      currency: 'GHS',
      transactionId: settled.id,
      paidAt: new Date(),
      channel: 'mobile_money',
      feesPesewas: 0,
    }),
    'fulfilled',
  );
  const selection = (await f.owner.query('SELECT id FROM app.commute_selections LIMIT 1')).rows[0];
  const client = await f.runtime.connect();
  try {
    assert.equal(await f.pricing.fareForSelection(client, selection.id), 600);
  } finally {
    client.release();
  }
});
