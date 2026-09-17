import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHash, randomUUID } from 'node:crypto';
import { mkdtemp, writeFile, chmod, rm, symlink } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { readConfiguration, ConfigurationError } from '../src/runtime/config.js';
import { R2ObjectStore } from '../src/runtime/avatars.js';
import { jobFailed, jobLog } from '../src/runtime/job-outcome.js';
import {
  rehearsalEnvironment,
  localRehearsalAdmin,
  readPrivateEnvironment,
} from '../src/runtime/rehearsal.js';

const key = (n: number) => Buffer.alloc(32, n).toString('base64');
// Provider-shaped, but assembled at runtime so no credential-looking literal
// is committed. The repository's secret scan allowlist is deliberately narrow.
const providerKey = (mode: 'test' | 'live') =>
  ['sk', mode, randomUUID().replaceAll('-', '').slice(0, 18)].join('_');
const PEM = '-----BEGIN PRIVATE KEY-----\\nMHc=\\n-----END PRIVATE KEY-----';
const maintenanceUser = randomUUID();
test('private environment reads reject symlinks, public files, directories and oversized content', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'trotxi-env-descriptor-'));
  const file = join(dir, 'private.env');
  try {
    await writeFile(file, 'VALUE=private-fixture\n', { mode: 0o600 });
    assert.deepEqual(await readPrivateEnvironment(file), { VALUE: 'private-fixture' });
    await symlink(file, join(dir, 'link.env'));
    await assert.rejects(readPrivateEnvironment(join(dir, 'link.env')));
    await assert.rejects(readPrivateEnvironment(dir), /ordinary private env/);
    await assert.rejects(readPrivateEnvironment('relative.env'), /absolute/);
    await chmod(file, 0o644);
    await assert.rejects(readPrivateEnvironment(file), /chmod 600/);
    await chmod(file, 0o600);
    await writeFile(file, Buffer.alloc(1_048_577, 65));
    await assert.rejects(readPrivateEnvironment(file), /at most 1 MiB/);
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
});
test('local rehearsal never accepts a staging database or an existing application database', () => {
  assert.equal(localRehearsalAdmin('postgres://test:pw@127.0.0.1:55432/postgres').port, '55432');
  for (const url of [
    undefined,
    'postgres://test:pw@db.render.com/postgres',
    'postgres://test:pw@127.0.0.1/application',
    'postgres://test:pw@127.0.0.1/postgres?host=db.render.com',
    'https://127.0.0.1/postgres',
  ])
    assert.throws(() => localRehearsalAdmin(url));
  assert.throws(
    () => localRehearsalAdmin('invalid-url-containing-private-data'),
    (error: unknown) => error instanceof Error && !String(error.stack).includes('private-data'),
  );
});
test('provider rehearsal CLI validates private files and fails closed before network activity', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'trotxi-provider-env-test-'));
  const file = join(dir, 'private.env');
  const secret = providerKey('test');
  const write = (key: string) =>
    writeFile(
      file,
      `PAYSTACK_SECRET_KEY=${key}\nR2_ACCOUNT_ID=account\nR2_ACCESS_KEY_ID=access\nR2_SECRET_ACCESS_KEY=secret\nR2_BUCKET=bucket\n`,
      { mode: 0o600 },
    );
  const run = (args: string[]) =>
    spawnSync(process.execPath, ['--import', 'tsx', 'scripts/provider-rehearsal.ts', ...args], {
      cwd: fileURLToPath(new URL('..', import.meta.url)),
      env: { PATH: process.env.PATH },
      encoding: 'utf8',
      timeout: 10_000,
    });
  try {
    await write(secret);
    const args = ['--env-file', file, '--check', 'preflight'];
    const good = run(args);
    assert.equal(good.status, 0, good.stderr);
    assert.match(good.stdout, /No provider request or database connection/);
    assert.equal(good.stdout.includes(secret), false);
    await chmod(file, 0o644);
    const publicFile = run(args);
    assert.equal(publicFile.status, 1);
    assert.match(publicFile.stderr, /chmod 600/);
    await chmod(file, 0o600);
    const live = providerKey('live');
    await write(live);
    const refused = run(['--env-file', file, '--check', 'paystack']);
    assert.equal(refused.status, 1);
    assert.match(refused.stderr, /TEST/);
    assert.equal((refused.stdout + refused.stderr).includes(live), false);
    assert.equal(run(['--env-file', file, '--chek', 'paystack']).status, 2);
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
});
test('provider rehearsal refuses live keys and never passes database or unrelated secrets', () => {
  const secret = providerKey('test');
  const source = {
    PAYSTACK_SECRET_KEY: secret,
    DATABASE_URL: 'must-not-be-used',
    JWT_SECRET: 'must-not-be-used',
    RENDER_API_KEY: 'must-not-be-used',
    REPLACEMENT_ALLOW_LIVE_PAYMENTS: 'yes',
    R2_ACCOUNT_ID: 'account',
    R2_ACCESS_KEY_ID: 'access',
    R2_SECRET_ACCESS_KEY: 'secret',
    R2_BUCKET: 'bucket',
  };
  assert.deepEqual(rehearsalEnvironment(source, 'paystack'), {
    REPLACEMENT_PAYSTACK_SECRET_KEY: secret,
  });
  assert.deepEqual(rehearsalEnvironment(source, 'r2'), {
    R2_ACCOUNT_ID: 'account',
    R2_ACCESS_KEY_ID: 'access',
    R2_SECRET_ACCESS_KEY: 'secret',
    R2_BUCKET: 'bucket',
  });
  for (const check of ['paystack', 'r2'] as const) {
    assert.throws(
      () => rehearsalEnvironment({ ...source, PAYSTACK_SECRET_KEY: providerKey('live') }, check),
      /TEST/,
    );
    assert.throws(
      () =>
        rehearsalEnvironment(
          { ...source, REPLACEMENT_PAYSTACK_SECRET_KEY: providerKey('test') },
          check,
        ),
      /Conflicting/,
    );
  }
  assert.throws(
    () => rehearsalEnvironment({ ...source, PAYSTACK_SECRET_KEY: secret + '\n' }, 'paystack'),
    /invalid/,
  );
});
test('maintenance exit policy detects 200 partial failures and contract drift, not business blocks', () => {
  const clean = { considered: 0, succeeded: 0, blocked: 0, failed: 0, failures: [] };
  assert.equal(
    jobFailed({
      job: 'payments',
      status: 200,
      body: {
        data: {
          inbox: clean,
          reconciliation: clean,
          periods: { ...clean, considered: 1, blocked: 1 },
        },
      },
    }),
    false,
  );
  assert.equal(
    jobFailed({
      job: 'payments',
      status: 200,
      body: {
        data: {
          inbox: clean,
          reconciliation: clean,
          periods: {
            ...clean,
            considered: 1,
            failed: 1,
            failures: [{ resourceId: 'period', reason: 'unexpected_error' }],
          },
        },
      },
    }),
    true,
  );
  assert.equal(
    jobFailed({ job: 'erasures', status: 200, body: { considered: 1, completed: 0, failed: 1 } }),
    true,
  );
  assert.throws(
    () => jobFailed({ job: 'gps-retention', status: 200, body: { data: { succeeded: 1 } } }),
    /contract_drift/,
  );
  assert.equal(jobFailed({ job: 'admission', status: 503, body: {} }), true);
  const result = {
    job: 'gps-retention' as const,
    status: 200,
    body: { data: clean },
    retention: {
      expiredFixes: 1,
      heldFixes: 0,
      deletableFixes: 1,
      oldestDeletableAt: null,
      overdueSeconds: 3601,
      batches: 1,
      elapsedMs: 1,
      budgetExhausted: true,
    },
  };
  assert.equal(jobFailed(result), true);
  const logged = JSON.parse(
    jobLog({
      job: 'route-learning',
      status: 200,
      body: {
        data: {
          ...clean,
          failures: Array.from({ length: 100 }, () => ({ resourceId: 'x', reason: 'failure' })),
        },
      },
    }),
  );
  assert.equal(logged.body.data.failures.length, 10);
});
/** One complete, valid deployment. Every scenario starts from this. */
function environment(): Record<string, string> {
  return {
    REPLACEMENT_RUNTIME_DATABASE_URL: 'postgres://runtime:pw@db.internal:5432/trotxi',
    REPLACEMENT_POOL_SIZE: '8',
    PORT: '10000',
    REPLACEMENT_SERVICE_NAME: 'trotxi-api-next',
    REPLACEMENT_SERVICE_VERSION: '0.1.0',
    REPLACEMENT_GIT_COMMIT: 'e2b1c0ddeadbeef',
    REPLACEMENT_ACCESS_ISSUER: 'https://api.trotxi.com',
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
    REPLACEMENT_GOOGLE_CLIENT_ID: '431341307838-example.apps.googleusercontent.com',
    REPLACEMENT_AUTH_PROVIDERS: 'google,apple',
    REPLACEMENT_APPLE_CLIENT_ID: 'com.trotxi.trotxiCommuter,com.trotxi.web',
    REPLACEMENT_APPLE_TEAM_ID: 'TEAMID1234',
    REPLACEMENT_APPLE_KEY_ID: 'KEYID12345',
    REPLACEMENT_APPLE_PRIVATE_KEY: PEM,
    REPLACEMENT_PAYSTACK_SECRET_KEY: providerKey('test'),
    REPLACEMENT_R2_ACCOUNT_ID: 'ff00ff00ff00ff00ff00ff00ff00ff00',
    REPLACEMENT_R2_ACCESS_KEY_ID: 'AKIAEXAMPLE',
    REPLACEMENT_R2_SECRET_ACCESS_KEY: 'secret-access-key',
    REPLACEMENT_R2_BUCKET_NAME: 'trotxi-avatars',
    REPLACEMENT_AVATAR_URL_TTL_SECONDS: '300',
    REPLACEMENT_AVATAR_MAX_BYTES: '2097152',
    REPLACEMENT_MAP_TILES_URL: 'https://tiles.trotxi.com/ghana.pmtiles',
    REPLACEMENT_MAP_STYLE_URL: 'https://tiles.trotxi.com/style.light.json',
    REPLACEMENT_MAP_STYLE_DARK_URL: 'https://tiles.trotxi.com/style.dark.json',
    REPLACEMENT_MAP_ATTRIBUTION: 'Trotxi basemap',
    REPLACEMENT_DOCS_URL: 'https://docs.trotxi.com',
    REPLACEMENT_MINIMUM_BUILD_OPS: '1',
    REPLACEMENT_MINIMUM_BUILD_DRIVER_IOS: '2',
    REPLACEMENT_MINIMUM_BUILD_DRIVER_ANDROID: '2',
    REPLACEMENT_MINIMUM_BUILD_COMMUTER_IOS: '3',
    REPLACEMENT_MINIMUM_BUILD_COMMUTER_ANDROID: '3',
    REPLACEMENT_REQUESTS_PER_MINUTE: '120',
    REPLACEMENT_REQUESTS_PER_IP_PER_MINUTE: '600',
    REPLACEMENT_AUTH_REQUESTS_PER_MINUTE: '10',
    REPLACEMENT_TRUST_PROXY: 'loopback, linklocal, uniquelocal',
    REPLACEMENT_MAINTENANCE_USER_ID: maintenanceUser,
  };
}
function refuses(env: Record<string, string | undefined>, fragment: string) {
  assert.throws(
    () => readConfiguration(env),
    (error: unknown) =>
      error instanceof ConfigurationError && error.message.includes(fragment)
        ? true
        : assert.fail(`Expected a refusal naming ${fragment}, got ${String(error)}`),
  );
}

