import { test } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID, randomBytes } from 'node:crypto';
import { setup } from './helpers/financial-fixture.js';
import { AccountService } from '../src/account/service.js';
import { MembershipService } from '../src/membership/service.js';
import { FinancialFoundation } from '../src/payments/foundation.js';
import { Pricing } from '../src/payments/pricing.js';
import { createTransportApp } from '../src/http/app.js';

type Response = { statusCode: number; body: string; json(): any };
function expectStatus(response: Response, code: number) {
  assert.equal(response.statusCode, code, response.body);
  return response.body ? response.json().data : null;
}
const PNG = Buffer.concat([
  Buffer.from('89504e470d0a1a0a', 'hex'),
  Buffer.from('the rest is not a real image, only its declared kind'),
]);

async function fixture(t: TestContext, options: { store?: boolean; reach?: boolean } = {}) {
  const f = await setup(t);
  const stored: { objectKey: string; bytes: number }[] = [];
  const removed: string[] = [];
  const revoked: string[] = [];
  const account = new AccountService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    deviceKey: randomBytes(32),
    avatars:
      options.store === false
        ? undefined
        : {
            put: async ({ bytes }) => {
              const objectKey = `avatars/${randomUUID()}`;
              stored.push({ objectKey, bytes: bytes.length });
              return { objectKey };
            },
            signedUrl: async (key, seconds) => `https://private.example/${key}?expires=${seconds}`,
          },
    reach:
      options.reach === false
        ? {}
        : {
            removeAvatarObject: async (key) => {
              removed.push(key);
            },
            revokeProviderGrant: async ({ subject }) => {
              revoked.push(subject);
            },
          },
  });
  const pricing = new Pricing({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 13),
  });
  const membership = new MembershipService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 13),
    fareForSelection: pricing.fareForSelection,
  });
  const financial = new FinancialFoundation({
    ...f.dependencies,
    quote: pricing.quote,
    assertCheckoutAllowed: membership.assertCheckoutAllowed,
    assertPeriodCanClose: membership.assertPeriodCanClose,
    materializeAssignment: membership.materializeAssignment,
  });
  const app = await createTransportApp({
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 13),
    authorizeSession: f.dependencies.authorizeSession,
    coordinateReservations: membership.coordinateReservations,
    membership,
    account,
    verifyAccess: async (header) =>
      ({ 'Bearer rider': f.actor, 'Bearer other': f.other })[header as string] ?? null,
    minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
  });
  t.after(() => app.close());
  const call = (
    method: 'GET' | 'PATCH' | 'POST' | 'PUT' | 'DELETE',
    url: string,
    options: { who?: string; payload?: unknown; headers?: Record<string, string> } = {},
  ) =>
    app.inject({
      method,
      url,
      headers: {
        authorization: `Bearer ${options.who ?? 'rider'}`,
        'x-trotxi-client': 'commuter',
        'x-trotxi-build': '1',
        'x-trotxi-platform': 'android',
        ...(method === 'GET' || method === 'DELETE' ? {} : { 'idempotency-key': randomUUID() }),
        ...(options.headers ?? {}),
      },
      ...(options.payload === undefined ? {} : { payload: options.payload as never }),
    }) as Promise<Response>;
  const upload = (bytes: Buffer, type = 'image/png', who = 'rider') => {
    const boundary = '----trotxitest' + randomUUID().replaceAll('-', '');
    const head = Buffer.from(
      `--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="a.png"\r\n` +
        `Content-Type: ${type}\r\n\r\n`,
    );
    const tail = Buffer.from(`\r\n--${boundary}--\r\n`);
    return app.inject({
      method: 'PUT',
      url: '/v1/me/avatar',
      headers: {
        authorization: `Bearer ${who}`,
        'x-trotxi-client': 'commuter',
        'x-trotxi-build': '1',
        'x-trotxi-platform': 'android',
        'content-type': `multipart/form-data; boundary=${boundary}`,
      },
      payload: Buffer.concat([head, bytes, tail]),
    }) as Promise<Response>;
  };
  return {
    ...f,
    account,
    membership,
    financial,
    pricing,
    app,
    call,
    upload,
    stored: () => stored,
    removed: () => removed,
    revoked: () => revoked,
  };
}

test('ACC-01 a rider renames only their own account', async (t) => {
  const f = await fixture(t);
  const renamed = expectStatus(
    await f.call('PATCH', '/v1/me', { payload: { displayName: '  Ama Serwaa  ' } }),
    200,
  );
  assert.equal(renamed.displayName, 'Ama Serwaa', 'surrounding space is not part of a name');
  assert.equal(renamed.id, f.actor.userId);
  assert.equal(
    (await f.owner.query('SELECT display_name FROM app.users WHERE id=$1', [f.other.userId]))
      .rows[0].display_name,
    null,
    'nobody else changed',
  );
  for (const bad of [{ displayName: '' }, { displayName: '   ' }, { displayName: 'x'.repeat(101) }])
    assert.equal((await f.call('PATCH', '/v1/me', { payload: bad })).statusCode, 400, String(bad));
  assert.equal((await f.call('PATCH', '/v1/me', { payload: { role: 'admin' } })).statusCode, 400);
});

