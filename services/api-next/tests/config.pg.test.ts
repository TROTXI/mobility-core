import { test } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { setup } from './helpers/financial-fixture.js';
import { ConfigService } from '../src/config/service.js';
import { MembershipService } from '../src/membership/service.js';
import { createTransportApp } from '../src/http/app.js';

type Response = { statusCode: number; body: string; json(): any };
function expectStatus(response: Response, code: number) {
  assert.equal(response.statusCode, code, response.body);
  const body = response.json();
  return 'data' in body ? body.data : body;
}

async function fixture(t: TestContext) {
  const f = await setup(t);
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [f.adminId]);
  const admin = { userId: f.adminId, sessionId: f.adminId };
  const config = new ConfigService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    build: { service: 'trotxi-api-next', version: '0.0.0-test', commit: 'abcdef0' },
    cursorSecret: Buffer.alloc(32, 17),
    mapTiles: {
      url: 'https://tiles.example/{z}/{x}/{y}.png',
      styleUrl: 'https://tiles.example/style.json',
      darkStyleUrl: null,
      attribution: 'Tiles by Example',
    },
    support: {
      phone: '+233200000000',
      whatsapp: null,
      email: 'ops@example.com',
      hours: '06:00-20:00',
    },
    fallbackBuilds: { driver: { ios: 3, android: 3 }, commuter: { ios: 2, android: 2 } },
  });
  const membership = new MembershipService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 17),
  });
  const app = await createTransportApp({
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 17),
    authorizeSession: f.dependencies.authorizeSession,
    coordinateReservations: membership.coordinateReservations,
    membership,
    config,
    verifyAccess: async (header) =>
      ({ 'Bearer rider': f.actor, 'Bearer ops': admin })[header as string] ?? null,
    minimumBuilds: { ops: 1, driver: { ios: 3, android: 3 }, commuter: { ios: 2, android: 2 } },
  });
  t.after(() => app.close());
  const call = (
    method: 'GET' | 'PUT' | 'PATCH',
    url: string,
    options: {
      who?: 'rider' | 'ops' | 'none';
      client?: string;
      build?: string;
      platform?: string;
      payload?: unknown;
      key?: string;
      match?: string;
    } = {},
  ) => {
    const who = options.who ?? 'ops';
    const client = options.client ?? (who === 'ops' ? 'ops' : 'commuter');
    return app.inject({
      method,
      url,
      headers: {
        ...(who === 'none' ? {} : { authorization: `Bearer ${who}` }),
        ...(options.client === '' ? {} : { 'x-trotxi-client': client }),
        ...(options.build === '' ? {} : { 'x-trotxi-build': options.build ?? '9' }),
        ...(client === 'ops' || options.platform === ''
          ? {}
          : { 'x-trotxi-platform': options.platform ?? 'android' }),
        ...(method === 'GET' ? {} : { 'idempotency-key': options.key ?? randomUUID() }),
        ...(options.match ? { 'if-match': options.match } : {}),
      },
      ...(options.payload === undefined ? {} : { payload: options.payload as never }),
    }) as Promise<Response>;
  };
  const bare = (url: string) => app.inject({ method: 'GET', url }) as Promise<Response>;
  return { ...f, admin, app, config, call, bare };
}

test('CFG-01 the unauthenticated endpoints answer without any client metadata', async (t) => {
  const f = await fixture(t);
  assert.deepEqual(expectStatus(await f.bare('/healthz'), 200), { status: 'ok' });
  assert.deepEqual(expectStatus(await f.bare('/'), 200), { docs: '/docs', health: '/healthz' });
  assert.partialDeepStrictEqual(expectStatus(await f.bare('/version'), 200), {
    service: 'trotxi-api-next',
    commit: 'abcdef0',
  });
  assert.deepEqual(expectStatus(await f.bare('/readyz'), 200), { status: 'ok' });
});

test('CFG-02 start-up tells a client what it needs and nothing private', async (t) => {
  const f = await fixture(t);
  const boot = expectStatus(await f.bare('/flags'), 200);
  assert.deepEqual(boot.mapTiles, {
    url: 'https://tiles.example/{z}/{x}/{y}.png',
    styleUrl: 'https://tiles.example/style.json',
    darkStyleUrl: null,
    attribution: 'Tiles by Example',
  });
  assert.equal(boot.operations.email, 'ops@example.com');
  assert.ok(new Date(boot.serverTime).getTime() > 0);
  assert.deepEqual(
    boot.applications.map((a: any) => [a.app, a.platform, a.minSupportedBuild, a.storeUrl]),
    [
      ['commuter', 'ios', 2, null],
      ['commuter', 'android', 2, null],
      ['driver', 'ios', 3, null],
      ['driver', 'android', 3, null],
    ],
    'an unconfigured floor is the one the deployment was composed with',
  );
  assert.deepEqual(boot.flags, [], 'no flags are published until ops sets one');
});

