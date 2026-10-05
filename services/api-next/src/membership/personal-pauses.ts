// Personal pauses: a rider pausing paid coverage for a stretch of days.
import type { PoolClient } from 'pg';
import type { Actor, Body, Outcome } from '../transport/service.js';
import { fail } from '../transport/errors.js';
import { iso, type MembershipCore } from './core.js';

export function personalDate(value: unknown): string {
  if (
    typeof value !== 'string' ||
    !/^(?!0000)\d{4}-\d{2}-\d{2}$/.test(value) ||
    !Number.isFinite(Date.parse(value)) ||
    new Date(value).toISOString().slice(0, 10) !== value
  )
    fail(400, 'invalid_request', 'Supply a real calendar date.');
  return value;
}
export async function personalPauseView(
  m: MembershipCore,
  c: PoolClient,
  pauseId: string,
): Promise<Body> {
  const p = (
    await c.query(
      `SELECT *,to_char(start_date,'YYYY-MM-DD') AS start_day,to_char(resume_date,'YYYY-MM-DD') AS resume_day,
    CASE WHEN state='terminated' THEN 'terminated' WHEN resume_date<=(app.personal_pause_now() AT TIME ZONE 'Africa/Accra')::date THEN 'resumed'
    WHEN start_date<=(app.personal_pause_now() AT TIME ZONE 'Africa/Accra')::date THEN 'paused' ELSE 'scheduled' END AS phase,
    ends_before+make_interval(days=>resume_date-start_date) AS expected_end FROM app.personal_pauses WHERE id=$1`,
      [pauseId],
    )
  ).rows[0];
  return {
    id: p.id,
    startDate: p.start_day,
    resumeDate: p.resume_day,
    status: p.phase,
    projectedEndsAt: p.state === 'terminated' ? null : iso(p.expected_end),
    extensionApplied: p.state === 'completed',
  };
}
export async function insertPersonalPause(
  m: MembershipCore,
  c: PoolClient,
  userId: string,
  input: Body,
) {
  const start = personalDate(input.startDate),
    resume = personalDate(input.resumeDate);
  const b = await m.period(c, userId);
  if ((await c.query('SELECT app.has_pending_renewal($1) AS blocked', [b.id])).rows[0].blocked)
    fail(
      409,
      'renewal_dates_locked',
      'Resolve the upcoming renewal before changing coverage dates.',
    );
  if ((await c.query('SELECT 1 FROM app.personal_pauses WHERE period_id=$1', [b.id])).rowCount)
    fail(409, 'personal_pause_used', 'This paid period already has a personal pause.');
  const cancelled = (
    await c.query(
      `SELECT id FROM app.reservations WHERE period_id=$1 AND service_date>=$2 AND service_date<$3
    AND status IN ('pending','reserved','unseated') ORDER BY service_date,direction`,
      [b.id, start, resume],
    )
  ).rows.map((r) => r.id);
  const row = (
    await c.query(
      `INSERT INTO app.personal_pauses(period_id,user_id,start_date,original_resume_date,resume_date,ends_before)
    VALUES ($1,$2,$3,$4,$4,$5) RETURNING id`,
      [b.id, userId, start, resume, b.effective_ends_at],
    )
  ).rows[0];
  return { id: row.id as string, cancelled };
}
export async function previewPersonalPause(
  m: MembershipCore,
  actor: Actor,
  input: Body,
): Promise<Outcome> {
  return m.tx(async (c) => {
    await m.lockUser(c, actor.userId);
    await m.authorize(c, actor, 'previewPersonalPause');
    // Validate through the exact database rules without keeping a pause,
    // cancellation, version increment or command. No provider calls occur.
    await c.query('SAVEPOINT preview');
    const created = await insertPersonalPause(m, c, actor.userId, input);
    const view = await personalPauseView(m, c, created.id);
    await c.query('ROLLBACK TO SAVEPOINT preview');
    return {
      status: 200,
      headers: {},
      body: {
        data: {
          startDate: view.startDate!,
          resumeDate: view.resumeDate!,
          projectedEndsAt: view.projectedEndsAt!,
          cancelledReservationIds: created.cancelled,
        },
      },
    };
  });
}
export async function resumeDuePersonalPauses(
  m: MembershipCore,
  actor: Actor,
  limit = 100,
): Promise<Outcome> {
  if (!Number.isInteger(limit) || limit < 1 || limit > 100)
    fail(400, 'invalid_request', 'Invalid batch limit.');
  const rows = await m.tx(async (c) => {
    await m.authorize(c, actor, 'runPersonalPauseResumes');
    return (
      await c.query(
        `SELECT id,user_id FROM app.personal_pauses WHERE state='planned'
      AND resume_date<=(app.personal_pause_now() AT TIME ZONE 'Africa/Accra')::date ORDER BY resume_date,id LIMIT $1`,
        [limit],
      )
    ).rows;
  });
  const result = {
    considered: rows.length,
    succeeded: 0,
    blocked: 0,
    failed: 0,
    failures: [] as { resourceId: string; reason: string }[],
  };
  for (const row of rows)
    try {
      const n = await m.tx(async (c) => {
        await m.lockUser(c, row.user_id);
        await m.authorize(c, actor, 'runPersonalPauseResumes');
        return Number(
          (await c.query('SELECT app.settle_personal_pauses($1) n', [row.user_id])).rows[0].n,
        );
      });
      if (n) result.succeeded++;
      else result.blocked++;
    } catch {
      result.failed++;
      result.failures.push({ resourceId: row.id, reason: 'personal_resume_failed' });
    }
  return { status: 200, headers: {}, body: { data: result } };
}

export async function resumePersonalPause(
  m: MembershipCore,
  c: PoolClient,
  actor: Actor,
  target: string,
  input: Body,
): Promise<string> {
  await m.period(c, actor.userId);
  const resumeDate = personalDate(input.resumeDate);
  const row = (
    await c.query(
      `UPDATE app.personal_pauses SET resume_date=$3 WHERE id=$1 AND user_id=$2
    AND state='planned' AND resume_date>$3 RETURNING id`,
      [target, actor.userId, resumeDate],
    )
  ).rows[0];
  if (!row) fail(409, 'personal_resume_not_allowed', 'Choose an earlier future service day.');
  return row.id;
}

export async function getPersonalPause(
  m: MembershipCore,
  c: PoolClient,
  actor: Actor,
): Promise<Outcome> {
  await c.query('SELECT app.settle_personal_pauses($1)', [actor.userId]);
  const row = (
    await c.query(
      'SELECT id FROM app.personal_pauses WHERE user_id=$1 ORDER BY created_at DESC,id DESC LIMIT 1',
      [actor.userId],
    )
  ).rows[0];
  return {
    status: 200,
    headers: {},
    body: { data: row ? await personalPauseView(m, c, row.id) : null },
  } as Outcome;
}
