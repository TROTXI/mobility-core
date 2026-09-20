import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { mkdir, readFile, readdir, writeFile } from 'node:fs/promises';
import { relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { setTimeout as delay } from 'node:timers/promises';
import pg from 'pg';
import { grantRuntime, migrate, migration, readMigrations } from '../src/db/migrate.js';

// Deliberately fail, never describe.skip: only a disposable loopback admin DB.
const value = process.env.HARNESS_ADMIN_DATABASE_URL;
if (!value || process.env.HARNESS_ALLOW_CREATE_DATABASES !== '1')
  throw new Error(
    'HARNESS_ADMIN_DATABASE_URL and HARNESS_ALLOW_CREATE_DATABASES=1 required; Postgres tests never skip',
  );
const url = new URL(value);
if (
  !['postgres:', 'postgresql:'].includes(url.protocol) ||
  !['127.0.0.1', 'localhost', '[::1]'].includes(url.hostname) ||
  url.pathname !== '/postgres' ||
  url.search ||
  url.hash
)
  throw new Error('Tests require an explicitly disposable loopback postgres admin database');
const admin = new pg.Pool({ connectionString: url.href, max: 2 });
const run = randomBytes(6).toString('hex');
const owned = new Set<string>();
const roles = new Set<string>();
const files = await readMigrations(fileURLToPath(new URL('../migrations/', import.meta.url)));
const root = fileURLToPath(new URL('../', import.meta.url));
const sha256 = (data: Buffer) => createHash('sha256').update(data).digest('hex');
async function inventory(dir: string): Promise<string[]> {
  const found: string[] = [];
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    if (['node_modules', 'dist'].includes(entry.name)) continue;
    const path = resolve(dir, entry.name);
    if (entry.isDirectory()) found.push(...(await inventory(path)));
    else if (entry.isFile()) found.push(path);
  }
  return found.sort();
}
async function sourceHashes() {
  const paths = [...(await inventory(root)), resolve(root, '../../pnpm-lock.yaml')].sort();
  return Promise.all(
    paths.map(async (path) => ({
      path: relative(resolve(root, '../..'), path),
      sha256: sha256(await readFile(path)),
    })),
  );
}
const source = await sourceHashes();
const evidence: { race: string; blockerPid: number; waiterPid: number }[] = [];
const cleanup: string[] = [];
let serial = 0;
async function database(): Promise<pg.Pool> {
  const name = `trotxi_harness_${run}_transport_${++serial}`;
  await admin.query(`CREATE DATABASE "${name}"`);
  owned.add(name);
  const db = new URL(url);
  db.pathname = `/${name}`;
  return new pg.Pool({ connectionString: db.href, max: 8 });
}
after(async () => {
  try {
    for (const name of owned) {
      await admin.query(`DROP DATABASE "${name}"`);
      cleanup.push(name);
    }
    for (const role of roles) {
      await admin.query(`DROP ROLE "${role}"`);
      cleanup.push(role);
    }
    assert.deepEqual(await sourceHashes(), source, 'candidate sources changed during the run');
  } finally {
    await admin.end();
    const output = process.env.REPLACEMENT_EVIDENCE_DIR;
    if (output) {
      await mkdir(output, { recursive: true });
      await writeFile(
        resolve(output, 'transport-metadata.json'),
        JSON.stringify(
          {
            kind: 'storage-integrity-not-payment-comparison',
            gitRevision: execFileSync('git', ['rev-parse', 'HEAD'], {
              cwd: root,
              encoding: 'utf8',
            }).trim(),
            source,
            migrations: files.map(({ name, sha256 }) => ({ name, sha256 })),
            evidence,
            cleanup,
            result:
              'See test report for pass/fail. Git revision alone does not assert a clean checkout.',
          },
          null,
          2,
        ) + '\n',
      );
    }
  }
});
async function withDb(work: (pool: pg.Pool) => Promise<void>) {
  const pool = await database();
  try {
    await migrate(pool, files);
    await work(pool);
  } finally {
    await pool.end();
  }
}
async function rejects(query: Promise<unknown>, code = '23514', message?: RegExp) {
  await assert.rejects(query, (error: unknown) => {
    assert.equal((error as { code: string }).code, code);
    if (message) assert.match((error as Error).message, message);
    return true;
  });
}
async function id(
  pool: pg.Pool | pg.PoolClient,
  sql: string,
  values: unknown[] = [],
): Promise<string> {
  return (await pool.query(sql + ' RETURNING id', values)).rows[0].id;
}

