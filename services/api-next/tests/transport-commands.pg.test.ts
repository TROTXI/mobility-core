import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes, randomUUID } from 'node:crypto';
import { mkdir, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import pg from 'pg';
import { createTransportApp } from '../src/http/app.js';
import { TransportError } from '../src/transport/errors.js';
import { TransportService } from '../src/transport/service.js';
import type { Body, Command } from '../src/transport/service.js';
import { grantRuntime, migrate, readMigrations } from '../src/db/migrate.js';

const value = process.env.HARNESS_ADMIN_DATABASE_URL;
if (!value || process.env.HARNESS_ALLOW_CREATE_DATABASES !== '1')
  throw new Error('Disposable PostgreSQL configuration required; command tests never skip');
const url = new URL(value);
if (
  !['postgres:', 'postgresql:'].includes(url.protocol) ||
  !['127.0.0.1', 'localhost', '[::1]'].includes(url.hostname) ||
  url.pathname !== '/postgres' ||
  url.search ||
  url.hash
)
  throw new Error('Only an explicitly disposable loopback postgres admin database is allowed');
const admin = new pg.Pool({ connectionString: url.href, max: 2, connectionTimeoutMillis: 3000 });
const migrations = await readMigrations(fileURLToPath(new URL('../migrations/', import.meta.url)));
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
        resolve(process.env.REPLACEMENT_EVIDENCE_DIR, 'command-metadata.json'),
        JSON.stringify(
          {
            kind: 'transport-command-http-postgres-not-payment-comparison',
            identityBoundary:
              'Verified opaque test credentials plus a real test-session row; NOT production signature/session implementation.',
            bookingBoundary:
              'Only an explicit test transaction coordinator is exercised. No production reservation implementation claimed.',
            migrations: migrations.map((m) => ({ name: m.name, sha256: m.sha256 })),
            evidence,
            cleanedDatabases: owned,
            cleanedRoles: roles,
          },
          null,
          2,
        ) + '\n',
      );
    }
  } finally {
    await admin.end();
  }
});
async function id(pool: pg.Pool, sql: string, values: unknown[] = []): Promise<string> {
  return (await pool.query(`${sql} RETURNING id`, values)).rows[0].id;
}
async function setup(coordinated = false, budget = 1000) {
  const n = ++serial,
    name = `trotxi_harness_${run}_commands_${n}`,
    role = `trotxi_runtime_cmd_${run}_${n}`;
  await admin.query(`CREATE DATABASE "${name}"`);
  owned.push(name);
  const db = new URL(url);
  db.pathname = `/${name}`;
  const owner = new pg.Pool({ connectionString: db.href, max: 4, connectionTimeoutMillis: 3000 });
  let runtime: pg.Pool | undefined;
  try {
    await migrate(owner, migrations);
    // Explicit test adapters, not reduced substitutes for transport tables.
    await owner.query(
      'CREATE TABLE app.test_sessions(user_id uuid,session_id text PRIMARY KEY,active boolean NOT NULL)',
    );
    await owner.query('CREATE TABLE app.test_booking_effects(trip_id uuid,operation text)');
    const users = {} as Record<'admin' | 'otherAdmin' | 'driver' | 'other' | 'rider', string>;
    for (const label of ['admin', 'otherAdmin', 'driver', 'other', 'rider'] as const) {
      users[label] = await id(owner, 'INSERT INTO app.users(role) VALUES ($1)', [
        label === 'rider'
          ? 'commuter'
          : label === 'admin' || label === 'otherAdmin'
            ? 'admin'
            : 'driver',
      ]);
      await owner.query('INSERT INTO app.test_sessions VALUES ($1,$2,true)', [
        users[label],
        `session-${label}`,
      ]);
    }
    const driver = await id(owner, "INSERT INTO app.drivers(user_id,name) VALUES ($1,'Driver A')", [
      users.driver,
    ]);
    const otherDriver = await id(
      owner,
      "INSERT INTO app.drivers(user_id,name) VALUES ($1,'Driver B')",
      [users.other],
    );
    const vehicle = await id(
      owner,
      "INSERT INTO app.vehicles(plate,label,capacity) VALUES ('GT '||upper(substr(md5(random()::text),1,4))||'-20','Fixture bus',16)",
    );
    const route = await id(owner, "INSERT INTO app.routes(name) VALUES ('Fixture corridor')");
    const pattern = await id(
      owner,
      "INSERT INTO app.route_patterns(route_id,direction) VALUES ($1,'outbound')",
      [route],
    );
    const version = await id(
      owner,
      'INSERT INTO app.route_pattern_versions(pattern_id,revision) VALUES ($1,1)',
      [pattern],
    );
    const stop = await id(
      owner,
      "INSERT INTO app.stops(name,latitude,longitude) VALUES ('Depot',5.6,-0.2)",
    );
    const stops: string[] = [];
    for (let i = 0; i < 3; i++)
      stops.push(
        await id(
          owner,
          `INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude)
      VALUES ($1,$2,$3,$4,5.6,-0.2)`,
          [version, stop, i, `Stop ${i}`],
        ),
      );
    const geometry = await id(
      owner,
      `INSERT INTO app.route_geometries(pattern_version_id,source,line)
      VALUES ($1,'configured',ST_GeomFromText('LINESTRING(-0.2 5.6,-0.21 5.6,-0.2 5.6)',4326))`,
      [version],
    );
    for (const [index, occurrence] of stops.entries())
      await owner.query('INSERT INTO app.geometry_stop_distances VALUES ($1,$2,$3,$4)', [
        geometry,
        version,
        occurrence,
        index * 500,
      ]);
    await owner.query("UPDATE app.route_geometries SET state='published' WHERE id=$1", [geometry]);
    await owner.query(
      "UPDATE app.route_pattern_versions SET state='published',geometry_id=$2,effective_from='2026-01-01' WHERE id=$1",
      [version, geometry],
    );
    await admin.query(`CREATE ROLE "${role}" LOGIN PASSWORD 'runtime-test-only'`);
    roles.push(role);
    await grantRuntime(owner, role);
    const runtimeUrl = new URL(db);
    runtimeUrl.username = role;
    runtimeUrl.password = 'runtime-test-only';
    runtime = new pg.Pool({
      connectionString: runtimeUrl.href,
      max: 8,
      connectionTimeoutMillis: 3000,
      application_name: `commands-${run}-${n}`,
    });
    const app = await createTransportApp({
      pool: runtime,
      cursorSecret: Buffer.alloc(32, 7),
      requestsPerMinute: budget,
      minimumBuilds: { ops: 2, driver: { ios: 2, android: 2 }, commuter: { ios: 2, android: 2 } },
      verifyAccess: async (authorization) => {
        const label = authorization.replace(/^Bearer /, '') as keyof typeof users;
        return users[label] ? { userId: users[label], sessionId: `session-${label}` } : null;
      },
      authorizeSession: async (client, actor) => {
        const session = (
          await client.query(
            'SELECT active FROM app.test_sessions WHERE session_id=$1 AND user_id=$2 FOR SHARE',
            [actor.sessionId, actor.userId],
          )
        ).rows[0];
        if (!session?.active)
          throw new TransportError(401, 'unauthenticated', 'Sign in to continue.');
      },
      // Explicit test adapters only. Production application creation refuses
      // an absent adapter; no application option bypasses that requirement.
      coordinateReservations: async (client, change) => {
        if (!coordinated)
          throw new TransportError(
            503,
            'reservation_coordinator_unavailable',
            'Test coordinator unavailable.',
          );
        await client.query('INSERT INTO app.test_booking_effects VALUES ($1,$2)', [
          change.before.id,
          change.operation,
        ]);
      },
    });
    await app.ready();
    const headers = (who: keyof typeof users, ops = false) => ({
      authorization: `Bearer ${who}`,
      'x-trotxi-client': ops ? 'ops' : 'driver',
      'x-trotxi-build': '2',
      ...(!ops ? { 'x-trotxi-platform': 'android' } : {}),
    });
    async function request(
      who: keyof typeof users,
      method: 'GET' | 'POST' | 'PUT' | 'PATCH',
      path: string,
      body?: unknown,
      key: string = randomUUID(),
      token?: string,
    ) {
      return app.inject({
        method,
        url: path,
        headers: {
          ...headers(who, path.startsWith('/v1/ops/')),
          ...(method === 'GET' ? {} : { 'idempotency-key': key }),
          ...(token ? { 'if-match': token } : {}),
          ...(body === undefined ? {} : { 'content-type': 'application/json' }),
        },
        ...(body === undefined ? {} : { payload: JSON.stringify(body) }),
      });
    }
    const scheduleInput = {
      departure: { kind: 'new' },
      patternVersionId: version,
      serviceWindow: 'morning',
      localDeparture: '06:30',
      timeZone: 'Africa/Accra',
      weekdays: [1, 2, 3, 4, 5],
      effectiveFrom: '2026-01-01',
      effectiveTo: null,
    };
    async function seedTrip(assigned = driver, time = '2026-09-15T06:30:00.000000Z') {
      const departure = await id(
        owner,
        'INSERT INTO app.service_departures(pattern_id) VALUES ($1)',
        [pattern],
      );
      const schedule = await id(
        owner,
        `INSERT INTO app.service_schedules(pattern_version_id,pattern_id,departure_id,service_window,local_departure,weekdays,effective_from)
        VALUES ($1,$2,$3,'morning','06:30',ARRAY[1,2,3,4,5]::smallint[],'2026-01-01')`,
        [version, pattern, departure],
      );
      const trip = await id(
        owner,
        `INSERT INTO app.trips(schedule_id,pattern_version_id,departure_id,service_date,scheduled_at,assigned_driver_id,vehicle_id)
        VALUES ($1,$2,$3,$4,$5,$6,$7)`,
        [schedule, version, departure, time.slice(0, 10), time, assigned, vehicle],
      );
      return { trip, schedule, departure };
    }
    return {
      owner,
      runtime,
      app,
      users,
      driver,
      otherDriver,
      vehicle,
      route,
      pattern,
      version,
      stops,
      headers,
      request,
      scheduleInput,
      seedTrip,
      async close() {
        await app.close();
        await runtime!.end();
        await owner.end();
      },
    };
  } catch (error) {
    await runtime?.end();
    await owner.end();
    throw error;
  }
}
type Case = Awaited<ReturnType<typeof setup>>;
async function withCase(work: (c: Case) => Promise<void>, coordinated = false, budget = 1000) {
  const c = await setup(coordinated, budget);
  try {
    await work(c);
  } finally {
    await c.close();
  }
}
function status(response: { statusCode: number; body: string }, expected: number) {
  assert.equal(response.statusCode, expected, response.body);
}
async function counts(c: Case) {
  return (
    await c.owner.query(`SELECT
  (SELECT count(*)::int FROM app.transport_commands) AS commands,
  (SELECT count(*)::int FROM app.trip_events) AS events,
  (SELECT count(*)::int FROM app.schedule_events) AS schedules,
  (SELECT count(*)::int FROM app.test_booking_effects) AS booking_effects`)
  ).rows[0];
}

