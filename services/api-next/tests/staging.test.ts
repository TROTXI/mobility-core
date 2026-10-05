import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import type { Pool } from 'pg';
import { readConfiguration } from '../src/runtime/config.js';
import { assertRuntimeRole } from '../src/runtime/compose.js';
import { STAGING_SERVICE_ID } from '../src/runtime/staging-profile.js';
import { spawnSync } from 'node:child_process';
import { access, readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { jwtVerify } from 'jose';
import { stagingDatabase } from '../src/runtime/staging-database.js';
import { stagingInstallerConfiguration } from '../scripts/migrate-staging.js';
import { failureLine, MaintenanceFailure } from '../scripts/maintenance-safety.js';
import {
  maintainStagingPayments,
  paymentMaintenanceConfiguration,
  runStagingJobs,
} from '../scripts/maintain-staging-payments.js';
import { GROUPS, scheduledJobs } from '../scripts/maintain-staging.js';

const settings = () => ({
  RENDER_SERVICE_ID: STAGING_SERVICE_ID,
  RENDER_SERVICE_NAME: 'trotxi-api-staging',
  RENDER_GIT_COMMIT: 'a'.repeat(40),
  REPLACEMENT_RUNTIME_DATABASE_URL:
    'postgres://trotxi_runtime_api:fixture@dpg-d8sugvv7f7vs73bifff0-a.frankfurt-postgres.render.com/trotxi',
  JWT_SECRET: 'fixture-root-secret-32-bytes-long-only-for-tests',
  PAYSTACK_SECRET_KEY: ['sk', 'test', randomUUID().replaceAll('-', '')].join('_'),
  GOOGLE_CLIENT_ID: 'fixture.apps.googleusercontent.com',
  R2_ACCOUNT_ID: 'account',
  R2_ACCESS_KEY_ID: 'access',
  R2_SECRET_ACCESS_KEY: 'fixture',
  R2_BUCKET: 'avatars',
  MAP_TILES_URL: 'https://tiles.example/map.pmtiles',
  MAP_STYLE_URL: 'https://tiles.example/light.json',
  MAP_STYLE_DARK_URL: 'https://tiles.example/dark.json',
  TRUST_PROXY: 'loopback, linklocal, uniquelocal',
});

test('the retired seed is absent and payment maintenance keeps a standalone entry point', async () => {
  for (const path of ['../scripts/seed-staging.ts', '../../../.github/workflows/seed-staging.yml'])
    await assert.rejects(access(new URL(path, import.meta.url)), { code: 'ENOENT' });
  const workflow = await readFile(
    new URL('../../../.github/workflows/payments-maintenance.yml', import.meta.url),
    'utf8',
  );
  assert.match(workflow, /run: node --import tsx scripts\/maintain-staging-payments.ts/);
  assert.doesNotMatch(workflow, /scripts\/seed-staging\.ts|SEED_MAINTENANCE|SEED_STAGING_URL/);
});

test('payment maintenance only accepts the staging target and a derived access key', () => {
  const env = {
    REPLACEMENT_RUNTIME_DATABASE_URL:
      'postgres://trotxi_runtime_worker:fixture@dpg-d8sugvv7f7vs73bifff0-a.frankfurt-postgres.render.com/trotxi',
    REPLACEMENT_ACCESS_SECRET: Buffer.alloc(32, 2).toString('base64'),
    REPLACEMENT_MAINTENANCE_USER_ID: randomUUID(),
  };
  const config = paymentMaintenanceConfiguration(env);
  assert.equal(new URL(config.connectionString).search, '');
  assert.equal(config.ssl.rejectUnauthorized, true);
  assert.deepEqual(config.key, Buffer.alloc(32, 2));
  for (const database of [
    env.REPLACEMENT_RUNTIME_DATABASE_URL.replace('/trotxi', '/production'),
    env.REPLACEMENT_RUNTIME_DATABASE_URL.replace('trotxi_runtime_worker:fixture', 'trotxi:fixture'),
    env.REPLACEMENT_RUNTIME_DATABASE_URL.replace(
      'dpg-d8sugvv7f7vs73bifff0-a.frankfurt-postgres.render.com',
      'other.example',
    ),
    env.REPLACEMENT_RUNTIME_DATABASE_URL + '?host=other.example',
    env.REPLACEMENT_RUNTIME_DATABASE_URL + '?sslmode=no-verify',
    env.REPLACEMENT_RUNTIME_DATABASE_URL + '?sslrootcert=/tmp/hostile.crt',
  ])
    assert.throws(() =>
      paymentMaintenanceConfiguration({ ...env, REPLACEMENT_RUNTIME_DATABASE_URL: database }),
    );
  assert.throws(() => paymentMaintenanceConfiguration({ ...env, REPLACEMENT_ACCESS_SECRET: '' }));
  const run = spawnSync(
    process.execPath,
    ['--import', 'tsx', 'scripts/maintain-staging-payments.ts'],
    {
      cwd: fileURLToPath(new URL('../', import.meta.url)),
      env: { PATH: process.env.PATH, REPLACEMENT_DATABASE_URL: 'private-malformed-url' },
      encoding: 'utf8',
      timeout: 10_000,
    },
  );
  assert.equal(run.status, 1);
  assert.match(run.stderr, /"category":"configuration"/);
  assert.doesNotMatch(run.stderr + run.stdout, /private-malformed-url/);
});

test('payment maintenance calls both jobs, logs counts only, and revokes on every failure', async () => {
  const key = Buffer.alloc(32, 3);
  const success = { data: { considered: 1, succeeded: 1, blocked: 0, failed: 0, failures: [] } };
  for (const mode of ['success', 'partial', 'http', 'malformed', 'network'] as const) {
    let revoked = false;
    const jobs: string[] = [];
    const logs: string[] = [];
    const ids = new Set<string>();
    const pool = {
      query: async (sql: string, values?: unknown[]) => {
        if (sql.startsWith('UPDATE')) {
          assert.deepEqual(values, ['session']);
          revoked = true;
        }
        return { rows: [{ id: 'session', user_id: 'operator' }] };
      },
    } as unknown as Pool;
    const request: typeof fetch = async (input, init) => {
      jobs.push(String(input));
      assert.equal(init?.redirect, 'error');
      assert.equal(init?.method, 'POST');
      assert.deepEqual(JSON.parse(init?.body as string), { limit: 100 });
      const headers = new Headers(init?.headers);
      assert.equal(headers.get('x-trotxi-client'), 'worker');
      ids.add(headers.get('idempotency-key')!);
      const verified = await jwtVerify(headers.get('authorization')!.slice(7), key, {
        algorithms: ['HS256'],
        issuer: 'trotxi-api',
        audience: 'trotxi-clients',
      });
      assert.equal(verified.payload.sid, 'session');
      assert.equal(verified.payload.sub, 'operator');
      if (mode === 'network') throw new Error('private-provider-error');
      const body =
        mode === 'partial'
          ? {
              data: {
                ...success.data,
                failed: 1,
                failures: [{ resourceId: 'private-id', reason: 'private-reason' }],
              },
            }
          : mode === 'malformed' || mode === 'http'
            ? { error: 'private-error' }
            : success;
      return Response.json(body, { status: mode === 'http' ? 503 : 200 });
    };
    const run = maintainStagingPayments(pool, key, 'operator', request, (line) => logs.push(line));
    if (mode === 'success') await run;
    else await assert.rejects(run);
    assert.equal(revoked, true);
    assert.deepEqual(jobs, [
      'https://trotxi-api-staging.onrender.com/v1/ops/maintenance/payment-inbox',
      ...(mode === 'network'
        ? []
        : ['https://trotxi-api-staging.onrender.com/v1/ops/maintenance/payment-reconciliation']),
    ]);
    assert.equal(ids.size, jobs.length);
    assert.doesNotMatch(logs.join('\n'), /private-|Bearer|operator|session/);
    if (mode === 'success') assert.equal(JSON.parse(logs[0]!).succeeded, 1);
  }
});

test('staging uses a restricted database and preserves existing provider keys', () => {
  const env = settings();
  const before = { ...env };
  const config = readConfiguration(env);
  assert.deepEqual(env, before);
  assert.equal(config.existingStaging, true);
  assert.equal(config.databaseUrl, env.REPLACEMENT_RUNTIME_DATABASE_URL);
  assert.equal(config.databaseSsl?.rejectUnauthorized, true);
  assert.equal(config.paystack.secretKey, env.PAYSTACK_SECRET_KEY);
  assert.equal(config.avatars.secretAccessKey, env.R2_SECRET_ACCESS_KEY);
  assert.equal(config.google.clientId, env.GOOGLE_CLIENT_ID);
  assert.equal(config.mapTiles.styleUrl, env.MAP_STYLE_URL);
  assert.equal(config.build.commit, env.RENDER_GIT_COMMIT);
  assert.deepEqual(config.providers, ['google']);
  assert.equal(config.opsOrigin, 'https://trotxi-ops-staging.onrender.com');
  assert.equal(config.maintenanceUserId, '');
  assert.equal(new Set(Object.values(config.keys).map((k) => k.toString('hex'))).size, 8);
  assert.deepEqual(readConfiguration(env).keys, config.keys);
  assert.notDeepEqual(
    readConfiguration({ ...env, JWT_SECRET: env.JWT_SECRET + 'changed' }).keys,
    config.keys,
  );
});

test('WebAuthn origin is independent of CORS origin order', () => {
  const env = {
    ...settings(),
    CORS_ORIGINS: 'http://localhost:5173,https://trotxi-ops-staging.onrender.com',
  };
  assert.equal(readConfiguration(env).opsOrigin, 'https://trotxi-ops-staging.onrender.com');
  assert.equal(
    readConfiguration({ ...env, OPS_ORIGIN: 'https://ops.example.com' }).opsOrigin,
    'https://ops.example.com',
  );
});

test('staging config rejects live keys, foreign targets, weak roots and mixed key sets', () => {
  for (const change of [
    { RENDER_SERVICE_NAME: 'production' },
    { RENDER_SERVICE_ID: 'another-service' },
    { REPLACEMENT_DEPLOYMENT_ENVIRONMENT: 'production' },
    { PAYSTACK_SECRET_KEY: ['sk', 'live', randomUUID().replaceAll('-', '')].join('_') },
    { JWT_SECRET: 'short' },
    { DATABASE_URL: 'private-invalid-value' },
    { DATABASE_URL: 'postgres://trotxi:fixture@other-host/trotxi' },
    {
      REPLACEMENT_RUNTIME_DATABASE_URL:
        settings().REPLACEMENT_RUNTIME_DATABASE_URL + '?host=other-host',
    },
    {
      REPLACEMENT_RUNTIME_DATABASE_URL: settings().REPLACEMENT_RUNTIME_DATABASE_URL.replace(
        '/trotxi',
        '/other',
      ),
    },
    { REPLACEMENT_ACCESS_SECRET: Buffer.alloc(32, 1).toString('base64') },
  ])
    assert.throws(() => readConfiguration({ ...settings(), ...change }));
});

test('the staging owner no longer bypasses runtime privilege checks', async () => {
  const row = {
    installed: true,
    create_schema: true,
    rewrite_history: true,
    database: 'trotxi',
    login: 'trotxi',
  };
  const pool = (changes = {}) =>
    ({ query: async () => ({ rows: [{ ...row, ...changes }] }) }) as unknown as Pool;
  await assert.rejects(assertRuntimeRole(pool()), /can create objects/);
  await assert.rejects(assertRuntimeRole(pool({ installed: false })), /not installed/);
  await assertRuntimeRole(pool({ create_schema: false, rewrite_history: false }));
});

test('TLS options cannot disable verification or override the pinned server', () => {
  const url = settings().REPLACEMENT_RUNTIME_DATABASE_URL;
  const ca = '-----BEGIN CERTIFICATE-----\nfixture\n-----END CERTIFICATE-----';
  const verified = stagingDatabase(url + '?sslmode=verify-full', ca);
  assert.deepEqual(verified.ssl, { rejectUnauthorized: true, ca });
  assert.equal(new URL(verified.connectionString).search, '');
  for (const suffix of [
    '?sslmode=require',
    '?ssl=false',
    '?sslmode=disable',
    '?sslmode=verify-full&sslmode=disable',
    '?sslrootcert=/tmp/cert',
    '?host=evil',
    '#fragment',
  ])
    assert.throws(() => stagingDatabase(url + suffix, undefined));
  assert.throws(() => stagingDatabase(url, 'not-a-certificate'));
  const installer = {
    STAGING_DATABASE_URL: url.replace('trotxi_runtime_api:', 'trotxi:'),
    STAGING_RUNTIME_DATABASE_URL: url,
    STAGING_MAINTENANCE_DATABASE_URL: url.replace('trotxi_runtime_api:', 'trotxi_runtime_worker:'),
    REPLACEMENT_MAINTENANCE_USER_ID: randomUUID(),
  };
  assert.deepEqual(stagingInstallerConfiguration(installer).roles, [
    'trotxi_runtime_api',
    'trotxi_runtime_worker',
  ]);
  assert.throws(() =>
    stagingInstallerConfiguration({ ...installer, STAGING_MAINTENANCE_DATABASE_URL: url }),
  );
  assert.throws(() => stagingInstallerConfiguration({ ...installer, STAGING_DATABASE_URL: url }));
  assert.equal(JSON.parse(failureLine(new Error('secret-value'))).category, 'internal');
  assert.equal(JSON.parse(failureLine(new MaintenanceFailure('transport'))).category, 'transport');
});

test('maintenance workflow has no root key fetch or owner credentials and requires protected main', async () => {
  const source = await readFile(
    new URL('../../../.github/workflows/payments-maintenance.yml', import.meta.url),
    'utf8',
  );
  assert.match(source, /permissions:\s+contents: read/);
  assert.equal((source.match(/environment: staging/g) ?? []).length, 2);
  assert.equal((source.match(/if: github.ref == 'refs\/heads\/main'/g) ?? []).length, 2);
  assert.doesNotMatch(source, /JWT_SECRET|RENDER_API_KEY|secrets\.STAGING_DATABASE_URL|GITHUB_ENV/);
  assert.match(source, /secrets\.STAGING_ACCESS_SECRET/);
  assert.match(source, /secrets\.STAGING_EMAIL_ENCRYPTION_KEY/);
});

test('service maintenance groups call the right routes for the right Accra days', () => {
  const now = new Date('2026-10-05T21:00:00Z');
  const calls = (group: (typeof GROUPS)[number], at = now) =>
    scheduledJobs(group, at).map((j) => [j.route, j.body]);
  assert.deepEqual(calls('ask'), [
    ['ask-dispatch', { travelDate: '2026-10-06', direction: 'outbound', limit: 100 }],
    ['ask-dispatch', { travelDate: '2026-10-06', direction: 'return', limit: 100 }],
  ]);
  // The midnight cutoff books the day the 21:00 ask was about.
  assert.deepEqual(calls('defaults', new Date('2026-10-06T00:00:00Z')), [
    ['reservation-defaults', { travelDate: '2026-10-06', direction: 'outbound', limit: 100 }],
    ['reservation-defaults', { travelDate: '2026-10-06', direction: 'return', limit: 100 }],
  ]);
  assert.deepEqual(calls('no-shows'), [
    ['no-shows', { travelDate: '2026-10-05', direction: 'outbound', limit: 100 }],
    ['no-shows', { travelDate: '2026-10-05', direction: 'return', limit: 100 }],
  ]);
  assert.deepEqual(calls('nightly'), [
    ...['06', '07', '08', '09', '10', '11', '12'].map((d) => [
      'trip-generation',
      { serviceDate: `2026-10-${d}`, limit: 100 },
    ]),
    ['personal-pause-resumes', { limit: 100 }],
    ['route-learning', { limit: 100 }],
    ['gps-retention', { limit: 100 }],
    ['auto-renewals', { limit: 100 }],
  ]);
});

test('the service maintenance workflow maps every schedule to a group and holds no master key', async () => {
  const workflow = await readFile(
    new URL('../../../.github/workflows/service-maintenance.yml', import.meta.url),
    'utf8',
  );
  assert.ok(workflow.includes('node --import tsx scripts/maintain-staging.ts "$group"'));
  const crons = [...workflow.matchAll(/- cron: '([^']+)'/g)].map((m) => m[1]!);
  assert.equal(crons.length, GROUPS.length);
  for (const cron of crons) assert.ok(workflow.includes(`|'${cron}') group=`), cron);
  for (const group of GROUPS) assert.ok(workflow.includes(`${group}|'`), group);
  assert.match(workflow, /environment: staging/);
  assert.match(workflow, /if: github.ref == 'refs\/heads\/main'/);
  for (const forbidden of [
    'JWT_SECRET',
    'OWNER',
    'RENDER_API',
    'PAYSTACK_SECRET',
    'EMAIL_ENCRYPTION',
  ])
    assert.doesNotMatch(workflow, new RegExp(forbidden));
});

test('staging jobs post each body unchanged to its route and refuse an unknown group', async () => {
  const key = Buffer.alloc(32, 5);
  const seen: [string, unknown][] = [];
  const pool = {
    query: async () => ({ rows: [{ id: 'session', user_id: 'operator' }] }),
  } as unknown as Pool;
  const ok = { data: { considered: 0, succeeded: 0, blocked: 0, failed: 0, failures: [] } };
  await runStagingJobs(
    pool,
    key,
    'operator',
    scheduledJobs('ask', new Date('2026-10-05T18:00:00Z')),
    async (input, init) => {
      seen.push([String(input), JSON.parse(init?.body as string)]);
      return Response.json(ok);
    },
    () => {},
  );
  assert.deepEqual(seen, [
    [
      'https://trotxi-api-staging.onrender.com/v1/ops/maintenance/ask-dispatch',
      { travelDate: '2026-10-06', direction: 'outbound', limit: 100 },
    ],
    [
      'https://trotxi-api-staging.onrender.com/v1/ops/maintenance/ask-dispatch',
      { travelDate: '2026-10-06', direction: 'return', limit: 100 },
    ],
  ]);
  const run = spawnSync(
    process.execPath,
    ['--import', 'tsx', 'scripts/maintain-staging.ts', 'everything'],
    {
      cwd: fileURLToPath(new URL('../', import.meta.url)),
      env: { PATH: process.env.PATH },
      encoding: 'utf8',
      timeout: 10_000,
    },
  );
  assert.equal(run.status, 1);
  assert.match(run.stderr, /"category":"configuration"/);
});
