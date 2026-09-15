import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes, randomUUID } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import pg from 'pg';
import { createTransportApp } from '../src/http/app.js';
import { TransportError } from '../src/transport/errors.js';
import { grantRuntime, migrate, readMigrations } from '../src/db/migrate.js';

const value = process.env.HARNESS_ADMIN_DATABASE_URL;
if (!value || process.env.HARNESS_ALLOW_CREATE_DATABASES !== '1')
  throw new Error('Disposable PostgreSQL required; GPS tests never skip');
const url = new URL(value);
if (
  !['postgres:', 'postgresql:'].includes(url.protocol) ||
  !['127.0.0.1', 'localhost', '[::1]'].includes(url.hostname) ||
  url.pathname !== '/postgres'
)
  throw new Error('Only an explicitly disposable loopback postgres admin database is allowed');
const admin = new pg.Pool({ connectionString: url.href, max: 2, connectionTimeoutMillis: 3000 });
const migrations = await readMigrations(fileURLToPath(new URL('../migrations/', import.meta.url)));
const run = randomBytes(5).toString('hex'),
  owned: string[] = [],
  roles: string[] = [];
let serial = 0;
after(async () => {
  try {
    for (const name of owned) await admin.query(`DROP DATABASE "${name}"`);
    for (const role of roles) await admin.query(`DROP ROLE "${role}"`);
  } finally {
    await admin.end();
  }
});

type Response = { statusCode: number; body: string; json(): any };
function expectStatus(response: Response, code: number) {
  assert.equal(response.statusCode, code, response.body);
  return response.json().data;
}