test('CMD-01 atomic schedule creation, normalized replay and cross-key business uniqueness', () =>
  withCase(async (c) => {
    const first = await c.request(
      'admin',
      'POST',
      '/v1/ops/service-schedules',
      c.scheduleInput,
      'schedule-key',
    );
    status(first, 201);
    const schedule = first.json().data;
    const replay = await c.request(
      'admin',
      'POST',
      '/v1/ops/service-schedules',
      { ...c.scheduleInput, weekdays: [5, 4, 3, 2, 1] },
      'schedule-key',
    );
    status(replay, 201);
    assert.deepEqual(replay.json(), first.json());
    const mismatch = await c.request(
      'admin',
      'POST',
      '/v1/ops/service-schedules',
      { ...c.scheduleInput, localDeparture: '07:30' },
      'schedule-key',
    );
    status(mismatch, 409);
    assert.equal(mismatch.json().error.code, 'idempotency_payload_conflict');
    const input = {
      scheduleId: schedule.id,
      serviceDate: '2026-09-15',
      scheduledAt: '2026-09-15T06:30:00Z',
    };
    const trip = await c.request('admin', 'POST', '/v1/ops/trips', input, 'trip-key');
    status(trip, 201);
    assert.equal(trip.headers.etag, trip.json().data.editToken);
    assert.equal(trip.json().data.departureId, schedule.departureId);
    assert.equal(trip.json().data.assignedDriverId, null);
    status(await c.request('admin', 'POST', '/v1/ops/trips', input, 'another-key'), 409);
    const revised = await c.request(
      'admin',
      'POST',
      '/v1/ops/service-schedules',
      {
        ...c.scheduleInput,
        departure: { kind: 'existing', departureId: schedule.departureId },
        localDeparture: '07:00',
      },
      'revision',
    );
    status(revised, 201);
    assert.equal(revised.json().data.departureId, schedule.departureId);
    assert.notEqual(revised.json().data.id, schedule.id);
    status(
      await c.request(
        'admin',
        'POST',
        '/v1/ops/trips',
        {
          ...input,
          scheduleId: revised.json().data.id,
          scheduledAt: '2026-09-15T07:00:00Z',
        },
        'revised-duplicate',
      ),
      409,
    );
    status(
      await c.request(
        'admin',
        'POST',
        '/v1/ops/service-schedules',
        {
          ...c.scheduleInput,
          departure: { kind: 'existing', departureId: randomUUID() },
        },
        'unknown-departure',
      ),
      409,
    );
    assert.deepEqual(await counts(c), { commands: 3, events: 1, schedules: 2, booking_effects: 0 });
    assert.equal(
      (await c.owner.query('SELECT count(*)::int AS n FROM app.service_departures')).rows[0].n,
      1,
    );
    assert.ok(!('_cursor' in trip.json().data));
  }));