// Full replacement migration, never a reduced CREATE TABLE fixture. Raw SQL is
// intentional for category B/C checks: rejecting at HTTP is insufficient.
async function fixture(
  pool: pg.Pool,
  direction = 'outbound',
  existing?: { route: string; pattern: string; revision: number },
) {
  const user = await id(pool, "INSERT INTO app.users(role) VALUES ('driver')");
  const driver = await id(pool, "INSERT INTO app.drivers(user_id,name) VALUES ($1,'Test driver')", [
    user,
  ]);
  // MIG-05 deliberately stops the chain early, so this fixture runs against
  // schemas both before and after 010 added a required plate. Adapt to the
  // schema in front of it rather than relaxing the column or the chain check.
  const platedFleet = (
    await pool.query(
      "SELECT 1 FROM information_schema.columns WHERE table_schema='app' AND table_name='vehicles' AND column_name='plate'",
    )
  ).rowCount;
  const vehicle = await id(
    pool,
    platedFleet
      ? "INSERT INTO app.vehicles(plate,label,capacity) VALUES ('GT '||upper(substr(md5(random()::text),1,4))||'-20','Test bus', 16)"
      : "INSERT INTO app.vehicles(label,capacity) VALUES ('Test bus', 16)",
  );
  const route =
    existing?.route ?? (await id(pool, "INSERT INTO app.routes(name) VALUES ('Test corridor')"));
  const pattern =
    existing?.pattern ??
    (await id(pool, 'INSERT INTO app.route_patterns(route_id,direction) VALUES ($1,$2)', [
      route,
      direction,
    ]));
  const version = await id(
    pool,
    'INSERT INTO app.route_pattern_versions(pattern_id,revision) VALUES ($1,$2)',
    [pattern, existing?.revision ?? 1],
  );
  const stop = await id(
    pool,
    "INSERT INTO app.stops(name,latitude,longitude) VALUES ('Loop depot',5.6,-0.2)",
  );
  const occurrences: string[] = [];
  for (let ordinal = 0; ordinal < 3; ordinal++) {
    occurrences.push(
      await id(
        pool,
        `INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude)
      VALUES ($1,$2,$3,$4,5.6,-0.2)`,
        [version, stop, ordinal, `Visit ${ordinal}`],
      ),
    );
  }
  const geometry = await id(
    pool,
    `INSERT INTO app.route_geometries(pattern_version_id,source,line)
    VALUES ($1,'configured',ST_GeomFromText('LINESTRING(-0.2 5.6,-0.21 5.6,-0.2 5.6)',4326))`,
    [version],
  );
  for (const [ordinal, occurrence] of occurrences.entries())
    await pool.query('INSERT INTO app.geometry_stop_distances VALUES ($1,$2,$3,$4)', [
      geometry,
      version,
      occurrence,
      ordinal * 1000,
    ]);
  return { user, driver, vehicle, route, pattern, version, stop, occurrences, geometry };
}
type Fixture = Awaited<ReturnType<typeof fixture>>;
async function publish(pool: pg.Pool | pg.PoolClient, f: Fixture, from = '2026-01-01T00:00:00Z') {
  await pool.query("UPDATE app.route_geometries SET state='published' WHERE id=$1", [f.geometry]);
  await pool.query(
    "UPDATE app.route_pattern_versions SET state='published',geometry_id=$2,effective_from=$3 WHERE id=$1",
    [f.version, f.geometry, from],
  );
}
async function schedule(pool: pg.Pool, f: Fixture, departure?: string) {
  departure ??= await id(pool, 'INSERT INTO app.service_departures(pattern_id) VALUES ($1)', [
    f.pattern,
  ]);
  const schedule = await id(
    pool,
    `INSERT INTO app.service_schedules(pattern_version_id,service_window,local_departure,weekdays,effective_from,departure_id,pattern_id)
    VALUES ($1,'morning','06:30',ARRAY[1,2,3,4,5]::smallint[],'2026-01-01',$2,$3)`,
    [f.version, departure, f.pattern],
  );
  return { schedule, departure };
}
async function trip(pool: pg.Pool, f: Fixture) {
  const { schedule: scheduleId, departure } = await schedule(pool, f);
  const tripId = await id(
    pool,
    `INSERT INTO app.trips(schedule_id,pattern_version_id,scheduled_at,assigned_driver_id,vehicle_id,departure_id,service_date)
    VALUES ($1,$2,'2026-09-15 06:30Z',$3,$4,$5,'2026-09-15')`,
    [scheduleId, f.version, f.driver, f.vehicle, departure],
  );
  return { schedule: scheduleId, departure, tripId };
}

function createRun(
  pool: pg.Pool | pg.PoolClient,
  f: Fixture,
  s: { schedule: string; departure: string },
  serviceDate = '2026-09-15',
  scheduledAt = '2026-09-15T06:30:00Z',
  runNumber = 1,
) {
  return id(
    pool,
    `INSERT INTO app.trips(schedule_id,pattern_version_id,departure_id,
    service_date,scheduled_at,run_number) VALUES ($1,$2,$3,$4,$5,$6)`,
    [s.schedule, f.version, s.departure, serviceDate, scheduledAt, runNumber],
  );
}

async function duplicateRun(query: Promise<unknown>) {
  await assert.rejects(query, (error: unknown) => {
    const e = error as { code: string; constraint: string };
    assert.equal(e.code, '23505');
    assert.equal(e.constraint, 'trip_departure_occurrence');
    return true;
  });
}

test('MIG-01 clean install records hashes, rerun is no-op, historical drift fails', () =>
  withDb(async (pool) => {
    assert.deepEqual(await migrate(pool, files), []);
    assert.deepEqual(
      (await pool.query('SELECT name,sha256 FROM public._replacement_migrations ORDER BY name'))
        .rows,
      files.map(({ name, sha256 }) => ({ name, sha256 })),
    );
    const changed = files.map((f) => migration(f.name, f.sql + '\n-- changed'));
    await assert.rejects(migrate(pool, changed), /Applied replacement migration differs/);
    const tables = await pool.query(
      "SELECT count(*)::int AS n FROM pg_tables WHERE schemaname='app'",
    );
    // Seventeen transport/catalog + five auth + two driver command/audit tables,
    // plus driver_incidents, driver_requests and fleet_events from 010,
    // and ten financial foundation tables from 011 (asserted by name below).
    // 012 adds evidence, collections, refunds, disputes, access blocks,
    // reversals, reviews and review command receipts.
    // 013 adds selections/legs, slots/requests/assignments, pauses,
    // restrictions, reservations and membership receipts/events.
    // One durable ask-intent table makes notification delivery separately auditable.
    // 014 adds the trace and its live projection, learned speeds with the
    // samples and per-trip marker behind them, trace holds and gps receipts.
    // 015 adds boarding receipts, charges, attendance, QR uses and code budgets.
    // 016 adds plan pricing, corridor fares, the pricing command and event
    // receipts, and the provider checkout session behind a purchase.
    // 017 adds push devices, the erasure record and its outstanding tasks.
    // 017 adds push devices, the erasure record, its outstanding tasks and the
    // account command receipt. 018 adds minimum versions, feature flags and
    // the configuration receipts.
    // 022 adds the encrypted transactional email outbox.
    // 023–025 add push deliveries, refund initiation and personal pauses.
    assert.equal(tables.rows[0].n, 86);
    assert.deepEqual(
      (
        await pool.query(
          "SELECT tablename FROM pg_tables WHERE schemaname='app' AND tablename IN ('memberships','purchases','purchase_legs','payment_attempts','billing_periods','credit_adjustments','credit_holds','period_closures','ride_entries','credit_entries') ORDER BY tablename",
        )
      ).rows.map((r) => r.tablename),
      [
        'billing_periods',
        'credit_adjustments',
        'credit_entries',
        'credit_holds',
        'memberships',
        'payment_attempts',
        'period_closures',
        'purchase_legs',
        'purchases',
        'ride_entries',
      ],
    );
  }));