async function setup() {
  const n = ++serial,
    name = `trotxi_harness_${run}_gps_${n}`,
    role = `trotxi_runtime_gps_${run}_${n}`;
  await admin.query(`CREATE DATABASE "${name}"`);
  owned.push(name);
  const db = new URL(url);
  db.pathname = `/${name}`;
  const owner = new pg.Pool({ connectionString: db.href, max: 5, connectionTimeoutMillis: 3000 });
  await migrate(owner, migrations);
  const users = { admin: randomUUID(), driver: randomUUID(), other: randomUUID() };
  await owner.query('CREATE TABLE app.test_gps_sessions(user_id uuid PRIMARY KEY)');
  for (const [label, id] of Object.entries(users)) {
    await owner.query('INSERT INTO app.users(id,role) VALUES ($1,$2)', [
      id,
      label === 'admin' ? 'admin' : 'driver',
    ]);
    await owner.query('INSERT INTO app.test_gps_sessions(user_id) VALUES ($1)', [id]);
  }
  const drivers: Record<string, string> = {};
  for (const label of ['driver', 'other'])
    drivers[label] = (
      await owner.query('INSERT INTO app.drivers(user_id,name) VALUES ($1,$2) RETURNING id', [
        users[label as 'driver'],
        label,
      ])
    ).rows[0].id;
  await admin.query(`CREATE ROLE "${role}" LOGIN PASSWORD 'runtime-test-only'`);
  roles.push(role);
  await grantRuntime(owner, role);
  db.username = role;
  db.password = 'runtime-test-only';
  const applicationName = `gps-${run}-${n}`;
  const runtime = new pg.Pool({
    connectionString: db.href,
    max: 8,
    connectionTimeoutMillis: 3000,
    application_name: applicationName,
  });
  const app = await createTransportApp({
    pool: runtime,
    cursorSecret: Buffer.alloc(32, 7),
    requestsPerMinute: 2000,
    requestsPerIpPerMinute: 3000,
    minimumBuilds: { ops: 2, driver: { ios: 2, android: 2 }, commuter: { ios: 3, android: 3 } },
    verifyAccess: async (auth) => {
      const id = users[auth.replace(/^Bearer /, '') as keyof typeof users];
      return id ? { userId: id, sessionId: id } : null;
    },
    authorizeSession: async (client, actor) => {
      if (
        !(
          await client.query('SELECT 1 FROM app.test_gps_sessions WHERE user_id=$1 FOR SHARE', [
            actor.userId,
          ])
        ).rowCount
      )
        throw new TransportError(401, 'unauthenticated', 'Sign in to continue.');
    },
    coordinateReservations: async () => {
      throw new TransportError(503, 'unavailable', 'Not wired in this slice.');
    },
  });
  const request = (
    method: 'GET' | 'POST',
    path: string,
    body?: unknown,
    options: { who?: keyof typeof users; key?: string; token?: string; ops?: boolean } = {},
  ) =>
    app.inject({
      method,
      url: path,
      headers: {
        authorization: `Bearer ${options.who ?? 'admin'}`,
        ...(options.who && options.who !== 'admin' && !options.ops
          ? { 'x-trotxi-client': 'driver', 'x-trotxi-build': '2', 'x-trotxi-platform': 'android' }
          : { 'x-trotxi-client': 'ops', 'x-trotxi-build': '2' }),
        ...(method !== 'GET' ? { 'idempotency-key': options.key ?? randomUUID() } : {}),
        ...(options.token ? { 'if-match': options.token } : {}),
        ...(body === undefined ? {} : { 'content-type': 'application/json' }),
      },
      ...(body === undefined ? {} : { payload: JSON.stringify(body) }),
    }) as Promise<Response>;

  /** A published pattern version with a scheduled run assigned to one driver. */
  const trip = async (
    label: 'driver' | 'other',
    status = 'active',
    sameRunAs?: string,
    startedHoursAgo = 2,
  ) => {
    // Launch allows one run per departure per service date, so a second trip on
    // the same published version is the same departure on an earlier day.
    if (sameRunAs) {
      const parent = (
        await owner.query(
          'SELECT schedule_id,pattern_version_id,departure_id FROM app.trips WHERE id=$1',
          [sameRunAs],
        )
      ).rows[0];
      const taken = (
        await owner.query('SELECT count(*)::int AS n FROM app.trips WHERE departure_id=$1', [
          parent.departure_id,
        ])
      ).rows[0].n;
      const reused = (
        await owner.query(
          `INSERT INTO app.trips(schedule_id,pattern_version_id,departure_id,service_date,
            scheduled_at,assigned_driver_id,status)
          VALUES ($1,$2,$3,(current_date-$4::int)::date,clock_timestamp(),$5,'scheduled')
          RETURNING id`,
          [
            parent.schedule_id,
            parent.pattern_version_id,
            parent.departure_id,
            taken,
            drivers[label],
          ],
        )
      ).rows[0].id;
      return drive(reused, status, startedHoursAgo);
    }
    const route = (
      await owner.query("INSERT INTO app.routes(name) VALUES ('GPS corridor') RETURNING id")
    ).rows[0].id;
    const pattern = (
      await owner.query(
        "INSERT INTO app.route_patterns(route_id,direction) VALUES ($1,'outbound') RETURNING id",
        [route],
      )
    ).rows[0].id;
    const stop = (
      await owner.query(
        "INSERT INTO app.stops(name,latitude,longitude) VALUES ('S',5.6,-0.2) RETURNING id",
      )
    ).rows[0].id;
    const version = (
      await owner.query(
        'INSERT INTO app.route_pattern_versions(pattern_id,revision) VALUES ($1,1) RETURNING id',
        [pattern],
      )
    ).rows[0].id;
    const occurrences: string[] = [];
    for (const ordinal of [0, 1])
      occurrences.push(
        (
          await owner.query(
            `INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude)
            VALUES ($1,$2,$3,'S',5.6,-0.2) RETURNING id`,
            [version, stop, ordinal],
          )
        ).rows[0].id,
      );
    const geometry = (
      await owner.query(
        `INSERT INTO app.route_geometries(pattern_version_id,source,state,line)
        VALUES ($1,'configured','draft',
          ST_SetSRID(ST_MakeLine(ARRAY[ST_MakePoint(-0.2,5.6),ST_MakePoint(-0.21,5.61)]),4326))
        RETURNING id`,
        [version],
      )
    ).rows[0].id;
    for (const [index, occurrence] of occurrences.entries())
      await owner.query(
        `INSERT INTO app.geometry_stop_distances(geometry_id,pattern_version_id,stop_occurrence_id,distance_meters)
        VALUES ($1,$2,$3,$4)`,
        [geometry, version, occurrence, index * 1000],
      );
    await owner.query("UPDATE app.route_geometries SET state='published' WHERE id=$1", [geometry]);
    await owner.query(
      `UPDATE app.route_pattern_versions
      SET geometry_id=$2,state='published',effective_from=clock_timestamp()-interval '1 day'
      WHERE id=$1`,
      [version, geometry],
    );
    const departure = (
      await owner.query('INSERT INTO app.service_departures(pattern_id) VALUES ($1) RETURNING id', [
        pattern,
      ])
    ).rows[0].id;
    const today = new Date().toISOString().slice(0, 10);
    const schedule = (
      await owner.query(
        `INSERT INTO app.service_schedules(pattern_version_id,pattern_id,departure_id,service_window,
          local_departure,weekdays,effective_from)
        VALUES ($1,$2,$3,'morning','06:30',ARRAY[1,2,3,4,5,6,7]::smallint[],
          current_date-interval '30 days') RETURNING id`,
        [version, pattern, departure],
      )
    ).rows[0].id;
    const id = (
      await owner.query(
        `INSERT INTO app.trips(schedule_id,pattern_version_id,departure_id,service_date,
          scheduled_at,assigned_driver_id,status)
        VALUES ($1,$2,$3,$4::date,clock_timestamp(),$5,'scheduled') RETURNING id`,
        [schedule, version, departure, today, drivers[label]],
      )
    ).rows[0].id;
    return drive(id, status, startedHoursAgo);
  };
  /** Drive a scheduled trip into the state the case needs. */
  const drive = async (id: string, status: string, startedHoursAgo = 2) => {
    if (status === 'active')
      await owner.query(
        `UPDATE app.trips SET status='active',
          started_at=clock_timestamp()-make_interval(hours => $2) WHERE id=$1`,
        [id, startedHoursAgo],
      );
    if (status === 'completed') {
      // The schema refuses scheduled -> completed, so the fixture runs the
      // trip the way a driver would.
      await owner.query(
        `UPDATE app.trips SET status='active',started_at=clock_timestamp()-interval '1 hour'
        WHERE id=$1`,
        [id],
      );
      await owner.query(
        "UPDATE app.trips SET status='completed',completed_at=clock_timestamp() WHERE id=$1",
        [id],
      );
    }
    return id;
  };
  /** A fix a given number of metres along the run's published line. */
  const place = async (
    tripId: string,
    metres: number,
    at: Date,
    extra: { accuracy?: number; receivedAt?: Date; adjusted?: boolean } = {},
  ) =>
    (
      await owner.query(
        `INSERT INTO app.trip_positions
          (trip_id,client_fix_id,captured_at,effective_captured_at,received_at,accuracy_meters,clock_adjusted,location,payload_digest)
        SELECT $1,gen_random_uuid(),
          CASE WHEN $6 THEN $2::timestamptz+interval '60 seconds' ELSE $2::timestamptz END,
          $2::timestamptz,$3,$4,$6,
          ST_LineInterpolatePoint(g.line,LEAST(1,$5::float8/ST_Length(g.line::geography))),
          encode(sha256(gen_random_uuid()::text::bytea),'hex')
        FROM app.trips t
        JOIN app.route_pattern_versions v ON v.id=t.pattern_version_id
        JOIN app.route_geometries g ON g.id=v.geometry_id
        WHERE t.id=$1 RETURNING id`,
        [
          tripId,
          at,
          extra.receivedAt ?? at,
          extra.accuracy ?? null,
          metres,
          extra.adjusted ?? false,
        ],
      )
    ).rows[0].id;
  const fix = (extra: Record<string, unknown> = {}) => ({
    clientFixId: randomUUID(),
    capturedAt: new Date().toISOString(),
    latitude: 5.6,
    longitude: -0.2,
    ...extra,
  });
  const incidentFor = async (tripId: string) =>
    (
      await owner.query(
        `INSERT INTO app.driver_incidents(driver_id,trip_id,category)
        SELECT assigned_driver_id,id,'collision' FROM app.trips WHERE id=$1 RETURNING id`,
        [tripId],
      )
    ).rows[0].id;
  /** A hold recorded while the trace was still fresh, as ops would have. */
  const holdFor = async (tripId: string, from: Date, to: Date) =>
    (
      await owner.query(
        `INSERT INTO app.trace_holds
          (incident_id,trip_id,received_from,received_to,reason,review_at,created_by)
        VALUES ($1,$2,$3,$4,'Collision under investigation',clock_timestamp()+interval '30 days',$5)
        RETURNING id`,
        [await incidentFor(tripId), tripId, from, to, users.admin],
      )
    ).rows[0].id;
  return {
    owner,
    runtime,
    applicationName,
    users,
    request,
    holdFor,
    trip,
    fix,
    place,
    incidentFor,
    close: async () => {
      await app.close();
      await runtime.end();
      await owner.end();
    },
  };
}
type Case = Awaited<ReturnType<typeof setup>>;
/** Wait for `count` runtime connections to be genuinely blocked on a lock. */
async function contended(c: Case, count: number) {
  const deadline = Date.now() + 4000;
  for (;;) {
    const rows = (
      await c.owner.query(
        `SELECT pid FROM pg_stat_activity
        WHERE application_name=$1 AND state='active'
          AND cardinality(pg_blocking_pids(pid))>0`,
        [c.applicationName],
      )
    ).rows;
    if (rows.length >= count) return rows;
    if (Date.now() > deadline)
      throw new Error(`expected ${count} blocked connections, saw ${rows.length}`);
    await new Promise((resolve) => setTimeout(resolve, 10));
  }
}
async function withCase(work: (c: Case) => Promise<void>) {
  const c = await setup();
  try {
    await work(c);
  } finally {
    await c.close();
  }
}