test('ACC-02 a device token belongs to the handset, not to an account forever', async (t) => {
  const f = await fixture(t);
  const token = 'device-token-' + randomUUID();
  const mine = expectStatus(
    await f.call('POST', '/v1/me/devices', { payload: { token, platform: 'android' } }),
    200,
  );
  assert.equal(mine.platform, 'android');
  // Re-registering the same token is the same device, not a second one.
  const again = expectStatus(
    await f.call('POST', '/v1/me/devices', { payload: { token, platform: 'android' } }),
    200,
  );
  assert.equal(again.id, mine.id);
  // The same handset signing in as somebody else moves with them.
  const theirs = expectStatus(
    await f.call('POST', '/v1/me/devices', {
      who: 'other',
      payload: { token, platform: 'ios' },
    }),
    200,
  );
  assert.equal(theirs.id, mine.id);
  const rows = (await f.owner.query('SELECT user_id,platform FROM app.push_devices')).rows;
  assert.equal(rows.length, 1, 'one handset is one row');
  assert.equal(rows[0].user_id, f.other.userId);
  assert.equal(
    (
      await f.owner.query('SELECT token_ciphertext FROM app.push_devices')
    ).rows[0].token_ciphertext.includes(Buffer.from(token)),
    false,
    'the raw token is not what is stored',
  );
  assert.equal(
    (await f.call('POST', '/v1/me/devices', { payload: { token, platform: 'blackberry' } }))
      .statusCode,
    400,
  );
});

test('ACC-03 an avatar is what it says it is, and its URL is short lived', async (t) => {
  const f = await fixture(t);
  assert.equal((await f.call('GET', '/v1/me/avatar')).statusCode, 404, 'nothing uploaded yet');

  assert.equal((await f.upload(Buffer.from('not an image at all'), 'image/png')).statusCode, 415);
  assert.equal((await f.upload(PNG, 'application/pdf')).statusCode, 415);
  assert.equal(f.stored().length, 0, 'a refused upload stores nothing');

  const uploaded = expectStatus(await f.upload(PNG), 200);
  assert.equal(f.stored().length, 1);
  assert.ok(uploaded.url.startsWith('https://private.example/avatars/'));
  assert.ok(new Date(uploaded.expiresAt).getTime() > Date.now());
  const signed = expectStatus(await f.call('GET', '/v1/me/avatar'), 200);
  assert.ok(signed.url.includes('expires='));
  assert.ok(new Date(signed.expiresAt).getTime() > Date.now());
  assert.equal(
    (await f.owner.query('SELECT avatar_object_key FROM app.users WHERE id=$1', [f.actor.userId]))
      .rows[0].avatar_object_key,
    f.stored()[0]!.objectKey,
  );
});

test('ACC-04 an unwired avatar store refuses rather than pretending', async (t) => {
  const f = await fixture(t, { store: false });
  assert.equal((await f.upload(PNG)).statusCode, 503);
  assert.equal((await f.call('GET', '/v1/me/avatar')).statusCode, 404);
});

