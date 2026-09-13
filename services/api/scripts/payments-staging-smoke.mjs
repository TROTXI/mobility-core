// Run against staging only. Hosted Paystack checkout is completed with official
// test payment details between phases. Preserve labelled fixture records for
// review. Expiry simulation changes timestamps on this fixture's period only.
import assert from 'node:assert/strict';
import { createHash, createHmac } from 'node:crypto';
import { setTimeout as delay } from 'node:timers/promises';
import { Pool } from 'pg';
import { SignJWT } from 'jose';

const base = process.env.API_BASE_URL;
const secret = process.env.PAYSTACK_SECRET_KEY;
assert.equal(base, 'https://trotxi-api-staging.onrender.com');
assert.ok(secret?.startsWith('sk_test_'), 'Only sandbox payments are permitted');
assert.ok(process.env.JWT_SECRET, 'Staging signing configuration required');
const naturalDelivery = process.env.SMOKE_PHASE?.startsWith('natural-');
const userId = naturalDelivery
  ? 'd9afdce5-19c6-4933-82c7-c9f58d104e6f'
  : '26a7363c-0a96-4ce5-9db2-ef42ab34c746';
const routeId = naturalDelivery
  ? '5bd8eafa-dc09-4872-86e0-a591438dd5d1'
  : '87217b45-71a9-497f-b72e-38c6c8dd7a6b';
const label = naturalDelivery
  ? 'Natural webhook verification fixture 2026-09-13'
  : 'Payment verification fixture 2026-09-13';
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
  max: 2,
  statement_timeout: 15000,
  connectionTimeoutMillis: 15000,
});

async function token(role) {
  return new SignJWT({ role })
    .setProtectedHeader({ alg: 'HS256' })
    .setSubject(userId)
    .setIssuedAt()
    .setIssuer(process.env.JWT_ISSUER)
    .setAudience(process.env.JWT_AUDIENCE)
    .setExpirationTime('10m')
    .sign(new TextEncoder().encode(process.env.JWT_SECRET));
}

async function api(path, body, role = 'commuter') {
  const res = await fetch(`${base}${path}`, {
    method: 'POST',
    headers: { authorization: `Bearer ${await token(role)}`, 'content-type': 'application/json' },
    body: JSON.stringify(body ?? {}),
    signal: AbortSignal.timeout(30000),
  });
  const data = await res.json();
  assert.ok(res.ok, `${path}: HTTP ${res.status}, ${JSON.stringify(data)}`);
  return data;
}

async function fixturePayments() {
  const user = await pool.query('SELECT display_name FROM users WHERE id = $1', [userId]);
  assert.equal(user.rows[0]?.display_name, label, 'Fixture identity mismatch');
  const result = await pool.query(
    'SELECT * FROM payments WHERE user_id = $1 ORDER BY created_at, id',
    [userId],
  );
  return result.rows;
}

async function subscriptionCheckout() {
  const result = await api('/payments/subscribe', { plan: 'monthly', routeId });
  console.log('HOSTED_TEST_CHECKOUT', JSON.stringify(result));
  const duplicate = await fetch(`${base}/payments/subscribe`, {
    method: 'POST',
    headers: {
      authorization: `Bearer ${await token('commuter')}`,
      'content-type': 'application/json',
    },
    body: JSON.stringify({ plan: 'monthly', routeId }),
    signal: AbortSignal.timeout(30000),
  });
  assert.equal(duplicate.status, 409, 'Duplicate checkout must be rejected');
  console.log('PASS duplicate checkout rejected');
  return result;
}