test('GPS-01 only the assigned driver of an active run may report a position', () =>
  withCase(async (c) => {
    const mine = await c.trip('driver');
    const theirs = await c.trip('other');
    const scheduled = await c.trip('driver', 'scheduled');

    expectStatus(
      await c.request('POST', `/v1/driver/trips/${mine}/positions`, c.fix(), { who: 'driver' }),
      200,
    );
    // Another driver's run and a run that does not exist are the same answer.
    for (const target of [theirs, randomUUID()])
      expectStatus(
        await c.request('POST', `/v1/driver/trips/${target}/positions`, c.fix(), {
          who: 'driver',
        }),
        404,
      );
    // Collection is for an active run only: a scheduled one is refused.
    expectStatus(
      await c.request('POST', `/v1/driver/trips/${scheduled}/positions`, c.fix(), {
        who: 'driver',
      }),
      409,
    );
    assert.equal(
      (await c.owner.query('SELECT count(*)::int n FROM app.trip_positions')).rows[0].n,
      1,
    );
  }));

test('GPS-02 a device clock is preserved but never believed past the accepted skew', () =>
  withCase(async (c) => {
    const trip = await c.trip('driver');
    // Past the accepted skew the clock is broken, not skewed: nothing it
    // reports can be placed in time, so the fix is refused rather than guessed.
    const future = new Date(Date.now() + 10 * 60_000).toISOString();
    expectStatus(
      await c.request('POST', `/v1/driver/trips/${trip}/positions`, c.fix({ capturedAt: future }), {
        who: 'driver',
      }),
      409,
    );
    // A small lead is clamped too. Believed, it would freeze the marker until
    // the server clock caught up, and every correctly timed fix in between
    // would be refused for the live projection.
    const near = new Date(Date.now() + 110_000).toISOString();
    const ok = expectStatus(
      await c.request('POST', `/v1/driver/trips/${trip}/positions`, c.fix({ capturedAt: near }), {
        who: 'driver',
      }),
      200,
    );
    assert.equal(ok.clockAdjusted, true);
    assert.equal(ok.capturedAt, near, 'the device word is still preserved exactly');
    assert.ok(new Date(ok.effectiveCapturedAt) <= new Date(), 'never believed into the future');
    const corrected = expectStatus(
      await c.request('POST', `/v1/driver/trips/${trip}/positions`, c.fix(), { who: 'driver' }),
      200,
    );
    assert.equal(corrected.acceptedForLive, true, 'the next honest fix still moves the marker');
    // A queue older than the upload window is history, not a live fix.
    expectStatus(
      await c.request(
        'POST',
        `/v1/driver/trips/${trip}/positions`,
        c.fix({ capturedAt: new Date(Date.now() - 25 * 3600_000).toISOString() }),
        { who: 'driver' },
      ),
      409,
    );
  }));

