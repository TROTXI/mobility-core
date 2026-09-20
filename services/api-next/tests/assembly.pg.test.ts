import { test } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { createHash, createHmac, randomUUID } from 'node:crypto';
import pg from 'pg';
import { setup } from './helpers/financial-fixture.js';
import contract from '../src/http/contract.json' with { type: 'json' };
import { readConfiguration } from '../src/runtime/config.js';
import { assertRuntimeRole, composeBackend } from '../src/runtime/compose.js';
import { runJob } from '../src/runtime/maintenance.js';
import { jobFailed } from '../src/runtime/job-outcome.js';
import { TransportService } from '../src/transport/service.js';
import type { Backend } from '../src/runtime/compose.js';

const key = (n: number) => Buffer.alloc(32, n).toString('base64');
// Provider-shaped, assembled at runtime rather than committed as a literal, and
// held so the webhook below signs with the same secret the backend was given.
const PAYSTACK_KEY = ['sk', 'test', randomUUID().replaceAll('-', '').slice(0, 18)].join('_');
type Fixture = Awaited<ReturnType<typeof setup>>;

test('ASM-23 retention drains multiple bounded transactions and reports overdue backlog when budget stops it', async (t) => {
  const { f, backend } = await assembled(t);
  const trip = (
    await f.owner.query(
      `INSERT INTO app.trips(schedule_id,pattern_version_id,departure_id,service_date,scheduled_at,status)
    SELECT id,pattern_version_id,departure_id,current_date,clock_timestamp(),'scheduled'
    FROM app.service_schedules WHERE id=$1 RETURNING id`,
      [f.input.legs[0]!.scheduleId],
    )
  ).rows[0].id;
  const seed = () =>
    f.owner.query(
      `INSERT INTO app.trip_positions(trip_id,client_fix_id,captured_at,effective_captured_at,received_at,location,payload_digest)
    SELECT $1,gen_random_uuid(),statement_timestamp()-interval '40 days',statement_timestamp()-interval '40 days',statement_timestamp()-interval '40 days',
      ST_SetSRID(ST_MakePoint(-0.2,5.6),4326),repeat('a',64) FROM generate_series(1,5)`,
      [trip],
    );
  await seed();
  const limited = await runJob(backend, { job: 'gps-retention', limit: 2, maxBatches: 1 });
  assert.equal(limited.retention?.deletableFixes, 3);
  assert.equal(limited.retention?.budgetExhausted, true);
  assert.equal(jobFailed(limited), true, 'overdue deletion must reach the scheduler');
  const drained = await runJob(backend, { job: 'gps-retention', limit: 2, maxBatches: 10 });
  assert.equal(drained.retention?.deletableFixes, 0);
  assert.equal(drained.retention?.batches, 3);
  assert.equal(jobFailed(drained), false);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.trip_positions')).rows[0].n,
    0,
  );
});
function configurationFor(f: Fixture, over: Record<string, string> = {}) {
  return readConfiguration({
    REPLACEMENT_RUNTIME_DATABASE_URL: f.runtimeUrl,
    REPLACEMENT_POOL_SIZE: '6',
    PORT: '10000',
    REPLACEMENT_SERVICE_NAME: 'trotxi-api-next',
    REPLACEMENT_SERVICE_VERSION: '0.1.0',
    REPLACEMENT_GIT_COMMIT: 'assembly-test',
    REPLACEMENT_ACCESS_ISSUER: 'https://api.trotxi.test',
    REPLACEMENT_ACCESS_AUDIENCE: 'trotxi-clients',
    REPLACEMENT_ACCESS_TTL_SECONDS: '900',
    REPLACEMENT_REFRESH_TTL_DAYS: '30',
    REPLACEMENT_SHIFT_TTL_HOURS: '12',
    REPLACEMENT_ACCESS_SECRET: key(1),
    REPLACEMENT_CURSOR_SECRET: key(2),
    REPLACEMENT_PIN_SECRET: key(3),
    REPLACEMENT_CREDENTIAL_REPLAY_KEY: key(4),
    REPLACEMENT_PROVIDER_ENCRYPTION_KEY: key(5),
    REPLACEMENT_BOARDING_PROOF_KEY: key(6),
    REPLACEMENT_DEVICE_KEY: key(7),
    REPLACEMENT_PAYSTACK_EVIDENCE_KEY: key(8),
    REPLACEMENT_GOOGLE_CLIENT_ID: 'example.apps.googleusercontent.com',
    REPLACEMENT_AUTH_PROVIDERS: 'google,apple',
    REPLACEMENT_APPLE_CLIENT_ID: 'com.trotxi.trotxiCommuter',
    REPLACEMENT_APPLE_TEAM_ID: 'TEAMID1234',
    REPLACEMENT_APPLE_KEY_ID: 'KEYID12345',
    REPLACEMENT_APPLE_PRIVATE_KEY: '-----BEGIN PRIVATE KEY-----\nMHc=\n-----END PRIVATE KEY-----',
    REPLACEMENT_PAYSTACK_SECRET_KEY: PAYSTACK_KEY,
    REPLACEMENT_R2_ACCOUNT_ID: 'ff00ff00ff00ff00ff00ff00ff00ff00',
    REPLACEMENT_R2_ACCESS_KEY_ID: 'AKIAEXAMPLE',
    REPLACEMENT_R2_SECRET_ACCESS_KEY: 'secret-access-key',
    REPLACEMENT_R2_BUCKET_NAME: 'trotxi-avatars',
    REPLACEMENT_AVATAR_URL_TTL_SECONDS: '300',
    REPLACEMENT_AVATAR_MAX_BYTES: '2097152',
    REPLACEMENT_MAP_TILES_URL: 'https://tiles.trotxi.test/ghana.pmtiles',
    REPLACEMENT_MAP_STYLE_URL: 'https://tiles.trotxi.test/style.light.json',
    REPLACEMENT_MAP_STYLE_DARK_URL: 'https://tiles.trotxi.test/style.dark.json',
    REPLACEMENT_MAP_ATTRIBUTION: 'Trotxi basemap',
    REPLACEMENT_DOCS_URL: 'https://docs.trotxi.test',
    REPLACEMENT_MINIMUM_BUILD_OPS: '1',
    REPLACEMENT_MINIMUM_BUILD_DRIVER_IOS: '1',
    REPLACEMENT_MINIMUM_BUILD_DRIVER_ANDROID: '1',
    REPLACEMENT_MINIMUM_BUILD_COMMUTER_IOS: '1',
    REPLACEMENT_MINIMUM_BUILD_COMMUTER_ANDROID: '1',
    REPLACEMENT_REQUESTS_PER_MINUTE: '5000',
    REPLACEMENT_REQUESTS_PER_IP_PER_MINUTE: '5000',
    REPLACEMENT_AUTH_REQUESTS_PER_MINUTE: '5000',
    REPLACEMENT_TRUST_PROXY: 'none',
    REPLACEMENT_MAINTENANCE_USER_ID: f.adminId,
    ...over,
  });
}
/** The same session the worker opens: a real row, judged by the real rules. */
async function tokenFor(backend: Backend, userId: string) {
  const session = (
    await backend.pool.query(
      `INSERT INTO app.auth_sessions(user_id,expires_at)
      VALUES ($1, clock_timestamp() + interval '1 hour') RETURNING id,created_at,expires_at`,
      [userId],
    )
  ).rows[0];
  return backend.auth.tokens.sign(
    { userId, sessionId: session.id },
    'admin',
    session.created_at,
    session.expires_at,
  );
}
async function assembled(t: TestContext, over: Record<string, string> = {}) {
  const f = await setup(t);
  const backend = await composeBackend(configurationFor(f, over));
  t.after(() => backend.close());
  const ops = await tokenFor(backend, f.adminId);
  const call = (
    method: 'GET' | 'POST',
    url: string,
    options: {
      payload?: unknown;
      client?: string;
      platform?: string;
      token?: string;
      key?: string;
      match?: string;
    } = {},
  ) =>
    backend.app.inject({
      method,
      url,
      headers: {
        authorization: `Bearer ${options.token ?? ops}`,
        'x-trotxi-client': options.client ?? 'ops',
        'x-trotxi-build': '9',
        ...(options.platform ? { 'x-trotxi-platform': options.platform } : {}),
        ...(method === 'POST' ? { 'idempotency-key': options.key ?? randomUUID() } : {}),
        ...(options.match ? { 'if-match': options.match } : {}),
      },
      ...(options.payload === undefined ? {} : { payload: options.payload as never }),
    });
  return { f, backend, ops, call };
}

