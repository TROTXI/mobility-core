import { randomUUID } from 'node:crypto';
import { purgeExpiredDriverSecrets } from '../auth/driver-service.js';
import type { Backend } from './compose.js';
import { jobFailed } from './job-outcome.js';
import { purgeExpiredCommandPayloads } from './receipt-retention.js';
import { redactExpiredIncidents } from './incident-retention.js';
import { purgeExpiredPhoneOtpChallenges } from '../auth/phone-otp.js';
import { purgeExpiredEmailAccess } from '../auth/email-auth.js';
import { redactExpiredPaymentEvidence } from '../payments/evidence-retention.js';

export const JOBS = [
  'personal-pause-resumes',
  'payments',
  'ask-dispatch',
  'reservation-defaults',
  'no-shows',
  'route-learning',
  'gps-retention',
  'incident-retention',
  'payment-evidence-retention',
  'erasures',
  'driver-secrets',
  'admission',
  'emails',
  'trip-generation',
  'push',
  'auto-renewals',
] as const;
export type Job = (typeof JOBS)[number];
export interface JobRequest {
  job: Job;
  travelDate?: string;
  direction?: 'outbound' | 'return';
  limit?: number;
  maxBatches?: number;
  maxRunMs?: number;
}
export interface JobResult {
  job: Job;
  status: number;
  body: unknown;
  receiptPayloadsCleared?: number;
  retention?: {
    expiredFixes: number;
    heldFixes: number;
    deletableFixes: number;
    oldestDeletableAt: string | null;
    overdueSeconds: number;
    batches: number;
    elapsedMs: number;
    budgetExhausted: boolean;
  };
}

