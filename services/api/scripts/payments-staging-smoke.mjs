// Opt-in staging fixtures only. No period mutation, cleanup, or admin endpoints.
import assert from 'node:assert/strict';
import { createHash, createHmac, randomUUID } from 'node:crypto';
import { appendFile } from 'node:fs/promises';
import { setTimeout as delay } from 'node:timers/promises';
import { pathToFileURL } from 'node:url';
import { Pool } from 'pg';
import { SignJWT } from 'jose';

export function readConfig(env) {
  const phase = env.SMOKE_PHASE;
  assert.ok(['setup', 'verify-delivery', 'replay'].includes(phase), 'Unknown smoke phase');
  assert.equal(env.API_BASE_URL, 'https://trotxi-api-staging.onrender.com');
  assert.ok(env.PAYSTACK_SECRET_KEY?.startsWith('sk_test_'), 'Only sandbox keys are permitted');
  const fixtureId = env.FIXTURE_ID || (phase === 'setup' ? randomUUID() : '');
  assert.match(
    fixtureId,
    /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i,
    'Supply the fixture UUID from the setup run',
  );
  if (phase === 'setup') assert.ok(env.JWT_SECRET, 'Staging signing configuration required');
  const userId = fixtureId.toLowerCase();
  const hash = createHash('sha256').update(`payment-smoke-route:${userId}`).digest('hex');
  const routeId = `${hash.slice(0, 8)}-${hash.slice(8, 12)}-4${hash.slice(13, 16)}-a${hash.slice(17, 20)}-${hash.slice(20, 32)}`;
  return {
    phase,
    userId,
    routeId,
    label: `Payment smoke fixture ${userId}`,
    email: `payment-smoke-${userId}@example.com`,
    base: env.API_BASE_URL,
    secret: env.PAYSTACK_SECRET_KEY,
  };
}

export function assertDelivery(payment, provider, allocations, events, period) {
  assert.equal(payment.status, 'fulfilled');
  assert.equal(payment.purpose, 'subscription');
  assert.equal(payment.currency, 'GHS');
  assert.ok(Number.isSafeInteger(payment.rides_granted) && payment.rides_granted > 0);
  assert.ok(Number.isSafeInteger(payment.amount) && payment.amount > 0);
  assert.equal(payment.provider_domain, 'test');
  assert.equal(provider.domain, 'test');
  assert.equal(provider.status, 'success');
  assert.equal(provider.reference, payment.reference);
  assert.equal(provider.amount, payment.amount);
  assert.equal(provider.currency, 'GHS');
  assert.match(String(provider.id), /^\d+$/);
  assert.equal(String(provider.id), String(payment.provider_transaction_id));
  assert.equal(allocations.count, 1);
  assert.equal(allocations.rides, payment.rides_granted);
  assert.equal(period?.status, 'open');
  // Ignore this tool's explicitly marked replays. The application inbox does not
  // authenticate provenance beyond the shared HMAC; do not externally replay this
  // fixture when testing natural delivery.
  assert.ok(
    events.some((e) => e.status === 'processed' && !e.is_replay),
    "Expected a processed provider event, not just this tool's replay",
  );
  assert.ok(
    events.every((e) => e.status === 'processed'),
    'Inbox work remains unresolved',
  );
}