test('CFG-03 a stored build floor governs admission, not a constructor value', async (t) => {
  const f = await fixture(t);
  // Build 9 clears the composed floor of 2.
  assert.equal(
    (await f.call('GET', '/v1/me/membership', { who: 'rider', build: '9' })).statusCode,
    200,
  );

  const raised = expectStatus(
    await f.call('PUT', '/v1/ops/min-versions/commuter/android', {
      payload: { minSupportedBuild: 50, apiMajor: 1, storeUrl: 'https://play.example/app' },
      match: '*',
    }),
    200,
  );
  assert.partialDeepStrictEqual(raised, {
    app: 'commuter',
    platform: 'android',
    minSupportedBuild: 50,
  });

  const refused = await f.call('GET', '/v1/me/membership', { who: 'rider', build: '9' });
  assert.equal(refused.statusCode, 426, refused.body);
  assert.equal(refused.json().error.code, 'client_upgrade_required');
  assert.equal(
    (await f.call('GET', '/v1/me/membership', { who: 'rider', build: '50' })).statusCode,
    200,
    'and a build at the new floor is admitted',
  );
  // The other platform is untouched, so the floor is per app and platform.
  assert.equal(
    (await f.call('GET', '/v1/me/membership', { who: 'rider', build: '9', platform: 'ios' }))
      .statusCode,
    200,
  );
  const boot = expectStatus(await f.bare('/flags'), 200);
  assert.partialDeepStrictEqual(
    boot.applications.find((a: any) => a.app === 'commuter' && a.platform === 'android'),
    { minSupportedBuild: 50, storeUrl: 'https://play.example/app' },
  );
});

test('CFG-04 flags are published as definitions for the client to decide', async (t) => {
  const f = await fixture(t);
  expectStatus(
    await f.call('PUT', '/v1/ops/flags/commute.transfers', {
      payload: { enabled: true, rolloutPercentage: 100, description: 'Everyone' },
      match: '*',
    }),
    200,
  );
  expectStatus(
    await f.call('PUT', '/v1/ops/flags/map.live', {
      payload: { enabled: false, rolloutPercentage: 100, description: 'Off for now' },
      match: '*',
    }),
    200,
  );
  assert.deepEqual(
    expectStatus(await f.bare('/flags'), 200).flags,
    [
      { key: 'commute.transfers', enabled: true, rolloutPercentage: 100 },
      { key: 'map.live', enabled: false, rolloutPercentage: 100 },
    ],
    'the reviewed schema carries the rollout to the client, so the client buckets',
  );
  assert.equal(
    JSON.stringify(expectStatus(await f.bare('/flags'), 200).flags).includes('description'),
    false,
    'and the ops description is not part of what a client is told',
  );

  // Editing one needs the token the ops list hands out.
  assert.equal(
    (
      await f.call('PUT', '/v1/ops/flags/map.live', {
        payload: { enabled: true, rolloutPercentage: 50, description: 'Half' },
        match: '*',
      })
    ).statusCode,
    412,
    'a flag that exists cannot be overwritten blind',
  );
  const current = expectStatus(await f.call('GET', '/v1/ops/flags'), 200).find(
    (x: any) => x.key === 'map.live',
  );
  const edited = expectStatus(
    await f.call('PUT', '/v1/ops/flags/map.live', {
      payload: { enabled: true, rolloutPercentage: 50, description: 'Half' },
      match: `"flag:map.live:${current.version}"`,
    }),
    200,
  );
  assert.equal(edited.version, current.version + 1);
  assert.equal(
    expectStatus(await f.bare('/flags'), 200).flags.find((x: any) => x.key === 'map.live')
      .rolloutPercentage,
    50,
  );
});

