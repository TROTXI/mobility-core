import { hkdfSync } from 'node:crypto';
import { stagingDatabase } from './staging-database.js';

export const STAGING_SERVICE_ID = 'srv-d8suhkn7f7vs73bigd40';
type Env = Record<string, string | undefined>;
const purposes = [
  'ACCESS_SECRET',
  'CURSOR_SECRET',
  'PIN_SECRET',
  'CREDENTIAL_REPLAY_KEY',
  'PROVIDER_ENCRYPTION_KEY',
  'BOARDING_PROOF_KEY',
  'DEVICE_KEY',
  'PAYSTACK_EVIDENCE_KEY',
] as const;

/** Existing staging only, with a separately provisioned restricted DB login.
 * Stable, purpose-separated derivation preserves keys across restarts.
 * Rotating JWT_SECRET also rotates encryption keys: never rotate casually.
 */
export function existingStagingEnvironment(env: Env): Env {
  if (
    env.RENDER_SERVICE_ID !== STAGING_SERVICE_ID ||
    env.RENDER_SERVICE_NAME !== 'trotxi-api-staging'
  )
    throw new Error('Existing settings require the named staging service');
  if (env.DEPLOYMENT_ENVIRONMENT && env.DEPLOYMENT_ENVIRONMENT !== 'staging')
    throw new Error('The staging service cannot configure production');
  if (!env.PAYSTACK_SECRET_KEY?.startsWith('sk_test_'))
    throw new Error('PAYSTACK_SECRET_KEY must be TEST on staging');
  if (!env.JWT_SECRET || Buffer.byteLength(env.JWT_SECRET) < 32)
    throw new Error('JWT_SECRET must contain at least 32 bytes');
  if (env.DATABASE_URL || env.MIGRATION_DATABASE_URL)
    throw new Error('Remove the owner database credentials from the staging API environment');
  stagingDatabase(env.RUNTIME_DATABASE_URL, env.STAGING_DATABASE_CA_CERT);
  for (const purpose of purposes)
    if (env[purpose])
      throw new Error('Remove extra key settings before using existing staging settings');
  if (env.R2_BUCKET_NAME && env.R2_BUCKET && env.R2_BUCKET_NAME !== env.R2_BUCKET)
    throw new Error('Conflicting settings for R2_BUCKET_NAME');
  const result: Env = {
    ...env,
    DEPLOYMENT_ENVIRONMENT: 'staging',
    SERVICE_NAME: 'trotxi-api-staging',
    POOL_SIZE: '4',
    AUTH_PROVIDERS: 'google',
    OPS_ORIGIN: env.OPS_ORIGIN ?? 'https://trotxi-ops-staging.onrender.com',
    R2_BUCKET_NAME: env.R2_BUCKET_NAME ?? env.R2_BUCKET,
  };
  for (const purpose of purposes)
    // Preserve this salt exactly: changing it would rotate stored encryption keys.
    result[purpose] = Buffer.from(
      hkdfSync('sha256', env.JWT_SECRET, 'trotxi:replacement:staging:v1', purpose, 32),
    ).toString('base64');
  return result;
}
