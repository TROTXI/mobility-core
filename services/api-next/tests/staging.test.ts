import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import type { Pool } from 'pg';
import { readConfiguration } from '../src/runtime/config.js';
import { assertRuntimeRole } from '../src/runtime/compose.js';
import { STAGING_SERVICE_ID } from '../src/runtime/staging-profile.js';

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
  assert.equal(config.maintenanceUserId, '');
  assert.equal(new Set(Object.values(config.keys).map((k) => k.toString('hex'))).size, 9);
  assert.deepEqual(readConfiguration(env).keys, config.keys);
  assert.notDeepEqual(
    readConfiguration({ ...env, JWT_SECRET: env.JWT_SECRET + 'changed' }).keys,
    config.keys,
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
