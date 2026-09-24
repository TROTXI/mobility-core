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
import { hashDriverPin } from '../src/auth/driver-pin.js';
import { hashToken, providerTokenBox } from '../src/auth/credentials.js';
import { TransportError } from '../src/transport/errors.js';
import type { PasskeyRelyingParty } from '../src/auth/passkeys.js';
import { grantRuntime, migrate, readMigrations } from '../src/db/migrate.js';

const value = process.env.HARNESS_ADMIN_DATABASE_URL;
if (!value || process.env.HARNESS_ALLOW_CREATE_DATABASES !== '1')
  throw new Error('Disposable PostgreSQL required; auth tests never skip');
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
const keys = createLocalJWKSet({ keys: [{ ...jwk, kid: 'auth-pg' }] });
const pinSecret = 'auth-pg-pin-secret'.repeat(3),
  encryptionKey = Buffer.alloc(32, 7);
const access = {
  secret: Buffer.alloc(32, 8),
  issuer: 'auth-pg-issuer',
  audience: 'auth-pg-access',
  ttlSeconds: 900,
};
const google = new GoogleIdTokenVerifier('web-client', keys),
  apple = new AppleIdTokenVerifier(['ios-client'], keys);
const testPasskeys: PasskeyRelyingParty = {
  registrationOptions: async ({ userId, userName, displayName, credentials }) => ({
    rp: { id: 'localhost', name: 'Trotxi Ops' },
    user: { id: Buffer.from(userId).toString('base64url'), name: userName, displayName },
    challenge: randomBytes(32).toString('base64url'),
    pubKeyCredParams: [{ type: 'public-key', alg: -7 }],
    timeout: 300_000,
    excludeCredentials: credentials.map((credential) => ({
      id: credential.id,
      type: 'public-key',
      transports: credential.transports,
    })),
    authenticatorSelection: { residentKey: 'required', userVerification: 'required' },
    attestation: 'none',
  }),
  verifyRegistration: async (response, challenge) => {
    if (response.response.clientDataJSON !== challenge) throw new Error('wrong challenge');
    return {
      id: response.id,
      publicKey: Buffer.alloc(64, 1),
      counter: 0,
      transports: response.response.transports,
      deviceType: 'multiDevice',
      backedUp: true,
    };
  },
  authenticationOptions: async (credentials) => ({
    challenge: randomBytes(32).toString('base64url'),
    timeout: 300_000,
    rpId: 'localhost',
    allowCredentials: credentials.map((credential) => ({
      id: credential.id,
      type: 'public-key',
      transports: credential.transports,
    })),
    userVerification: 'required',
  }),
  verifyAuthentication: async (response, challenge, credential) => {
    if (
      response.id !== credential.id ||
      response.response.clientDataJSON !== challenge ||
      response.response.signature === 'YmFk'
    )
      throw new Error('invalid assertion');
    return { newCounter: credential.counter + 1, deviceType: 'multiDevice', backedUp: true };
  },
};
async function identityToken(
  subject: string,
  provider = 'google',
  claims: Record<string, unknown> = {},
) {
  return new SignJWT({ email: 'same-email@example.invalid', email_verified: true, ...claims })
    .setProtectedHeader({ alg: 'RS256', kid: 'auth-pg' })
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
        resolve(process.env.REPLACEMENT_EVIDENCE_DIR, 'auth-metadata.json'),
        JSON.stringify(
          {
            kind: 'replacement-auth-http-postgres-not-provider-sandbox',
            providerBoundary:
              'Real JOSE signature/audience/nonce verification with locally generated test JWKS. Apple code exchange test adapter; no external account or staging call.',
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
    name = `trotxi_harness_${run}_auth_${n}`,
    role = `trotxi_runtime_auth_${run}_${n}`;
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
    passkeys: testPasskeys,
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
    method: 'GET' | 'POST' | 'DELETE',
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
        'x-trotxi-client': path === '/v1/auth/driver' ? 'driver' : 'commuter',
        'x-trotxi-platform': 'ios',
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
  async function seedDriver() {
    const userId = randomUUID(),
      driverId = randomUUID();
    await owner.query("INSERT INTO app.users(id,role,display_name) VALUES ($1,'driver','Driver')", [
      userId,
    ]);
    await owner.query("INSERT INTO app.drivers(id,user_id,name) VALUES ($1,$2,'Driver')", [
      driverId,
      userId,
    ]);
    await owner.query(
      "INSERT INTO app.driver_credentials(driver_id,driver_code,pin_hash) VALUES ($1,'DR-B7K9',$2)",
      [driverId, hashDriverPin('938755', pinSecret)],
    );
    return { userId, driverId };
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
    seedDriver,
    lockUser,
    waitForWaiters,
    role,
  };
}
const data = (response: { statusCode: number; body: string; json(): any }, status = 200) => {
  assert.equal(response.statusCode, status, response.body);
  return status === 204 ? undefined : response.json().data;
};

test('AUTH-01 / ID-01–02: concurrent first social sign-ins share identity, no orphan user, no email linking', async (t) => {
  const f = await setup(t),
    blocker = await f.owner.connect();
  await blocker.query('BEGIN');
  await blocker.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
    JSON.stringify(['auth-identity', 'google', 'same']),
  ]);
  const a = f.sign('same'),
    b = f.sign('same');
  try {
    await f.waitForWaiters(2);
  } finally {
    await blocker.query('COMMIT');
    blocker.release();
  }
  const [one, two] = await Promise.all([a, b]);
  assert.equal(one.account.id, two.account.id);
  assert.deepEqual(
    (
      await f.owner.query(`SELECT (SELECT count(*)::int FROM app.users) AS users,
    (SELECT count(*)::int FROM app.auth_identities) AS identities,(SELECT count(*)::int FROM app.auth_sessions) AS sessions`)
    ).rows[0],
    { users: 1, identities: 1, sessions: 2 },
  );
  const otherProvider = await f.sign('same', 'apple');
  assert.notEqual(otherProvider.account.id, one.account.id);
  const otherSubject = await f.sign('different');
  assert.notEqual(otherSubject.account.id, one.account.id);
  assert.equal((await f.owner.query('SELECT count(*)::int AS n FROM app.users')).rows[0].n, 3);
});
test('AUTH-02: first-sign-in failure rolls back identity, user and session together', async (t) => {
  const f = await setup(t);
  await f.owner
    .query(`CREATE FUNCTION app.auth_fault() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'injected_issue_failure'; END $$;
    CREATE TRIGGER auth_fault BEFORE INSERT ON app.refresh_credentials FOR EACH ROW EXECUTE FUNCTION app.auth_fault()`);
  const token = await identityToken('fault');
  data(await f.request('POST', '/v1/auth/google', { idToken: token }), 500);
  assert.deepEqual(
    (
      await f.owner.query(`SELECT (SELECT count(*)::int FROM app.users) AS users,
    (SELECT count(*)::int FROM app.auth_identities) AS identities,(SELECT count(*)::int FROM app.auth_sessions) AS sessions`)
    ).rows[0],
    { users: 0, identities: 0, sessions: 0 },
  );
  await f.owner.query('DROP TRIGGER auth_fault ON app.refresh_credentials');
  data(await f.request('POST', '/v1/auth/google', { idToken: token }));
});
test('AUTH-03 / ID-03: real concurrent refresh consumes once, commits reuse revocation, lost response cannot silently replay', async (t) => {
  const f = await setup(t),
    first = await f.sign(),
    otherDevice = await f.sign();
  const blocker = await f.lockUser(first.account.id);
  const a = f.request('POST', '/v1/auth/refresh', { refreshToken: first.refreshToken }),
    b = f.request('POST', '/v1/auth/refresh', { refreshToken: first.refreshToken });
  try {
    await f.waitForWaiters(2);
  } finally {
    await blocker.query('COMMIT');
    blocker.release();
  }
  const replies = await Promise.all([a, b]);
  assert.deepEqual(replies.map((r) => r.statusCode).sort(), [200, 401]);
  const issued = data(replies.find((r) => r.statusCode === 200)!);
  assert.deepEqual(
    (
      await f.owner
        .query(`SELECT (SELECT count(*)::int FROM app.auth_sessions WHERE revoked_at IS NULL) AS active,
    (SELECT count(*)::int FROM app.refresh_credentials) AS credentials,
    (SELECT count(*)::int FROM app.refresh_credentials WHERE consumed_at IS NOT NULL) AS consumed`)
    ).rows[0],
    { active: 0, credentials: 3, consumed: 1 },
  );
  for (const token of [issued.refreshToken, otherDevice.refreshToken])
    data(await f.request('POST', '/v1/auth/refresh', { refreshToken: token }), 401);
  data(await f.request('GET', '/v1/me', undefined, issued.accessToken), 401);
});
test('AUTH-04: injected refresh insert failure rolls back consume; same old credential retries successfully', async (t) => {
  const f = await setup(t),
    first = await f.sign();
  await f.owner
    .query(`CREATE FUNCTION app.auth_fault() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'secret-must-not-leak'; END $$;
    CREATE TRIGGER auth_fault BEFORE INSERT ON app.refresh_credentials FOR EACH ROW EXECUTE FUNCTION app.auth_fault()`);
  const failed = await f.request('POST', '/v1/auth/refresh', { refreshToken: first.refreshToken });
  data(failed, 500);
  assert.equal(failed.body.includes('secret-must-not-leak'), false);
  assert.deepEqual(
    (
      await f.owner.query('SELECT consumed_at FROM app.refresh_credentials WHERE token_hash=$1', [
        hashToken(first.refreshToken),
      ])
    ).rows[0],
    { consumed_at: null },
  );
  await f.owner.query('DROP TRIGGER auth_fault ON app.refresh_credentials');
  const next = data(
    await f.request('POST', '/v1/auth/refresh', { refreshToken: first.refreshToken }),
  );
  assert.notEqual(next.refreshToken, first.refreshToken);
  assert.ok(Date.parse(next.refreshExpiresAt) >= Date.parse(first.refreshExpiresAt));
  data(await f.request('GET', '/v1/me', undefined, next.accessToken));
});
test('AUTH-05 / ID-04: logout is device-local, idempotent, and immediately revokes access', async (t) => {
  const f = await setup(t),
    a = await f.sign(),
    b = await f.sign();
  for (let n = 0; n < 2; n++)
    data(await f.request('POST', '/v1/auth/logout', { refreshToken: a.refreshToken }), 204);
  data(await f.request('POST', '/v1/auth/logout', { refreshToken: 'unknown' }), 204);
  data(await f.request('GET', '/v1/me', undefined, a.accessToken), 401);
  data(await f.request('POST', '/v1/auth/refresh', { refreshToken: a.refreshToken }), 401);
  data(await f.request('GET', '/v1/me', undefined, b.accessToken));
  const next = data(await f.request('POST', '/v1/auth/refresh', { refreshToken: b.refreshToken }));
  data(await f.request('POST', '/v1/auth/logout', { refreshToken: b.refreshToken }), 204); // old consumed token no-op
  data(await f.request('GET', '/v1/me', undefined, next.accessToken));
});
test('AUTH-06 / ID-05: sessions use self-bound opaque pagination, safe revocation and secret-free responses', async (t) => {
  const f = await setup(t),
    a = await f.sign(),
    b = await f.sign(),
    foreign = await f.sign('foreign');
  const first = await f.request('GET', '/v1/me/sessions?limit=1', undefined, a.accessToken),
    firstRows = data(first);
  assert.equal(firstRows.length, 1);
  assert.equal(firstRows[0].current, true);
  assert.deepEqual(Object.keys(firstRows[0]).sort(), ['createdAt', 'current', 'expiresAt', 'id']);
  const cursor = first.json().page.nextCursor;
  assert.ok(cursor);
  const second = data(
    await f.request('GET', `/v1/me/sessions?limit=1&cursor=${cursor}`, undefined, a.accessToken),
  );
  assert.equal(second[0].current, false);
  assert.notEqual(firstRows[0].id, second[0].id);
  data(
    await f.request('GET', `/v1/me/sessions?cursor=${cursor}`, undefined, foreign.accessToken),
    400,
  );
  const foreignId = (await f.service.tokens.verify(`Bearer ${foreign.accessToken}`))!.sessionId;
  data(
    await f.request('DELETE', `/v1/me/sessions/${foreignId}`, undefined, a.accessToken, {
      'idempotency-key': 'other',
    }),
    204,
  );
  data(await f.request('GET', '/v1/me', undefined, foreign.accessToken));
  for (let n = 0; n < 2; n++)
    data(
      await f.request('DELETE', `/v1/me/sessions/${second[0].id}`, undefined, a.accessToken, {
        'idempotency-key': 'revoke',
      }),
      204,
    );
  data(await f.request('GET', '/v1/me', undefined, b.accessToken), 401);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.auth_commands')).rows[0].n,
    2,
  );
  assert.equal(first.headers['cache-control'], 'no-store');
  assert.equal(first.body.includes('token'), false);
});
test('AUTH-07 / ID-06: five actual concurrent wrong-PIN attempts persist lockout; unknown code has the same first rejection', async (t) => {
  const f = await setup(t),
    { userId, driverId } = await f.seedDriver();
  const unknown = await f.request('POST', '/v1/auth/driver', {
    code: 'ZZZZ',
    pin: '938754',
    ownDevice: true,
  });
  data(unknown, 401);
  const blocker = await f.lockUser(userId);
  const requests = Array.from({ length: 5 }, () =>
    f.request('POST', '/v1/auth/driver', { code: 'b7k9', pin: '938754', ownDevice: true }),
  );
  try {
    await f.waitForWaiters(5);
  } finally {
    await blocker.query('COMMIT');
    blocker.release();
  }
  const replies = await Promise.all(requests);
  assert.deepEqual(replies.map((r) => r.statusCode).sort(), [401, 401, 401, 401, 423]);
  assert.equal(replies.find((r) => r.statusCode === 423)!.headers['retry-after'], '900');
  assert.equal(
    replies.find((r) => r.statusCode === 401)!.json().error.code,
    unknown.json().error.code,
  );
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT failed_attempts,locked_until>clock_timestamp() AS locked FROM app.driver_credentials WHERE driver_id=$1',
        [driverId],
      )
    ).rows[0],
    { failed_attempts: 5, locked: true },
  );
  data(
    await f.request('POST', '/v1/auth/driver', { code: 'B7K9', pin: '938755', ownDevice: true }),
    423,
  );
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.auth_sessions')).rows[0].n,
    0,
  );
});
test('AUTH-08 / ID-07–08: shared-device TTL survives rotation, expired lock recovers, suspension kills session authorization', async (t) => {
  const f = await setup(t),
    { driverId } = await f.seedDriver();
  await f.owner.query(
    "UPDATE app.driver_credentials SET failed_attempts=5,locked_until=clock_timestamp()-interval '1 minute' WHERE driver_id=$1",
    [driverId],
  );
  const input = { code: 'dr-b7k9', pin: '938755', ownDevice: false };
  const short = data(await f.request('POST', '/v1/auth/driver', input));
  assert.equal(short.account.role, 'driver');
  assert.equal(short.driver.id, driverId);
  assert.equal(short.mustChangePin, true);
  assert.ok(Date.parse(short.refreshExpiresAt) - Date.now() < 12 * 3600000 + 1000);
  const next = data(
    await f.request('POST', '/v1/auth/refresh', { refreshToken: short.refreshToken }),
  );
  assert.equal(next.refreshExpiresAt, short.refreshExpiresAt);
  const long = data(await f.request('POST', '/v1/auth/driver', { ...input, ownDevice: true }));
  assert.ok(Date.parse(long.refreshExpiresAt) - Date.now() > 29 * 86400000);
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT failed_attempts,locked_until FROM app.driver_credentials WHERE driver_id=$1',
        [driverId],
      )
    ).rows[0],
    { failed_attempts: 0, locked_until: null },
  );
  await f.owner.query("UPDATE app.driver_credentials SET status='suspended' WHERE driver_id=$1", [
    driverId,
  ]);
  data(await f.request('POST', '/v1/auth/driver', input), 403);
  data(await f.request('POST', '/v1/auth/refresh', { refreshToken: next.refreshToken }), 401);
  data(await f.request('GET', '/v1/me', undefined, next.accessToken), 401);
  data(
    await f.request('GET', '/v1/driver/trips', undefined, next.accessToken, {
      'x-trotxi-client': 'driver',
    }),
    401,
  );
});
test('AUTH-09: real JWT transport integration reads DB roles and revoked/erased facts, never header claims', async (t) => {
  const f = await setup(t),
    a = await f.sign();
  // ops forbids platform; use app directly to omit rather than spoof metadata.
  const ops = () =>
    f.app.inject({
      method: 'GET',
      url: '/v1/ops/routes',
      headers: {
        authorization: `Bearer ${a.accessToken}`,
        'x-trotxi-client': 'ops',
        'x-trotxi-build': '2',
        'x-role': 'admin',
      },
    });
  data(await ops(), 403);
  await f.owner.query("UPDATE app.users SET role='admin' WHERE id=$1", [a.account.id]);
  // Promotion alone does not open ops: the new admin still has to pass the
  // authenticator check, and is asked for a code rather than signed out.
  assert.equal((await ops()).json().error.code, 'passkey_required');
  await f.owner.query(
    'UPDATE app.auth_sessions SET admin_verified_at=clock_timestamp() WHERE user_id=$1',
    [a.account.id],
  );
  data(await ops()); // JWT still says commuter; current DB role decides.
  await f.owner.query('UPDATE app.users SET deleted_at=clock_timestamp() WHERE id=$1', [
    a.account.id,
  ]);
  data(await ops(), 401);
  data(await f.request('GET', '/v1/me', undefined, a.accessToken), 401);
  data(await f.request('POST', '/v1/auth/google', { idToken: await identityToken('rider') }), 401);
  assert.equal((await f.owner.query('SELECT count(*)::int AS n FROM app.users')).rows[0].n, 1);
});
test('AUTH-10: Apple first name and encrypted revocation token are preserved, retries do not overwrite corrected name', async (t) => {
  const f = await setup(t),
    first = await f.sign('apple-user', 'apple', {
      displayName: 'First Name',
      authorizationCode: 'fresh',
    });
  assert.equal(first.account.displayName, 'First Name');
  const row = (
    await f.owner.query(
      'SELECT provider_token_ciphertext FROM app.auth_identities WHERE user_id=$1',
      [first.account.id],
    )
  ).rows[0];
  assert.equal(row.provider_token_ciphertext.includes('apple-private-refresh'), false);
  assert.equal(
    providerTokenBox(encryptionKey).open(row.provider_token_ciphertext, 'apple-user'),
    'apple-private-refresh',
  );
  await f.owner.query("UPDATE app.users SET display_name='Corrected' WHERE id=$1", [
    first.account.id,
  ]);
  assert.equal(
    (await f.sign('apple-user', 'apple', { displayName: 'Overwrite', authorizationCode: 'used' }))
      .account.displayName,
    'Corrected',
  );
  assert.equal(
    (
      await f.owner.query(
        'SELECT provider_token_ciphertext FROM app.auth_identities WHERE user_id=$1',
        [first.account.id],
      )
    ).rows[0].provider_token_ciphertext,
    row.provider_token_ciphertext,
  );
});
test('AUTH-11: HTTP rejects unsupported builds, invalid provider input, extra fields and brute force', async (t) => {
  const f = await setup(t, 3),
    idToken = await identityToken('limit');
  data(
    await f.request('POST', '/v1/auth/google', { idToken }, undefined, { 'x-trotxi-build': '1' }),
    426,
  );
  data(await f.request('POST', '/v1/auth/google', { idToken, role: 'admin' }), 400);
  data(await f.request('POST', '/v1/auth/google', { idToken: 'invalid' }), 401);
  const limited = await f.request('POST', '/v1/auth/google', { idToken });
  data(limited, 429);
  assert.ok(limited.headers['retry-after']);
});
test('AUTH-12: narrow runtime cannot reach owner or mutate completed revocation receipts', async (t) => {
  const f = await setup(t),
    a = await f.sign();
  assert.equal(
    (await f.owner.query("SELECT pg_has_role($1,current_user,'USAGE') AS owner_rights", [f.role]))
      .rows[0].owner_rights,
    false,
  );
  assert.equal(
    (
      await f.owner.query(
        "SELECT has_table_privilege($1,'app.auth_commands','UPDATE') AS update_allowed",
        [f.role],
      )
    ).rows[0].update_allowed,
    false,
  );
  const target = randomUUID();
  data(
    await f.request('DELETE', `/v1/me/sessions/${target}`, undefined, a.accessToken, {
      'idempotency-key': 'safe',
    }),
    204,
  );
  await assert.rejects(f.runtime.query('UPDATE app.auth_commands SET key_hash=key_hash'), {
    code: '42501',
  });
  await assert.rejects(f.runtime.query('DELETE FROM app.auth_sessions'), { code: '42501' });
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.transport_commands')).rows[0].n,
    0,
  );
  for (const table of ['auth_sessions', 'refresh_credentials', 'auth_commands']) {
    const stored = JSON.stringify((await f.owner.query(`SELECT * FROM app.${table}`)).rows);
    assert.equal(stored.includes(a.accessToken), false);
    assert.equal(stored.includes(a.refreshToken), false);
  }
});

