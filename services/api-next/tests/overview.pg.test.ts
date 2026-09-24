import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { createHash, randomBytes, randomUUID } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import pg from 'pg';
import { createTransportApp } from '../src/http/app.js';
import { TransportError } from '../src/transport/errors.js';
import { STALE_FIX_AFTER_SECONDS } from '../src/transport/overview.js';
import { grantRuntime, migrate, readMigrations } from '../src/db/migrate.js';

const value = process.env.HARNESS_ADMIN_DATABASE_URL;
if (!value || process.env.HARNESS_ALLOW_CREATE_DATABASES !== '1')
  throw new Error('Disposable PostgreSQL required; overview tests never skip');
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
/** Closed here rather than per test, so a failing assertion still tears down. */
const open: { close(): Promise<unknown> }[] = [];
after(async () => {
  try {
    for (const resource of open) await resource.close().catch(() => {});
    for (const name of owned) await admin.query(`DROP DATABASE "${name}" WITH (FORCE)`);
    for (const role of roles) await admin.query(`DROP ROLE "${role}"`);
  } finally {
    await admin.end();
  }
});

/** The service day the board reads, in the same terms the board uses. */
const today = () => new Date().toISOString().slice(0, 10);

async function setup(options: { staleFixAfterSeconds?: number } = {}) {
  const n = ++serial,
    name = `trotxi_harness_${run}_overview_${n}`,
    role = `trotxi_runtime_overview_${run}_${n}`;
  await admin.query(`CREATE DATABASE "${name}"`);
  owned.push(name);
  const db = new URL(url);
  db.pathname = `/${name}`;
  const owner = new pg.Pool({ connectionString: db.href, max: 5, connectionTimeoutMillis: 3000 });
  await migrate(owner, migrations);
  const users = { admin: randomUUID(), commuter: randomUUID() };
  await owner.query('CREATE TABLE app.test_overview_sessions(user_id uuid PRIMARY KEY)');
  for (const [label, id] of Object.entries(users)) {
    await owner.query('INSERT INTO app.users(id,role) VALUES ($1,$2)', [
      id,
      label === 'admin' ? 'admin' : 'commuter',
    ]);
    await owner.query('INSERT INTO app.test_overview_sessions(user_id) VALUES ($1)', [id]);
  }
  await admin.query(`CREATE ROLE "${role}" LOGIN PASSWORD 'runtime-test-only'`);
  roles.push(role);
  await grantRuntime(owner, role);
  db.username = role;
  db.password = 'runtime-test-only';
  const runtime = new pg.Pool({
    connectionString: db.href,
    max: 8,
    connectionTimeoutMillis: 3000,
  });
  const app = await createTransportApp({
    pool: runtime,
    cursorSecret: Buffer.alloc(32, 9),
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
          await client.query(
            'SELECT 1 FROM app.test_overview_sessions WHERE user_id=$1 FOR SHARE',
            [actor.userId],
          )
        ).rowCount
      )
        throw new TransportError(401, 'unauthenticated', 'Sign in to continue.');
    },
    coordinateReservations: async () => {
      throw new TransportError(503, 'unavailable', 'Not wired in this slice.');
    },
    ...(options.staleFixAfterSeconds === undefined
      ? {}
      : { staleFixAfterSeconds: options.staleFixAfterSeconds }),
  });
  let vehicles = 0;
  open.push(
    { close: () => app.close() },
    { close: () => runtime.end() },
    { close: () => owner.end() },
  );
  const one = async (sql: string, args: unknown[] = []) =>
    (await owner.query(sql + ' RETURNING id', args)).rows[0].id as string;

  /** The smallest published corridor a trip can hang off. */
  const corridor = async (label: string, serviceWindow: 'morning' | 'evening' = 'morning') => {
    const route = await one('INSERT INTO app.routes(name) VALUES ($1)', [label]);
    const pattern = await one(
      "INSERT INTO app.route_patterns(route_id,direction) VALUES ($1,'outbound')",
      [route],
    );
    const version = await one(
      'INSERT INTO app.route_pattern_versions(pattern_id,revision) VALUES ($1,1)',
      [pattern],
    );
    const physical = await one(
      'INSERT INTO app.stops(name,latitude,longitude) VALUES ($1,5.6,-0.2)',
      [label],
    );
    const occurrences: string[] = [];
    for (let ordinal = 0; ordinal < 2; ordinal++)
      occurrences.push(
        await one(
          `INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude)
          VALUES ($1,$2,$3,$4,5.6,-0.2)`,
          [version, physical, ordinal, label],
        ),
      );
    const geometry = await one(
      `INSERT INTO app.route_geometries(pattern_version_id,source,line)
      VALUES ($1,'configured',ST_GeomFromText('LINESTRING(-0.2 5.6,-0.21 5.6,-0.2 5.6)',4326))`,
      [version],
    );
    for (const [index, occurrence] of occurrences.entries())
      await owner.query('INSERT INTO app.geometry_stop_distances VALUES ($1,$2,$3,$4)', [
        geometry,
        version,
        occurrence,
        index * 1000,
      ]);
    await owner.query("UPDATE app.route_geometries SET state='published' WHERE id=$1", [geometry]);
    await owner.query(
      `UPDATE app.route_pattern_versions
      SET state='published',geometry_id=$2,effective_from='2025-01-01' WHERE id=$1`,
      [version, geometry],
    );
    return { routeName: label, pattern, version, serviceWindow };
  };

  /**
   * One departure per run. run_number is pinned to 1 and a departure occurs
   * once per service date, so two runs on one corridor are two departures,
   * which is also what they are in real life.
   */
  let departures = 0;
  const departure = async (line: { pattern: string; version: string; serviceWindow: string }) => {
    const hour = String(6 + (departures % 12)).padStart(2, '0');
    const id = await one('INSERT INTO app.service_departures(pattern_id) VALUES ($1)', [
      line.pattern,
    ]);
    const schedule = await one(
      `INSERT INTO app.service_schedules(departure_id,pattern_id,pattern_version_id,service_window,local_departure,weekdays,effective_from)
      VALUES ($1,$2,$3,$4,$5,ARRAY[1,2,3,4,5,6,7]::smallint[],'2025-01-01')`,
      [id, line.pattern, line.version, line.serviceWindow, `${hour}:${departures++ % 6}0`],
    );
    return { departure: id, schedule, version: line.version };
  };

  const trip = async (
    line: { pattern: string; version: string; serviceWindow: string },
    options: {
      status?: 'scheduled' | 'active';
      driver?: boolean;
      vehicle?: boolean;
      serviceDate?: string;
    } = {},
  ) => {
    const status = options.status ?? 'scheduled';
    const driverId =
      options.driver === false
        ? null
        : await one('INSERT INTO app.drivers(name) VALUES ($1)', [`driver-${randomUUID()}`]);
    const vehicleId =
      options.vehicle === false
        ? null
        : await one('INSERT INTO app.vehicles(label,plate,capacity) VALUES ($1,$2,18)', [
            `bus-${serial}-${vehicles}`,
            `GT-${serial}-${vehicles++}`,
          ]);
    const from = await departure(line);
    // Every trip starts scheduled. The schema refuses one born active, which is
    // the same rule the driver lifecycle enforces, so the fixture follows it
    // rather than reaching around it.
    const id = await one(
      `INSERT INTO app.trips(schedule_id,departure_id,pattern_version_id,service_date,scheduled_at,
        assigned_driver_id,vehicle_id)
      VALUES ($1,$2,$3,$4,now(),$5,$6)`,
      [
        from.schedule,
        from.departure,
        from.version,
        options.serviceDate ?? today(),
        driverId,
        vehicleId,
      ],
    );
    if (status === 'active')
      await owner.query("UPDATE app.trips SET status='active',started_at=now() WHERE id=$1", [id]);
    return id;
  };

  /** A fix that landed `ageSeconds` ago, promoted to the live marker. */
  const fix = async (tripId: string, ageSeconds: number) => {
    const at = new Date(Date.now() - ageSeconds * 1000);
    const positionId = await one(
      `INSERT INTO app.trip_positions(trip_id,client_fix_id,captured_at,effective_captured_at,
        received_at,location,payload_digest)
      VALUES ($1,$2,$3,$3,$3,ST_SetSRID(ST_MakePoint(-0.2,5.6),4326),$4)`,
      [
        tripId,
        randomUUID(),
        at,
        createHash('sha256')
          .update(tripId + ageSeconds)
          .digest('hex'),
      ],
    );
    await owner.query(
      `INSERT INTO app.trip_live_positions(trip_id,position_id,effective_captured_at,received_at,location)
      VALUES ($1,$2,$3,$3,ST_SetSRID(ST_MakePoint(-0.2,5.6),4326))`,
      [tripId, positionId, at],
    );
  };

  const board = (serviceWindow = 'morning', who: keyof typeof users = 'admin', extra = '') =>
    app.inject({
      method: 'GET',
      url: `/v1/ops/overview?window=${serviceWindow}${extra}`,
      headers: {
        authorization: `Bearer ${who}`,
        'x-trotxi-client': 'ops',
        'x-trotxi-build': '2',
      },
    });

  return { owner, runtime, app, corridor, trip, fix, board };
}

