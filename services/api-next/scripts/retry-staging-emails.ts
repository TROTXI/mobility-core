/** Bounded staging outbox retry; no seeding, new messages or credential issuance. */
import { pathToFileURL } from 'node:url';
import pg from 'pg';
import { TransactionalEmail } from '../src/notifications/email.js';
import { ResendSender } from '../src/notifications/resend.js';
import { jobFailed, jobLog } from '../src/runtime/job-outcome.js';

/**
 * What the retry needs, or why it should not run. The workflow derives the
 * outbox key from the staging master key in its own step and passes only the
 * derived key here; this script never sees the master key.
 */
export function retryConfiguration(
  env: NodeJS.ProcessEnv,
):
  | { skip: string }
  | { skip?: undefined; connectionString: string; encryptionKey: Buffer; apiKey: string } {
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
  const apiKey = env.RESEND_API_KEY;
  // No sender configured is the API's own "email not configured": nothing was
  // sent immediately either, so there is nothing to retry. Skip, do not fail.
  if (!apiKey) return { skip: 'RESEND_API_KEY is not set; email retries skipped.' };
  if (!apiKey.startsWith('re_') || /\s/.test(apiKey))
    throw new Error('RESEND_API_KEY is malformed');
  const encryptionKey = Buffer.from(env.EMAIL_ENCRYPTION_KEY ?? '', 'base64');
  if (encryptionKey.length !== 32)
    throw new Error('EMAIL_ENCRYPTION_KEY must be the 32-byte derived outbox key');
  if (!database.searchParams.has('sslmode')) database.searchParams.set('sslmode', 'no-verify');
  return { connectionString: database.href, encryptionKey, apiKey };
}

async function main() {
  const config = retryConfiguration(process.env);
  if (config.skip !== undefined) {
    process.stdout.write(`::notice::${config.skip}\n`);
    return;
  }
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