const SERVICE_DAY: Record<string, string> = {
  'ask-dispatch': '/v1/ops/maintenance/ask-dispatch',
  'reservation-defaults': '/v1/ops/maintenance/reservation-defaults',
  'no-shows': '/v1/ops/maintenance/no-shows',
};
const BATCH: Record<string, string> = {
  'personal-pause-resumes': '/v1/ops/maintenance/personal-pause-resumes',
  payments: '/v1/ops/maintenance/payments',
  'route-learning': '/v1/ops/maintenance/route-learning',
  'gps-retention': '/v1/ops/maintenance/gps-retention',
  'auto-renewals': '/v1/ops/maintenance/auto-renewals',
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
  if (!backend.maintenanceUserId)
    throw new Error('REPLACEMENT_MAINTENANCE_USER_ID is required to run maintenance');
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
      // Elevated at birth. Admin sessions need the authenticator check, and this
      // one is minted by a process holding database access, which is already
      // past anything a second factor protects. Without this, every scheduled
      // job would be refused the moment two-factor sign-in shipped.
      `INSERT INTO app.auth_sessions(user_id,expires_at,admin_verified_at,issued_for)
      VALUES ($1, clock_timestamp() + make_interval(mins => $2), clock_timestamp(),'maintenance')
      RETURNING id,created_at,expires_at`,
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
 * as any operator pressing the same button. The direct physical sweeps have no
 * reviewed operation and are called directly; neither can be triggered over
 * HTTP, which is the point of them living in the worker.
 */
async function runJobCore(backend: Backend, request: JobRequest): Promise<JobResult> {
  const limit = request.limit ?? 100;
  if (!Number.isInteger(limit) || limit < 1 || limit > 100)
    throw new Error('A maintenance batch is between 1 and 100');
  const day = SERVICE_DAY[request.job];
  if (day && (!request.travelDate || !request.direction))
    throw new Error(`${request.job} needs a travel date and a direction`);
  // Opened for every job, including those with no HTTP route: destroying
  // credential ciphertext and withdrawing a rider's provider grant are not
  // things an unattributed process should be able to start, so the operations
  // account is checked and a session opened before either runs.
  //
  // KNOWN GAP, flagged rather than invented: these write no command receipt. There
  // is no reviewed operation and no command store for them, and adding one is
  // a contract and schema decision, not something to improvise here.
  const session = await operatorSession(backend);
  try {
    if (request.job === 'push') {
      if (!backend.push)
        throw new Error('FIREBASE_SERVICE_ACCOUNT is required for the push worker');
      return { job: request.job, status: 200, body: await backend.push.drain(limit) };
    }
    if (request.job === 'trip-generation') {
      const response = await backend.app.inject({
        method: 'POST',
        url: '/v1/ops/maintenance/trip-generation',
        headers: {
          authorization: `Bearer ${session.token}`,
          'x-trotxi-client': 'worker',
          'x-trotxi-build': '1',
        },
        payload: {
          serviceDate:
            request.travelDate ?? new Date(Date.now() + 86400000).toISOString().slice(0, 10),
          limit,
        },
      });
      return { job: request.job, status: response.statusCode, body: response.json() };
    }
    if (request.job === 'emails') {
      if (!backend.email && !backend.sms)
        throw new Error('An email or SMS provider is required for the notification worker');
      await backend.email?.prepareReminders(limit);
      const email = await backend.email?.drain(limit);
      const sms = await backend.sms?.drain(limit);
      const counts = {
        considered: 0,
        accepted: 0,
        cancelled: 0,
        failed: 0,
        retried: 0,
        unknown: 0,
      };
      for (const key of Object.keys(counts) as (keyof typeof counts)[]) {
        counts[key] = (email?.[key] ?? 0) + (sms?.[key] ?? 0);
      }
      return { job: request.job, status: 200, body: counts };
    }
    if (request.job === 'driver-secrets')
      return {
        job: request.job,
        status: 200,
        body: { cleared: await purgeExpiredDriverSecrets(backend.pool, limit) },
      };
    if (request.job === 'erasures') {
      const emailAccessPurged = await purgeExpiredEmailAccess(backend.pool, limit);
      const receiptPayloadsCleared =
        (await backend.account.purgeExpiredReceipts(limit)) +
        (await purgeExpiredCommandPayloads(backend.pool, limit));
      const phoneChallengesPurged = await purgeExpiredPhoneOtpChallenges(backend.pool, limit);
      return {
        job: request.job,
        status: 200,
        body: {
          ...(await backend.account.retryErasures(limit)),
          phoneChallengesPurged,
          emailAccessPurged,
        },
        receiptPayloadsCleared,
      };
    }
    if (request.job === 'admission')
      return {
        job: request.job,
        status: 200,
        body: { cleared: await backend.admission.sweep(limit * 10) },
      };
    if (request.job === 'incident-retention')
      return {
        job: request.job,
        status: 200,
        body: await redactExpiredIncidents(backend.pool, backend.maintenanceUserId!, limit),
      };
    if (request.job === 'payment-evidence-retention')
      return {
        job: request.job,
        status: 200,
        body: await redactExpiredPaymentEvidence(
          backend.pool,
          limit,
          request.maxBatches ?? 100,
          request.maxRunMs ?? 45_000,
        ),
      };
    const maxBatches = request.job === 'gps-retention' ? (request.maxBatches ?? 1000) : 1;
    const maxRunMs = request.maxRunMs ?? 45000;
    if (
      !Number.isInteger(maxBatches) ||
      maxBatches < 1 ||
      maxBatches > 10000 ||
      !Number.isInteger(maxRunMs) ||
      maxRunMs < 1 ||
      maxRunMs > 60000
    )
      throw new Error('Invalid maintenance drain budget');
    const started = Date.now();
    let batches = 0;
    const totals = {
      considered: 0,
      succeeded: 0,
      blocked: 0,
      failed: 0,
      failures: [] as { resourceId: string; reason: string }[],
    };
    let result: JobResult;
    do {
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
      result = { job: request.job, status: response.statusCode, body: response.json() };
      batches++;
      const failed = jobFailed(result); // Contract drift fails even when HTTP is 200.
      if (request.job !== 'gps-retention' || response.statusCode !== 200) return result;
      const data = (result.body as { data: typeof totals }).data;
      for (const name of ['considered', 'succeeded', 'blocked', 'failed'] as const)
        totals[name] += data[name];
      totals.failures.push(...data.failures);
      if (failed || data.considered === 0) break;
      // Each request commits independently. A transaction never spans the drain.
    } while (batches < maxBatches && Date.now() - started < maxRunMs);
    const metrics = (
      await backend.pool.query(`WITH expired AS (
      SELECT p.received_at,EXISTS(SELECT 1 FROM app.trace_holds h WHERE h.trip_id=p.trip_id AND h.state='active'
        AND p.received_at>=h.received_from AND p.received_at<h.received_to) AS held
      FROM app.trip_positions p WHERE p.received_at<clock_timestamp()-make_interval(days=>app.trace_retention_days()))
      SELECT count(*)::text AS expired,count(*) FILTER(WHERE held)::text AS held,
        count(*) FILTER(WHERE NOT held)::text AS deletable,min(received_at) FILTER(WHERE NOT held) AS oldest,
        greatest(0,extract(epoch FROM (clock_timestamp()-make_interval(days=>app.trace_retention_days())-
          min(received_at) FILTER(WHERE NOT held))))::double precision AS overdue FROM expired`)
    ).rows[0];
    return {
      job: request.job,
      status: 200,
      body: { data: totals },
      retention: {
        expiredFixes: Number(metrics.expired),
        heldFixes: Number(metrics.held),
        deletableFixes: Number(metrics.deletable),
        oldestDeletableAt: metrics.oldest?.toISOString() ?? null,
        overdueSeconds: Number(metrics.overdue),
        batches,
        elapsedMs: Date.now() - started,
        budgetExhausted:
          Number(metrics.deletable) > 0 &&
          (batches >= maxBatches || Date.now() - started >= maxRunMs),
      },
    };
  } finally {
    await session.release();
  }
}

export async function runJob(backend: Backend, request: JobRequest): Promise<JobResult> {
  // Do not open an un-attributed worker session if the start cannot be saved.
  // A missing outcome exposes an interrupted run rather than pretending it
  // completed. HTTP subcalls use this worker session and do not double-log.
  const audit = backend.maintenanceAudit;
  const runId = await audit.startWorker(backend.maintenanceUserId, request.job);
  let finishAttempted = false;
  try {
    const result = await runJobCore(backend, request);
    const failed = jobFailed(result);
    finishAttempted = true;
    await audit.finish(runId, result.status, result.body, failed);
    return result;
  } catch (error) {
    if (!finishAttempted) await audit.finish(runId, 500, null, true);
    throw error;
  }
}
