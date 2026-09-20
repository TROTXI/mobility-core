import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { setup } from './helpers/financial-fixture.js';
import { RefundInitiation } from '../src/payments/refunds.js';
import { createTransportApp } from '../src/http/app.js';

async function fixture(
  t: Parameters<typeof setup>[0],
  initiate: (ref: string, n: number, id: string) => Promise<string>,
) {
  const f = await setup(t);
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [f.adminId]);
  const actor = { userId: f.adminId, sessionId: f.adminId };
  await f.grant(1000);
  const purchase = await f.buy();
  await f.service.fulfill(f.settle(purchase));
  const event = (
    await f.owner.query(
      `INSERT INTO app.payment_events(environment,source,payload_hash,ciphertext)
    VALUES ('test','verify',repeat('a',64),$1) RETURNING id`,
      [Buffer.alloc(29)],
    )
  ).rows[0].id;
  await f.owner.query(
    `INSERT INTO app.payment_collections(attempt_id,purchase_id,user_id,environment,provider_transaction_id,amount_pesewas,currency,paid_at,event_id)
    VALUES ($1,$2,$3,'test','12345',$4,'GHS',clock_timestamp(),$5)`,
    [purchase.attempt.id, purchase.id, f.actor.userId, purchase.cashDuePesewas, event],
  );
  const refunds = new RefundInitiation({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    environment: 'test',
    initiate,
  });
  const app = await createTransportApp({
    ...f.dependencies,
    cursorSecret: Buffer.alloc(32, 9),
    coordinateReservations: async () => {},
    refunds,
    minimumBuilds: { ops: 1, commuter: { ios: 1, android: 1 }, driver: { ios: 1, android: 1 } },
    verifyAccess: async (h) =>
      h === 'Bearer admin' ? actor : h === 'Bearer rider' ? f.actor : null,
  });
  t.after(() => app.close());
  const payload = {
    amount: { amountMinor: purchase.cashDuePesewas, currency: 'GHS' },
    reason: 'Requested staging refund',
  };
  return { ...f, actor, purchase, refunds, app, payload };
}
test('REF-01 concurrent retries issue one TEST refund for cash only; response does not claim settlement', async (t) => {
  let calls = 0;
  const f = await fixture(t, async (_, amount) => {
    calls++;
    assert.equal(amount, 25400);
    return '123';
  });
  const key = randomUUID();
  const request = {
    method: 'POST' as const,
    url: `/v1/ops/purchases/${f.purchase.id}/refunds`,
    headers: {
      authorization: 'Bearer admin',
      'x-trotxi-client': 'ops',
      'x-trotxi-build': '1',
      'idempotency-key': key,
    },
    payload: f.payload,
  };
  const replies = await Promise.all([f.app.inject(request), f.app.inject(request)]);
  assert.ok(
    replies.every((r) => r.statusCode === 202),
    replies.map((r) => r.body).join('\n'),
  );
  assert.equal(calls, 1);
  assert.equal((await f.refunds.read(f.actor, f.purchase.id)).status, 200);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.payment_refunds')).rows[0].n,
    0,
  );
  assert.equal(
    (await f.owner.query('SELECT state FROM app.billing_periods')).rows[0].state,
    'open',
  );
  const retained = (await f.owner.query('SELECT * FROM app.refund_initiations')).rows[0];
  assert.equal(retained.actor_user_id, f.adminId);
  assert.equal(retained.reason, f.payload.reason);
  await assert.rejects(
    f.refunds.initiate(f.actor, f.purchase.id, { ...f.payload, reason: 'changed' }, key),
    (e: any) => e.code === 'idempotency_conflict',
  );
  await assert.rejects(
    f.refunds.initiate(f.actor, f.purchase.id, f.payload, randomUUID()),
    (e: any) => e.code === 'refund_already_requested',
  );
});
test('REF-02 uncertain provider outcome and fresh keys cannot issue another refund', async (t) => {
  let calls = 0;
  const f = await fixture(t, async () => {
    calls++;
    throw new Error('timeout with private provider body');
  });
  const key = randomUUID();
  const first = await f.refunds.initiate(f.actor, f.purchase.id, f.payload, key);
  assert.equal((first.body as any).data.state, 'unknown');
  assert.deepEqual(await f.refunds.initiate(f.actor, f.purchase.id, f.payload, key), first);
  await assert.rejects(f.refunds.initiate(f.actor, f.purchase.id, f.payload, randomUUID()));
  assert.equal(calls, 1);
  assert.ok(!JSON.stringify(first).includes('private provider'));
});
test('REF-03 authorization precedes purchase discovery, refund cannot exceed collected cash, live mode refuses', async (t) => {
  let calls = 0;
  const f = await fixture(t, async () => {
    calls++;
    return '1';
  });
  for (const id of [f.purchase.id, randomUUID()])
    await assert.rejects(
      f.refunds.initiate(f.actor === f.other ? f.actor : f.other, id, f.payload, randomUUID()),
      (e: any) => e.status === 403,
    );
  await assert.rejects(
    f.refunds.initiate(
      f.actor,
      f.purchase.id,
      { ...f.payload, amount: { amountMinor: 26400, currency: 'GHS' } },
      randomUUID(),
    ),
    (e: any) => e.code === 'refund_exceeds_remaining',
  );
  const live = new RefundInitiation({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    environment: 'live',
    initiate: async () => {
      calls++;
      return '1';
    },
  });
  await assert.rejects(
    live.initiate(f.actor, f.purchase.id, f.payload, randomUUID()),
    (e: any) => e.code === 'test_only',
  );
  assert.equal(calls, 0);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.refund_initiations')).rows[0].n,
    0,
  );
});