/**
 * What a deployment genuinely owns, and nothing else.
 *
 * Its database, its secrets, its bucket. Everything else has a working answer
 * already, because a timeout or a basemap URL is the same everywhere until
 * somebody decides otherwise. Turning those into requirements does not make a
 * deployment safer, it just gives one missing secret thirty more ways to look
 * like a different problem.
 */
const MUST_BE_STATED = [
  'REPLACEMENT_RUNTIME_DATABASE_URL',
  'REPLACEMENT_ACCESS_SECRET',
  'REPLACEMENT_CURSOR_SECRET',
  'REPLACEMENT_PIN_SECRET',
  'REPLACEMENT_CREDENTIAL_REPLAY_KEY',
  'REPLACEMENT_PROVIDER_ENCRYPTION_KEY',
  'REPLACEMENT_BOARDING_PROOF_KEY',
  'REPLACEMENT_DEVICE_KEY',
  'REPLACEMENT_PAYSTACK_EVIDENCE_KEY',
  'REPLACEMENT_PAYSTACK_SECRET_KEY',
  'REPLACEMENT_R2_ACCOUNT_ID',
  'REPLACEMENT_R2_ACCESS_KEY_ID',
  'REPLACEMENT_R2_SECRET_ACCESS_KEY',
  'REPLACEMENT_R2_BUCKET_NAME',
];

