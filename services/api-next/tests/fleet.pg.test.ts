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
  throw new Error('Disposable PostgreSQL required; fleet tests never skip');
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

type Response = { statusCode: number; body: string; headers: Record<string, unknown>; json(): any };
function expectStatus(response: Response, code: number) {
  assert.equal(response.statusCode, code, response.body);
  return response.json().data;
}

async function setup() {
  const n = ++serial,
    name = `trotxi_harness_${run}_fleet_${n}`,
    role = `trotxi_runtime_flt_${run}_${n}`;
  await admin.query(`CREATE DATABASE "${name}"`);
  owned.push(name);
  const db = new URL(url);
  db.pathname = `/${name}`;
  const owner = new pg.Pool({ connectionString: db.href, max: 5, connectionTimeoutMillis: 3000 });
  await migrate(owner, migrations);
  const users = { admin: randomUUID(), driver: randomUUID(), rider: randomUUID() };
  await owner.query(
    'CREATE TABLE app.test_fleet_sessions(user_id uuid PRIMARY KEY, active boolean NOT NULL DEFAULT true)',
  );
  for (const [label, id] of Object.entries(users)) {
    await owner.query('INSERT INTO app.users(id,role) VALUES ($1,$2)', [
      id,
      label === 'rider' ? 'commuter' : label === 'driver' ? 'driver' : 'admin',
    ]);
    await owner.query('INSERT INTO app.test_fleet_sessions(user_id) VALUES ($1)', [id]);
  }
  await owner.query('INSERT INTO app.drivers(user_id,name) VALUES ($1,$2)', [
    users.driver,
    'Kojo Mensah',
  ]);
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
    cursorSecret: Buffer.alloc(32, 5),
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
            'SELECT 1 FROM app.test_fleet_sessions WHERE user_id=$1 AND active FOR SHARE',
            [actor.userId],
          )
        ).rowCount
      )
        throw new TransportError(401, 'unauthenticated', 'Sign in to continue.');
    },
    coordinateReservations: async () => {
      throw new TransportError(503, 'test_coordinator_unavailable', 'Not wired in this slice.');
    },
  });
  async function request(
    method: 'GET' | 'POST' | 'PATCH',
    path: string,
    body?: unknown,
    options: { token?: string; key?: string; who?: keyof typeof users; anonymous?: boolean } = {},
  ) {
    return app.inject({
      method,
      url: path,
      headers: {
        ...(options.anonymous ? {} : { authorization: `Bearer ${options.who ?? 'admin'}` }),
        'x-trotxi-client': 'ops',
        'x-trotxi-build': '2',
        ...(method !== 'GET' ? { 'idempotency-key': options.key ?? randomUUID() } : {}),
        ...(options.token ? { 'if-match': options.token } : {}),
        ...(body === undefined ? {} : { 'content-type': 'application/json' }),
      },
      ...(body === undefined ? {} : { payload: JSON.stringify(body) }),
    }) as Promise<Response>;
  }
  const body = (plate: string, extra: Record<string, unknown> = {}) => ({
    plate,
    label: null,
    make: null,
    colour: null,
    capacity: 18,
    ...extra,
  });
  const vehicle = async (plate: string, extra: Record<string, unknown> = {}) =>
    expectStatus(await request('POST', '/v1/ops/vehicles', body(plate, extra)), 201);
  return {
    owner,
    runtime,
    users,
    request,
    body,
    vehicle,
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

test('FLT-01 fleet lifecycle: create, list with edit tokens, and edit only under If-Match', () =>
  withCase(async (c) => {
    const created = await c.vehicle('GT 1234-20', {
      label: 'Bus 1',
      make: 'Toyota',
      colour: 'White',
    });
    assert.partialDeepStrictEqual(created, {
      plate: 'GT 1234-20',
      label: 'Bus 1',
      make: 'Toyota',
      colour: 'White',
      capacity: 18,
      archived: false,
    });
    const listed = expectStatus(await c.request('GET', '/v1/ops/vehicles'), 200);
    assert.equal(listed.length, 1);
    assert.equal(listed[0].editToken, created.editToken);

    expectStatus(await c.request('PATCH', `/v1/ops/vehicles/${created.id}`, { capacity: 22 }), 428);
    expectStatus(
      await c.request(
        'PATCH',
        `/v1/ops/vehicles/${created.id}`,
        { capacity: 22 },
        { token: '"vehicle:x:1"' },
      ),
      412,
    );
    const edited = expectStatus(
      await c.request(
        'PATCH',
        `/v1/ops/vehicles/${created.id}`,
        { capacity: 22, colour: null },
        { token: created.editToken },
      ),
      200,
    );
    assert.equal(edited.capacity, 22);
    assert.equal(edited.colour, null);
    assert.notEqual(edited.editToken, created.editToken);
    // An empty patch is refused rather than issuing SET with no assignments.
    expectStatus(
      await c.request('PATCH', `/v1/ops/vehicles/${created.id}`, {}, { token: edited.editToken }),
      400,
    );
  }));

test('FLT-02 plate spelling is not identity: normalized on write, one replay scope on retry', () =>
  withCase(async (c) => {
    const key = randomUUID();
    const first = expectStatus(
      await c.request('POST', '/v1/ops/vehicles', c.body(' gt  1234-20 '), { key }),
      201,
    );
    assert.equal(first.plate, 'GT 1234-20');
    const replay = expectStatus(
      await c.request('POST', '/v1/ops/vehicles', c.body('GT 1234-20'), { key }),
      201,
    );
    assert.equal(replay.id, first.id);
    assert.equal(
      (await c.owner.query('SELECT count(*)::int n FROM app.vehicles')).rows[0].n,
      1,
      'a differently spelled retry must not mint a second bus',
    );
    // A genuinely different payload under the same key is a conflict, not a
    // silent second execution and not the first response returned wrongly.
    expectStatus(await c.request('POST', '/v1/ops/vehicles', c.body('GT 9999-20'), { key }), 409);
  }));

test('FLT-03 one live plate at a time; archived vehicles keep theirs for trip history', () =>
  withCase(async (c) => {
    const first = await c.vehicle('GT 1234-20');
    expectStatus(
      await c.request('POST', '/v1/ops/vehicles', c.body('gt 1234-20', { capacity: 14 })),
      409,
    );
    expectStatus(
      await c.request(
        'PATCH',
        `/v1/ops/vehicles/${first.id}`,
        { archived: true },
        { token: first.editToken },
      ),
      200,
    );
    const replacement = await c.vehicle('GT 1234-20', { capacity: 14 });
    assert.notEqual(replacement.id, first.id);
    assert.deepEqual(
      (await c.owner.query('SELECT plate FROM app.vehicles ORDER BY created_at')).rows.map(
        (r) => r.plate,
      ),
      ['GT 1234-20', 'GT 1234-20'],
    );
  }));

test('FLT-04 a vehicle carrying a scheduled run cannot be archived and leaves no partial write', () =>
  withCase(async (c) => {
    const bus = await c.vehicle('GT 9999-20');
    // Minimal operated history, built directly so this test exercises the
    // archival guard rather than the route-publication contract.
    const today = new Date().toISOString().slice(0, 10);
    const route = (
      await c.owner.query("INSERT INTO app.routes(name) VALUES ('Madina corridor') RETURNING id")
    ).rows[0].id;
    const pattern = (
      await c.owner.query(
        "INSERT INTO app.route_patterns(route_id,direction) VALUES ($1,'outbound') RETURNING id",
        [route],
      )
    ).rows[0].id;
    const stop = (
      await c.owner.query(
        "INSERT INTO app.stops(name,latitude,longitude) VALUES ('Depot',5.6,-0.2) RETURNING id",
      )
    ).rows[0].id;
    // Draft first: publishing is guarded until the version carries a complete
    // geometry and one distance per stop occurrence.
    const version = (
      await c.owner.query(
        'INSERT INTO app.route_pattern_versions(pattern_id,revision) VALUES ($1,1) RETURNING id',
        [pattern],
      )
    ).rows[0].id;
    const occurrences: string[] = [];
    for (const ordinal of [0, 1])
      occurrences.push(
        (
          await c.owner.query(
            `INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude)
            VALUES ($1,$2,$3,'Depot',5.6,-0.2) RETURNING id`,
            [version, stop, ordinal],
          )
        ).rows[0].id,
      );
    const geometry = (
      await c.owner.query(
        `INSERT INTO app.route_geometries(pattern_version_id,source,state,line)
        VALUES ($1,'configured','draft',
          ST_SetSRID(ST_MakeLine(ARRAY[ST_MakePoint(-0.2,5.6),ST_MakePoint(-0.21,5.61)]),4326))
        RETURNING id`,
        [version],
      )
    ).rows[0].id;
    for (const [index, occurrence] of occurrences.entries())
      await c.owner.query(
        `INSERT INTO app.geometry_stop_distances(geometry_id,pattern_version_id,stop_occurrence_id,distance_meters)
        VALUES ($1,$2,$3,$4)`,
        [geometry, version, occurrence, index],
      );
    // Publish the geometry only once its complete ordered distance set exists.
    await c.owner.query("UPDATE app.route_geometries SET state='published' WHERE id=$1", [
      geometry,
    ]);
    await c.owner.query(
      `UPDATE app.route_pattern_versions
      SET geometry_id=$2,state='published',effective_from=clock_timestamp()-interval '1 day'
      WHERE id=$1`,
      [version, geometry],
    );
    const departure = (
      await c.owner.query(
        'INSERT INTO app.service_departures(pattern_id) VALUES ($1) RETURNING id',
        [pattern],
      )
    ).rows[0].id;
    const schedule = (
      await c.owner.query(
        `INSERT INTO app.service_schedules(pattern_version_id,pattern_id,departure_id,service_window,
          local_departure,weekdays,effective_from)
        VALUES ($1,$2,$3,'morning','06:30',ARRAY[1,2,3,4,5,6,7]::smallint[],$4::date) RETURNING id`,
        [version, pattern, departure, today],
      )
    ).rows[0].id;
    await c.owner.query(
      `INSERT INTO app.trips(schedule_id,pattern_version_id,departure_id,service_date,
        scheduled_at,vehicle_id,status)
      VALUES ($1,$2,$3,$4::date,clock_timestamp(),$5,'scheduled')`,
      [schedule, version, departure, today, bus.id],
    );

    const blocked = await c.request(
      'PATCH',
      `/v1/ops/vehicles/${bus.id}`,
      { archived: true, capacity: 40 },
      { token: bus.editToken },
    );
    assert.equal(blocked.statusCode, 409, blocked.body);
    assert.equal(blocked.json().error, 'vehicle_has_open_trips');
    const row = (
      await c.owner.query('SELECT archived_at,capacity,version FROM app.vehicles WHERE id=$1', [
        bus.id,
      ])
    ).rows[0];
    assert.deepEqual(
      { archived_at: row.archived_at, capacity: row.capacity, version: row.version },
      { archived_at: null, capacity: 18, version: 1 },
      'a refused archive must not leave the accompanying capacity edit applied',
    );
    assert.equal(
      (
        await c.owner.query(
          "SELECT count(*)::int n FROM app.transport_commands WHERE operation='updateVehicle'",
        )
      ).rows[0].n,
      0,
      'a failed command leaves no receipt, so the same key can be retried',
    );
  }));

test('FLT-05 fleet commands are receipt-backed events the runtime role cannot rewrite', () =>
  withCase(async (c) => {
    const bus = await c.vehicle('GT 4321-20');
    const events = (
      await c.owner.query(
        `SELECT e.vehicle_id,e.operation,e.actor_user_id,t.operation AS receipt
        FROM app.fleet_events e JOIN app.transport_commands t ON t.id=e.command_id
        WHERE e.vehicle_id=$1`,
        [bus.id],
      )
    ).rows;
    assert.equal(events.length, 1);
    assert.partialDeepStrictEqual(events[0], {
      vehicle_id: bus.id,
      operation: 'createVehicle',
      actor_user_id: c.users.admin,
      receipt: 'createVehicle',
    });
    // Two independent layers. The runtime role never holds UPDATE or DELETE, so
    // it is refused on privilege before any trigger runs; the append-only
    // trigger then also refuses the owner, which does hold them.
    const update = "UPDATE app.fleet_events SET operation='updateVehicle' WHERE vehicle_id=$1";
    const remove = 'DELETE FROM app.fleet_events WHERE vehicle_id=$1';
    for (const sql of [update, remove]) {
      await assert.rejects(c.runtime.query(sql, [bus.id]), /permission denied/);
      await assert.rejects(c.owner.query(sql, [bus.id]), /append_only_history/);
    }
    assert.equal(
      (await c.owner.query('SELECT count(*)::int n FROM app.fleet_events')).rows[0].n,
      1,
    );
  }));

test('FLT-06 fleet operations are admin-only and require a live session', () =>
  withCase(async (c) => {
    for (const who of ['driver', 'rider'] as const) {
      expectStatus(await c.request('POST', '/v1/ops/vehicles', c.body('GT 1111-20'), { who }), 403);
      expectStatus(await c.request('GET', '/v1/ops/vehicles', undefined, { who }), 403);
    }
    expectStatus(
      await c.request('POST', '/v1/ops/vehicles', c.body('GT 1111-20'), { anonymous: true }),
      401,
    );
    // A revoked session fails even with a structurally valid token.
    await c.owner.query('UPDATE app.test_fleet_sessions SET active=false WHERE user_id=$1', [
      c.users.admin,
    ]);
    expectStatus(await c.request('GET', '/v1/ops/vehicles'), 401);
    assert.equal((await c.owner.query('SELECT count(*)::int n FROM app.vehicles')).rows[0].n, 0);
  }));

test('FLT-07 incident and request tables enforce their shape before any endpoint exposes them', () =>
  withCase(async (c) => {
    const driver = (await c.owner.query('SELECT id FROM app.drivers LIMIT 1')).rows[0].id;
    const insertIncident = (columns: string, values: unknown[]) =>
      c.owner.query(
        `INSERT INTO app.driver_incidents(driver_id,category,${columns}) VALUES ($1,'vehicle',${values
          .map((_, i) => `$${i + 2}`)
          .join(',')})`,
        [driver, ...values],
      );
    // A yard report carries no trip: that must be accepted, not refused.
    await insertIncident('note', ['Brake warning light in the yard']);
    // Half a position locates nothing.
    await assert.rejects(insertIncident('latitude', [5.6]), /incident_position_is_whole/);
    await insertIncident('latitude,longitude', [5.6, -0.2]);
    // A decision without its actor or resolution is not attributable.
    await assert.rejects(
      insertIncident('status,resolution', ['resolved', 'Towed']),
      /incident_decision_is_attributable/,
    );

    const request = (columns: string, values: unknown[]) =>
      c.owner.query(
        `INSERT INTO app.driver_requests(driver_id,${columns}) VALUES ($1,${values
          .map((_, i) => `$${i + 2}`)
          .join(',')})`,
        [driver, ...values],
      );
    const route = expectStatus(
      await c.request('POST', '/v1/ops/routes', { name: 'Adenta corridor' }),
      201,
    );
    // Each kind carries the fields it means and no others.
    await assert.rejects(request('kind,route_id', ['leave', route.id]), /driver_request_shape/);
    await assert.rejects(request('kind', ['route_change']), /driver_request_shape/);
    await assert.rejects(
      request('kind,from_date,to_date', ['leave', '2026-10-05', '2026-10-01']),
      /driver_request_dates/,
    );
    await request('kind,route_id', ['route_change', route.id]);
    // One open ask per driver keeps the ops queue a decision list, not a pile.
    await assert.rejects(
      request('kind,route_id', ['route_change', route.id]),
      /driver_requests_one_open/,
    );
    await assert.rejects(
      request('kind,route_id,status', ['route_change', route.id, 'approved']),
      /driver_request_decision_is_attributable/,
    );
  }));