test('ASM-EMAIL configured email worker is composed; missing key refuses explicitly', async (t) => {
  const enabled = await assembled(t, { RESEND_API_KEY: 're_fixture_only' });
  assert.ok(enabled.backend.email);
  const result = await runJob(enabled.backend, { job: 'emails', limit: 1 });
  assert.deepEqual(result.body, {
    considered: 0,
    accepted: 0,
    cancelled: 0,
    failed: 0,
    retried: 0,
    unknown: 0,
  });
  assert.equal(jobFailed(result), false);
  const disabled = await assembled(t);
  assert.equal(disabled.backend.email, undefined);
  await assert.rejects(runJob(disabled.backend, { job: 'emails' }), /RESEND_API_KEY is required/);
});

test('ASM-09 the backend refuses a database it could rewrite its own history on', async (t) => {
  const f = await setup(t);
  // The owner installs the schema, so it can create objects and update event
  // tables. A deployment pointed there would work and be quietly unauditable.
  await assert.rejects(
    () => assertRuntimeRole(f.owner),
    /can create objects in the app schema/,
    'the migration owner must not be accepted as a runtime connection',
  );
  // Not the runtime role's privileges: the schema simply is not there.
  const empty = new pg.Pool({ connectionString: process.env.HARNESS_ADMIN_DATABASE_URL, max: 1 });
  t.after(() => empty.end());
  await assert.rejects(() => assertRuntimeRole(empty), /schema is not installed/);
  // And the composed backend runs the same check before it builds anything.
  const owner = configurationFor({ ...f, runtimeUrl: f.ownerUrl } as typeof f);
  await assert.rejects(() => composeBackend(owner), /can create objects in the app schema/);
  await assertRuntimeRole(f.runtime);
});

