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
import { PhoneOtp } from '../src/auth/phone-otp.js';
import { purgeExpiredEmailAccess } from '../src/auth/email-auth.js';
import { StandbyService } from '../src/membership/standby.js';
import type { Purchases } from '../src/payments/purchases.js';
import type { SmsSender } from '../src/notifications/mnotify.js';
import { SmsSendError } from '../src/notifications/mnotify.js';
import type { AuthOptions } from '../src/auth/service.js';
import { GoogleIdTokenVerifier } from '../src/auth/id-token-verifier.google.js';
import { AppleIdTokenVerifier } from '../src/auth/id-token-verifier.apple.js';
import { hashDriverPin } from '../src/auth/driver-pin.js';
import { hashToken, providerTokenBox } from '../src/auth/credentials.js';
import { TransactionalEmail } from '../src/notifications/email.js';
import { bootstrapSuperadmin } from '../src/auth/ops-bootstrap.js';
import { AccountService } from '../src/account/service.js';
import { ErasureJournal } from '../src/account/erasure-journal.js';
import { ErasureRecovery } from '../src/account/erasure-recovery.js';
import { MemoryErasureStore } from './helpers/erasure-store.js';
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
test('PHONE-01: verified phone creates a separate commuter, never adopts Google profile or funding', async (t) => {
  const sent: string[] = [];
  const { owner, request, sign } = await setup(
    t,
    1000,
    {},
    {
      send: async (_phone, message) => {
        sent.push(message);
        return 'test-receipt';
      },
    },
  );
  const googleAccount = await sign('phone-profile-google');
  await owner.query('UPDATE app.users SET phone=$1 WHERE id=$2', [
    '+233241234567',
    googleAccount.account.id,
  ]);
  const requested = await request('POST', '/v1/auth/phone/request', { phone: '0241234567' });
  assert.equal(requested.statusCode, 200, requested.body);
  const { challengeId } = requested.json().data;
  const code = sent[0]!.match(/\b(\d{6})\b/)![1]!;
  const stored = (
    await owner.query('SELECT * FROM app.phone_otp_challenges WHERE id=$1', [challengeId])
  ).rows[0];
  assert.ok(!JSON.stringify(stored).includes('241234567'));
  assert.notEqual(stored.code_hash, code);
  const verified = await request('POST', '/v1/auth/phone/verify', { challengeId, code });
  assert.equal(verified.statusCode, 200, verified.body);
  const account = verified.json().data.account;
  assert.notEqual(account.id, googleAccount.account.id);
  assert.equal(account.role, 'commuter');
  assert.equal(account.phone, '+233241234567');
  assert.equal(
    (
      await owner.query('SELECT count(*)::int AS n FROM app.memberships WHERE user_id=$1', [
        account.id,
      ])
    ).rows[0].n,
    0,
  );
  const replay = await request('POST', '/v1/auth/phone/verify', { challengeId, code });
  assert.equal(replay.statusCode, 401, replay.body);
  const scrubbed = (
    await owner.query('SELECT * FROM app.phone_otp_challenges WHERE id=$1', [challengeId])
  ).rows[0];
  assert.equal(scrubbed.code_hash, null);
  assert.equal(scrubbed.phone_ciphertext, null);
  assert.equal(
    (await request('POST', '/v1/auth/phone/request', { phone: '+233241234567' })).statusCode,
    429,
  );
});

test('PHONE-PASSWORD-01: phone proof completes named signup, contact proof enables recovery', async (t) => {
  let code = '';
  const f = await setup(
    t,
    1000,
    {},
    {
      send: async (_phone, message) => {
        code = message.match(/\b(\d{6})\b/)![1]!;
        return 'test-receipt';
      },
    },
  );
  const requested = data(
    await f.request('POST', '/v1/auth/phone/request', { phone: '0241234567' }),
  );
  const temporary = data(
    await f.request('POST', '/v1/auth/phone/verify', {
      challengeId: requested.challengeId,
      code,
    }),
  );
  assert.equal(temporary.account.phoneRegistrationPending, true);
  assert.equal(
    (await f.request('GET', '/v1/me', undefined, temporary.accessToken)).statusCode,
    200,
  );
  const beforeRegistration = await f.request(
    'GET',
    '/v1/me/verification',
    undefined,
    temporary.accessToken,
  );
  assert.equal(beforeRegistration.json().error.code, 'registration_required');
  data(
    await f.request(
      'POST',
      '/v1/me/phone-registration',
      {
        firstName: 'Ama',
        otherNames: 'Akua',
        lastName: 'Mensah',
        email: 'ama@outlook.com',
        password: emailPassword,
      },
      temporary.accessToken,
    ),
    204,
  );
  assert.equal(
    (await f.request('GET', '/v1/me', undefined, temporary.accessToken)).statusCode,
    401,
  );
  assert.equal(
    (
      await f.request('POST', '/v1/auth/phone/password', {
        phone: '0241234567',
        password: 'wrong password',
      })
    ).statusCode,
    401,
  );
  const signed = data(
    await f.request('POST', '/v1/auth/phone/password', {
      phone: '0241234567',
      password: emailPassword,
    }),
  );
  assert.equal(signed.account.displayName, 'Ama Akua Mensah');
  assert.equal(signed.account.phoneRegistrationPending, false);
  const fixture = await f.owner.connect();
  try {
    await fixture.query('BEGIN');
    await fixture.query('SET LOCAL session_replication_role=replica');
    await fixture.query(
      "UPDATE app.phone_otp_challenges SET created_at=created_at-interval '61 seconds',expires_at=expires_at-interval '61 seconds'",
    );
    await fixture.query('COMMIT');
  } finally {
    fixture.release();
  }
  const secondCode = data(
    await f.request('POST', '/v1/auth/phone/request', {
      phone: '0241234567',
    }),
  );
  const otpSignIn = await f.request('POST', '/v1/auth/phone/verify', {
    challengeId: secondCode.challengeId,
    code,
  });
  assert.equal(otpSignIn.statusCode, 409);
  assert.equal(otpSignIn.json().error.code, 'password_required');
  const contact = data(
    await f.request('GET', '/v1/me/email-access', undefined, signed.accessToken),
  );
  assert.equal(contact.emailVerified, false);
  assert.equal(contact.passwordEnabled, true);
  const token = await emailToken(f);
  assert.equal(
    (
      await f.request('POST', '/v1/auth/email/complete', {
        token,
        password: 'not a reset password',
      })
    ).statusCode,
    400,
  );
  data(await f.request('POST', '/v1/auth/email/verify', { token }), 204);
  assert.equal(
    data(await f.request('GET', '/v1/me/email-access', undefined, signed.accessToken))
      .emailVerified,
    true,
  );
  await f.owner.query(
    "UPDATE app.email_auth_challenges SET created_at=created_at-interval '2 minutes'",
  );
  data(await f.request('POST', '/v1/auth/email/reset', { email: 'ama@outlook.com' }));
  const resetToken = await emailToken(f);
  data(
    await f.request('POST', '/v1/auth/email/complete', {
      token: resetToken,
      password: 'new correct horse trotxi battery',
    }),
    204,
  );
  assert.equal(
    (
      await f.request('POST', '/v1/auth/phone/password', {
        phone: '0241234567',
        password: emailPassword,
      })
    ).statusCode,
    401,
  );
  assert.equal(
    (
      await f.request('POST', '/v1/auth/phone/password', {
        phone: '0241234567',
        password: 'new correct horse trotxi battery',
      })
    ).statusCode,
    200,
  );
});

test('PHONE-02: five incorrect guesses commit and exhaust the challenge', async (t) => {
  let code = '';
  const { owner, request } = await setup(
    t,
    1000,
    {},
    {
      send: async (_phone, message) => {
        code = message.match(/\b(\d{6})\b/)![1]!;
        return 'test-receipt';
      },
    },
  );
  const requested = await request('POST', '/v1/auth/phone/request', { phone: '0241234567' });
  assert.equal(requested.statusCode, 200, requested.body);
  const { challengeId } = requested.json().data;
  const wrong = code === '000000' ? '000001' : '000000';
  for (let i = 0; i < 5; i++) {
    assert.equal(
      (await request('POST', '/v1/auth/phone/verify', { challengeId, code: wrong })).statusCode,
      401,
    );
  }
  assert.equal(
    (await owner.query('SELECT attempts FROM app.phone_otp_challenges WHERE id=$1', [challengeId]))
      .rows[0].attempts,
    5,
  );
  assert.equal(
    (await request('POST', '/v1/auth/phone/verify', { challengeId, code })).statusCode,
    401,
  );
  assert.equal(
    (await owner.query("SELECT count(*)::int AS n FROM app.auth_identities WHERE provider='phone'"))
      .rows[0].n,
    0,
  );
});

