import type { PoolClient } from 'pg';
import type { Backend } from './compose.js';
import { runJob, type JobRequest, type JobResult } from './maintenance.js';
import { jobFailed } from './job-outcome.js';
import { scheduledGroups, schedulerDelay } from './job-schedule.js';

const LOCK = 'trotxi:maintenance-scheduler:v1';
const BATCH_LIMIT = 100;
const MAX_PASSES = 10;
const PASS_BUDGET_MS = 45_000;

type Run = (request: JobRequest) => Promise<JobResult>;
type Summary = { full: boolean; progress: number };

/** Work which can still fill another batch, not merely HTTP success. */
export function batchProgress(result: JobResult): Summary {
  const body = result.body as Record<string, any>;
  const data = (body.data ?? body) as Record<string, any>;
  if (result.job === 'payments') {
    const parts = ['inbox', 'reconciliation', 'periods'].map((key) => data[key]);
    return {
      full: parts.some((part) => part.considered >= BATCH_LIMIT),
      progress: parts.reduce((sum, part) => sum + part.succeeded, 0),
    };
  }
  if (result.job === 'gps-retention')
    return { full: (result.retention?.deletableFixes ?? 0) > 0, progress: data.succeeded };
  if (result.job === 'incident-retention')
    return { full: data.remainingEligible > 0, progress: data.redacted };
  if (result.job === 'payment-evidence-retention')
    return { full: data.backlogRemaining, progress: data.redacted };
  if (result.job === 'admission' || result.job === 'driver-secrets')
    return {
      full: data.cleared >= (result.job === 'admission' ? 1000 : 100),
      progress: data.cleared,
    };
  if (result.job === 'erasures') {
    const counts = [
      data.considered,
      data.phoneChallengesPurged,
      data.emailAccessPurged.expired,
      data.emailAccessPurged.pending,
    ];
    return {
      full:
        counts.some((count) => count >= BATCH_LIMIT) ||
        (result.receiptPayloadsCleared ?? 0) >= BATCH_LIMIT,
      progress:
        data.completed +
        data.phoneChallengesPurged +
        data.emailAccessPurged.expired +
        data.emailAccessPurged.pending +
        (result.receiptPayloadsCleared ?? 0),
    };
  }
  // Route learning marks every non-failed trace as processed, including traces
  // that teach no segments. Those blocked items leave the candidate query.
  // Other jobs can keep blocked items eligible, so do not count them globally.
  if (result.job === 'route-learning')
    return { full: data.considered >= BATCH_LIMIT, progress: data.succeeded + data.blocked };
  return {
    full: data.considered >= BATCH_LIMIT,
    progress: data.succeeded ?? (data.accepted ?? 0) + (data.cancelled ?? 0),
  };
}

export async function drainScheduledJob(
  request: JobRequest,
  run: Run,
  stopped: () => boolean,
  clock = Date.now,
): Promise<void> {
  const start = clock();
  for (let pass = 0; pass < MAX_PASSES; pass++) {
    if (stopped()) throw new Error('scheduler_stopped');
    // Service-day acquisition must never run with a date that became yesterday
    // while a slow provider held up the preceding group.
    if (
      (request.job === 'ask-dispatch' || request.job === 'reservation-defaults') &&
      request.travelDate! < new Date(clock()).toISOString().slice(0, 10)
    )
      throw new Error('scheduler_service_day_expired');
    const result = await run({ ...request, limit: BATCH_LIMIT });
    if (result.status < 200 || result.status >= 300) throw new Error('scheduler_job_failed');
    const failed = jobFailed(result); // Validate the response before reading counts.
    const progress = batchProgress(result);
    // Retention helpers deliberately flag a remaining backlog. Continue it
    // only when actual deletion/redaction made progress within this budget.
    const retentionBacklog = [
      'incident-retention',
      'payment-evidence-retention',
      'gps-retention',
    ].includes(request.job);
    const data = ((result.body as any).data ?? result.body) as any;
    const realFailure =
      result.status !== 200 || (data.failed ?? 0) > 0 || (data.failures?.length ?? 0) > 0;
    if (failed && !(retentionBacklog && progress.full && progress.progress > 0 && !realFailure))
      throw new Error('scheduler_job_failed');
    if (!progress.full) return;
    // A full blocked batch must not spin forever or be reported as drained.
    if (progress.progress === 0 || clock() - start >= PASS_BUDGET_MS)
      throw new Error('scheduler_backlog_remaining');
  }
  throw new Error('scheduler_backlog_remaining');
}