test('ASM-10 the assembled backend routes every reviewed operation', async (t) => {
  const { backend } = await assembled(t);
  const expected: string[] = [];
  for (const [path, methods] of Object.entries(contract.paths))
    for (const [method, operation] of Object.entries(methods)) {
      expected.push((operation as { operationId: string }).operationId);
      assert.equal(
        backend.app.hasRoute({
          method: method.toUpperCase() as 'GET',
          url: path.replaceAll(/\{([^}]+)\}/g, ':$1'),
        }),
        true,
        `${method.toUpperCase()} ${path} is not routed by the assembled backend`,
      );
    }
  // Every group's dependency is required, so none of them may be absent. A
  // route that is skipped for a missing service would fail the loop above.
  assert.equal(expected.length, 133);
  assert.equal(new Set(expected).size, 133);
});

test('ASM-11 the unauthenticated surface answers, and readiness tells the truth', async (t) => {
  const { f, backend } = await assembled(t);
  const bare = (url: string) => backend.app.inject({ method: 'GET', url });
  assert.deepEqual((await bare('/healthz')).json(), { status: 'ok' });
  assert.deepEqual((await bare('/readyz')).json(), { status: 'ok' });
  const build = (await bare('/version')).json();
  assert.equal(build.service, 'trotxi-api-next');
  assert.equal(build.commit, 'assembly-test');
  const bootstrap = (await bare('/flags')).json();
  assert.equal(bootstrap.mapTiles.url, 'https://tiles.trotxi.test/ghana.pmtiles');
  assert.ok(Array.isArray(bootstrap.flags));
  // Readiness reads a row, so a database this service can no longer read has
  // to change the answer. Liveness is about this process and must not start
  // lying about it, or a rolling deploy replaces a healthy instance with one
  // that cannot serve.
  await f.owner.query(`REVOKE SELECT ON app.users FROM "${f.role}"`);
  const failed = await bare('/readyz');
  assert.equal(failed.statusCode, 503);
  assert.deepEqual(failed.json(), { status: 'unavailable' });
  assert.equal((await bare('/healthz')).statusCode, 200);
  await f.owner.query(`GRANT SELECT ON app.users TO "${f.role}"`);
  assert.equal((await bare('/readyz')).statusCode, 200);
});

test('ASM-12 the worker acts as a real operator and always gives the session back', async (t) => {
  const { f, backend } = await assembled(t);
  const sessions = async () =>
    (
      await f.owner.query(
        'SELECT id,revoked_at FROM app.auth_sessions WHERE user_id=$1 ORDER BY created_at',
        [f.adminId],
      )
    ).rows;
  const before = await sessions();
  const ok = await runJob(backend, { job: 'gps-retention', limit: 10 });
  assert.equal(ok.status, 200, JSON.stringify(ok.body));
  // A job that is refused is reported as a refusal. A worker that exited zero
  // here is how a sweep silently stops running.
  const refused = await runJob(backend, {
    job: 'ask-dispatch',
    travelDate: '2020-01-01',
    direction: 'outbound',
  });
  assert.equal(refused.status, 400, JSON.stringify(refused.body));
  const after = await sessions();
  assert.equal(after.length, before.length + 2, 'each run opens exactly one session');
  for (const session of after.slice(before.length))
    assert.notEqual(session.revoked_at, null, 'the worker session outlived its run');
  // The operations account is checked before a session is minted at all.
  await f.owner.query("UPDATE app.users SET role='commuter' WHERE id=$1", [f.adminId]);
  await assert.rejects(
    () => runJob(backend, { job: 'gps-retention' }),
    /not an operator/,
    'a worker must not run as a user who is not an operator',
  );
  assert.equal((await sessions()).length, after.length);
  await f.owner.query("UPDATE app.users SET role='admin' WHERE id=$1", [f.adminId]);
});

test('ASM-13 the worker client is the maintenance surface and nothing else', async (t) => {
  const { call } = await assembled(t);
  const run = (client: string, platform?: string) =>
    call('POST', '/v1/ops/maintenance/gps-retention', { payload: { limit: 5 }, client, platform });
  assert.equal((await run('worker')).statusCode, 200);
  assert.equal((await run('ops')).statusCode, 200);
  // It carries no app build, so a platform on it is a caller that has not
  // understood what it is.
  assert.equal((await run('worker', 'ios')).statusCode, 400);
  assert.equal((await run('commuter', 'ios')).statusCode, 400);
  // And it is not a general operations credential.
  for (const url of ['/v1/ops/routes', '/v1/ops/trips', '/v1/ops/drivers']) {
    const response = await call('GET', url, { client: 'worker' });
    assert.equal(response.statusCode, 400, `${url} accepted the worker client`);
    assert.equal(response.json().error.code, 'client_metadata_required');
  }
});