test('MIG-02 old/unknown database is refused without changing it', async () => {
  const pool = await database();
  try {
    await pool.query('CREATE TABLE public.payments (id integer)');
    await assert.rejects(migrate(pool, files), /already contains application objects/);
    assert.equal(
      (await pool.query("SELECT to_regclass('public._replacement_migrations') AS marker")).rows[0]
        .marker,
      null,
    );
    assert.equal((await pool.query('SELECT count(*)::int AS n FROM public.payments')).rows[0].n, 0);
  } finally {
    await pool.end();
  }
});

test('MIG-03 failed DDL rolls back its objects and migration record; retry works', () =>
  withDb(async (pool) => {
    const nextName = `${String(files.length + 1).padStart(3, '0')}_failure.sql`;
    const next = migration(nextName, 'CREATE TABLE app.failed_example(id integer); SELECT 1/0;');
    await rejects(migrate(pool, [...files, next]), '22012');
    assert.equal(
      (await pool.query("SELECT to_regclass('app.failed_example') AS t")).rows[0].t,
      null,
    );
    assert.equal(
      (await pool.query('SELECT count(*)::int AS n FROM public._replacement_migrations')).rows[0].n,
      files.length,
    );
    const fixed = migration(nextName, 'CREATE TABLE app.failed_example(id integer);');
    assert.deepEqual(await migrate(pool, [...files, fixed]), [nextName]);
    await assert.rejects(migrate(pool, files), /Applied replacement migration differs/);
  }));

test('MIG-04 concurrent installers wait on the same lock and install once', async () => {
  const pool = await database();
  const blocker = await pool.connect();
  let first: Promise<string[]> | undefined;
  let second: Promise<string[]> | undefined;
  try {
    await blocker.query(
      "SELECT pg_advisory_lock(hashtextextended('trotxi:replacement:migrations',0))",
    );
    const pid = (await blocker.query('SELECT pg_backend_pid() AS pid')).rows[0].pid;
    first = migrate(pool, files);
    second = migrate(pool, files);
    let waiting: { pid: number }[] = [];
    const deadline = Date.now() + 5000;
    while (Date.now() < deadline) {
      waiting = (
        await pool.query(
          `SELECT pid FROM pg_stat_activity
        WHERE datname=current_database() AND pid <> $1 AND $1=ANY(pg_blocking_pids(pid))`,
          [pid],
        )
      ).rows;
      if (waiting.length === 2) break;
      await delay(10);
    }
    assert.equal(new Set(waiting.map((r) => r.pid)).size, 2, 'both installers must contend');
    evidence.push(
      ...waiting.map((r) => ({ race: 'migration-install', blockerPid: pid, waiterPid: r.pid })),
    );
    await blocker.query(
      "SELECT pg_advisory_unlock(hashtextextended('trotxi:replacement:migrations',0))",
    );
    assert.deepEqual((await Promise.all([first, second])).map((r) => r.length).sort(), [
      0,
      files.length,
    ]);
  } finally {
    await blocker.query('SELECT pg_advisory_unlock_all()');
    await Promise.allSettled([first, second].filter((p): p is Promise<string[]> => !!p));
    blocker.release();
    await pool.end();
  }
});

test('MIG-05 departure migration preserves 001 and refuses ambiguous populated schedules without mutation', async () => {
  const foundation = files[0];
  assert.ok(foundation);
  assert.equal(
    foundation.sha256,
    'ebb63118163775f18e0295b8a1186476545a69bdf557f04ef54294d46a5437eb',
  );
  const pool = await database();
  try {
    await migrate(pool, files.slice(0, 1));
    const f = await fixture(pool);
    await publish(pool, f);
    const legacy = await id(
      pool,
      `INSERT INTO app.service_schedules(pattern_version_id,
      service_window,local_departure,weekdays,effective_from)
      VALUES ($1,'morning','06:30',ARRAY[1,2,3,4,5]::smallint[],'2026-01-01')`,
      [f.version],
    );
    const before = (await pool.query('SELECT * FROM app.service_schedules')).rows;
    await rejects(migrate(pool, files), '23514', /departure_identity_requires_empty_transport/);
    assert.deepEqual((await pool.query('SELECT * FROM app.service_schedules')).rows, before);
    assert.equal(before[0].id, legacy);
    assert.deepEqual(
      (await pool.query('SELECT name,sha256 FROM public._replacement_migrations ORDER BY name'))
        .rows,
      [{ name: foundation.name, sha256: foundation.sha256 }],
    );
    assert.equal(
      (await pool.query("SELECT to_regclass('app.service_departures') AS t")).rows[0].t,
      null,
    );
  } finally {
    await pool.end();
  }
});

test('DEP-01 identity rejects duplicate runs and launch run 2, not distinct departures or business dates', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await publish(pool, f);
    const s = await schedule(pool, f);
    const first = await createRun(pool, f, s);
    await duplicateRun(createRun(pool, f, s));
    await rejects(
      createRun(pool, f, s, '2026-09-15', '2026-09-15T06:30:00Z', 2),
      '23514',
      /one_bus_per_departure_at_launch/,
    );
    const tomorrow = await createRun(pool, f, s, '2026-09-16', '2026-09-16T06:30:00Z');
    const another = await createRun(pool, f, await schedule(pool, f));
    const rows = (
      await pool.query(`SELECT id,departure_id,service_date::text,run_number
      FROM app.trips ORDER BY service_date,id`)
    ).rows;
    assert.equal(rows.length, 3);
    assert.equal(new Set([first, tomorrow, another]).size, 3);
    assert.deepEqual(
      rows.find((row) => row.id === first),
      {
        id: first,
        departure_id: s.departure,
        service_date: '2026-09-15',
        run_number: 1,
      },
    );
  }));