test('PHONE-03: expired, uncertain-send and wrong-client challenges cannot sign in', async (t) => {
  let code = '',
    reject = false;
  const { owner, request } = await setup(
    t,
    1000,
    {},
    {
      send: async (_phone, message) => {
        code = message.match(/\b(\d{6})\b/)![1]!;
        if (reject) throw new Error('uncertain provider response');
        return 'test-receipt';
      },
    },
  );
  assert.equal(
    (
      await request('POST', '/v1/auth/phone/request', { phone: '0241234567' }, undefined, {
        'x-trotxi-client': 'ops',
      })
    ).statusCode,
    403,
  );
  const requested = await request('POST', '/v1/auth/phone/request', { phone: '0241234567' });
  const { challengeId } = requested.json().data;
  // Owner-only test clock fixture. The runtime cannot alter an OTP's lifetime.
  const fixture = await owner.connect();
  try {
    await fixture.query('BEGIN');
    await fixture.query('SET LOCAL session_replication_role=replica');
    await fixture.query(
      "UPDATE app.phone_otp_challenges SET created_at=statement_timestamp()-interval '6 minutes', expires_at=statement_timestamp()-interval '1 minute' WHERE id=$1",
      [challengeId],
    );
    await fixture.query('COMMIT');
  } finally {
    fixture.release();
  }
  assert.equal(
    (await request('POST', '/v1/auth/phone/verify', { challengeId, code })).statusCode,
    401,
  );
  reject = true;
  const failed = await request('POST', '/v1/auth/phone/request', { phone: '0541234567' });
  assert.equal(failed.statusCode, 503, failed.body);
  const row = (await owner.query("SELECT * FROM app.phone_otp_challenges WHERE state='failed'"))
    .rows[0];
  assert.equal(row.code_hash, null);
  assert.equal(row.phone_ciphertext, null);
  assert.equal(
    (await request('POST', '/v1/auth/phone/verify', { challengeId: row.id, code })).statusCode,
    401,
  );
});

test('PHONE-05: rolling source budget is shared, atomic and cannot trust a caller forwarding header', async (t) => {
  let sends = 0;
  const f = await setup(
    t,
    1000,
    {},
    {
      send: async () => {
        sends++;
        return 'provider-receipt';
      },
    },
  );
  const first = await f.request('POST', '/v1/auth/phone/request', { phone: '0241000001' });
  assert.equal(first.statusCode, 200, first.body);
  const row = (await f.owner.query('SELECT * FROM app.phone_otp_challenges')).rows[0];
  assert.ok(!JSON.stringify(row).includes('127.0.0.1'));
  // Forty-nine charged attempts on this source. The last two requests really
  // contend through the HTTP/service path, not through a fake budget callback.
  await f.owner.query(
    `INSERT INTO app.phone_otp_challenges(id,phone_hash,source_hash,created_at,expires_at,state)
    SELECT gen_random_uuid(),repeat(md5(n::text),2),$1,statement_timestamp(),statement_timestamp()+interval '5 minutes','failed'
    FROM generate_series(1,48) n`,
    [row.source_hash],
  );
  const results = await Promise.all(
    ['0241000002', '0241000003'].map((phone) =>
      f.request('POST', '/v1/auth/phone/request', { phone }),
    ),
  );
  assert.deepEqual(results.map((res) => res.statusCode).sort(), [200, 429]);
  assert.equal(
    results.find((res) => res.statusCode === 429)!.json().error.code,
    'phone_source_limited',
  );
  assert.equal(sends, 2);
  const forged = await f.request(
    'POST',
    '/v1/auth/phone/request',
    { phone: '0241000004' },
    undefined,
    { 'x-forwarded-for': '192.0.2.99' },
  );
  assert.equal(forged.statusCode, 429);
  const other = await f.request(
    'POST',
    '/v1/auth/phone/request',
    { phone: '0241000005' },
    undefined,
    {},
    '192.0.2.10',
  );
  assert.equal(other.statusCode, 200, other.body);
  assert.equal(sends, 3);
  await assert.rejects(
    f.owner.query("UPDATE app.phone_otp_challenges SET source_hash=repeat('a',64)"),
    /phone_otp_immutable/,
  );
});

test('PHONE-06: landlines spend no SMS budget; explicit rejection has a safe, distinct error', async (t) => {
  let sends = 0;
  const f = await setup(
    t,
    1000,
    {},
    {
      send: async () => {
        sends++;
        throw new SmsSendError('rejected');
      },
    },
  );
  const landline = await f.request('POST', '/v1/auth/phone/request', { phone: '0301234567' });
  assert.equal(landline.statusCode, 400);
  assert.equal(landline.json().error.code, 'invalid_phone');
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.phone_otp_challenges')).rows[0].n,
    0,
  );
  assert.equal(sends, 0);
  const rejected = await f.request('POST', '/v1/auth/phone/request', { phone: '0241000006' });
  assert.equal(rejected.statusCode, 503, rejected.body);
  assert.equal(rejected.json().error.code, 'sms_delivery_rejected');
  assert.equal(sends, 1);
  const row = (await f.owner.query('SELECT * FROM app.phone_otp_challenges')).rows[0];
  assert.equal(row.state, 'failed');
  assert.equal(row.code_hash, null);
  assert.equal(row.phone_ciphertext, null);
});

test('PHONE-04: concurrent verification consumes once; later OTP reopens the same phone account', async (t) => {
  let code = '';
  const { owner, runtime, request } = await setup(
    t,
    1000,
    {},
    {
      send: async (_phone, message) => {
        code = message.match(/\b(\d{6})\b/)![1]!;
        return 'test-receipt';
      },
    },
  );
  const first = await request('POST', '/v1/auth/phone/request', { phone: '0241234567' });
  assert.equal(first.statusCode, 200, first.body);
  const { challengeId } = first.json().data;
  const race = await Promise.all(
    [1, 2].map(() => request('POST', '/v1/auth/phone/verify', { challengeId, code })),
  );
  assert.deepEqual(race.map((r) => r.statusCode).sort(), [200, 401]);
  const accountId = race.find((r) => r.statusCode === 200)!.json().data.account.id;
  await assert.rejects(
    runtime.query('UPDATE app.phone_otp_challenges SET attempts=0 WHERE id=$1', [challengeId]),
    /phone_otp_immutable/,
  );
  await assert.rejects(
    runtime.query(
      "UPDATE app.phone_otp_challenges SET created_at=created_at-interval '1 day' WHERE id=$1",
      [challengeId],
    ),
    /phone_otp_immutable/,
  );
  await assert.rejects(
    runtime.query('DELETE FROM app.phone_otp_challenges WHERE id=$1', [challengeId]),
    /phone_otp_window_live/,
  );
  const fixture = await owner.connect();
  try {
    await fixture.query('BEGIN');
    await fixture.query('SET LOCAL session_replication_role=replica');
    await fixture.query(
      "UPDATE app.phone_otp_challenges SET created_at=created_at-interval '61 seconds',expires_at=expires_at-interval '61 seconds' WHERE id=$1",
      [challengeId],
    );
    await fixture.query('COMMIT');
  } finally {
    fixture.release();
  }
  const second = await request('POST', '/v1/auth/phone/request', { phone: '+233241234567' });
  assert.equal(second.statusCode, 200, second.body);
  const again = await request('POST', '/v1/auth/phone/verify', {
    challengeId: second.json().data.challengeId,
    code,
  });
  assert.equal(again.statusCode, 200, again.body);
  assert.equal(again.json().data.account.id, accountId);
  assert.equal(
    (await owner.query("SELECT count(*)::int AS n FROM app.auth_identities WHERE provider='phone'"))
      .rows[0].n,
    1,
  );
});