test('GPS-03 a replayed fix is one row, and a late upload cannot move the marker backwards', () =>
  withCase(async (c) => {
    const trip = await c.trip('driver');
    const newest = c.fix({ capturedAt: new Date().toISOString() });
    const first = expectStatus(
      await c.request('POST', `/v1/driver/trips/${trip}/positions`, newest, { who: 'driver' }),
      200,
    );
    assert.equal(first.acceptedForLive, true);
    // The same fix uploaded again is the same row and does not re-advance.
    const again = expectStatus(
      await c.request('POST', `/v1/driver/trips/${trip}/positions`, newest, { who: 'driver' }),
      200,
    );
    assert.equal(again.clientFixId, first.clientFixId);
    assert.equal(again.acceptedForLive, false);
    // An older queued fix is stored but must not become the live marker.
    const stale = expectStatus(
      await c.request(
        'POST',
        `/v1/driver/trips/${trip}/positions`,
        c.fix({
          capturedAt: new Date(Date.now() - 60_000).toISOString(),
          latitude: 1,
          longitude: 1,
        }),
        { who: 'driver' },
      ),
      200,
    );
    assert.equal(stale.acceptedForLive, false);
    const live = (
      await c.owner.query(
        'SELECT effective_captured_at,ST_Y(location) AS lat FROM app.trip_live_positions WHERE trip_id=$1',
        [trip],
      )
    ).rows[0];
    assert.equal(live.lat, 5.6, 'the marker still shows the newest capture, not the late one');
    assert.equal(
      (await c.owner.query('SELECT count(*)::int n FROM app.trip_positions')).rows[0].n,
      2,
      'both distinct fixes are durable even though only one is live',
    );
  }));

test('GPS-04 the live projection refuses a backwards write at the database', () =>
  withCase(async (c) => {
    const trip = await c.trip('driver');
    expectStatus(
      await c.request('POST', `/v1/driver/trips/${trip}/positions`, c.fix(), { who: 'driver' }),
      200,
    );
    await assert.rejects(
      c.owner.query(
        `UPDATE app.trip_live_positions
        SET effective_captured_at=effective_captured_at-interval '1 minute' WHERE trip_id=$1`,
        [trip],
      ),
      /live_position_must_advance/,
      'the guard is in the schema, not only in the handler',
    );
  }));