test('AUTH-13: provider network/key-fetch failure is 503, not credential rejection or an orphan account', async (t) => {
  const unavailable = new GoogleIdTokenVerifier('web-client', async () => {
    throw new TypeError('provider network unavailable');
  });
  const f = await setup(t, 1000, { google: unavailable, apple: undefined });
  data(
    await f.request('POST', '/v1/auth/google', { idToken: await identityToken('network') }),
    503,
  );
  data(
    await f.request('POST', '/v1/auth/apple', {
      idToken: await identityToken('disabled', 'apple'),
    }),
    503,
  );
  assert.equal((await f.owner.query('SELECT count(*)::int AS n FROM app.users')).rows[0].n, 0);
});
test('AUTH-14: refresh lock timeout is transient, preserves credentials, and succeeds after the blocker clears', async (t) => {
  const f = await setup(t),
    a = await f.sign(),
    blocker = await f.lockUser(a.account.id);
  try {
    data(await f.request('POST', '/v1/auth/refresh', { refreshToken: a.refreshToken }), 503);
  } finally {
    await blocker.query('COMMIT');
    blocker.release();
  }
  assert.deepEqual(
    (
      await f.owner.query('SELECT consumed_at FROM app.refresh_credentials WHERE token_hash=$1', [
        hashToken(a.refreshToken),
      ])
    ).rows[0],
    { consumed_at: null },
  );
  data(await f.request('POST', '/v1/auth/refresh', { refreshToken: a.refreshToken }));
});
test('AUTH-15: expiry and query boundaries fail closed; old expired generations cannot revoke a newer session', async (t) => {
  const f = await setup(t),
    a = await f.sign();
  for (const path of [
    '/v1/me?userId=other',
    '/v1/me/sessions?limit=201',
    '/v1/me/sessions?limit=0',
    '/v1/me/sessions?limit=1.5',
    '/v1/me/sessions?cursor=bad',
  ])
    data(await f.request('GET', path, undefined, a.accessToken), 400);
  data(await f.request('GET', '/v1/me/sessions?limit=200', undefined, a.accessToken));
  const next = data(await f.request('POST', '/v1/auth/refresh', { refreshToken: a.refreshToken }));
  await f.owner.query(
    "UPDATE app.refresh_credentials SET created_at=clock_timestamp()-interval '2 days',expires_at=clock_timestamp()-interval '1 day' WHERE token_hash=$1",
    [hashToken(a.refreshToken)],
  );
  data(await f.request('POST', '/v1/auth/refresh', { refreshToken: a.refreshToken }), 401);
  data(await f.request('GET', '/v1/me', undefined, next.accessToken));
  const actor = (await f.service.tokens.verify(`Bearer ${next.accessToken}`))!;
  await f.owner.query(
    "UPDATE app.auth_sessions SET created_at=clock_timestamp()-interval '2 days',expires_at=clock_timestamp()-interval '1 day' WHERE id=$1",
    [actor.sessionId],
  );
  data(await f.request('GET', '/v1/me', undefined, next.accessToken), 401);
  data(await f.request('POST', '/v1/auth/refresh', { refreshToken: next.refreshToken }), 401);
});
test('AUTH-16: revocation waits for an authorized transaction; every subsequent transport read rejects it', async (t) => {
  const f = await setup(t),
    a = await f.sign(),
    actor = (await f.service.tokens.verify(`Bearer ${a.accessToken}`))!;
  const client = await f.runtime.connect();
  await client.query('BEGIN');
  await f.service.authorizeSession(client, actor);
  const logout = f.request('POST', '/v1/auth/logout', { refreshToken: a.refreshToken });
  try {
    await f.waitForWaiters(1);
  } finally {
    await client.query('COMMIT');
    client.release();
  }
  data(await logout, 204);
  data(await f.request('GET', '/v1/me', undefined, a.accessToken), 401);
});
test('AUTH-17: session-revocation failures leave no receipt; unauthorized replay is never cached success', async (t) => {
  const f = await setup(t),
    a = await f.sign(),
    b = await f.sign();
  const actor = (await f.service.tokens.verify(`Bearer ${a.accessToken}`))!,
    target = (await f.service.tokens.verify(`Bearer ${b.accessToken}`))!;
  const path = `/v1/me/sessions/${target.sessionId}`,
    headers = { 'idempotency-key': 'same-key' };
  await f.owner
    .query(`CREATE FUNCTION app.auth_fault() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'receipt failed'; END $$;
    CREATE TRIGGER auth_fault BEFORE INSERT ON app.auth_commands FOR EACH ROW EXECUTE FUNCTION app.auth_fault()`);
  data(await f.request('DELETE', path, undefined, a.accessToken, headers), 500);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.auth_commands')).rows[0].n,
    0,
  );
  data(await f.request('GET', '/v1/me', undefined, b.accessToken));
  await f.owner.query('DROP TRIGGER auth_fault ON app.auth_commands');
  data(await f.request('DELETE', path, undefined, a.accessToken, headers), 204);
  const expiredTarget = randomUUID();
  await f.owner.query(
    `INSERT INTO app.auth_commands(actor_user_id,target_session_id,key_hash,created_at,replay_expires_at)
    VALUES ($1,$2,$3,clock_timestamp()-interval '8 days',clock_timestamp()-interval '1 day')`,
    [a.account.id, expiredTarget, hashToken('expired')],
  );
  const expired = await f.request(
    'DELETE',
    `/v1/me/sessions/${expiredTarget}`,
    undefined,
    a.accessToken,
    { 'idempotency-key': 'expired' },
  );
  data(expired, 409);
  assert.equal(expired.json().error.code, 'idempotency_expired');
  data(
    await f.request('DELETE', `/v1/me/sessions/${actor.sessionId}`, undefined, a.accessToken, {
      'idempotency-key': 'self',
    }),
    204,
  );
  data(await f.request('DELETE', path, undefined, a.accessToken, headers), 401);
});

