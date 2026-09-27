import { test } from 'node:test';
import assert from 'node:assert/strict';
import { retryConfiguration } from '../scripts/retry-staging-emails.js';
import { existingStagingEnvironment, STAGING_SERVICE_ID } from '../src/runtime/staging-profile.js';

const env = {
  REPLACEMENT_DATABASE_URL:
    'postgres://trotxi:fixture@dpg-d8sugvv7f7vs73bifff0-a.frankfurt-postgres.render.com/trotxi',
  JWT_SECRET: 'fixture-staging-root-key'.repeat(3),
  RESEND_API_KEY: 're_fixture_only',
};
test('email retries decrypt with precisely the running staging service key', () => {
  const service = existingStagingEnvironment({
    DATABASE_URL: env.REPLACEMENT_DATABASE_URL,
    JWT_SECRET: env.JWT_SECRET,
    PAYSTACK_SECRET_KEY: 'sk_test_fixture',
    RENDER_SERVICE_ID: STAGING_SERVICE_ID,
    RENDER_SERVICE_NAME: 'trotxi-api-staging',
  });
  const config = retryConfiguration(env);
  assert.deepEqual(config.encryptionKey, Buffer.from(service.REPLACEMENT_DEVICE_KEY!, 'base64'));
  assert.equal(new URL(config.connectionString).searchParams.get('sslmode'), 'no-verify');
});
test('retry configuration refuses another database, owner or unsafe URL options', () => {
  for (const url of [
    'postgres://trotxi:fixture@production.example/trotxi',
    env.REPLACEMENT_DATABASE_URL.replace('/trotxi', '/other'),
    env.REPLACEMENT_DATABASE_URL.replace('trotxi:fixture', 'other:fixture'),
    `${env.REPLACEMENT_DATABASE_URL}?options=-csearch_path=public`,
  ]) {
    assert.throws(() => retryConfiguration({ ...env, REPLACEMENT_DATABASE_URL: url }));
  }
});
test('retry configuration requires the existing root and sending credentials', () => {
  assert.throws(() => retryConfiguration({ ...env, JWT_SECRET: '' }));
  assert.throws(() => retryConfiguration({ ...env, RESEND_API_KEY: '' }));
  assert.throws(() => retryConfiguration({ ...env, RESEND_API_KEY: 're_bad\nkey' }));
});