test('ACC-05 erasure stops the account working and leaves nothing personal', async (t) => {
  const f = await fixture(t);
  await f.owner.query(
    "UPDATE app.users SET display_name='Ama',email='ama@example.com',phone='+233200000000' WHERE id=$1",
    [f.actor.userId],
  );
  await f.owner.query(
    "INSERT INTO app.auth_identities(user_id,provider,subject) VALUES ($1,'google',$2)",
    [f.actor.userId, 'google-subject-' + randomUUID()],
  );
  const session = (
    await f.owner.query(
      `INSERT INTO app.auth_sessions(user_id,created_at,expires_at,refresh_ttl_seconds)
      VALUES ($1,clock_timestamp(),clock_timestamp()+interval '30 days',2592000) RETURNING id`,
      [f.actor.userId],
    )
  ).rows[0].id;
  expectStatus(await f.upload(PNG), 200);
  expectStatus(
    await f.call('POST', '/v1/me/devices', {
      payload: { token: 'tok-' + randomUUID(), platform: 'ios' },
    }),
    200,
  );

  assert.equal((await f.call('DELETE', '/v1/me')).statusCode, 204);

  const user = (await f.owner.query('SELECT * FROM app.users WHERE id=$1', [f.actor.userId]))
    .rows[0];
  assert.ok(user.deleted_at, 'the account is closed');
  assert.deepEqual(
    {
      displayName: user.display_name,
      email: user.email,
      phone: user.phone,
      avatar: user.avatar_object_key,
    },
    { displayName: null, email: null, phone: null, avatar: null },
    'and keeps none of the identity it had',
  );
  const identity = (await f.owner.query('SELECT subject FROM app.auth_identities')).rows[0];
  assert.ok(identity.subject.startsWith('erased:'), 'the provider subject is gone');
  assert.equal(
    (await f.owner.query('SELECT revoked_at FROM app.auth_sessions WHERE id=$1', [session])).rows[0]
      .revoked_at !== null,
    true,
  );
  const device = (await f.owner.query('SELECT * FROM app.push_devices')).rows[0];
  assert.ok(device.revoked_at);
  assert.equal(device.token_ciphertext, null, 'a revoked device keeps no token');
  assert.deepEqual(f.removed(), [f.stored()[0]!.objectKey], 'the stored object is removed');
  assert.equal(f.revoked().length, 1, 'the provider grant is revoked');
  const tasks = (await f.owner.query('SELECT kind,state FROM app.erasure_tasks ORDER BY kind'))
    .rows;
  assert.deepEqual(
    tasks.map((x: any) => [x.kind, x.state]),
    [
      ['avatar_object', 'done'],
      ['provider_revocation', 'done'],
    ],
  );
  const record = (await f.owner.query('SELECT * FROM app.account_erasures')).rows[0];
  assert.equal(record.user_id, f.actor.userId);
  assert.equal(record.identities_scrubbed, 1);
  assert.equal(record.devices_revoked, 1);

  // Closing an account is what takes its identity away, whoever does the
  // closing. A writer that forgets to scrub does not get to keep a name.
  await f.owner.query(
    "UPDATE app.users SET display_name='Kofi',phone='+233200000001' WHERE id=$1",
    [f.other.userId],
  );
  await f.owner.query('UPDATE app.users SET deleted_at=clock_timestamp() WHERE id=$1', [
    f.other.userId,
  ]);
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT display_name,phone,email,avatar_object_key FROM app.users WHERE id=$1',
        [f.other.userId],
      )
    ).rows[0],
    { display_name: null, phone: null, email: null, avatar_object_key: null },
  );

  // The account cannot be brought back, and cannot act again.
  await assert.rejects(
    f.owner.query('UPDATE app.users SET deleted_at=NULL WHERE id=$1', [f.actor.userId]),
    /erasure_is_final/,
  );
  assert.equal(
    (await f.call('PATCH', '/v1/me', { payload: { displayName: 'Back' } })).statusCode,
    401,
  );
});

test('ACC-06 an unreachable provider leaves work to retry, not a finished erasure', async (t) => {
  const f = await fixture(t, { reach: false });
  await f.owner.query(
    "INSERT INTO app.auth_identities(user_id,provider,subject) VALUES ($1,'apple',$2)",
    [f.actor.userId, 'apple-subject-' + randomUUID()],
  );
  expectStatus(await f.upload(PNG), 200);
  assert.equal(
    (await f.call('DELETE', '/v1/me')).statusCode,
    204,
    'the local part still completes',
  );
  const tasks = (
    await f.owner.query(
      'SELECT kind,state,attempts,last_failure FROM app.erasure_tasks ORDER BY kind',
    )
  ).rows;
  assert.deepEqual(
    tasks.map((x: any) => [x.kind, x.state, x.attempts]),
    [
      ['avatar_object', 'unavailable', 1],
      ['provider_revocation', 'unavailable', 1],
    ],
  );
  assert.ok(tasks.every((x: any) => x.last_failure));
  // The retry is bounded and does not invent success while still unwired.
  assert.deepEqual(await f.account.retryErasures(), { considered: 2, completed: 0 });
  const after = (await f.owner.query('SELECT attempts FROM app.erasure_tasks ORDER BY kind')).rows;
  assert.deepEqual(
    after.map((x: any) => x.attempts),
    [2, 2],
  );
});

test('ACC-07 erasure clears what a rider had booked and keeps what accounting needs', async (t) => {
  const f = await fixture(t);
  await f.owner.query(
    `INSERT INTO app.route_fares(route_id,amount_pesewas,effective_from,created_by,command_id)
    VALUES ($1,600,clock_timestamp()-interval '1 day',$2,gen_random_uuid())`,
    [f.input.routeId, f.adminId],
  );
  const purchase = await f.financial.checkout(f.actor, f.input, randomUUID(), new Date());
  assert.equal(await f.financial.fulfill(f.settle(purchase)), 'fulfilled');
  const before = (await f.owner.query('SELECT * FROM app.ride_entries')).rows;
  assert.ok(before.length, 'the rider has a ledger');

  assert.equal((await f.call('DELETE', '/v1/me')).statusCode, 204);

  assert.deepEqual(
    (await f.owner.query('SELECT * FROM app.ride_entries')).rows,
    before,
    'accounting we are required to keep is kept, untouched',
  );
  assert.equal(
    (
      await f.owner.query('SELECT count(*)::int n FROM app.purchases WHERE user_id=$1', [
        f.actor.userId,
      ])
    ).rows[0].n,
    1,
  );
  assert.equal(
    (
      await f.owner.query(
        'SELECT count(*)::int n FROM app.commute_assignments WHERE user_id=$1 AND effective_to IS NULL',
        [f.actor.userId],
      )
    ).rows[0].n,
    0,
    "and 013's triggers closed what the rider had",
  );
});