test('CMD-02 assigned driver lifecycle is coherent and fresh-key duplicate start/complete is harmless', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip();
    status(await c.request('driver', 'POST', `/v1/driver/trips/${trip}/complete`), 409);
    const start = await c.request(
      'driver',
      'POST',
      `/v1/driver/trips/${trip}/start`,
      undefined,
      'start',
    );
    status(start, 200);
    status(
      await c.request('driver', 'POST', `/v1/driver/trips/${trip}/start`, undefined, 'start-again'),
      200,
    );
    const complete = await c.request(
      'driver',
      'POST',
      `/v1/driver/trips/${trip}/complete`,
      undefined,
      'complete',
    );
    status(complete, 200);
    status(
      await c.request(
        'driver',
        'POST',
        `/v1/driver/trips/${trip}/complete`,
        undefined,
        'complete-again',
      ),
      200,
    );
    status(
      await c.request('driver', 'POST', `/v1/driver/trips/${trip}/start`, undefined, 'new-start'),
      409,
    );
    assert.equal(start.json().data.status, 'active');
    assert.equal(complete.json().data.status, 'completed');
    assert.ok(
      Date.parse(complete.json().data.completedAt) >= Date.parse(start.json().data.startedAt),
    );
    assert.ok(!('assignedDriverId' in start.json().data));
    assert.deepEqual(await counts(c), { commands: 4, events: 2, schedules: 0, booking_effects: 0 });
  }));
test('CMD-17 UUID case does not change occurrence identity or the command replay scope', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip();
    const start = await c.request('driver', 'POST', `/v1/driver/trips/${trip}/start`);
    status(start, 200);
    const first = await c.request(
      'driver',
      'POST',
      `/v1/driver/trips/${trip.toUpperCase()}/arrivals`,
      { stopOccurrenceId: c.stops[0]!.toUpperCase() },
      'case-invariant',
      start.headers.etag as string,
    );
    status(first, 200);
    const replay = await c.request(
      'driver',
      'POST',
      `/v1/driver/trips/${trip}/arrivals`,
      { stopOccurrenceId: c.stops[0] },
      'case-invariant',
      start.headers.etag as string,
    );
    status(replay, 200);
    assert.deepEqual(replay.json(), first.json());
    assert.equal(first.json().data.currentStopOccurrenceId, c.stops[0]);
    assert.deepEqual(await counts(c), { commands: 2, events: 2, schedules: 0, booking_effects: 0 });
  }));
