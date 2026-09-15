import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
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
// 014 waits outside the installer until 013 lands, so the suite applies the
// reviewed chain and then the draft, exactly as it will run once renamed.
const draft = await readFile(
  fileURLToPath(new URL('../schema-drafts/014_gps_and_learning.sql', import.meta.url)),
  'utf8',
);
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
  await owner.query(draft);
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
  const runtime = new pg.Pool({ connectionString: db.href, max: 8, connectionTimeoutMillis: 3000 });
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
  const trip = async (label: 'driver' | 'other', status = 'active', sameRunAs?: string) => {
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
      return drive(reused, status);
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
    return drive(id, status);
  };
  /** Drive a scheduled trip into the state the case needs. */
  const drive = async (id: string, status: string) => {
    if (status === 'active')
      await owner.query(
        "UPDATE app.trips SET status='active',started_at=clock_timestamp() WHERE id=$1",
        [id],
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
    extra: { accuracy?: number; receivedAt?: Date } = {},
  ) =>
    (
      await owner.query(
        `INSERT INTO app.trip_positions
          (trip_id,client_fix_id,captured_at,effective_captured_at,received_at,accuracy_meters,location)
        SELECT $1,gen_random_uuid(),$2,$2,$3,$4,
          ST_LineInterpolatePoint(g.line,LEAST(1,$5::float8/ST_Length(g.line::geography)))
        FROM app.trips t
        JOIN app.route_pattern_versions v ON v.id=t.pattern_version_id
        JOIN app.route_geometries g ON g.id=v.geometry_id
        WHERE t.id=$1 RETURNING id`,
        [tripId, at, extra.receivedAt ?? at, extra.accuracy ?? null, metres],
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
  return {
    owner,
    runtime,
    users,
    request,
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
    const future = new Date(Date.now() + 10 * 60_000).toISOString();
    const ahead = expectStatus(
      await c.request('POST', `/v1/driver/trips/${trip}/positions`, c.fix({ capturedAt: future }), {
        who: 'driver',
      }),
      200,
    );
    assert.equal(ahead.clockAdjusted, true);
    assert.equal(ahead.capturedAt, future, 'the device word is preserved exactly');
    assert.ok(
      new Date(ahead.effectiveCapturedAt) < new Date(future),
      'the believed time is pulled back, never pushed forward',
    );
    // A capture inside the allowance is believed as reported.
    const near = new Date(Date.now() + 30_000).toISOString();
    const ok = expectStatus(
      await c.request('POST', `/v1/driver/trips/${trip}/positions`, c.fix({ capturedAt: near }), {
        who: 'driver',
      }),
      200,
    );
    assert.equal(ok.clockAdjusted, false);
    assert.equal(ok.effectiveCapturedAt, ok.capturedAt);
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
    await c.place(brisk, 1000, new Date(start.getTime() + 200_000), { accuracy: 8 });

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
    await c.place(slow, 1000, new Date(start.getTime() + 500_000));
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

test('GPS-07 retention redacts past the deadline, keeps exactly what a hold names', () =>
  withCase(async (c) => {
    const purge = async () =>
      expectStatus(
        await c.request('POST', '/v1/ops/maintenance/gps-retention', { limit: 50 }),
        200,
      );
    const trace = async (tripId: string) =>
      (
        await c.owner.query(
          `SELECT received_at,redacted_at,location IS NULL AS gone FROM app.trip_positions
          WHERE trip_id=$1 ORDER BY received_at`,
          [tripId],
        )
      ).rows;
    const live = async (tripId: string) =>
      (
        await c.owner.query(
          'SELECT redacted_at,location IS NULL AS gone FROM app.trip_live_positions WHERE trip_id=$1',
          [tripId],
        )
      ).rows[0];

    // The sweep is ops work. A driver holding a valid session cannot start it.
    expectStatus(
      await c.request(
        'POST',
        '/v1/ops/maintenance/gps-retention',
        { limit: 50 },
        {
          who: 'driver',
          ops: true,
        },
      ),
      403,
    );

    const old = await c.trip('driver', 'completed');
    const day = 86_400_000;
    const stale = [40, 39, 38].map((days) => new Date(Date.now() - days * day)) as [
      Date,
      Date,
      Date,
    ];
    const ids: string[] = [];
    for (const [index, at] of stale.entries())
      ids.push(await c.place(old, index * 100, at, { receivedAt: at }));
    const newest = ids[2]!;
    await c.owner.query(
      `INSERT INTO app.trip_live_positions(trip_id,position_id,effective_captured_at,received_at,location)
      SELECT trip_id,id,effective_captured_at,received_at,location FROM app.trip_positions WHERE id=$1`,
      [newest],
    );
    // A run inside the window is not the purge's business.
    const recent = await c.trip('driver', 'completed');
    await c.place(recent, 0, new Date());

    // The hold names the newest fix only, by receipt window and one trip.
    const incident = await c.incidentFor(old);
    const held = expectStatus(
      await c.request('POST', '/v1/ops/trace-holds', {
        incidentId: incident,
        tripId: old,
        reason: 'Collision under investigation',
        receivedFrom: new Date(stale[2].getTime() - 60_000).toISOString(),
        receivedTo: new Date(stale[2].getTime() + 60_000).toISOString(),
        reviewAt: new Date(Date.now() + 30 * day).toISOString(),
      }),
      201,
    );

    assert.partialDeepStrictEqual(await purge(), {
      considered: 1,
      succeeded: 0,
      blocked: 1,
      failed: 0,
      failures: [],
    });
    const after = await trace(old);
    assert.deepEqual(
      after.map((r) => r.gone),
      [true, true, false],
      'the hold keeps the fixes inside its window and no others',
    );
    assert.ok(after[0].redacted_at instanceof Date);
    // The marker still points at a fix the hold retains, so it survives too.
    assert.equal((await live(old)).gone, false);
    assert.equal((await trace(recent))[0].gone, false, 'a trace inside the window is untouched');

    expectStatus(
      await c.request(
        'POST',
        `/v1/ops/trace-holds/${held.id}/release`,
        { reason: 'Closed' },
        {
          token: held.editToken,
        },
      ),
      200,
    );
    assert.partialDeepStrictEqual(await purge(), { considered: 1, succeeded: 1, blocked: 0 });
    assert.deepEqual(
      (await trace(old)).map((r) => r.gone),
      [true, true, true],
    );
    assert.equal(
      (await live(old)).gone,
      true,
      'the map cannot outlive the trace it was drawn from',
    );
    // Nothing is deleted: the fix, its trip and its timings remain.
    assert.equal((await trace(old)).length, 3);
    assert.partialDeepStrictEqual(await purge(), { considered: 0 });
  }));

test('GPS-08 a run still reporting after its trace was purged gets its marker back', () =>
  withCase(async (c) => {
    const stuck = await c.trip('driver');
    const long = new Date(Date.now() - 40 * 86_400_000);
    const first = await c.place(stuck, 0, long, { receivedAt: long });
    await c.owner.query(
      `INSERT INTO app.trip_live_positions(trip_id,position_id,effective_captured_at,received_at,location)
      SELECT trip_id,id,effective_captured_at,received_at,location FROM app.trip_positions WHERE id=$1`,
      [first],
    );
    assert.partialDeepStrictEqual(
      expectStatus(
        await c.request('POST', '/v1/ops/maintenance/gps-retention', { limit: 50 }),
        200,
      ),
      { considered: 1, succeeded: 1 },
    );
    const redacted = await c.owner.query(
      'SELECT redacted_at FROM app.trip_live_positions WHERE trip_id=$1',
      [stuck],
    );
    assert.ok(redacted.rows[0].redacted_at instanceof Date);

    const fresh = expectStatus(
      await c.request('POST', `/v1/driver/trips/${stuck}/positions`, c.fix(), { who: 'driver' }),
      200,
    );
    assert.equal(fresh.acceptedForLive, true);
    const back = await c.owner.query(
      'SELECT redacted_at,location IS NULL AS gone FROM app.trip_live_positions WHERE trip_id=$1',
      [stuck],
    );
    assert.deepEqual(back.rows[0], { redacted_at: null, gone: false });
  }));
