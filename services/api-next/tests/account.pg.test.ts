import { test } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID, randomBytes } from 'node:crypto';
import { setTimeout as delay } from 'node:timers/promises';
import { setup } from './helpers/financial-fixture.js';
import { AccountService } from '../src/account/service.js';
import { MembershipService } from '../src/membership/service.js';
import { FinancialFoundation } from '../src/payments/foundation.js';
import { Pricing } from '../src/payments/pricing.js';
import { createTransportApp } from '../src/http/app.js';
import { PhoneOtp } from '../src/auth/phone-otp.js';

type Response = { statusCode: number; body: string; json(): any };
test('driver app can register its own push device without opening other account routes to driver metadata', async (t) => {
  const f = await fixture(t);
  await f.owner.query("UPDATE app.users SET role='driver' WHERE id=$1", [f.actor.userId]);
  const response = await f.call('POST', '/v1/me/devices', {
    payload: { platform: 'android', token: 'driver-token' },
    headers: { 'x-trotxi-client': 'driver' },
  });
  expectStatus(response, 200);
  assert.equal(
    (
      await f.owner.query('SELECT user_id FROM app.push_devices WHERE id=$1', [
        response.json().data.id,
      ])
    ).rows[0].user_id,
    f.actor.userId,
  );
  expectStatus(
    await f.call('PATCH', '/v1/me', {
      payload: { displayName: 'Changed' },
      headers: { 'x-trotxi-client': 'driver' },
    }),
    400,
  );
});

