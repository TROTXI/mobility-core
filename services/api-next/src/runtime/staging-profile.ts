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
  if (
    env.REPLACEMENT_DEPLOYMENT_ENVIRONMENT &&
    env.REPLACEMENT_DEPLOYMENT_ENVIRONMENT !== 'staging'
  )
    throw new Error('The staging service cannot configure production');
  if (!env.PAYSTACK_SECRET_KEY?.startsWith('sk_test_'))
    throw new Error('PAYSTACK_SECRET_KEY must be TEST on staging');
  if (!env.JWT_SECRET || Buffer.byteLength(env.JWT_SECRET) < 32)
    throw new Error('JWT_SECRET must contain at least 32 bytes');
  if (env.DATABASE_URL || env.REPLACEMENT_DATABASE_URL)
    throw new Error('Remove the owner database credentials from the staging API environment');
  stagingDatabase(env.REPLACEMENT_RUNTIME_DATABASE_URL, env.STAGING_DATABASE_CA_CERT);
  for (const purpose of purposes)
    if (env[`REPLACEMENT_${purpose}`])
      throw new Error(
        'Remove extra REPLACEMENT key settings before using existing staging settings',
      );
  const result: Env = {
    ...env,
    REPLACEMENT_DEPLOYMENT_ENVIRONMENT: 'staging',
    REPLACEMENT_SERVICE_NAME: 'trotxi-api-staging',
    REPLACEMENT_POOL_SIZE: '4',
    REPLACEMENT_PAYSTACK_SECRET_KEY: env.PAYSTACK_SECRET_KEY,
    REPLACEMENT_GOOGLE_CLIENT_ID: env.GOOGLE_CLIENT_ID,
    REPLACEMENT_AUTH_PROVIDERS: 'google',
    REPLACEMENT_OPS_ORIGIN: env.OPS_ORIGIN ?? 'https://trotxi-ops-staging.onrender.com',
    REPLACEMENT_R2_ACCOUNT_ID: env.R2_ACCOUNT_ID,
    REPLACEMENT_R2_ACCESS_KEY_ID: env.R2_ACCESS_KEY_ID,
    REPLACEMENT_R2_SECRET_ACCESS_KEY: env.R2_SECRET_ACCESS_KEY,
    REPLACEMENT_R2_BUCKET_NAME: env.R2_BUCKET,
    REPLACEMENT_MAP_TILES_URL: env.MAP_TILES_URL,
    REPLACEMENT_MAP_STYLE_URL: env.MAP_STYLE_URL,
    REPLACEMENT_MAP_STYLE_DARK_URL: env.MAP_STYLE_DARK_URL,
    REPLACEMENT_TRUST_PROXY: env.TRUST_PROXY,
    REPLACEMENT_OPERATIONS_PHONE: env.OPERATIONS_PHONE,
    REPLACEMENT_OPERATIONS_WHATSAPP: env.OPERATIONS_WHATSAPP,
    REPLACEMENT_OPERATIONS_EMAIL: env.OPERATIONS_EMAIL,
    REPLACEMENT_OPERATIONS_HOURS: env.OPERATIONS_HOURS,
  };
  for (const purpose of purposes)
    result[`REPLACEMENT_${purpose}`] = Buffer.from(
      hkdfSync('sha256', env.JWT_SECRET, 'trotxi:replacement:staging:v1', purpose, 32),
    ).toString('base64');
  return result;
}