test('KYC-01: Google commuter upgrades the same account by OTP without creating a phone sign-in identity', async (t) => {
  let code = '';
  const { owner, request, sign } = await setup(
    t,
    1000,
    {},
    {
      send: async (_phone, message) => {
        code = message.match(/\b(\d{6})\b/)![1]!;
        return 'test-receipt';
      },
    },
  );
  const rider = await sign('kyc-google-upgrade');
  await owner.query(
    "UPDATE app.users SET first_name='Test',last_name='Rider',display_name='Test Rider' WHERE id=$1",
    [rider.account.id],
  );
  const before = await request('GET', '/v1/me/verification', undefined, rider.accessToken);
  assert.equal(before.statusCode, 200, before.body);
  assert.equal(before.json().data.standbyEligible, false);
  const started = await request(
    'POST',
    '/v1/me/phone-verification/start',
    { phone: '0241234567' },
    rider.accessToken,
  );
  assert.equal(started.statusCode, 200, started.body);
  const confirmed = await request(
    'POST',
    '/v1/me/phone-verification/confirm',
    { challengeId: started.json().data.challengeId, code },
    rider.accessToken,
  );
  assert.equal(confirmed.statusCode, 200, confirmed.body);
  assert.equal(confirmed.json().data.status, 'verified');
  const after = await request('GET', '/v1/me/verification', undefined, rider.accessToken);
  assert.equal(after.json().data.phone.status, 'verified');
  assert.equal(after.json().data.standbyEligible, true);
  assert.equal(
    (await owner.query("SELECT count(*)::int AS n FROM app.auth_identities WHERE provider='phone'"))
      .rows[0].n,
    0,
  );
  assert.equal((await owner.query('SELECT count(*)::int AS n FROM app.users')).rows[0].n, 1);
  const replay = await request(
    'POST',
    '/v1/me/phone-verification/confirm',
    { challengeId: started.json().data.challengeId, code },
    rider.accessToken,
  );
  assert.equal(replay.statusCode, 401, replay.body);
});

test('KYC-02: account-bound code cannot be redeemed by another signed-in rider', async (t) => {
  let code = '';
  const { request, sign } = await setup(
    t,
    1000,
    {},
    {
      send: async (_phone, message) => {
        code = message.match(/\b(\d{6})\b/)![1]!;
        return 'test-receipt';
      },
    },
  );
  const first = await sign('kyc-first');
  const second = await sign('kyc-second');
  const started = await request(
    'POST',
    '/v1/me/phone-verification/start',
    { phone: '0241234567' },
    first.accessToken,
  );
  assert.equal(started.statusCode, 200, started.body);
  const challengeId = started.json().data.challengeId;
  const wrongOwner = await request(
    'POST',
    '/v1/me/phone-verification/confirm',
    { challengeId, code },
    second.accessToken,
  );
  assert.equal(wrongOwner.statusCode, 401, wrongOwner.body);
  const rightOwner = await request(
    'POST',
    '/v1/me/phone-verification/confirm',
    { challengeId, code },
    first.accessToken,
  );
  assert.equal(rightOwner.statusCode, 200, rightOwner.body);
});