test('an empty day is an empty board, not an error', async () => {
  const f = await setup();
  const response = await f.board();
  assert.equal(response.statusCode, 200, response.body);
  const body = response.json().data;
  assert.deepEqual(body.trips, []);
  assert.equal(body.window, 'morning');
  assert.equal(body.staleFixAfterSeconds, STALE_FIX_AFTER_SECONDS);
  assert.ok(Date.parse(body.generatedAt) > 0, 'generatedAt must be an instant');
});

test('a run with no driver or no bus is flagged, not left blank', async () => {
  const f = await setup();
  const line = await f.corridor('Circle - Madina');
  await f.trip(line, { driver: false });
  await f.trip(line, { vehicle: false });
  await f.trip(line);

  const body = (await f.board()).json().data;
  assert.equal(body.trips.length, 3);
  const badges = body.trips.map((t: { badge: string }) => t.badge).sort();
  assert.deepEqual(badges, ['on_time', 'unassigned', 'unassigned']);
  // The console renders Assign in place of an empty cell, so it needs to know
  // which half is missing.
  const noDriver = body.trips.find((t: { driverId: null }) => t.driverId === null);
  assert.equal(noDriver.badge, 'unassigned');
  assert.equal(noDriver.capacity, 18, 'the seat ceiling is still reported');
  const noBus = body.trips.find((t: { vehicleId: null }) => t.vehicleId === null);
  assert.equal(noBus.badge, 'unassigned');
  assert.equal(noBus.capacity, null);
});

