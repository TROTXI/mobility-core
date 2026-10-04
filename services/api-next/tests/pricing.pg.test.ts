import { test } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { createHmac, randomBytes, randomUUID } from 'node:crypto';
import { setup, files } from './helpers/financial-fixture.js';
import { migrate, grantRuntime } from '../src/db/migrate.js';
import { FinancialFoundation } from '../src/payments/foundation.js';
import { MembershipService } from '../src/membership/service.js';
import { Pricing } from '../src/payments/pricing.js';
import { Purchases } from '../src/payments/purchases.js';
import { createTransportApp } from '../src/http/app.js';
import { AccountService } from '../src/account/service.js';
import { StandbyService } from '../src/membership/standby.js';
import { countTravelDays } from '../src/membership/offer-terms.js';
import { expireUnpaidOffers } from '../src/payments/offer-expiry.js';
import { PaymentRecovery } from '../src/payments/recovery.js';
import { PaystackEvidence } from '../src/payments/provider.js';

type Response = { statusCode: number; body: string; json(): any };
function expectStatus(response: Response, code: number) {
  assert.equal(response.statusCode, code, response.body);
  return response.json().data;
}

/** A rider, an admin and a corridor, priced from the database rather than a stub. */
async function fixture(t: TestContext, target = true, requireOffer = false) {
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
    requireOffer,
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
  const standby = new StandbyService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    purchases,
    cursorSecret: Buffer.alloc(32, 11),
  });
  const app = await createTransportApp({
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 11),
    authorizeSession: f.dependencies.authorizeSession,
    coordinateReservations: membership.coordinateReservations,
    membership,
    pricing,
    purchases,
    standby,
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
    standby,
    financial,
    membership,
    call,
    publishFare,
    initialized: () => initialized,
  };
}

async function offeredFixture(t: TestContext) {
  const f = await fixture(t, true, true);
  await f.owner.query("UPDATE app.users SET display_name='Offer rider' WHERE id=$1", [
    f.actor.userId,
  ]);
  const verify = () =>
    f.owner.query(
      `INSERT INTO app.commuter_phone_verifications(user_id,phone_hash,last_four,verified_at,method)
    VALUES ($1,$2,'1234',clock_timestamp(),'account_upgrade')`,
      [f.actor.userId, 'a'.repeat(64)],
    );
  for (const leg of f.input.legs)
    expectStatus(
      await f.call('POST', `/v1/ops/routes/${f.input.routeId}/fares`, {
        who: 'ops',
        payload: {
          patternVersionId: leg.patternVersionId,
          pickupOccurrenceId: leg.pickupOccurrenceId,
          dropoffOccurrenceId: leg.dropoffOccurrenceId,
          amount: { amountMinor: leg.direction === 'outbound' ? 500 : 800, currency: 'GHS' },
          effectiveFrom: '2026-01-01T00:00:00Z',
        },
      }),
      201,
    );
  const selection = { ...f.input, useCredit: false };
  const request = { selection, travelDays: [1, 3, 5] };
  const start = new Date(Date.now() + 3 * 86400000).toISOString().slice(0, 10);
  const end = new Date(Date.now() + 17 * 86400000).toISOString().slice(0, 10);
  const offerInput = {
    expiresAt: new Date(Date.now() + 86400000).toISOString(),
    coverageStart: start,
    coverageEnd: end,
    price: { amountMinor: 7000, currency: 'GHS' },
    credits: [
      { direction: 'outbound', creditPerUnusedRide: { amountMinor: 100, currency: 'GHS' } },
      { direction: 'return', creditPerUnusedRide: { amountMinor: 200, currency: 'GHS' } },
    ],
  };
  const join = async () =>
    expectStatus(await f.call('POST', '/v1/me/standby', { payload: request }), 201);
  const offer = async (appId: string, key = randomUUID(), input = offerInput) =>
    expectStatus(
      await f.call('POST', `/v1/ops/standby/${appId}/offers`, { who: 'ops', key, payload: input }),
      201,
    );
  const accept = (appId: string, key = randomUUID()) =>
    f.call('POST', `/v1/me/standby/${appId}/accept`, { key });
  return { ...f, verify, request, offerInput, join, offer, accept, start, end };
}

