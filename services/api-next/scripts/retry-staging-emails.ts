/** Bounded staging outbox retry; no seeding, new messages or credential issuance. */
import { pathToFileURL } from 'node:url';
import pg from 'pg';
import { TransactionalEmail } from '../src/notifications/email.js';
import { ResendSender } from '../src/notifications/resend.js';
import { jobFailed, jobLog } from '../src/runtime/job-outcome.js';
import { stagingDatabase } from '../src/runtime/staging-database.js';
import { assertRuntimeRole } from '../src/runtime/compose.js';
import { MaintenanceAudit } from '../src/runtime/maintenance-audit.js';
import {
  assertMaintenanceIdentity,
  failureLine,
  guarded,
  maintenanceUserId,
} from './maintenance-safety.js';

/**
 * Only the outbox key and sender credential reach this step, never the master key.
 */
export function retryConfiguration(env: NodeJS.ProcessEnv) {
  const apiKey = env.RESEND_API_KEY;
  // No sender configured is the API's own "email not configured": nothing was
  // sent immediately either, so there is nothing to retry. Skip, do not fail.
  if (!apiKey) return { skip: 'RESEND_API_KEY is not set; email retries skipped.' };
  const database = stagingDatabase(
    env.REPLACEMENT_RUNTIME_DATABASE_URL,
    env.STAGING_DATABASE_CA_CERT,
  );
  if (!apiKey.startsWith('re_') || /\s/.test(apiKey))
    throw new Error('RESEND_API_KEY is malformed');
  const encryptionKey = Buffer.from(env.EMAIL_ENCRYPTION_KEY ?? '', 'base64');
  if (encryptionKey.length !== 32)
    throw new Error('EMAIL_ENCRYPTION_KEY must be the 32-byte derived outbox key');
  return { ...database, encryptionKey, apiKey, userId: maintenanceUserId(env) };
}

async function main() {
  const config = await guarded('configuration', async () => retryConfiguration(process.env));
  if (config.skip !== undefined) {
    process.stdout.write(`::notice::${config.skip}\n`);
    return;
  }
  const pool = new pg.Pool({
    connectionString: config.connectionString,
    ssl: config.ssl,
    max: 4,
    connectionTimeoutMillis: 10000,
  });
  try {
    await guarded('database', () => assertRuntimeRole(pool));
    await assertMaintenanceIdentity(pool, config.userId);
    const audit = new MaintenanceAudit(pool);
    const runId = await guarded('database', () => audit.startWorker(config.userId, 'emails'));
    const email = new TransactionalEmail({
      pool,
      encryptionKey: config.encryptionKey,
      sender: new ResendSender(config.apiKey),
      staging: true,
    });
    // Retry all due transactional mail, not just drivers. Do not prepare reminders:
    // this schedule retries the outbox; it does not introduce new sending policy.
    const body = await email.drain(100).catch(async () => {
      await guarded('database', () => audit.finish(runId, 500, null, true));
      throw new Error('Email drain failed');
    });
    const result = { job: 'emails' as const, status: 200, body };
    await guarded('database', () => audit.finish(runId, result.status, body, jobFailed(result)));
    process.stdout.write(`${jobLog(result)}\n`);
    if (jobFailed(result)) process.exitCode = 1;
  } finally {
    await pool.end();
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((error) => {
    // These are public Actions logs: never expose connection strings, keys or payloads.
    process.stderr.write(`${failureLine(error)}\n`);
    process.exitCode = 1;
  });
}