test('a running bus that stopped reporting is stale; a fresh one is not', async () => {
  const f = await setup();
  const line = await f.corridor('Kaneshie - Lapaz');
  const quiet = await f.trip(line, { status: 'active' });
  const reporting = await f.trip(line, { status: 'active' });
  const silent = await f.trip(line, { status: 'active' });
  await f.fix(quiet, STALE_FIX_AFTER_SECONDS + 180);
  await f.fix(reporting, 5);

  const body = (await f.board()).json().data;
  const by = new Map(body.trips.map((t: { tripId: string }) => [t.tripId, t]));

  const stale = by.get(quiet) as any;
  assert.equal(stale.badge, 'stale_gps');
  assert.ok(
    stale.fixAgeSeconds >= STALE_FIX_AFTER_SECONDS + 180,
    `age ${stale.fixAgeSeconds} should exceed the threshold`,
  );
  assert.ok(Date.parse(stale.lastFixAt) > 0);
  assert.deepEqual(stale.lastPosition, { latitude: 5.6, longitude: -0.2 });

  const fresh = by.get(reporting) as any;
  assert.equal(fresh.badge, 'on_time');
  assert.ok(fresh.fixAgeSeconds <= STALE_FIX_AFTER_SECONDS);

  // Never reported at all. An age of zero here would read as "just heard from".
  const never = by.get(silent) as any;
  assert.equal(never.badge, 'stale_gps');
  assert.equal(never.lastFixAt, null);
  assert.equal(never.fixAgeSeconds, null);
  assert.equal(never.lastPosition, null);
});