test('ASM-14 expired credential ciphertext is physically removed, and only that', async (t) => {
  const { f, backend } = await assembled(t);
  const driverUser = (
    await f.owner.query("INSERT INTO app.users(role) VALUES ('driver') RETURNING id")
  ).rows[0].id;
  const driver = (
    await f.owner.query("INSERT INTO app.drivers(user_id,name) VALUES ($1,'Driver') RETURNING id", [
      driverUser,
    ])
  ).rows[0].id;
  const command = async (id: string, minutesAgo: number) => {
    await f.owner.query(
      `INSERT INTO app.driver_commands(id,actor_user_id,driver_id,operation,target,key_hash,input_hash,
        response_status,response_headers,secret_ciphertext,pin_version,created_at,replay_expires_at)
      VALUES ($1,$2,$3,'issueDriverCredential',$4,$5,repeat('b',64),200,'{}'::jsonb,
        'sealed-pin',1, clock_timestamp() - make_interval(mins => $6),
        clock_timestamp() - make_interval(mins => $6) + interval '1 minute')`,
      [id, f.adminId, driver, driver, createHash('sha256').update(id).digest('hex'), minutesAgo],
    );
    return id;
  };
  const expired = await command(randomUUID(), 30);
  const fresh = await command(randomUUID(), -30);
  const result = await runJob(backend, { job: 'driver-secrets', limit: 50 });
  assert.deepEqual(result.body, { cleared: 1 });
  const rows = await f.owner.query(
    'SELECT id,secret_ciphertext FROM app.driver_commands WHERE id=ANY($1)',
    [[expired, fresh]],
  );
  assert.equal(rows.rows.find((r) => r.id === expired)!.secret_ciphertext, null);
  assert.equal(rows.rows.find((r) => r.id === fresh)!.secret_ciphertext, 'sealed-pin');
  // The receipt itself stays: only the recoverable secret goes.
  assert.equal(rows.rowCount, 2);
  assert.deepEqual((await runJob(backend, { job: 'driver-secrets' })).body, { cleared: 0 });
});

test('ASM-15 outstanding erasure work is retried and never reported as finished', async (t) => {
  const { f, backend } = await assembled(t);
  const user = (await f.owner.query("INSERT INTO app.users(role) VALUES ('commuter') RETURNING id"))
    .rows[0].id;
  // Google issues nothing this can withdraw, and an object key this store did
  // not mint addresses nothing. Both must stay outstanding.
  await f.owner.query(
    `INSERT INTO app.erasure_tasks(user_id,kind,reference)
    VALUES ($1,'provider_revocation',$2),($1,'avatar_object','legacy/not-ours.jpg')`,
    [user, `google:${randomUUID()}:subject-1`],
  );
  const first = await runJob(backend, { job: 'erasures', limit: 10 });
  assert.deepEqual(first.body, { considered: 2, completed: 0, failed: 2 });
  const rows = (
    await f.owner.query(
      'SELECT kind,state,attempts,completed_at,last_failure FROM app.erasure_tasks WHERE user_id=$1 ORDER BY kind',
      [user],
    )
  ).rows;
  assert.deepEqual(
    rows.map((r) => [r.kind, r.state, r.attempts, r.completed_at]),
    [
      ['avatar_object', 'unavailable', 1, null],
      ['provider_revocation', 'unavailable', 1, null],
    ],
  );
  assert.equal(rows[0]!.last_failure, 'Error');
  // A second sweep tries again rather than giving up on them.
  assert.deepEqual((await runJob(backend, { job: 'erasures' })).body, {
    considered: 2,
    completed: 0,
    failed: 2,
  });
  assert.equal(
    (
      await f.owner.query('SELECT max(attempts) AS n FROM app.erasure_tasks WHERE user_id=$1', [
        user,
      ])
    ).rows[0].n,
    2,
  );
});

