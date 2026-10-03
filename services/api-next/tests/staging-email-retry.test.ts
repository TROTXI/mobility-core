import { test } from 'node:test';
import assert from 'node:assert/strict';
import { hkdfSync } from 'node:crypto';
import { retryConfiguration } from '../scripts/retry-staging-emails.js';
import { existingStagingEnvironment, STAGING_SERVICE_ID } from '../src/runtime/staging-profile.js';

const root = 'fixture-staging-root-key'.repeat(3);
// What the workflow's key step derives and hands over; the root stays there.
const derived = Buffer.from(
  hkdfSync('sha256', root, 'trotxi:replacement:staging:v1', 'DEVICE_KEY', 32),
).toString('base64');
const env = {
  REPLACEMENT_RUNTIME_DATABASE_URL:
    'postgres://trotxi_runtime_worker:fixture@dpg-d8sugvv7f7vs73bifff0-a.frankfurt-postgres.render.com/trotxi',
  REPLACEMENT_MAINTENANCE_USER_ID: '00000000-0000-4000-8000-000000000001',
  EMAIL_ENCRYPTION_KEY: derived,
  RESEND_API_KEY: 're_fixture_only',
};
test('email retries decrypt with precisely the running staging service key', () => {
  const service = existingStagingEnvironment({
    REPLACEMENT_RUNTIME_DATABASE_URL: env.REPLACEMENT_RUNTIME_DATABASE_URL,
    JWT_SECRET: root,
    PAYSTACK_SECRET_KEY: 'sk_test_fixture',
    RENDER_SERVICE_ID: STAGING_SERVICE_ID,
    RENDER_SERVICE_NAME: 'trotxi-api-staging',
  });
  const config = retryConfiguration(env);
  assert.equal(config.skip, undefined);
  if (config.skip !== undefined) return;
  // The workflow's derivation matches the key the running service seals with.
  assert.deepEqual(config.encryptionKey, Buffer.from(service.REPLACEMENT_DEVICE_KEY!, 'base64'));
  assert.equal(config.ssl.rejectUnauthorized, true);
});
test('retry configuration refuses another database, owner or unsafe URL options', () => {
  for (const url of [
    'postgres://trotxi:fixture@production.example/trotxi',
    env.REPLACEMENT_RUNTIME_DATABASE_URL.replace('/trotxi', '/other'),
    env.REPLACEMENT_RUNTIME_DATABASE_URL.replace('trotxi_runtime_worker:fixture', 'trotxi:fixture'),
    `${env.REPLACEMENT_RUNTIME_DATABASE_URL}?options=-csearch_path=public`,
  ]) {
    assert.throws(() => retryConfiguration({ ...env, REPLACEMENT_RUNTIME_DATABASE_URL: url }));
  }
});
test('no Resend key skips instead of failing; a bad key or outbox key still fails', () => {
  for (const missing of [
    { ...env, RESEND_API_KEY: '' },
    { ...env, RESEND_API_KEY: undefined },
  ])
    assert.match(retryConfiguration(missing).skip ?? '', /not set/);
  assert.throws(() => retryConfiguration({ ...env, RESEND_API_KEY: 're_bad\nkey' }));
  assert.throws(() => retryConfiguration({ ...env, EMAIL_ENCRYPTION_KEY: '' }));
  assert.throws(() => retryConfiguration({ ...env, EMAIL_ENCRYPTION_KEY: 'c2hvcnQ=' }));
});

test('the script never reads the master key', async () => {
  const source = await (
    await import('node:fs/promises')
  ).readFile(new URL('../scripts/retry-staging-emails.ts', import.meta.url), 'utf8');
  assert.ok(!source.includes('JWT_SECRET'), 'the master key stays in the workflow key step');
});