test('OFFER-01 phone verification and Ops offer are required; checkout freezes exact terms once', async (t) => {
  const f = await offeredFixture(t);
  const direct = await f.call('POST', '/v1/me/purchases', { payload: f.input });
  assert.equal(direct.statusCode, 409, direct.body);
  assert.equal(direct.json().error.code, 'offer_required');
  assert.equal(
    (await f.call('POST', '/v1/me/standby', { payload: f.request })).json().error.code,
    'phone_verification_required',
  );
  await f.verify();
  const application = await f.join(),
    issued = await f.offer(application.id);
  const terms = issued.offer.terms;
  assert.deepEqual(
    terms.legs.map((l: any) => l.ridesGranted),
    [6, 6],
  );
  const firstLeg = f.input.legs[0]!;
  expectStatus(
    await f.call('POST', `/v1/ops/routes/${f.input.routeId}/fares`, {
      who: 'ops',
      payload: {
        patternVersionId: firstLeg.patternVersionId,
        pickupOccurrenceId: firstLeg.pickupOccurrenceId,
        dropoffOccurrenceId: firstLeg.dropoffOccurrenceId,
        amount: { amountMinor: 900, currency: 'GHS' },
        effectiveFrom: new Date().toISOString(),
      },
    }),
    201,
  );
  const key = randomUUID(),
    purchase = expectStatus(await f.accept(application.id, key), 201);
  assert.deepEqual(purchase.offerTerms, terms);
  assert.equal(purchase.price.amountMinor, 7000);
  assert.ok(new Date(purchase.checkout.expiresAt) <= new Date(issued.offer.expiresAt));
  assert.equal(f.initialized(), 1);
  assert.equal(expectStatus(await f.accept(application.id, key), 201).id, purchase.id);
  assert.equal(f.initialized(), 1);
  assert.equal((await f.accept(application.id, randomUUID())).statusCode, 409);
  const row = (await f.owner.query('SELECT * FROM app.purchases WHERE id=$1', [purchase.id]))
    .rows[0];
  assert.equal(row.rides_granted, 12);
  assert.equal(row.conversion_rate_pesewas, 0);
  await assert.rejects(
    f.owner.query(
      "UPDATE app.standby_offers SET terms=jsonb_set(terms,'{price,amountMinor}','1') WHERE id=$1",
      [issued.offer.id],
    ),
    /immutable_offer_terms/,
  );
  assert.equal((await f.owner.query('SELECT count(*)::int n FROM app.purchases')).rows[0].n, 1);
});

test('OFFER-02 frozen coverage and per-journey credits close correctly, and a fresh renewal can be requested', async (t) => {
  const f = await offeredFixture(t);
  await f.verify();
  const app = await f.join();
  await f.offer(app.id);
  const purchase = expectStatus(await f.accept(app.id), 201);
  const attempt = (
    await f.owner.query('SELECT * FROM app.payment_attempts WHERE purchase_id=$1', [purchase.id])
  ).rows[0];
  assert.equal(
    await f.financial.fulfill({
      reference: attempt.reference,
      environment: 'test',
      amountPesewas: 7000,
      currency: 'GHS',
      transactionId: randomUUID(),
      paidAt: new Date(),
      channel: null,
      feesPesewas: 0,
    }),
    'fulfilled',
  );
  const period = await f.period(purchase.id);
  assert.equal(period.starts_at.toISOString().slice(0, 10), f.start);
  assert.equal(period.original_ends_at.toISOString().slice(0, 10), f.end);
  assert.equal(
    (await f.owner.query('SELECT state FROM app.standby_applications WHERE id=$1', [app.id]))
      .rows[0].state,
    'completed',
  );
  const renewal = await f.join();
  assert.notEqual(renewal.id, app.id);
  const renewalDenied = await f.call('POST', `/v1/ops/standby/${renewal.id}/offers`, {
    who: 'ops',
    payload: {
      ...f.offerInput,
      coverageStart: f.end,
      coverageEnd: new Date(new Date(f.end).getTime() + 14 * 86400000).toISOString().slice(0, 10),
    },
  });
  assert.equal(renewalDenied.json().error.code, 'renewal_payment_window_required');
  await f.financial.closePeriod(period.id, new Date(`${f.end}T00:00:00Z`));
  const closure = (
    await f.owner.query('SELECT * FROM app.period_closures WHERE period_id=$1', [period.id])
  ).rows[0];
  assert.equal(closure.rides_converted, 12);
  assert.equal(closure.credit_granted_pesewas, 1800);
  assert.deepEqual(closure.journey_breakdown, [
    { direction: 'outbound', rides: 6, creditPerRide: 100 },
    { direction: 'return', rides: 6, creditPerRide: 200 },
  ]);
});

