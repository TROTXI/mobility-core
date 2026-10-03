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
import {
  maintainStagingPayments,
  paymentMaintenanceConfiguration,
} from '../scripts/maintain-staging-payments.js';

const settings = () => ({
  RENDER_SERVICE_ID: STAGING_SERVICE_ID,
  RENDER_SERVICE_NAME: 'trotxi-api-staging',
  RENDER_GIT_COMMIT: 'a'.repeat(40),
  DATABASE_URL: 'postgres://trotxi:fixture@dpg-d8sugvv7f7vs73bifff0-a/trotxi',
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
    REPLACEMENT_DATABASE_URL:
      'postgres://trotxi:fixture@dpg-d8sugvv7f7vs73bifff0-a.frankfurt-postgres.render.com/trotxi',
    REPLACEMENT_ACCESS_SECRET: Buffer.alloc(32, 2).toString('base64'),
  };
  const config = paymentMaintenanceConfiguration(env);
  assert.equal(new URL(config.connectionString).searchParams.get('sslmode'), 'no-verify');
  assert.deepEqual(config.key, Buffer.alloc(32, 2));
  for (const database of [
    env.REPLACEMENT_DATABASE_URL.replace('/trotxi', '/production'),
    env.REPLACEMENT_DATABASE_URL.replace('trotxi:fixture', 'other:fixture'),
    env.REPLACEMENT_DATABASE_URL.replace(
      'dpg-d8sugvv7f7vs73bifff0-a.frankfurt-postgres.render.com',
      'other.example',
    ),
    env.REPLACEMENT_DATABASE_URL + '?host=other.example',
  ])
    assert.throws(() =>
      paymentMaintenanceConfiguration({ ...env, REPLACEMENT_DATABASE_URL: database }),
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
  assert.match(run.stderr, /Staging payment maintenance failed/);
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
    const run = maintainStagingPayments(pool, key, request, (line) => logs.push(line));
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

test('existing staging config needs no new secrets and preserves existing provider values', () => {
  const env = settings();
  const before = { ...env };
  const config = readConfiguration(env);
  assert.deepEqual(env, before);
  assert.equal(config.existingStaging, true);
  assert.equal(config.databaseUrl, env.DATABASE_URL);
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
    { DATABASE_URL: settings().DATABASE_URL + '?host=other-host' },
    { DATABASE_URL: settings().DATABASE_URL.replace('/trotxi', '/other') },
    { REPLACEMENT_ACCESS_SECRET: Buffer.alloc(32, 1).toString('base64') },
  ])
    assert.throws(() => readConfiguration({ ...settings(), ...change }));
});

test('owner exception requires both explicit staging configuration and matching database facts', async () => {
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
  await assertRuntimeRole(pool(), true);
  await assert.rejects(
    assertRuntimeRole(pool({ database: 'production' }), true),
    /staging owner exception/,
  );
  await assert.rejects(
    assertRuntimeRole(pool({ login: 'another-owner' }), true),
    /staging owner exception/,
  );
  await assert.rejects(assertRuntimeRole(pool({ installed: false }), true), /not installed/);
  await assertRuntimeRole(pool({ create_schema: false, rewrite_history: false }));
});