test('DEP-02 rescheduling cannot free the original departure identity for a generator retry', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await publish(pool, f);
    const t = await trip(pool, f);
    await pool.query("UPDATE app.trips SET scheduled_at='2026-09-15 07:00Z' WHERE id=$1", [
      t.tripId,
    ]);
    await duplicateRun(createRun(pool, f, t));
    assert.deepEqual(
      (
        await pool.query(`SELECT id,departure_id,service_date::text,run_number,scheduled_at
      FROM app.trips`)
      ).rows,
      [
        {
          id: t.tripId,
          departure_id: t.departure,
          service_date: '2026-09-15',
          run_number: 1,
          scheduled_at: new Date('2026-09-15T07:00:00Z'),
        },
      ],
    );
  }));

test('DEP-03 midnight delay retains the stored business date and refuses edits to identity', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await publish(pool, f);
    const s = await schedule(pool, f);
    const tripId = await createRun(pool, f, s, '2026-09-15', '2026-09-15T23:30:00Z');
    await pool.query("UPDATE app.trips SET scheduled_at='2026-09-16 00:15Z' WHERE id=$1", [tripId]);
    await rejects(
      pool.query("UPDATE app.trips SET service_date='2026-09-16' WHERE id=$1", [tripId]),
      '23514',
      /immutable_departure_occurrence/,
    );
    await rejects(
      pool.query('UPDATE app.trips SET run_number=2 WHERE id=$1', [tripId]),
      '23514',
      /immutable_departure_occurrence/,
    );
    const other = await schedule(pool, f);
    await rejects(
      pool.query('UPDATE app.trips SET departure_id=$2 WHERE id=$1', [tripId, other.departure]),
      '23514',
      /immutable_departure_occurrence/,
    );
    await duplicateRun(createRun(pool, f, s, '2026-09-15', '2026-09-16T00:15:00Z'));
    assert.deepEqual(
      (
        await pool.query(`SELECT id,service_date::text,
      (scheduled_at AT TIME ZONE 'Africa/Accra')::date::text AS operational_date FROM app.trips`)
      ).rows,
      [{ id: tripId, service_date: '2026-09-15', operational_date: '2026-09-16' }],
    );
    // Insertion after a delay was already known must not derive the date either.
    await createRun(pool, f, other, '2026-09-15', '2026-09-16T00:15:00Z');
  }));

test('DEP-04 cancellation retains identity and cannot be resurrected by regeneration', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await publish(pool, f);
    const t = await trip(pool, f);
    await pool.query("UPDATE app.trips SET status='cancelled' WHERE id=$1", [t.tripId]);
    await duplicateRun(createRun(pool, f, t));
    await rejects(
      pool.query("UPDATE app.trips SET status='scheduled' WHERE id=$1", [t.tripId]),
      '23514',
      /immutable_terminal_trip/,
    );
    assert.deepEqual((await pool.query('SELECT id,status FROM app.trips')).rows, [
      { id: t.tripId, status: 'cancelled' },
    ]);
  }));

test('DEP-05 concurrent generators actually contend and persist exactly one departure occurrence', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await publish(pool, f);
    const s = await schedule(pool, f);
    const first = await pool.connect();
    const second = await pool.connect();
    let pending: Promise<void> | undefined;
    try {
      await first.query('BEGIN');
      const tripId = await createRun(first, f, s);
      const firstPid = (await first.query('SELECT pg_backend_pid() AS pid')).rows[0].pid;
      const secondPid = (await second.query('SELECT pg_backend_pid() AS pid')).rows[0].pid;
      assert.notEqual(firstPid, secondPid);
      pending = duplicateRun(createRun(second, f, s));
      let contended = false;
      const deadline = Date.now() + 5000;
      while (Date.now() < deadline) {
        if (
          (
            await pool.query('SELECT $1 = ANY(pg_blocking_pids($2)) AS blocked', [
              firstPid,
              secondPid,
            ])
          ).rows[0].blocked
        ) {
          contended = true;
          break;
        }
        await delay(10);
      }
      assert.equal(contended, true, 'generator connections must demonstrably contend');
      evidence.push({ race: 'departure-generation', blockerPid: firstPid, waiterPid: secondPid });
      await first.query('COMMIT');
      await pending;
      assert.deepEqual((await pool.query('SELECT id,departure_id FROM app.trips')).rows, [
        { id: tripId, departure_id: s.departure },
      ]);
    } finally {
      await first.query('ROLLBACK');
      // Drain before releasing clients even when an assertion failed.
      if (pending) await Promise.allSettled([pending]);
      first.release();
      second.release();
    }
  }));

test('DEP-06 a new published pattern revision cannot duplicate an existing departure on its business date', () =>
  withDb(async (pool) => {
    const a = await fixture(pool);
    await publish(pool, a);
    const t = await trip(pool, a);
    const b = await fixture(pool, 'outbound', { route: a.route, pattern: a.pattern, revision: 2 });
    // Both operational timestamps below are eligible for their respective
    // revisions. The rejection must be identity, not unavailable version.
    await pool.query(
      "UPDATE app.route_pattern_versions SET state='retired',effective_to='2026-09-15 12:00Z' WHERE id=$1",
      [a.version],
    );
    await publish(pool, b, '2026-09-15T12:00:00Z');
    const revised = await schedule(pool, b, t.departure);
    assert.notEqual(revised.schedule, t.schedule);
    await duplicateRun(createRun(pool, b, revised, '2026-09-15', '2026-09-15T15:30:00Z'));
    const next = await createRun(pool, b, revised, '2026-09-16', '2026-09-16T06:30:00Z');
    assert.deepEqual(
      (
        await pool.query(`SELECT id,schedule_id,pattern_version_id,departure_id,service_date::text
      FROM app.trips ORDER BY service_date`)
      ).rows,
      [
        {
          id: t.tripId,
          schedule_id: t.schedule,
          pattern_version_id: a.version,
          departure_id: t.departure,
          service_date: '2026-09-15',
        },
        {
          id: next,
          schedule_id: revised.schedule,
          pattern_version_id: b.version,
          departure_id: t.departure,
          service_date: '2026-09-16',
        },
      ],
    );
  }));

