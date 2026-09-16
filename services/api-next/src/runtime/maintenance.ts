import { randomUUID } from 'node:crypto';
import { purgeExpiredDriverSecrets } from '../auth/driver-service.js';
import type { Backend } from './compose.js';

export const JOBS = [
  'payments',
  'ask-dispatch',
  'reservation-defaults',
  'no-shows',
  'route-learning',
  'gps-retention',
  'erasures',
  'driver-secrets',
] as const;
export type Job = (typeof JOBS)[number];
export interface JobRequest {
  job: Job;
  travelDate?: string;
  direction?: 'outbound' | 'return';
  limit?: number;
}
export interface JobResult {
  job: Job;
  status: number;
  body: unknown;
}

const SERVICE_DAY: Record<string, string> = {
  'ask-dispatch': '/v1/ops/maintenance/ask-dispatch',
  'reservation-defaults': '/v1/ops/maintenance/reservation-defaults',
  'no-shows': '/v1/ops/maintenance/no-shows',
};
const BATCH: Record<string, string> = {
  payments: '/v1/ops/maintenance/payments',
  'route-learning': '/v1/ops/maintenance/route-learning',
  'gps-retention': '/v1/ops/maintenance/gps-retention',
};

/**
 * A real, revocable session for the named operations account.
 *
 * The worker is not exempt from authorization. It signs in as an actual admin
 * user, every receipt it writes names that user, and the session is revoked
 * when the run ends whether or not the run succeeded. Nothing here is
 * reachable from a route: minting belongs to the process that owns the
 * scheduled work, not to the application surface.
 */
async function operatorSession(backend: Backend, minutes = 15) {
  const user = (
    await backend.pool.query('SELECT role,deleted_at FROM app.users WHERE id=$1', [
      backend.maintenanceUserId,
    ])
  ).rows[0];
  if (!user) throw new Error('The configured maintenance user does not exist');
  if (user.deleted_at) throw new Error('The configured maintenance user is closed');
  if (user.role !== 'admin') throw new Error('The configured maintenance user is not an operator');
  const session = (
    await backend.pool.query(
      `INSERT INTO app.auth_sessions(user_id,expires_at)
      VALUES ($1, clock_timestamp() + make_interval(mins => $2)) RETURNING id,created_at,expires_at`,
      [backend.maintenanceUserId, minutes],
    )
  ).rows[0];
  const token = await backend.auth.tokens.sign(
    { userId: backend.maintenanceUserId, sessionId: session.id },
    'admin',
    session.created_at,
    session.expires_at,
  );
  return {
    token,
    release: async () => {
      await backend.pool.query(
        'UPDATE app.auth_sessions SET revoked_at=COALESCE(revoked_at,clock_timestamp()) WHERE id=$1',
        [session.id],
      );
    },
  };
}

/**
 * Run one scheduled job.
 *
 * The batch and service-day jobs go through the application's own routes, so
 * they get the same schema validation, authorization, receipts and idempotency
 * as any operator pressing the same button. The two physical sweeps have no
 * reviewed operation and are called directly; neither can be triggered over
 * HTTP, which is the point of them living in the worker.
 */
export async function runJob(backend: Backend, request: JobRequest): Promise<JobResult> {
  const limit = request.limit ?? 100;
  if (!Number.isInteger(limit) || limit < 1 || limit > 100)
    throw new Error('A maintenance batch is between 1 and 100');
  if (request.job === 'driver-secrets')
    return {
      job: request.job,
      status: 200,
      body: { cleared: await purgeExpiredDriverSecrets(backend.pool, limit) },
    };
  if (request.job === 'erasures')
    return { job: request.job, status: 200, body: await backend.account.retryErasures(limit) };
  const day = SERVICE_DAY[request.job];
  if (day && (!request.travelDate || !request.direction))
    throw new Error(`${request.job} needs a travel date and a direction`);
  const session = await operatorSession(backend);
  try {
    const response = await backend.app.inject({
      method: 'POST',
      url: day ?? BATCH[request.job]!,
      payload: day
        ? { travelDate: request.travelDate, direction: request.direction, limit }
        : { limit },
      headers: {
        authorization: `Bearer ${session.token}`,
        'idempotency-key': randomUUID(),
        'x-trotxi-client': 'worker',
        'x-trotxi-build': '1',
      },
    });
    return { job: request.job, status: response.statusCode, body: response.json() };
  } finally {
    await session.release();
  }
}