test('OFFER-03 invalid credits, dates, changed replays and late payment cannot silently grant access', async (t) => {
  const f = await offeredFixture(t);
  await f.grant(500);
  f.request.selection.useCredit = true;
  await f.verify();
  const app = await f.join();
  const url = `/v1/ops/standby/${app.id}/offers`;
  assert.equal(
    (
      await f.call('POST', url, {
        who: 'ops',
        payload: { ...f.offerInput, price: { amountMinor: 100, currency: 'GHS' } },
      })
    ).statusCode,
    400,
  );
  assert.equal(
    (await f.call('POST', url, { who: 'ops', payload: { ...f.offerInput, coverageEnd: f.start } }))
      .statusCode,
    400,
  );
  const key = randomUUID(),
    offer = await f.offer(app.id, key);
  assert.deepEqual(await f.offer(app.id, key), offer);
  assert.equal(
    (
      await f.call('POST', url, {
        who: 'ops',
        key,
        payload: { ...f.offerInput, price: { amountMinor: 7100, currency: 'GHS' } },
      })
    ).json().error.code,
    'idempotency_conflict',
  );
  const purchase = expectStatus(await f.accept(app.id), 201);
  const attempt = (
    await f.owner.query('SELECT * FROM app.payment_attempts WHERE purchase_id=$1', [purchase.id])
  ).rows[0];
  assert.equal(
    await f.financial.fulfill({
      reference: attempt.reference,
      environment: 'test',
      amountPesewas: purchase.cashDue.amountMinor,
      currency: 'GHS',
      transactionId: randomUUID(),
      paidAt: new Date(f.start + 'T00:00:01Z'),
      channel: null,
      feesPesewas: 0,
    }),
    'not_pending',
  );
  assert.equal(purchase.appliedCredit.amountMinor, 500);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.billing_periods')).rows[0].n,
    0,
  );
  assert.equal(
    (await f.owner.query('SELECT state,failure_code FROM app.purchases WHERE id=$1', [purchase.id]))
      .rows[0].failure_code,
    'offer_expired',
  );
  assert.equal(
    (await f.owner.query("SELECT count(*)::int n FROM app.credit_holds WHERE state='held'")).rows[0]
      .n,
    0,
  );
  assert.notEqual(
    (await f.join()).id,
    app.id,
    'late payment does not strand the rider in the old application',
  );
});

test('OFFER-04 calendar allowances count real dates, not four weeks or 44 rides', () => {
  assert.equal(
    countTravelDays(new Date('2026-10-01'), new Date('2026-11-01'), [1, 2, 3, 4, 5]),
    22,
  );
  assert.equal(countTravelDays(new Date('2026-10-01'), new Date('2026-11-01'), [1, 3, 5]), 13);
  assert.equal(
    countTravelDays(new Date('2028-02-01'), new Date('2028-03-01'), [1, 2, 3, 4, 5, 6, 7]),
    29,
  );
});

