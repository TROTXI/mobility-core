import { test } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { createHmac, randomBytes, randomUUID } from 'node:crypto';
import { setup, at, renewAt } from './helpers/financial-fixture.js';
import { PaymentRecovery } from '../src/payments/recovery.js';
import { PaystackEvidence } from '../src/payments/provider.js';
import { FinancialFoundation } from '../src/payments/foundation.js';
import { TransportError } from '../src/transport/errors.js';
import { createTransportApp } from '../src/http/app.js';
import { purgeExpiredCommandPayloads } from '../src/runtime/receipt-retention.js';

// Generated locally; never an account credential or a provider network token.
const secret = `sk_test_${randomBytes(16).toString('hex')}`;
async function fixture(
  t: TestContext,
  request: typeof fetch = async () => new Response('', { status: 503 }),
) {
  const f = await setup(t);
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [f.adminId]);
  const provider = new PaystackEvidence(secret, randomBytes(32), request);
  const options = {
    pool: f.runtime,
    provider,
    foundation: f.service,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: randomBytes(32),
    reversePeriod: async () => {},
  };
  const recovery = new PaymentRecovery(options);
  const enqueue = async (payload: unknown) => {
    const raw = Buffer.from(JSON.stringify(payload));
    await recovery.acceptWebhook(raw, createHmac('sha512', secret).update(raw).digest('hex'));
  };
  const send = async (payload: unknown) => {
    await enqueue(payload);
    return recovery.processInbox();
  };
  const success = (p: Awaited<ReturnType<typeof f.buy>>, id = '1001', paidAt = at) => ({
    event: 'charge.success',
    data: {
      id,
      reference: p.attempt.reference,
      domain: 'test',
      currency: 'GHS',
      amount: p.cashDuePesewas,
      status: 'success',
      paid_at: paidAt.toISOString(),
    },
  });
  const refund = (
    p: Awaited<ReturnType<typeof f.buy>>,
    amount = p.cashDuePesewas,
    reference = 'refund-1',
    state = 'processed',
  ) => ({
    event: `refund.${state}`,
    data: {
      transaction_reference: p.attempt.reference,
      domain: 'test',
      currency: 'GHS',
      amount,
      status: state,
      refund_reference: reference,
    },
  });
  const dispute = (
    p: Awaited<ReturnType<typeof f.buy>>,
    id = '7001',
    amount = p.cashDuePesewas,
    state = 'create',
    resolution: string | null = null,
  ) => ({
    event: `charge.dispute.${state}`,
    data: {
      id,
      domain: 'test',
      currency: 'GHS',
      amount,
      resolution,
      transaction: { reference: p.attempt.reference },
    },
  });
  const admin = { userId: f.adminId, sessionId: f.adminId };
  return { ...f, provider, options, recovery, enqueue, send, success, refund, dispute, admin };
}

