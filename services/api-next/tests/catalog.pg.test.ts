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
import { grantRuntime, migrate, readMigrations } from '../src/db/migrate.js';

const value = process.env.HARNESS_ADMIN_DATABASE_URL;
if (!value || process.env.HARNESS_ALLOW_CREATE_DATABASES !== '1')
  throw new Error('Disposable PostgreSQL required; catalog tests never skip');
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
        resolve(process.env.REPLACEMENT_EVIDENCE_DIR, 'catalog-metadata.json'),
        JSON.stringify(
          {
            kind: 'catalog-http-postgres-not-baseline-comparison',
            identityBoundary:
              'Identity and revocable opaque credentials are test adapters. CAT-01 creates all transport/catalog data through HTTP; CAT-12 separately inserts two owner-only route timestamp fixtures to prove microsecond pagination.',
            bookingBoundary:
              'Explicit throwing test coordinator. No real reservation implementation claimed.',
            migrations: migrations.map(({ name, sha256 }) => ({ name, sha256 })),
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
const baseDay = Date.parse(new Date().toISOString().slice(0, 10));
const day = (offset: number) => new Date(baseDay + offset * 86400000).toISOString();
type Response = { statusCode: number; body: string; headers: Record<string, unknown>; json(): any };
function expectStatus(response: Response, code: number) {
  assert.equal(response.statusCode, code, response.body);
  return response.json().data;
}
async function setup() {
  const n = ++serial,
    name = `trotxi_harness_${run}_catalog_${n}`,
    role = `trotxi_runtime_cat_${run}_${n}`;
  await admin.query(`CREATE DATABASE "${name}"`);
  owned.push(name);
  const db = new URL(url);
  db.pathname = `/${name}`;
  const owner = new pg.Pool({ connectionString: db.href, max: 5, connectionTimeoutMillis: 3000 });
  let runtime: pg.Pool | undefined;
  try {
    await migrate(owner, migrations);
    const users = {
      admin: randomUUID(),
      other: randomUUID(),
      driver: randomUUID(),
      rider: randomUUID(),
    };
    await owner.query(
      'CREATE TABLE app.test_catalog_sessions(user_id uuid PRIMARY KEY, active boolean NOT NULL DEFAULT true)',
    );
    for (const [label, id] of Object.entries(users)) {
      await owner.query('INSERT INTO app.users(id,role) VALUES ($1,$2)', [
        id,
        label === 'rider' ? 'commuter' : label === 'driver' ? 'driver' : 'admin',
      ]);
      await owner.query('INSERT INTO app.test_catalog_sessions(user_id) VALUES ($1)', [id]);
    }
    await admin.query(`CREATE ROLE "${role}" LOGIN PASSWORD 'runtime-test-only'`);
    roles.push(role);
    await grantRuntime(owner, role);
    db.username = role;
    db.password = 'runtime-test-only';
    const applicationName = `catalog-${run}-${n}`;
    runtime = new pg.Pool({
      connectionString: db.href,
      max: 8,
      connectionTimeoutMillis: 3000,
      application_name: applicationName,
    });
    const app = await createTransportApp({
      pool: runtime,
      cursorSecret: Buffer.alloc(32, 3),
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
              'SELECT 1 FROM app.test_catalog_sessions WHERE user_id=$1 AND active FOR SHARE',
              [actor.userId],
            )
          ).rowCount
        )
          throw new TransportError(401, 'unauthenticated', 'Sign in to continue.');
      },
      coordinateReservations: async () => {
        throw new TransportError(
          503,
          'test_coordinator_unavailable',
          'Explicit test coordinator unavailable.',
        );
      },
    });
    async function request(
      method: 'GET' | 'POST' | 'PATCH',
      path: string,
      body?: unknown,
      options: { token?: string; key?: string; who?: keyof typeof users; public?: boolean } = {},
    ) {
      return app.inject({
        method,
        url: path,
        headers: {
          ...(!options.public ? { authorization: `Bearer ${options.who ?? 'admin'}` } : {}),
          'x-trotxi-client': 'ops',
          'x-trotxi-build': '2',
          ...(method !== 'GET' ? { 'idempotency-key': options.key ?? randomUUID() } : {}),
          ...(options.token ? { 'if-match': options.token } : {}),
          ...(body === undefined ? {} : { 'content-type': 'application/json' }),
        },
        ...(body === undefined ? {} : { payload: JSON.stringify(body) }),
      });
    }
    async function catalog() {
      const route = expectStatus(
        await request('POST', '/v1/ops/routes', { name: 'Circle corridor' }),
        201,
      );
      const physical = expectStatus(
        await request('POST', '/v1/ops/stops', {
          name: 'Depot',
          location: { latitude: 5.6, longitude: -0.2 },
        }),
        201,
      );
      const pattern = expectStatus(
        await request('POST', '/v1/ops/route-patterns', {
          routeId: route.id,
          direction: 'outbound',
        }),
        201,
      );
      const input = {
        stops: [
          {
            stopId: physical.id,
            name: 'Depot outbound',
            location: { latitude: 5.6, longitude: -0.2 },
          },
          {
            stopId: physical.id,
            name: 'Depot return visit',
            location: { latitude: 5.6, longitude: -0.2 },
          },
        ],
        geometry: {
          points: [
            { latitude: 5.6, longitude: -0.2 },
            { latitude: 5.6, longitude: -0.21 },
            { latitude: 5.6, longitude: -0.2 },
          ],
          stopDistancesMeters: [0, 2200],
        },
      };
      const version = expectStatus(
        await request('POST', `/v1/ops/route-patterns/${pattern.id}/versions`, input),
        201,
      );
      return { route, physical, pattern, input, version };
    }
    async function publish(
      c: Awaited<ReturnType<typeof catalog>>,
      from = day(-2),
      version = c.version,
      key = randomUUID(),
    ) {
      return request(
        'POST',
        `/v1/ops/route-patterns/${c.pattern.id}/versions/${version.id}/publish`,
        { reason: 'Test publication', effectiveFrom: from },
        { token: version.editToken, key },
      );
    }
    async function schedule(version: string) {
      return expectStatus(
        await request('POST', '/v1/ops/service-schedules', {
          departure: { kind: 'new' },
          patternVersionId: version,
          serviceWindow: 'morning',
          localDeparture: '06:30',
          timeZone: 'Africa/Accra',
          weekdays: [1, 2, 3, 4, 5, 6, 7],
          effectiveFrom: day(-10).slice(0, 10),
          effectiveTo: null,
        }),
        201,
      );
    }
    return {
      owner,
      runtime,
      app,
      users,
      role,
      applicationName,
      request,
      catalog,
      publish,
      schedule,
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
async function withCase(work: (c: Case) => Promise<void>) {
  const c = await setup();
  try {
    await work(c);
  } finally {
    await c.close();
  }
}
async function accounting(c: Case) {
  return (
    await c.owner.query(`SELECT
    (SELECT count(*)::int FROM app.route_pattern_versions) versions,
    (SELECT count(*)::int FROM app.route_geometries) geometries,
    (SELECT count(*)::int FROM app.route_pattern_stops) occurrences,
    (SELECT count(*)::int FROM app.catalog_events) events,
    (SELECT count(*)::int FROM app.transport_commands) receipts`)
  ).rows[0];
}
async function blocked(c: Case, count: number) {
  const deadline = Date.now() + 2500;
  while (Date.now() < deadline) {
    const rows = (
      await c.owner.query(
        `SELECT pid,pg_blocking_pids(pid) blockers FROM pg_stat_activity
      WHERE application_name=$1 AND state='active' AND cardinality(pg_blocking_pids(pid))>0`,
        [c.applicationName],
      )
    ).rows;
    if (rows.length >= count) {
      evidence.push({ test: 'actual catalog lock contention', connections: rows });
      return rows;
    }
    await delay(10);
  }
  assert.fail('Expected distinct database connections to be observably blocked');
}

test('CAT-01 HTTP creates the entire route -> stops -> loop version -> publication -> schedule -> trip path', () =>
  withCase(async (c) => {
    const f = await c.catalog();
    assert.equal(f.version.revision, 1);
    assert.equal(f.version.state, 'draft');
    assert.equal(f.version.stops[0].stopId, f.version.stops[1].stopId);
    assert.notEqual(f.version.stops[0].id, f.version.stops[1].id);
    assert.deepEqual(
      f.version.stops.map((s: { ordinal: number }) => s.ordinal),
      [0, 1],
    );
    expectStatus(await c.publish(f), 200);
    const list = await c.request('GET', '/v1/routes', undefined, { public: true });
    assert.deepEqual(
      expectStatus(list, 200).map((r: { id: string }) => r.id),
      [f.route.id],
    );
    assert.equal(list.headers['cache-control'], 'no-store');
    assert.equal(
      expectStatus(
        await c.request('GET', `/v1/route-patterns/${f.pattern.id}`, undefined, { public: true }),
        200,
      ).publishedVersionId,
      f.version.id,
    );
    const geometry = expectStatus(
      await c.request('GET', `/v1/route-geometries/${f.version.geometryId}`, undefined, {
        public: true,
      }),
      200,
    );
    assert.equal(geometry.source, 'configured');
    assert.deepEqual(
      geometry.stopDistances.map((d: { stopOccurrenceId: string }) => d.stopOccurrenceId),
      f.version.stops.map((s: { id: string }) => s.id),
    );
    const schedule = await c.schedule(f.version.id);
    assert.equal(
      expectStatus(
        await c.request('GET', `/v1/routes/${f.route.id}/schedules`, undefined, { public: true }),
        200,
      )[0].id,
      schedule.id,
    );
    const trip = expectStatus(
      await c.request('POST', '/v1/ops/trips', {
        scheduleId: schedule.id,
        serviceDate: day(0).slice(0, 10),
        scheduledAt: day(0),
      }),
      201,
    );
    assert.equal(trip.patternVersionId, f.version.id);
    assert.deepEqual(trip.stops, f.version.stops);
    assert.deepEqual(await accounting(c), {
      versions: 1,
      geometries: 1,
      occurrences: 2,
      events: 5,
      receipts: 7,
    });
  }));

test('CAT-14 a configured geometry larger than the default body limit works; oversized drafts are refused', () =>
  withCase(async (c) => {
    const f = await c.catalog();
    const points = Array.from({ length: 6000 }, (_, i) => f.input.geometry.points[i % 3]);
    const body = { ...f.input, geometry: { ...f.input.geometry, points } };
    assert.ok(Buffer.byteLength(JSON.stringify(body)) > 65536);
    const large = expectStatus(
      await c.request('POST', `/v1/ops/route-patterns/${f.pattern.id}/versions`, body),
      201,
    );
    expectStatus(await c.publish(f, day(-2), large), 200);
    assert.equal(
      expectStatus(
        await c.request('GET', `/v1/route-geometries/${large.geometryId}`, undefined, {
          public: true,
        }),
        200,
      ).points.length,
      6000,
    );
    const before = await accounting(c);
    expectStatus(
      await c.request('POST', `/v1/ops/route-patterns/${f.pattern.id}/versions`, {
        ...body,
        geometry: { ...body.geometry, points: Array(10001).fill(points[0]) },
      }),
      400,
    );
    assert.deepEqual(await accounting(c), before);
  }));

test('CAT-15 identical concurrent draft retries serialize and commit one geometry, revision, event and receipt', () =>
  withCase(async (c) => {
    const f = await c.catalog(),
      before = await accounting(c),
      key = randomUUID();
    const lock = await c.owner.connect();
    let jobs: Promise<Response>[] = [];
    try {
      await lock.query('BEGIN');
      await lock.query('SELECT 1 FROM app.route_patterns WHERE id=$1 FOR UPDATE', [f.pattern.id]);
      jobs = [1, 2].map(() =>
        c.request('POST', `/v1/ops/route-patterns/${f.pattern.id}/versions`, f.input, { key }),
      );
      await blocked(c, 2);
      await lock.query('COMMIT');
      const responses = await Promise.all(jobs);
      responses.forEach((r) => expectStatus(r, 201));
      assert.equal(responses[0]!.body, responses[1]!.body);
      assert.deepEqual(await accounting(c), {
        versions: before.versions + 1,
        geometries: before.geometries + 1,
        occurrences: before.occurrences + 2,
        events: before.events + 1,
        receipts: before.receipts + 1,
      });
    } finally {
      await lock.query('ROLLBACK');
      lock.release();
      await Promise.allSettled(jobs);
    }
  }));

test('CAT-02 edit tokens come from lists; missing/stale tokens and missing targets cause zero writes', () =>
  withCase(async (c) => {
    const f = await c.catalog();
    const route = expectStatus(await c.request('GET', '/v1/ops/routes'), 200)[0];
    assert.equal(route.editToken, f.route.editToken);
    const original = await accounting(c);
    expectStatus(await c.request('PATCH', `/v1/ops/routes/${route.id}`, { name: 'Revised' }), 428);
    expectStatus(
      await c.request(
        'PATCH',
        `/v1/ops/routes/${route.id}`,
        { name: 'Revised' },
        { token: 'stale' },
      ),
      412,
    );
    for (const token of [undefined, 'stale']) {
      expectStatus(
        await c.request('PATCH', `/v1/ops/routes/${randomUUID()}`, { name: 'Absent' }, { token }),
        404,
      );
      expectStatus(
        await c.request('PATCH', `/v1/ops/stops/${randomUUID()}`, { name: 'Absent' }, { token }),
        404,
      );
    }
    assert.deepEqual(await accounting(c), original);
    const key = randomUUID();
    const changed = await c.request(
      'PATCH',
      `/v1/ops/routes/${route.id}`,
      { name: 'Revised', description: null },
      { token: route.editToken, key },
    );
    const row = expectStatus(changed, 200);
    assert.equal(row.version, 2);
    assert.equal(row.editToken, changed.headers.etag);
    assert.equal(
      (
        await c.request(
          'PATCH',
          `/v1/ops/routes/${route.id.toUpperCase()}`,
          { name: 'Revised', description: null },
          { token: route.editToken, key },
        )
      ).body,
      changed.body,
    );
    expectStatus(
      await c.request(
        'PATCH',
        `/v1/ops/routes/${route.id}`,
        { name: 'Different' },
        { token: row.editToken, key },
      ),
      409,
    );
    expectStatus(
      await c.request('PATCH', `/v1/ops/routes/${route.id}`, {}, { token: row.editToken }),
      400,
    );
  }));

test('CAT-03 public catalog excludes drafts/archives, nested reads enforce ownership, snapshots never follow physical-stop edits', () =>
  withCase(async (c) => {
    const f = await c.catalog();
    for (const path of [
      `/v1/routes/${f.route.id}`,
      `/v1/route-patterns/${f.pattern.id}`,
      `/v1/route-patterns/${f.pattern.id}/versions/${f.version.id}`,
      `/v1/route-geometries/${f.version.geometryId}`,
    ])
      expectStatus(await c.request('GET', path, undefined, { public: true }), 404);
    assert.deepEqual(
      expectStatus(await c.request('GET', '/v1/routes', undefined, { public: true }), 200),
      [],
    );
    const published = expectStatus(await c.publish(f), 200);
    expectStatus(
      await c.request(
        'PATCH',
        `/v1/ops/stops/${f.physical.id}`,
        { name: 'Edited physical stop', location: { latitude: 5.7, longitude: -0.3 } },
        { token: f.physical.editToken },
      ),
      200,
    );
    const read = expectStatus(
      await c.request(
        'GET',
        `/v1/route-patterns/${f.pattern.id}/versions/${f.version.id}`,
        undefined,
        { public: true },
      ),
      200,
    );
    assert.deepEqual(read, published);
    const other = expectStatus(
      await c.request('POST', '/v1/ops/route-patterns', {
        routeId: f.route.id,
        direction: 'return',
      }),
      201,
    );
    expectStatus(
      await c.request('GET', `/v1/ops/route-patterns/${other.id}/versions/${f.version.id}`),
      404,
    );
    expectStatus(
      await c.request(
        'POST',
        `/v1/ops/route-patterns/${other.id}/versions/${f.version.id}/publish`,
        { effectiveFrom: day(1), reason: '' },
        { token: published.editToken },
      ),
      404,
    );
    expectStatus(
      await c.request(
        'PATCH',
        `/v1/ops/routes/${f.route.id}`,
        { archived: true },
        { token: f.route.editToken },
      ),
      200,
    );
    expectStatus(
      await c.request('GET', `/v1/route-geometries/${f.version.geometryId}`, undefined, {
        public: true,
      }),
      404,
    );
    assert.equal(expectStatus(await c.request('GET', '/v1/ops/routes'), 200)[0].archived, true);
  }));

test('CAT-04 geometry shape, cardinality, order and bounds are enforced with no partial draft or occupied key', () =>
  withCase(async (c) => {
    const f = await c.catalog(),
      original = await accounting(c),
      path = `/v1/ops/route-patterns/${f.pattern.id}/versions`;
    const key = randomUUID();
    for (const geometry of [
      undefined,
      { ...f.input.geometry, stopDistancesMeters: [0] },
      { ...f.input.geometry, stopDistancesMeters: [100, 0] },
      { ...f.input.geometry, stopDistancesMeters: [0, 1000000] },
      {
        points: [f.input.geometry.points[0], f.input.geometry.points[0]],
        stopDistancesMeters: [0, 0],
      },
    ]) {
      expectStatus(await c.request('POST', path, { ...f.input, geometry }, { key }), 400);
      assert.deepEqual(await accounting(c), original);
    }
    const result = expectStatus(await c.request('POST', path, f.input, { key }), 201);
    assert.equal(result.revision, 2);
    expectStatus(
      await c.request(
        'PATCH',
        `/v1/ops/stops/${f.physical.id}`,
        { archived: true },
        { token: f.physical.editToken },
      ),
      200,
    );
    expectStatus(await c.publish(f), 409);
    expectStatus(await c.request('POST', path, f.input), 409);
    assert.equal(
      (
        await c.owner.query('SELECT state FROM app.route_pattern_versions WHERE id=$1', [
          f.version.id,
        ])
      ).rows[0].state,
      'draft',
    );
  }));

test('CAT-05 publication refuses orphaned trips and rolls back prior interval, geometry, event and receipt', () =>
  withCase(async (c) => {
    const f = await c.catalog();
    expectStatus(await c.publish(f), 200);
    const schedule = await c.schedule(f.version.id);
    const trip = expectStatus(
      await c.request('POST', '/v1/ops/trips', {
        scheduleId: schedule.id,
        serviceDate: day(4).slice(0, 10),
        scheduledAt: day(4),
      }),
      201,
    );
    const draft = expectStatus(
      await c.request('POST', `/v1/ops/route-patterns/${f.pattern.id}/versions`, f.input),
      201,
    );
    const original = await accounting(c),
      key = randomUUID();
    const rejected = await c.publish(f, day(2), draft, key);
    expectStatus(rejected, 409);
    assert.equal(rejected.json().error.code, 'reassignment_required');
    assert.deepEqual(await accounting(c), original);
    assert.deepEqual(
      (
        await c.owner.query(
          'SELECT state,effective_to FROM app.route_pattern_versions WHERE id=$1',
          [f.version.id],
        )
      ).rows[0],
      { state: 'published', effective_to: null },
    );
    assert.equal(
      (
        await c.owner.query('SELECT state FROM app.route_geometries WHERE id=$1', [
          draft.geometryId,
        ])
      ).rows[0].state,
      'draft',
    );
    // No coordinator bypass: reschedule is blocked, so move the boundary AFTER
    // the existing departure instead. Failed keys are reusable with corrected input.
    expectStatus(await c.publish(f, day(5), draft, key), 200);
    assert.deepEqual(
      (
        await c.owner.query('SELECT pattern_version_id,scheduled_at FROM app.trips WHERE id=$1', [
          trip.id,
        ])
      ).rows[0],
      { pattern_version_id: f.version.id, scheduled_at: new Date(day(4)) },
    );
  }));

test('CAT-06 replacement publication records both intervals and only switches the public pointer at the effective boundary', () =>
  withCase(async (c) => {
    const f = await c.catalog();
    expectStatus(await c.publish(f, day(-3)), 200);
    const draft = expectStatus(
      await c.request('POST', `/v1/ops/route-patterns/${f.pattern.id}/versions`, f.input),
      201,
    );
    expectStatus(await c.publish(f, day(-1), draft), 200);
    const pointer = expectStatus(
      await c.request('GET', `/v1/route-patterns/${f.pattern.id}`, undefined, { public: true }),
      200,
    );
    assert.equal(pointer.publishedVersionId, draft.id);
    const event = (
      await c.owner.query(
        "SELECT before_state,after_state FROM app.catalog_events WHERE operation='publishPatternVersion' AND pattern_version_id=$1",
        [draft.id],
      )
    ).rows[0];
    assert.equal(event.before_state.previousVersion.effectiveTo, null);
    assert.deepEqual(event.after_state.previousVersion, {
      id: f.version.id,
      state: 'retired',
      effectiveFrom: day(-3),
      effectiveTo: day(-1),
      version: 4,
    });
    const future = expectStatus(
      await c.request('POST', `/v1/ops/route-patterns/${f.pattern.id}/versions`, f.input),
      201,
    );
    expectStatus(await c.publish(f, day(5), future), 200);
    assert.equal(
      expectStatus(
        await c.request('GET', `/v1/route-patterns/${f.pattern.id}`, undefined, { public: true }),
        200,
      ).publishedVersionId,
      draft.id,
    );
    const old = expectStatus(
      await c.request(
        'GET',
        `/v1/route-patterns/${f.pattern.id}/versions/${f.version.id}`,
        undefined,
        { public: true },
      ),
      200,
    );
    assert.equal(old.state, 'retired');
    assert.deepEqual(old.stops, f.version.stops);
  }));

test('CAT-07 a failed audit insert rolls publication back; the same key can succeed after recovery', () =>
  withCase(async (c) => {
    const f = await c.catalog(),
      before = await accounting(c),
      key = randomUUID();
    await c.owner
      .query(`CREATE FUNCTION app.test_fail_catalog() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'injected write failure'; END $$;
    CREATE TRIGGER test_fail_catalog BEFORE INSERT ON app.catalog_events FOR EACH ROW EXECUTE FUNCTION app.test_fail_catalog()`);
    const response = await c.publish(f, day(-2), f.version, key);
    expectStatus(response, 500);
    assert.equal(response.body.includes('injected'), false);
    assert.deepEqual(await accounting(c), before);
    assert.equal(
      (
        await c.owner.query('SELECT state FROM app.route_geometries WHERE id=$1', [
          f.version.geometryId,
        ])
      ).rows[0].state,
      'draft',
    );
    await c.owner.query('DROP TRIGGER test_fail_catalog ON app.catalog_events');
    expectStatus(await c.publish(f, day(-2), f.version, key), 200);
  }));

test('CAT-08 competing publications genuinely contend and cannot open overlapping versions', () =>
  withCase(async (c) => {
    const f = await c.catalog();
    const second = expectStatus(
      await c.request('POST', `/v1/ops/route-patterns/${f.pattern.id}/versions`, f.input),
      201,
    );
    const lock = await c.owner.connect();
    let jobs: ReturnType<Case['publish']>[] = [];
    try {
      await lock.query('BEGIN');
      await lock.query('SELECT 1 FROM app.route_patterns WHERE id=$1 FOR UPDATE', [f.pattern.id]);
      jobs = [c.publish(f), c.publish(f, day(-2), second)];
      await blocked(c, 2);
      await lock.query('COMMIT');
      const responses = await Promise.all(jobs);
      assert.deepEqual(responses.map((r) => r.statusCode).sort(), [200, 409]);
      assert.deepEqual(
        (
          await c.owner.query(
            'SELECT state,count(*)::int n FROM app.route_pattern_versions GROUP BY state ORDER BY state',
          )
        ).rows,
        [
          { state: 'draft', n: 1 },
          { state: 'published', n: 1 },
        ],
      );
      assert.equal(
        (
          await c.owner.query(
            "SELECT count(*)::int n FROM app.catalog_events WHERE operation='publishPatternVersion'",
          )
        ).rows[0].n,
        1,
      );
    } finally {
      await lock.query('ROLLBACK');
      lock.release();
      await Promise.allSettled(jobs);
    }
  }));

test('CAT-09 concurrent publication and trip creation cannot commit an orphaned departure', () =>
  withCase(async (c) => {
    const f = await c.catalog();
    expectStatus(await c.publish(f), 200);
    const schedule = await c.schedule(f.version.id);
    const second = expectStatus(
      await c.request('POST', `/v1/ops/route-patterns/${f.pattern.id}/versions`, f.input),
      201,
    );
    const lock = await c.owner.connect();
    let jobs: Promise<Response>[] = [];
    try {
      await lock.query('BEGIN');
      await lock.query('SELECT 1 FROM app.route_pattern_versions WHERE id=$1 FOR UPDATE', [
        f.version.id,
      ]);
      jobs = [
        c.publish(f, day(2), second),
        c.request('POST', '/v1/ops/trips', {
          scheduleId: schedule.id,
          serviceDate: day(3).slice(0, 10),
          scheduledAt: day(3),
        }),
      ];
      await blocked(c, 2);
      await lock.query('COMMIT');
      const responses = await Promise.all(jobs);
      assert.ok(
        (responses[0]!.statusCode === 200 && responses[1]!.statusCode === 409) ||
          (responses[0]!.statusCode === 409 && responses[1]!.statusCode === 201),
        JSON.stringify(responses.map((r) => [r.statusCode, r.body])),
      );
      assert.equal(
        (
          await c.owner
            .query(`SELECT count(*)::int n FROM app.trips t JOIN app.route_pattern_versions v ON v.id=t.pattern_version_id
      WHERE t.status<>'cancelled' AND (t.scheduled_at<v.effective_from OR t.scheduled_at>=v.effective_to)`)
        ).rows[0].n,
        0,
      );
    } finally {
      await lock.query('ROLLBACK');
      lock.release();
      await Promise.allSettled(jobs);
    }
  }));

test('CAT-10 authorization and session revocation run before catalog replay; public build floors still apply', () =>
  withCase(async (c) => {
    const key = randomUUID(),
      body = { name: 'Replay target' };
    expectStatus(await c.request('POST', '/v1/ops/routes', body, { key }), 201);
    for (const who of ['driver', 'rider'] as const) {
      expectStatus(await c.request('POST', '/v1/ops/routes', body, { who, key }), 403);
      expectStatus(await c.request('GET', '/v1/ops/routes', undefined, { who }), 403);
    }
    await c.owner.query('UPDATE app.test_catalog_sessions SET active=false WHERE user_id=$1', [
      c.users.admin,
    ]);
    expectStatus(await c.request('POST', '/v1/ops/routes', body, { key }), 401);
    await c.owner.query('UPDATE app.test_catalog_sessions SET active=true WHERE user_id=$1', [
      c.users.admin,
    ]);
    await c.owner.query("UPDATE app.users SET role='commuter' WHERE id=$1", [c.users.admin]);
    expectStatus(await c.request('POST', '/v1/ops/routes', body, { key }), 403);
    const headers = { 'x-trotxi-client': 'commuter', 'x-trotxi-platform': 'ios' };
    expectStatus(
      await c.app.inject({ url: '/v1/routes', headers: { ...headers, 'x-trotxi-build': '2' } }),
      426,
    );
    expectStatus(
      await c.app.inject({ url: '/v1/routes', headers: { ...headers, 'x-trotxi-build': '3' } }),
      200,
    );
    expectStatus(await c.app.inject({ url: '/v1/routes' }), 400);
  }));

test('CAT-11 nested publication replay scope includes the version, and retries preserve exactly one audit event', () =>
  withCase(async (c) => {
    const f = await c.catalog(),
      key = randomUUID();
    const first = await c.publish(f, day(-2), f.version, key);
    expectStatus(first, 200);
    const replay = await c.request(
      'POST',
      `/v1/ops/route-patterns/${f.pattern.id.toUpperCase()}/versions/${f.version.id.toUpperCase()}/publish`,
      { reason: 'Test publication', effectiveFrom: day(-2) },
      { token: f.version.editToken, key },
    );
    assert.equal(replay.body, first.body);
    const other = expectStatus(
      await c.request('POST', `/v1/ops/route-patterns/${f.pattern.id}/versions`, f.input),
      201,
    );
    expectStatus(await c.publish(f, day(2), other, key), 200);
    assert.deepEqual(
      (
        await c.owner.query(
          "SELECT target FROM app.transport_commands WHERE operation='publishPatternVersion' ORDER BY created_at",
        )
      ).rows,
      [{ target: `${f.pattern.id}/${f.version.id}` }, { target: `${f.pattern.id}/${other.id}` }],
    );
  }));

test('CAT-12 list cursors preserve microseconds and bind actor, resource and parent; archives cannot strand open trips', () =>
  withCase(async (c) => {
    const f = await c.catalog();
    expectStatus(await c.request('POST', '/v1/ops/routes', { name: 'Second' }), 201);
    // created_at is immutable: seed exact cursor ties on additional owner fixtures.
    await c.owner.query(
      "INSERT INTO app.routes(name,created_at) VALUES ('micro-a','2050-01-01 00:00:00.123456Z'),('micro-b','2050-01-01 00:00:00.123455Z')",
    );
    const first = await c.request('GET', '/v1/ops/routes?limit=1');
    assert.equal(expectStatus(first, 200)[0].name, 'micro-a');
    const cursor = first.json().page.nextCursor;
    assert.equal(
      expectStatus(await c.request('GET', `/v1/ops/routes?limit=1&cursor=${cursor}`), 200)[0].name,
      'micro-b',
    );
    expectStatus(
      await c.request('GET', `/v1/ops/routes?limit=1&cursor=${cursor}`, undefined, {
        who: 'other',
      }),
      400,
    );
    expectStatus(await c.request('GET', `/v1/ops/stops?limit=1&cursor=${cursor}`), 400);
    for (const query of ['limit=201', 'limit=-1', 'unknown=yes'])
      expectStatus(await c.request('GET', `/v1/ops/routes?${query}`), 400);
    expectStatus(
      await c.request('POST', `/v1/ops/route-patterns/${f.pattern.id}/versions`, f.input),
      201,
    );
    const versionPage = await c.request(
      'GET',
      `/v1/ops/route-patterns/${f.pattern.id}/versions?limit=1`,
    );
    expectStatus(versionPage, 200);
    const versionCursor = versionPage.json().page.nextCursor;
    assert.ok(versionCursor);
    const otherPattern = expectStatus(
      await c.request('POST', '/v1/ops/route-patterns', {
        routeId: f.route.id,
        direction: 'return',
      }),
      201,
    );
    expectStatus(
      await c.request(
        'GET',
        `/v1/ops/route-patterns/${otherPattern.id}/versions?limit=1&cursor=${versionCursor}`,
      ),
      400,
    );
    expectStatus(await c.publish(f), 200);
    const schedule = await c.schedule(f.version.id);
    expectStatus(
      await c.request('POST', '/v1/ops/trips', {
        scheduleId: schedule.id,
        serviceDate: day(0).slice(0, 10),
        scheduledAt: day(0),
      }),
      201,
    );
    const current = expectStatus(await c.request('GET', '/v1/ops/routes'), 200).find(
      (r: { id: string }) => r.id === f.route.id,
    );
    const archive = await c.request(
      'PATCH',
      `/v1/ops/routes/${f.route.id}`,
      { archived: true },
      { token: current.editToken },
    );
    expectStatus(archive, 409);
    assert.equal(archive.json().error.code, 'route_has_open_trips');
  }));

test('CAT-13 catalog history is append-only, runtime cannot assume owner, and receipt actors must match at commit', () =>
  withCase(async (c) => {
    const f = await c.catalog();
    assert.equal(
      (await c.owner.query("SELECT pg_has_role($1,current_user,'USAGE') AS elevated", [c.role]))
        .rows[0].elevated,
      false,
    );
    await assert.rejects(
      c.runtime.query("UPDATE app.catalog_events SET reason='tamper'"),
      (e: unknown) => (e as { code: string }).code === '42501',
    );
    await assert.rejects(
      c.owner.query("UPDATE app.catalog_events SET reason='tamper'"),
      /append_only_history/,
    );
    const connection = await c.runtime.connect();
    try {
      await connection.query('BEGIN');
      await connection.query(
        `INSERT INTO app.catalog_events(actor_user_id,command_id,route_id,operation,before_state,after_state)
      VALUES ($1,$2,$3,'updateRoute','{}','{}')`,
        [c.users.admin, randomUUID(), f.route.id],
      );
      await assert.rejects(
        connection.query('COMMIT'),
        (e: unknown) => (e as { code: string }).code === '23503',
      );
    } finally {
      await connection.query('ROLLBACK');
      connection.release();
    }
  }));