test('CMD-03 occurrence identity, explicit backward correction, stale-token refusal and replay before If-Match', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip();
    const started = await c.request('driver', 'POST', `/v1/driver/trips/${trip}/start`);
    status(started, 200);
    const path = `/v1/driver/trips/${trip}/arrivals`,
      firstInput = { stopOccurrenceId: c.stops[0], correction: false };
    status(await c.request('driver', 'POST', path, firstInput, 'missing'), 428);
    const first = await c.request(
      'driver',
      'POST',
      path,
      firstInput,
      'first',
      started.headers.etag as string,
    );
    status(first, 200);
    const second = await c.request(
      'driver',
      'POST',
      path,
      { stopOccurrenceId: c.stops[2], correction: false },
      'second',
      first.headers.etag as string,
    );
    status(second, 200);
    const retry = await c.request(
      'driver',
      'POST',
      path,
      firstInput,
      'first',
      started.headers.etag as string,
    );
    status(retry, 200);
    assert.deepEqual(retry.json(), first.json());
    status(
      await c.request(
        'driver',
        'POST',
        path,
        firstInput,
        'stale-new',
        started.headers.etag as string,
      ),
      412,
    );
    const backward = await c.request(
      'driver',
      'POST',
      path,
      firstInput,
      'no-correction',
      second.headers.etag as string,
    );
    status(backward, 409);
    assert.equal(backward.json().error.code, 'explicit_correction_required');
    const corrected = await c.request(
      'driver',
      'POST',
      path,
      { ...firstInput, correction: true },
      'correction',
      second.headers.etag as string,
    );
    status(corrected, 200);
    status(
      await c.request(
        'driver',
        'POST',
        path,
        { stopOccurrenceId: randomUUID(), correction: false },
        'alien',
        corrected.headers.etag as string,
      ),
      409,
    );
    const row = (
      await c.owner.query('SELECT current_stop_occurrence_id,version FROM app.trips WHERE id=$1', [
        trip,
      ])
    ).rows[0];
    assert.deepEqual(row, { current_stop_occurrence_id: c.stops[0], version: 5 });
    assert.deepEqual(
      (
        await c.owner.query('SELECT operation FROM app.trip_events ORDER BY created_at,id')
      ).rows.map((r) => r.operation),
      ['start', 'arrive', 'arrive', 'correct_arrival'],
    );
  }));
test('CMD-04 current session, account role and assignment authorize every replay; headers cannot elevate authority', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip();
    const path = `/v1/driver/trips/${trip}/start`;
    const foreign = await c.request('other', 'POST', path);
    status(foreign, 404);
    const absent = await c.request('other', 'POST', `/v1/driver/trips/${randomUUID()}/start`);
    status(absent, 404);
    assert.equal(foreign.json().error.code, absent.json().error.code);
    status(await c.request('rider', 'POST', '/v1/ops/service-schedules', c.scheduleInput), 403);
    status(await c.request('driver', 'POST', path, undefined, 'saved'), 200);
    await c.owner.query(
      "UPDATE app.test_sessions SET active=false WHERE session_id='session-driver'",
    );
    status(await c.request('driver', 'POST', path, undefined, 'saved'), 401);
    await c.owner.query(
      "UPDATE app.test_sessions SET active=true WHERE session_id='session-driver'",
    );
    await c.owner.query('UPDATE app.drivers SET archived_at=clock_timestamp() WHERE id=$1', [
      c.driver,
    ]);
    status(await c.request('driver', 'POST', path, undefined, 'saved'), 404);
    await c.owner.query('UPDATE app.drivers SET archived_at=NULL WHERE id=$1', [c.driver]);
    await c.owner.query('UPDATE app.users SET deleted_at=clock_timestamp() WHERE id=$1', [
      c.users.driver,
    ]);
    status(await c.request('driver', 'POST', path, undefined, 'saved'), 401);
    assert.deepEqual(await counts(c), { commands: 1, events: 1, schedules: 0, booking_effects: 0 });
  }));
test('CMD-05 unavailable test coordinator and direct unwired service both fail without mutation or receipt', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip(),
      token = `"trip:${trip}:1"`;
    for (const [method, path, input] of [
      [
        'PUT',
        `/v1/ops/trips/${trip}/assignment`,
        { driverId: c.otherDriver, vehicleId: c.vehicle },
      ],
      ['PATCH', `/v1/ops/trips/${trip}`, { scheduledAt: '2026-09-15T07:00:00Z' }],
      ['POST', `/v1/ops/trips/${trip}/cancel`, { reason: 'Test cancellation' }],
    ] as const) {
      const r = await c.request('admin', method, path, input, randomUUID(), token);
      status(r, 503);
      assert.equal(r.json().error.code, 'reservation_coordinator_unavailable');
    }
    // Only the lower-level service permits omission for isolated testing.
    // The HTTP factory now rejects that configuration before it can serve.
    const unwired = new TransportService({
      pool: c.runtime,
      cursorSecret: Buffer.alloc(32, 7),
      authorizeSession: async (client, actor) => {
        const session = await client.query(
          'SELECT active FROM app.test_sessions WHERE user_id=$1 AND session_id=$2 FOR SHARE',
          [actor.userId, actor.sessionId],
        );
        assert.equal(session.rows[0]?.active, true);
      },
    });
    for (const [operation, input] of [
      ['assignTrip', { driverId: c.otherDriver, vehicleId: c.vehicle }],
      ['rescheduleTrip', { scheduledAt: '2026-09-15T07:00:00Z' }],
      ['cancelTrip', { reason: 'Test cancellation' }],
    ] as [Command, Body][]) {
      await assert.rejects(
        unwired.command(
          { userId: c.users.admin, sessionId: 'session-admin' },
          operation,
          trip,
          input,
          randomUUID(),
          token,
        ),
        (e: unknown) =>
          e instanceof TransportError &&
          e.status === 503 &&
          e.code === 'reservation_coordinator_unavailable',
      );
    }
    assert.equal(
      (await c.owner.query('SELECT version FROM app.trips WHERE id=$1', [trip])).rows[0].version,
      1,
    );
    assert.deepEqual(await counts(c), { commands: 0, events: 0, schedules: 0, booking_effects: 0 });
  }));
