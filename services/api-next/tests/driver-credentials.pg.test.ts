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
import { TransactionalEmail } from '../src/notifications/email.js';
import { EmailSendError } from '../src/notifications/resend.js';
import type { EmailMessage } from '../src/notifications/resend.js';
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
  emailEnabled = true,
  sendImmediately = false,
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
  // A real outbox and worker with a recording provider: nothing leaves the
  // machine. failNext makes the next send fail the way Resend can.
  const sent: { message: EmailMessage; key: string }[] = [];
  const mailer = { failNext: null as EmailSendError | null };
  const email = new TransactionalEmail({
    pool: runtime,
    encryptionKey: Buffer.alloc(32, 4),
    staging: true,
    sender: {
      send: async (message, key) => {
        if (mailer.failNext) {
          const error = mailer.failNext;
          mailer.failNext = null;
          throw error;
        }
        sent.push({ message, key });
        return `provider-${sent.length}`;
      },
    },
  });
  const app = await createReplacementApp({
    // Queue-only by default, so tests drive the worker explicitly and can
    // observe a message while it waits. Production also sends right away.
    ...(emailEnabled
      ? {
          driverEmail: sendImmediately ? email : { queueCredential: email.queueCredential },
        }
      : {}),
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
    email,
    sent,
    mailer,
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

async function fixture(t: TestContext, emailEnabled = true, sendImmediately = false) {
  const f = await setup(t, 1000, {}, emailEnabled, sendImmediately),
    ops = await f.sign('operator');
  await f.owner.query("UPDATE app.users SET role='admin' WHERE id=$1", [ops.account.id]);
  // A verified operator. The second factor itself is tested in auth.pg.test.ts;
  // these tests are about credentials, so the admin here has passed it.
  await f.owner.query(
    'UPDATE app.auth_sessions SET admin_verified_at=clock_timestamp() WHERE user_id=$1',
    [ops.account.id],
  );
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
  const reset = async (id: string, key = randomUUID(), extra: Record<string, unknown> = {}) =>
    call(
      'POST',
      `/v1/ops/drivers/${id}/credentials/reset-pin`,
      { reason: 'Test reset', ...extra },
      key,
    );
  const action = async (id: string, action: string) =>
    call('POST', `/v1/ops/drivers/${id}/credentials/actions`, {
      action,
      reason: 'Test state change',
    });
  const login = async (secret: { code: string; pin: string }) =>
    data(
      await f.request('POST', '/v1/auth/driver', {
        code: secret.code,
        pin: secret.pin,
        ownDevice: true,
      }),
    );
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
    (await f.request('POST', '/v1/auth/driver', { code: old.code, pin: old.pin, ownDevice: true }))
      .statusCode,
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
  // Still signed in: a temporary-PIN session may read its own record.
  data(
    await f.request('GET', '/v1/driver/me', undefined, session.accessToken, {
      'x-trotxi-client': 'driver',
    }),
  );
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
    (
      await f.request('POST', '/v1/auth/driver', {
        code: fresh.code,
        pin: fresh.pin,
        ownDevice: true,
      })
    ).statusCode,
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
    signin = f.request('POST', '/v1/auth/driver', {
      code: secret.code,
      pin: secret.pin,
      ownDevice: true,
    });
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

// ---- Email onboarding and temporary PINs (migration 029) -------------------

const asDriver = { 'x-trotxi-client': 'driver' };
const outbox = async (f: { owner: pg.Pool }, userId: string) =>
  (
    await f.owner.query(
      `SELECT id,kind,state,failure_code,payload_ciphertext,source_id,expires_at
       FROM app.email_outbox WHERE user_id=$1 ORDER BY created_at,id`,
      [userId],
    )
  ).rows;

test('DRV-30: onboarding queues one encrypted email with the credential, replay adds none, the worker sends it once', async (t) => {
  const f = await fixture(t),
    driver = await f.create({ name: 'Ama Mensah', email: 'ama.driver@example.test' }),
    key = randomUUID();
  assert.equal(driver.email, 'ama.driver@example.test');
  assert.equal(driver.credential, null);
  const secret = data(await f.issue(driver.id, key, { emailInstructions: true }), 201);
  assert.match(secret.code, /^DR-[A-Z2-9]{4}$/);
  assert.equal(secret.email.state, 'queued', 'queued, never "sent"');
  assert.equal(secret.email.to, 'ama.driver@example.test');
  const hours = (Date.parse(secret.temporaryPinExpiresAt) - Date.now()) / 3600000;
  assert.ok(hours > 71.9 && hours <= 72, `temporary PIN window ${hours}h`);
  // Same key, same answer, and still exactly one message.
  assert.deepEqual(data(await f.issue(driver.id, key, { emailInstructions: true }), 201), secret);
  const listed = data(await f.call('GET', '/v1/ops/drivers')).find(
    (row: { id: string }) => row.id === driver.id,
  );
  const userId = listed.userId;
  const rows = await outbox(f, userId);
  assert.equal(rows.length, 1);
  assert.equal(rows[0].kind, 'driver_credentials_issued');
  assert.equal(rows[0].state, 'pending');
  assert.equal(new Date(rows[0].expires_at).toISOString(), secret.temporaryPinExpiresAt);
  // The PIN exists only inside the ciphertext: not in the outbox row, the
  // receipt or the audit event.
  const everything = JSON.stringify([
    rows,
    (await f.owner.query('SELECT * FROM app.driver_commands WHERE driver_id=$1', [driver.id])).rows,
    (await f.owner.query('SELECT * FROM app.driver_events WHERE driver_id=$1', [driver.id])).rows,
  ]);
  assert.ok(!everything.includes(secret.pin), 'PIN stored in plaintext');
  assert.deepEqual(listed.credential, {
    driverCode: secret.code,
    status: 'active',
    mustChangePin: true,
    temporaryPinExpiresAt: secret.temporaryPinExpiresAt,
    lockedUntil: null,
  });
  assert.equal(listed.credentialEmail.purpose, 'onboarding');
  assert.equal(listed.credentialEmail.state, 'queued');

  const stats = await f.email.drain(10);
  assert.equal(stats.accepted, 1);
  assert.equal(f.sent.length, 1);
  const { message, key: providerKey } = f.sent[0]!;
  assert.equal(message.to, 'ama.driver@example.test');
  assert.equal(providerKey, `trotxi-email/${rows[0].id}`);
  assert.match(message.subject, /^\[STAGING TEST\] Your Trotxi driver sign-in details$/);
  assert.ok(message.text.includes(`Driver code: ${secret.code}`));
  assert.ok(message.text.includes(`Temporary PIN: ${secret.pin}`));
  assert.ok(message.text.includes('choose your own six-digit PIN'));
  assert.ok(!message.text.includes('No real payment'), 'driver mail has its own staging note');
  assert.ok(!('driverId' in message) && !('pinVersion' in message), 'binding stays internal');
  const after = (await outbox(f, userId))[0];
  assert.equal(after.state, 'accepted');
  assert.equal(after.payload_ciphertext, null, 'payload scrubbed once accepted');
  const shown = data(await f.call('GET', '/v1/ops/drivers')).find(
    (row: { id: string }) => row.id === driver.id,
  );
  assert.equal(shown.credentialEmail.state, 'provider_accepted');
});

test('DRV-31: email is refused without an address or a configured sender, and nothing is issued', async (t) => {
  const f = await fixture(t),
    bare = await f.create({ name: 'No Address' });
  const missing = await f.issue(bare.id, randomUUID(), { emailInstructions: true });
  assert.equal(missing.statusCode, 409, missing.body);
  assert.equal(missing.json().error.code, 'driver_email_missing');
  assert.equal(
    (await f.owner.query('SELECT 1 FROM app.driver_credentials WHERE driver_id=$1', [bare.id]))
      .rowCount,
    0,
  );
  const invalid = await f.call('POST', '/v1/ops/drivers', { name: 'Bad', email: 'not-an-address' });
  assert.equal(invalid.statusCode, 400, invalid.body);
  // Without email, issue works exactly as before and says no email was queued.
  const plain = data(await f.issue(bare.id), 201);
  assert.equal(plain.email, null);

  const g = await fixture(t, false),
    driver = await g.create({ name: 'Unconfigured', email: 'u.driver@example.test' });
  const refused = await g.issue(driver.id, randomUUID(), { emailInstructions: true });
  assert.equal(refused.statusCode, 503, refused.body);
  assert.equal(refused.json().error.code, 'email_unavailable');
  assert.equal(
    (await g.owner.query('SELECT 1 FROM app.driver_credentials WHERE driver_id=$1', [driver.id]))
      .rowCount,
    0,
    'no credential without the email that was asked for',
  );
});

test('DRV-32: a failed issue leaves neither the credential nor its email', async (t) => {
  const f = await fixture(t),
    driver = await f.create({ name: 'Rollback', email: 'r.driver@example.test' }),
    key = randomUUID();
  await f.owner.query(
    "CREATE FUNCTION app.test_fail_issue_event() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN IF NEW.operation='issueDriverCredential' THEN RAISE EXCEPTION 'injected'; END IF; RETURN NEW; END $$; CREATE TRIGGER test_fail_issue_event BEFORE INSERT ON app.driver_events FOR EACH ROW EXECUTE FUNCTION app.test_fail_issue_event()",
  );
  assert.equal((await f.issue(driver.id, key, { emailInstructions: true })).statusCode, 500);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.email_outbox')).rows[0].n,
    0,
  );
  assert.equal(
    (await f.owner.query('SELECT 1 FROM app.driver_credentials WHERE driver_id=$1', [driver.id]))
      .rowCount,
    0,
  );
  await f.owner.query('DROP TRIGGER test_fail_issue_event ON app.driver_events');
  data(await f.issue(driver.id, key, { emailInstructions: true }), 201);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.email_outbox')).rows[0].n,
    1,
  );
});

test('DRV-33: a reset, PIN change or address change cancels mail that would deliver an obsolete PIN', async (t) => {
  const f = await fixture(t),
    driver = await f.create({ name: 'Kofi Asare', email: 'kofi.driver@example.test' });
  const first = data(await f.issue(driver.id, randomUUID(), { emailInstructions: true }), 201);
  const userId = (await f.owner.query('SELECT user_id FROM app.drivers WHERE id=$1', [driver.id]))
    .rows[0].user_id;
  const reset = data(await f.reset(driver.id, randomUUID(), { emailInstructions: true }));
  assert.notEqual(reset.pin, first.pin);
  let rows = await outbox(f, userId);
  assert.deepEqual(
    rows.map((r) => [r.kind, r.state, r.failure_code]),
    [
      ['driver_credentials_issued', 'cancelled', 'stale_credential'],
      ['driver_pin_reset', 'pending', null],
    ],
  );
  assert.equal(rows[0].payload_ciphertext, null, 'the cancelled PIN is scrubbed');

  // Address edited while the reset mail waits: it was written for the old one.
  const current = data(await f.call('GET', '/v1/ops/drivers')).find(
    (row: { id: string }) => row.id === driver.id,
  );
  data(
    await f.call(
      'PATCH',
      `/v1/ops/drivers/${driver.id}`,
      { email: 'kofi.new@example.test' },
      randomUUID(),
      {
        'if-match': current.editToken,
      },
    ),
  );
  rows = await outbox(f, userId);
  assert.equal(rows[1].state, 'cancelled');
  assert.equal(rows[1].failure_code, 'stale_credential');

  // A fresh reset to the new address, then the driver sets a private PIN
  // before the worker runs: the waiting mail must not go out.
  const again = data(await f.reset(driver.id, randomUUID(), { emailInstructions: true }));
  assert.equal(again.email.to, 'kofi.new@example.test');
  const session = await f.login(again);
  const change = await f.request(
    'POST',
    '/v1/auth/driver/pin',
    { currentPin: again.pin, newPin: '572914' },
    session.accessToken,
    { ...asDriver, 'idempotency-key': randomUUID() },
  );
  assert.equal(change.statusCode, 204, change.body);
  rows = await outbox(f, userId);
  assert.deepEqual(
    rows.map((r) => r.state),
    ['cancelled', 'cancelled', 'cancelled'],
  );
  assert.equal((await f.email.drain(10)).accepted, 0);
  assert.equal(f.sent.length, 0);
});

test('DRV-34: the worker rechecks the credential version before sending, and erasure cancels', async (t) => {
  const f = await fixture(t),
    driver = await f.create({ name: 'Race', email: 'race.driver@example.test' });
  data(await f.issue(driver.id, randomUUID(), { emailInstructions: true }), 201);
  const userId = (await f.owner.query('SELECT user_id FROM app.drivers WHERE id=$1', [driver.id]))
    .rows[0].user_id;
  // A change the cancellation did not see (another writer, a restored
  // backup): the version moved, the mail is still pending.
  await f.owner.query(
    'UPDATE app.driver_credentials SET pin_version=pin_version+1 WHERE driver_id=$1',
    [driver.id],
  );
  const stats = await f.email.drain(10);
  assert.equal(stats.cancelled, 1);
  assert.equal(f.sent.length, 0);
  assert.equal((await outbox(f, userId))[0].failure_code, 'stale_credential');

  const other = await f.create({ name: 'Erased', email: 'erased.driver@example.test' });
  data(await f.issue(other.id, randomUUID(), { emailInstructions: true }), 201);
  const otherUser = (await f.owner.query('SELECT user_id FROM app.drivers WHERE id=$1', [other.id]))
    .rows[0].user_id;
  await f.owner.query('UPDATE app.users SET deleted_at=clock_timestamp() WHERE id=$1', [otherUser]);
  const [erased] = await outbox(f, otherUser);
  assert.equal(erased.state, 'cancelled');
  assert.equal(erased.failure_code, 'account_closed');
});

test('DRV-35: a temporary PIN reaches only setup, the change revokes it, and the private PIN reaches work', async (t) => {
  const f = await fixture(t),
    driver = await f.create({ name: 'Setup Driver' }),
    secret = data(await f.issue(driver.id), 201),
    session = await f.login(secret);
  assert.equal(session.mustChangePin, true);
  assert.equal(session.temporaryPinExpiresAt, secret.temporaryPinExpiresAt);
  const blocked = await f.request(
    'GET',
    '/v1/driver/trips',
    undefined,
    session.accessToken,
    asDriver,
  );
  assert.equal(blocked.statusCode, 403, blocked.body);
  assert.equal(blocked.json().error.code, 'pin_change_required');
  const self = data(
    await f.request('GET', '/v1/driver/me', undefined, session.accessToken, asDriver),
  );
  assert.equal(self.credential.mustChangePin, true);
  // Identifying the account is allowed too: it is how a restored app finds
  // out it must send the driver to PIN setup. Sessions management is not.
  data(await f.request('GET', '/v1/me', undefined, session.accessToken, asDriver));
  assert.equal(
    (await f.request('GET', '/v1/me/sessions', undefined, session.accessToken, asDriver))
      .statusCode,
    403,
  );
  assert.equal(self.credential.temporaryPinExpiresAt, secret.temporaryPinExpiresAt);
  // Restoring the session later changes nothing: the rule is on the server.
  const refreshed = data(
    await f.request('POST', '/v1/auth/refresh', { refreshToken: session.refreshToken }),
  );
  assert.equal(
    (await f.request('GET', '/v1/driver/trips', undefined, refreshed.accessToken, asDriver))
      .statusCode,
    403,
  );
  const key = randomUUID(),
    body = { currentPin: secret.pin, newPin: '483920' };
  const change = await f.request('POST', '/v1/auth/driver/pin', body, refreshed.accessToken, {
    ...asDriver,
    'idempotency-key': key,
  });
  assert.equal(change.statusCode, 204, change.body);
  // The change revokes every session, including the one that made it.
  assert.equal(
    (await f.request('GET', '/v1/driver/me', undefined, refreshed.accessToken, asDriver))
      .statusCode,
    401,
  );
  const fresh = await f.login({ code: secret.code, pin: '483920' });
  assert.equal(fresh.mustChangePin, false);
  assert.equal(fresh.temporaryPinExpiresAt, null);
  const trips = await f.request('GET', '/v1/driver/trips', undefined, fresh.accessToken, asDriver);
  assert.equal(trips.statusCode, 200, trips.body);
  // Ops never sees the private PIN: nothing it can read carries it.
  const listed = JSON.stringify(data(await f.call('GET', '/v1/ops/drivers')));
  assert.ok(!listed.includes('483920'));
});

test('DRV-36: an expired temporary PIN opens no session and cannot be changed; a reset issues a new window', async (t) => {
  const f = await fixture(t),
    driver = await f.create({ name: 'Late Driver' }),
    secret = data(await f.issue(driver.id), 201),
    session = await f.login(secret);
  await f.owner.query(
    "UPDATE app.driver_credentials SET temporary_pin_expires_at=clock_timestamp()-interval '1 minute' WHERE driver_id=$1",
    [driver.id],
  );
  const signIn = await f.request('POST', '/v1/auth/driver', {
    code: secret.code,
    pin: secret.pin,
    ownDevice: true,
  });
  assert.equal(signIn.statusCode, 403, signIn.body);
  assert.equal(signIn.json().error.code, 'temporary_pin_expired');
  const change = await f.request(
    'POST',
    '/v1/auth/driver/pin',
    { currentPin: secret.pin, newPin: '483920' },
    session.accessToken,
    { ...asDriver, 'idempotency-key': randomUUID() },
  );
  assert.equal(change.statusCode, 403, change.body);
  assert.equal(change.json().error.code, 'temporary_pin_expired');
  // A wrong PIN is still just wrong: expiry is only revealed to the right one.
  const wrong = await f.request('POST', '/v1/auth/driver', {
    code: secret.code,
    pin: secret.pin === '111111' ? '222222' : '111111',
    ownDevice: true,
  });
  assert.equal(wrong.statusCode, 401);
  const renewed = data(await f.reset(driver.id));
  assert.ok(Date.parse(renewed.temporaryPinExpiresAt) > Date.now() + 71 * 3600000);
  assert.equal((await f.login(renewed)).mustChangePin, true);
});

test('DRV-37: only a verified operator issues or resets; drivers and commuters cannot', async (t) => {
  const f = await fixture(t),
    driver = await f.create({ name: 'Guarded', email: 'guarded@example.test' }),
    secret = data(await f.issue(driver.id), 201),
    temporary = await f.login(secret);
  data(
    await f.request(
      'POST',
      '/v1/auth/driver/pin',
      { currentPin: secret.pin, newPin: '759302' },
      temporary.accessToken,
      { ...asDriver, 'idempotency-key': randomUUID() },
    ),
    204,
  );
  const self = await f.login({ code: secret.code, pin: '759302' });
  const rider = await f.sign('rider-guard');
  for (const token of [self.accessToken, rider.accessToken]) {
    const refused = await f.request(
      'POST',
      `/v1/ops/drivers/${driver.id}/credentials/reset-pin`,
      { reason: 'not mine', emailInstructions: true },
      token,
      { 'idempotency-key': randomUUID() },
    );
    assert.equal(refused.statusCode, 403, refused.body);
  }
  // An admin whose passkey check has lapsed is sent to verify, not let through.
  await f.owner.query('UPDATE app.auth_sessions SET admin_verified_at=NULL WHERE user_id=$1', [
    f.ops.account.id,
  ]);
  const unverified = await f.reset(driver.id, randomUUID(), { emailInstructions: true });
  assert.equal(unverified.statusCode, 403);
  assert.equal(unverified.json().error.code, 'passkey_required');
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.email_outbox')).rows[0].n,
    0,
  );
});