test('ASM-16 a funded run blocks a future revision until ops explicitly clears it', async (t) => {
  const { f, backend, call } = await assembled(t);
  const id = async (sql: string, args: unknown[] = []) =>
    (await f.owner.query(`${sql} RETURNING id`, args)).rows[0].id as string;
  // A real funded seat on a real run, so the publication below is blocked by
  // something a rider has actually paid for.
  const purchase = await f.buy();
  assert.equal(await f.service.fulfill(f.settle(purchase)), 'fulfilled');
  const period = await f.period(purchase.id);
  const outbound = f.input.legs.find((l) => l.direction === 'outbound')!;
  // A selection is checked as a whole at commit: both legs land together or
  // the pair is not a commute.
  const client = await f.owner.connect();
  let selection: string;
  try {
    await client.query('BEGIN');
    selection = (
      await client.query('INSERT INTO app.commute_selections(route_id) VALUES ($1) RETURNING id', [
        f.input.routeId,
      ])
    ).rows[0].id;
    for (const leg of f.input.legs)
      await client.query(
        `INSERT INTO app.commute_selection_legs(selection_id,direction,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id)
        VALUES ($1,$2,$3,$4,$5,$6)`,
        [
          selection,
          leg.direction,
          leg.scheduleId,
          leg.patternVersionId,
          leg.pickupOccurrenceId,
          leg.dropoffOccurrenceId,
        ],
      );
    await client.query('COMMIT');
  } finally {
    client.release();
  }
  const assignment = await id(
    `INSERT INTO app.commute_assignments(user_id,membership_id,period_id,selection_id,purchase_id,effective_from)
    VALUES ($1,$2,$3,$4,$5,'2026-01-01')`,
    [f.actor.userId, period.membership_id, period.id, selection, purchase.id],
  );
  const vehicle = await id("INSERT INTO app.vehicles(plate,capacity) VALUES ('ASM 16',18)");
  const trip = (
    await f.owner.query(
      `INSERT INTO app.trips(schedule_id,departure_id,pattern_version_id,service_date,scheduled_at,vehicle_id)
      SELECT id,departure_id,pattern_version_id,'2026-01-15'::date,'2026-01-15'::date+local_departure,$2
      FROM app.service_schedules WHERE id=$1 RETURNING *`,
      [outbound.scheduleId, vehicle],
    )
  ).rows[0];
  const reservation = await id(
    `INSERT INTO app.reservations(user_id,period_id,assignment_id,selection_id,direction,service_date,
      trip_id,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id,status,source)
    VALUES ($1,$2,$3,$4,'outbound','2026-01-15',$5,$6,$7,$8,$9,'reserved','confirmation')`,
    [
      f.actor.userId,
      period.id,
      assignment,
      selection,
      trip.id,
      outbound.scheduleId,
      outbound.patternVersionId,
      outbound.pickupOccurrenceId,
      outbound.dropoffOccurrenceId,
    ],
  );
  // A complete next revision of the same corridor, waiting to go live.
  const pattern = (
    await f.owner.query('SELECT pattern_id FROM app.route_pattern_versions WHERE id=$1', [
      outbound.patternVersionId,
    ])
  ).rows[0].pattern_id;
  const draft = await id(
    'INSERT INTO app.route_pattern_versions(pattern_id,revision) VALUES ($1,2)',
    [pattern],
  );
  const stop = await id(
    "INSERT INTO app.stops(name,latitude,longitude) VALUES ('ASM 16 stop',5.6,-0.2)",
  );
  const occurrences: string[] = [];
  for (let ordinal = 0; ordinal < 2; ordinal++)
    occurrences.push(
      await id(
        `INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude)
        VALUES ($1,$2,$3,'ASM 16 stop',5.6,-0.2)`,
        [draft, stop, ordinal],
      ),
    );
  const geometry = await id(
    `INSERT INTO app.route_geometries(pattern_version_id,source,line)
    VALUES ($1,'configured',ST_GeomFromText('LINESTRING(-0.2 5.6,-0.21 5.6,-0.2 5.6)',4326))`,
    [draft],
  );
  for (const [i, occurrence] of occurrences.entries())
    await f.owner.query('INSERT INTO app.geometry_stop_distances VALUES ($1,$2,$3,$4)', [
      geometry,
      draft,
      occurrence,
      i * 1000,
    ]);
  await f.owner.query('UPDATE app.route_pattern_versions SET geometry_id=$2 WHERE id=$1', [
    draft,
    geometry,
  ]);
  const token = async () =>
    `"version:${draft}:${(await f.owner.query('SELECT version FROM app.route_pattern_versions WHERE id=$1', [draft])).rows[0].version}"`;
  const publish = async () =>
    call('POST', `/v1/ops/route-patterns/${pattern}/versions/${draft}/publish`, {
      payload: { reason: 'Corridor revision', effectiveFrom: '2026-01-10T00:00:00Z' },
      match: await token(),
    });
  // Closing the old revision would strand a run that is already sold, so the
  // publication is refused rather than moving anyone silently.
  const blocked = await publish();
  assert.equal(blocked.statusCode, 409, blocked.body);
  assert.equal(blocked.json().error.code, 'reassignment_required');
  assert.equal(
    (
      await f.owner.query('SELECT state,effective_to FROM app.route_pattern_versions WHERE id=$1', [
        outbound.patternVersionId,
      ])
    ).rows[0].state,
    'published',
    'a refused publication must leave the live revision alone',
  );
  // The assembled backend has the reservation coordinator, so ops can make
  // that decision attributably: cancelling the run releases the funded seat.
  const cancelled = await call('POST', `/v1/ops/trips/${trip.id}/cancel`, {
    payload: { reason: 'Corridor revision' },
    match: `"trip:${trip.id}:${trip.version}"`,
  });
  assert.equal(cancelled.statusCode, 200, cancelled.body);
  assert.equal(
    (await f.owner.query('SELECT status FROM app.reservations WHERE id=$1', [reservation])).rows[0]
      .status,
    'operator_cancelled',
  );
  const published = await publish();
  assert.equal(published.statusCode, 200, published.body);
  const versions = (
    await f.owner.query(
      'SELECT id,state,effective_from,effective_to FROM app.route_pattern_versions WHERE id=ANY($1) ORDER BY revision',
      [[outbound.patternVersionId, draft]],
    )
  ).rows;
  assert.deepEqual(
    versions.map((v) => v.state),
    ['retired', 'published'],
  );
  assert.equal(versions[0]!.effective_to.toISOString(), '2026-01-10T00:00:00.000Z');
  assert.equal(versions[1]!.effective_to, null);
});

