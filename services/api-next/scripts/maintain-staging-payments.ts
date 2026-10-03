/** Staging payment recovery only. No account, catalogue or credential seeding. */
import { randomUUID } from 'node:crypto';
import { pathToFileURL } from 'node:url';
import { SignJWT } from 'jose';
import pg from 'pg';
import { z } from 'zod';

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
  const database = new URL(env.REPLACEMENT_DATABASE_URL ?? '');
  if (
    !['postgres:', 'postgresql:'].includes(database.protocol) ||
    database.pathname !== '/trotxi' ||
    database.username !== 'trotxi' ||
    database.hostname !== 'dpg-d8sugvv7f7vs73bifff0-a.frankfurt-postgres.render.com' ||
    (database.port && database.port !== '5432') ||
    [...database.searchParams.keys()].some((key) => !['sslmode', 'sslrootcert'].includes(key)) ||
    database.hash
  )
    throw new Error('Only the existing external staging database is allowed');
  const key = Buffer.from(env.REPLACEMENT_ACCESS_SECRET ?? '', 'base64');
  if (key.length !== 32) throw new Error('The derived staging access key must be 32 bytes');
  if (!database.searchParams.has('sslmode')) database.searchParams.set('sslmode', 'no-verify');
  return { connectionString: database.href, key };
}

export async function maintainStagingPayments(
  pool: pg.Pool,
  key: Uint8Array,
  request: typeof fetch = fetch,
  log: (line: string) => void = (line) => process.stdout.write(`${line}\n`),
): Promise<void> {
  // Preserve the staging scheduler's short-lived, elevated operator session,
  // but never create an administrator if none exists.
  const session = (
    await pool.query<{ id: string; user_id: string }>(
      `INSERT INTO app.auth_sessions(user_id,expires_at,admin_verified_at)
       SELECT id,clock_timestamp()+interval '10 minutes',clock_timestamp()
       FROM app.users WHERE role='admin' AND deleted_at IS NULL
       ORDER BY created_at,id LIMIT 1 RETURNING id,user_id`,
    )
  ).rows[0];
  if (!session) throw new Error('An existing active staging administrator is required');

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
    for (const job of ['payment-inbox', 'payment-reconciliation'] as const) {
      const response = await request(`${API}/v1/ops/maintenance/${job}`, {
        method: 'POST',
        redirect: 'error',
        headers: {
          'content-type': 'application/json',
          'x-trotxi-client': 'ops',
          'x-trotxi-build': '1',
          'idempotency-key': randomUUID(),
          authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ limit: 100 }),
      });
      const parsed = batch.safeParse(await response.json().catch(() => null));
      const ok = response.status === 200 && parsed.success;
      const counts = ok ? parsed.data.data : undefined;
      failed ||= !ok || counts!.failed > 0 || counts!.failures.length > 0;
      // Public Actions logs get only allowlisted counts, never raw responses,
      // resource IDs, error reasons, account details or tokens.
      log(
        JSON.stringify({
          job,
          status: response.status,
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
    if (failed) throw new Error('Staging payment maintenance did not complete successfully');
  } finally {
    await pool.query('UPDATE app.auth_sessions SET revoked_at=clock_timestamp() WHERE id=$1', [
      session.id,
    ]);
  }
}

async function main() {
  const config = paymentMaintenanceConfiguration(process.env);
  const pool = new pg.Pool({
    connectionString: config.connectionString,
    max: 2,
    connectionTimeoutMillis: 10_000,
  });
  try {
    await maintainStagingPayments(pool, config.key);
  } finally {
    await pool.end();
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch(() => {
    process.stderr.write(
      'Staging payment maintenance failed; check configuration and Ops payment status.\n',
    );
    process.exitCode = 1;
  });
}