test('CMD-06 explicit booking coordinator shares assignment, midnight reschedule and cancellation transactions', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip();
    const assignment = await c.request(
      'admin',
      'PUT',
      `/v1/ops/trips/${trip}/assignment`,
      { driverId: c.otherDriver, vehicleId: c.vehicle },
      'assign',
      `"trip:${trip}:1"`,
    );
    status(assignment, 200);
    assert.equal(assignment.json().data.assignedDriverId, c.otherDriver);
    const move = await c.request(
      'admin',
      'PATCH',
      `/v1/ops/trips/${trip}`,
      { scheduledAt: '2026-09-16T00:15:00Z' },
      'move',
      assignment.headers.etag as string,
    );
    status(move, 200);
    assert.equal(move.json().data.serviceDate, '2026-09-15');
    // Pinned to the fixture's days, not the endpoint's default window. That
    // default is the last seven days relative to now, so a listing with no
    // range silently stops containing a fixture dated in the past: this test
    // began failing on 2026-09-22 with nothing changed but the date. The
    // reschedule above moves scheduled_at into the 16th, and the filter reads
    // scheduled_at, so both days are needed.
    const roster = await c.request(
      'other',
      'GET',
      '/v1/driver/trips?fromDate=2026-09-15&toDate=2026-09-16',
    );
    status(roster, 200);
    const assigned = roster.json().data.find((row: { id: string }) => row.id === trip);
    const latestChange = (
      await c.owner.query(
        "SELECT max(created_at) AS changed FROM app.trip_events WHERE trip_id=$1 AND operation IN ('assign','reschedule','cancel')",
        [trip],
      )
    ).rows[0].changed;
    assert.ok(latestChange, 'fixture must contain a committed schedule change');
    assert.equal(assigned?.assignmentChangedAt, latestChange.toISOString());
    const cancel = await c.request(
      'admin',
      'POST',
      `/v1/ops/trips/${trip}/cancel`,
      { reason: 'Test' },
      'cancel',
      move.headers.etag as string,
    );
    status(cancel, 200);
    status(
      await c.request(
        'admin',
        'POST',
        `/v1/ops/trips/${trip}/cancel`,
        { reason: 'Test' },
        'cancel',
        move.headers.etag as string,
      ),
      200,
    );
    assert.equal(cancel.json().data.status, 'cancelled');
    assert.deepEqual(await counts(c), { commands: 3, events: 3, schedules: 0, booking_effects: 3 });
  }, true));
test('CMD-07 an event-write failure rolls back state, coordinated effects and key; same-key retry can succeed', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip();
    const before = (await c.owner.query('SELECT * FROM app.trips WHERE id=$1', [trip])).rows;
    await c.owner
      .query(`CREATE FUNCTION app.test_fail_event() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'private fault text'; END $$;
    CREATE TRIGGER test_fail_event BEFORE INSERT ON app.trip_events FOR EACH ROW EXECUTE FUNCTION app.test_fail_event()`);
    const path = `/v1/ops/trips/${trip}`,
      body = { scheduledAt: '2026-09-16T00:15:00Z' },
      token = `"trip:${trip}:1"`;
    const failed = await c.request('admin', 'PATCH', path, body, 'retryable', token);
    status(failed, 500);
    assert.ok(!failed.body.includes('private fault'));
    assert.deepEqual(
      (await c.owner.query('SELECT * FROM app.trips WHERE id=$1', [trip])).rows,
      before,
    );
    assert.deepEqual(await counts(c), { commands: 0, events: 0, schedules: 0, booking_effects: 0 });
    await c.owner.query('DROP TRIGGER test_fail_event ON app.trip_events');
    status(await c.request('admin', 'PATCH', path, body, 'retryable', token), 200);
    assert.deepEqual(await counts(c), { commands: 1, events: 1, schedules: 0, booking_effects: 1 });
  }, true));
test('CMD-08 schedule failure leaves no new departure, and keys are scoped by caller and operation', () =>
  withCase(async (c) => {
    await c.owner.query('UPDATE app.routes SET archived_at=clock_timestamp() WHERE id=$1', [
      c.route,
    ]);
    status(
      await c.request('admin', 'POST', '/v1/ops/service-schedules', c.scheduleInput, 'same'),
      409,
    );
    assert.equal(
      (await c.owner.query('SELECT count(*)::int AS n FROM app.service_departures')).rows[0].n,
      0,
    );
    await c.owner.query('UPDATE app.routes SET archived_at=NULL WHERE id=$1', [c.route]);
    const first = await c.request(
      'admin',
      'POST',
      '/v1/ops/service-schedules',
      c.scheduleInput,
      'same',
    );
    status(first, 201);
    const other = await c.request(
      'otherAdmin',
      'POST',
      '/v1/ops/service-schedules',
      c.scheduleInput,
      'same',
    );
    status(other, 201);
    assert.notEqual(first.json().data.id, other.json().data.id);
    status(
      await c.request(
        'admin',
        'POST',
        '/v1/ops/trips',
        {
          scheduleId: first.json().data.id,
          serviceDate: '2026-09-15',
          scheduledAt: '2026-09-15T06:30:00Z',
        },
        'same',
      ),
      201,
    );
    await c.owner.query("UPDATE app.users SET role='commuter' WHERE id=$1", [c.users.admin]);
    status(
      await c.request('admin', 'POST', '/v1/ops/service-schedules', c.scheduleInput, 'same'),
      403,
    );
    assert.deepEqual(await counts(c), { commands: 3, events: 1, schedules: 2, booking_effects: 0 });
  }));