test('DEP-07 composite ownership rejects cross-pattern schedules and cross-departure trips', () =>
  withDb(async (pool) => {
    const a = await fixture(pool);
    const b = await fixture(pool);
    await publish(pool, a);
    await publish(pool, b);
    const s = await schedule(pool, a);
    await rejects(schedule(pool, b, s.departure), '23503', /schedule_departure_owner/);
    await rejects(
      pool.query(
        `INSERT INTO app.service_schedules(pattern_version_id,pattern_id,departure_id,
      service_window,local_departure,weekdays,effective_from)
      VALUES ($1,$2,$3,'morning','06:30',ARRAY[1,2,3,4,5]::smallint[],'2026-01-01')`,
        [b.version, a.pattern, s.departure],
      ),
      '23503',
      /schedule_pattern_version_owner/,
    );
    const other = await schedule(pool, a);
    await rejects(
      createRun(pool, a, { schedule: s.schedule, departure: other.departure }),
      '23503',
      /trip_schedule_departure_owner/,
    );
    await rejects(
      pool.query('UPDATE app.service_departures SET pattern_id=$2 WHERE id=$1', [
        s.departure,
        b.pattern,
      ]),
    );
    assert.equal((await pool.query('SELECT count(*)::int AS n FROM app.trips')).rows[0].n, 0);
  }));

test('DEP-08 schedule operating days apply to business date, while operational version eligibility still applies', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await publish(pool, f);
    const s = await schedule(pool, f);
    await rejects(
      createRun(pool, f, s, '2026-09-19', '2026-09-18T23:30:00Z'),
      '23514',
      /service_date_not_in_schedule/,
    );
    await rejects(createRun(pool, f, s, '2025-12-31'), '23514', /service_date_not_in_schedule/);
    const tripId = await createRun(pool, f, s, '2026-09-18', '2026-09-19T00:15:00Z');
    await pool.query(
      "UPDATE app.route_pattern_versions SET state='retired',effective_to='2026-10-01' WHERE id=$1",
      [f.version],
    );
    await rejects(
      pool.query("UPDATE app.trips SET scheduled_at='2026-10-01 00:15Z' WHERE id=$1", [tripId]),
      '23514',
      /unavailable_pattern_version/,
    );
    assert.deepEqual(
      (await pool.query('SELECT service_date::text,scheduled_at FROM app.trips')).rows,
      [{ service_date: '2026-09-18', scheduled_at: new Date('2026-09-19T00:15:00Z') }],
    );
  }));

test('DEP-09 direct schedule repointing is rejected even within the same departure and pattern version', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await publish(pool, f);
    const original = await schedule(pool, f);
    const tripId = await createRun(pool, f, original, '2026-09-14', '2026-09-14T06:30:00Z');
    const before = (await pool.query('SELECT * FROM app.trips WHERE id=$1', [tripId])).rows;
    // A Monday run, with targets that all satisfy the composite ownership FK.
    // Include a date-compatible revision: this is a reassignment guard, not a
    // policy that silently allows changing schedules when weekdays happen to fit.
    const revisions = [
      { label: 'Tuesday only', weekdays: [2], from: '2026-01-01', to: null },
      { label: 'not yet effective', weekdays: [1], from: '2026-09-15', to: null },
      { label: 'no longer effective', weekdays: [1], from: '2026-01-01', to: '2026-09-13' },
      { label: 'date-compatible revision', weekdays: [1], from: '2026-01-01', to: null },
    ];
    for (const revision of revisions) {
      const target = await id(
        pool,
        `INSERT INTO app.service_schedules
        (pattern_version_id,pattern_id,departure_id,service_window,local_departure,weekdays,effective_from,effective_to)
        VALUES ($1,$2,$3,'morning','07:00',$4,$5,$6)`,
        [f.version, f.pattern, original.departure, revision.weekdays, revision.from, revision.to],
      );
      assert.deepEqual(
        (
          await pool.query(
            `SELECT pattern_version_id,departure_id
        FROM app.service_schedules WHERE id=$1`,
            [target],
          )
        ).rows,
        [{ pattern_version_id: f.version, departure_id: original.departure }],
        revision.label,
      );
      await rejects(
        pool.query('UPDATE app.trips SET schedule_id=$2 WHERE id=$1', [tripId, target]),
        '23514',
        /^explicit_reassignment_required$/,
      );
      // Prove no partial write, including version/updated_at, for every target.
      assert.deepEqual(
        (await pool.query('SELECT * FROM app.trips WHERE id=$1', [tripId])).rows,
        before,
        revision.label,
      );
    }
  }));

test('DEP-10 ISO weekdays are documented in the catalog and Sunday is 7, never JavaScript 0', () =>
  withDb(async (pool) => {
    const description = (
      await pool.query(`SELECT col_description(attrelid,attnum) AS value
      FROM pg_attribute WHERE attrelid='app.service_schedules'::regclass AND attname='weekdays'`)
    ).rows[0].value;
    assert.equal(
      description,
      'ISO weekdays: 1 = Monday, 2 = Tuesday, 3 = Wednesday, 4 = Thursday, 5 = Friday, 6 = Saturday, 7 = Sunday. Not JavaScript getDay() (0 = Sunday). Evaluated against stored service_date, not date(scheduled_at).',
    );
    const f = await fixture(pool);
    await publish(pool, f);
    const original = await schedule(pool, f);
    const sunday = await id(
      pool,
      `INSERT INTO app.service_schedules
      (pattern_version_id,pattern_id,departure_id,service_window,local_departure,weekdays,effective_from)
      VALUES ($1,$2,$3,'morning','06:30',ARRAY[7]::smallint[],'2026-01-01')`,
      [f.version, f.pattern, original.departure],
    );
    const selected = { schedule: sunday, departure: original.departure };
    const tripId = await createRun(pool, f, selected, '2026-09-20', '2026-09-20T06:30:00Z');
    await rejects(
      createRun(pool, f, selected, '2026-09-21', '2026-09-21T06:30:00Z'),
      '23514',
      /^service_date_not_in_schedule$/,
    );
    assert.equal(
      (await pool.query('SELECT app.valid_weekdays(ARRAY[0]::smallint[]) AS valid')).rows[0].valid,
      false,
    );
    assert.deepEqual((await pool.query('SELECT id,service_date::text FROM app.trips')).rows, [
      { id: tripId, service_date: '2026-09-20' },
    ]);
  }));