test('OFFER-07 expiry releases an unpaid offer while a delayed provider collection remains reviewable', async (t) => {
  const f = await offeredFixture(t);
  await f.verify();
  await f.grant(500);
  f.request.selection.useCredit = true;
  const app = await f.join(),
    offered = await f.offer(app.id),
    purchase = expectStatus(await f.accept(app.id), 201);
  assert.equal(purchase.appliedCredit.amountMinor, 500);
  const c = await f.runtime.connect();
  try {
    await c.query('BEGIN');
    await c.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [f.actor.userId]);
    await expireUnpaidOffers(
      c,
      f.actor.userId,
      new Date(new Date(offered.offer.expiresAt).getTime() + 1),
    );
    await c.query('COMMIT');
  } catch (error) {
    await c.query('ROLLBACK');
    throw error;
  } finally {
    c.release();
  }
  assert.equal(
    (await f.owner.query('SELECT state FROM app.credit_holds WHERE purchase_id=$1', [purchase.id]))
      .rows[0].state,
    'released',
  );
  assert.equal(
    (await f.owner.query('SELECT state FROM app.standby_applications WHERE id=$1', [app.id]))
      .rows[0].state,
    'completed',
  );
  assert.notEqual((await f.join()).id, app.id);
  const attempt = (
    await f.owner.query('SELECT * FROM app.payment_attempts WHERE purchase_id=$1', [purchase.id])
  ).rows[0];
  assert.equal(attempt.state, 'pending', 'local expiry does not fabricate provider failure');
  const secret = `sk_test_${randomBytes(16).toString('hex')}`;
  const recovery = new PaymentRecovery({
    pool: f.runtime,
    provider: new PaystackEvidence(secret, randomBytes(32), async () => {
      throw new Error('No network expected');
    }),
    foundation: f.financial,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: randomBytes(32),
    reversePeriod: f.membership.reversePeriod,
  });
  const payload = Buffer.from(
    JSON.stringify({
      event: 'charge.success',
      data: {
        id: '1007',
        reference: attempt.reference,
        domain: 'test',
        currency: 'GHS',
        amount: purchase.cashDue.amountMinor,
        status: 'success',
        paid_at: new Date().toISOString(),
      },
    }),
  );
  await recovery.acceptWebhook(payload, createHmac('sha512', secret).update(payload).digest('hex'));
  assert.equal((await recovery.processInbox()).failed, 1);
  assert.deepEqual(
    (
      await f.owner.query(`SELECT (SELECT count(*)::int FROM app.payment_collections) collections,
    (SELECT count(*)::int FROM app.billing_periods) periods,(SELECT reason FROM app.payment_reviews) reason`)
    ).rows[0],
    { collections: 1, periods: 0, reason: 'late_success' },
  );
});