test('ASM-17 without the composed coordinator that same decision is unavailable', async (t) => {
  const f = await setup(t);
  // The state the design recorded as fail-closed: trip edits that could touch
  // a booking refuse rather than guess. This is the control for ASM-16 — if
  // the assembled backend stopped composing the coordinator, that scenario
  // would land here instead of releasing the seat.
  const uncoordinated = new TransportService({
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 2),
    authorizeSession: f.dependencies.authorizeSession,
  });
  const vehicle = (
    await f.owner.query(
      "INSERT INTO app.vehicles(plate,capacity) VALUES ('ASM 17',18) RETURNING id",
    )
  ).rows[0].id;
  const trip = (
    await f.owner.query(
      `INSERT INTO app.trips(schedule_id,departure_id,pattern_version_id,service_date,scheduled_at,vehicle_id)
      SELECT id,departure_id,pattern_version_id,'2026-01-15'::date,'2026-01-15'::date+local_departure,$2
      FROM app.service_schedules WHERE id=$1 RETURNING *`,
      [f.input.legs.find((l) => l.direction === 'outbound')!.scheduleId, vehicle],
    )
  ).rows[0];
  const admin = { userId: f.adminId, sessionId: f.adminId };
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [f.adminId]);
  await assert.rejects(
    () =>
      uncoordinated.command(
        admin,
        'cancelTrip',
        trip.id,
        { reason: 'Corridor revision' },
        randomUUID(),
        `"trip:${trip.id}:${trip.version}"`,
      ),
    (error: unknown) => {
      const e = error as { status?: number; code?: string };
      assert.equal(e.status, 503);
      assert.equal(e.code, 'reservation_coordinator_unavailable');
      return true;
    },
  );
  assert.equal(
    (await f.owner.query('SELECT status FROM app.trips WHERE id=$1', [trip.id])).rows[0].status,
    'scheduled',
  );
});

test('ASM-18 raising the operations build floor must not switch the sweeps off', async (t) => {
  // The worker carries no app build: there is no release of it to upgrade. If
  // it were held to the console's floor, raising that floor to push an upgrade
  // would silently stop retention, erasure and period close, and the only
  // symptom would be a red cron nobody is watching.
  const { call, backend } = await assembled(t, { REPLACEMENT_MINIMUM_BUILD_OPS: '9999' });
  const refused = await call('GET', '/v1/ops/routes', { client: 'ops' });
  assert.equal(refused.statusCode, 426, refused.body);
  assert.equal(refused.json().error.code, 'client_upgrade_required');
  for (const job of ['gps-retention', 'route-learning', 'payments'] as const) {
    const result = await runJob(backend, { job, limit: 5 });
    assert.equal(result.status, 200, `${job}: ${JSON.stringify(result.body)}`);
  }
  const worker = await call('POST', '/v1/ops/maintenance/gps-retention', {
    payload: { limit: 5 },
    client: 'worker',
  });
  assert.equal(worker.statusCode, 200, worker.body);
});

/** Five requests from one socket, each claiming a different client address. */
async function forwardedBurst(backend: Backend, peer: string) {
  const codes: number[] = [];
  for (let i = 0; i < 5; i++) {
    const response = await backend.app.inject({
      method: 'GET',
      url: '/v1/routes',
      remoteAddress: peer,
      headers: {
        'x-forwarded-for': `198.51.100.${i}`,
        'x-trotxi-client': 'commuter',
        'x-trotxi-build': '9',
        'x-trotxi-platform': 'ios',
      },
    });
    codes.push(response.statusCode);
  }
  return codes;
}

test('ASM-19 an untrusted peer cannot state the address it is limited by', async (t) => {
  // Every per-IP budget buckets on what the server sees. A deployment that has
  // not named its proxy must ignore the header, or a direct caller dodges its
  // own budget by inventing a new address for every request.
  const { backend } = await assembled(t, {
    REPLACEMENT_REQUESTS_PER_IP_PER_MINUTE: '3',
    REPLACEMENT_TRUST_PROXY: 'none',
  });
  const codes = await forwardedBurst(backend, '203.0.113.7');
  assert.equal(
    codes.filter((c) => c === 429).length,
    2,
    `a forged forwarded address bought a fresh budget: ${codes.join(',')}`,
  );
});

test('ASM-19b a named proxy is believed, so riders behind it keep their own budgets', async (t) => {
  // The other half, and the half that catches a value that is validated and
  // then dropped: behind a proxy this deployment has named, each client is
  // limited on its own address rather than all of them sharing the balancer's.
  const { backend } = await assembled(t, {
    REPLACEMENT_REQUESTS_PER_IP_PER_MINUTE: '3',
    REPLACEMENT_TRUST_PROXY: '127.0.0.1',
  });
  const codes = await forwardedBurst(backend, '127.0.0.1');
  assert.deepEqual(
    codes.filter((c) => c === 429),
    [],
    `the configured proxy was not believed: ${codes.join(',')}`,
  );
  // And the peer has to be the one that was named. An unnamed peer stating
  // someone else's address is still limited on its own.
  const stranger = await forwardedBurst(backend, '203.0.113.7');
  assert.equal(
    stranger.filter((c) => c === 429).length,
    2,
    `an unnamed peer was believed: ${stranger.join(',')}`,
  );
});

test('ASM-19c the backend is composed from configuration alone', () => {
  // No adapter parameter exists to pass a recording fake, a permissive session
  // callback or an in-memory object store through. A second required parameter
  // would fail this; an optional one would not, so the rule is also stated in
  // the README and enforced by review.
  assert.equal(composeBackend.length, 1);
});