test('ID target: linked driver is unique while multiple unlinked drivers are allowed', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await rejects(
      pool.query("INSERT INTO app.drivers(user_id,name) VALUES ($1,'Duplicate')", [f.user]),
      '23505',
    );
    await pool.query("INSERT INTO app.drivers(name) VALUES ('Unlinked A'),('Unlinked B')");
    await rejects(pool.query('DELETE FROM app.users WHERE id=$1', [f.user]), '23503');
  }));

test('VER-01 zero-based repeated physical stops retain distinct immutable occurrence IDs', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await publish(pool, f);
    await pool.query("UPDATE app.stops SET name='Renamed depot',latitude=5.7 WHERE id=$1", [
      f.stop,
    ]);
    const rows = await pool.query(
      'SELECT id,name,latitude,ordinal FROM app.route_pattern_stops WHERE pattern_version_id=$1 ORDER BY ordinal',
      [f.version],
    );
    assert.equal(new Set(rows.rows.map((r) => r.id)).size, 3);
    assert.deepEqual(
      rows.rows.map(({ name, latitude, ordinal }) => ({ name, latitude, ordinal })),
      [0, 1, 2].map((ordinal) => ({ name: `Visit ${ordinal}`, latitude: 5.6, ordinal })),
    );
    await rejects(
      pool.query("UPDATE app.route_pattern_stops SET name='Wrong' WHERE id=$1", [f.occurrences[0]]),
    );
    await rejects(
      pool.query('DELETE FROM app.route_pattern_stops WHERE id=$1', [f.occurrences[0]]),
    );
    await rejects(
      pool.query(
        `INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude)
    VALUES ($1,$2,3,'Extra',5.6,-0.2)`,
        [f.version, f.stop],
      ),
    );
    await rejects(
      pool.query(
        "UPDATE app.route_pattern_versions SET state='draft',effective_from=NULL WHERE id=$1",
        [f.version],
      ),
    );
  }));

test('VER-01 incomplete version or geometry cannot be published', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await rejects(
      pool.query(
        "UPDATE app.route_pattern_versions SET state='published',effective_from='2026-01-01' WHERE id=$1",
        [f.version],
      ),
      '23514',
      /incomplete/,
    );
    await pool.query(
      'DELETE FROM app.geometry_stop_distances WHERE geometry_id=$1 AND stop_occurrence_id=$2',
      [f.geometry, f.occurrences[2]],
    );
    await rejects(
      pool.query("UPDATE app.route_geometries SET state='published' WHERE id=$1", [f.geometry]),
      '23514',
      /incomplete/,
    );
    assert.equal(
      (await pool.query('SELECT state FROM app.route_geometries WHERE id=$1', [f.geometry])).rows[0]
        .state,
      'draft',
    );
    await pool.query('INSERT INTO app.geometry_stop_distances VALUES ($1,$2,$3,2000)', [
      f.geometry,
      f.version,
      f.occurrences[2],
    ]);
    await pool.query('UPDATE app.route_pattern_stops SET ordinal=4 WHERE id=$1', [
      f.occurrences[2],
    ]);
    await rejects(publish(pool, f), '23514', /incomplete_published_version/);
  }));

test('VER-01 geometry and distance ownership reject cross-version links directly', () =>
  withDb(async (pool) => {
    const a = await fixture(pool);
    const b = await fixture(pool, 'return');
    await rejects(
      pool.query('UPDATE app.route_pattern_versions SET geometry_id=$2 WHERE id=$1', [
        a.version,
        b.geometry,
      ]),
      '23503',
    );
    await rejects(
      pool.query('INSERT INTO app.geometry_stop_distances VALUES ($1,$2,$3,0)', [
        a.geometry,
        a.version,
        b.occurrences[0],
      ]),
      '23503',
    );
    await publish(pool, a);
    await rejects(
      pool.query(
        "UPDATE app.route_geometries SET line=ST_GeomFromText('LINESTRING(0 0,1 1)',4326) WHERE id=$1",
        [a.geometry],
      ),
    );
    await rejects(
      pool.query('UPDATE app.geometry_stop_distances SET distance_meters=99 WHERE geometry_id=$1', [
        a.geometry,
      ]),
    );
  }));

test('VER-01 geometry distances are complete, finite, ordered and on the line', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await pool.query(
      'UPDATE app.geometry_stop_distances SET distance_meters=3000 WHERE stop_occurrence_id=$1',
      [f.occurrences[1]],
    );
    await rejects(
      pool.query("UPDATE app.route_geometries SET state='published' WHERE id=$1", [f.geometry]),
    );
    await rejects(
      pool.query(
        "UPDATE app.geometry_stop_distances SET distance_meters='NaN' WHERE stop_occurrence_id=$1",
        [f.occurrences[1]],
      ),
    );
  }));

test('VER-01 published intervals cannot overlap and cannot orphan an existing trip', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await publish(pool, f);
    await trip(pool, f);
    await rejects(
      pool.query(
        "UPDATE app.route_pattern_versions SET state='retired',effective_to='2026-08-01' WHERE id=$1",
        [f.version],
      ),
      '23514',
      /reassignment_required/,
    );
    const other = await id(
      pool,
      'INSERT INTO app.route_pattern_versions(pattern_id,revision) VALUES ($1,2)',
      [f.pattern],
    );
    // An immediate exclusion check isolates the overlap constraint from completeness.
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      await client.query('SET CONSTRAINTS ALL IMMEDIATE');
      await rejects(
        client.query(
          "UPDATE app.route_pattern_versions SET state='published',effective_from='2026-02-01' WHERE id=$1",
          [other],
        ),
        '23P01',
      );
      await client.query('ROLLBACK');
    } finally {
      client.release();
    }
  }));