test('GPS-05 a trace hold is bounded, attributable, and released only under its own token', () =>
  withCase(async (c) => {
    const trip = await c.trip('driver');
    const incident = await c.incidentFor(trip);
    const window = {
      receivedFrom: new Date(Date.now() - 3600_000).toISOString(),
      receivedTo: new Date().toISOString(),
      reviewAt: new Date(Date.now() + 30 * 86400_000).toISOString(),
    };
    const held = expectStatus(
      await c.request('POST', '/v1/ops/trace-holds', {
        incidentId: incident,
        tripId: trip,
        reason: 'Collision under investigation',
        ...window,
      }),
      201,
    );
    assert.partialDeepStrictEqual(held, { state: 'active', tripId: trip, incidentId: incident });
    // An inverted interval is refused rather than retaining nothing silently.
    expectStatus(
      await c.request('POST', '/v1/ops/trace-holds', {
        incidentId: incident,
        tripId: trip,
        reason: 'Backwards',
        receivedFrom: window.receivedTo,
        receivedTo: window.receivedFrom,
        reviewAt: window.reviewAt,
      }),
      400,
    );
    const listed = expectStatus(await c.request('GET', '/v1/ops/trace-holds'), 200);
    assert.equal(listed.length, 1);

    expectStatus(
      await c.request('POST', `/v1/ops/trace-holds/${held.id}/release`, { reason: 'Closed' }),
      428,
    );
    const released = expectStatus(
      await c.request(
        'POST',
        `/v1/ops/trace-holds/${held.id}/release`,
        { reason: 'Investigation closed' },
        { token: held.editToken },
      ),
      200,
    );
    assert.equal(released.state, 'released');
    assert.notEqual(released.editToken, held.editToken);
    // Releasing twice is refused, and the stale token no longer works.
    expectStatus(
      await c.request(
        'POST',
        `/v1/ops/trace-holds/${held.id}/release`,
        { reason: 'Again' },
        { token: held.editToken },
      ),
      412,
    );
    const row = (
      await c.owner.query(
        'SELECT released_by,release_reason,released_at FROM app.trace_holds WHERE id=$1',
        [held.id],
      )
    ).rows[0];
    assert.equal(row.released_by, c.users.admin);
    assert.equal(row.release_reason, 'Investigation closed');
    assert.ok(row.released_at);
    // Both commands are receipt-backed and the runtime cannot rewrite them.
    assert.equal(
      (
        await c.owner.query(
          `SELECT count(*)::int n FROM app.gps_events e
          JOIN app.transport_commands t ON t.id=e.command_id WHERE e.hold_id=$1`,
          [held.id],
        )
      ).rows[0].n,
      2,
    );
    await assert.rejects(
      c.runtime.query('DELETE FROM app.gps_events WHERE hold_id=$1', [held.id]),
      /permission denied/,
    );
  }));

test('GPS-06 learning turns finished runs into median segment speeds, once each', () =>
  withCase(async (c) => {
    const learn = async (limit = 50) =>
      expectStatus(await c.request('POST', '/v1/ops/maintenance/route-learning', { limit }), 200);
    const speeds = async (tripId: string) =>
      (
        await c.owner.query(
          `SELECT s.* FROM app.segment_speeds s
          JOIN app.trips t ON t.pattern_version_id=s.pattern_version_id
          WHERE t.id=$1 ORDER BY s.from_ordinal`,
          [tripId],
        )
      ).rows;

    const brisk = await c.trip('driver', 'completed');
    const start = new Date(Date.now() - 3600_000);
    await c.place(brisk, 0, start);
    // A fix too coarse to place on a road is ignored. Believed, it would put
    // the bus a kilometre ahead in ten seconds and teach a nonsense speed.
    await c.place(brisk, 1000, new Date(start.getTime() + 10_000), { accuracy: 500 });
    await c.place(brisk, 500, new Date(start.getTime() + 100_000), { accuracy: 8 });
    await c.place(brisk, 1200, new Date(start.getTime() + 240_000), { accuracy: 8 });

    assert.partialDeepStrictEqual(await learn(), {
      considered: 1,
      succeeded: 1,
      blocked: 0,
      failed: 0,
      failures: [],
    });
    const first = await speeds(brisk);
    assert.equal(first.length, 1);
    assert.partialDeepStrictEqual(first[0], { from_ordinal: 0, sample_count: 1 });
    assert.ok(Math.abs(first[0].metres_per_second - 5) < 0.2, String(first[0].metres_per_second));

    // The same run is never folded in twice, however often the sweep runs.
    assert.partialDeepStrictEqual(await learn(), { considered: 0, succeeded: 0 });
    assert.equal((await speeds(brisk))[0].sample_count, 1);

    // A run on the same published version contributes one more sample, and the
    // published speed is their median rather than the newest word.
    const slow = await c.trip('driver', 'completed', brisk);
    await c.place(slow, 0, start);
    await c.place(slow, 500, new Date(start.getTime() + 250_000));
    await c.place(slow, 1200, new Date(start.getTime() + 600_000));
    assert.partialDeepStrictEqual(await learn(), { considered: 1, succeeded: 1 });
    const both = await speeds(brisk);
    assert.equal(both[0].sample_count, 2);
    assert.ok(Math.abs(both[0].metres_per_second - 3.5) < 0.2, String(both[0].metres_per_second));

    // A finished run that taught us nothing is still marked, so the sweep
    // drains instead of reconsidering it forever.
    const barren = await c.trip('driver', 'completed');
    assert.partialDeepStrictEqual(await learn(), { considered: 1, succeeded: 0, blocked: 1 });
    assert.partialDeepStrictEqual(await learn(), { considered: 0 });
    assert.equal(
      (
        await c.owner.query('SELECT segments_learned FROM app.trip_learning WHERE trip_id=$1', [
          barren,
        ])
      ).rows[0].segments_learned,
      0,
    );
  }));