/**
 * Passkey elevation end to end. The browser ceremony is a deterministic test
 * adapter; session, challenge, credential, authorization and replay handling
 * all run through the real HTTP and PostgreSQL paths.
 */
async function operator(f: Awaited<ReturnType<typeof setup>>, subject: string) {
  const signed = await f.sign(subject);
  await f.owner.query("UPDATE app.users SET role='admin' WHERE id=$1", [signed.account.id]);
  return { id: signed.account.id as string, token: signed.accessToken as string };
}
/** As the Ops website calls: its own client, and no mobile platform header. */
function ops(
  f: Awaited<ReturnType<typeof setup>>,
  method: 'GET' | 'POST',
  path: string,
  token: string,
  body?: unknown,
) {
  return f.app.inject({
    method,
    url: path,
    ...(body !== undefined ? { payload: body as object } : {}),
    headers: { authorization: `Bearer ${token}`, 'x-trotxi-client': 'ops', 'x-trotxi-build': '2' },
  });
}
function registrationResponse(challenge: string, id = randomBytes(24).toString('base64url')) {
  return {
    id,
    rawId: id,
    type: 'public-key',
    authenticatorAttachment: 'platform',
    clientExtensionResults: {},
    response: {
      clientDataJSON: challenge,
      attestationObject: 'YXR0ZXN0YXRpb24',
      transports: ['internal', 'hybrid'],
    },
  };
}
function authenticationResponse(challenge: string, id: string, signature = 'c2lnbmF0dXJl') {
  return {
    id,
    rawId: id,
    type: 'public-key',
    authenticatorAttachment: 'platform',
    clientExtensionResults: {},
    response: {
      clientDataJSON: challenge,
      authenticatorData: 'YXV0aGVudGljYXRvci1kYXRh',
      signature,
      userHandle: null,
    },
  };
}
async function register(f: Awaited<ReturnType<typeof setup>>, token: string, id?: string) {
  const started = await ops(f, 'POST', '/v1/auth/passkeys/registration/options', token);
  assert.equal(started.statusCode, 200, started.body);
  const options = started.json().data;
  const response = registrationResponse(options.challenge, id);
  const completed = await ops(
    f,
    'POST',
    '/v1/auth/passkeys/registration/verification',
    token,
    response,
  );
  assert.equal(completed.statusCode, 204, completed.body);
  return response.id as string;
}

