import { test, after } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID, randomBytes } from 'node:crypto';
import { mkdir, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import pg from 'pg';
import { readMigrations, migrate, grantRuntime } from '../src/db/migrate.js';
import { FinancialFoundation } from '../src/payments/foundation.js';
import type {
  CheckoutInput,
  FinancialDependencies,
  Settlement,
} from '../src/payments/foundation.js';
import { priceTerms } from '../src/payments/terms.js';
import { TransportError } from '../src/transport/errors.js';

const raw = process.env.HARNESS_ADMIN_DATABASE_URL;
if (!raw || process.env.HARNESS_ALLOW_CREATE_DATABASES !== '1')
  throw new Error('Explicit disposable Postgres required; financial tests never skip');
const url = new URL(raw);
if (
  !['postgres:', 'postgresql:'].includes(url.protocol) ||
  !['127.0.0.1', 'localhost', '[::1]'].includes(url.hostname) ||
  url.pathname !== '/postgres' ||
  url.search ||
  url.hash
)
  throw new Error('Only loopback disposable postgres admin database is allowed');
const admin = new pg.Pool({ connectionString: url.href, max: 2 });
const files = await readMigrations(fileURLToPath(new URL('../migrations/', import.meta.url)));
const run = randomBytes(5).toString('hex'),
  owned: string[] = [],
  roles: string[] = [],
  evidence: unknown[] = [];
let serial = 0;
after(async () => {
  try {
    for (const name of owned) await admin.query(`DROP DATABASE "${name}"`);
    for (const role of roles) await admin.query(`DROP ROLE "${role}"`);
    if (process.env.REPLACEMENT_EVIDENCE_DIR) {
      await mkdir(process.env.REPLACEMENT_EVIDENCE_DIR, { recursive: true });
      await writeFile(
        resolve(process.env.REPLACEMENT_EVIDENCE_DIR, 'payment-foundation-metadata.json'),
        JSON.stringify(
          {
            kind: 'financial-foundation-not-complete-payment-comparison',
            limitation:
              'Real contiguous migration chain and financial domain tests; NOT HTTP/provider/commute integration or complete baseline/candidate comparison.',
            migrations: files.map(({ name, sha256 }) => ({ name, sha256 })),
            evidence,
            cleanedDatabases: owned,
            cleanedRoles: roles,
          },
          null,
          2,
        ),
      );
    }
  } finally {
    await admin.end();
  }
});
const at = new Date('2026-01-01T00:00:00Z'),
  renewAt = new Date('2026-02-02T00:00:00Z');
async function setup(
  t: TestContext,
  overrides: Partial<FinancialDependencies> = {},
  upgrade = false,
) {
  const n = ++serial,
    name = `trotxi_harness_${run}_finance_${n}`,
    role = `trotxi_runtime_fin_${run}_${n}`;
  await admin.query(`CREATE DATABASE "${name}"`);
  owned.push(name);
  const db = new URL(url);
  db.pathname = '/' + name;
  const owner = new pg.Pool({ connectionString: db.href, max: 5 });
  t.after(() => owner.end());
  if (upgrade) {
    await migrate(owner, files.slice(0, 10));
    const vehicle = (
      await owner.query(
        "INSERT INTO app.vehicles(plate,capacity) VALUES ('TEST UPGRADE 010',18) RETURNING *",
      )
    ).rows[0];
    const history = (
      await owner.query('SELECT name,sha256 FROM public._replacement_migrations ORDER BY name')
    ).rows;
    assert.deepEqual(await migrate(owner, files), ['011_payment_foundation.sql']);
    assert.deepEqual(
      (await owner.query('SELECT * FROM app.vehicles WHERE id=$1', [vehicle.id])).rows[0],
      vehicle,
    );
    assert.deepEqual(
      (
        await owner.query(
          'SELECT name,sha256 FROM public._replacement_migrations ORDER BY name LIMIT 10',
        )
      ).rows,
      history,
    );
    assert.deepEqual(await migrate(owner, files), []);
  } else await migrate(owner, files);
  const id = async (sql: string, args: unknown[] = []) =>
    (await owner.query(sql + ' RETURNING id', args)).rows[0].id as string;
  const userId = await id("INSERT INTO app.users(role) VALUES ('commuter')"),
    otherId = await id("INSERT INTO app.users(role) VALUES ('commuter')");
  const adminId = await id("INSERT INTO app.users(role) VALUES ('admin')");
  await owner.query(
    'CREATE TABLE app.test_fin_sessions(user_id uuid PRIMARY KEY, active boolean NOT NULL)',
  );
  await owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true),($2,true)', [
    userId,
    otherId,
  ]);
  const route = await id("INSERT INTO app.routes(name) VALUES ('Financial test corridor')");
  const legs: CheckoutInput['legs'] = [];
  for (const direction of ['outbound', 'return'] as const) {
    const pattern = await id('INSERT INTO app.route_patterns(route_id,direction) VALUES ($1,$2)', [
      route,
      direction,
    ]);
    const version = await id(
      'INSERT INTO app.route_pattern_versions(pattern_id,revision) VALUES ($1,1)',
      [pattern],
    );
    const physical = await id(
      "INSERT INTO app.stops(name,latitude,longitude) VALUES ('Fixture',5.6,-0.2)",
    );
    const occurrences: string[] = [];
    for (let ordinal = 0; ordinal < 2; ordinal++)
      occurrences.push(
        await id(
          "INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude) VALUES ($1,$2,$3,'Fixture',5.6,-0.2)",
          [version, physical, ordinal],
        ),
      );
    const geom = await id(
      "INSERT INTO app.route_geometries(pattern_version_id,source,line) VALUES ($1,'configured',ST_GeomFromText('LINESTRING(-0.2 5.6,-0.21 5.6,-0.2 5.6)',4326))",
      [version],
    );
    for (const [i, occ] of occurrences.entries())
      await owner.query('INSERT INTO app.geometry_stop_distances VALUES ($1,$2,$3,$4)', [
        geom,
        version,
        occ,
        i * 1000,
      ]);
    await owner.query("UPDATE app.route_geometries SET state='published' WHERE id=$1", [geom]);
    await owner.query(
      "UPDATE app.route_pattern_versions SET state='published',geometry_id=$2,effective_from='2025-01-01' WHERE id=$1",
      [version, geom],
    );
    const departure = await id('INSERT INTO app.service_departures(pattern_id) VALUES ($1)', [
      pattern,
    ]);
    const schedule = await id(
      `INSERT INTO app.service_schedules(departure_id,pattern_id,pattern_version_id,service_window,local_departure,weekdays,effective_from)
    VALUES ($1,$2,$3,$4,'06:30',ARRAY[1,2,3,4,5,6,7]::smallint[],'2025-01-01')`,
      [departure, pattern, version, direction === 'outbound' ? 'morning' : 'evening'],
    );
    legs.push({
      direction,
      scheduleId: schedule,
      patternVersionId: version,
      pickupOccurrenceId: occurrences[0]!,
      dropoffOccurrenceId: occurrences[1]!,
    });
  }
  await admin.query(`CREATE ROLE "${role}" LOGIN PASSWORD 'runtime-test-only'`);
  roles.push(role);
  await grantRuntime(owner, role);
  db.username = role;
  db.password = 'runtime-test-only';
  const applicationName = `finance-${run}-${n}`,
    runtime = new pg.Pool({ connectionString: db.href, max: 8, application_name: applicationName });
  t.after(() => runtime.end());
  const actor = { userId, sessionId: userId },
    other = { userId: otherId, sessionId: otherId };
  const input: CheckoutInput = { plan: 'monthly', routeId: route, legs, useCredit: true };
  const terms = priceTerms({
    farePesewas: 600,
    ridesGranted: 44,
    priceMultiplierBp: 10000,
    conversionRatePesewas: 45,
  });
  const dependencies: FinancialDependencies = {
    pool: runtime,
    environment: 'test',
    authorizeSession: async (c, a) => {
      if (
        !(
          await c.query(
            'SELECT 1 FROM app.test_fin_sessions WHERE user_id=$1 AND active FOR SHARE',
            [a.userId],
          )
        ).rowCount
      )
        throw new TransportError(401, 'unauthenticated', 'Test session revoked');
    },
    // Domain-isolated test boundaries. They are not a real pricing/access/booking
    // implementation; production composition remains unwired and fail-closed.
    quote: async () => terms,
    assertCheckoutAllowed: async () => {},
    assertPeriodCanClose: async () => {},
    materializeAssignment: async () => {},
    ...overrides,
  };
  const service = new FinancialFoundation(dependencies);
  const buy = (key = randomUUID(), date = at, who = actor) =>
    service.checkout(who, input, key, date);
  const grant = async (amount: number, who = userId) => {
    const adjustment = await id(
      "INSERT INTO app.credit_adjustments(user_id,actor_user_id,delta_pesewas,reason) VALUES ($1,$2,$3,'Fixture adjustment')",
      [who, adminId, amount],
    );
    await owner.query(
      "INSERT INTO app.credit_entries(user_id,reason,delta_pesewas,adjustment_id) VALUES ($1,'adjustment',$2,$3)",
      [who, amount, adjustment],
    );
  };
  const settle = (p: Awaited<ReturnType<typeof buy>>, date = at): Settlement => ({
    reference: p.attempt.reference,
    environment: 'test',
    amountPesewas: p.cashDuePesewas,
    currency: 'GHS',
    transactionId: p.attempt.id,
    paidAt: date,
    channel: 'mobile_money',
    feesPesewas: 0,
  });
  const period = async (p: string) =>
    (await owner.query('SELECT * FROM app.billing_periods WHERE purchase_id=$1', [p])).rows[0];
  const lock = async () => {
    const c = await owner.connect();
    await c.query('BEGIN');
    await c.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [userId]);
    return c;
  };
  const waiters = async (count: number) => {
    for (let i = 0; i < 200; i++) {
      const rows = (
        await owner.query(
          "SELECT pid FROM pg_stat_activity WHERE application_name=$1 AND wait_event_type='Lock'",
          [applicationName],
        )
      ).rows;
      if (rows.length >= count) {
        evidence.push({ test: t.name, waiterPids: rows.map((r) => r.pid) });
        return;
      }
      await delay(10);
    }
    assert.fail('Required real PostgreSQL contention was not observed');
  };
  evidence.push({ test: t.name });
  return {
    owner,
    runtime,
    role,
    actor,
    other,
    input,
    terms,
    dependencies,
    service,
    buy,
    grant,
    settle,
    period,
    lock,
    waiters,
  };
}