test('GPS-07 retention deletes expired traces and keeps exactly what a hold names', () =>
  withCase(async (c) => {
    const purge = async (limit = 50) =>
      expectStatus(await c.request('POST', '/v1/ops/maintenance/gps-retention', { limit }), 200);
    const fixes = async (tripId: string) =>
      (
        await c.owner.query(
          'SELECT received_at FROM app.trip_positions WHERE trip_id=$1 ORDER BY received_at',
          [tripId],
        )
      ).rows.length;
    const marker = async (tripId: string) =>
      (await c.owner.query('SELECT 1 FROM app.trip_live_positions WHERE trip_id=$1', [tripId]))
        .rowCount;

    // The sweep is ops work. A driver holding a valid session cannot start it.
    expectStatus(
      await c.request(
        'POST',
        '/v1/ops/maintenance/gps-retention',
        { limit: 50 },
        { who: 'driver', ops: true },
      ),
      403,
    );

    const day = 86_400_000;
    const old = await c.trip('driver', 'completed');
    const ids: string[] = [];
    for (const [index, days] of [40, 39, 38].entries()) {
      const at = new Date(Date.now() - days * day);
      ids.push(await c.place(old, index * 100, at, { receivedAt: at }));
    }
    await c.owner.query(
      `INSERT INTO app.trip_live_positions(trip_id,position_id,effective_captured_at,received_at,location)
      SELECT trip_id,id,effective_captured_at,received_at,location FROM app.trip_positions WHERE id=$1`,
      [ids[2]],
    );
    // A run inside the window is not the sweep's business.
    const recent = await c.trip('driver', 'completed');
    await c.place(recent, 0, new Date());

    // Recorded while the trace was fresh: the hold names the newest fix only.
    const newest = new Date(Date.now() - 38 * day);
    await c.holdFor(old, new Date(newest.getTime() - 60_000), new Date(newest.getTime() + 60_000));

    assert.partialDeepStrictEqual(await purge(), {
      considered: 1,
      succeeded: 0,
      blocked: 1,
      failed: 0,
      failures: [],
    });
    assert.equal(await fixes(old), 1, 'the hold keeps its own fixes and no others');
    assert.equal(await marker(old), 1, 'the marker points at a fix the hold retains');
    assert.equal(await fixes(recent), 1, 'a trace inside the window is untouched');

    const listed = expectStatus(await c.request('GET', '/v1/ops/trace-holds'), 200)[0];
    expectStatus(
      await c.request(
        'POST',
        `/v1/ops/trace-holds/${listed.id}/release`,
        { reason: 'Investigation closed' },
        { token: listed.editToken },
      ),
      200,
    );
    assert.partialDeepStrictEqual(await purge(), { considered: 1, succeeded: 1, blocked: 0 });
    assert.equal(await fixes(old), 0);
    assert.equal(await marker(old), 0, 'the marker cannot outlive the trace it was drawn from');
    assert.partialDeepStrictEqual(await purge(), { considered: 0 });

    // The deadline is the schema's, not the sweep's: the runtime role cannot
    // delete a fix that has not expired even by going straight at the table.
    await assert.rejects(
      c.runtime.query('DELETE FROM app.trip_positions WHERE trip_id=$1', [recent]),
      /trace_not_expired/,
    );
  }));

test('GPS-08 a hold and the sweep cannot both win: evidence is kept or the hold is refused', () =>
  withCase(async (c) => {
    const day = 86_400_000;
    const trip = await c.trip('driver', 'completed');
    const at = new Date(Date.now() - 40 * day);
    for (const metres of [0, 100, 200]) await c.place(trip, metres, at, { receivedAt: at });

    const blocker = await c.owner.connect();
    let sweep: Promise<unknown> | undefined;
    try {
      await blocker.query('BEGIN');
      await blocker.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
        `trotxi:gps:trace:${trip}`,
      ]);
      sweep = c.request('POST', '/v1/ops/maintenance/gps-retention', { limit: 50 });
      // The sweep has chosen its batch and is waiting for the trip lock.
      await contended(c, 1);
      await blocker.query(
        `INSERT INTO app.trace_holds
          (incident_id,trip_id,received_from,received_to,reason,review_at,created_by)
        VALUES ($1,$2,$3,$4,'Collision under investigation',clock_timestamp()+interval '30 days',$5)`,
        [
          await c.incidentFor(trip),
          trip,
          new Date(at.getTime() - 60_000),
          new Date(at.getTime() + 60_000),
          c.users.admin,
        ],
      );
      await blocker.query('COMMIT');
      assert.partialDeepStrictEqual(expectStatus((await sweep) as never, 200), {
        considered: 1,
        succeeded: 0,
        blocked: 1,
      });
      assert.equal(
        (await c.owner.query('SELECT 1 FROM app.trip_positions WHERE trip_id=$1', [trip])).rowCount,
        3,
        'a hold committed while the sweep was choosing its batch still keeps its evidence',
      );
    } finally {
      await blocker.query('ROLLBACK').catch(() => undefined);
      blocker.release();
      await Promise.allSettled([sweep]);
    }

    // The other half of the protocol: a hold that reaches past the deadline
    // cannot promise evidence the sweep was already entitled to delete.
    const stale = expectStatus(
      await c.request('POST', '/v1/ops/trace-holds', {
        incidentId: await c.incidentFor(trip),
        tripId: trip,
        reason: 'Reported late',
        receivedFrom: new Date(Date.now() - 45 * day).toISOString(),
        receivedTo: new Date().toISOString(),
        reviewAt: new Date(Date.now() + 30 * day).toISOString(),
      }),
      409,
    );
    assert.equal(stale, undefined);
  }));