test('OFFER-05 upgrade reconnects committed legacy checkouts and releases orphan acceptance claims', async (t) => {
  const f = await setup(t, {}, false, 41);
  const key = randomUUID(),
    p = await f.buy(key, new Date());
  const purchaseBefore = (await f.owner.query('SELECT * FROM app.purchases WHERE id=$1', [p.id]))
    .rows[0];
  const ids: string[] = [];
  for (const user of [f.actor.userId, f.other.userId]) {
    const a = (
      await f.owner.query(
        "INSERT INTO app.standby_applications(user_id,route_id,selection,state) VALUES ($1,$2,$3,'offered') RETURNING id",
        [user, f.input.routeId, JSON.stringify(f.input)],
      )
    ).rows[0].id;
    const offer = (
      await f.owner.query(
        `INSERT INTO app.standby_offers(application_id,state,expires_at,offer_key_hash,acceptance_key_hash)
      VALUES ($1,'accepting',clock_timestamp()+interval '1 day',repeat('b',64),$2) RETURNING id`,
        [a, user === f.actor.userId ? purchaseBefore.checkout_key_hash : 'c'.repeat(64)],
      )
    ).rows[0];
    ids.push(offer.id);
  }
  await migrate(f.owner, files);
  await grantRuntime(f.owner, f.role);
  const linked = (await f.owner.query('SELECT * FROM app.standby_offers WHERE id=$1', [ids[0]]))
    .rows[0];
  assert.equal(linked.purchase_id, p.id);
  assert.equal(linked.state, 'checkout_open');
  const orphan = (await f.owner.query('SELECT * FROM app.standby_offers WHERE id=$1', [ids[1]]))
    .rows[0];
  assert.equal(orphan.state, 'offered');
  assert.equal(orphan.acceptance_key_hash, null);
  assert.deepEqual(
    (await f.owner.query('SELECT * FROM app.purchases WHERE id=$1', [p.id])).rows[0],
    { ...purchaseBefore, offer_id: null, offer_terms: null },
  );
  const current = new FinancialFoundation({ ...f.dependencies, requireOffer: true });
  assert.equal((await current.checkout(f.actor, f.input, key, new Date(), ids[0])).id, p.id);
  assert.equal(
    (await current.checkout(f.actor, f.input, key, new Date())).id,
    p.id,
    'existing direct checkout can recover, but never create a replacement',
  );
  await assert.rejects(
    current.checkout(f.actor, f.input, randomUUID()),
    /Request and accept an Ops subscription offer/,
  );
});

test('OFFER-06 reservation weekdays and directional allowances survive period extension; used rides reduce only their own credit', async (t) => {
  const f = await offeredFixture(t);
  await f.verify();
  const app = await f.join();
  await f.offer(app.id);
  const purchase = expectStatus(await f.accept(app.id), 201);
  const attempt = (
    await f.owner.query('SELECT * FROM app.payment_attempts WHERE purchase_id=$1', [purchase.id])
  ).rows[0];
  await f.financial.fulfill({
    reference: attempt.reference,
    environment: 'test',
    amountPesewas: 7000,
    currency: 'GHS',
    transactionId: randomUUID(),
    paidAt: new Date(),
    channel: null,
    feesPesewas: 0,
  });
  const period = await f.period(purchase.id);
  const vehicle = (
    await f.owner.query(
      "INSERT INTO app.vehicles(plate,capacity) VALUES ('OFFER TEST',18) RETURNING id",
    )
  ).rows[0].id;
  const driver = (
    await f.owner.query("INSERT INTO app.drivers(name) VALUES ('Offer test') RETURNING id")
  ).rows[0].id;
  const days: string[] = [];
  let excluded = '';
  for (let ms = new Date(f.start).getTime(); ms < new Date(f.end).getTime(); ms += 86400000) {
    const date = new Date(ms);
    if ([1, 3, 5].includes(date.getUTCDay())) days.push(date.toISOString().slice(0, 10));
    else excluded = date.toISOString().slice(0, 10);
  }
  const reserve = async (day: string, direction = 'outbound') => {
    const leg = f.input.legs.find((l) => l.direction === direction)!;
    await f.owner.query(
      `INSERT INTO app.trips(schedule_id,departure_id,pattern_version_id,service_date,scheduled_at,assigned_driver_id,vehicle_id)
      SELECT id,departure_id,pattern_version_id,$2::date,$2::date+local_departure,$3,$4 FROM app.service_schedules WHERE id=$1`,
      [leg.scheduleId, day, driver, vehicle],
    );
    return f.membership.command(
      f.actor,
      'decideReservation',
      undefined,
      { travelDate: day, direction, decision: 'confirm' },
      randomUUID(),
    );
  };
  await assert.rejects(reserve(excluded), /not included in your offer/);
  for (const day of days) await reserve(day);
  const extension = new Date(new Date(f.end).getTime() + 7 * 86400000);
  await f.owner.query('UPDATE app.billing_periods SET effective_ends_at=$2 WHERE id=$1', [
    period.id,
    extension,
  ]);
  const extra = new Date(new Date(days[0]!).getTime() + 14 * 86400000).toISOString().slice(0, 10);
  await assert.rejects(reserve(extra), /No rides remain for this direction/);
  // One outward ride consumed, other reservations declined. Directional
  // pricing must not value that outward ride using the return credit rate.
  const r = (
    await f.owner.query(
      "SELECT * FROM app.reservations WHERE period_id=$1 AND status='reserved' ORDER BY service_date",
      [period.id],
    )
  ).rows[0];
  const c = await f.owner.connect();
  try {
    await c.query('BEGIN');
    const command = (
      await c.query(
        `INSERT INTO app.boarding_commands(actor_user_id,operation,target,key_hash,input_hash,response_body)
      VALUES ($1,'boardRider',$2,repeat('d',64),repeat('e',64),$3) RETURNING id`,
        [
          f.adminId,
          r.trip_id,
          JSON.stringify({
            reservationId: r.id,
            status: 'boarded',
            alreadyApplied: false,
            chargedRides: 1,
          }),
        ],
      )
    ).rows[0].id;
    await c.query(
      `INSERT INTO app.reservation_charges(reservation_id,period_id,user_id,trip_id,reason,command_id,charged_at)
      VALUES ($1,$2,$3,$4,'boarding',$5,$6)`,
      [r.id, period.id, f.actor.userId, r.trip_id, command, new Date()],
    );
    await c.query(
      "UPDATE app.reservations SET status='boarded',settled_at=(SELECT charged_at FROM app.reservation_charges WHERE reservation_id=$1) WHERE id=$1",
      [r.id],
    );
    await c.query(
      "INSERT INTO app.ride_entries(user_id,period_id,reason,delta_rides,reservation_id) VALUES ($1,$2,'boarding',-1,$3)",
      [f.actor.userId, period.id, r.id],
    );
    await c.query('COMMIT');
  } catch (error) {
    await c.query('ROLLBACK');
    throw error;
  } finally {
    c.release();
  }
  for (const day of days.slice(1))
    await f.membership.command(
      f.actor,
      'decideReservation',
      undefined,
      { travelDate: day, direction: 'outbound', decision: 'decline' },
      randomUUID(),
    );
  await f.financial.closePeriod(period.id, extension);
  const closure = (
    await f.owner.query('SELECT * FROM app.period_closures WHERE period_id=$1', [period.id])
  ).rows[0];
  assert.equal(closure.rides_converted, 11);
  assert.equal(closure.credit_granted_pesewas, 1700);
});