async function contend(c: Case, trip: string, requests: () => Promise<unknown>[]) {
  const blocker = await c.owner.connect();
  let pending: Promise<unknown>[] = [];
  try {
    await blocker.query('BEGIN');
    await blocker.query('SELECT id FROM app.trips WHERE id=$1 FOR UPDATE', [trip]);
    const blockerPid = (await blocker.query('SELECT pg_backend_pid() AS pid')).rows[0].pid;
    pending = requests();
    let waiting: { pid: number; blockers: number[] }[] = [];
    const deadline = Date.now() + 2200;
    while (Date.now() < deadline) {
      waiting = (
        await c.owner.query(`SELECT pid,pg_blocking_pids(pid) AS blockers FROM pg_stat_activity
        WHERE datname=current_database() AND application_name LIKE 'commands-%' AND wait_event_type='Lock'`)
      ).rows;
      if (
        new Set(waiting.map((r) => r.pid)).size === 2 &&
        waiting.some((r) => r.blockers.includes(blockerPid))
      )
        break;
      await delay(10);
    }
    assert.equal(
      new Set(waiting.map((r) => r.pid)).size,
      2,
      'two real command connections must be waiting before release',
    );
    assert.ok(waiting.some((r) => r.blockers.includes(blockerPid)));
    evidence.push({ trip, blockerPid, waiting });
    await blocker.query('COMMIT');
    return await Promise.all(pending);
  } finally {
    await blocker.query('ROLLBACK');
    await Promise.allSettled(pending);
    blocker.release();
  }
}
test('CMD-09 concurrent identical HTTP retries contend and commit one transition, event and receipt', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip();
    const responses = await contend(c, trip, () => [
      c.request('driver', 'POST', `/v1/driver/trips/${trip}/start`, undefined, 'same'),
      c.request('driver', 'POST', `/v1/driver/trips/${trip}/start`, undefined, 'same'),
    ]);
    const [a, b] = responses as Awaited<ReturnType<Case['request']>>[];
    status(a!, 200);
    status(b!, 200);
    assert.deepEqual(a!.json(), b!.json());
    assert.deepEqual(await counts(c), { commands: 1, events: 1, schedules: 0, booking_effects: 0 });
  }));
test('CMD-10 concurrent distinct arrivals with one edit token cannot overwrite each other', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip();
    const start = await c.request('driver', 'POST', `/v1/driver/trips/${trip}/start`);
    status(start, 200);
    const responses = await contend(c, trip, () => [
      c.request(
        'driver',
        'POST',
        `/v1/driver/trips/${trip}/arrivals`,
        { stopOccurrenceId: c.stops[0], correction: false },
        'a',
        start.headers.etag as string,
      ),
      c.request(
        'driver',
        'POST',
        `/v1/driver/trips/${trip}/arrivals`,
        { stopOccurrenceId: c.stops[1], correction: false },
        'b',
        start.headers.etag as string,
      ),
    ]);
    assert.deepEqual(
      (responses as { statusCode: number }[]).map((r) => r.statusCode).sort(),
      [200, 412],
    );
    assert.deepEqual(await counts(c), { commands: 2, events: 2, schedules: 0, booking_effects: 0 });
  }));
test('CMD-11 driver scope precedes pagination; microsecond cursors bind caller and filters; rows carry edit tokens', () =>
  withCase(async (c) => {
    const trips = [];
    for (const suffix of ['123455', '123456', '123457'])
      trips.push(await c.seedTrip(c.driver, `2026-09-15T06:30:00.${suffix}Z`));
    await c.seedTrip(c.otherDriver, '2026-09-15T06:30:00.123456Z');
    const base = '/v1/driver/trips?fromDate=2026-09-15&toDate=2026-09-15&limit=1';
    let next: string | null = null;
    const seen: string[] = [];
    for (let i = 0; i < 3; i++) {
      const r = await c.request('driver', 'GET', base + (next ? `&cursor=${next}` : ''));
      status(r, 200);
      assert.equal(r.json().data.length, 1);
      const row = r.json().data[0];
      seen.push(row.id);
      assert.equal(row.editToken, `"trip:${row.id}:1"`);
      assert.ok(!('assignedDriverId' in row));
      next = r.json().page.nextCursor;
      if (i === 0) {
        assert.ok(next && next.length <= 128);
        status(await c.request('other', 'GET', `${base}&cursor=${next}`), 400);
        status(await c.request('driver', 'GET', `${base}&routeId=${c.route}&cursor=${next}`), 400);
      }
    }
    assert.deepEqual(
      seen,
      trips.map((t) => t.trip),
    );
    assert.equal(next, null);
    const ops = await c.request(
      'admin',
      'GET',
      '/v1/ops/trips?fromDate=2026-09-15&toDate=2026-09-15',
    );
    status(ops, 200);
    assert.equal(ops.json().data.length, 4);
    assert.ok('assignedDriverId' in ops.json().data[0]);
    status(await c.request('driver', 'GET', '/v1/driver/trips?fromDate=2026-09-15'), 400);
    status(
      await c.request('driver', 'GET', '/v1/driver/trips?fromDate=2026-01-01&toDate=2026-09-15'),
      400,
    );
    status(await c.request('driver', 'GET', '/v1/driver/trips?userId=someone'), 400);
  }));