test('PASSKEY-01 an admin needs a user-verified passkey before any Ops action', async (t) => {
  const f = await setup(t);
  const admin = await operator(f, 'ops-passkey-1');
  const refused = await ops(f, 'GET', '/v1/ops/riders', admin.token);
  assert.equal(refused.statusCode, 403, refused.body);
  assert.equal(refused.json().error.code, 'passkey_required');

  const before = (await ops(f, 'GET', '/v1/auth/passkeys', admin.token)).json().data;
  assert.deepEqual(before, {
    registered: false,
    passkeyCount: 0,
    registrationPending: false,
    verified: false,
  });

  const started = await ops(f, 'POST', '/v1/auth/passkeys/registration/options', admin.token);
  assert.equal(started.statusCode, 200, started.body);
  const options = started.json().data;
  assert.equal(options.rp.id, 'localhost');
  assert.equal(options.authenticatorSelection.userVerification, 'required');
  assert.equal(options.authenticatorSelection.residentKey, 'required');

  const wrong = await ops(
    f,
    'POST',
    '/v1/auth/passkeys/registration/verification',
    admin.token,
    registrationResponse(randomBytes(32).toString('base64url')),
  );
  assert.equal(wrong.statusCode, 400);
  assert.equal(wrong.json().error.code, 'passkey_verification_failed');

  const credential = registrationResponse(options.challenge);
  assert.equal(
    (await ops(f, 'POST', '/v1/auth/passkeys/registration/verification', admin.token, credential))
      .statusCode,
    204,
  );
  assert.equal((await ops(f, 'GET', '/v1/ops/riders', admin.token)).statusCode, 200);
  assert.deepEqual((await ops(f, 'GET', '/v1/auth/passkeys', admin.token)).json().data, {
    registered: true,
    passkeyCount: 1,
    registrationPending: false,
    verified: true,
  });

  const columns = (
    await f.owner.query(
      `SELECT column_name FROM information_schema.columns
       WHERE table_schema='app' AND table_name='admin_passkeys' ORDER BY column_name`,
    )
  ).rows.map((row) => row.column_name);
  assert.equal(
    columns.some((name) => /secret|recovery|private/i.test(name)),
    false,
  );
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT action FROM app.admin_passkey_events WHERE user_id=$1 ORDER BY occurred_at',
        [admin.id],
      )
    ).rows.map((row) => row.action),
    ['registration_started', 'registered'],
  );
});