test('ASM-01 a deployment states its secrets, and nothing it does not own', () => {
  // Dropping one of these is still refused by name, so a real gap says what to
  // set rather than starting half-wired.
  for (const name of MUST_BE_STATED) {
    const env = environment();
    delete env[name];
    refuses(env, name);
  }
  // And dropping anything else still starts, on a default that works.
  const bare: Record<string, string> = {};
  for (const name of MUST_BE_STATED) bare[name] = environment()[name]!;
  const config = readConfiguration(bare);
  assert.equal(config.build.service, 'trotxi-api');
  assert.equal(config.listen.port, 10000);
  assert.deepEqual(config.providers, ['google']);
  assert.equal(config.access.ttlSeconds, 900);
  assert.equal(config.limits.perUser, 120);
  assert.equal(config.trustProxy, 'loopback, linklocal, uniquelocal');
  assert.match(config.mapTiles.url ?? '', /^https:\/\//);
  // The worker's operator account is the worker's requirement, not the
  // listener's: an API that will not serve riders because a scheduled job has
  // no operator is refusing the wrong thing.
  assert.equal(config.maintenanceUserId, '');
});

test('Render reports the deployed revision rather than a stale environment value', () => {
  const env = environment();
  env.RENDER_GIT_COMMIT = 'a'.repeat(40);
  assert.equal(readConfiguration(env).build.commit, env.RENDER_GIT_COMMIT);
  delete env.REPLACEMENT_GIT_COMMIT;
  assert.equal(readConfiguration(env).build.commit, env.RENDER_GIT_COMMIT);
  delete env.RENDER_GIT_COMMIT;
  // With neither, the build says it does not know rather than refusing to
  // start. A wrong commit on /version would be worse than an honest one.
  assert.equal(readConfiguration(env).build.commit, 'unknown');
});

test('ASM-02 no two purposes may share one key', () => {
  for (const [a, b] of [
    ['REPLACEMENT_ACCESS_SECRET', 'REPLACEMENT_DEVICE_KEY'],
    ['REPLACEMENT_CURSOR_SECRET', 'REPLACEMENT_BOARDING_PROOF_KEY'],
    ['REPLACEMENT_PIN_SECRET', 'REPLACEMENT_CREDENTIAL_REPLAY_KEY'],
    ['REPLACEMENT_PROVIDER_ENCRYPTION_KEY', 'REPLACEMENT_PAYSTACK_EVIDENCE_KEY'],
  ]) {
    const env = environment();
    env[b!] = env[a!]!;
    assert.throws(() => readConfiguration(env), ConfigurationError);
  }
  // Hex and base64 spellings of the same bytes are the same key.
  const env = environment();
  env.REPLACEMENT_DEVICE_KEY = Buffer.alloc(32, 1).toString('hex');
  refuses(env, 'must differ');
  const short = environment();
  short.REPLACEMENT_DEVICE_KEY = Buffer.alloc(16, 9).toString('base64');
  refuses(short, '32 bytes');
});

test('ASM-03 live money and a shared owner connection are refused', () => {
  const live = environment();
  live.REPLACEMENT_PAYSTACK_SECRET_KEY = providerKey('live');
  refuses(live, 'TEST key');
  live.REPLACEMENT_ALLOW_LIVE_PAYMENTS = 'yes';
  refuses(live, 'TEST key');
  live.REPLACEMENT_DEPLOYMENT_ENVIRONMENT = 'staging';
  refuses(live, 'TEST key');
  live.REPLACEMENT_DEPLOYMENT_ENVIRONMENT = 'production';
  delete live.REPLACEMENT_ALLOW_LIVE_PAYMENTS;
  refuses(live, 'REPLACEMENT_ALLOW_LIVE_PAYMENTS');
  live.REPLACEMENT_ALLOW_LIVE_PAYMENTS = 'yes';
  assert.equal(readConfiguration(live).paystack.secretKey.startsWith('sk_live_'), true);
  const invalidEnvironment = environment();
  invalidEnvironment.REPLACEMENT_DEPLOYMENT_ENVIRONMENT = 'stagng';
  refuses(invalidEnvironment, 'REPLACEMENT_DEPLOYMENT_ENVIRONMENT');
  const wrong = environment();
  wrong.REPLACEMENT_PAYSTACK_SECRET_KEY = ['pk', 'test', '0123456789abcdef'].join('_');
  refuses(wrong, 'Paystack secret key');
  // The service must not run as the role that installs and owns the schema.
  const owner = environment();
  owner.REPLACEMENT_DATABASE_URL = owner.REPLACEMENT_RUNTIME_DATABASE_URL!;
  refuses(owner, 'not the migration owner');
});

test('ASM-04 public URLs must be absolute https, and identity must be real', () => {
  for (const name of [
    'REPLACEMENT_MAP_TILES_URL',
    'REPLACEMENT_MAP_STYLE_URL',
    'REPLACEMENT_MAP_STYLE_DARK_URL',
    'REPLACEMENT_DOCS_URL',
  ]) {
    const plain = environment();
    plain[name] = 'http://tiles.trotxi.com/ghana.pmtiles';
    refuses(plain, 'https');
    const relative = environment();
    relative[name] = '/ghana.pmtiles';
    refuses(relative, 'absolute URL');
  }
  const pem = environment();
  pem.REPLACEMENT_APPLE_PRIVATE_KEY = 'not-a-key';
  refuses(pem, 'PKCS#8');
  const audience = environment();
  audience.REPLACEMENT_APPLE_CLIENT_ID = ' , ';
  refuses(audience, 'REPLACEMENT_APPLE_CLIENT_ID');
  const operator = environment();
  operator.REPLACEMENT_MAINTENANCE_USER_ID = 'ops';
  refuses(operator, 'must be a user id');
  // Support contacts are the one thing that may genuinely be unknown, and an
  // invented number is worse than none.
  const quiet = environment();
  assert.deepEqual(readConfiguration(quiet).support, {
    phone: null,
    whatsapp: null,
    email: null,
    hours: null,
  });
});

test('ASM-04b a provider is offered completely or not at all', () => {
  // There is no Apple Developer account yet. Requiring one made the service
  // refuse to start; treating one as optional would have made it answer 503
  // the moment a rider tapped the button. It is a deployment statement
  // instead: what is offered must be complete, and what is not offered has no
  // route to be disappointed by.
  const offered = readConfiguration(environment());
  assert.deepEqual(offered.providers, ['google', 'apple']);
  assert.equal(offered.apple?.teamId, 'TEAMID1234');
  const googleOnly = environment();
  googleOnly.REPLACEMENT_AUTH_PROVIDERS = 'google';
  for (const name of [
    'REPLACEMENT_APPLE_CLIENT_ID',
    'REPLACEMENT_APPLE_TEAM_ID',
    'REPLACEMENT_APPLE_KEY_ID',
    'REPLACEMENT_APPLE_PRIVATE_KEY',
  ])
    delete googleOnly[name];
  const without = readConfiguration(googleOnly);
  assert.deepEqual(without.providers, ['google']);
  assert.equal(without.apple, null);
  // Claiming a provider and not configuring it is still a refusal, by name.
  for (const name of [
    'REPLACEMENT_APPLE_CLIENT_ID',
    'REPLACEMENT_APPLE_TEAM_ID',
    'REPLACEMENT_APPLE_KEY_ID',
    'REPLACEMENT_APPLE_PRIVATE_KEY',
  ]) {
    const claimed = environment();
    delete claimed[name];
    refuses(claimed, name);
  }
  // Riders need a door. Driver sign-in is a PIN and is not one.
  const none = environment();
  none.REPLACEMENT_AUTH_PROVIDERS = 'apple';
  refuses(none, 'must include google');
  const unknown = environment();
  unknown.REPLACEMENT_AUTH_PROVIDERS = 'google,facebook';
  refuses(unknown, 'may list google and apple');
});

test('ASM-05 the proxy boundary is stated, and a hop count is not a statement', () => {
  // Every per-IP limit buckets on the address the server sees. Behind a load
  // balancer that is the balancer, so one caller can rate-limit everyone and
  // per-IP admission stops being a control. Nobody can guess this, so the
  // deployment has to say it.
  assert.equal(readConfiguration(environment()).trustProxy, 'loopback, linklocal, uniquelocal');
  const none = environment();
  none.REPLACEMENT_TRUST_PROXY = 'none';
  assert.equal(readConfiguration(none).trustProxy, false);
  // Fastify ignores a numeric value and trusts nobody, so a hop count would
  // silently switch the whole thing off rather than configure it.
  for (const bad of ['1', '2']) {
    const env = environment();
    env.REPLACEMENT_TRUST_PROXY = bad;
    refuses(env, 'not a hop count');
  }
  const junk = environment();
  junk.REPLACEMENT_TRUST_PROXY = 'loopback; drop table users';
  refuses(junk, 'address list');
});

test('ASM-05b a validator must not rewrite the value it approves', () => {
  // A tile template is the value most likely to arrive here, and percent-
  // encoding its braces would hand clients a URL that fetches nothing while
  // the deploy reported success.
  const env = environment();
  env.REPLACEMENT_MAP_TILES_URL = 'https://tiles.trotxi.com/{z}/{x}/{y}.png';
  assert.equal(readConfiguration(env).mapTiles.url, 'https://tiles.trotxi.com/{z}/{x}/{y}.png');
  const bare = environment();
  bare.REPLACEMENT_DOCS_URL = 'https://docs.trotxi.com';
  assert.equal(readConfiguration(bare).docsUrl, 'https://docs.trotxi.com');
});

const store = (over: Partial<ConstructorParameters<typeof R2ObjectStore>[0]> = {}) =>
  new R2ObjectStore({
    accountId: 'ff00ff00ff00ff00ff00ff00ff00ff00',
    accessKeyId: 'AKIAEXAMPLE',
    secretAccessKey: 'secret-access-key',
    bucket: 'trotxi-avatars',
    now: () => new Date('2026-09-15T08:00:00Z'),
    ...over,
  });

// Signatures for one fixed request, computed with @smithy/signature-v4 5.7.3
// against the same clock, credentials, bucket and object. A signature this
// implementation merely computes consistently is worth nothing: a canonical
// request that is wrong in a stable way still 403s every upload and every read.
const FIXED = {
  objectKey:
    'avatars/11111111-2222-4333-8444-555555555555/66666666-7777-4888-8999-aaaaaaaaaaaa.jpg',
  bytes: Buffer.from('ffd8ffe000104a464946', 'hex'),
  presign: '9a2f8769cc640204ab26d84b38df2c2b9424ac6aa293a013016433667424e797',
  delete: 'c41d931213a152b9c15c1d1f4c2ae4bbce31078a9697ab4a9ec188f3f648ebad',
};

test('ASM-06 an avatar URL is signed locally and only for keys this store made', async () => {
  const s = store();
  assert.equal(
    new URL(s.sign(FIXED.objectKey, 300)!).searchParams.get('X-Amz-Signature'),
    FIXED.presign,
    'the presigned GET signature does not match an independent SigV4 implementation',
  );
  const objectKey = `avatars/${randomUUID()}/${randomUUID()}.jpg`;
  const url = s.sign(objectKey, 300)!;
  const parsed = new URL(url);
  assert.equal(parsed.host, 'ff00ff00ff00ff00ff00ff00ff00ff00.r2.cloudflarestorage.com');
  assert.equal(parsed.pathname, `/trotxi-avatars/${objectKey}`);
  assert.equal(parsed.searchParams.get('X-Amz-Expires'), '300');
  assert.equal(parsed.searchParams.get('X-Amz-Date'), '20260915T080000Z');
  assert.equal(
    parsed.searchParams.get('X-Amz-Credential'),
    'AKIAEXAMPLE/20260915/auto/s3/aws4_request',
  );
  assert.match(parsed.searchParams.get('X-Amz-Signature')!, /^[a-f0-9]{64}$/);
  // The same request signs the same way, and any change to what is being
  // authorized changes the signature.
  assert.equal(s.sign(objectKey, 300), url);
  assert.notEqual(s.sign(objectKey, 301), url);
  assert.notEqual(store({ secretAccessKey: 'other' }).sign(objectKey, 300), url);
  assert.notEqual(s.sign(`avatars/${randomUUID()}/${randomUUID()}.jpg`, 300), url);
  // A stored key that is not one of ours addresses nothing and signs nothing.
  for (const bad of [
    '../secrets/id_rsa',
    'avatars/../../etc/passwd',
    `avatars/${randomUUID()}/${randomUUID()}.exe`,
    `AVATARS/${randomUUID()}/${randomUUID()}.jpg`,
  ]) {
    assert.equal(s.sign(bad, 300), null);
    assert.equal(await s.signedUrl(bad, 300), null);
    await assert.rejects(() => s.remove(bad), /avatar_key_unrecognised/);
  }
  assert.equal(s.sign(objectKey, 0), null);
  assert.equal(s.sign(objectKey, 604801), null);
});

test('ASM-07 storing an avatar is signed, verified and never assumed', async () => {
  const seen: { url: string; init: RequestInit }[] = [];

  const responder = (status: number) => async (url: unknown, init: unknown) => {
    seen.push({ url: String(url), init: init as RequestInit });
    return new Response(null, { status });
  };
  const bytes = Buffer.from('ffd8ffe000104a464946', 'hex');
  const userId = randomUUID();
  const { objectKey } = await store({ request: responder(200) as typeof fetch }).put({
    userId,
    bytes,
    contentType: 'image/jpeg',
  });
  assert.match(objectKey, new RegExp(`^avatars/${userId}/[0-9a-f-]{36}\\.jpg$`));
  const [call] = seen;
  assert.equal(call!.init.method, 'PUT');
  const headers = call!.init.headers as Record<string, string>;
  assert.equal(headers['content-type'], 'image/jpeg');
  // The signature covers the bytes, not just the request line.
  assert.equal(headers['x-amz-content-sha256'], createHash('sha256').update(bytes).digest('hex'));
  assert.match(
    headers.authorization!,
    /^AWS4-HMAC-SHA256 Credential=AKIAEXAMPLE\/20260915\/auto\/s3\/aws4_request, SignedHeaders=content-type;host;x-amz-content-sha256;x-amz-date, Signature=[a-f0-9]{64}$/,
  );
  // A store that refused the bytes has not stored them, so the account must
  // not be left pointing at an object that is not there.
  await assert.rejects(
    () =>
      store({ request: responder(403) as typeof fetch }).put({
        userId,
        bytes,
        contentType: 'image/jpeg',
      }),
    /avatar_store_rejected_403/,
  );
  await assert.rejects(
    () => store().put({ userId, bytes, contentType: 'image/gif' }),
    /Unsupported avatar media type/,
  );
});

test('ASM-08 removing an object reports a refusal, and an absent one is done', async () => {
  // Header-signed requests go through the same canonical construction as the
  // upload, so this vector covers that path too. The upload's own key is minted
  // per call, which is why it is checked by shape rather than by value.
  const authorizations: string[] = [];
  await store({
    request: (async (_url: unknown, init: unknown) => {
      authorizations.push((init as { headers: Record<string, string> }).headers.authorization!);
      return new Response(null, { status: 204 });
    }) as typeof fetch,
  }).remove(FIXED.objectKey);
  assert.equal(
    /Signature=([a-f0-9]{64})$/.exec(authorizations[0]!)?.[1],
    FIXED.delete,
    'the DELETE signature does not match an independent SigV4 implementation',
  );
  const objectKey = `avatars/${randomUUID()}/${randomUUID()}.png`;
  const answer = (status: number) =>
    store({ request: (async () => new Response(null, { status })) as typeof fetch });
  await answer(204).remove(objectKey);
  await answer(404).remove(objectKey);
  await assert.rejects(() => answer(500).remove(objectKey), /avatar_delete_rejected_500/);
});