test('ASM-20 money, coverage and a seat are one flow through the assembled backend', async (t) => {
  const { f, backend, call } = await assembled(t);
  // A committed purchase with its attempt, made by the domain fixture. Opening
  // checkout itself would call the provider, and nothing here talks to a
  // network: the point is what the assembled backend does with the money once
  // the provider says it arrived.
  // Coverage has to span now: the assembled backend closes ended periods on
  // the real clock, and a fixture month starting in January would be over.
  const now = new Date();
  const purchase = await f.buy(randomUUID(), now);
  const attempt = (
    await f.owner.query('SELECT * FROM app.payment_attempts WHERE purchase_id=$1', [purchase.id])
  ).rows[0];
  const body = JSON.stringify({
    event: 'charge.success',
    data: {
      id: '900001',
      reference: attempt.reference,
      status: 'success',
      amount: attempt.amount_pesewas,
      currency: 'GHS',
      domain: 'test',
      channel: 'mobile_money',
      fees: 0,
      paid_at: now.toISOString(),
    },
  });
  const delivered = await backend.app.inject({
    method: 'POST',
    url: '/webhooks/paystack',
    payload: body,
    headers: {
      'content-type': 'application/json',
      'x-paystack-signature': createHmac('sha512', PAYSTACK_KEY).update(body).digest('hex'),
    },
  });
  assert.equal(delivered.statusCode, 200, delivered.body);
  // Nothing is granted by delivery alone: the inbox is durable and the worker
  // owns the effect.
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.billing_periods')).rows[0].n,
    0,
    'coverage was granted before the inbox was worked',
  );
  const worked = await runJob(backend, { job: 'payments', limit: 10 });
  assert.equal(worked.status, 200, JSON.stringify(worked.body));
  // Payments granted coverage; membership materialised the commute the rider
  // paid for. Neither domain was called directly.
  const period = (
    await f.owner.query('SELECT * FROM app.billing_periods WHERE purchase_id=$1', [purchase.id])
  ).rows[0];
  assert.equal(period.state, 'open');
  assert.equal(
    (
      await f.owner.query(
        'SELECT COALESCE(SUM(delta_rides),0)::int AS n FROM app.ride_entries WHERE period_id=$1',
        [period.id],
      )
    ).rows[0].n,
    44,
  );
  const assignment = (
    await f.owner.query('SELECT * FROM app.commute_assignments WHERE period_id=$1', [period.id])
  ).rows[0];
  assert.ok(assignment, 'the paid-for commute was never materialised');
  // The rider reads their own membership through the assembled backend.
  const rider = await tokenFor(backend, f.actor.userId);
  const membership = await call('GET', '/v1/me/membership', {
    token: rider,
    client: 'commuter',
    platform: 'ios',
  });
  assert.equal(membership.statusCode, 200, membership.body);
  const view = membership.json().data;
  assert.equal(view.membership.lifecycle, 'open');
  assert.equal(view.coverage.id, period.id);
  // And takes a seat on a real run, which is transport's row and membership's
  // decision, reached over HTTP with the rider's own session.
  const outbound = f.input.legs.find((l) => l.direction === 'outbound')!;
  const travelDate = new Date(now.getTime() + 86400000).toISOString().slice(0, 10);
  const vehicle = (
    await f.owner.query(
      "INSERT INTO app.vehicles(plate,capacity) VALUES ('ASM 20',18) RETURNING id",
    )
  ).rows[0].id;
  await f.owner.query(
    `INSERT INTO app.trips(schedule_id,departure_id,pattern_version_id,service_date,scheduled_at,vehicle_id)
    SELECT id,departure_id,pattern_version_id,$2::date,$2::date+local_departure,$3
    FROM app.service_schedules WHERE id=$1`,
    [outbound.scheduleId, travelDate, vehicle],
  );
  const confirmed = await call('POST', '/v1/me/reservation-decisions', {
    token: rider,
    client: 'commuter',
    platform: 'ios',
    payload: { travelDate, direction: 'outbound', decision: 'confirm' },
  });
  assert.equal(confirmed.statusCode, 200, confirmed.body);
  const reservation = (
    await f.owner.query('SELECT * FROM app.reservations WHERE period_id=$1', [period.id])
  ).rows[0];
  assert.equal(reservation.status, 'reserved');
  // Coverage the rider has paid for is not closed early. The batch does not
  // consider this period at all, which is the honest thing to assert here: the
  // seat does not block a close that was never attempted.
  //
  // That an unsettled funded seat blocks the close of the period funding it is
  // proven where it can be driven deterministically, by the preservation
  // harness at PAY-09, which fails if the refusal is reclassified.
  const close = await runJob(backend, { job: 'payments', limit: 10 });
  assert.equal(close.status, 200, JSON.stringify(close.body));
  const batch = (close.body as { data?: Record<string, unknown> }).data ?? close.body;
  assert.deepEqual(
    (batch as { periods: unknown }).periods,
    { considered: 0, succeeded: 0, blocked: 0, failed: 0, failures: [] },
    `a period whose coverage has not ended was considered for close: ${JSON.stringify(close.body)}`,
  );
  assert.equal(
    (await f.owner.query('SELECT state FROM app.billing_periods WHERE id=$1', [period.id])).rows[0]
      .state,
    'open',
  );
});