test('CMD-12 strict wire validation rejects guessed state, identity edits and malformed schedule conventions', () =>
  withCase(async (c) => {
    const { trip, schedule } = await c.seedTrip();
    for (const body of [
      { status: 'active' },
      { scheduledAt: '2026-09-15T07:00:00Z', serviceDate: '2026-09-16' },
      { scheduleId: schedule },
    ])
      status(
        await c.request('admin', 'PATCH', `/v1/ops/trips/${trip}`, body, 'bad', `"trip:${trip}:1"`),
        400,
      );
    for (const change of [
      { weekdays: [0] },
      { weekdays: [1, 1] },
      { effectiveFrom: '2026-02-30' },
      { effectiveTo: '2025-12-31' },
      { departure: undefined },
    ])
      status(
        await c.request('admin', 'POST', '/v1/ops/service-schedules', {
          ...c.scheduleInput,
          ...change,
        }),
        400,
      );
    status(
      await c.request('admin', 'POST', '/v1/ops/trips', {
        scheduleId: schedule,
        serviceDate: '2026-09-15',
        scheduledAt: '2026-09-15T06:30:00Z',
        runNumber: 2,
      }),
      400,
    );
    status(
      await c.request('driver', 'POST', `/v1/driver/trips/${trip}/start`, { role: 'admin' }),
      400,
    );
    assert.deepEqual(await counts(c), { commands: 0, events: 0, schedules: 0, booking_effects: 0 });
  }));
test('CMD-13 expired retry keys are refused, not re-executed', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip();
    const path = `/v1/driver/trips/${trip}/start`;
    status(await c.request('driver', 'POST', path, undefined, 'expired'), 200);
    // Owner-only fixture manipulation, unavailable to the tested runtime role.
    await c.owner
      .query(`ALTER TABLE app.transport_commands DISABLE TRIGGER transport_commands_append_only;
    UPDATE app.transport_commands SET created_at=clock_timestamp()-interval '8 days',replay_expires_at=clock_timestamp()-interval '1 day';
    ALTER TABLE app.transport_commands ENABLE TRIGGER transport_commands_append_only`);
    const retry = await c.request('driver', 'POST', path, undefined, 'expired');
    status(retry, 409);
    assert.equal(retry.json().error.code, 'idempotency_key_expired');
    assert.deepEqual(await counts(c), { commands: 1, events: 1, schedules: 0, booking_effects: 0 });
  }));
test('CMD-14 commands run as a real narrow runtime login, not the schema owner', () =>
  withCase(async (c) => {
    const schedule = await c.request('admin', 'POST', '/v1/ops/service-schedules', c.scheduleInput);
    status(schedule, 201);
    const rejects = (query: Promise<unknown>) =>
      assert.rejects(query, (e: unknown) => (e as { code: string }).code === '42501');
    await rejects(c.runtime.query('CREATE TABLE app.bad(id int)'));
    await rejects(c.runtime.query('UPDATE app.transport_commands SET response_status=200'));
    await rejects(c.runtime.query("UPDATE app.schedule_events SET operation='create'"));
    await rejects(c.runtime.query('DELETE FROM app.trips'));
  }));
test('CMD-18 only the actual table owner may insert receiptless event fixtures', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip();
    const insert = `INSERT INTO app.trip_events(trip_id,actor_user_id,operation,before_state,after_state)
      VALUES ($1,$2,'create','{}','{}') RETURNING command_id`;
    const args = [trip, c.users.admin];
    assert.equal((await c.owner.query(insert, args)).rows[0].command_id, null);
    const receiptRequired = (error: unknown) => {
      assert.equal((error as { code: string }).code, '23514');
      assert.match((error as Error).message, /^trip_event_receipt_required$/);
      return true;
    };
    await assert.rejects(c.runtime.query(insert, args), receiptRequired);
    await assert.rejects(
      c.runtime.query(
        `INSERT INTO app.trip_events
      (trip_id,actor_user_id,operation,before_state,after_state,command_id)
      VALUES ($1,$2,'create','{}','{}',NULL)`,
        args,
      ),
      receiptRequired,
    );
    const ownerRole = (await c.owner.query('SELECT current_user AS name')).rows[0].name;
    const denied = (error: unknown) => (error as { code: string }).code === '42501';
    await assert.rejects(
      c.runtime.query("SELECT set_config('role',$1,false)", [ownerRole]),
      denied,
    );
    await assert.rejects(
      c.runtime.query('ALTER TABLE app.trip_events DISABLE TRIGGER require_trip_event_receipt'),
      denied,
    );
    const guard = (
      await c.owner.query(`SELECT prosecdef,proconfig FROM pg_proc
      WHERE oid='app.require_trip_event_receipt()'::regprocedure`)
    ).rows[0];
    assert.deepEqual(guard, { prosecdef: false, proconfig: ['search_path=pg_catalog'] });
    // Ordinary commands still work as the same restricted runtime login.
    status(await c.request('driver', 'POST', `/v1/driver/trips/${trip}/start`), 200);
    assert.deepEqual(await counts(c), { commands: 1, events: 2, schedules: 0, booking_effects: 0 });
  }));
test('CMD-19 receipt and event actors must match at commit, while event-before-receipt remains valid', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip();
    const eventSql = `INSERT INTO app.trip_events
      (trip_id,actor_user_id,command_id,operation,before_state,after_state)
      VALUES ($1,$2,$3,'create','{}','{}') RETURNING id`;
    const client = await c.runtime.connect();
    try {
      for (const kind of ['missing', 'wrong-actor', 'matching']) {
        const command = randomUUID();
        await client.query('BEGIN');
        try {
          // A non-null reference permits the INSERT; the FK validates at COMMIT.
          assert.equal((await client.query(eventSql, [trip, c.users.admin, command])).rowCount, 1);
          if (kind !== 'missing')
            await client.query(
              `INSERT INTO app.transport_commands
            (id,actor_user_id,operation,target,key_hash,input_hash,response_status,response_body,response_headers,replay_expires_at)
            VALUES ($1,$2,'createTrip','collection',$3,$4,201,'{}','{}',clock_timestamp()+interval '7 days')`,
              [
                command,
                kind === 'wrong-actor' ? c.users.otherAdmin : c.users.admin,
                randomBytes(32).toString('hex'),
                randomBytes(32).toString('hex'),
              ],
            );
          if (kind === 'matching') await client.query('COMMIT');
          else {
            await assert.rejects(client.query('COMMIT'), (error: unknown) => {
              assert.equal((error as { code: string }).code, '23503');
              assert.equal(
                (error as { constraint: string }).constraint,
                'trip_event_command_actor',
              );
              return true;
            });
            assert.deepEqual(await counts(c), {
              commands: 0,
              events: 0,
              schedules: 0,
              booking_effects: 0,
            });
          }
        } finally {
          await client.query('ROLLBACK');
        }
      }
    } finally {
      client.release();
    }
    // Owner exception is only for NULL: supplied references still obey the FK.
    await assert.rejects(
      c.owner.query(eventSql, [trip, c.users.admin, randomUUID()]),
      (e: unknown) => (e as { code: string }).code === '23503',
    );
    assert.deepEqual(await counts(c), { commands: 1, events: 1, schedules: 0, booking_effects: 0 });
  }));