test('VER-02 changing departure across noon cannot change direction or service window', () =>
  withDb(async (pool) => {
    const f = await fixture(pool, 'return');
    await publish(pool, f);
    const t = await trip(pool, f);
    await pool.query("UPDATE app.trips SET scheduled_at='2026-09-15 15:30Z' WHERE id=$1", [
      t.tripId,
    ]);
    const row = (
      await pool.query(
        `SELECT p.direction,s.service_window FROM app.trips t
    JOIN app.service_schedules s ON s.id=t.schedule_id JOIN app.route_pattern_versions v ON v.id=t.pattern_version_id
    JOIN app.route_patterns p ON p.id=v.pattern_id WHERE t.id=$1`,
        [t.tripId],
      )
    ).rows[0];
    assert.deepEqual(row, { direction: 'return', service_window: 'morning' });
    await rejects(
      pool.query("UPDATE app.route_patterns SET direction='outbound' WHERE id=$1", [f.pattern]),
    );
  }));

test('VER-01 trip schedule and current occurrence must belong to its exact version', () =>
  withDb(async (pool) => {
    const a = await fixture(pool);
    const b = await fixture(pool);
    await publish(pool, a);
    await publish(pool, b);
    const t = await trip(pool, a);
    const u = await trip(pool, b);
    await rejects(
      pool.query(
        `INSERT INTO app.trips(schedule_id,pattern_version_id,scheduled_at,departure_id,service_date)
    VALUES ($1,$2,'2026-09-16 06:30Z',$3,'2026-09-16')`,
        [u.schedule, a.version, u.departure],
      ),
      '23503',
    );
    await pool.query(
      "UPDATE app.trips SET status='active',started_at='2026-09-15 06:30Z' WHERE id=$1",
      [t.tripId],
    );
    await rejects(
      pool.query('UPDATE app.trips SET current_stop_occurrence_id=$2 WHERE id=$1', [
        t.tripId,
        b.occurrences[0],
      ]),
      '23503',
    );
    await pool.query('UPDATE app.trips SET current_stop_occurrence_id=$2 WHERE id=$1', [
      t.tripId,
      a.occurrences[0],
    ]);
    assert.equal(
      (await pool.query('SELECT current_stop_occurrence_id FROM app.trips WHERE id=$1', [t.tripId]))
        .rows[0].current_stop_occurrence_id,
      a.occurrences[0],
    );
  }));

test('TRP-01 storage permits valid transitions and refuses timestamp holes and rewrites', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await publish(pool, f);
    const t = await trip(pool, f);
    await rejects(
      pool.query(
        "UPDATE app.trips SET status='completed',started_at=now(),completed_at=now() WHERE id=$1",
        [t.tripId],
      ),
    );
    await pool.query(
      "UPDATE app.trips SET status='active',started_at='2026-09-15 06:30Z' WHERE id=$1",
      [t.tripId],
    );
    await rejects(
      pool.query("UPDATE app.trips SET scheduled_at='2026-09-15 08:00Z' WHERE id=$1", [t.tripId]),
    );
    await rejects(
      pool.query('UPDATE app.trips SET assigned_driver_id=NULL WHERE id=$1', [t.tripId]),
    );
    await rejects(
      pool.query("UPDATE app.trips SET status='completed',completed_at=NULL WHERE id=$1", [
        t.tripId,
      ]),
    );
    await pool.query(
      "UPDATE app.trips SET status='completed',completed_at='2026-09-15 07:30Z' WHERE id=$1",
      [t.tripId],
    );
    await rejects(
      pool.query("UPDATE app.trips SET status='active',completed_at=NULL WHERE id=$1", [t.tripId]),
    );
    const row = (
      await pool.query(
        'SELECT status,version,completed_at-started_at AS duration FROM app.trips WHERE id=$1',
        [t.tripId],
      )
    ).rows[0];
    assert.equal(row.status, 'completed');
    assert.equal(row.version, 3);
    assert.equal(row.duration.hours, 1);
  }));

test('VER-01 archival blocks new choices while operated history remains readable', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await publish(pool, f);
    const t = await trip(pool, f);
    await pool.query("UPDATE app.trips SET status='active',started_at=now() WHERE id=$1", [
      t.tripId,
    ]);
    await pool.query('UPDATE app.routes SET archived_at=now() WHERE id=$1', [f.route]);
    await rejects(trip(pool, f));
    await pool.query("UPDATE app.trips SET status='completed',completed_at=now() WHERE id=$1", [
      t.tripId,
    ]);
    await rejects(pool.query('DELETE FROM app.routes WHERE id=$1', [f.route]), '23503');
    await rejects(
      pool.query('DELETE FROM app.route_pattern_versions WHERE id=$1', [f.version]),
      '23503',
    );
    await rejects(pool.query('DELETE FROM app.trips WHERE id=$1', [t.tripId]), '23514');
    assert.equal(
      (await pool.query('SELECT status FROM app.trips WHERE id=$1', [t.tripId])).rows[0].status,
      'completed',
    );
  }));

test('storage rejects invalid weekdays and unversioned mutable schedules', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await publish(pool, f);
    const t = await trip(pool, f);
    await rejects(
      pool.query(
        `INSERT INTO app.service_schedules(pattern_version_id,service_window,local_departure,weekdays,effective_from,departure_id,pattern_id)
    VALUES ($1,'morning','06:30',ARRAY[1,1]::smallint[],'2026-01-01',$2,$3)`,
        [f.version, t.departure, f.pattern],
      ),
    );
    await rejects(
      pool.query("UPDATE app.service_schedules SET local_departure='15:00' WHERE id=$1", [
        t.schedule,
      ]),
    );
  }));