test('a driver sets their own photo from the driver app, and still cannot rename', async (t) => {
  const f = await fixture(t);
  await f.owner.query("UPDATE app.users SET role='driver' WHERE id=$1", [f.actor.userId]);

  // The photo is the person's, and the driver app is where a driver is. This
  // was refused before the client check ever reached authentication, which
  // read in the app as an upload that failed for no stated reason.
  expectStatus(await f.upload(PNG, 'image/png', 'rider', randomUUID(), 'driver'), 200);
  expectStatus(
    await f.call('GET', '/v1/me/avatar', { headers: { 'x-trotxi-client': 'driver' } }),
    200,
  );
  expectStatus(
    await f.call('DELETE', '/v1/me/avatar', { headers: { 'x-trotxi-client': 'driver' } }),
    204,
  );

  // Widening the photo did not widen the rest of the account surface.
  expectStatus(
    await f.call('PATCH', '/v1/me', {
      payload: { displayName: 'Changed' },
      headers: { 'x-trotxi-client': 'driver' },
    }),
    400,
  );
});
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
  const tokens: (string | null)[] = [];
  let reachable = options.reach !== false;
  const account = new AccountService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    deviceKey: randomBytes(32),
    avatars:
      options.store === false
        ? undefined
        : {
            put: async ({ bytes, objectKey }) => {
              stored.push({ objectKey, bytes: bytes.length });
              return { objectKey };
            },
            signedUrl: async (key, seconds) => `https://private.example/${key}?expires=${seconds}`,
          },
    reach: {
      removeAvatarObject: async (key) => {
        if (!reachable) throw new Error('unreachable');
        removed.push(key);
      },
      revokeProviderGrant: async ({ subject, tokenCiphertext }) => {
        if (!reachable) throw new Error('unreachable');
        revoked.push(subject);
        tokens.push(tokenCiphertext);
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
        ...(method === 'GET' ? {} : { 'idempotency-key': randomUUID() }),
        ...(options.headers ?? {}),
      },
      ...(options.payload === undefined ? {} : { payload: options.payload as never }),
    }) as Promise<Response>;
  const upload = (
    bytes: Buffer,
    type = 'image/png',
    who = 'rider',
    key = randomUUID(),
    client = 'commuter',
  ) => {
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
        'x-trotxi-client': client,
        'x-trotxi-build': '1',
        'x-trotxi-platform': 'android',
        'content-type': `multipart/form-data; boundary=${boundary}`,
        'idempotency-key': key,
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
    tokens: () => tokens,
    reconnect: () => {
      reachable = true;
    },
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
  // The reviewed contract requires a key on every account command.
  assert.equal(
    (
      await f.call('PATCH', '/v1/me', {
        payload: { displayName: 'No key' },
        headers: { 'idempotency-key': '' },
      })
    ).statusCode,
    400,
  );
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
test('ACC-DELETE: avatar removal queues physical erasure and replay cannot remove a replacement', async (t) => {
  const f = await fixture(t);
  expectStatus(await f.upload(PNG), 200);
  const old = (
    await f.owner.query('SELECT avatar_object_key FROM app.users WHERE id=$1', [f.actor.userId])
  ).rows[0].avatar_object_key;
  const key = randomUUID();
  expectStatus(
    await f.call('DELETE', '/v1/me/avatar', { headers: { 'idempotency-key': key } }),
    204,
  );
  assert.equal((await f.call('GET', '/v1/me/avatar')).statusCode, 404);
  assert.equal(
    (
      await f.owner.query(
        "SELECT count(*)::int n FROM app.erasure_tasks WHERE kind='avatar_object' AND reference=$1",
        [old],
      )
    ).rows[0].n,
    1,
  );
  await f.account.retryErasures(100);
  assert.ok(f.removed().includes(old));
  expectStatus(await f.upload(PNG), 200);
  const next = (
    await f.owner.query('SELECT avatar_object_key FROM app.users WHERE id=$1', [f.actor.userId])
  ).rows[0].avatar_object_key;
  expectStatus(
    await f.call('DELETE', '/v1/me/avatar', { headers: { 'idempotency-key': key } }),
    204,
  );
  assert.equal(
    (await f.owner.query('SELECT avatar_object_key FROM app.users WHERE id=$1', [f.actor.userId]))
      .rows[0].avatar_object_key,
    next,
  );
  assert.equal((await f.call('GET', '/v1/me/avatar')).statusCode, 200);
  assert.equal(
    (await f.owner.query('SELECT deleted_at FROM app.users WHERE id=$1', [f.actor.userId])).rows[0]
      .deleted_at,
    null,
  );
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
  assert.equal(f.revoked().length, 0, 'Google ID-token sign-in holds no revocable grant');
  const tasks = (
    await f.owner.query(
      "SELECT kind,state FROM app.erasure_tasks WHERE state<>'cancelled' ORDER BY kind",
    )
  ).rows;
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
  const status = (
    await f.owner.query('SELECT * FROM app.account_erasure_status WHERE user_id=$1', [
      f.actor.userId,
    ])
  ).rows[0];
  assert.equal(status.tracked_cleanup_state, 'tracked_complete');
  assert.equal(status.tracked_pending, 0);
  assert.equal(status.tracked_unavailable, 0);
  assert.equal(status.tracked_done, 2);
  assert.equal(JSON.stringify(status).includes('ama@example.com'), false);

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
    "INSERT INTO app.auth_identities(user_id,provider,subject,provider_token_ciphertext) VALUES ($1,'apple',$2,'sealed-test-grant')",
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
      "SELECT kind,state,attempts,last_failure FROM app.erasure_tasks WHERE state<>'cancelled' ORDER BY kind",
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
  const status = (
    await f.owner.query('SELECT * FROM app.account_erasure_status WHERE user_id=$1', [
      f.actor.userId,
    ])
  ).rows[0];
  assert.equal(status.tracked_cleanup_state, 'retry_needed');
  assert.equal(status.tracked_unavailable, 2);
  // The retry is bounded and does not invent success while still unwired.
  assert.deepEqual(await f.account.retryErasures(), { considered: 2, completed: 0, failed: 2 });
  const after = (
    await f.owner.query(
      "SELECT attempts FROM app.erasure_tasks WHERE state<>'cancelled' ORDER BY kind",
    )
  ).rows;
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

test('ACC-08 a handset comes back after its previous owner closes their account', async (t) => {
  const f = await fixture(t);
  const token = 'shared-handset-' + randomUUID();
  expectStatus(
    await f.call('POST', '/v1/me/devices', { payload: { token, platform: 'android' } }),
    200,
  );
  assert.equal((await f.call('DELETE', '/v1/me')).statusCode, 204);
  // The phone is still a phone. Its next owner registers it and it works.
  const reclaimed = expectStatus(
    await f.call('POST', '/v1/me/devices', {
      who: 'other',
      payload: { token, platform: 'ios' },
    }),
    200,
  );
  const row = (await f.owner.query('SELECT * FROM app.push_devices')).rows[0];
  assert.equal(row.id, reclaimed.id);
  assert.equal(row.user_id, f.other.userId);
  assert.equal(row.revoked_at, null);
  assert.ok(row.token_ciphertext, 'and it can be notified again');
});

test('ACC-09 the provider is asked to revoke the grant it actually issued', async (t) => {
  const f = await fixture(t);
  const subject = 'apple-subject-' + randomUUID();
  await f.owner.query(
    "INSERT INTO app.auth_identities(user_id,provider,subject,provider_token_ciphertext) VALUES ($1,'apple',$2,$3)",
    [f.actor.userId, subject, 'sealed-refresh-token'],
  );
  assert.equal((await f.call('DELETE', '/v1/me')).statusCode, 204);
  assert.deepEqual(f.revoked(), [subject], 'the provider knows the subject, not our row id');
  assert.deepEqual(f.tokens(), ['sealed-refresh-token'], 'and Apple needs the token to revoke');
  assert.equal(
    (await f.owner.query('SELECT provider_token_ciphertext,subject FROM app.auth_identities'))
      .rows[0].provider_token_ciphertext,
    null,
    'which is kept only until the revocation succeeds',
  );
});

test('ACC-10 a replaced avatar does not stay in the store, and a retry writes one object', async (t) => {
  const f = await fixture(t);
  const key = randomUUID();
  expectStatus(await f.upload(PNG, 'image/png', 'rider', key), 200);
  expectStatus(await f.upload(PNG, 'image/png', 'rider', key), 200);
  assert.equal(f.stored().length, 1, 'the same key writes one object');

  expectStatus(await f.upload(PNG, 'image/png', 'rider', randomUUID()), 200);
  assert.equal(f.stored().length, 2);
  assert.deepEqual(
    f.removed(),
    [f.stored()[0]!.objectKey],
    'and the picture it replaced is deleted rather than left behind',
  );
});

test('ACC-11 erasure closes a driver record too', async (t) => {
  const f = await fixture(t);
  await f.owner.query("UPDATE app.users SET role='driver' WHERE id=$1", [f.actor.userId]);
  await f.owner.query(
    "INSERT INTO app.drivers(user_id,name,phone,email,license_number) VALUES ($1,'Kwesi','+233555000111','kwesi.driver@example.test','GH-LIC-9911')",
    [f.actor.userId],
  );
  assert.equal((await f.call('DELETE', '/v1/me')).statusCode, 204);
  const driver = (
    await f.owner.query('SELECT * FROM app.drivers WHERE user_id=$1', [f.actor.userId])
  ).rows[0];
  assert.equal(driver.phone, null);
  assert.equal(driver.email, null, 'the contact email goes with the rest');
  assert.equal(driver.license_number, null);
  assert.notEqual(driver.name, 'Kwesi');
  assert.ok(driver.archived_at);
});

test('ACC-12 a malformed upload is a bad request, and a closed row is born closed', async (t) => {
  const f = await fixture(t);
  const boundary = '----trotxi' + randomUUID().replaceAll('-', '');
  const twoFields = Buffer.from(
    `--${boundary}\r\nContent-Disposition: form-data; name="note"\r\n\r\nhello\r\n` +
      `--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="a.png"\r\n` +
      `Content-Type: image/png\r\n\r\n`,
  );
  const malformed = await f.app.inject({
    method: 'PUT',
    url: '/v1/me/avatar',
    headers: {
      authorization: 'Bearer rider',
      'x-trotxi-client': 'commuter',
      'x-trotxi-build': '1',
      'x-trotxi-platform': 'android',
      'idempotency-key': randomUUID(),
      'content-type': `multipart/form-data; boundary=${boundary}`,
    },
    payload: Buffer.concat([twoFields, PNG, Buffer.from(`\r\n--${boundary}--\r\n`)]),
  });
  assert.equal(malformed.statusCode, 400, malformed.body);
  assert.equal(malformed.json().error.code, 'invalid_request');
  assert.equal(malformed.json().error.message, 'Supply exactly one image part.');
  assert.equal(f.stored().length, 0);

  // A row created already closed keeps nothing either.
  const ghost = (
    await f.owner.query(
      `INSERT INTO app.users(role,display_name,email,phone,deleted_at)
      VALUES ('commuter','Ghost','ghost@example.com','+233200000009',clock_timestamp())
      RETURNING display_name,email,phone`,
    )
  ).rows[0];
  assert.deepEqual(ghost, { display_name: null, email: null, phone: null });
});

test('ACC-13 two sweeps do not do the same outside work twice', async (t) => {
  const f = await fixture(t, { reach: false });
  expectStatus(await f.upload(PNG), 200);
  assert.equal((await f.call('DELETE', '/v1/me')).statusCode, 204);
  f.reconnect();
  const [a, b] = await Promise.all([f.account.retryErasures(), f.account.retryErasures()]);
  assert.equal(f.removed().length, 1, 'the object is deleted once');
  assert.equal(a.completed + b.completed, 1, 'and counted once');

  // An exhausted attempt count must not make completion impossible.
  const settled = (
    await f.owner.query(
      "SELECT state FROM app.erasure_tasks WHERE kind='avatar_object' AND disposition='removed'",
    )
  ).rows[0];
  assert.equal(settled.state, 'done');
});

test('ACC-14 deleting a phone account invalidates its outstanding code without resetting the abuse budget', async (t) => {
  const f = await fixture(t);
  const phoneHash = 'a'.repeat(64);
  const challengeId = randomUUID();
  await f.owner.query("UPDATE app.users SET phone='+233241234567' WHERE id=$1", [f.actor.userId]);
  await f.owner.query(
    "INSERT INTO app.auth_identities(user_id,provider,subject) VALUES ($1,'phone',$2)",
    [f.actor.userId, phoneHash],
  );
  await f.owner.query(
    `INSERT INTO app.phone_otp_challenges
      (id,phone_hash,source_hash,phone_ciphertext,code_hash,state,expires_at)
     VALUES ($1,$2,$3,'encrypted-phone',$4,'sent',clock_timestamp()+interval '4 minutes')`,
    [challengeId, phoneHash, 'b'.repeat(64), 'c'.repeat(64)],
  );
  assert.equal((await f.call('DELETE', '/v1/me')).statusCode, 204);
  const challenge = (
    await f.owner.query('SELECT * FROM app.phone_otp_challenges WHERE id=$1', [challengeId])
  ).rows[0];
  assert.equal(challenge.state, 'failed');
  assert.equal(challenge.phone_ciphertext, null);
  assert.equal(challenge.code_hash, null);
  assert.equal(challenge.phone_hash, phoneHash, 'the 24-hour rate budget is not reset');
  const otp = new PhoneOtp(f.runtime, { send: async () => 'test' }, randomBytes(32), true);
  const c = await f.runtime.connect();
  try {
    await c.query('BEGIN');
    assert.equal(await otp.verify(c, challengeId, '123456'), null);
    await c.query('ROLLBACK');
  } finally {
    c.release();
  }
  await assert.rejects(
    f.runtime.query("UPDATE app.phone_otp_challenges SET state='sent' WHERE id=$1", [challengeId]),
    /phone_otp_immutable/,
  );
  assert.equal(
    (
      await f.owner.query("SELECT subject FROM app.auth_identities WHERE provider='phone'")
    ).rows[0].subject.startsWith('erased:'),
    true,
  );
});

test('ACC-15 erasure closes seeded linked stores while preserving only restricted delivery facts', async (t) => {
  const f = await fixture(t);
  const driverId = (
    await f.owner.query(
      "INSERT INTO app.drivers(user_id,name,phone,email) VALUES ($1,'Ama Driver','+233241234567','ama@example.test') RETURNING id",
      [f.actor.userId],
    )
  ).rows[0].id;
  await f.owner.query(
    "UPDATE app.users SET phone='+233241234567',email='ama@example.test' WHERE id=$1",
    [f.actor.userId],
  );
  const phoneHash = 'd'.repeat(64);
  await f.owner.query(
    "INSERT INTO app.auth_identities(user_id,provider,subject) VALUES ($1,'phone',$2)",
    [f.actor.userId, phoneHash],
  );
  const challengeId = randomUUID();
  await f.owner.query(
    `INSERT INTO app.phone_otp_challenges(id,phone_hash,source_hash,phone_ciphertext,code_hash,state,expires_at)
     VALUES ($1,$2,$3,'sealed-phone',$4,'sent',clock_timestamp()+interval '4 minutes')`,
    [challengeId, phoneHash, 'e'.repeat(64), 'f'.repeat(64)],
  );
  const emailId = randomUUID();
  await f.owner.query(
    `INSERT INTO app.email_outbox(id,user_id,kind,source_id,dedupe_key,payload_ciphertext)
     VALUES ($1,$2,'subscription_active',$3,$4,'sealed-email')`,
    [emailId, f.actor.userId, randomUUID(), randomUUID()],
  );
  const smsId = randomUUID();
  await f.owner.query(
    `INSERT INTO app.driver_sms_outbox(id,user_id,driver_id,command_id,pin_version,expires_at,payload_ciphertext)
     VALUES ($1,$2,$3,$4,1,clock_timestamp()+interval '1 hour','sealed-sms')`,
    [smsId, f.actor.userId, driverId, randomUUID()],
  );
  expectStatus(await f.upload(PNG), 200);
  expectStatus(
    await f.call('POST', '/v1/me/devices', {
      payload: { token: 'delete-device-' + randomUUID(), platform: 'android' },
    }),
    200,
  );

  expectStatus(await f.call('DELETE', '/v1/me'), 204);
  const local = (
    await f.owner.query(
      `SELECT u.email,u.phone,u.avatar_object_key,d.email AS driver_email,d.phone AS driver_phone,
        e.state AS email_state,e.payload_ciphertext AS email_payload,
        s.state AS sms_state,s.payload_ciphertext AS sms_payload,
        o.state AS otp_state,o.phone_ciphertext AS otp_phone,o.code_hash AS otp_code,
        p.revoked_at,p.token_ciphertext
       FROM app.users u JOIN app.drivers d ON d.user_id=u.id
       JOIN app.email_outbox e ON e.user_id=u.id
       JOIN app.driver_sms_outbox s ON s.user_id=u.id
       JOIN app.phone_otp_challenges o ON o.phone_hash=$2
       JOIN app.push_devices p ON p.user_id=u.id
       WHERE u.id=$1`,
      [f.actor.userId, phoneHash],
    )
  ).rows[0];
  assert.deepEqual(
    [
      local.email,
      local.phone,
      local.avatar_object_key,
      local.driver_email,
      local.driver_phone,
      local.email_payload,
      local.sms_payload,
      local.otp_phone,
      local.otp_code,
      local.token_ciphertext,
    ],
    Array(10).fill(null),
  );
  assert.deepEqual(
    [local.email_state, local.sms_state, local.otp_state],
    ['cancelled', 'cancelled', 'failed'],
  );
  assert.ok(local.revoked_at);
  assert.deepEqual(f.removed(), [f.stored()[0]!.objectKey]);
  assert.equal(
    (
      await f.owner.query(
        'SELECT tracked_cleanup_state FROM app.account_erasure_status WHERE user_id=$1',
        [f.actor.userId],
      )
    ).rows[0].tracked_cleanup_state,
    'tracked_complete',
  );
});

test('ACC-16 erasure waits for in-flight phone issuance then cancels its challenge', async (t) => {
  const f = await fixture(t);
  const phoneHash = '1'.repeat(64);
  const challengeId = randomUUID();
  await f.owner.query("UPDATE app.users SET phone='+233241234567' WHERE id=$1", [f.actor.userId]);
  await f.owner.query(
    "INSERT INTO app.auth_identities(user_id,provider,subject) VALUES ($1,'phone',$2)",
    [f.actor.userId, phoneHash],
  );
  const issuer = await f.owner.connect();
  let deletion: Promise<Response> | undefined;
  let waiting = false;
  try {
    await issuer.query('BEGIN');
    await issuer.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
      `phone-otp:${phoneHash}`,
    ]);
    deletion = f.call('DELETE', '/v1/me');
    for (let attempt = 0; attempt < 100; attempt++) {
      const row = (
        await f.owner.query(
          `SELECT 1 FROM pg_stat_activity
           WHERE datname=current_database() AND wait_event='advisory'
             AND query LIKE 'SELECT pg_advisory_xact_lock%' LIMIT 1`,
        )
      ).rows[0];
      if (row) {
        waiting = true;
        break;
      }
      await delay(20);
    }
    await issuer.query(
      `INSERT INTO app.phone_otp_challenges
        (id,phone_hash,source_hash,phone_ciphertext,code_hash,state,expires_at)
       VALUES ($1,$2,$3,'sealed-phone',$4,'sending',clock_timestamp()+interval '4 minutes')`,
      [challengeId, phoneHash, '2'.repeat(64), '3'.repeat(64)],
    );
    await issuer.query('COMMIT');
  } finally {
    await issuer.query('ROLLBACK').catch(() => undefined);
    issuer.release();
  }
  assert.equal((await deletion!).statusCode, 204);
  assert.equal(waiting, true, 'deletion must wait on the issuance lock before scrubbing');
  const challenge = (
    await f.owner.query(
      'SELECT state,phone_ciphertext,code_hash FROM app.phone_otp_challenges WHERE id=$1',
      [challengeId],
    )
  ).rows[0];
  assert.deepEqual(challenge, { state: 'failed', phone_ciphertext: null, code_hash: null });
  assert.equal(
    (
      await f.owner.query(
        "UPDATE app.phone_otp_challenges SET state='sent' WHERE id=$1 AND state='sending'",
        [challengeId],
      )
    ).rowCount,
    0,
    'the issuer cannot promote a cancelled challenge after deletion',
  );
});