test('GPS-09 a held trip cannot crowd out traces the sweep could have deleted', () =>
  withCase(async (c) => {
    const day = 86_400_000;
    const at = new Date(Date.now() - 40 * day);
    const remaining = async (tripId: string) =>
      (await c.owner.query('SELECT 1 FROM app.trip_positions WHERE trip_id=$1', [tripId])).rowCount;

    // Ordered so the held trip is the one the sweep would reach first.
    const first = await c.trip('driver', 'completed');
    await c.place(first, 0, at, { receivedAt: at });
    await c.holdFor(first, new Date(at.getTime() - 60_000), new Date(at.getTime() + 60_000));
    const second = await c.trip('driver', 'completed');
    await c.place(second, 0, new Date(at.getTime() + 1000), {
      receivedAt: new Date(at.getTime() + 1000),
    });

    const swept = expectStatus(
      await c.request('POST', '/v1/ops/maintenance/gps-retention', { limit: 1 }),
      200,
    );
    assert.partialDeepStrictEqual(swept, { considered: 1, succeeded: 1 });
    assert.equal(await remaining(second), 0, 'one sweep is enough to reach the unheld trace');
    assert.equal(await remaining(first), 1, 'and the held one is still held');
  }));

test('GPS-10 a run that joined a segment halfway teaches nothing about it', () =>
  withCase(async (c) => {
    const partial = await c.trip('driver', 'completed');
    const start = new Date(Date.now() - 3600_000);
    // Only the last hundred metres of a a thousand-metre segment were seen.
    await c.place(partial, 900, start);
    await c.place(partial, 1200, new Date(start.getTime() + 300_000));
    assert.partialDeepStrictEqual(
      expectStatus(
        await c.request('POST', '/v1/ops/maintenance/route-learning', { limit: 50 }),
        200,
      ),
      { considered: 1, succeeded: 0, blocked: 1, failed: 0 },
    );
    assert.equal(
      (await c.owner.query('SELECT 1 FROM app.segment_samples')).rowCount,
      0,
      '100 metres in 100 seconds is not a thousand-metre segment at 10 m/s',
    );
  }));

test('GPS-11 concurrent learners take turns rather than overwrite the aggregate', () =>
  withCase(async (c) => {
    const trip = await c.trip('driver', 'completed');
    const start = new Date(Date.now() - 3600_000);
    await c.place(trip, 0, start);
    await c.place(trip, 500, new Date(start.getTime() + 100_000));
    await c.place(trip, 1200, new Date(start.getTime() + 240_000));
    const version = (
      await c.owner.query('SELECT pattern_version_id FROM app.trips WHERE id=$1', [trip])
    ).rows[0].pattern_version_id;

    const blocker = await c.owner.connect();
    let sweep: Promise<unknown> | undefined;
    try {
      await blocker.query('BEGIN');
      await blocker.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
        `trotxi:gps:speeds:${version}:morning`,
      ]);
      sweep = c.request('POST', '/v1/ops/maintenance/route-learning', { limit: 50 });
      // The sweep has written its own sample and is waiting to recompute.
      await contended(c, 1);
      await blocker.query(
        `INSERT INTO app.segment_samples
          (pattern_version_id,service_window,from_ordinal,metres_per_second,observed_on)
        VALUES ($1,'morning',0,2,current_date)`,
        [version],
      );
      await blocker.query('COMMIT');
      expectStatus((await sweep) as never, 200);
      const published = (
        await c.owner.query('SELECT * FROM app.segment_speeds WHERE pattern_version_id=$1', [
          version,
        ])
      ).rows[0];
      assert.equal(published.sample_count, 2, 'the median was taken after the other writer landed');
      assert.ok(Math.abs(published.metres_per_second - 3.5) < 0.2, published.metres_per_second);
    } finally {
      await blocker.query('ROLLBACK').catch(() => undefined);
      blocker.release();
      await Promise.allSettled([sweep]);
    }
  }));

test('GPS-12 the runtime cannot rewrite the receipt the deletion guard reads', () =>
  withCase(async (c) => {
    const trip = await c.trip('driver', 'completed');
    const fresh = new Date();
    await c.place(trip, 0, fresh, { receivedAt: fresh });
    const survives = async (why: string) =>
      assert.equal(
        (await c.owner.query('SELECT 1 FROM app.trip_positions WHERE trip_id=$1', [trip])).rowCount,
        1,
        why,
      );

    await assert.rejects(
      c.runtime.query('DELETE FROM app.trip_positions WHERE trip_id=$1', [trip]),
      /trace_not_expired/,
    );
    // Backdating the receipt would expire the fix on demand, and would also
    // move it out of any hold interval naming it.
    await assert.rejects(
      c.runtime.query(
        `UPDATE app.trip_positions SET received_at=clock_timestamp()-interval '40 days'
        WHERE trip_id=$1`,
        [trip],
      ),
      (e: { code?: string }) => e.code === '42501' || /append_only_history/.test(String(e)),
    );
    await survives('a receipt the runtime cannot move is a receipt it cannot delete on');
    // Nor through the projection, which carries no facts of its own.
    await c.owner.query(
      `INSERT INTO app.trip_live_positions(trip_id,position_id,effective_captured_at,received_at,location)
      SELECT trip_id,id,effective_captured_at,received_at,location FROM app.trip_positions WHERE trip_id=$1`,
      [trip],
    );
    await assert.rejects(
      c.runtime.query(
        `UPDATE app.trip_live_positions SET received_at=clock_timestamp()-interval '40 days'
        WHERE trip_id=$1`,
        [trip],
      ),
      /live_position_must_advance/,
    );
    // And the version of that write which would satisfy the advance rule still
    // cannot restate a receipt the trace table refuses to change.
    await assert.rejects(
      c.runtime.query(
        `UPDATE app.trip_live_positions
        SET received_at=clock_timestamp()-interval '40 days',
            effective_captured_at=effective_captured_at+interval '1 second'
        WHERE trip_id=$1`,
        [trip],
      ),
      /live_position_must_match_fix/,
    );
    await assert.rejects(
      c.runtime.query('DELETE FROM app.trip_live_positions WHERE trip_id=$1', [trip]),
      /trace_not_expired/,
    );
    await survives('the fix is still here');
  }));