test('PASSKEY-02 elevation is per session and a completed assertion cannot replay', async (t) => {
  const f = await setup(t);
  const admin = await operator(f, 'ops-passkey-2');
  const credentialId = await register(f, admin.token);

  const second = await f.sign('ops-passkey-2');
  assert.equal((await ops(f, 'GET', '/v1/ops/riders', second.accessToken)).statusCode, 403);
  const options = (
    await ops(f, 'POST', '/v1/auth/passkeys/authentication/options', second.accessToken)
  ).json().data;
  const assertion = authenticationResponse(options.challenge, credentialId);
  assert.equal(
    (
      await ops(
        f,
        'POST',
        '/v1/auth/passkeys/authentication/verification',
        second.accessToken,
        assertion,
      )
    ).statusCode,
    204,
  );
  assert.equal((await ops(f, 'GET', '/v1/ops/riders', second.accessToken)).statusCode, 200);
  const replay = await ops(
    f,
    'POST',
    '/v1/auth/passkeys/authentication/verification',
    second.accessToken,
    assertion,
  );
  assert.equal(replay.statusCode, 409);
  assert.equal(replay.json().error.code, 'passkey_challenge_missing');
  assert.equal(
    (
      await f.owner.query(
        'SELECT signature_counter FROM app.admin_passkeys WHERE user_id=$1 AND credential_id=$2',
        [admin.id, credentialId],
      )
    ).rows[0].signature_counter,
    '1',
  );
});