/** Four ordered occurrences, including two visits to the same physical stop. */
async function fareCorridor(f: Awaited<ReturnType<typeof fixture>>) {
  const route = (
    await f.owner.query("INSERT INTO app.routes(name) VALUES ('Pair fares') RETURNING id")
  ).rows[0].id;
  const pattern = (
    await f.owner.query(
      "INSERT INTO app.route_patterns(route_id,direction) VALUES ($1,'outbound') RETURNING id",
      [route],
    )
  ).rows[0].id;
  const version = (
    await f.owner.query(
      'INSERT INTO app.route_pattern_versions(pattern_id,revision) VALUES ($1,1) RETURNING id',
      [pattern],
    )
  ).rows[0].id;
  const stop = (
    await f.owner.query(
      "INSERT INTO app.stops(name,latitude,longitude) VALUES ('Physical stop',5.6,-0.2) RETURNING id",
    )
  ).rows[0].id;
  const occurrences: string[] = [];
  for (let index = 0; index < 4; index++)
    occurrences.push(
      (
        await f.owner.query(
          'INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude) VALUES ($1,$2,$3,$4,5.6,-0.2) RETURNING id',
          [version, stop, index, ['A', 'B', 'C', 'D'][index]],
        )
      ).rows[0].id,
    );
  const geometry = (
    await f.owner.query(
      "INSERT INTO app.route_geometries(pattern_version_id,source,line) VALUES ($1,'configured',ST_GeomFromText('LINESTRING(-0.2 5.6,-0.21 5.6,-0.2 5.6)',4326)) RETURNING id",
      [version],
    )
  ).rows[0].id;
  for (const [index, occurrence] of occurrences.entries())
    await f.owner.query('INSERT INTO app.geometry_stop_distances VALUES ($1,$2,$3,$4)', [
      geometry,
      version,
      occurrence,
      index * 300,
    ]);
  await f.owner.query("UPDATE app.route_geometries SET state='published' WHERE id=$1", [geometry]);
  await f.owner.query(
    "UPDATE app.route_pattern_versions SET state='published',geometry_id=$2,effective_from='2025-01-01' WHERE id=$1",
    [version, geometry],
  );
  const leg = (a: number, b: number) => ({
    direction: 'outbound' as const,
    scheduleId: randomUUID(),
    patternVersionId: version,
    pickupOccurrenceId: occurrences[a]!,
    dropoffOccurrenceId: occurrences[b]!,
  });
  const payload = (a: number, b: number, amount = 500, from = '2026-01-01T00:00:00Z') => ({
    patternVersionId: version,
    pickupOccurrenceId: occurrences[a],
    dropoffOccurrenceId: occurrences[b],
    amount: { amountMinor: amount, currency: 'GHS' },
    effectiveFrom: from,
  });
  const publish = (body: unknown, key?: string) =>
    f.call('POST', `/v1/ops/routes/${route}/fares`, { who: 'ops', payload: body, key });
  const quote = async (a: number, b: number, at = '2026-01-02T00:00:00Z') => {
    const c = await f.runtime.connect();
    try {
      return await f.pricing.quoteJourney(c, route, leg(a, b), new Date(at));
    } finally {
      c.release();
    }
  };
  return { route, version, occurrences, leg, payload, publish, quote };
}

