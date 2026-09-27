/** Bounded staging outbox retry; no seeding, new messages or credential issuance. */
import { hkdfSync } from 'node:crypto';
import { pathToFileURL } from 'node:url';
import pg from 'pg';
import { TransactionalEmail } from '../src/notifications/email.js';
import { ResendSender } from '../src/notifications/resend.js';
import { jobFailed, jobLog } from '../src/runtime/job-outcome.js';

export function retryConfiguration(env: NodeJS.ProcessEnv) {
  const database = new URL(env.REPLACEMENT_DATABASE_URL ?? '');
  if (
    !['postgres:', 'postgresql:'].includes(database.protocol) ||
    database.pathname !== '/trotxi' ||
    database.username !== 'trotxi' ||
    database.hostname !== 'dpg-d8sugvv7f7vs73bifff0-a.frankfurt-postgres.render.com' ||
    [...database.searchParams.keys()].some((key) => !['sslmode', 'sslrootcert'].includes(key)) ||
    database.hash
  )
    throw new Error('Only the existing external staging database is allowed');
  const jwt = env.JWT_SECRET;
  if (!jwt || Buffer.byteLength(jwt) < 32) throw new Error('Staging JWT_SECRET is required');
  const apiKey = env.RESEND_API_KEY;
  if (!apiKey?.startsWith('re_') || /\s/.test(apiKey))
    throw new Error('RESEND_API_KEY is required');
  // Exactly the DEVICE_KEY derivation used by existingStagingEnvironment at boot.
  const encryptionKey = Buffer.from(
    hkdfSync('sha256', jwt, 'trotxi:replacement:staging:v1', 'DEVICE_KEY', 32),
  );
  if (!database.searchParams.has('sslmode')) database.searchParams.set('sslmode', 'no-verify');
  return { connectionString: database.href, encryptionKey, apiKey };
}

async function main() {
  const config = retryConfiguration(process.env);
  const pool = new pg.Pool({
    connectionString: config.connectionString,
    max: 4,
    connectionTimeoutMillis: 10000,
  });
  try {
    const email = new TransactionalEmail({
      pool,
      encryptionKey: config.encryptionKey,
      sender: new ResendSender(config.apiKey),
      staging: true,
    });
    // Retry all due transactional mail, not just drivers. Do not prepare reminders:
    // this schedule retries the outbox; it does not introduce new sending policy.
    const result = { job: 'emails' as const, status: 200, body: await email.drain(100) };
    process.stdout.write(`${jobLog(result)}\n`);
    if (jobFailed(result)) process.exitCode = 1;
  } finally {
    await pool.end();
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch(() => {
    // These are public Actions logs: never expose connection strings, keys or payloads.
    process.stderr.write('Staging email retry failed; check configuration and outbox status.\n');
    process.exitCode = 1;
  });
}