test('REC-01: raw authenticated evidence is durable, encrypted and deduplicated; unknown/foreign facts quarantine', async (t) => {
  const f = await fixture(t),
    p = await f.buy(),
    payload = f.success(p),
    raw = Buffer.from(JSON.stringify(payload));
  await assert.rejects(
    f.recovery.acceptWebhook(raw, 'bad'),
    (e: any) => e.code === 'invalid_signature',
  );
  assert.equal((await f.owner.query('SELECT * FROM app.payment_events')).rowCount, 0);
  await Promise.all([f.enqueue(payload), f.enqueue(payload)]);
  const event = (await f.owner.query('SELECT * FROM app.payment_events')).rows[0];
  assert.equal(event.state, 'ready');
  assert.ok(!event.ciphertext.includes(Buffer.from(p.attempt.reference)));
  assert.equal((await f.owner.query('SELECT * FROM app.payment_events')).rowCount, 1);
  assert.equal(
    (await f.owner.query('SELECT state FROM app.purchases')).rows[0].state,
    'awaiting_payment',
  );
  assert.equal((await f.recovery.processInbox()).succeeded, 1);
  assert.equal((await f.recovery.processInbox()).considered, 0);
  await f.enqueue({ ...payload, data: { ...payload.data, reference: 'retired-fixture' } });
  await f.enqueue({ ...payload, data: { ...payload.data, domain: 'live' } });
  assert.equal((await f.recovery.processInbox()).failed, 2);
  assert.deepEqual(
    (
      await f.owner.query(
        "SELECT reason FROM app.payment_events WHERE state='quarantined' ORDER BY reason",
      )
    ).rows.map((r) => r.reason),
    ['invalid_facts', 'unknown_reference'],
  );
});
test('REC-02: distinct simultaneous success events actually contend and commit one fulfilment', async (t) => {
  const f = await fixture(t);
  await f.grant(1000);
  const p = await f.buy();
  await f.enqueue(f.success(p));
  await f.enqueue({ ...f.success(p), delivery: 2 });
  const blocker = await f.lock();
  const first = f.recovery.processInbox(1),
    second = f.recovery.processInbox(2);
  await f.waiters(2);
  await blocker.query('COMMIT');
  blocker.release();
  await Promise.all([first, second]);
  assert.deepEqual(
    (
      await f.owner.query(`SELECT (SELECT count(*)::int FROM app.billing_periods) periods,
 (SELECT count(*)::int FROM app.ride_entries) rides,(SELECT count(*)::int FROM app.payment_collections) collections,
 (SELECT count(*)::int FROM app.payment_events WHERE state='processed') events,
 (SELECT state FROM app.credit_holds) hold`)
    ).rows[0],
    { periods: 1, rides: 1, collections: 1, events: 2, hold: 'captured' },
  );
});
test('REC-03: acknowledgement failure rolls back cash facts and fulfilment; durable retry recovers', async (t) => {
  const f = await fixture(t);
  await f.grant(1000);
  const p = await f.buy();
  await f.enqueue(f.success(p));
  await f.owner
    .query(`CREATE FUNCTION app.test_ack_failure() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'test_write_failure'; END $$;
 CREATE TRIGGER test_ack_failure BEFORE UPDATE ON app.payment_events FOR EACH ROW WHEN(NEW.state='processed') EXECUTE FUNCTION app.test_ack_failure()`);
  assert.equal((await f.recovery.processInbox()).failed, 1);
  assert.deepEqual(
    (
      await f.owner.query(`SELECT (SELECT count(*)::int FROM app.payment_collections) collections,
 (SELECT count(*)::int FROM app.billing_periods) periods,(SELECT state FROM app.credit_holds) hold,
 (SELECT state FROM app.payment_events) event`)
    ).rows[0],
    { collections: 0, periods: 0, hold: 'held', event: 'ready' },
  );
  await f.owner.query('DROP TRIGGER test_ack_failure ON app.payment_events');
  await f.owner.query(
    "UPDATE app.payment_events SET available_at=clock_timestamp() WHERE state='ready'",
  );
  assert.equal((await f.recovery.processInbox()).succeeded, 1);
});
test('REC-04: Verify recovers missing webhook; 404 and unresolved status never release held credit', async (t) => {
  let status = 'pending',
    ref = '',
    amount = 0,
    unavailable = true;
  const request: typeof fetch = async () =>
    unavailable
      ? new Response('', { status: 404 })
      : Response.json({
          status: true,
          data: {
            reference: ref,
            domain: 'test',
            currency: 'GHS',
            amount,
            status,
            id: 3001,
            paid_at: at.toISOString(),
          },
        });
  const f = await fixture(t, request);
  await f.grant(1000);
  const p = await f.buy();
  ref = p.attempt.reference;
  amount = p.cashDuePesewas;
  const cutoff = new Date(Date.now() + 1000);
  assert.equal((await f.recovery.reconcile(cutoff)).failed, 1);
  unavailable = false;
  assert.equal((await f.recovery.reconcile(cutoff)).blocked, 1);
  assert.equal((await f.recovery.reconcile(cutoff)).blocked, 1);
  assert.deepEqual(await f.service.balance(f.actor), { credit: 1000, held: 1000, available: 0 });
  status = 'success';
  assert.equal((await f.recovery.reconcile(cutoff)).succeeded, 1);
  assert.equal((await f.period(p.id)).state, 'open');
  assert.deepEqual(await f.service.balance(f.actor), { credit: 0, held: 0, available: 0 });
});
test('REC-05: explicit verified failure releases hold; late success is cash evidence plus review, never second allocation', async (t) => {
  let ref = '',
    amount = 0;
  const f = await fixture(t, async () =>
    Response.json({
      status: true,
      data: { reference: ref, domain: 'test', currency: 'GHS', amount, status: 'failed' },
    }),
  );
  await f.grant(1000);
  const p = await f.buy();
  ref = p.attempt.reference;
  amount = p.cashDuePesewas;
  assert.equal((await f.recovery.reconcile(new Date(Date.now() + 1000))).succeeded, 1);
  assert.equal(
    (await f.owner.query('SELECT state FROM app.credit_holds WHERE purchase_id=$1', [p.id])).rows[0]
      .state,
    'released',
  );
  const next = await f.buy();
  assert.notEqual(next.id, p.id);
  assert.equal((await f.send(f.success(p))).failed, 1);
  assert.deepEqual(
    (
      await f.owner.query(`SELECT (SELECT count(*)::int FROM app.payment_collections) collections,
 (SELECT count(*)::int FROM app.billing_periods) periods,(SELECT reason FROM app.payment_reviews) reason`)
    ).rows[0],
    { collections: 1, periods: 0, reason: 'late_success' },
  );
  assert.equal(
    (await f.owner.query('SELECT state FROM app.purchases WHERE id=$1', [next.id])).rows[0].state,
    'awaiting_payment',
  );
});
test('REC-06: concurrent full refund restores captured credit exactly once without editing capture history', async (t) => {
  const f = await fixture(t);
  await f.grant(1000);
  const p = await f.buy();
  await f.send(f.success(p));
  const before = (await f.owner.query('SELECT * FROM app.credit_holds')).rows;
  await f.enqueue(f.refund(p));
  await f.enqueue({ ...f.refund(p), delivery: 2 });
  const blocker = await f.lock();
  const a = f.recovery.processInbox(1),
    b = f.recovery.processInbox(2);
  await f.waiters(2);
  await blocker.query('COMMIT');
  blocker.release();
  await Promise.all([a, b]);
  assert.deepEqual((await f.owner.query('SELECT * FROM app.credit_holds')).rows, before);
  assert.equal((await f.owner.query('SELECT * FROM app.payment_reversals')).rowCount, 1);
  assert.equal((await f.period(p.id)).state, 'reversed');
  assert.deepEqual(await f.service.balance(f.actor), { credit: 1000, held: 0, available: 1000 });
  assert.equal(
    Number(
      (await f.owner.query('SELECT sum(delta_rides) rides FROM app.ride_entries')).rows[0].rides,
    ),
    0,
  );
});
test('REC-07: closed-period refund is not consumption and claws back conversion credit', async (t) => {
  const f = await fixture(t);
  const p = await f.buy();
  await f.send(f.success(p));
  await f.service.closePeriod((await f.period(p.id)).id, renewAt);
  assert.equal((await f.service.balance(f.actor)).credit, 1980);
  assert.equal((await f.send(f.refund(p))).succeeded, 1);
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT consumed_rides,rides_removed,conversion_credit_pesewas,recovered_credit_pesewas,estimated_debt_pesewas::int FROM app.payment_reversals',
      )
    ).rows[0],
    {
      consumed_rides: 0,
      rides_removed: 0,
      conversion_credit_pesewas: 1980,
      recovered_credit_pesewas: 1980,
      estimated_debt_pesewas: 0,
    },
  );
  assert.equal((await f.service.balance(f.actor)).credit, 0);
  assert.equal(
    (await f.owner.query("SELECT * FROM app.payment_reviews WHERE kind='manual_review'")).rowCount,
    0,
  );
});
test('REC-08: held conversion credit is not stolen; unrecovered value is the manual-review amount', async (t) => {
  const f = await fixture(t);
  await f.grant(1000);
  const p = await f.buy();
  await f.send(f.success(p));
  await f.service.closePeriod((await f.period(p.id)).id, renewAt);
  const next = await f.buy(randomUUID(), renewAt);
  assert.equal(next.appliedCreditPesewas, 1980);
  assert.equal((await f.send(f.refund(p))).succeeded, 1);
  assert.deepEqual(await f.service.balance(f.actor), { credit: 2980, held: 1980, available: 1000 });
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT consumed_rides,recovered_credit_pesewas,restored_credit_pesewas,estimated_debt_pesewas::int FROM app.payment_reversals',
      )
    ).rows[0],
    {
      consumed_rides: 0,
      recovered_credit_pesewas: 0,
      restored_credit_pesewas: 1000,
      estimated_debt_pesewas: 1980,
    },
  );
  const reviews = await f.recovery.reviews(f.admin);
  const review = reviews.items.find((r) => r.kind === 'manual_review')!;
  assert.equal(review.amount.amountMinor, 1980);
  assert.ok(review.editToken);
});
test('REC-09: partial accepted disputes unfreeze only their source; decline cannot clear another block', async (t) => {
  const f = await fixture(t);
  const p = await f.buy();
  await f.send(f.success(p));
  await f.send(f.dispute(p, '7001', 1000));
  await f.send(f.dispute(p, '7002', 500));
  await f.send(f.dispute(p, '7001', 1000, 'resolve', 'merchant-accepted'));
  assert.equal((await f.recovery.closeEndedPeriods(renewAt)).blocked, 1);
  await f.send(f.refund(p, 400, 'partial-1'));
  assert.equal(
    (await f.owner.query('SELECT * FROM app.payment_access_blocks WHERE released_at IS NULL'))
      .rowCount,
    2,
  );
  await f.send(f.refund(p, 600, 'partial-2'));
  assert.equal(
    (await f.owner.query('SELECT * FROM app.payment_access_blocks WHERE released_at IS NULL'))
      .rowCount,
    1,
  );
  assert.equal((await f.owner.query('SELECT * FROM app.payment_reversals')).rowCount, 0);
  assert.equal((await f.period(p.id)).state, 'open');
  await f.send(f.dispute(p, '7002', 500, 'resolve', 'declined'));
  assert.equal(
    (await f.owner.query('SELECT * FROM app.payment_access_blocks WHERE released_at IS NULL'))
      .rowCount,
    0,
  );
  assert.equal((await f.recovery.closeEndedPeriods(renewAt)).succeeded, 1);
  await f.send({ ...f.dispute(p, '7002', 500), delivery: 'old' });
  assert.equal(
    (await f.owner.query('SELECT * FROM app.payment_access_blocks WHERE released_at IS NULL'))
      .rowCount,
    0,
  );
});
test('REC-10: historical-period dispute never blocks new coverage, and conflicting final verdict quarantines', async (t) => {
  const f = await fixture(t);
  const p = await f.buy();
  await f.send(f.success(p));
  await f.service.closePeriod((await f.period(p.id)).id, renewAt);
  const next = await f.buy(randomUUID(), renewAt);
  await f.send(f.success(next, '1002', renewAt));
  await f.send(f.dispute(p));
  assert.equal(
    (
      await f.owner.query('SELECT * FROM app.payment_access_blocks WHERE period_id=$1', [
        (await f.period(next.id)).id,
      ])
    ).rowCount,
    0,
  );
  await f.send(f.dispute(p, '7001', p.cashDuePesewas, 'resolve', 'declined'));
  assert.equal(
    (await f.send(f.dispute(p, '7001', p.cashDuePesewas, 'resolve', 'merchant-accepted'))).failed,
    1,
  );
  assert.equal(
    (await f.owner.query('SELECT resolution FROM app.payment_disputes')).rows[0].resolution,
    'declined',
  );
});
test('REC-11: full refund rolls back every effect when reservation coordination fails', async (t) => {
  const f = await fixture(t);
  const p = await f.buy();
  await f.send(f.success(p));
  await f.enqueue(f.refund(p));
  const broken = new PaymentRecovery({
    ...f.options,
    reversePeriod: async () => {
      throw new Error('injected reservation write failure');
    },
  });
  assert.equal((await broken.processInbox()).failed, 1);
  assert.equal((await f.period(p.id)).state, 'open');
  assert.equal((await f.owner.query('SELECT * FROM app.payment_refunds')).rowCount, 0);
  assert.equal((await f.owner.query('SELECT * FROM app.payment_reversals')).rowCount, 0);
  assert.equal(
    Number((await f.owner.query('SELECT sum(delta_rides) n FROM app.ride_entries')).rows[0].n),
    44,
  );
});
test('REC-12: one malformed close cannot abort another rider; own checkout still fails loudly', async (t) => {
  const f = await fixture(t);
  const p = await f.buy();
  await f.send(f.success(p));
  const q = await f.buy(randomUUID(), at, f.other);
  await f.send(f.success(q, '1002'));
  const broken = new FinancialFoundation({
    ...f.dependencies,
    assertPeriodCanClose: async (_c, b) => {
      if (b.userId === f.actor.userId) throw new Error('injected close failure');
    },
  });
  const recovery = new PaymentRecovery({ ...f.options, foundation: broken });
  const batch = await recovery.closeEndedPeriods(renewAt);
  assert.equal(batch.considered, 2);
  assert.equal(batch.failed, 1);
  assert.equal(batch.succeeded, 1);
  assert.equal((await f.period(p.id)).state, 'open');
  assert.equal((await f.period(q.id)).state, 'closed');
  await assert.rejects(broken.checkout(f.actor, f.input, randomUUID(), renewAt));
});
test('REC-13: review decisions are replayable and attributable, but never provider resolutions', async (t) => {
  const f = await fixture(t);
  const p = await f.buy();
  await f.send(f.success(p));
  await f.send(f.dispute(p));
  const review = (await f.recovery.reviews(f.admin)).items[0]!;
  const key = randomUUID(),
    decision = {
      decision: 'waived' as const,
      reason: 'Duplicate ops ticket, provider dispute remains pending',
    };
  const result = await f.recovery.decide(f.admin, review.id, decision, key, review.editToken);
  assert.equal(result.status, 'waived');
  assert.deepEqual(
    await f.recovery.decide(f.admin, review.id, decision, key, review.editToken),
    result,
  );
  await assert.rejects(
    f.recovery.decide(f.admin, review.id, { ...decision, reason: 'other' }, key, review.editToken),
    (e: any) => e.code === 'idempotency_conflict',
  );
  assert.equal(
    (await f.owner.query('SELECT * FROM app.payment_access_blocks WHERE released_at IS NULL'))
      .rowCount,
    1,
  );
  assert.equal((await f.owner.query('SELECT * FROM app.payment_review_commands')).rowCount, 1);
  const clock = t.mock.method(Date, 'now', () => new Date('2100-01-01').getTime());
  await assert.rejects(
    f.recovery.decide(f.admin, review.id, decision, key, review.editToken),
    (e: any) => e.code === 'idempotency_expired',
  );
  clock.mock.restore();
  await f.owner
    .query(`INSERT INTO app.payment_review_commands(actor_user_id,review_id,key_hash,input_hash,decision,reason,response_body,created_at)
    SELECT actor_user_id,review_id,repeat('e',64),input_hash,decision,reason,response_body,clock_timestamp()-interval '8 days' FROM app.payment_review_commands`);
  const retained = (
    await f.owner.query(
      'SELECT id,decision,reason,review_id FROM app.payment_review_commands ORDER BY id',
    )
  ).rows;
  assert.equal(await purgeExpiredCommandPayloads(f.runtime), 1);
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT id,decision,reason,review_id FROM app.payment_review_commands ORDER BY id',
      )
    ).rows,
    retained,
  );
  assert.equal(
    (
      await f.owner.query(
        'SELECT count(*)::int n FROM app.payment_review_commands WHERE response_body IS NULL',
      )
    ).rows[0].n,
    1,
  );
  await assert.rejects(
    f.runtime.query("UPDATE app.payment_review_commands SET decision='resolved'"),
    /permission denied/,
  );
  await f.owner.query("UPDATE app.users SET role='commuter' WHERE id=$1", [f.adminId]);
  await assert.rejects(
    f.recovery.decide(f.admin, review.id, decision, key, review.editToken),
    (e: any) => e.code === 'forbidden',
  );
});
test('REC-14: HTTP webhook raw bytes, ops auth, schema envelopes and per-review edit tokens', async (t) => {
  const f = await fixture(t);
  const app = await createTransportApp({
    pool: f.runtime,
    cursorSecret: randomBytes(32),
    authorizeSession: f.dependencies.authorizeSession,
    coordinateReservations: async () => {},
    verifyAccess: async (value) =>
      value === 'Bearer ops' ? f.admin : value === 'Bearer rider' ? f.actor : null,
    minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
    payments: f.recovery,
  });
  t.after(() => app.close());
  const p = await f.buy(),
    payload = '  ' + JSON.stringify(f.success(p)) + '\n',
    raw = Buffer.from(payload);
  const signature = createHmac('sha512', secret).update(raw).digest('hex');
  const ack = await app.inject({
    method: 'POST',
    url: '/webhooks/paystack',
    headers: { 'content-type': 'application/json', 'x-paystack-signature': signature },
    payload,
  });
  assert.equal(ack.statusCode, 200, ack.body);
  assert.deepEqual(ack.json(), { received: true });
  const altered = await app.inject({
    method: 'POST',
    url: '/webhooks/paystack',
    headers: { 'content-type': 'application/json', 'x-paystack-signature': signature },
    payload: payload.trim(),
  });
  assert.equal(altered.statusCode, 401);
  const headers = { authorization: 'Bearer ops', 'x-trotxi-client': 'ops', 'x-trotxi-build': '1' };
  const denied = await app.inject({
    method: 'POST',
    url: '/v1/ops/maintenance/payment-inbox',
    headers: { ...headers, authorization: 'Bearer rider' },
    payload: { limit: 10 },
  });
  assert.equal(denied.statusCode, 403);
  assert.equal(
    (await f.owner.query("SELECT * FROM app.payment_events WHERE state='ready'")).rowCount,
    1,
  );
  const worked = await app.inject({
    method: 'POST',
    url: '/v1/ops/maintenance/payment-inbox',
    headers,
    payload: { limit: 10 },
  });
  assert.equal(worked.statusCode, 200, worked.body);
  assert.deepEqual(worked.json().data, {
    considered: 1,
    succeeded: 1,
    blocked: 0,
    failed: 0,
    failures: [],
  });
  await f.send(f.dispute(p));
  const list = await app.inject({ url: '/v1/ops/payments/reviews', headers });
  assert.equal(list.statusCode, 200, list.body);
  const review = list.json().data[0];
  assert.equal(review.amount.amountMinor, p.cashDuePesewas);
  assert.ok(review.editToken);
  const decision = await app.inject({
    method: 'POST',
    url: `/v1/ops/payments/reviews/${review.id}/decisions`,
    headers: { ...headers, 'idempotency-key': randomUUID(), 'if-match': review.editToken },
    payload: { decision: 'resolved', reason: 'Ops ticket reviewed; dispute remains with provider' },
  });
  assert.equal(decision.statusCode, 200, decision.body);
  assert.equal(decision.json().data.status, 'resolved');
  assert.equal(
    (await f.owner.query('SELECT * FROM app.payment_access_blocks WHERE released_at IS NULL'))
      .rowCount,
    1,
  );
  const bad = await app.inject({
    method: 'POST',
    url: '/v1/ops/maintenance/payments',
    headers,
    payload: { limit: 101 },
  });
  assert.equal(bad.statusCode, 400);
});
test('REC-15: runtime cannot fabricate reversal amounts or erase originals; incomplete reversal cannot commit', async (t) => {
  const f = await fixture(t);
  const p = await f.buy();
  await f.send(f.success(p));
  await f.enqueue(f.refund(p));
  const event = (await f.owner.query("SELECT id FROM app.payment_events WHERE state='ready'"))
    .rows[0].id;
  const b = await f.period(p.id),
    c = await f.runtime.connect();
  const insert = async (rides: number) => {
    const refund = (
      await c.query(
        `INSERT INTO app.payment_refunds(attempt_id,purchase_id,user_id,environment,provider_reference,amount_pesewas,state,event_id)
   VALUES ($1,$2,$3,'test','direct-refund',$4,'processed',$5) RETURNING id`,
        [p.attempt.id, p.id, f.actor.userId, p.cashDuePesewas, event],
      )
    ).rows[0];
    return c.query(
      `INSERT INTO app.payment_reversals(purchase_id,user_id,period_id,refund_id,rides_removed,consumed_rides,conversion_credit_pesewas,recovered_credit_pesewas,restored_credit_pesewas,estimated_debt_pesewas)
   VALUES ($1,$2,$3,$4,$5,0,0,0,0,0)`,
      [p.id, f.actor.userId, b.id, refund.id, rides],
    );
  };
  try {
    await c.query('BEGIN');
    await assert.rejects(insert(43), /^error: reversal_source_mismatch$/);
    await c.query('ROLLBACK');
    await c.query('BEGIN');
    await insert(44);
    await assert.rejects(c.query('COMMIT'), /^error: incomplete_reversal$/);
    await c.query('ROLLBACK');
  } finally {
    c.release();
  }
  assert.equal((await f.owner.query('SELECT * FROM app.payment_reversals')).rowCount, 0);
  await assert.rejects(
    f.runtime.query('UPDATE app.payment_collections SET amount_pesewas=100'),
    (e: any) => e.code === '42501',
  );
  await assert.rejects(
    f.runtime.query('DELETE FROM app.payment_events'),
    (e: any) => e.code === '42501',
  );
  assert.equal((await f.recovery.processInbox()).succeeded, 1);
});
test('REC-16: refund arriving before charge stays retryable; refund of a late unfulfilled collection grants nothing', async (t) => {
  let ref = '',
    amount = 0;
  const f = await fixture(t, async () =>
    Response.json({
      status: true,
      data: { reference: ref, domain: 'test', currency: 'GHS', amount, status: 'failed' },
    }),
  );
  const p = await f.buy();
  assert.equal((await f.send(f.refund(p))).blocked, 1);
  assert.equal((await f.send(f.success(p))).succeeded, 1);
  await f.owner.query(
    "UPDATE app.payment_events SET available_at=clock_timestamp() WHERE state='ready'",
  );
  assert.equal((await f.recovery.processInbox()).succeeded, 1);
  assert.equal((await f.period(p.id)).state, 'reversed');
  const next = await f.buy(randomUUID(), renewAt);
  ref = next.attempt.reference;
  amount = next.cashDuePesewas;
  assert.equal((await f.recovery.reconcile(new Date(Date.now() + 1000))).succeeded, 1);
  assert.equal((await f.send(f.success(next, '1002', renewAt))).failed, 1);
  assert.equal((await f.send(f.refund(next, next.cashDuePesewas, 'late-refund'))).succeeded, 1);
  assert.equal(await f.period(next.id), undefined);
  assert.equal((await f.owner.query('SELECT * FROM app.payment_reversals')).rowCount, 1);
  assert.equal(
    (await f.owner.query("SELECT * FROM app.payment_refunds WHERE state='processed'")).rowCount,
    2,
  );
});