test('runtime role cannot mutate event history, delete/truncate tables or install DDL', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    await publish(pool, f);
    const t = await trip(pool, f);
    const role = `trotxi_runtime_${run}`;
    await admin.query(`CREATE ROLE "${role}" NOLOGIN`);
    roles.add(role);
    await grantRuntime(pool, role);
    const client = await pool.connect();
    try {
      await client.query(`SET ROLE "${role}"`);
      await client.query(
        // Runtime fixtures now obey the same receipt requirement as commands;
        // do not switch this insert to the owner and weaken the privilege test.
        `WITH receipt AS (
          INSERT INTO app.transport_commands
            (id,actor_user_id,operation,target,key_hash,input_hash,response_status,response_body,response_headers,replay_expires_at)
          VALUES (gen_random_uuid(),$2,'startTrip',$1::text,repeat('a',64),repeat('b',64),200,'{}','{}',clock_timestamp()+interval '7 days')
          RETURNING id
        ) INSERT INTO app.trip_events(trip_id,actor_user_id,command_id,operation,before_state,after_state)
        SELECT $1::uuid,$2,receipt.id,'start','{}','{}' FROM receipt`,
        [t.tripId, f.user],
      );
      await rejects(client.query("UPDATE app.trip_events SET reason='tamper'"), '42501');
      await rejects(client.query('DELETE FROM app.trips'), '42501');
      await rejects(client.query('TRUNCATE app.trips CASCADE'), '42501');
      await rejects(client.query('CREATE TABLE app.evil(id integer)'), '42501');
      await rejects(client.query('CREATE SCHEMA evil'), '42501');
      await rejects(client.query('SELECT * FROM public._replacement_migrations'), '42501');
      await rejects(client.query('ALTER TABLE app.trips DISABLE TRIGGER ALL'), '42501');
    } finally {
      await client.query('RESET ROLE');
      client.release();
    }
    await rejects(pool.query("UPDATE app.trip_events SET reason='owner-tamper'"));
    await assert.rejects(grantRuntime(pool, 'postgres'));
    await admin.query(`GRANT pg_write_all_data TO "${role}"`);
    await assert.rejects(grantRuntime(pool, role), /independent/);
    await admin.query(`REVOKE pg_write_all_data FROM "${role}"`);
  }));

test('VER-01 attribution negative control is detected at the persisted occurrence/version boundary', () =>
  withDb(async (pool) => {
    const a = await fixture(pool);
    const b = await fixture(pool);
    await publish(pool, a);
    await publish(pool, b);
    const t = await trip(pool, a);
    await pool.query(
      "UPDATE app.trips SET status='active',started_at=now(),current_stop_occurrence_id=$2 WHERE id=$1",
      [t.tripId, a.occurrences[0]],
    );
    async function observe() {
      return (
        await pool.query(
          `SELECT t.pattern_version_id AS trip_version,s.pattern_version_id AS stop_version
      FROM app.trips t JOIN app.route_pattern_stops s ON s.id=t.current_stop_occurrence_id WHERE t.id=$1`,
          [t.tripId],
        )
      ).rows[0];
    }
    const good = await observe();
    assert.equal(good.stop_version, good.trip_version, 'trip.currentStopVersion');
    // A mutation in this run-owned disposable database only. Remove just the FK
    // so the observer must catch a real persisted cross-version attribution bug.
    const constraint = (
      await pool.query(`SELECT conname FROM pg_constraint
    WHERE conrelid='app.trips'::regclass AND confrelid='app.route_pattern_stops'::regclass`)
    ).rows[0].conname;
    assert.match(constraint, /^[a-z0-9_]+$/);
    await pool.query(`ALTER TABLE app.trips DROP CONSTRAINT "${constraint}"`);
    await pool.query('UPDATE app.trips SET current_stop_occurrence_id=$2 WHERE id=$1', [
      t.tripId,
      b.occurrences[0],
    ]);
    const bad = await observe();
    assert.throws(
      () => assert.equal(bad.stop_version, bad.trip_version, 'trip.currentStopVersion'),
      (error: unknown) => {
        assert.ok(error instanceof assert.AssertionError);
        assert.match(error.message, /trip\.currentStopVersion/);
        assert.equal(error.actual, b.version);
        assert.equal(error.expected, a.version);
        return true;
      },
    );
  }));

test('VER-01 publication and stop edits actually contend; blocked edit cannot rewrite published history', () =>
  withDb(async (pool) => {
    const f = await fixture(pool);
    const publisher = await pool.connect();
    const editor = await pool.connect();
    let edit: Promise<unknown> | undefined;
    try {
      await publisher.query('BEGIN');
      await publish(publisher, f);
      const publisherPid = (await publisher.query('SELECT pg_backend_pid() AS pid')).rows[0].pid;
      const editorPid = (await editor.query('SELECT pg_backend_pid() AS pid')).rows[0].pid;
      assert.notEqual(publisherPid, editorPid);
      edit = rejects(
        editor.query("UPDATE app.route_pattern_stops SET name='Racing edit' WHERE id=$1", [
          f.occurrences[0],
        ]),
        '23514',
        /immutable_published_stops/,
      );
      let contended = false;
      const deadline = Date.now() + 5000;
      while (Date.now() < deadline) {
        const lock = await pool.query('SELECT $1 = ANY(pg_blocking_pids($2)) AS blocked', [
          publisherPid,
          editorPid,
        ]);
        if (lock.rows[0].blocked) {
          contended = true;
          break;
        }
        await delay(10);
      }
      assert.equal(
        contended,
        true,
        'expected two distinct connections blocked on the publication lock',
      );
      evidence.push({
        race: 'publication-stop-edit',
        blockerPid: publisherPid,
        waiterPid: editorPid,
      });
      await publisher.query('COMMIT');
      await edit;
      assert.equal(
        (
          await pool.query('SELECT name FROM app.route_pattern_stops WHERE id=$1', [
            f.occurrences[0],
          ])
        ).rows[0].name,
        'Visit 0',
      );
    } finally {
      await publisher.query('ROLLBACK');
      if (edit) await edit;
      publisher.release();
      editor.release();
    }
  }));