async function main() {
  const cfg = readConfig(process.env);
  const connection = new URL(process.env.DATABASE_URL);
  // URL SSL options override node-postgres ssl config. Remove them so verification
  // cannot silently disable certificate validation. Supply a trusted CA if needed.
  for (const key of ['sslmode', 'ssl', 'sslcert', 'sslkey', 'sslrootcert'])
    connection.searchParams.delete(key);
  const pool = new Pool({
    connectionString: connection.toString(),
    ssl: {
      rejectUnauthorized: true,
      ...(process.env.STAGING_DATABASE_CA_CERT ? { ca: process.env.STAGING_DATABASE_CA_CERT } : {}),
    },
    max: 2,
    options: cfg.phase === 'setup' ? undefined : '-c default_transaction_read_only=on',
    statement_timeout: 15000,
    connectionTimeoutMillis: 15000,
  });
  async function report(value) {
    console.log(value);
    if (process.env.GITHUB_STEP_SUMMARY)
      await appendFile(process.env.GITHUB_STEP_SUMMARY, `${value}\n\n`);
  }
  async function fixturePayment() {
    const identity = await pool.query(
      `SELECT u.display_name, u.email, r.name FROM users u CROSS JOIN routes r
       WHERE u.id=$1 AND r.id=$2`,
      [cfg.userId, cfg.routeId],
    );
    assert.equal(identity.rows[0]?.display_name, cfg.label, 'Fixture rider mismatch');
    assert.equal(identity.rows[0]?.email, cfg.email, 'Fixture email mismatch');
    assert.equal(identity.rows[0]?.name, cfg.label, 'Fixture route mismatch');
    const { rows } = await pool.query('SELECT * FROM payments WHERE user_id=$1', [cfg.userId]);
    assert.equal(rows.length, 1, 'Expected exactly one fixture checkout');
    return rows[0];
  }
  async function verifyProvider(payment) {
    const response = await fetch(
      `https://api.paystack.co/transaction/verify/${encodeURIComponent(payment.reference)}`,
      { headers: { authorization: `Bearer ${cfg.secret}` }, signal: AbortSignal.timeout(15000) },
    );
    assert.equal(response.status, 200);
    return (await response.json()).data;
  }
  async function checkDelivery() {
    let payment = await fixturePayment();
    for (let i = 0; i < 30 && payment.status !== 'fulfilled'; i++) {
      await delay(1000);
      payment = await fixturePayment();
    }
    const provider = await verifyProvider(payment);
    const allocations = await pool.query(
      `SELECT count(*)::int AS count, coalesce(sum(delta_rides),0)::int AS rides FROM entitlement_ledger
       WHERE user_id=$1 AND ref_type='payment' AND ref_id=$2 AND reason='allocation'`,
      [cfg.userId, payment.reference],
    );
    const events = await pool.query(
      `SELECT status, payload->>'verification_fixture' IS NOT NULL AS is_replay
       FROM payment_webhook_events WHERE reference=$1 AND event_type='charge.success'`,
      [payment.reference],
    );
    const periods = await pool.query(
      'SELECT status FROM subscription_periods WHERE id=$1 AND payment_id=$2 AND subscription_id=$3',
      [payment.subscription_period_id, payment.id, payment.subscription_id],
    );
    assertDelivery(payment, provider, allocations.rows[0], events.rows, periods.rows[0]);
    await report(
      `PASS delivery: ${payment.reference}; one allocation of ${allocations.rows[0].rides} rides; processed inbox events: ${events.rowCount}.`,
    );
    return { payment, provider };
  }
  try {
    await report(`Fixture UUID: ${cfg.userId}. Phase: ${cfg.phase}. Test domain only.`);
    if (cfg.phase === 'setup') {
      const client = await pool.connect();
      try {
        await client.query('BEGIN');
        // No upsert: reusing an existing fixture must fail without modifying it.
        await client.query('INSERT INTO users (id,display_name,email) VALUES ($1,$2,$3)', [
          cfg.userId,
          cfg.label,
          cfg.email,
        ]);
        await client.query('INSERT INTO routes (id,name,description) VALUES ($1,$2,$3)', [
          cfg.routeId,
          cfg.label,
          'Sandbox verification only; no trips or notification devices',
        ]);
        await client.query(
          'INSERT INTO corridor_fares (route_id,fare_pesewas,note) VALUES ($1,600,$2)',
          [cfg.routeId, cfg.label],
        );
        await client.query('COMMIT');
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      } finally {
        client.release();
      }
      const jwt = await new SignJWT({ role: 'commuter' })
        .setProtectedHeader({ alg: 'HS256' })
        .setSubject(cfg.userId)
        .setIssuedAt()
        .setIssuer(process.env.JWT_ISSUER)
        .setAudience(process.env.JWT_AUDIENCE)
        .setExpirationTime('10m')
        .sign(new TextEncoder().encode(process.env.JWT_SECRET));
      const checkout = () =>
        fetch(`${cfg.base}/payments/subscribe`, {
          method: 'POST',
          headers: { authorization: `Bearer ${jwt}`, 'content-type': 'application/json' },
          body: JSON.stringify({ plan: 'monthly', routeId: cfg.routeId }),
          signal: AbortSignal.timeout(30000),
        });
      const response = await checkout();
      assert.equal(response.status, 200, 'Checkout failed; fixture retained for investigation');
      const result = await response.json();
      const hosted = new URL(result.authorizationUrl);
      assert.equal(hosted.origin, 'https://checkout.paystack.com');
      await report(
        `Complete this TEST checkout: ${hosted.href}\nReference: ${result.reference}\nThen run verify-delivery with fixture UUID ${cfg.userId}.`,
      );
      assert.equal((await checkout()).status, 409, 'Duplicate checkout must be rejected');
      await report('PASS duplicate checkout rejected. Setup is not proof of payment fulfilment.');
    } else {
      // Require natural delivery BEFORE allowing the replay phase. Neither phase
      // uses reconciliation, period-close, or a manually signed event to recover it.
      const { payment, provider } = await checkDelivery();
      if (cfg.phase === 'replay') {
        const payload = JSON.stringify({
          event: 'charge.success',
          verification_fixture: cfg.userId,
          data: {
            id: provider.id,
            reference: provider.reference,
            status: provider.status,
            amount: provider.amount,
            currency: provider.currency,
            domain: provider.domain,
            channel: provider.channel,
            fees: provider.fees,
            paid_at: provider.paid_at,
          },
        });
        const signature = createHmac('sha512', cfg.secret).update(payload).digest('hex');
        const hash = createHash('sha256').update(payload).digest('hex');
        const responses = await Promise.all(
          [1, 2].map(() =>
            fetch(`${cfg.base}/webhooks/paystack`, {
              method: 'POST',
              headers: { 'content-type': 'application/json', 'x-paystack-signature': signature },
              body: payload,
              signal: AbortSignal.timeout(30000),
            }),
          ),
        );
        for (const response of responses) assert.equal(response.status, 200);
        let processed = false;
        for (let i = 0; i < 30; i++) {
          const event = await pool.query(
            'SELECT status FROM payment_webhook_events WHERE reference=$1 AND payload_sha256=$2',
            [payment.reference, hash],
          );
          if (event.rows[0]?.status === 'processed') {
            processed = true;
            break;
          }
          await delay(1000);
        }
        assert.ok(processed, 'Replay inbox event was not processed');
        await checkDelivery();
        await report('PASS two concurrent signed replays processed without a second allocation.');
      }
    }
  } finally {
    await pool.end();
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) await main();