test('GPS-13 a crossing joins observations the bus made back to back', () =>
  withCase(async (c) => {
    const trip = await c.trip('driver', 'completed');
    const start = new Date(Date.now() - 3600_000);
    const at = (seconds: number) => new Date(start.getTime() + seconds * 1000);
    // Runs on past the boundary, backtracks, then genuinely crosses. The real
    // crossing is between (500m, 200s) and (1100m, 210s): 208.33s, so 4.8 m/s.
    // Pairing the nearest fix on each side by distance would join (900m, 90s)
    // with (1100m, 210s) and invent 6.67 m/s.
    for (const [metres, seconds] of [
      [0, 0],
      [900, 90],
      [500, 200],
      [1100, 210],
    ] as const)
      await c.place(trip, metres, at(seconds));
    expectStatus(await c.request('POST', '/v1/ops/maintenance/route-learning', { limit: 50 }), 200);
    const learned = (await c.owner.query('SELECT metres_per_second FROM app.segment_speeds'))
      .rows[0];
    assert.ok(learned, 'the traversal is real and should teach something');
    assert.ok(
      Math.abs(learned.metres_per_second - 4.8) < 0.05,
      `expected 4.8 m/s, got ${learned.metres_per_second}`,
    );
  }));

test('GPS-14 a clamped capture times the upload, not the bus, so it teaches nothing', () =>
  withCase(async (c) => {
    const trip = await c.trip('driver', 'completed');
    const start = new Date(Date.now() - 3600_000);
    for (const [metres, seconds] of [
      [0, 0],
      [500, 100],
      [1200, 240],
    ] as const)
      await c.place(trip, metres, new Date(start.getTime() + seconds * 1000), { adjusted: true });
    assert.partialDeepStrictEqual(
      expectStatus(
        await c.request('POST', '/v1/ops/maintenance/route-learning', { limit: 50 }),
        200,
      ),
      { considered: 1, succeeded: 0, blocked: 1, failed: 0 },
    );
    assert.equal((await c.owner.query('SELECT 1 FROM app.segment_samples')).rowCount, 0);
  }));

test('GPS-15 one fix identity means one fix', () =>
  withCase(async (c) => {
    const trip = await c.trip('driver');
    const send = (body: Record<string, unknown>) =>
      c.request('POST', `/v1/driver/trips/${trip}/positions`, body, { who: 'driver' });
    const first = c.fix();
    const original = expectStatus(await send(first), 200);
    // The same reading uploaded again is the original receipt, not a new fix.
    const replay = expectStatus(await send(first), 200);
    assert.equal(replay.clientFixId, original.clientFixId);
    assert.equal(replay.receivedAt, original.receivedAt);
    // A different reading wearing that identity is refused, not silently
    // answered with the old one.
    expectStatus(await send({ ...first, latitude: 6.7 }), 409);
    expectStatus(await send({ ...first, accuracyMeters: 12 }), 409);
    const rows = await c.owner.query(
      'SELECT ST_Y(location) AS lat FROM app.trip_positions WHERE trip_id=$1',
      [trip],
    );
    assert.equal(rows.rowCount, 1);
    assert.equal(rows.rows[0].lat, 5.6, 'the stored fix is untouched');
  }));

test('GPS-16 collection is bounded to the run it belongs to', () =>
  withCase(async (c) => {
    const trip = await c.trip('driver');
    const send = (body: Record<string, unknown>) =>
      c.request('POST', `/v1/driver/trips/${trip}/positions`, body, { who: 'driver' });
    expectStatus(await send(c.fix()), 200);
    // A capture from before the wheels turned belongs to some other interval.
    expectStatus(
      await send(c.fix({ capturedAt: new Date(Date.now() - 3 * 3600_000).toISOString() })),
      409,
    );
    // A run left active for over a day is forgotten, not driving.
    const forgotten = await c.trip('driver', 'active', undefined, 25);
    expectStatus(
      await c.request('POST', `/v1/driver/trips/${forgotten}/positions`, c.fix(), {
        who: 'driver',
      }),
      409,
    );
  }));