async function verifyAndReplay(payment) {
  const response = await fetch(
    `https://api.paystack.co/transaction/verify/${encodeURIComponent(payment.reference)}`,
    {
      headers: { authorization: `Bearer ${secret}` },
      signal: AbortSignal.timeout(15000),
    },
  );
  assert.equal(response.status, 200);
  const { data } = await response.json();
  assert.equal(data.domain, 'test');
  assert.equal(data.status, 'success', 'Complete the hosted sandbox checkout before this phase');
  assert.equal(data.reference, payment.reference);
  assert.equal(data.amount, payment.amount);
  assert.equal(data.currency, 'GHS');
  const before = await pool.query('SELECT status FROM payments WHERE id = $1', [payment.id]);
  console.log('NATURAL_WEBHOOK_STATE', before.rows[0].status);
  const replay = JSON.stringify({
    event: 'charge.success',
    data: {
      id: data.id,
      reference: data.reference,
      status: data.status,
      amount: data.amount,
      currency: data.currency,
      domain: data.domain,
      channel: data.channel,
      fees: data.fees,
      paid_at: data.paid_at,
    },
  });
  const signature = createHmac('sha512', secret).update(replay).digest('hex');
  const replayHash = createHash('sha256').update(replay).digest('hex');
  const inbox = await pool.query(
    `SELECT status, count(*)::int AS events FROM payment_webhook_events
     WHERE reference=$1 AND payload_sha256<>$2 GROUP BY status`,
    [payment.reference, replayHash],
  );
  console.log('PROVIDER_INBOX_BEFORE_REPLAY', JSON.stringify(inbox.rows));
  const responses = await Promise.all(
    [1, 2].map(() =>
      fetch(`${base}/webhooks/paystack`, {
        method: 'POST',
        headers: { 'content-type': 'application/json', 'x-paystack-signature': signature },
        body: replay,
        signal: AbortSignal.timeout(30000),
      }),
    ),
  );
  for (const res of responses) assert.equal(res.status, 200);
  let fulfilled;
  for (let i = 0; i < 20; i++) {
    fulfilled = (await pool.query('SELECT * FROM payments WHERE id=$1', [payment.id])).rows[0];
    if (fulfilled.status === 'fulfilled') break;
    await delay(1000);
  }
  assert.equal(fulfilled.status, 'fulfilled');
  assert.equal(fulfilled.provider_domain, 'test');
  const allocations = await pool.query(
    `SELECT count(*)::int AS count, sum(delta_rides)::int AS rides FROM entitlement_ledger
     WHERE user_id=$1 AND ref_type='payment' AND ref_id=$2 AND reason='allocation'`,
    [userId, payment.reference],
  );
  assert.equal(allocations.rows[0].count, 1);
  assert.equal(allocations.rows[0].rides, payment.rides_granted);
  console.log(
    'PASS Paystack success verified and two webhook replays left exactly one allocation',
    payment.reference,
  );
  return fulfilled;
}