test('KYC-03: verified new rider joins standby, Ops offers, and rider can withdraw', async (t) => {
  const { owner, runtime, request, sign } = await setup(t);
  const rider = await sign('standby-rider');
  assert.equal(
    (await request('GET', '/v1/me/verification', undefined, rider.accessToken)).statusCode,
    200,
  );
  const riderId = rider.account.id as string;
  await owner.query(
    "UPDATE app.users SET first_name='Test',last_name='Rider',display_name='Test Rider' WHERE id=$1",
    [riderId],
  );
  const adminId = randomUUID();
  await owner.query(
    "INSERT INTO app.users(id,role,display_name) VALUES ($1,'admin','Pilot admin')",
    [adminId],
  );
  const standby = new StandbyService({
    pool: runtime,
    authorizeSession: async () => {},
    purchases: {} as Purchases,
    cursorSecret: Buffer.alloc(32, 6),
  });
  const riderActor = { userId: riderId, sessionId: randomUUID() };
  const adminActor = { userId: adminId, sessionId: randomUUID() };
  await assert.rejects(
    standby.join(riderActor, {}),
    (error: any) => error?.code === 'phone_verification_required',
  );
  await owner.query(
    `INSERT INTO app.commuter_phone_verifications(user_id,phone_hash,last_four,verified_at,method)
     VALUES ($1,$2,'4567',clock_timestamp(),'account_upgrade')`,
    [riderId, 'a'.repeat(64)],
  );
  const one = async (sql: string, params: unknown[] = []) =>
    (await owner.query(sql + ' RETURNING id', params)).rows[0].id as string;
  const route = await one("INSERT INTO app.routes(name) VALUES ('Standby corridor')");
  const stop = await one(
    "INSERT INTO app.stops(name,latitude,longitude) VALUES ('Pilot stop',5.6,-0.2)",
  );
  const legs: Record<string, string>[] = [];
  for (const direction of ['outbound', 'return']) {
    const pattern = await one('INSERT INTO app.route_patterns(route_id,direction) VALUES ($1,$2)', [
      route,
      direction,
    ]);
    const version = await one(
      'INSERT INTO app.route_pattern_versions(pattern_id,revision) VALUES ($1,1)',
      [pattern],
    );
    const pickup = await one(
      "INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude) VALUES ($1,$2,0,'Start',5.6,-0.2)",
      [version, stop],
    );
    const dropoff = await one(
      "INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude) VALUES ($1,$2,1,'End',5.6,-0.2)",
      [version, stop],
    );
    const geometry = await one(
      "INSERT INTO app.route_geometries(pattern_version_id,source,line) VALUES ($1,'configured',ST_GeomFromText('LINESTRING(-0.2 5.6,-0.21 5.6)',4326))",
      [version],
    );
    await owner.query('INSERT INTO app.geometry_stop_distances VALUES ($1,$2,$3,0)', [
      geometry,
      version,
      pickup,
    ]);
    await owner.query('INSERT INTO app.geometry_stop_distances VALUES ($1,$2,$3,1000)', [
      geometry,
      version,
      dropoff,
    ]);
    await owner.query("UPDATE app.route_geometries SET state='published' WHERE id=$1", [geometry]);
    await owner.query(
      "UPDATE app.route_pattern_versions SET state='published',geometry_id=$2,effective_from='2026-01-01' WHERE id=$1",
      [version, geometry],
    );
    const departure = await one('INSERT INTO app.service_departures(pattern_id) VALUES ($1)', [
      pattern,
    ]);
    const schedule = await one(
      `INSERT INTO app.service_schedules(pattern_version_id,service_window,local_departure,weekdays,effective_from,departure_id,pattern_id)
       VALUES ($1,'morning','06:30',ARRAY[1,2,3,4,5]::smallint[],'2026-01-01',$2,$3)`,
      [version, departure, pattern],
    );
    legs.push({
      direction,
      scheduleId: schedule,
      patternVersionId: version,
      pickupOccurrenceId: pickup,
      dropoffOccurrenceId: dropoff,
    });
  }
  const selection = { plan: 'monthly', routeId: route, legs, useCredit: false };
  const standbyRequest = { selection, travelDays: [1, 2, 3, 4, 5] };
  const joined = await standby.join(riderActor, standbyRequest);
  assert.equal(joined.status, 201);
  const appId = (joined.body as any).data.id as string;
  assert.equal((await standby.join(riderActor, standbyRequest)).status, 200);
  const expiresAt = new Date(Date.now() + 86400000).toISOString();
  for (const leg of legs)
    await owner.query(
      `INSERT INTO app.route_fares(route_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id,
     amount_pesewas,effective_from,created_by,command_id) VALUES ($1,$2,$3,$4,600,'2026-01-01',$5,gen_random_uuid())`,
      [route, leg.patternVersionId, leg.pickupOccurrenceId, leg.dropoffOccurrenceId, adminId],
    );
  const offerInput = {
    expiresAt,
    coverageStart: new Date(Date.now() + 2 * 86400000).toISOString().slice(0, 10),
    coverageEnd: new Date(Date.now() + 16 * 86400000).toISOString().slice(0, 10),
    price: { amountMinor: 12000, currency: 'GHS' },
    credits: ['outbound', 'return'].map((direction) => ({
      direction,
      creditPerUnusedRide: { amountMinor: 50, currency: 'GHS' },
    })),
    reason: 'Seat open on the pilot route',
  };
  const offerKey = randomUUID();
  const offered = await standby.offer(adminActor, appId, offerInput, offerKey);
  assert.equal((offered.body as any).data.offer.state, 'offered');
  assert.deepEqual(await standby.offer(adminActor, appId, offerInput, offerKey), offered);
  await assert.rejects(
    standby.offer(
      adminActor,
      appId,
      { ...offerInput, expiresAt: new Date(Date.now() + 2 * 86400000).toISOString() },
      offerKey,
    ),
    (error: any) => error?.code === 'idempotency_conflict',
  );
  await assert.rejects(
    standby.offer(adminActor, appId, offerInput, randomUUID()),
    (error: any) => error?.code === 'standby_not_pending',
  );
  const notice = await owner.query(
    'SELECT kind,target_type,target_id FROM app.rider_notifications WHERE user_id=$1',
    [riderId],
  );
  assert.deepEqual(
    notice.rows.map((r) => r.kind),
    ['standby_offered'],
  );
  assert.equal(notice.rows[0].target_id, appId);
  const firstPage = (await standby.list(adminActor, true, { limit: '1' })).body as any;
  assert.equal(firstPage.data.length, 1);
  const otherRider = randomUUID();
  await owner.query(
    "INSERT INTO app.users(id,role,display_name) VALUES ($1,'commuter','Other rider')",
    [otherRider],
  );
  await owner.query(
    'INSERT INTO app.standby_applications(user_id,route_id,selection) VALUES ($1,$2,$3::jsonb)',
    [otherRider, route, JSON.stringify(selection)],
  );
  const pageOne = (await standby.list(adminActor, true, { limit: '1' })).body as any;
  assert.equal(pageOne.data.length, 1);
  assert.ok(pageOne.page.nextCursor);
  const pageTwo = (
    await standby.list(adminActor, true, { limit: '1', cursor: pageOne.page.nextCursor })
  ).body as any;
  assert.equal(pageTwo.data.length, 1);
  assert.notEqual(pageTwo.data[0].id, pageOne.data[0].id);
  assert.equal(pageTwo.page.nextCursor, null);
  assert.deepEqual(pageOne.routeDemand, [
    { routeId: route, routeName: 'Standby corridor', requests: 2 },
  ]);
  assert.deepEqual(pageTwo.routeDemand, pageOne.routeDemand);
  await owner.query(
    "UPDATE app.standby_applications SET travel_days=ARRAY[1,3]::smallint[], selection=jsonb_set(selection,'{plan}','\"annual\"') WHERE user_id=$1",
    [otherRider],
  );
  const pending = (
    await standby.list(adminActor, true, {
      routeId: route,
      state: 'submitted',
      plan: 'annual',
      day: '3',
      q: 'other',
    })
  ).body as any;
  assert.equal(pending.data.length, 1);
  assert.equal(pending.data[0].riderId, otherRider);
  assert.equal(pending.routeDemand[0].requests, 1);
  const none = (await standby.list(adminActor, true, { day: '7' })).body as any;
  assert.deepEqual(none.data, []);
  assert.deepEqual(none.routeDemand, []);
  const literal = (await standby.list(adminActor, true, { q: '%' })).body as any;
  assert.deepEqual(literal.data, []);
  for (const filter of [
    { routeId: 'bad' },
    { state: 'bogus' },
    { plan: 'weekly' },
    { day: '8' },
    { day: '1.5' },
  ])
    await assert.rejects(
      standby.list(adminActor, true, filter),
      (e: any) => e?.code === 'invalid_query',
    );
  for (const filter of [
    { routeId: route },
    { state: 'submitted' },
    { plan: 'annual' },
    { day: '1' },
    { q: 'Other' },
  ])
    await assert.rejects(
      standby.list(adminActor, true, { cursor: pageOne.page.nextCursor, ...filter }),
      (e: any) => e?.code === 'invalid_cursor',
    );
  await assert.rejects(
    standby.list(riderActor, false, { state: 'submitted' }),
    (e: any) => e?.code === 'invalid_query',
  );
  assert.equal(
    (await standby.list(riderActor)).body &&
      'routeDemand' in ((await standby.list(riderActor)).body as object),
    false,
  );
  // Two routes may share a name. Demand uses IDs and is not scoped to the
  // currently selected route, nor to the one-row page above.
  const anotherRoute = await one("INSERT INTO app.routes(name) VALUES ('Standby corridor')");
  const anotherRider = await one(
    "INSERT INTO app.users(role,display_name) VALUES ('commuter','Third rider')",
  );
  await owner.query(
    'INSERT INTO app.standby_applications(user_id,route_id,selection,travel_days) VALUES ($1,$2,$3::jsonb,ARRAY[1]::smallint[])',
    [anotherRider, anotherRoute, JSON.stringify({ ...selection, routeId: anotherRoute })],
  );
  const scoped = (await standby.list(adminActor, true, { routeId: route, limit: '1' })).body as any;
  assert.equal(scoped.data[0].selection.routeId, route);
  assert.equal(scoped.routeDemand.length, 2);
  assert.equal(scoped.routeDemand[0].routeId, route);
  assert.equal(scoped.routeDemand[0].requests, 2);
  assert.equal(scoped.routeDemand[1].routeId, anotherRoute);
  await assert.rejects(
    standby.list(riderActor, false, { cursor: pageOne.page.nextCursor }),
    (error: any) => error?.code === 'invalid_cursor',
  );
  await assert.rejects(
    standby.list(adminActor, true, { limit: '101' }),
    (error: any) => error?.code === 'invalid_query',
  );
  let signalPurchase!: () => void;
  let releasePurchase!: () => void;
  const purchaseStarted = new Promise<void>((resolve) => (signalPurchase = resolve));
  const purchaseRelease = new Promise<void>((resolve) => (releasePurchase = resolve));
  const racing = new StandbyService({
    pool: runtime,
    authorizeSession: async () => {},
    cursorSecret: Buffer.alloc(32, 6),
    purchases: {
      create: async () => {
        signalPurchase();
        await purchaseRelease;
        throw new TransportError(409, 'fare_unavailable', 'No current fare.');
      },
    } as unknown as Purchases,
  });
  const firstAcceptance = racing.accept(riderActor, appId, randomUUID());
  await purchaseStarted;
  await assert.rejects(
    racing.accept(riderActor, appId, randomUUID()),
    (error: any) => error?.code === 'offer_unavailable',
  );
  releasePurchase();
  await assert.rejects(firstAcceptance, (error: any) => error?.code === 'fare_unavailable');
  const refusing = new StandbyService({
    pool: runtime,
    authorizeSession: async () => {},
    cursorSecret: Buffer.alloc(32, 6),
    purchases: {
      create: async () => {
        throw new TransportError(409, 'fare_unavailable', 'No current fare.');
      },
    } as unknown as Purchases,
  });
  await assert.rejects(
    refusing.accept(riderActor, appId, randomUUID()),
    (error: any) => error?.code === 'fare_unavailable',
  );
  const reset = (await standby.list(riderActor)).body as any;
  assert.equal(reset.data[0].offer.state, 'offered');
  const withdrawn = await standby.withdraw(riderActor, appId);
  assert.equal((withdrawn.body as any).data.state, 'withdrawn');
  assert.deepEqual(await standby.offer(adminActor, appId, offerInput, offerKey), offered);
});

