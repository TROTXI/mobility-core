import { after } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID, randomBytes } from 'node:crypto';
import { mkdir, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import pg from 'pg';
import { readMigrations, migrate, grantRuntime } from '../../src/db/migrate.js';
import { FinancialFoundation } from '../../src/payments/foundation.js';
import type {
  CheckoutInput,
  FinancialDependencies,
  Settlement,
} from '../../src/payments/foundation.js';
import { priceTerms } from '../../src/payments/terms.js';
import { TransportError } from '../../src/transport/errors.js';

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
export const files = await readMigrations(
  fileURLToPath(new URL('../../migrations/', import.meta.url)),
);
const run = randomBytes(5).toString('hex'),
  owned: string[] = [],
  roles: string[] = [],
  evidence: unknown[] = [];
let serial = 0;
after(async () => {
  // One database that refuses to drop must not strand every database after it
  // in the list. Failures are collected and reported once, at the end.
  const stranded: string[] = [];
  try {
    for (const name of owned)
      await admin
        .query(`DROP DATABASE "${name}"`)
        .catch((error) => stranded.push(`${name}: ${(error as Error).message}`));
    for (const role of roles)
      await admin
        .query(`DROP ROLE "${role}"`)
        .catch((error) => stranded.push(`${role}: ${(error as Error).message}`));
    if (process.env.REPLACEMENT_EVIDENCE_DIR) {
      await mkdir(process.env.REPLACEMENT_EVIDENCE_DIR, { recursive: true });
      await writeFile(
        resolve(process.env.REPLACEMENT_EVIDENCE_DIR, `financial-metadata-${run}.json`),
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
  if (stranded.length)
    throw new Error(`Test databases or roles were left behind: ${stranded.join('; ')}`);
});
export const at = new Date('2026-01-01T00:00:00Z'),
  renewAt = new Date('2026-02-02T00:00:00Z');
export async function setup(
  t: TestContext,
  overrides: Partial<FinancialDependencies> = {},
  upgrade = false,
  through = files.length,
) {
  const n = ++serial,
    name = `trotxi_harness_${run}_finance_${n}`,
    role = `trotxi_runtime_fin_${run}_${n}`;
  await admin.query(`CREATE DATABASE "${name}"`);
  owned.push(name);
  const db = new URL(url);
  db.pathname = '/' + name;
  const ownerUrl = db.href;
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
    assert.deepEqual(await migrate(owner, files.slice(0, 11)), ['011_payment_foundation.sql']);
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
    await migrate(owner, files);
    assert.deepEqual(await migrate(owner, files), []);
  } else await migrate(owner, files.slice(0, through));
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
    ownerUrl,
    runtimeUrl: db.href,
    adminId,
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