test('DRV-38: a failed send retries with the same provider idempotency key', async (t) => {
  const f = await fixture(t),
    driver = await f.create({ name: 'Retry', email: 'retry.driver@example.test' });
  data(await f.issue(driver.id, randomUUID(), { emailInstructions: true }), 201);
  f.mailer.failNext = new EmailSendError(true);
  const first = await f.email.drain(10);
  assert.equal(first.retried, 1);
  const [row] = (
    await f.owner.query("SELECT id FROM app.email_outbox WHERE kind='driver_credentials_issued'")
  ).rows;
  await f.owner.query(
    "UPDATE app.email_outbox SET next_attempt_at=clock_timestamp()-interval '1 second' WHERE id=$1",
    [row.id],
  );
  assert.equal((await f.email.drain(10)).accepted, 1);
  assert.equal(f.sent.length, 1);
  assert.equal(f.sent[0]!.key, `trotxi-email/${row.id}`);
});

test('DRV-39: upgrading to 029 keeps drivers and PINs, and gives outstanding temporary PINs a deadline', async (t) => {
  const n = ++serial,
    name = `trotxi_harness_${run}_driver_${n}`;
  await admin.query(`CREATE DATABASE "${name}"`);
  owned.push(name);
  const db = new URL(url);
  db.pathname = `/${name}`;
  const owner = new pg.Pool({ connectionString: db.href, max: 2 });
  t.after(() => owner.end());
  const before = migrations.filter((m) => m.name < '029');
  assert.ok(before.length < migrations.length);
  await migrate(owner, before);
  const temp = (
    await owner.query("INSERT INTO app.drivers(name) VALUES ('Legacy Temp') RETURNING id")
  ).rows[0].id;
  const kept = (
    await owner.query("INSERT INTO app.drivers(name) VALUES ('Legacy Private') RETURNING id")
  ).rows[0].id;
  // Before 029 the column defaulted to true: an issued, still-temporary PIN.
  await owner.query(
    "INSERT INTO app.driver_credentials(driver_id,driver_code,pin_hash) VALUES ($1,'DR-AAAA',$2)",
    [temp, 'a'.repeat(64)],
  );
  await owner.query(
    "INSERT INTO app.driver_credentials(driver_id,driver_code,pin_hash,must_change_pin) VALUES ($1,'DR-BBBB',$2,false)",
    [kept, 'b'.repeat(64)],
  );
  await migrate(owner, migrations);
  const rows = (
    await owner.query(
      'SELECT driver_id,pin_hash,must_change_pin,temporary_pin_expires_at FROM app.driver_credentials ORDER BY driver_code',
    )
  ).rows;
  assert.equal(rows.length, 2);
  assert.equal(rows[0].pin_hash, 'a'.repeat(64));
  assert.equal(rows[0].must_change_pin, true);
  const hours = (new Date(rows[0].temporary_pin_expires_at).getTime() - Date.now()) / 3600000;
  assert.ok(hours > 71.9 && hours <= 72, `legacy temporary PIN window ${hours}h`);
  assert.equal(rows[1].pin_hash, 'b'.repeat(64));
  assert.equal(rows[1].temporary_pin_expires_at, null);
  assert.equal((await owner.query('SELECT count(*)::int AS n FROM app.drivers')).rows[0].n, 2);
});