test('PAIR-01 exact stop-pair fares differ, long journeys are explicit, legacy prices do not substitute', async (t) => {
  const f = await fixture(t),
    p = await fareCorridor(f);
  const bc = expectStatus(await p.publish(p.payload(1, 2, 500)), 201);
  expectStatus(await p.publish(p.payload(2, 3, 800)), 201);
  expectStatus(await p.publish(p.payload(1, 3, 1100)), 201);
  expectStatus(
    await p.publish({
      amount: { amountMinor: 999, currency: 'GHS' },
      effectiveFrom: '2026-01-01T00:00:00Z',
    }),
    201,
  );
  assert.deepEqual(await p.quote(1, 2), { fareId: bc.id, amountPesewas: 500 });
  assert.equal((await p.quote(2, 3)).amountPesewas, 800);
  assert.equal((await p.quote(1, 3)).amountPesewas, 1100);
  await assert.rejects(p.quote(0, 3), /Ops must publish a fare/);
  await assert.rejects(p.quote(2, 1), /Ops must publish a fare/);
  const listed = expectStatus(
    await f.call('GET', `/v1/ops/routes/${p.route}/fares`, { who: 'ops' }),
    200,
  );
  assert.deepEqual(listed.find((row: any) => row.id === bc.id).journey, {
    pickup: 'B',
    dropoff: 'C',
    direction: 'outbound',
  });
});

test('PAIR-02 replacing a fare preserves other journeys and history, and replays are scoped', async (t) => {
  const f = await fixture(t),
    p = await fareCorridor(f);
  const key = randomUUID(),
    input = p.payload(1, 2, 500);
  const first = expectStatus(await p.publish(input, key), 201);
  assert.equal(expectStatus(await p.publish(input, key), 201).id, first.id);
  assert.equal((await p.publish(p.payload(2, 3, 800), key)).statusCode, 409);
  expectStatus(await p.publish(p.payload(2, 3, 800)), 201);
  expectStatus(await p.publish(p.payload(1, 2, 600, '2026-02-01T00:00:00Z')), 201);
  assert.equal((await p.quote(1, 2)).amountPesewas, 500);
  assert.equal((await p.quote(1, 2, '2026-02-01T00:00:00Z')).amountPesewas, 600);
  assert.equal((await p.quote(2, 3, '2026-02-02T00:00:00Z')).amountPesewas, 800);
  await assert.rejects(
    f.owner.query('UPDATE app.route_fares SET amount_pesewas=1 WHERE id=$1', [first.id]),
    /immutable_fare/,
  );
});

