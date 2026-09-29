import type { Pool } from 'pg';
import type { Actor } from '../transport/service.js';
import { fail } from '../transport/errors.js';

type Counts = { considered: number | null; failed: number | null };

function counts(payload: unknown): Counts {
  const data =
    payload && typeof payload === 'object' && 'data' in payload
      ? (payload as { data: unknown }).data
      : payload;
  if (!data || typeof data !== 'object') return { considered: null, failed: null };
  if ('cleared' in data && Number.isSafeInteger(data.cleared))
    return { considered: data.cleared as number, failed: 0 };
  const values = Object.values(data).filter(
    (value) => value && typeof value === 'object' && !Array.isArray(value),
  );
  const parts = values.length && !('considered' in data) ? values : [data];
  const sum = (key: 'considered' | 'failed') => {
    const found = parts.map((part) => (part as Record<string, unknown>)[key]);
    return found.every((value) => Number.isSafeInteger(value) && (value as number) >= 0)
      ? (found as number[]).reduce((a, b) => a + b, 0)
      : null;
  };
  return { considered: sum('considered'), failed: sum('failed') };
}

/** Records bounded audit facts only; request, provider and rider payloads stay out. */
export class MaintenanceAudit {
  constructor(private readonly pool: Pool) {}

  async startWorker(actorUserId: string, operation: string): Promise<string> {
    const result = await this.pool.query<{ id: string }>(
      `INSERT INTO app.maintenance_run_starts(actor_user_id,operation,origin)
       VALUES ($1,$2,'worker') RETURNING id`,
      [actorUserId, operation],
    );
    return result.rows[0]!.id;
  }

  async startApi(actor: Actor, client: unknown, operation: string): Promise<string | null> {
    const session = await this.pool.query<{ issued_for: string; role: string }>(
      `SELECT s.issued_for,u.role FROM app.auth_sessions s
       JOIN app.users u ON u.id=s.user_id
       WHERE s.id=$1 AND s.user_id=$2 AND s.revoked_at IS NULL
         AND s.expires_at>clock_timestamp() AND u.deleted_at IS NULL`,
      [actor.sessionId, actor.userId],
    );
    const identity = session.rows[0];
    const issuedFor = identity?.issued_for;
    if (!issuedFor) fail(401, 'unauthenticated', 'Sign in to continue.');
    if (identity.role !== 'admin') fail(403, 'forbidden', 'Operations access is required.');
    if (issuedFor === 'maintenance') {
      if (client !== 'worker') fail(403, 'wrong_client', 'Use the maintenance worker client.');
      // The outer worker run covers this routed operation exactly once.
      return null;
    }
    if (client === 'worker') fail(403, 'wrong_client', 'Worker access requires a worker session.');
    const result = await this.pool.query<{ id: string }>(
      `INSERT INTO app.maintenance_run_starts(actor_user_id,operation,origin)
       VALUES ($1,$2,'api') RETURNING id`,
      [actor.userId, operation],
    );
    return result.rows[0]!.id;
  }

  async finish(
    id: string,
    statusCode: number,
    payload: unknown,
    forcedFailure = false,
  ): Promise<void> {
    let decoded: unknown = payload;
    if (typeof payload === 'string') {
      try {
        decoded = JSON.parse(payload);
      } catch {
        decoded = null;
      }
    }
    const { considered, failed } = counts(decoded);
    const state =
      forcedFailure || statusCode >= 300 || (failed ?? 0) > 0
        ? 'failed'
        : considered === 0
          ? 'no_work'
          : 'completed';
    await this.pool.query(
      `INSERT INTO app.maintenance_run_outcomes(run_id,state,status_code,considered_count,failed_count)
       VALUES ($1,$2,$3,$4,$5)`,
      [id, state, statusCode, considered, failed],
    );
  }
}