test('FIN-01 / PAY-01: financial source fields have pesewa units and runtime cannot mutate ledger history', async (t) => {
  const f = await setup(t);
  const rows = (
    await f.owner.query(
      "SELECT c.relname,a.attname,col_description(c.oid,a.attnum) AS comment FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace JOIN pg_attribute a ON a.attrelid=c.oid WHERE n.nspname='app' AND a.attname LIKE '%pesewas' AND a.attnum>0",
    )
  ).rows;
  assert.equal(rows.length, 12);
  for (const r of rows) assert.match(r.comment, /pesewas/);
  await f.grant(1000);
  await assert.rejects(
    f.runtime.query('UPDATE app.credit_entries SET delta_pesewas=2000'),
    (e) => (e as { code: string }).code === '42501',
  );
  await assert.rejects(
    f.runtime.query('DELETE FROM app.credit_entries'),
    (e) => (e as { code: string }).code === '42501',
  );
  assert.equal(
    (
      await f.owner.query(
        "SELECT pg_has_role($1,(SELECT relowner FROM pg_class WHERE oid='app.credit_entries'::regclass),'MEMBER') AS inherits",
        [f.role],
      )
    ).rows[0].inherits,
    false,
  );
});
test('FIN-02 / PAY-02: real concurrent checkouts cannot promise the same credit', async (t) => {
  const f = await setup(t);
  await f.grant(1000);
  const blocker = await f.lock(),
    a = f.buy(),
    b = f.buy();
  try {
    await f.waiters(2);
  } finally {
    await blocker.query('COMMIT');
    blocker.release();
  }
  const out = await Promise.allSettled([a, b]);
  assert.equal(out.filter((r) => r.status === 'fulfilled').length, 1);
  assert.equal(out.filter((r) => r.status === 'rejected').length, 1);
  assert.deepEqual(await f.service.balance(f.actor), { credit: 1000, held: 1000, available: 0 });
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT (SELECT count(*)::int FROM app.purchases) AS purchases,(SELECT count(*)::int FROM app.payment_attempts) AS attempts,(SELECT count(*)::int FROM app.credit_holds) AS holds',
      )
    ).rows[0],
    { purchases: 1, attempts: 1, holds: 1 },
  );
});
test('FIN-03: same-key replay preserves frozen terms; changed payload and revoked session cannot replay', async (t) => {
  const f = await setup(t),
    key = randomUUID(),
    p = await f.buy(key);
  f.terms.priceMultiplierBp = 20000;
  f.terms.pricePesewas = 52800;
  assert.deepEqual(await f.buy(key), p);
  await assert.rejects(
    f.service.checkout(f.actor, { ...f.input, useCredit: false }, key, at),
    (e) => (e as TransportError).code === 'idempotency_conflict',
  );
  await f.owner.query('UPDATE app.test_fin_sessions SET active=false WHERE user_id=$1', [
    f.actor.userId,
  ]);
  await assert.rejects(f.buy(key), (e) => (e as TransportError).code === 'unauthenticated');
});
test('FIN-04 / PAY-03 domain boundary: concurrent settlement allocates once and captures credit once', async (t) => {
  const f = await setup(t);
  await f.grant(1000);
  const p = await f.buy(),
    blocker = await f.lock();
  const a = f.service.fulfill(f.settle(p)),
    b = f.service.fulfill(f.settle(p));
  try {
    await f.waiters(2);
  } finally {
    await blocker.query('COMMIT');
    blocker.release();
  }
  assert.deepEqual((await Promise.all([a, b])).sort(), ['already_fulfilled', 'fulfilled']);
  assert.deepEqual(await f.service.balance(f.actor), { credit: 0, held: 0, available: 0 });
  assert.deepEqual(
    (
      await f.owner.query(
        "SELECT (SELECT count(*)::int FROM app.billing_periods) AS periods,(SELECT sum(delta_rides)::int FROM app.ride_entries) AS rides,(SELECT count(*)::int FROM app.ride_entries WHERE reason='allocation') AS allocations,(SELECT count(*)::int FROM app.credit_entries WHERE reason='purchase_applied') AS captures",
      )
    ).rows[0],
    { periods: 1, rides: 44, allocations: 1, captures: 1 },
  );
});
test('FIN-05 / PAY-04–06: close racing renewal converts once; next purchase gets frozen-rate credit and distinct coverage', async (t) => {
  const f = await setup(t),
    first = await f.buy();
  await f.service.fulfill(f.settle(first));
  // New prices must not change the first purchase's frozen conversion rate.
  f.terms.conversionRatePesewas = 90;
  const old = await f.period(first.id),
    blocker = await f.lock();
  const closing = f.service.closePeriod(old.id, renewAt),
    renewal = f.buy(randomUUID(), renewAt);
  try {
    await f.waiters(2);
  } finally {
    await blocker.query('COMMIT');
    blocker.release();
  }
  const [, next] = await Promise.all([closing, renewal]);
  assert.equal(next.appliedCreditPesewas, 1980);
  assert.equal(await f.service.fulfill(f.settle(next, renewAt)), 'fulfilled');
  assert.equal(await f.service.fulfill(f.settle(next, renewAt)), 'already_fulfilled');
  assert.deepEqual(
    (
      await f.owner.query(
        "SELECT (SELECT count(*)::int FROM app.period_closures) AS closes,(SELECT sum(credit_granted_pesewas)::int FROM app.period_closures) AS converted,(SELECT count(DISTINCT purchase_id)::int FROM app.billing_periods) AS purchases,(SELECT purchase_id FROM app.billing_periods WHERE state='open') AS current",
      )
    ).rows[0],
    { closes: 1, converted: 1980, purchases: 2, current: next.id },
  );
  assert.equal((await f.period(first.id)).state, 'closed');
  assert.deepEqual(await f.service.balance(f.actor), { credit: 0, held: 0, available: 0 });
});
test('FIN-06 / PAY-07 boundary and PAY-09 interface: close guards fail without mutations and exact boundary succeeds', async (t) => {
  const f = await setup(t),
    p = await f.buy();
  await f.service.fulfill(f.settle(p));
  const period = await f.period(p.id);
  assert.equal(
    await f.service.closePeriod(period.id, new Date(period.effective_ends_at.getTime() - 1)),
    false,
  );
  const blocked = new FinancialFoundation({
    ...f.dependencies,
    assertPeriodCanClose: async () => {
      throw new TransportError(409, 'period_close_blocked', 'Unsettled funded reservation');
    },
  });
  await assert.rejects(
    blocked.closePeriod(period.id, renewAt),
    (e) => (e as TransportError).code === 'period_close_blocked',
  );
  await assert.rejects(
    blocked.checkout(f.actor, f.input, randomUUID(), renewAt),
    (e) => (e as TransportError).code === 'period_close_blocked',
  );
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.period_closures')).rows[0].n,
    0,
  );
  assert.equal((await f.period(p.id)).state, 'open');
  assert.equal(await f.service.closePeriod(period.id, period.effective_ends_at), true);
});
test('FIN-07: post-allocation assignment failure rolls back attempt, period, rides and captured credit', async (t) => {
  let reached = false;
  const f = await setup(t, {
    materializeAssignment: async (client) => {
      assert.equal(
        (await client.query('SELECT count(*)::int AS n FROM app.ride_entries')).rows[0].n,
        1,
      );
      reached = true;
      throw new Error('injected_assignment_failure');
    },
  });
  await f.grant(1000);
  const p = await f.buy();
  await assert.rejects(f.service.fulfill(f.settle(p)));
  assert.equal(reached, true, 'failure must happen after allocation, not earlier plumbing');
  assert.deepEqual(await f.service.balance(f.actor), { credit: 1000, held: 1000, available: 0 });
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.billing_periods')).rows[0].n,
    0,
  );
  assert.equal(
    (await f.owner.query('SELECT state FROM app.payment_attempts WHERE purchase_id=$1', [p.id]))
      .rows[0].state,
    'pending',
  );
  const recovered = new FinancialFoundation({
    ...f.dependencies,
    materializeAssignment: async () => {},
  });
  assert.equal(await recovered.fulfill(f.settle(p)), 'fulfilled');
});
test('FIN-08: provider amount, currency, environment and transaction identity mismatches never grant value', async (t) => {
  const f = await setup(t),
    p = await f.buy(),
    s = f.settle(p);
  for (const bad of [
    { ...s, amountPesewas: s.amountPesewas + 1 },
    { ...s, currency: 'USD' },
    { ...s, environment: 'live' as const },
    { ...s, transactionId: '' },
  ])
    assert.equal(await f.service.fulfill(bad), 'mismatch');
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.billing_periods')).rows[0].n,
    0,
  );
  assert.equal(await f.service.fulfill(s), 'fulfilled');
  assert.equal(await f.service.fulfill({ ...s, transactionId: 'different' }), 'mismatch');
});
test('FIN-09 / OWN-01: direct SQL rejects cross-rider funding and second allocation', async (t) => {
  const f = await setup(t),
    p = await f.buy();
  await f.service.fulfill(f.settle(p));
  const period = await f.period(p.id);
  await assert.rejects(
    f.runtime.query(
      // Failed state avoids the pending-attempt unique index: only the ownership
      // FK can reject this otherwise-valid, fresh provider reference.
      "INSERT INTO app.payment_attempts(user_id,purchase_id,provider,environment,reference,state,amount_pesewas,currency) VALUES ($1,$2,'paystack','test',$3,'failed',26400,'GHS')",
      [f.other.userId, p.id, randomUUID()],
    ),
    (e) => (e as { code: string }).code === '23503',
  );
  await assert.rejects(
    f.runtime.query(
      "INSERT INTO app.credit_adjustments(user_id,actor_user_id,delta_pesewas,reason) VALUES ($1,$1,0,'invalid')",
      [f.other.userId],
    ),
    (e) => (e as { code: string }).code === '23514',
  );
  await assert.rejects(
    f.runtime.query(
      "INSERT INTO app.ride_entries(user_id,period_id,reason,delta_rides) VALUES ($1,$2,'allocation',44)",
      [f.actor.userId, period.id],
    ),
    (e) => (e as { code: string }).code === '23505',
  );
  assert.equal(
    (await f.owner.query('SELECT sum(delta_rides)::int AS rides FROM app.ride_entries')).rows[0]
      .rides,
    44,
  );
});
test('FIN-10: purchase terms cannot change, conversion rate cannot be NULL, invalid paired legs leave no key', async (t) => {
  const f = await setup(t),
    key = randomUUID();
  await assert.rejects(
    f.service.checkout(
      f.actor,
      { ...f.input, legs: [f.input.legs[0]!, f.input.legs[0]!] },
      key,
      at,
    ),
  );
  assert.equal((await f.owner.query('SELECT count(*)::int AS n FROM app.purchases')).rows[0].n, 0);
  const p = await f.buy(key);
  await assert.rejects(
    f.runtime.query('UPDATE app.purchases SET conversion_rate_pesewas=NULL WHERE id=$1', [p.id]),
    (e) => (e as { code: string }).code === '23514',
  );
  await assert.rejects(
    f.runtime.query('UPDATE app.purchases SET price_pesewas=100 WHERE id=$1', [p.id]),
    (e) => (e as { code: string }).code === '23514',
  );
  await assert.rejects(
    f.runtime.query('UPDATE app.memberships SET user_id=$2 WHERE id=$1', [
      p.membershipId,
      f.other.userId,
    ]),
    (e) => (e as Error).message === 'immutable_membership_identity',
  );
});
test('FIN-11: missing cross-domain adapters fail closed; credit leaves the provider minimum', async (t) => {
  const f = await setup(t);
  await f.grant(99999);
  await assert.rejects(
    new FinancialFoundation({ ...f.dependencies, assertCheckoutAllowed: undefined }).checkout(
      f.actor,
      f.input,
      randomUUID(),
      at,
    ),
    (e) => (e as TransportError).code === 'financial_dependencies_unavailable',
  );
  const p = await f.buy();
  assert.equal(p.cashDuePesewas, 100);
  assert.equal(p.appliedCreditPesewas, 26300);
  await assert.rejects(
    new FinancialFoundation({ ...f.dependencies, materializeAssignment: undefined }).fulfill(
      f.settle(p),
    ),
    (e) => (e as TransportError).code === 'financial_dependencies_unavailable',
  );
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.billing_periods')).rows[0].n,
    0,
  );
});

