/** Staging payment recovery only. No account, catalogue or credential seeding. */
import { randomUUID } from 'node:crypto';
import { pathToFileURL } from 'node:url';
import { SignJWT } from 'jose';
import pg from 'pg';
import { z } from 'zod';
import { stagingDatabase } from '../src/runtime/staging-database.js';
import { MaintenanceAudit } from '../src/runtime/maintenance-audit.js';
import { assertRuntimeRole } from '../src/runtime/compose.js';
import {
  assertMaintenanceIdentity,
  failureLine,
  guarded,
  MaintenanceFailure,
  maintenanceUserId,
} from './maintenance-safety.js';

const API = 'https://trotxi-api-staging.onrender.com';
const count = z.number().int().nonnegative().safe();
const batch = z.object({
  data: z.object({
    considered: count,
    succeeded: count,
    blocked: count,
    failed: count,
    failures: z.array(z.unknown()),
  }),
});

export function paymentMaintenanceConfiguration(env: NodeJS.ProcessEnv) {
  const database = stagingDatabase(
    env.REPLACEMENT_RUNTIME_DATABASE_URL,
    env.STAGING_DATABASE_CA_CERT,
  );
  const key = Buffer.from(env.REPLACEMENT_ACCESS_SECRET ?? '', 'base64');
  if (key.length !== 32) throw new Error('The derived staging access key must be 32 bytes');
  return { ...database, key, userId: maintenanceUserId(env) };
}

export async function maintainStagingPayments(
  pool: pg.Pool,
  key: Uint8Array,
  userId: string,
  request: typeof fetch = fetch,
  log: (line: string) => void = (line) => process.stdout.write(`${line}\n`),
): Promise<void> {
  await assertMaintenanceIdentity(pool, userId);
  const session = (
    await guarded('database', () =>
      pool.query<{ id: string; user_id: string }>(
        `INSERT INTO app.auth_sessions(user_id,expires_at,admin_verified_at,issued_for)
       SELECT id,clock_timestamp()+interval '10 minutes',clock_timestamp(),'maintenance'
       FROM app.users WHERE id=$1 AND role='admin' AND deleted_at IS NULL
       RETURNING id,user_id`,
        [userId],
      ),
    )
  ).rows[0];
  if (!session) throw new MaintenanceFailure('configuration');

  try {
    const token = await new SignJWT({ sid: session.id, role: 'admin' })
      .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
      .setSubject(session.user_id)
      .setIssuer('trotxi-api')
      .setAudience('trotxi-clients')
      .setIssuedAt()
      .setExpirationTime('10m')
      .sign(key);
    let failed = false;
    const audit = new MaintenanceAudit(pool);
    for (const job of ['payment-inbox', 'payment-reconciliation'] as const) {
      const runId = await guarded('database', () => audit.startWorker(userId, job));
      let response: Response;
      try {
        response = await guarded('transport', () =>
          request(`${API}/v1/ops/maintenance/${job}`, {
            method: 'POST',
            redirect: 'error',
            headers: {
              'content-type': 'application/json',
              'x-trotxi-client': 'worker',
              'x-trotxi-build': '1',
              'idempotency-key': randomUUID(),
              authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({ limit: 100 }),
          }),
        );
      } catch (error) {
        await guarded('database', () => audit.finish(runId, 503, null, true));
        throw error;
      }
      const parsed = batch.safeParse(await response.json().catch(() => null));
      const ok = response.status === 200 && parsed.success;
      const counts = ok ? parsed.data.data : undefined;
      failed ||= !ok || counts!.failed > 0 || counts!.failures.length > 0;
      const category =
        response.status !== 200
          ? 'http'
          : !parsed.success
            ? 'response_contract'
            : counts!.failed > 0 || counts!.failures.length > 0
              ? 'partial_batch'
              : undefined;
      await guarded('database', () =>
        audit.finish(
          runId,
          response.status,
          counts ? { data: counts } : null,
          category !== undefined,
        ),
      );
      // Public Actions logs get only allowlisted counts, never raw responses,
      // resource IDs, error reasons, account details or tokens.
      log(
        JSON.stringify({
          job,
          status: response.status,
          ...(category ? { category } : {}),
          ...(counts
            ? {
                considered: counts.considered,
                succeeded: counts.succeeded,
                blocked: counts.blocked,
                failed: counts.failed,
              }
            : {}),
        }),
      );
    }
    if (failed) throw new MaintenanceFailure('partial_batch');
  } finally {
    await guarded('session_revocation', () =>
      pool.query('UPDATE app.auth_sessions SET revoked_at=clock_timestamp() WHERE id=$1', [
        session.id,
      ]),
    );
  }
}

async function main() {
  const config = await guarded('configuration', async () =>
    paymentMaintenanceConfiguration(process.env),
  );
  const pool = new pg.Pool({
    connectionString: config.connectionString,
    ssl: config.ssl,
    max: 2,
    connectionTimeoutMillis: 10_000,
  });
  try {
    await guarded('database', () => assertRuntimeRole(pool));
    await maintainStagingPayments(pool, config.key, config.userId);
  } finally {
    await pool.end();
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((error) => {
    process.stderr.write(`${failureLine(error)}\n`);
    process.exitCode = 1;
  });
}