test('the board shows one window and one service day, and states which', async () => {
  const f = await setup();
  const morning = await f.corridor('Morning corridor', 'morning');
  const evening = await f.corridor('Evening corridor', 'evening');
  await f.trip(morning);
  await f.trip(evening);
  // Yesterday's run on today's window must not appear: the board is one day.
  await f.trip(morning, { serviceDate: '2025-01-02' });

  const am = (await f.board('morning')).json().data;
  assert.equal(am.trips.length, 1);
  assert.equal(am.trips[0].routeName, 'Morning corridor');
  assert.equal(am.window, 'morning');

  const pm = (await f.board('evening')).json().data;
  assert.equal(pm.trips.length, 1);
  assert.equal(pm.trips[0].routeName, 'Evening corridor');
  assert.equal(pm.window, 'evening');
});

test('the window is stated by the caller, and the board is admin only', async () => {
  const f = await setup();
  const missing = await f.app.inject({
    method: 'GET',
    url: '/v1/ops/overview',
    headers: { authorization: 'Bearer admin', 'x-trotxi-client': 'ops', 'x-trotxi-build': '2' },
  });
  assert.equal(missing.statusCode, 400, missing.body);

  const guessed = await f.board('midday');
  assert.equal(guessed.statusCode, 400, guessed.body);

  const commuter = await f.board('morning', 'commuter');
  assert.equal(commuter.statusCode, 403, commuter.body);
});

test('the tiles add up to the table under them', async () => {
  const f = await setup();
  const line = await f.corridor('Circle - Madina');
  await f.trip(line, { status: 'active' });
  await f.trip(line, { driver: false, vehicle: false });

  const body = (await f.board()).json().data;
  assert.equal(body.trips.length, 2);
  assert.deepEqual(body.tiles, {
    trips: 2,
    inProgress: 1,
    completed: 0,
    cancelled: 0,
    // The unassigned run has no bus yet, so it adds no seats.
    seatCapacity: 18,
    seatsConfirmed: 0,
    boarded: 0,
    noShows: 0,
    awaitingResolution: 0,
    // Running with no fix at all is the stale case, not the healthy one.
    staleGps: 1,
    unassigned: 1,
  });
  const running = body.trips.find((t: { status: string }) => t.status === 'active');
  assert.match(running.vehiclePlate, /^GT-/, 'the plate identifies the bus, the label may not');
  assert.equal(running.reserved, 0);
});

test('a past day can be reviewed, and the day shown is always stated', async () => {
  const f = await setup();
  const line = await f.corridor('Circle - Madina');
  await f.trip(line, { serviceDate: '2025-01-02' });

  const today = (await f.board()).json().data;
  assert.equal(today.trips.length, 0);
  assert.equal(today.serviceDate, new Date().toISOString().slice(0, 10));

  const past = (await f.board('morning', 'admin', '&date=2025-01-02')).json().data;
  assert.equal(past.trips.length, 1);
  assert.equal(past.serviceDate, '2025-01-02');

  for (const bad of ['2025-02-30', '2025-1-2', 'yesterday']) {
    const response = await f.board('morning', 'admin', `&date=${bad}`);
    assert.equal(response.statusCode, 400, `${bad}: ${response.body}`);
  }
});

test('how quiet a bus can go before it is flagged is configured, not hard-coded', async () => {
  const tight = await setup({ staleFixAfterSeconds: 60 });
  const line = await tight.corridor('Circle - Madina');
  const trip = await tight.trip(line, { status: 'active' });
  await tight.fix(trip, 120);
  const flagged = (await tight.board()).json().data;
  assert.equal(flagged.staleFixAfterSeconds, 60);
  assert.equal(flagged.trips[0].badge, 'stale_gps', 'two minutes is past a one-minute threshold');

  const relaxed = await setup();
  const again = await relaxed.corridor('Circle - Madina');
  const same = await relaxed.trip(again, { status: 'active' });
  await relaxed.fix(same, 120);
  assert.equal((await relaxed.board()).json().data.trips[0].badge, 'on_time');
});