test('FIN-12: a valid adjustment cannot spend credit already held for a purchase', async (t) => {
  const f = await setup(t);
  await f.grant(1000);
  await f.buy();
  // This bypasses checkout entirely: the ledger/hold guard itself must reject
  // spending even one pesewa, not the one-unresolved-purchase guard.
  const adjustment = (
    await f.runtime.query(
      "INSERT INTO app.credit_adjustments(user_id,actor_user_id,delta_pesewas,reason) VALUES ($1,$1,-1,'Fixture debit') RETURNING id",
      [f.actor.userId],
    )
  ).rows[0].id;
  await assert.rejects(
    f.runtime.query(
      "INSERT INTO app.credit_entries(user_id,reason,delta_pesewas,adjustment_id) VALUES ($1,'adjustment',-1,$2)",
      [f.actor.userId, adjustment],
    ),
    (e) => (e as Error).message === 'credit_entry_consumes_held_or_missing_value',
  );
  assert.deepEqual(await f.service.balance(f.actor), { credit: 1000, held: 1000, available: 0 });
});

test('FIN-13: genuinely concurrent identical checkout retries return one purchase and one hold', async (t) => {
  const f = await setup(t);
  await f.grant(1000);
  const key = randomUUID(),
    blocker = await f.lock();
  const a = f.buy(key),
    b = f.buy(key);
  try {
    await f.waiters(2);
  } finally {
    await blocker.query('COMMIT');
    blocker.release();
  }
  const [first, second] = await Promise.all([a, b]);
  assert.deepEqual(first, second);
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT (SELECT count(*)::int FROM app.purchases) AS purchases,(SELECT count(*)::int FROM app.payment_attempts) AS attempts,(SELECT count(*)::int FROM app.credit_holds) AS holds',
      )
    ).rows[0],
    { purchases: 1, attempts: 1, holds: 1 },
  );
});