test('CFG-05 configuration is ops work, attributable and replayable', async (t) => {
  const f = await fixture(t);
  assert.equal(
    (
      await f.call('PUT', '/v1/ops/flags/x.y', {
        who: 'rider',
        client: 'ops',
        payload: { enabled: true, rolloutPercentage: 0, description: 'nope' },
        match: '*',
      })
    ).statusCode,
    403,
    'a rider cannot configure the service',
  );
  assert.equal(
    (
      await f.call('PUT', '/v1/ops/flags/x.y', {
        payload: { enabled: true, rolloutPercentage: 0, description: 'no token' },
      })
    ).statusCode,
    428,
  );
  const key = randomUUID();
  const payload = { enabled: true, rolloutPercentage: 25, description: 'Replay me' };
  const first = expectStatus(
    await f.call('PUT', '/v1/ops/flags/x.y', { payload, match: '*', key }),
    200,
  );
  const replay = expectStatus(
    await f.call('PUT', '/v1/ops/flags/x.y', { payload, match: '*', key }),
    200,
  );
  assert.equal(replay.version, first.version, 'a replay does not bump the flag again');
  assert.equal(
    (
      await f.call('PUT', '/v1/ops/flags/x.y', {
        payload: { ...payload, rolloutPercentage: 30 },
        match: '*',
        key,
      })
    ).statusCode,
    409,
  );
  const events = (
    await f.owner.query(
      'SELECT action,target,reason,before_state,after_state FROM app.config_events',
    )
  ).rows;
  assert.equal(events.length, 1);
  assert.partialDeepStrictEqual(events[0], { action: 'setFlag', target: 'x.y', reason: null });
  assert.deepEqual(events[0].before_state, {});
  assert.equal(events[0].after_state.rolloutPercentage, 25);
});

test('CFG-06 a role change is attributable and never strands the service without an admin', async (t) => {
  const f = await fixture(t);
  const token = (id: string) =>
    f.owner
      .query('SELECT version FROM app.users WHERE id=$1', [id])
      .then((r) => `"user:${id}:${r.rows[0].version}"`);

  assert.equal(
    (
      await f.call('PATCH', `/v1/ops/users/${f.actor.userId}/role`, {
        payload: { role: 'driver' },
        match: '*',
      })
    ).statusCode,
    400,
    'a role change states its reason',
  );
  // The record comes first: a driver role with no driver record is a role
  // authorization refuses, which locks the account out of everything.
  await f.owner.query("INSERT INTO app.drivers(user_id,name) VALUES ($1,'Ama')", [f.actor.userId]);
  const promoted = expectStatus(
    await f.call('PATCH', `/v1/ops/users/${f.actor.userId}/role`, {
      payload: { role: 'driver', reason: 'Joined the fleet' },
      match: await token(f.actor.userId),
    }),
    200,
  );
  assert.equal(promoted.role, 'driver');
  assert.equal(
    (
      await f.call('PATCH', `/v1/ops/users/${f.actor.userId}/role`, {
        payload: { role: 'commuter', reason: 'Stale token' },
        match: '"user:' + f.actor.userId + ':1"',
      })
    ).statusCode,
    412,
  );
  const event = (
    await f.owner.query(
      "SELECT reason,before_state,after_state FROM app.config_events WHERE action='changeRole'",
    )
  ).rows[0];
  assert.equal(event.reason, 'Joined the fleet');
  assert.deepEqual([event.before_state.role, event.after_state.role], ['commuter', 'driver']);

  // A closed account cannot be given a role.
  await f.owner.query('UPDATE app.users SET deleted_at=clock_timestamp() WHERE id=$1', [
    f.other.userId,
  ]);
  await assert.rejects(
    f.owner.query("UPDATE app.users SET role='driver' WHERE id=$1", [f.other.userId]),
    /role_change_requires_open_account/,
  );
});