test('PASSKEY-03 a verified admin can add a second passkey; an unelevated session cannot', async (t) => {
  const f = await setup(t);
  const admin = await operator(f, 'ops-passkey-3');
  await register(f, admin.token);
  await register(f, admin.token);

  const fresh = await f.sign('ops-passkey-3');
  const refused = await ops(f, 'POST', '/v1/auth/passkeys/registration/options', fresh.accessToken);
  assert.equal(refused.statusCode, 403);
  assert.equal(refused.json().error.code, 'passkey_required');
  assert.equal(
    (await ops(f, 'GET', '/v1/auth/passkeys', fresh.accessToken)).json().data.passkeyCount,
    2,
  );
});

test('PASSKEY-04 only another elevated admin can reset passkeys', async (t) => {
  const f = await setup(t);
  const lost = await operator(f, 'ops-passkey-4a');
  await register(f, lost.token);
  const helper = await operator(f, 'ops-passkey-4b');
  await register(f, helper.token);

  const self = await ops(f, 'POST', `/v1/ops/users/${helper.id}/passkeys/reset`, helper.token);
  assert.equal(self.statusCode, 403);
  assert.equal(self.json().error.code, 'self_reset_forbidden');

  const unverified = await f.sign('ops-passkey-4b');
  assert.equal(
    (await ops(f, 'POST', `/v1/ops/users/${lost.id}/passkeys/reset`, unverified.accessToken))
      .statusCode,
    403,
  );

  const reset = await ops(f, 'POST', `/v1/ops/users/${lost.id}/passkeys/reset`, helper.token);
  assert.equal(reset.statusCode, 204, reset.body);
  assert.equal((await ops(f, 'GET', '/v1/auth/passkeys', lost.token)).statusCode, 401);

  const back = await f.sign('ops-passkey-4a');
  assert.equal(
    (await ops(f, 'GET', '/v1/auth/passkeys', back.accessToken)).json().data.registered,
    false,
  );
  assert.equal(
    (await ops(f, 'POST', '/v1/auth/passkeys/registration/options', back.accessToken)).statusCode,
    200,
  );
  assert.deepEqual(
    (
      await f.owner.query(
        "SELECT actor_user_id FROM app.admin_passkey_events WHERE user_id=$1 AND action='reset'",
        [lost.id],
      )
    ).rows,
    [{ actor_user_id: helper.id }],
  );
});