test('DRV-40: the credential email is sent straight after the issue commits, without the worker', async (t) => {
  const f = await fixture(t, true, true),
    driver = await f.create({ name: 'Now Driver', email: 'now.driver@example.test' });
  const secret = data(await f.issue(driver.id, randomUUID(), { emailInstructions: true }), 201);
  assert.equal(secret.email.state, 'queued', 'the response still says queued, not sent');
  // Sent in the background once the transaction committed; no worker run.
  const end = Date.now() + 5000;
  while (!f.sent.length && Date.now() < end) await delay(20);
  assert.equal(f.sent.length, 1);
  assert.ok(f.sent[0]!.message.text.includes(`Temporary PIN: ${secret.pin}`));
  const [row] = (
    await f.owner.query(
      "SELECT id,state FROM app.email_outbox WHERE kind='driver_credentials_issued'",
    )
  ).rows;
  assert.equal(row.state, 'accepted');
  assert.equal(f.sent[0]!.key, `trotxi-email/${row.id}`);
  // The worker finds nothing left to do, so nothing is sent twice.
  assert.equal((await f.email.drain(10)).considered, 0);
  assert.equal(f.sent.length, 1);

  // A provider failure leaves it queued for the worker, with the same key.
  const other = await f.create({ name: 'Later Driver', email: 'later.driver@example.test' });
  f.mailer.failNext = new EmailSendError(true);
  data(await f.issue(other.id, randomUUID(), { emailInstructions: true }), 201);
  const waitFor = Date.now() + 5000;
  let pending;
  while (Date.now() < waitFor) {
    pending = (
      await f.owner.query(
        "SELECT state,attempts FROM app.email_outbox WHERE kind='driver_credentials_issued' ORDER BY created_at DESC LIMIT 1",
      )
    ).rows[0];
    if (pending.attempts > 0) break;
    await delay(20);
  }
  assert.equal(pending.state, 'pending', 'still queued after a failed first attempt');
  assert.equal(f.sent.length, 1);
});