try {
  if (['setup', 'natural-setup'].includes(process.env.SMOKE_PHASE)) {
    const existing = await pool.query('SELECT id FROM users WHERE id=$1', [userId]);
    assert.equal(existing.rowCount, 0, 'Fixture already exists; do not initialize it again');
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      await client.query('INSERT INTO users (id, display_name, email) VALUES ($1,$2,$3)', [
        userId,
        label,
        naturalDelivery
          ? 'payments-webhook-smoke@example.com'
          : 'payments-staging-smoke@example.com',
      ]);
      await client.query('INSERT INTO routes (id, name, description) VALUES ($1,$2,$3)', [
        routeId,
        label,
        'Sandbox payment verification only; no trips or notifications',
      ]);
      await client.query(
        'INSERT INTO corridor_fares (route_id, fare_pesewas, note) VALUES ($1,600,$2)',
        [routeId, label],
      );
      await client.query('COMMIT');
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
    await subscriptionCheckout();
  } else if (process.env.SMOKE_PHASE === 'natural-check') {
    // This phase never posts or replays a webhook and never invokes reconciliation.
    // The only fulfilment source for this fresh fixture must be Paystack delivery.
    const payments = await fixturePayments();
    assert.equal(payments.length, 1);
    let payment = payments[0];
    for (let i = 0; i < 30 && payment.status !== 'fulfilled'; i++) {
      await delay(1000);
      [payment] = await fixturePayments();
    }
    assert.equal(payment.status, 'fulfilled', 'Automatic provider webhook must fulfil payment');
    assert.equal(payment.provider_domain, 'test');
    const response = await fetch(
      `https://api.paystack.co/transaction/verify/${encodeURIComponent(payment.reference)}`,
      { headers: { authorization: `Bearer ${secret}` }, signal: AbortSignal.timeout(15000) },
    );
    assert.equal(response.status, 200);
    const { data } = await response.json();
    assert.equal(data.domain, 'test');
    assert.equal(data.status, 'success');
    assert.equal(data.reference, payment.reference);
    assert.equal(data.amount, payment.amount);
    assert.equal(data.currency, 'GHS');
    const inbox = await pool.query(
      'SELECT status, count(*)::int AS events FROM payment_webhook_events WHERE reference=$1 GROUP BY status',
      [payment.reference],
    );
    assert.ok(inbox.rows.some((row) => row.status === 'processed' && row.events >= 1));
    assert.ok(inbox.rows.every((row) => row.status === 'processed'));
    const allocations = await pool.query(
      `SELECT count(*)::int AS count, sum(delta_rides)::int AS rides FROM entitlement_ledger
       WHERE user_id=$1 AND ref_type='payment' AND ref_id=$2 AND reason='allocation'`,
      [userId, payment.reference],
    );
    assert.equal(allocations.rows[0].count, 1);
    assert.equal(allocations.rows[0].rides, payment.rides_granted);
    const periods = await pool.query(
      'SELECT status FROM subscription_periods WHERE id=$1 AND payment_id=$2',
      [payment.subscription_period_id, payment.id],
    );
    assert.equal(periods.rows[0]?.status, 'open');
    console.log(
      'PASS automatic Paystack delivery: fulfilled with exactly one allocation; no manual replay or reconciliation',
    );
    console.log(
      'NATURAL_DELIVERY_EVIDENCE',
      JSON.stringify({
        userId,
        routeId,
        reference: payment.reference,
        status: payment.status,
        subscriptionId: payment.subscription_id,
        periodId: payment.subscription_period_id,
        inbox: inbox.rows,
        allocations: allocations.rows[0],
      }),
    );
  } else if (process.env.SMOKE_PHASE === 'close-renew') {
    const payments = await fixturePayments();
    assert.equal(payments.length, 1);
    const first = await verifyAndReplay(payments[0]);
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      await client.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [userId]);
      const unrelated = await client.query(
        `SELECT p.id FROM subscription_periods p JOIN subscriptions s ON s.id=p.subscription_id
         WHERE p.status='open' AND p.period_end<=now() AND s.status='active' AND s.user_id<>$1`,
        [userId],
      );
      assert.equal(
        unrelated.rowCount,
        0,
        'Other ended periods exist; do not run a global close for this smoke test',
      );
      const updated = await client.query(
        `UPDATE subscription_periods SET period_start=now()-interval '1 month 1 minute',
         period_end=now()-interval '1 minute'
         WHERE id=$1 AND payment_id=$2 AND status='open' RETURNING period_start,period_end`,
        [first.subscription_period_id, first.id],
      );
      assert.equal(updated.rowCount, 1);
      await client.query(
        'UPDATE subscriptions SET period_start=$2,period_end=$3 WHERE id=$1 AND user_id=$4',
        [first.subscription_id, updated.rows[0].period_start, updated.rows[0].period_end, userId],
      );
      await client.query('COMMIT');
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
    console.log('TEST_CLOCK: moved only this fixture first period to the past');
    const close = await api('/admin/close-subscription-periods', {}, 'admin');
    assert.equal(close.closed, 1);
    assert.equal(close.ridesConverted, first.rides_granted);
    assert.equal(close.creditPesewas, first.rides_granted * first.credit_pesewas_per_ride);
    const repeat = await api('/admin/close-subscription-periods', {}, 'admin');
    assert.equal(repeat.closed, 0);
    console.log('PASS period close and replay', JSON.stringify(close));
    const renewal = await subscriptionCheckout();
    assert.equal(renewal.appliedCreditPesewas, close.creditPesewas);
    console.log('PASS renewal reserved the exact converted credit');
  } else if (process.env.SMOKE_PHASE === 'finish') {
    const payments = await fixturePayments();
    assert.equal(payments.length, 2);
    const firstEvents = await pool.query(
      `SELECT status, count(*)::int AS events FROM payment_webhook_events
       WHERE reference=$1 GROUP BY status`,
      [payments[0].reference],
    );
    console.log('FIRST_PAYMENT_INBOX_TOTAL', JSON.stringify(firstEvents.rows));
    const second = await verifyAndReplay(payments[1]);
    assert.equal(second.subscription_id, payments[0].subscription_id);
    assert.notEqual(second.subscription_period_id, payments[0].subscription_period_id);
    const periods = await pool.query(
      'SELECT status FROM subscription_periods WHERE subscription_id=$1 ORDER BY period_start',
      [second.subscription_id],
    );
    assert.deepEqual(
      periods.rows.map((row) => row.status),
      ['closed', 'open'],
    );
    const balance = await pool.query(
      'SELECT coalesce(sum(delta_pesewas),0)::int AS credit FROM credit_ledger WHERE user_id=$1',
      [userId],
    );
    assert.equal(balance.rows[0].credit, 0);
    const rides = await pool.query(
      'SELECT coalesce(sum(delta_rides),0)::int AS rides FROM entitlement_ledger WHERE user_id=$1',
      [userId],
    );
    assert.equal(rides.rows[0].rides, second.rides_granted);
    const hold = await pool.query(
      'SELECT status,amount_pesewas FROM credit_holds WHERE payment_id=$1',
      [second.id],
    );
    assert.equal(hold.rows[0].status, 'captured');
    assert.equal(hold.rows[0].amount_pesewas, second.applied_credit_pesewas);
    console.log(
      'PASS renewal reused membership, created new period, captured exact credit, and allocated exactly one new batch of rides',
    );
    console.log(
      'FINAL_FIXTURE',
      JSON.stringify({
        userId,
        routeId,
        subscriptionId: second.subscription_id,
        paymentReferences: payments.map((p) => p.reference),
        rides: rides.rows[0].rides,
        credit: balance.rows[0].credit,
      }),
    );
  } else throw new Error('Unknown smoke phase');
} finally {
  await pool.end();
}