test('PAIR-03 invalid, partial and cross-route pairs fail, including direct database writes', async (t) => {
  const f = await fixture(t),
    p = await fareCorridor(f);
  assert.equal((await p.publish(p.payload(2, 1))).statusCode, 409);
  assert.equal((await p.publish(p.payload(1, 1))).statusCode, 409);
  assert.equal(
    (await p.publish({ ...p.payload(1, 2), dropoffOccurrenceId: undefined })).statusCode,
    400,
  );
  assert.equal(
    (
      await f.call('POST', `/v1/ops/routes/${f.input.routeId}/fares`, {
        who: 'ops',
        payload: p.payload(1, 2),
      })
    ).statusCode,
    409,
  );
  assert.equal(
    (
      await f.call('POST', `/v1/ops/routes/${p.route}/fares`, {
        payload: p.payload(1, 2),
        client: 'ops',
      })
    ).statusCode,
    403,
  );
  await assert.rejects(
    f.owner.query(
      `INSERT INTO app.route_fares(route_id,amount_pesewas,effective_from,created_by,command_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id)
     VALUES ($1,500,'2026-01-01',$2,gen_random_uuid(),$3,$4,$5)`,
      [p.route, f.adminId, p.version, p.occurrences[2], p.occurrences[1]],
    ),
    /invalid_fare_stop_pair/,
  );
});

test('PAIR-04 simultaneous first prices cannot create overlapping fare windows', async (t) => {
  const f = await fixture(t),
    p = await fareCorridor(f);
  const responses = await Promise.all([
    p.publish(p.payload(1, 2, 500)),
    p.publish(p.payload(1, 2, 600)),
  ]);
  assert.deepEqual(responses.map((r) => r.statusCode).sort(), [201, 409]);
  assert.ok([500, 600].includes((await p.quote(1, 2)).amountPesewas));
});

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

test('PRC-09 deleted rider is absent from Ops profile reads while restricted purchase facts remain', async (t) => {
  const f = await fixture(t);
  await f.owner.query(
    "UPDATE app.users SET display_name='Ama Private',email='ama.private@example.test',phone='+233241234567' WHERE id=$1",
    [f.actor.userId],
  );
  expectStatus(await f.publishFare(600), 201);
  const purchase = expectStatus(
    await f.call('POST', '/v1/me/purchases', { payload: f.input }),
    201,
  );
  const account = new AccountService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    deviceKey: randomBytes(32),
  });
  assert.equal(
    (await account.handle(f.actor, 'eraseAccount', {}, undefined, randomUUID())).status,
    204,
  );

  const riders = expectStatus(await f.call('GET', '/v1/ops/riders', { who: 'ops' }), 200);
  assert.equal(
    riders.some((r: { id: string }) => r.id === f.actor.userId),
    false,
  );
  assert.equal(
    (await f.call('GET', `/v1/ops/riders/${f.actor.userId}`, { who: 'ops' })).statusCode,
    404,
  );
  const retained = expectStatus(
    await f.call('GET', `/v1/ops/purchases/${purchase.id}`, { who: 'ops' }),
    200,
  );
  assert.equal(retained.riderId, f.actor.userId, 'financial history remains linkable by ID');
  assert.equal(retained.id, purchase.id);
  assert.equal(JSON.stringify(retained).includes('Ama Private'), false);
  assert.equal(JSON.stringify(retained).includes('ama.private@example.test'), false);
  assert.equal(JSON.stringify(retained).includes('+233241234567'), false);
});
