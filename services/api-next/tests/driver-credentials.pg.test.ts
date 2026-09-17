import { purgeExpiredDriverSecrets } from '../src/auth/driver-service.js';
import { test, after } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes, randomUUID } from 'node:crypto';
import { mkdir, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import pg from 'pg';
import { createLocalJWKSet, exportJWK, generateKeyPair, SignJWT } from 'jose';
import { createReplacementApp } from '../src/http/replacement.js';
import { AuthService } from '../src/auth/service.js';
import type { AuthOptions } from '../src/auth/service.js';
import { GoogleIdTokenVerifier } from '../src/auth/id-token-verifier.google.js';
import { AppleIdTokenVerifier } from '../src/auth/id-token-verifier.apple.js';
import { hashToken } from '../src/auth/credentials.js';
import { TransportError } from '../src/transport/errors.js';
import { grantRuntime, migrate, readMigrations } from '../src/db/migrate.js';

const value = process.env.HARNESS_ADMIN_DATABASE_URL;
if (!value || process.env.HARNESS_ALLOW_CREATE_DATABASES !== '1')
  throw new Error('Disposable PostgreSQL required; driver tests never skip');
const url = new URL(value);
if (
  !['postgres:', 'postgresql:'].includes(url.protocol) ||
  !['127.0.0.1', 'localhost', '[::1]'].includes(url.hostname) ||
  url.pathname !== '/postgres' ||
  url.search ||
  url.hash
)
  throw new Error('Only disposable loopback postgres admin database is allowed');
const admin = new pg.Pool({ connectionString: url.href, max: 3, connectionTimeoutMillis: 3000 });
const migrations = await readMigrations(fileURLToPath(new URL('../migrations/', import.meta.url)));
const run = randomBytes(5).toString('hex'),
  owned: string[] = [],
  roles: string[] = [],
  evidence: string[] = [];
let serial = 0;
const pair = await generateKeyPair('RS256'),
  jwk = await exportJWK(pair.publicKey);
const keys = createLocalJWKSet({ keys: [{ ...jwk, kid: 'driver-pg' }] });
const pinSecret = 'driver-pg-pin-secret'.repeat(3),
  encryptionKey = Buffer.alloc(32, 7);
const access = {
  secret: Buffer.alloc(32, 8),
  issuer: 'driver-pg-issuer',
  audience: 'driver-pg-access',
  ttlSeconds: 900,
};
const google = new GoogleIdTokenVerifier('web-client', keys),
  apple = new AppleIdTokenVerifier(['ios-client'], keys);
async function identityToken(
  subject: string,
  provider = 'google',
  claims: Record<string, unknown> = {},
) {
  return new SignJWT({ email: 'same-email@example.invalid', email_verified: true, ...claims })
    .setProtectedHeader({ alg: 'RS256', kid: 'driver-pg' })
    .setSubject(subject)
    .setIssuer(provider === 'apple' ? 'https://appleid.apple.com' : 'https://accounts.google.com')
    .setAudience(provider === 'apple' ? 'ios-client' : 'web-client')
    .setIssuedAt()
    .setExpirationTime('5m')
    .sign(pair.privateKey);
}
after(async () => {
  try {
    for (const name of owned) await admin.query(`DROP DATABASE "${name}"`);
    for (const role of roles) await admin.query(`DROP ROLE "${role}"`);
    if (process.env.REPLACEMENT_EVIDENCE_DIR) {
      await mkdir(process.env.REPLACEMENT_EVIDENCE_DIR, { recursive: true });
      await writeFile(
        resolve(process.env.REPLACEMENT_EVIDENCE_DIR, 'driver-metadata.json'),
        JSON.stringify(
          {
            kind: 'replacement-driver-http-postgres',
            providerBoundary:
              'Locally signed Google JWTs bootstrap test ops accounts; real driver PIN and access-token verification. No external provider or staging call.',
            bookingBoundary:
              'Explicit throwing test coordinator. Real booking adapter remains required before startup.',
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
async function setup(
  t: TestContext,
  authBudget = 1000,
  providers: Partial<Pick<AuthOptions, 'google' | 'apple'>> = {},
) {
  const n = ++serial,
    name = `trotxi_harness_${run}_driver_${n}`,
    role = `trotxi_runtime_driver_${run}_${n}`;
  await admin.query(`CREATE DATABASE "${name}"`);
  owned.push(name);
  const db = new URL(url);
  db.pathname = `/${name}`;
  const owner = new pg.Pool({ connectionString: db.href, max: 5 });
  t.after(() => owner.end());
  await migrate(owner, migrations);
  await admin.query(`CREATE ROLE "${role}" LOGIN PASSWORD 'runtime-test-only'`);
  roles.push(role);
  await grantRuntime(owner, role);
  db.username = role;
  db.password = 'runtime-test-only';
  const applicationName = `auth-${run}-${n}`;
  const runtime = new pg.Pool({
    connectionString: db.href,
    max: 10,
    application_name: applicationName,
  });
  t.after(() => runtime.end());
  const identity = {
    access,
    pinSecret,
    refreshTtlDays: 30,
    shiftTtlHours: 12,
    google,
    apple,
    providerEncryptionKey: encryptionKey,
    appleTokens: {
      exchangeCode: async (code: string) => ({
        refreshToken: code === 'used' ? null : 'apple-private-refresh',
      }),
      revoke: async () => {},
    },
    ...providers,
  };
  const service = new AuthService({
    ...identity,
    pool: runtime,
    cursorSecret: Buffer.alloc(32, 6),
  });
  const app = await createReplacementApp({
    credentialReplayKey: Buffer.alloc(32, 9),
    pool: runtime,
    cursorSecret: Buffer.alloc(32, 6),
    identity,
    minimumBuilds: { ops: 2, driver: { ios: 2, android: 2 }, commuter: { ios: 2, android: 2 } },
    requestsPerMinute: 1000,
    requestsPerIpPerMinute: 3000,
    authRequestsPerMinute: authBudget,
    coordinateReservations: async () => {
      throw new TransportError(503, 'test_booking_unavailable', 'Explicit test booking adapter.');
    },
  });
  t.after(() => app.close());
  evidence.push(t.name);
  async function request(
    method: 'GET' | 'POST' | 'PATCH' | 'DELETE',
    path: string,
    body?: unknown,
    token?: string,
    headers: Record<string, string> = {},
  ) {
    return app.inject({
      method,
      url: path,
      ...(body !== undefined ? { payload: body as object } : {}),
      headers: {
        'x-trotxi-client': path.startsWith('/v1/ops/')
          ? 'ops'
          : path.startsWith('/v1/auth/driver')
            ? 'driver'
            : 'commuter',
        ...(path.startsWith('/v1/ops/') ? {} : { 'x-trotxi-platform': 'ios' }),
        'x-trotxi-build': '2',
        ...(token ? { authorization: `Bearer ${token}` } : {}),
        ...headers,
      },
    });
  }
  async function sign(subject = 'rider', provider = 'google', extra: Record<string, unknown> = {}) {
    const res = await request('POST', `/v1/auth/${provider}`, {
      idToken: await identityToken(subject, provider),
      ...extra,
    });
    assert.equal(res.statusCode, 200, res.body);
    return res.json().data;
  }
  async function lockUser(userId: string) {
    const client = await owner.connect();
    await client.query('BEGIN');
    await client.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [userId]);
    return client;
  }
  async function waitForWaiters(count: number) {
    const end = Date.now() + 2500;
    while (Date.now() < end) {
      const row = (
        await owner.query(
          "SELECT count(*)::int AS count FROM pg_stat_activity WHERE application_name=$1 AND wait_event_type='Lock'",
          [applicationName],
        )
      ).rows[0];
      if (row.count >= count) return;
      await delay(10);
    }
    assert.fail(`Did not observe ${count} real lock waiters`);
  }
  return {
    owner,
    runtime,
    service,
    app,
    request,
    sign,
    lockUser,
    waitForWaiters,
    role,
  };
}
const data = (response: { statusCode: number; body: string; json(): any }, status = 200) => {
  assert.equal(response.statusCode, status, response.body);
  return status === 204 ? undefined : response.json().data;
};

async function fixture(t: TestContext) {
  const f = await setup(t),
    ops = await f.sign('operator');
  await f.owner.query("UPDATE app.users SET role='admin' WHERE id=$1", [ops.account.id]);
  const call = (
    method: 'GET' | 'POST' | 'PATCH',
    path: string,
    body?: unknown,
    key = randomUUID(),
    extra: Record<string, string> = {},
  ) => f.request(method, path, body, ops.accessToken, { 'idempotency-key': key, ...extra });
  const create = async (body: Record<string, unknown> = { name: 'Ported Driver' }) =>
    data(await call('POST', '/v1/ops/drivers', body), 201);
  const issue = async (id: string, key = randomUUID(), body: Record<string, unknown> = {}) =>
    call('POST', `/v1/ops/drivers/${id}/credentials`, body, key);
  const reset = async (id: string, key = randomUUID()) =>
    call('POST', `/v1/ops/drivers/${id}/credentials/reset-pin`, { reason: 'Test reset' }, key);
  const action = async (id: string, action: string) =>
    call('POST', `/v1/ops/drivers/${id}/credentials/actions`, {
      action,
      reason: 'Test state change',
    });
  const login = async (secret: { code: string; pin: string }) =>
    data(await f.request('POST', '/v1/auth/driver', { ...secret, ownDevice: true }));
  return { ...f, ops, call, create, issue, reset, action, login };
}

test('DRV-01: HTTP provisioning, generated code, principal ownership, list edit tokens and no credential leakage', async (t) => {
  const f = await fixture(t),
    driver = await f.create(),
    secret = data(await f.issue(driver.id), 201),
    session = await f.login(secret);
  assert.match(secret.code, /^DR-/);
  assert.match(secret.pin, /^\d{6}$/);
  const list = data(await f.call('GET', '/v1/ops/drivers'));
  assert.equal(list.length, 1);
  assert.equal(list[0].userId, session.account.id);
  assert.ok(list[0].editToken);
  assert.equal(JSON.stringify(list).includes(secret.pin), false);
  const rows = (
    await f.owner.query(
      'SELECT u.role,d.user_id,c.must_change_pin,c.pin_version FROM app.drivers d JOIN app.users u ON u.id=d.user_id JOIN app.driver_credentials c ON c.driver_id=d.id WHERE d.id=$1',
      [driver.id],
    )
  ).rows;
  assert.deepEqual(rows, [
    { role: 'driver', user_id: session.account.id, must_change_pin: true, pin_version: 1 },
  ]);
  const receipt = (
    await f.owner.query(
      "SELECT response_body,secret_ciphertext FROM app.driver_commands WHERE operation='issueDriverCredential'",
    )
  ).rows[0];
  assert.equal(receipt.response_body, null);
  assert.ok(receipt.secret_ciphertext);
  assert.equal(receipt.secret_ciphertext.includes(secret.pin), false);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.driver_events')).rows[0].n,
    2,
  );
});

test('DRV-02: same-key first issue actually contends and replays one secret without orphan principals', async (t) => {
  const f = await fixture(t),
    driver = await f.create(),
    key = randomUUID(),
    blocker = await f.lockUser(f.ops.account.id);
  const a = f.issue(driver.id, key),
    b = f.issue(driver.id, key);
  try {
    await f.waitForWaiters(2);
  } finally {
    await blocker.query('COMMIT');
    blocker.release();
  }
  const [x, y] = await Promise.all([a, b]);
  assert.deepEqual(data(x, 201), data(y, 201));
  assert.deepEqual(
    (
      await f.owner.query(
        "SELECT (SELECT count(*)::int FROM app.users WHERE role='driver') AS users,(SELECT count(*)::int FROM app.driver_credentials) AS credentials,(SELECT count(*)::int FROM app.driver_commands WHERE operation='issueDriverCredential') AS receipts,(SELECT count(*)::int FROM app.driver_events WHERE operation='issueDriverCredential') AS events",
      )
    ).rows[0],
    { users: 1, credentials: 1, receipts: 1, events: 1 },
  );
  assert.equal((await f.issue(driver.id)).statusCode, 409);
});

test('DRV-03: explicit code normalization, collision rolls back principal and receipt, input conflict', async (t) => {
  const f = await fixture(t),
    one = await f.create(),
    two = await f.create(),
    key = randomUUID();
  const secret = data(await f.issue(one.id, key, { code: 'dr-b7k9' }), 201);
  assert.equal(secret.code, 'DR-B7K9');
  assert.deepEqual(data(await f.issue(one.id, key, { code: 'DR-B7K9' }), 201), secret);
  assert.equal((await f.issue(one.id, key, { code: 'DR-C7K9' })).statusCode, 409);
  assert.equal((await f.issue(two.id, randomUUID(), { code: 'DR-B7K9' })).statusCode, 409);
  assert.equal(
    (await f.owner.query('SELECT user_id FROM app.drivers WHERE id=$1', [two.id])).rows[0].user_id,
    null,
  );
  assert.equal(
    (await f.owner.query("SELECT count(*)::int AS n FROM app.users WHERE role='driver'")).rows[0].n,
    1,
  );
  data(await f.issue(two.id, randomUUID(), { code: 'DR-C7K9' }), 201);
});

test('DRV-04: reset revokes all sessions atomically, replay preserves PIN and obsolete generations never replay', async (t) => {
  const f = await fixture(t),
    driver = await f.create(),
    issueKey = randomUUID(),
    old = data(await f.issue(driver.id, issueKey), 201);
  const first = await f.login(old),
    second = await f.login(old),
    key = randomUUID(),
    fresh = data(await f.reset(driver.id, key));
  assert.notEqual(fresh.pin, old.pin);
  assert.deepEqual(data(await f.reset(driver.id, key)), fresh);
  for (const session of [first, second])
    assert.equal(
      (await f.request('GET', '/v1/me/sessions', undefined, session.accessToken)).statusCode,
      401,
    );
  assert.equal(
    (await f.request('POST', '/v1/auth/driver', { ...old, ownDevice: true })).statusCode,
    401,
  );
  await f.login(fresh);
  const stale = await f.issue(driver.id, issueKey);
  assert.equal(stale.statusCode, 409);
  assert.match(stale.body, /secret_no_longer_available/);
  assert.equal(
    (
      await f.owner.query('SELECT pin_version FROM app.driver_credentials WHERE driver_id=$1', [
        driver.id,
      ])
    ).rows[0].pin_version,
    2,
  );
});

test('DRV-05: event failure rolls back reset, sessions and key; same-key retry succeeds', async (t) => {
  const f = await fixture(t),
    driver = await f.create(),
    old = data(await f.issue(driver.id), 201),
    session = await f.login(old),
    key = randomUUID();
  await f.owner.query(
    "CREATE FUNCTION app.test_fail_driver_event() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN IF NEW.operation='resetDriverPin' THEN RAISE EXCEPTION 'injected_driver_event_failure'; END IF; RETURN NEW; END $$; CREATE TRIGGER test_fail_driver_event BEFORE INSERT ON app.driver_events FOR EACH ROW EXECUTE FUNCTION app.test_fail_driver_event()",
  );
  assert.equal((await f.reset(driver.id, key)).statusCode, 500);
  assert.equal(
    (
      await f.owner.query('SELECT pin_version FROM app.driver_credentials WHERE driver_id=$1', [
        driver.id,
      ])
    ).rows[0].pin_version,
    1,
  );
  data(await f.request('GET', '/v1/me/sessions', undefined, session.accessToken));
  assert.equal(
    (
      await f.owner.query('SELECT count(*)::int AS n FROM app.driver_commands WHERE key_hash=$1', [
        hashToken(key),
      ])
    ).rows[0].n,
    0,
  );
  await f.owner.query('DROP TRIGGER test_fail_driver_event ON app.driver_events');
  data(await f.reset(driver.id, key));
  assert.equal(
    (await f.request('GET', '/v1/me/sessions', undefined, session.accessToken)).statusCode,
    401,
  );
});

test('DRV-06: suspension, reset, unlock and activation remain distinct; revoked sessions never revive', async (t) => {
  const f = await fixture(t),
    driver = await f.create(),
    old = data(await f.issue(driver.id), 201),
    session = await f.login(old);
  data(await f.action(driver.id, 'suspend'), 204);
  const key = randomUUID(),
    fresh = data(await f.reset(driver.id, key));
  assert.deepEqual(data(await f.reset(driver.id, key)), fresh);
  data(await f.action(driver.id, 'unlock'), 204);
  assert.equal(
    (await f.request('POST', '/v1/auth/driver', { ...fresh, ownDevice: true })).statusCode,
    403,
  );
  data(await f.action(driver.id, 'activate'), 204);
  await f.login(fresh);
  assert.equal(
    (await f.request('GET', '/v1/me/sessions', undefined, session.accessToken)).statusCode,
    401,
  );
});

test('DRV-07: self PIN change rejects weak/reused PIN and revokes every session on success', async (t) => {
  const f = await fixture(t),
    driver = await f.create(),
    secret = data(await f.issue(driver.id), 201),
    one = await f.login(secret),
    two = await f.login(secret);
  const change = (newPin: string) =>
    f.request('POST', '/v1/auth/driver/pin', { currentPin: secret.pin, newPin }, one.accessToken, {
      'idempotency-key': randomUUID(),
    });
  assert.equal((await change('123456')).statusCode, 400);
  assert.equal((await change(secret.pin)).statusCode, 400);
  const newPin = secret.pin === '738194' ? '849205' : '738194';
  data(await change(newPin), 204);
  for (const s of [one, two])
    assert.equal(
      (await f.request('GET', '/v1/me/sessions', undefined, s.accessToken)).statusCode,
      401,
    );
  await f.login({ ...secret, pin: newPin });
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT must_change_pin,pin_version FROM app.driver_credentials WHERE driver_id=$1',
        [driver.id],
      )
    ).rows[0],
    { must_change_pin: false, pin_version: 2 },
  );
});

test('DRV-08: wrong current PIN commits lockout counters but no successful receipt', async (t) => {
  const f = await fixture(t),
    driver = await f.create(),
    secret = data(await f.issue(driver.id), 201),
    session = await f.login(secret),
    wrong = secret.pin === '738194' ? '849205' : '738194';
  for (let i = 0; i < 5; i++) {
    const res = await f.request(
      'POST',
      '/v1/auth/driver/pin',
      { currentPin: wrong, newPin: '937185' },
      session.accessToken,
      { 'idempotency-key': randomUUID() },
    );
    assert.equal(res.statusCode, i === 4 ? 423 : 401, res.body);
  }
  assert.equal(
    (
      await f.owner.query(
        "SELECT count(*)::int AS n FROM app.driver_commands WHERE operation='changeDriverPin'",
      )
    ).rows[0].n,
    0,
  );
  assert.equal(
    (
      await f.owner.query('SELECT failed_attempts FROM app.driver_credentials WHERE driver_id=$1', [
        driver.id,
      ])
    ).rows[0].failed_attempts,
    5,
  );
  data(await f.action(driver.id, 'unlock'), 204);
  await f.login(secret);
});

test('DRV-09: authorization precedes secret replay and commuter cannot provision or self-change', async (t) => {
  const f = await fixture(t),
    driver = await f.create(),
    key = randomUUID();
  data(await f.issue(driver.id, key), 201);
  const commuter = await f.sign('commuter');
  assert.equal(
    (
      await f.request('POST', '/v1/ops/drivers', { name: 'Forbidden' }, commuter.accessToken, {
        'x-trotxi-client': 'ops',
        'idempotency-key': randomUUID(),
      })
    ).statusCode,
    403,
  );
  assert.equal(
    (
      await f.request(
        'POST',
        '/v1/auth/driver/pin',
        { currentPin: '738194', newPin: '849205' },
        commuter.accessToken,
        { 'idempotency-key': randomUUID() },
      )
    ).statusCode,
    403,
  );
  await f.owner.query("UPDATE app.users SET role='commuter' WHERE id=$1", [f.ops.account.id]);
  assert.equal((await f.issue(driver.id, key)).statusCode, 403);
});

test('DRV-10: profile edits use resource tokens, replay before stale precondition and missing before preconditions', async (t) => {
  const f = await fixture(t),
    driver = await f.create({
      name: 'Original',
      phone: '+233241234567',
      licenseNumber: 'TEST-LIC',
    }),
    key = randomUUID();
  const edit = () =>
    f.call('PATCH', `/v1/ops/drivers/${driver.id}`, { name: 'Changed', phone: null }, key, {
      'if-match': driver.editToken,
    });
  const updated = data(await edit());
  assert.equal(updated.name, 'Changed');
  assert.equal(updated.phone, null);
  assert.equal(updated.licenseNumber, 'TEST-LIC');
  assert.deepEqual(data(await edit()), updated);
  assert.equal(
    (
      await f.call('PATCH', `/v1/ops/drivers/${driver.id}`, { name: 'Stale' }, randomUUID(), {
        'if-match': driver.editToken,
      })
    ).statusCode,
    412,
  );
  assert.equal(
    (await f.call('PATCH', `/v1/ops/drivers/${driver.id}`, { name: 'Missing token' })).statusCode,
    428,
  );
  assert.equal(
    (await f.call('PATCH', `/v1/ops/drivers/${randomUUID()}`, { name: 'Missing driver' }))
      .statusCode,
    404,
  );
});

test('DRV-11: link ownership cannot promote commuters or transfer credential access, archive revokes sessions', async (t) => {
  const f = await fixture(t),
    rider = await f.sign('rider');
  assert.equal(
    (await f.call('POST', '/v1/ops/drivers', { name: 'Wrong role', userId: rider.account.id }))
      .statusCode,
    409,
  );
  const driver = await f.create(),
    secret = data(await f.issue(driver.id), 201),
    session = await f.login(secret),
    list = data(await f.call('GET', '/v1/ops/drivers')),
    current = list[0];
  const second = await f.create(),
    secondSecret = data(await f.issue(second.id), 201),
    secondSession = await f.login(secondSecret);
  assert.equal(
    (
      await f.call(
        'PATCH',
        `/v1/ops/drivers/${driver.id}`,
        { userId: secondSession.account.id },
        randomUUID(),
        { 'if-match': current.editToken },
      )
    ).statusCode,
    409,
  );
  const archived = data(
    await f.call('PATCH', `/v1/ops/drivers/${driver.id}`, { archived: true }, randomUUID(), {
      'if-match': current.editToken,
    }),
  );
  assert.equal(archived.archived, true);
  assert.equal(
    (await f.request('GET', '/v1/me/sessions', undefined, session.accessToken)).statusCode,
    401,
  );
  assert.equal((await f.reset(driver.id)).statusCode, 409);
});

test('DRV-12: secret expiry refuses replay, bounded erasure preserves immutable tombstones and owner boundary', async (t) => {
  const f = await fixture(t),
    driver = await f.create();
  data(await f.issue(driver.id), 201);
  const key = randomUUID();
  await f.owner.query(
    `INSERT INTO app.driver_commands(id,actor_user_id,driver_id,operation,target,key_hash,input_hash,response_status,response_body,response_headers,secret_ciphertext,pin_version,created_at,replay_expires_at)
 SELECT gen_random_uuid(),actor_user_id,driver_id,operation,target,$1,input_hash,response_status,response_body,response_headers,secret_ciphertext,pin_version,transaction_timestamp()-interval '10 minutes',transaction_timestamp()-interval '5 minutes' FROM app.driver_commands WHERE operation='issueDriverCredential'`,
    [hashToken(key)],
  );
  const res = await f.issue(driver.id, key);
  assert.equal(res.statusCode, 409);
  assert.match(res.body, /secret_no_longer_available/);
  assert.equal(await purgeExpiredDriverSecrets(f.runtime, 1), 1);
  assert.equal(await purgeExpiredDriverSecrets(f.runtime, 1), 0);
  const receipt = (
    await f.owner.query('SELECT id,secret_ciphertext FROM app.driver_commands WHERE key_hash=$1', [
      hashToken(key),
    ])
  ).rows[0];
  assert.equal(receipt.secret_ciphertext, null);
  await assert.rejects(
    f.runtime.query("UPDATE app.driver_commands SET secret_ciphertext='replacement' WHERE id=$1", [
      receipt.id,
    ]),
    /immutable_driver_receipt/,
  );
  await assert.rejects(
    f.runtime.query('UPDATE app.driver_commands SET response_status=204 WHERE id=$1', [receipt.id]),
    /permission denied/,
  );
  await assert.rejects(f.runtime.query('DELETE FROM app.driver_events'), /permission denied/);
  assert.equal(
    (
      await f.owner.query(
        "SELECT pg_has_role($1,(SELECT relowner FROM pg_class WHERE oid='app.driver_events'::regclass),'USAGE') AS owns",
        [f.role],
      )
    ).rows[0].owns,
    false,
  );
});

test('DRV-13: concurrent sign-in and reset serialize on the principal; old PIN cannot leave a surviving session', async (t) => {
  const f = await fixture(t),
    driver = await f.create(),
    secret = data(await f.issue(driver.id), 201),
    session = await f.login(secret),
    blocker = await f.lockUser(session.account.id);
  const reset = f.reset(driver.id),
    signin = f.request('POST', '/v1/auth/driver', { ...secret, ownDevice: true });
  try {
    await f.waitForWaiters(2);
  } finally {
    await blocker.query('COMMIT');
    blocker.release();
  }
  const [resetResponse, signResponse] = await Promise.all([reset, signin]);
  data(resetResponse);
  assert.ok([200, 401].includes(signResponse.statusCode), signResponse.body);
  if (signResponse.statusCode === 200)
    assert.equal(
      (await f.request('GET', '/v1/me/sessions', undefined, signResponse.json().data.accessToken))
        .statusCode,
      401,
    );
  assert.equal(
    (
      await f.owner.query(
        'SELECT count(*)::int AS n FROM app.auth_sessions WHERE user_id=$1 AND revoked_at IS NULL',
        [session.account.id],
      )
    ).rows[0].n,
    0,
  );
});

test('DRV-14: open trip blocks archive and trip history blocks account transfer', async (t) => {
  const f = await fixture(t),
    driver = await f.create(),
    route = data(await f.call('POST', '/v1/ops/routes', { name: 'Driver archive test' }), 201),
    stop = data(
      await f.call('POST', '/v1/ops/stops', {
        name: 'Depot',
        location: { latitude: 5.6, longitude: -0.2 },
      }),
      201,
    ),
    pattern = data(
      await f.call('POST', '/v1/ops/route-patterns', { routeId: route.id, direction: 'outbound' }),
      201,
    ),
    version = data(
      await f.call('POST', `/v1/ops/route-patterns/${pattern.id}/versions`, {
        stops: [
          { stopId: stop.id, name: 'Depot', location: { latitude: 5.6, longitude: -0.2 } },
          { stopId: stop.id, name: 'Depot return', location: { latitude: 5.6, longitude: -0.2 } },
        ],
        geometry: {
          points: [
            { latitude: 5.6, longitude: -0.2 },
            { latitude: 5.6, longitude: -0.21 },
            { latitude: 5.6, longitude: -0.2 },
          ],
          stopDistancesMeters: [0, 2200],
        },
      }),
      201,
    );
  const now = new Date(),
    yesterday = new Date(now.getTime() - 86400000).toISOString();
  data(
    await f.call(
      'POST',
      `/v1/ops/route-patterns/${pattern.id}/versions/${version.id}/publish`,
      { reason: 'Test publish', effectiveFrom: yesterday },
      randomUUID(),
      { 'if-match': version.editToken },
    ),
  );
  const schedule = data(
      await f.call('POST', '/v1/ops/service-schedules', {
        departure: { kind: 'new' },
        patternVersionId: version.id,
        serviceWindow: 'morning',
        localDeparture: '06:30',
        timeZone: 'Africa/Accra',
        weekdays: [1, 2, 3, 4, 5, 6, 7],
        effectiveFrom: yesterday.slice(0, 10),
        effectiveTo: null,
      }),
      201,
    ),
    trip = data(
      await f.call('POST', '/v1/ops/trips', {
        scheduleId: schedule.id,
        serviceDate: now.toISOString().slice(0, 10),
        scheduledAt: now.toISOString(),
      }),
      201,
    );
  // Owner-only transport fact: no booking adapter is faked to claim assignment delivery.
  await f.owner.query('UPDATE app.trips SET assigned_driver_id=$2 WHERE id=$1', [
    trip.id,
    driver.id,
  ]);
  const archive = () =>
    f.call('PATCH', `/v1/ops/drivers/${driver.id}`, { archived: true }, randomUUID(), {
      'if-match': driver.editToken,
    });
  const blocked = await archive();
  assert.equal(blocked.statusCode, 409);
  assert.match(blocked.body, /driver_has_open_trips/);
  assert.equal(
    (await f.owner.query('SELECT archived_at FROM app.drivers WHERE id=$1', [driver.id])).rows[0]
      .archived_at,
    null,
  );
  await f.owner.query("UPDATE app.trips SET status='cancelled' WHERE id=$1", [trip.id]);
  data(await archive());
  const tomorrow = new Date(now.getTime() + 86400000).toISOString();
  const nextTrip = data(
    await f.call('POST', '/v1/ops/trips', {
      scheduleId: schedule.id,
      serviceDate: tomorrow.slice(0, 10),
      scheduledAt: tomorrow,
    }),
    201,
  );
  await assert.rejects(
    f.owner.query('UPDATE app.trips SET assigned_driver_id=$2 WHERE id=$1', [
      nextTrip.id,
      driver.id,
    ]),
    (error) =>
      (error as { code: string; message: string }).code === '23514' &&
      (error as Error).message === 'unavailable_driver',
  );
  // Provisioning may establish the first principal; a later transfer is forbidden
  // even when there is no credential, because operated/cancelled history exists.
  const a = randomUUID(),
    b = randomUUID();
  await f.owner.query("INSERT INTO app.users(id,role) VALUES ($1,'driver'),($2,'driver')", [a, b]);
  await f.owner.query('UPDATE app.drivers SET user_id=$2 WHERE id=$1', [driver.id, a]);
  await assert.rejects(
    f.owner.query('UPDATE app.drivers SET user_id=$2 WHERE id=$1', [driver.id, b]),
    (error) =>
      (error as { code: string; message: string }).code === '23514' &&
      (error as Error).message === 'explicit_driver_reassignment_required',
  );
});

test('DRV-16: database enforces driver receipt target bounds including both valid boundaries', async (t) => {
  const f = await fixture(t),
    driver = await f.create();
  const source = (
    await f.owner.query(
      "SELECT id FROM app.driver_commands WHERE driver_id=$1 AND operation='createDriver'",
      [driver.id],
    )
  ).rows[0].id;
  // Insert receipt fixtures through the narrow runtime role: validation must
  // come from PostgreSQL, not routed UUID validation or an application check.
  const insert = (target: string) =>
    f.runtime.query(
      `INSERT INTO app.driver_commands
    (id,actor_user_id,driver_id,operation,target,key_hash,input_hash,response_status,
     response_body,response_headers,secret_ciphertext,pin_version,created_at,replay_expires_at)
    SELECT $1,actor_user_id,driver_id,operation,$2::text,$3,input_hash,response_status,
     response_body,response_headers,secret_ciphertext,pin_version,created_at,replay_expires_at
    FROM app.driver_commands WHERE id=$4 RETURNING target`,
      [randomUUID(), target, hashToken(randomUUID()), source],
    );
  for (const target of ['', 'x'.repeat(129)]) {
    await assert.rejects(insert(target), (error) => {
      const e = error as { code?: string; constraint?: string };
      return e.code === '23514' && e.constraint === 'driver_commands_target_length';
    });
  }
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.driver_commands')).rows[0].n,
    1,
  );
  for (const target of ['x', 'x'.repeat(128)])
    assert.equal((await insert(target)).rows[0].target, target);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.driver_commands')).rows[0].n,
    3,
  );
});

test('DRV-15: event attribution FK is deferred and rejects another actor; lists paginate with per-resource tokens', async (t) => {
  const f = await fixture(t),
    one = await f.create(),
    two = await f.create();
  const response = await f.call('GET', '/v1/ops/drivers?limit=1'),
    first = data(response);
  assert.equal(first.length, 1);
  assert.equal(first[0].id, one.id);
  const cursor = response.json().page.nextCursor;
  assert.ok(cursor);
  const next = data(
    await f.call('GET', `/v1/ops/drivers?limit=1&cursor=${encodeURIComponent(cursor)}`),
  );
  assert.equal(next[0].id, two.id);
  assert.ok(next[0].editToken);
  const receipt = (
      await f.owner.query('SELECT * FROM app.driver_commands WHERE driver_id=$1', [one.id])
    ).rows[0],
    foreign = await f.sign('foreign');
  const client = await f.runtime.connect();
  await client.query('BEGIN');
  try {
    const id = randomUUID(),
      key = hashToken(randomUUID());
    await client.query(
      'INSERT INTO app.driver_events(driver_id,actor_user_id,command_id,operation) VALUES ($1,$2,$3,$4)',
      [one.id, foreign.account.id, id, 'updateDriver'],
    );
    await client.query(
      `INSERT INTO app.driver_commands(id,actor_user_id,driver_id,operation,target,key_hash,input_hash,response_status,response_body,response_headers,created_at,replay_expires_at)
   VALUES ($1,$2,$3,'updateDriver',$3::uuid::text,$4,$5,204,NULL,'{}',clock_timestamp(),clock_timestamp()+interval '7 days')`,
      [id, f.ops.account.id, one.id, key, receipt.input_hash],
    );
    await assert.rejects(
      client.query('COMMIT'),
      (error) => (error as { code: string }).code === '23503',
    );
  } finally {
    await client.query('ROLLBACK');
    client.release();
  }
  assert.equal(
    (
      await f.owner.query(
        "SELECT count(*)::int AS n FROM app.driver_events WHERE operation='updateDriver'",
      )
    ).rows[0].n,
    0,
  );
});

test('DRV-20: a driver can re-read their own record long after the sign-in response is gone', async (t) => {
  const f = await fixture(t),
    driver = await f.create(),
    secret = data(await f.issue(driver.id), 201),
    session = await f.login(secret);

  const me = async (token?: string) =>
    f.request('GET', '/v1/driver/me', undefined, token, { 'x-trotxi-client': 'driver' });

  const mine = data(await me(session.accessToken));
  assert.equal(mine.id, driver.id);
  assert.equal(mine.name, driver.name);
  // The point of the endpoint: sign-in carried {id, name} and nothing else,
  // and a session outlives that response by weeks.
  assert.equal(mine.licenseNumber, driver.licenseNumber ?? null);
  assert.equal(mine.credential.driverCode, secret.code);
  assert.equal(mine.credential.status, 'active');
  assert.equal(mine.credential.mustChangePin, true);
  assert.equal(mine.credential.lockedUntil, null);
  // The moderation state ops keeps about a driver is not the driver's to read.
  assert.equal(mine.failedAttempts, undefined);
  assert.equal(mine.userId, undefined);
  assert.equal(mine.archivedAt, undefined);

  // An admin is not a driver, and neither is an anonymous caller.
  const asOps = await f.request('GET', '/v1/driver/me', undefined, f.ops.accessToken, {
    'x-trotxi-client': 'driver',
  });
  assert.equal(asOps.statusCode, 403, asOps.body);
  assert.equal((await me()).statusCode, 401);
});

test('DRV-21: a suspended driver is refused this read too, not told why', async (t) => {
  const f = await fixture(t),
    driver = await f.create(),
    secret = data(await f.issue(driver.id), 201),
    session = await f.login(secret);
  assert.equal(
    data(
      await f.request('GET', '/v1/driver/me', undefined, session.accessToken, {
        'x-trotxi-client': 'driver',
      }),
    ).credential.status,
    'active',
  );

  await f.action(driver.id, 'suspend');

  // Session authorization refuses any credential that is not active, before a
  // handler runs, so this endpoint cannot be the one that explains a
  // suspension: the driver is already locked out of every authenticated call.
  // Recorded rather than worked around. Telling a suspended driver why would
  // mean an unauthenticated or specially exempted read, which is a decision
  // about what a revoked credential may still see, not a missing handler.
  const refused = await f.request('GET', '/v1/driver/me', undefined, session.accessToken, {
    'x-trotxi-client': 'driver',
  });
  assert.equal(refused.statusCode, 401, refused.body);
  assert.equal(refused.json().error.code, 'unauthenticated');
});