test('PASSKEY-05 challenges are session-bound, purpose-bound, expiring and replaceable', async (t) => {
  const f = await setup(t);
  const admin = await operator(f, 'ops-passkey-5');
  const first = (await ops(f, 'POST', '/v1/auth/passkeys/registration/options', admin.token)).json()
    .data;
  const second = (
    await ops(f, 'POST', '/v1/auth/passkeys/registration/options', admin.token)
  ).json().data;
  assert.notEqual(first.challenge, second.challenge);
  assert.equal(
    (
      await ops(
        f,
        'POST',
        '/v1/auth/passkeys/registration/verification',
        admin.token,
        registrationResponse(first.challenge),
      )
    ).statusCode,
    400,
  );

  await f.owner.query(
    `UPDATE app.admin_passkey_challenges
     SET created_at=clock_timestamp()-interval '6 minutes',
         expires_at=clock_timestamp()-interval '2 minutes'
     WHERE user_id=$1`,
    [admin.id],
  );
  const expired = await ops(
    f,
    'POST',
    '/v1/auth/passkeys/registration/verification',
    admin.token,
    registrationResponse(second.challenge),
  );
  assert.equal(expired.statusCode, 409);
  assert.equal(expired.json().error.code, 'passkey_challenge_missing');
});

test('PASSKEY-06 riders never meet the administrator passkey flow', async (t) => {
  const f = await setup(t);
  const rider = await f.sign('rider-passkey');
  const refused = await f.request('GET', '/v1/auth/passkeys', undefined, rider.accessToken);
  assert.equal(refused.statusCode, 403);
  assert.equal(refused.json().error.code, 'forbidden');
  assert.equal((await f.request('GET', '/v1/me', undefined, rider.accessToken)).statusCode, 200);
});