test('FIN-14: capture without debit fails at commit; exact capture plus debit commits', async (t) => {
  const f = await setup(t);
  await f.grant(1000);
  const purchase = await f.buy(),
    c = await f.runtime.connect();
  try {
    await c.query('BEGIN');
    const update = await c.query(
      "UPDATE app.credit_holds SET state='captured',settled_at=clock_timestamp() WHERE purchase_id=$1",
      [purchase.id],
    );
    assert.equal(
      update.rowCount,
      1,
      'intermediate capture must succeed before deferred validation',
    );
    await assert.rejects(c.query('COMMIT'), (error) => {
      const e = error as { code: string; constraint: string };
      return e.code === '23514' && e.constraint === 'captured_hold_requires_debit';
    });
    await c.query('ROLLBACK');
    assert.deepEqual(await f.service.balance(f.actor), { credit: 1000, held: 1000, available: 0 });
    assert.equal(
      (
        await f.owner.query(
          "SELECT count(*)::int AS n FROM app.credit_entries WHERE reason='purchase_applied'",
        )
      ).rows[0].n,
      0,
    );

    await c.query('BEGIN');
    await c.query(
      "UPDATE app.credit_holds SET state='captured',settled_at=clock_timestamp() WHERE purchase_id=$1",
      [purchase.id],
    );
    await c.query(
      "INSERT INTO app.credit_entries(user_id,reason,delta_pesewas,purchase_id) VALUES ($1,'purchase_applied',-1000,$2)",
      [f.actor.userId, purchase.id],
    );
    await c.query('COMMIT');
    assert.deepEqual(await f.service.balance(f.actor), { credit: 0, held: 0, available: 0 });
    assert.deepEqual(
      (
        await f.owner.query(
          'SELECT h.state,e.delta_pesewas FROM app.credit_holds h JOIN app.credit_entries e USING(purchase_id) WHERE h.purchase_id=$1',
          [purchase.id],
        )
      ).rows,
      [{ state: 'captured', delta_pesewas: -1000 }],
    );
  } finally {
    await c.query('ROLLBACK');
    c.release();
  }
});