test('CMD-20 all four conditional mutations return 404 before absent or stale If-Match', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip();
    const before = (await c.owner.query('SELECT * FROM app.trips WHERE id=$1', [trip])).rows;
    for (const token of [undefined, '"stale"']) {
      const missing = randomUUID();
      for (const [who, method, path, input] of [
        [
          'driver',
          'POST',
          `/v1/driver/trips/${missing}/arrivals`,
          { stopOccurrenceId: c.stops[0] },
        ],
        [
          'admin',
          'PUT',
          `/v1/ops/trips/${missing}/assignment`,
          { driverId: c.driver, vehicleId: c.vehicle },
        ],
        ['admin', 'PATCH', `/v1/ops/trips/${missing}`, { scheduledAt: '2026-09-15T07:00:00Z' }],
        ['admin', 'POST', `/v1/ops/trips/${missing}/cancel`, { reason: 'Missing trip' }],
      ] as const) {
        const reply = await c.request(who, method, path, input, randomUUID(), token);
        status(reply, 404);
        assert.equal(reply.json().error.code, 'not_found');
      }
      const foreign = await c.request(
        'other',
        'POST',
        `/v1/driver/trips/${trip}/arrivals`,
        { stopOccurrenceId: c.stops[0] },
        randomUUID(),
        token,
      );
      status(foreign, 404);
      assert.equal(foreign.json().error.code, 'not_found');
    }
    assert.deepEqual(
      (await c.owner.query('SELECT * FROM app.trips WHERE id=$1', [trip])).rows,
      before,
    );
    assert.deepEqual(await counts(c), { commands: 0, events: 0, schedules: 0, booking_effects: 0 });
  }));
test('CMD-15 compatibility metadata never grants authority; unsupported builds fail before writes', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip();
    for (const [headers, code] of [
      [{ authorization: 'Bearer driver' }, 400],
      [{ ...c.headers('driver'), 'x-trotxi-build': '1' }, 426],
      [{ ...c.headers('driver'), 'x-trotxi-client': 'ops' }, 400],
      [{ ...c.headers('driver'), authorization: 'Bearer not-a-token' }, 401],
    ] as const) {
      const r = await c.app.inject({
        method: 'POST',
        url: `/v1/driver/trips/${trip}/start`,
        headers: { ...headers, 'idempotency-key': randomUUID() },
      });
      status(r, code);
    }
    assert.deepEqual(await counts(c), { commands: 0, events: 0, schedules: 0, booking_effects: 0 });
  }));
test('CMD-16 bounded admission returns Retry-After instead of admitting unlimited authenticated requests', () =>
  withCase(
    async (c) => {
      status(await c.request('driver', 'GET', '/v1/driver/trips'), 200);
      status(await c.request('driver', 'GET', '/v1/driver/trips'), 200);
      const third = await c.request('driver', 'GET', '/v1/driver/trips');
      status(third, 429);
      assert.ok(Number(third.headers['retry-after']) > 0);
    },
    false,
    2,
  ));

test('CMD-21 a driver is told the plate of the bus, not just an optional label', () =>
  withCase(async (c) => {
    const { trip } = await c.seedTrip();
    const plate = (await c.owner.query('SELECT plate FROM app.vehicles WHERE id=$1', [c.vehicle]))
      .rows[0].plate as string;
    // Same reason as CMD-06: the fixture is dated, the default window is
    // relative, and an unpinned listing quietly empties as the days pass.
    const find = async (who: 'driver' | 'admin' | 'rider', path: string) =>
      JSON.parse(
        (await c.request(who, 'GET', `${path}?fromDate=2026-09-15&toDate=2026-09-15`)).body,
      ).data.find((t: { id: string }) => t.id === trip);

    const mine = await find('driver', '/v1/driver/trips');
    assert.equal(mine.vehiclePlate, plate);
    assert.equal(mine.vehicleLabel, 'Fixture bus');

    // A label is optional and a plate is not, which is the whole point: with no
    // label a driver previously had nothing at all identifying the vehicle.
    await c.owner.query('UPDATE app.vehicles SET label=NULL WHERE id=$1', [c.vehicle]);
    const unlabelled = await find('driver', '/v1/driver/trips');
    assert.equal(unlabelled.vehicleLabel, null);
    assert.equal(unlabelled.vehiclePlate, plate, 'the plate still identifies the bus');

    // Ops inherits the field. The rider catalogue deliberately does not: it
    // says what is running, never which bus was assigned to whom.
    assert.equal((await find('admin', '/v1/ops/trips')).vehiclePlate, plate);
    assert.equal('vehiclePlate' in (await find('rider', '/v1/trips')), false);
  }));