test('CFG-07 readiness fails closed when the database is gone', async (t) => {
  const f = await fixture(t);
  const broken = new ConfigService({
    pool: {
      connect: async () => {
        throw new Error('down');
      },
    } as never,
    authorizeSession: f.dependencies.authorizeSession,
    build: { service: 's', version: 'v', commit: 'c' },
    cursorSecret: Buffer.alloc(32, 17),
    mapTiles: { url: null, styleUrl: null, darkStyleUrl: null, attribution: 'none' },
    fallbackBuilds: { driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
  });
  const out = await broken.readiness();
  assert.equal(out.status, 503);
  assert.deepEqual(out.body, { status: 'unavailable' });
  assert.equal(broken.health().status, 200, 'liveness still answers for the process');
});

test('CFG-08 two administrators creating the same floor do not both win', async (t) => {
  const f = await fixture(t);
  const builds = [500, 400, 300, 200, 100, 2];
  const outcomes = await Promise.all(
    builds.map((minSupportedBuild) =>
      f.call('PUT', '/v1/ops/min-versions/commuter/android', {
        payload: { minSupportedBuild, apiMajor: 1, storeUrl: 'https://play.example/app' },
        match: '*',
      }),
    ),
  );
  const created = outcomes.filter((r) => r.statusCode === 200);
  assert.equal(created.length, 1, outcomes.map((r) => r.statusCode).join(','));
  assert.equal(
    outcomes.filter((r) => r.statusCode === 412).length,
    builds.length - 1,
    'a floor that exists cannot be created again',
  );
  const stored = (
    await f.owner.query('SELECT min_supported_build,version FROM app.minimum_versions')
  ).rows[0];
  assert.equal(stored.version, 1, 'one write, not six');
  assert.equal(stored.min_supported_build, expectStatus(created[0]!, 200).minSupportedBuild);
  const events = (await f.owner.query('SELECT before_state FROM app.config_events')).rows;
  assert.equal(events.length, 1, 'and one of them is recorded, not six claiming nothing was there');
});

test('CFG-09 a replay answers with what that command did', async (t) => {
  const f = await fixture(t);
  const key = randomUUID();
  const payload = { enabled: false, rolloutPercentage: 25, description: 'mine' };
  const mine = expectStatus(
    await f.call('PUT', '/v1/ops/flags/p.q', { payload, match: '*', key }),
    200,
  );
  // Somebody else moves it on.
  const current = expectStatus(await f.call('GET', '/v1/ops/flags'), 200)[0];
  expectStatus(
    await f.call('PUT', '/v1/ops/flags/p.q', {
      payload: { enabled: true, rolloutPercentage: 99, description: 'theirs' },
      match: `"flag:p.q:${current.version}"`,
    }),
    200,
  );
  const replay = expectStatus(
    await f.call('PUT', '/v1/ops/flags/p.q', { payload, match: '*', key }),
    200,
  );
  assert.deepEqual(replay, mine, "not another administrator's change wearing this command's name");
});

test('CFG-10 a role nobody can use is not granted, and ops learns no phone number', async (t) => {
  const f = await fixture(t);
  await f.owner.query("UPDATE app.users SET phone='+233241234567' WHERE id=$1", [f.actor.userId]);
  const refused = await f.call('PATCH', `/v1/ops/users/${f.actor.userId}/role`, {
    payload: { role: 'driver', reason: 'No record yet' },
    match: '*',
  });
  assert.equal(refused.statusCode, 409, refused.body);
  assert.equal(refused.json().error.code, 'driver_record_required');

  await f.owner.query("INSERT INTO app.drivers(user_id,name) VALUES ($1,'Kwesi')", [
    f.actor.userId,
  ]);
  const granted = expectStatus(
    await f.call('PATCH', `/v1/ops/users/${f.actor.userId}/role`, {
      payload: { role: 'driver', reason: 'Record created' },
      match: '*',
    }),
    200,
  );
  assert.equal(granted.role, 'driver');
  assert.equal(granted.phone, null, 'a role change is not an account read');
});

test('CFG-11 the ops lists honour what they declare', async (t) => {
  const f = await fixture(t);
  for (const key of ['a.one', 'b.two', 'c.three'])
    expectStatus(
      await f.call('PUT', `/v1/ops/flags/${key}`, {
        payload: { enabled: true, rolloutPercentage: 100, description: key },
        match: '*',
      }),
      200,
    );
  const page = await f.call('GET', '/v1/ops/flags?limit=2');
  const first = expectStatus(page, 200);
  assert.equal(first.length, 2);
  const cursor = page.json().page.nextCursor;
  assert.ok(cursor, 'three flags do not fit a page of two');
  assert.equal(
    expectStatus(
      await f.call('GET', `/v1/ops/flags?limit=2&cursor=${encodeURIComponent(cursor)}`),
      200,
    ).length,
    1,
  );
  assert.equal((await f.call('GET', '/v1/ops/flags?bogus=1')).statusCode, 400);
  assert.equal((await f.call('GET', '/v1/ops/flags?limit=0')).statusCode, 400);
  // A key the contract allows is reachable, and one it does not is refused.
  const long = 'a' + '.b'.repeat(60);
  assert.equal(long.length, 121);
  expectStatus(
    await f.call('PUT', `/v1/ops/flags/${long}`, {
      payload: { enabled: false, rolloutPercentage: 0, description: 'long' },
      match: '*',
    }),
    200,
  );
  assert.equal(
    (
      await f.call('PUT', '/v1/ops/flags/abc%00def', {
        payload: { enabled: false, rolloutPercentage: 0, description: 'null byte' },
        match: '*',
      })
    ).statusCode,
    404,
  );
});

test('CFG-12 a rider is told they are not an administrator, whatever else they got wrong', async (t) => {
  const f = await fixture(t);
  const refused = await f.call('PUT', '/v1/ops/flags/x.y', {
    who: 'rider',
    client: 'ops',
    payload: { enabled: true, rolloutPercentage: 0, description: 'nope' },
  });
  assert.equal(refused.statusCode, 403, refused.body);
  assert.equal((await f.owner.query('SELECT count(*)::int n FROM app.config_events')).rows[0].n, 0);
});