test('ASM-21 a provider this deployment does not have has no route at all', async (t) => {
  // With an Apple Developer account the deployment offers Apple and every
  // reviewed operation is routed, which ASM-10 checks. Without one, the
  // difference has to be visible in the surface rather than in a 503 a rider
  // meets after choosing the button.
  const { backend, call } = await assembled(t, { REPLACEMENT_AUTH_PROVIDERS: 'google' });
  assert.equal(backend.app.hasRoute({ method: 'POST', url: '/v1/auth/google' }), true);
  assert.equal(backend.app.hasRoute({ method: 'POST', url: '/v1/auth/apple' }), false);
  const gone = await backend.app.inject({
    method: 'POST',
    url: '/v1/auth/apple',
    payload: { idToken: 'irrelevant' },
    headers: { 'x-trotxi-client': 'commuter', 'x-trotxi-build': '9', 'x-trotxi-platform': 'ios' },
  });
  assert.equal(gone.statusCode, 404, gone.body);
  assert.equal(gone.json().error.code, 'not_found');
  // Everything else is still there: dropping a provider drops one route.
  let routed = 0;
  for (const [path, methods] of Object.entries(contract.paths))
    for (const [method, operation] of Object.entries(methods))
      if (
        backend.app.hasRoute({
          method: method.toUpperCase() as 'GET',
          url: path.replaceAll(/\{([^}]+)\}/g, ':$1'),
        })
      ) {
        routed += 1;
        assert.notEqual((operation as { operationId: string }).operationId, 'signInApple');
      }
  assert.equal(routed, 132);
  const docs = (await backend.app.inject({ method: 'GET', url: '/docs/json' })).json();
  assert.equal(docs.paths['/v1/auth/apple'], undefined);
  assert.ok(docs.paths['/v1/auth/google']);
  assert.equal(
    Object.values(docs.paths).flatMap((methods) => Object.values(methods as object)).length,
    routed,
  );
  void call;
});

test('ASM-22 two instances share one budget, and a closed window is the worker to clear', async (t) => {
  // The whole point of the shared counter: a budget kept in one process's
  // memory is a different budget in the next process, so scaling to two
  // instances quietly doubles what every rider is allowed.
  const f = await setup(t);
  const configuration = configurationFor(f, { REPLACEMENT_REQUESTS_PER_MINUTE: '4' });
  const first = await composeBackend(configuration);
  t.after(() => first.close());
  const second = await composeBackend(configuration);
  t.after(() => second.close());
  const rider = await tokenFor(first, f.actor.userId);
  const ask = (backend: Backend) =>
    backend.app.inject({
      method: 'GET',
      url: '/v1/me/membership',
      headers: {
        authorization: `Bearer ${rider}`,
        'x-trotxi-client': 'commuter',
        'x-trotxi-build': '9',
        'x-trotxi-platform': 'ios',
      },
    });
  // Two each, alternating. A per-process budget of four would admit all four
  // and then four more; one shared budget of four admits exactly four.
  // The limiter uses fixed database-clock windows. A minute rollover between
  // calls legitimately resets the budget: collect six in one observed window
  // instead of assuming this test always starts far enough from its boundary.
  // Bound the attempts; a slow/inconclusive run must fail, never pass vacuously.
  let window: number | undefined;
  const codes: number[] = [];
  for (let i = 0; i < 18 && codes.length < 6; i++) {
    const response = await ask(i % 2 ? second : first);
    const row = (
      await f.owner.query(
        'SELECT window_started_at,count FROM app.admission_counters WHERE subject=$1',
        [f.actor.userId],
      )
    ).rows[0];
    assert.ok(row, 'admission must write the shared counter');
    const observed = row.window_started_at.getTime();
    if (observed !== window) {
      window = observed;
      codes.length = 0;
    }
    codes.push(response.statusCode);
    assert.equal(Number(row.count), codes.length, 'both instances count into this same window');
  }
  assert.equal(codes.length, 6, 'six alternating requests must share an observed window');
  assert.deepEqual(codes, [200, 200, 200, 200, 429, 429]);
  assert.equal(
    codes.filter((c) => c === 429).length,
    2,
    `the second instance did not share the first's budget: ${codes.join(',')}`,
  );
  const counter = (
    await f.owner.query('SELECT subject,count FROM app.admission_counters WHERE subject=$1', [
      f.actor.userId,
    ])
  ).rows[0];
  assert.equal(Number(counter.count), 6, 'both instances counted into one row');
  // A live window is a rider's spent budget: clearing it would hand them a
  // fresh one, so the guard refuses and the sweep leaves it alone.
  assert.equal(await first.admission.sweep(100), 0);
  await assert.rejects(
    () => f.runtime.query('DELETE FROM app.admission_counters WHERE subject=$1', [f.actor.userId]),
    /admission_window_live/,
  );
  await f.owner.query(
    "UPDATE app.admission_counters SET window_started_at=clock_timestamp()-interval '5 minutes' WHERE subject=$1",
    [f.actor.userId],
  );
  assert.equal(await first.admission.sweep(100), 1);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.admission_counters')).rows[0].n,
    0,
  );
});