test('FIN-15: rollback removes capture and debit together; release requires no debit', async (t) => {
  const f = await setup(t);
  await f.grant(1000);
  const purchase = await f.buy(),
    c = await f.runtime.connect();
  try {
    await c.query('BEGIN');
    await c.query(
      "UPDATE app.credit_holds SET state='captured',settled_at=clock_timestamp() WHERE purchase_id=$1",
      [purchase.id],
    );
    await assert.rejects(
      c.query(
        "INSERT INTO app.credit_entries(user_id,reason,delta_pesewas,purchase_id) VALUES ($1,'purchase_applied',-999,$2)",
        [f.actor.userId, purchase.id],
      ),
      (e) => (e as Error).message === 'credit_source_amount_mismatch',
    );
    await c.query('ROLLBACK');
    await c.query('BEGIN');
    await c.query(
      "UPDATE app.credit_holds SET state='captured',settled_at=clock_timestamp() WHERE purchase_id=$1",
      [purchase.id],
    );
    await c.query(
      "INSERT INTO app.credit_entries(user_id,reason,delta_pesewas,purchase_id) VALUES ($1,'purchase_applied',-1000,$2)",
      [f.actor.userId, purchase.id],
    );
    await c.query('SET CONSTRAINTS ALL IMMEDIATE');
    await c.query('ROLLBACK');
    assert.deepEqual(await f.service.balance(f.actor), { credit: 1000, held: 1000, available: 0 });
    assert.equal(
      (
        await f.owner.query(
          "SELECT count(*)::int AS n FROM app.credit_entries WHERE reason='purchase_applied'",
        )
      ).rows[0].n,
      0,
    );
    await c.query(
      "UPDATE app.credit_holds SET state='released',settled_at=clock_timestamp() WHERE purchase_id=$1",
      [purchase.id],
    );
    assert.deepEqual(await f.service.balance(f.actor), { credit: 1000, held: 0, available: 1000 });
  } finally {
    await c.query('ROLLBACK');
    c.release();
  }
});

test('FIN-16: real 010-to-011 upgrade preserves vehicles/history and grants narrow financial access', async (t) => {
  const f = await setup(t, {}, true);
  assert.equal(files.length, 11);
  assert.deepEqual(
    (await f.owner.query('SELECT name,sha256 FROM public._replacement_migrations ORDER BY name'))
      .rows,
    files.map(({ name, sha256 }) => ({ name, sha256 })),
  );
  await f.grant(1000);
  const p = await f.buy();
  assert.equal(await f.service.fulfill(f.settle(p)), 'fulfilled');
  await assert.rejects(
    f.runtime.query('UPDATE app.credit_entries SET delta_pesewas=delta_pesewas'),
    (e) => (e as { code: string }).code === '42501',
  );
});