async function setup(
  t: TestContext,
  authBudget = 1000,
  providers: Partial<Pick<AuthOptions, 'google' | 'apple'>> = {},
  sms?: SmsSender,
  erasureJournal?: ErasureJournal,
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
  const sentEmails: string[] = [];
  const identity = {
    opsOrigin: 'https://ops.example.invalid',
    opsEmail: new TransactionalEmail({
      pool: runtime,
      encryptionKey: Buffer.alloc(32, 21),
      staging: true,
      sender: {
        send: async (message) => {
          sentEmails.push(message.text);
          return randomUUID();
        },
      },
    }),
    access,
    pinSecret,
    refreshTtlDays: 30,
    shiftTtlHours: 12,
    google,
    apple,
    providerEncryptionKey: encryptionKey,
    phoneIdentityKey: encryptionKey,
    passkeys: testPasskeys,
    appleTokens: {
      exchangeCode: async (code: string) => ({
        refreshToken: code === 'used' ? null : 'apple-private-refresh',
      }),
      revoke: async () => {},
    },
    ...providers,
    ...(sms ? { phoneOtp: new PhoneOtp(runtime, sms, encryptionKey, true) } : {}),
  };
  const emailDeliveries: Promise<void>[] = [];
  const commuterEmail = {
    queueEmailAccess: identity.opsEmail.queueEmailAccess,
    queuePasswordChanged: identity.opsEmail.queuePasswordChanged,
    sendQueued: (id: string) => {
      const promise = identity.opsEmail.sendQueued(id);
      emailDeliveries.push(promise);
      return promise;
    },
  };
  const service = new AuthService({
    ...identity,
    commuterEmail,
    pool: runtime,
    cursorSecret: Buffer.alloc(32, 6),
  });
  const app = await createReplacementApp({
    credentialReplayKey: Buffer.alloc(32, 9),
    pool: runtime,
    cursorSecret: Buffer.alloc(32, 6),
    identity: { ...identity, commuterEmail },
    compose: ({ authorizeSession }) => ({
      account: new AccountService({
        pool: runtime,
        authorizeSession,
        deviceKey: Buffer.alloc(32, 25),
        erasureJournal,
      }),
    }),
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
    remoteAddress = '127.0.0.1',
  ) {
    return app.inject({
      method,
      url: path,
      remoteAddress,
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
    sentEmails,
    emailDelivered: () => Promise.all(emailDeliveries),
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
  // Seeded with a private PIN: nothing operations issued is outstanding.
  assert.equal(short.mustChangePin, false);
  assert.equal(short.temporaryPinExpiresAt, null);
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
  assert.deepEqual(await f.service.authorizeActor(client, actor), {
    role: 'commuter',
    driverId: null,
  });
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
test('OPS-TEAM: invitation ownership, passkey activation, superadmin boundaries and account deletion', async (t) => {
  const store = new MemoryErasureStore();
  const journal = new ErasureJournal(store, randomUUID(), randomBytes(32));
  const f = await setup(t, 1000, {}, undefined, journal);
  await new ErasureRecovery(f.owner, journal, Buffer.alloc(32, 25)).initialize();
  const owner = await operator(f, 'team-owner');
  await register(f, owner.token);
  const database = (await f.owner.query('SELECT current_database() AS name')).rows[0].name;
  await assert.rejects(bootstrapSuperadmin(f.runtime, owner.id, database));
  await assert.rejects(bootstrapSuperadmin(f.owner, owner.id, 'wrong_database'));
  await bootstrapSuperadmin(f.owner, owner.id, database);
  await assert.rejects(bootstrapSuperadmin(f.owner, owner.id, database), /already completed/);
  await assert.rejects(
    f.owner.query('UPDATE app.users SET is_superadmin=false WHERE id=$1', [owner.id]),
    /last_superadmin/,
  );
  const selfChange = await ops(
    f,
    'POST',
    `/v1/ops/team/members/${owner.id.toUpperCase()}/access`,
    owner.token,
    { action: 'delete' },
  );
  assert.equal(selfChange.json().error.code, 'self_access_change');
  const selfErasure = await f.request('DELETE', '/v1/me', undefined, owner.token, {
    'idempotency-key': randomUUID(),
  });
  assert.equal(selfErasure.json().error.code, 'last_superadmin');
  assert.equal(
    (await journal.require()).value.entries.length,
    0,
    'refusal must not journal deletion',
  );
  const outsider = await operator(f, 'team-regular');
  await register(f, outsider.token);
  assert.equal((await ops(f, 'GET', '/v1/ops/team', outsider.token)).statusCode, 403);
  const unexplained = await ops(
    f,
    'POST',
    `/v1/ops/team/members/${outsider.id}/access`,
    owner.token,
    { action: 'make_superadmin', reason: '  ' },
  );
  assert.equal(unexplained.statusCode, 400);
  assert.equal(unexplained.json().error.code, 'reason_required');
  data(
    await ops(f, 'POST', `/v1/ops/team/members/${outsider.id}/access`, owner.token, {
      action: 'make_superadmin',
      reason: 'Covers dispatch on weekends',
    }),
  );
  assert.equal(
    (
      await f.owner.query(
        "SELECT reason FROM app.ops_team_events WHERE target_id=$1 AND action='make_superadmin'",
        [outsider.id],
      )
    ).rows[0].reason,
    'Covers dispatch on weekends',
  );
  assert.equal(
    (await f.owner.query('SELECT is_superadmin FROM app.users WHERE id=$1', [outsider.id])).rows[0]
      .is_superadmin,
    true,
  );
  assert.equal(
    (await ops(f, 'GET', '/v1/ops/team', outsider.token)).statusCode,
    401,
    'promotion also revokes old sessions',
  );
  data(
    await ops(f, 'POST', `/v1/ops/team/members/${outsider.id}/access`, owner.token, {
      action: 'make_admin',
    }),
  );
  assert.equal(
    (await f.owner.query('SELECT is_superadmin FROM app.users WHERE id=$1', [outsider.id])).rows[0]
      .is_superadmin,
    false,
  );
  const invite = (email: string, key = randomUUID()) =>
    ops(
      f,
      'POST',
      '/v1/ops/team/invitations',
      owner.token,
      { email, name: 'Invited operator' },
      key,
    );
  // Team changes need a passkey check from the last few minutes, not the
  // eight-hour elevation. The console prompts on the same code as elevation.
  await f.owner.query(
    "UPDATE app.auth_sessions SET admin_verified_at=clock_timestamp()-interval '10 minutes' WHERE user_id=$1",
    [owner.id],
  );
  assert.equal((await ops(f, 'GET', '/v1/ops/team', owner.token)).statusCode, 200);
  const stale = await invite('stale@example.invalid');
  assert.equal(stale.statusCode, 403);
  assert.equal(stale.json().error.code, 'passkey_required');
  assert.equal(
    (await ops(f, 'POST', `/v1/ops/users/${outsider.id}/passkeys/reset`, owner.token)).json().error
      .code,
    'passkey_required',
  );
  assert.equal(
    (await f.owner.query("SELECT 1 FROM app.ops_invitations WHERE email='stale@example.invalid'"))
      .rowCount,
    0,
  );
  await f.owner.query(
    'UPDATE app.auth_sessions SET admin_verified_at=clock_timestamp() WHERE user_id=$1',
    [owner.id],
  );
  // A rider's address is never turned into an operator account.
  data(
    await f.request('POST', '/v1/auth/google', {
      idToken: await identityToken('existing-rider', 'google', { email: 'rider@example.invalid' }),
    }),
  );
  const riderInvite = await invite('Rider@Example.invalid');
  assert.equal(riderInvite.statusCode, 409);
  assert.equal(riderInvite.json().error.code, 'operator_account_conflict');
  const key = randomUUID();
  const created = await invite('invited@example.invalid', key);
  const id = data(created).id;
  assert.equal(data(await invite('invited@example.invalid', key)).id, id);
  assert.equal(f.sentEmails.length, 1, 'command replay must not queue another email');
  assert.equal((await invite('different@example.invalid', key)).statusCode, 409);
  const oldToken = f.sentEmails.at(-1)!.match(/#invite=([A-Za-z0-9_-]+)/)![1]!;
  const signOps = (subject: string, email: string, invitationToken?: string) =>
    identityToken(subject, 'google', { email }).then((idToken) =>
      ops(f, 'POST', '/v1/auth/ops/google', '', {
        idToken,
        ...(invitationToken ? { invitationToken } : {}),
      }),
    );
  const count = Number((await f.owner.query('SELECT count(*) FROM app.users')).rows[0].count);
  assert.equal((await signOps('uninvited', 'other@example.invalid')).statusCode, 403);
  assert.equal((await signOps('uninvited', 'other@example.invalid', oldToken)).statusCode, 403);
  assert.equal(
    Number((await f.owner.query('SELECT count(*) FROM app.users')).rows[0].count),
    count,
    'refused Ops sign-in must not create commuter accounts',
  );
  data(await ops(f, 'POST', `/v1/ops/team/invitations/${id}/resend`, owner.token));
  const token = f.sentEmails.at(-1)!.match(/#invite=([A-Za-z0-9_-]+)/)![1]!;
  assert.notEqual(token, oldToken);
  assert.equal((await signOps('invited-sub', 'invited@example.invalid', oldToken)).statusCode, 403);
  const signed = data(await signOps('invited-sub', 'invited@example.invalid', token));
  assert.equal(signed.account.role, 'admin');
  assert.equal(signed.account.isSuperadmin, false);
  assert.equal((await ops(f, 'GET', '/v1/ops/riders', signed.accessToken)).statusCode, 403);
  assert.equal(
    (
      await f.owner.query('SELECT ops_invite_pending FROM app.users WHERE id=$1', [
        signed.account.id,
      ])
    ).rows[0].ops_invite_pending,
    true,
  );
  await register(f, signed.accessToken);
  assert.deepEqual(
    (await f.owner.query('SELECT email,name,token_hash FROM app.ops_invitations WHERE id=$1', [id]))
      .rows[0],
    { email: null, name: null, token_hash: null },
  );
  assert.equal((await ops(f, 'GET', '/v1/ops/riders', signed.accessToken)).statusCode, 200);
  assert.equal((await ops(f, 'GET', '/v1/ops/team', signed.accessToken)).statusCode, 403);
  assert.equal(
    (await ops(f, 'POST', `/v1/ops/users/${owner.id}/passkeys/reset`, signed.accessToken))
      .statusCode,
    403,
  );
  assert.equal(
    (await signOps('invited-sub', 'invited@example.invalid', token)).statusCode,
    403,
    'consumed invitation does not replay access',
  );
  assert.equal(
    (await signOps('invited-sub', 'invited@example.invalid')).statusCode,
    200,
    'ordinary login needs no invitation after activation',
  );
  assert.equal((await ops(f, 'GET', '/v1/ops/team?limit=200', owner.token)).statusCode, 200);
  assert.equal((await ops(f, 'GET', '/v1/ops/team?limit=201', owner.token)).statusCode, 400);
  const everyone = (await ops(f, 'GET', '/v1/ops/team?limit=200', owner.token)).json().data;
  assert.equal(everyone[0].id, signed.account.id, 'newest entry first, as the contract declares');
  const page1 = await ops(f, 'GET', '/v1/ops/team?limit=1', owner.token);
  assert.equal(page1.json().data.length, 1);
  assert.equal(page1.json().data[0].id, everyone[0].id);
  const next = page1.json().page.nextCursor;
  assert.ok(next);
  const page2 = await ops(
    f,
    'GET',
    `/v1/ops/team?limit=1&cursor=${encodeURIComponent(next)}`,
    owner.token,
  );
  assert.equal(page2.json().data[0].id, everyone[1].id);
  const deleteKey = randomUUID();
  const remove = (token = owner.token, key = deleteKey) =>
    ops(
      f,
      'POST',
      `/v1/ops/team/members/${signed.account.id}/access`,
      token,
      { action: 'delete' },
      key,
    );
  assert.equal((await remove(signed.accessToken)).statusCode, 403);
  const commuter = await f.sign('not-an-operator');
  assert.equal(
    (
      await ops(f, 'POST', `/v1/ops/team/members/${commuter.account.id}/access`, owner.token, {
        action: 'delete',
      })
    ).statusCode,
    404,
  );
  await f.owner.query("UPDATE app.erasure_recovery_control SET mode='fenced'");
  assert.equal((await remove()).json().error.code, 'account_recovery_fenced');
  await f.owner.query("UPDATE app.erasure_recovery_control SET mode='active'");
  store.refuse = true;
  assert.equal((await remove()).json().error.code, 'erasure_journal_unavailable');
  store.refuse = false;
  assert.equal((await journal.require()).value.entries.length, 0);
  assert.equal(
    (await f.owner.query('SELECT deleted_at FROM app.users WHERE id=$1', [signed.account.id]))
      .rows[0].deleted_at,
    null,
  );
  data(await remove());
  data(await remove()); // Same command replays after the target is erased.
  assert.equal((await remove(owner.token, randomUUID())).statusCode, 404);
  const erased = (
    await f.owner.query(
      'SELECT role,deleted_at,display_name,email,phone,is_superadmin FROM app.users WHERE id=$1',
      [signed.account.id],
    )
  ).rows[0];
  assert.ok(erased.deleted_at);
  assert.equal(erased.role, 'admin', 'erasure must not convert the account into a commuter');
  assert.equal(erased.display_name, null);
  assert.equal(erased.email, null);
  assert.equal(erased.phone, null);
  assert.equal(erased.is_superadmin, false);
  assert.equal(
    (
      await f.owner.query(
        'SELECT 1 FROM app.admin_passkeys WHERE user_id=$1 AND revoked_at IS NULL',
        [signed.account.id],
      )
    ).rowCount,
    0,
  );
  assert.equal(
    (
      await f.owner.query(
        "SELECT 1 FROM app.auth_identities WHERE user_id=$1 AND subject NOT LIKE 'erased:%'",
        [signed.account.id],
      )
    ).rowCount,
    0,
  );
  const deletion = (
    await f.owner.query('SELECT session_id FROM app.account_erasures WHERE user_id=$1', [
      signed.account.id,
    ])
  ).rows[0];
  const entries = (await journal.require()).value.entries;
  assert.equal(entries.length, 1);
  assert.equal(entries[0]!.userId, signed.account.id);
  assert.equal(entries[0]!.sessionId, deletion.session_id);
  assert.equal(
    (
      await f.owner.query('SELECT user_id FROM app.auth_sessions WHERE id=$1', [
        deletion.session_id,
      ])
    ).rows[0].user_id,
    owner.id,
    'deletion records the requesting superadmin session',
  );
  assert.equal((await ops(f, 'GET', '/v1/ops/riders', signed.accessToken)).statusCode, 401);
  assert.equal((await signOps('invited-sub', 'invited@example.invalid')).statusCode, 403);
  assert.ok(
    (
      await f.owner.query(
        "SELECT 1 FROM app.ops_team_events WHERE action='delete' AND target_id=$1",
        [signed.account.id],
      )
    ).rowCount,
  );
});

test('OPS-TEAM: expired or cancelled setup cannot activate, and invitation secret is hashed', async (t) => {
  const f = await setup(t),
    owner = await operator(f, 'team-expiry-owner');
  await register(f, owner.token);
  await f.owner.query('UPDATE app.users SET is_superadmin=true WHERE id=$1', [owner.id]);
  const existingCommuter = await f.sign('setup-rider');
  const invite = data(
    await ops(f, 'POST', '/v1/ops/team/invitations', owner.token, {
      email: 'setup@example.invalid',
      name: 'Setup',
    }),
  );
  const token = f.sentEmails.at(-1)!.match(/#invite=([A-Za-z0-9_-]+)/)![1]!;
  const row = (await f.owner.query('SELECT * FROM app.ops_invitations WHERE id=$1', [invite.id]))
    .rows[0];
  assert.notEqual(row.token_hash, token);
  const sign = (subject = 'setup-sub') =>
    identityToken(subject, 'google', { email: 'setup@example.invalid' }).then((idToken) =>
      ops(f, 'POST', '/v1/auth/ops/google', '', { idToken, invitationToken: token }),
    );
  // A Google identity that already has a rider account cannot claim, even
  // with the right link and address: cancelling would delete their rides.
  const conflict = await sign('setup-rider');
  assert.equal(conflict.statusCode, 409);
  assert.equal(conflict.json().error.code, 'operator_account_conflict');
  assert.equal(
    (
      await f.owner.query('SELECT role,ops_invite_pending FROM app.users WHERE id=$1', [
        existingCommuter.account.id,
      ])
    ).rows[0].role,
    'commuter',
  );
  data(await f.request('GET', '/v1/me', undefined, existingCommuter.accessToken));
  const signed = data(await sign());
  assert.notEqual(signed.account.id, existingCommuter.account.id);
  assert.equal(signed.account.email, 'setup@example.invalid');
  const started = data(
    await ops(f, 'POST', '/v1/auth/passkeys/registration/options', signed.accessToken),
  );
  data(await ops(f, 'POST', `/v1/ops/team/invitations/${invite.id}/cancel`, owner.token));
  const refused = await ops(
    f,
    'POST',
    '/v1/auth/passkeys/registration/verification',
    signed.accessToken,
    registrationResponse(started.challenge),
  );
  assert.equal(refused.statusCode, 401);
  assert.equal((await sign()).statusCode, 403);
  assert.ok(
    (await f.owner.query('SELECT deleted_at FROM app.users WHERE id=$1', [signed.account.id]))
      .rows[0].deleted_at,
    'cancelling claimed setup deletes the account rather than downgrading it',
  );
  assert.equal(
    (
      await f.owner.query('SELECT deleted_at FROM app.users WHERE id=$1', [
        existingCommuter.account.id,
      ])
    ).rows[0].deleted_at,
    null,
    'the rider account is untouched',
  );
  const invitation = data(
    await ops(f, 'POST', '/v1/ops/team/invitations', owner.token, {
      email: 'expired@example.invalid',
      name: 'Expiry',
    }),
  );
  const expiredToken = f.sentEmails.at(-1)!.match(/#invite=([A-Za-z0-9_-]+)/)![1]!;
  const expiredIdentity = await identityToken('expiry-sub', 'google', {
    email: 'expired@example.invalid',
  });
  const pending = data(
    await ops(f, 'POST', '/v1/auth/ops/google', '', {
      idToken: expiredIdentity,
      invitationToken: expiredToken,
    }),
  );
  await f.owner.query(
    "UPDATE app.ops_invitations SET created_at=clock_timestamp()-interval '2 days',expires_at=clock_timestamp()-interval '1 minute' WHERE id=$1",
    [invitation.id],
  );
  const expired = await ops(f, 'POST', '/v1/auth/ops/google', '', {
    idToken: await identityToken('expiry-sub', 'google', { email: 'expired@example.invalid' }),
    invitationToken: expiredToken,
  });
  assert.equal(expired.statusCode, 403);
  assert.equal(
    (await ops(f, 'POST', '/v1/auth/passkeys/registration/options', pending.accessToken)).json()
      .error.code,
    'invitation_expired',
  );
});

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
  key = randomUUID(),
) {
  return f.app.inject({
    method,
    url: path,
    ...((method === 'POST' ? withReason(path, body) : body) !== undefined
      ? { payload: (method === 'POST' ? withReason(path, body) : body) as object }
      : {}),
    headers: {
      authorization: `Bearer ${token}`,
      'x-trotxi-client': 'ops',
      'x-trotxi-build': '2',
      'idempotency-key': key,
    },
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
      authenticatorData: Buffer.from('test-authenticator-data').toString('base64url'),
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

test('PASSKEY-04 only another elevated superadmin can reset passkeys', async (t) => {
  const f = await setup(t);
  const lost = await operator(f, 'ops-passkey-4a');
  await register(f, lost.token);
  const helper = await operator(f, 'ops-passkey-4b');
  await register(f, helper.token);
  const regular = await ops(f, 'POST', `/v1/ops/users/${lost.id}/passkeys/reset`, helper.token);
  assert.equal(regular.statusCode, 403);
  assert.equal(regular.json().error.code, 'superadmin_required');
  await f.owner.query('UPDATE app.users SET is_superadmin=true WHERE id=$1', [helper.id]);

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

/** Ops actions that must say why; tests that do not test the reason supply one. */
function withReason(url: string, payload: unknown): unknown {
  if (!/^\/v1\/ops\/(team\/|users\/[^/]+\/passkeys\/reset)/.test(url)) return payload;
  if (payload === undefined) return { reason: 'Test reason' };
  if (payload && typeof payload === 'object' && !Array.isArray(payload) && !('reason' in payload))
    return { ...payload, reason: 'Test reason' };
  return payload;
}

const emailPassword = 'correct horse trotxi battery';
const emailRegistration = {
  email: 'ama@outlook.com',
  firstName: 'Ama',
  otherNames: 'Akua',
  lastName: 'Mensah',
};
async function emailToken(f: Awaited<ReturnType<typeof setup>>) {
  await f.emailDelivered();
  const message = f.sentEmails.at(-1)!;
  return (
    message.match(/token=([A-Za-z0-9_-]{43})/)?.[1] ??
    message.match(/Verification code: ([A-Za-z0-9_-]{43})/)?.[1] ??
    assert.fail('No verification token in fake mail')
  );
}
async function registeredEmail(f: Awaited<ReturnType<typeof setup>>) {
  data(await f.request('POST', '/v1/auth/email/signup', emailRegistration));
  data(
    await f.request('POST', '/v1/auth/email/complete', {
      token: await emailToken(f),
      password: emailPassword,
    }),
    204,
  );
  return data(
    await f.request('POST', '/v1/auth/email/login', {
      email: emailRegistration.email,
      password: emailPassword,
    }),
  );
}
test('EMAIL-01 any email domain, full names, proof before password, no automatic phone verification', async (t) => {
  const f = await setup(t);
  data(
    await f.request('POST', '/v1/auth/email/signup', {
      ...emailRegistration,
      email: 'AMA@outlook.com',
    }),
  );
  const token = await emailToken(f);
  assert.equal(f.sentEmails.length, 1);
  assert.equal(
    (
      await f.request('POST', '/v1/auth/email/login', {
        email: emailRegistration.email,
        password: emailPassword,
      })
    ).statusCode,
    401,
  );
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.auth_sessions')).rows[0].n,
    0,
  );
  const stored = (await f.owner.query('SELECT * FROM app.email_auth_challenges')).rows[0];
  assert.equal(stored.token_hash, hashToken(token));
  data(await f.request('POST', '/v1/auth/email/complete', { token, password: emailPassword }), 204);
  assert.equal(
    (await f.request('POST', '/v1/auth/email/complete', { token, password: emailPassword }))
      .statusCode,
    400,
  );
  const session = data(
    await f.request('POST', '/v1/auth/email/login', {
      email: emailRegistration.email,
      password: emailPassword,
    }),
  );
  assert.equal(session.account.displayName, 'Ama Akua Mensah');
  assert.equal(session.account.firstName, 'Ama');
  assert.equal(session.account.lastName, 'Mensah');
  assert.equal(session.account.otherNames, 'Akua');
  const verification = data(
    await f.request('GET', '/v1/me/verification', undefined, session.accessToken),
  );
  assert.equal(verification.standbyEligible, false);
  assert.deepEqual(verification.missing, ['phone']);
  const cr = (await f.owner.query('SELECT * FROM app.email_credentials')).rows[0];
  assert.ok(cr.password_hash.startsWith('argon2id-v1$'));
  assert.ok(!cr.password_hash.includes(emailPassword));
});
test('EMAIL-02 password reset is one-use, rejects old password, revokes every old session', async (t) => {
  const f = await setup(t),
    session = await registeredEmail(f);
  // Contact email is not an authentication identity. An independently issued
  // Ops invitation can produce a second contact row without owning this login.
  await f.owner.query("INSERT INTO app.users(role,email) VALUES('admin',$1)", [
    emailRegistration.email,
  ]);
  await f.owner.query(
    "UPDATE app.email_auth_challenges SET created_at=created_at-interval '2 minutes'",
  );
  const unknown = data(
    await f.request('POST', '/v1/auth/email/reset', { email: 'unknown@example.com' }),
  );
  const known = data(
    await f.request('POST', '/v1/auth/email/reset', { email: emailRegistration.email }),
  );
  assert.deepEqual(known, unknown);
  const token = await emailToken(f),
    password = 'another long password phrase';
  const results = await Promise.all(
    [1, 2].map(() => f.request('POST', '/v1/auth/email/complete', { token, password })),
  );
  assert.deepEqual(results.map((r) => r.statusCode).sort(), [204, 400]);
  assert.equal((await f.request('GET', '/v1/me', undefined, session.accessToken)).statusCode, 401);
  assert.equal(
    (
      await f.request('POST', '/v1/auth/email/login', {
        email: emailRegistration.email,
        password: emailPassword,
      })
    ).statusCode,
    401,
  );
  const fresh = data(
    await f.request('POST', '/v1/auth/email/login', { email: emailRegistration.email, password }),
  );
  assert.equal(fresh.account.id, session.account.id);
});
test('EMAIL-03 email linking requires the initiating account and session', async (t) => {
  const f = await setup(t),
    first = await f.sign('email-link'),
    other = await f.sign('email-other');
  data(
    await f.request(
      'POST',
      '/v1/me/email-access/link',
      { email: 'linked@yahoo.com' },
      first.accessToken,
    ),
  );
  const token = await emailToken(f);
  assert.equal(
    (await f.request('POST', '/v1/auth/email/complete', { token, password: emailPassword }))
      .statusCode,
    400,
  );
  assert.equal(
    (
      await f.request(
        'POST',
        '/v1/me/email-access/complete',
        { token, password: emailPassword },
        other.accessToken,
      )
    ).statusCode,
    400,
  );
  data(
    await f.request(
      'POST',
      '/v1/me/email-access/complete',
      { token, password: emailPassword },
      first.accessToken,
    ),
    204,
  );
  const email = data(
    await f.request('POST', '/v1/auth/email/login', {
      email: 'linked@yahoo.com',
      password: emailPassword,
    }),
  );
  assert.equal(email.account.id, first.account.id);
  assert.equal((await f.request('GET', '/v1/me', undefined, first.accessToken)).statusCode, 401);
});
test('EMAIL-04 expiry and erasure invalidate email links and erase names and credentials', async (t) => {
  const f = await setup(t);
  data(await f.request('POST', '/v1/auth/email/signup', emailRegistration));
  const token = await emailToken(f);
  await f.owner.query(
    "UPDATE app.email_auth_challenges SET created_at=clock_timestamp()-interval '31 minutes',expires_at=clock_timestamp()-interval '1 minute'",
  );
  assert.equal(
    (await f.request('POST', '/v1/auth/email/complete', { token, password: emailPassword }))
      .statusCode,
    400,
  );
  data(await f.request('POST', '/v1/auth/email/signup', emailRegistration));
  const newer = await emailToken(f);
  await f.owner.query('UPDATE app.users SET deleted_at=clock_timestamp()');
  assert.equal(
    (await f.request('POST', '/v1/auth/email/complete', { token: newer, password: emailPassword }))
      .statusCode,
    400,
  );
  const cr = (await f.owner.query('SELECT email,password_hash FROM app.email_credentials')).rows[0];
  assert.deepEqual(cr, { email: null, password_hash: null });
  const user = (await f.owner.query('SELECT first_name,last_name,other_names FROM app.users'))
    .rows[0];
  assert.deepEqual(user, { first_name: null, last_name: null, other_names: null });
});
test('EMAIL-05 change password checks current proof and recent sign-in, then revokes access', async (t) => {
  const f = await setup(t),
    session = await registeredEmail(f);
  assert.equal(
    (
      await f.request(
        'POST',
        '/v1/me/password',
        { currentPassword: 'wrong', password: 'a different long password' },
        session.accessToken,
      )
    ).statusCode,
    401,
  );
  data(
    await f.request(
      'POST',
      '/v1/me/password',
      { currentPassword: emailPassword, password: 'a different long password' },
      session.accessToken,
    ),
    204,
  );
  assert.equal((await f.request('GET', '/v1/me', undefined, session.accessToken)).statusCode, 401);
  const signed = data(
    await f.request('POST', '/v1/auth/email/login', {
      email: emailRegistration.email,
      password: 'a different long password',
    }),
  );
  await f.owner.query(
    "UPDATE app.auth_sessions SET created_at=created_at-interval '20 minutes' WHERE user_id=$1",
    [signed.account.id],
  );
  assert.equal(
    (
      await f.request(
        'POST',
        '/v1/me/password',
        { currentPassword: 'a different long password', password: emailPassword },
        signed.accessToken,
      )
    ).json().error.code,
    'recent_signin_required',
  );
});

test('EMAIL-06 tentative links cannot reserve a mailbox against its owner signing up', async (t) => {
  const f = await setup(t),
    attacker = await f.sign('pending-attacker');
  data(
    await f.request(
      'POST',
      '/v1/me/email-access/link',
      { email: emailRegistration.email },
      attacker.accessToken,
    ),
  );
  const pendingToken = await emailToken(f);
  const owner = await registeredEmail(f);
  assert.notEqual(owner.account.id, attacker.account.id);
  assert.equal(
    (
      await f.request(
        'POST',
        '/v1/me/email-access/complete',
        { token: pendingToken, password: emailPassword },
        attacker.accessToken,
      )
    ).statusCode,
    409,
  );
  assert.equal((await f.request('GET', '/v1/me', undefined, owner.accessToken)).statusCode, 200);
});

test('EMAIL-07 verified Google enrollment can proceed despite an unverified email claim', async (t) => {
  const email = 'owner@gmail.com';
  const f = await setup(t, 1000, {
    google: {
      verify: async (token) => ({
        provider: 'google',
        providerId: token,
        email: token === 'owner' ? email : 'attacker@example.com',
        displayName: 'Test rider',
      }),
    },
  });
  const attacker = data(await f.request('POST', '/v1/auth/google', { idToken: 'attacker' }));
  data(await f.request('POST', '/v1/me/email-access/link', { email }, attacker.accessToken));
  const pendingToken = await emailToken(f);
  data(await f.request('POST', '/v1/auth/email/signup', { ...emailRegistration, email }));
  const signupToken = await emailToken(f);
  const owner = data(await f.request('POST', '/v1/auth/google', { idToken: 'owner' }));
  assert.notEqual(owner.account.id, attacker.account.id);
  assert.equal(
    (
      await f.request(
        'POST',
        '/v1/me/email-access/complete',
        { token: pendingToken, password: emailPassword },
        attacker.accessToken,
      )
    ).statusCode,
    409,
  );
  assert.equal(
    (
      await f.request('POST', '/v1/auth/email/complete', {
        token: signupToken,
        password: emailPassword,
      })
    ).statusCode,
    409,
  );
});

test('EMAIL-09 reissued signup and same-address linking codes survive pending retention', async (t) => {
  const f = await setup(t),
    rider = await f.sign('resend-retention');
  const signup = () => f.request('POST', '/v1/auth/email/signup', emailRegistration);
  const link = () =>
    f.request(
      'POST',
      '/v1/me/email-access/link',
      { email: 'renewed-link@example.com' },
      rider.accessToken,
    );
  data(await signup());
  data(await link());
  await f.emailDelivered();
  await f.owner.query(
    "UPDATE app.email_credentials SET created_at=clock_timestamp()-interval '2 days'",
  );
  await f.owner.query(
    "UPDATE app.email_auth_challenges SET created_at=clock_timestamp()-interval '2 days',expires_at=clock_timestamp()-interval '1 day'",
  );
  data(await signup());
  const signupToken = await emailToken(f);
  data(await link());
  const linkToken = await emailToken(f);
  const ages = async () =>
    (await f.owner.query('SELECT user_id,created_at FROM app.email_credentials ORDER BY user_id'))
      .rows;
  const issued = await ages();
  data(await signup());
  data(await link());
  assert.deepEqual(await ages(), issued, 'suppressed resends must not prolong retention');
  assert.deepEqual(await purgeExpiredEmailAccess(f.runtime), { expired: 2, pending: 0 });
  data(
    await f.request('POST', '/v1/auth/email/complete', {
      token: signupToken,
      password: emailPassword,
    }),
    204,
  );
  data(
    await f.request(
      'POST',
      '/v1/me/email-access/complete',
      { token: linkToken, password: emailPassword },
      rider.accessToken,
    ),
    204,
  );
});

test('EMAIL-10 recent sign-in is checked at linking start, not shortened during the code lifetime', async (t) => {
  const f = await setup(t),
    rider = await f.sign('link-lifetime');
  const age = (minutes: number) =>
    f.owner.query(
      "UPDATE app.auth_sessions SET created_at=clock_timestamp()-($2::text||' minutes')::interval WHERE user_id=$1",
      [rider.account.id, minutes],
    );
  const request = () =>
    f.request(
      'POST',
      '/v1/me/email-access/link',
      { email: 'lifetime@example.com' },
      rider.accessToken,
    );
  await age(16);
  assert.equal((await request()).json().error.code, 'recent_signin_required');
  await age(14);
  data(await request());
  const token = await emailToken(f);
  const second = await f.sign('link-lifetime');
  assert.equal(
    (
      await f.request(
        'POST',
        '/v1/me/email-access/complete',
        { token, password: emailPassword },
        second.accessToken,
      )
    ).statusCode,
    400,
  );
  await age(16);
  data(
    await f.request(
      'POST',
      '/v1/me/email-access/complete',
      { token, password: emailPassword },
      rider.accessToken,
    ),
    204,
  );
});

test('EMAIL-08 retention removes abandoned signup PII without deleting a linked-method owner', async (t) => {
  const f = await setup(t),
    rider = await f.sign('pending-cleanup');
  data(
    await f.request(
      'POST',
      '/v1/me/email-access/link',
      { email: 'pending-link@example.com' },
      rider.accessToken,
    ),
  );
  await f.emailDelivered();
  data(await f.request('POST', '/v1/auth/email/signup', emailRegistration));
  await f.emailDelivered();
  await f.owner.query(
    "UPDATE app.email_credentials SET created_at=clock_timestamp()-interval '2 days'",
  );
  await f.owner.query(
    "UPDATE app.email_auth_challenges SET created_at=clock_timestamp()-interval '2 days',expires_at=clock_timestamp()-interval '1 day'",
  );
  const result = await purgeExpiredEmailAccess(f.runtime);
  assert.equal(result.pending, 2);
  assert.equal(result.expired, 2);
  assert.equal((await f.request('GET', '/v1/me', undefined, rider.accessToken)).statusCode, 200);
  const signup = (await f.owner.query('SELECT * FROM app.users WHERE id<>$1', [rider.account.id]))
    .rows[0];
  assert.ok(signup.deleted_at);
  assert.equal(signup.display_name, null);
  assert.equal(signup.first_name, null);
  assert.equal(
    (
      await f.owner.query(
        'SELECT count(*)::int AS n FROM app.email_credentials WHERE email IS NOT NULL',
      )
    ).rows[0].n,
    0,
  );
});