/** Read only at startup. Never use a human operator's account for automation. */
export async function validateScheduler(backend: Backend): Promise<void> {
  if (!backend.push || (!backend.email && !backend.sms))
    throw new Error('scheduler_requires_push_and_messaging');
  const result = await backend.pool.query(
    `SELECT u.id FROM app.users u WHERE u.id=$1 AND u.role='admin' AND u.deleted_at IS NULL
     AND u.email IS NULL AND u.phone IS NULL
     AND NOT EXISTS(SELECT 1 FROM app.auth_identities i WHERE i.user_id=u.id)
     AND NOT EXISTS(SELECT 1 FROM app.drivers d WHERE d.user_id=u.id)
     AND NOT EXISTS(SELECT 1 FROM app.auth_sessions s WHERE s.user_id=u.id AND s.issued_for='interactive')`,
    [backend.maintenanceUserId],
  );
  if (result.rowCount !== 1) throw new Error('scheduler_requires_service_identity');
}

/** One elected API replica runs bounded work. No externally callable endpoint. */
export class MaintenanceScheduler {
  private timer?: ReturnType<typeof setTimeout>;
  private running?: Promise<void>;
  private stopped = false;
  private started = false;
  constructor(
    private readonly backend: Backend,
    private readonly log: (event: Record<string, unknown>) => void,
    private readonly run: Run = (request) => runJob(backend, request),
    private readonly clock: () => number = Date.now,
  ) {}

  start() {
    if (this.started || this.stopped) return;
    this.started = true;
    this.schedule();
  }
  private schedule() {
    if (this.stopped) return;
    this.timer = setTimeout(() => {
      this.running = this.tick().catch(() =>
        this.log({ scheduler: 'failed', reason: 'tick_failed' }),
      );
      void this.running.finally(() => {
        this.running = undefined;
        this.schedule();
      });
    }, schedulerDelay());
    this.timer.unref();
  }
  async stop() {
    this.stopped = true;
    clearTimeout(this.timer);
    await this.running;
  }

  async tick(now = new Date()): Promise<void> {
    if (this.stopped) return;
    const connection = await this.backend.pool.connect();
    let lost = false;
    const onError = () => {
      lost = true;
    };
    connection.on('error', onError);
    let acquired = false;
    try {
      acquired = (
        await connection.query('SELECT pg_try_advisory_lock(hashtextextended($1,0)) AS acquired', [
          LOCK,
        ])
      ).rows[0].acquired;
      if (!acquired) return;
      for (const group of scheduledGroups(now)) {
        if (this.stopped || lost) break;
        if (!(await this.due(connection, group.key, now))) continue;
        const runId = await this.backend.maintenanceAudit.startWorker(
          this.backend.maintenanceUserId,
          group.key,
        );
        let failed = false;
        for (const request of group.jobs) {
          if (this.stopped || lost) {
            failed = true;
            break;
          }
          try {
            await drainScheduledJob(request, this.run, () => this.stopped || lost, this.clock);
          } catch {
            failed = true;
            // Never log provider payloads, user identifiers or raw exceptions.
            this.log({ scheduler: group.name, job: request.job, status: 'failed_or_backlogged' });
          }
        }
        await this.backend.maintenanceAudit.finish(
          runId,
          failed ? 503 : 200,
          { considered: group.jobs.length, failed: failed ? 1 : 0 },
          failed,
        );
        this.log({ scheduler: group.name, status: failed ? 'failed' : 'completed' });
      }
    } catch (error) {
      // An interrupted query may have acquired the session lock on the server.
      // Never return an uncertain connection to the pool.
      lost = true;
      throw error;
    } finally {
      if (acquired && !lost) {
        try {
          await connection.query('SELECT pg_advisory_unlock(hashtextextended($1,0))', [LOCK]);
        } catch {
          lost = true;
        }
      }
      connection.removeListener('error', onError);
      connection.release(lost);
    }
  }

  private async due(connection: PoolClient, key: string, now: Date): Promise<boolean> {
    const row = (
      await connection.query(
        `SELECT s.started_at,o.state FROM app.maintenance_run_starts s
       LEFT JOIN app.maintenance_run_outcomes o ON o.run_id=s.id
       WHERE s.operation=$1 AND s.origin='worker' AND s.started_at >= $2::timestamptz-interval '2 days'
       ORDER BY s.started_at DESC,s.id DESC LIMIT 1`,
        [key, now],
      )
    ).rows[0];
    if (!row) return true;
    if (row.state === 'completed' || row.state === 'no_work') return false;
    // Interrupted and failed daily runs can retry, without a tight retry loop.
    return now.getTime() - new Date(row.started_at).getTime() >= 5 * 60_000;
  }
}
