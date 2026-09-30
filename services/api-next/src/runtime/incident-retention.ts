import type { Pool } from 'pg';

export interface IncidentRetentionResult {
  considered: number;
  redacted: number;
  held: number;
  remainingEligible: number;
  oldestEligibleAt: string | null;
}

/**
 * One transaction and at most `limit` incident rows per run. A hold takes a
 * SHARE lock on the incident, so it cannot appear between our eligibility
 * check and the one-way redaction. The database trigger repeats the policy.
 */
export async function redactExpiredIncidents(
  pool: Pool,
  actorUserId: string,
  limit = 100,
): Promise<IncidentRetentionResult> {
  if (!Number.isInteger(limit) || limit < 1 || limit > 100)
    throw new Error('Invalid incident retention batch size');
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const due = `i.status='resolved' AND i.redacted_at IS NULL
      AND i.handled_at+make_interval(days=>app.incident_retention_days(i.category))<=clock_timestamp()`;
    const activeHold = `EXISTS(SELECT 1 FROM app.trace_holds h
      WHERE h.incident_id=i.id AND h.state='active')`;
    const rows = (
      await client.query(
        `SELECT i.id,i.category FROM app.driver_incidents i WHERE ${due}
        AND NOT ${activeHold}
        ORDER BY i.handled_at,i.id LIMIT $1 FOR UPDATE OF i SKIP LOCKED`,
        [limit],
      )
    ).rows;
    for (const row of rows) {
      await client.query(
        `UPDATE app.driver_incidents SET driver_id=NULL,trip_id=NULL,vehicle_id=NULL,
          note=NULL,latitude=NULL,longitude=NULL,resolution=NULL,handled_by=NULL,
          redacted_at=clock_timestamp(),updated_at=clock_timestamp(),version=version+1
        WHERE id=$1`,
        [row.id],
      );
      // The redacted row now permits this narrowly scoped early receipt purge.
      // Everything commits together, so no caller can observe an intermediate.
      await client.query(
        `UPDATE app.transport_commands c SET response_body=NULL,response_headers=NULL
        WHERE c.response_body IS NOT NULL
          AND (EXISTS(SELECT 1 FROM app.fleet_events e
            WHERE e.incident_id=$1 AND e.command_id=c.id)
            OR EXISTS(SELECT 1 FROM app.gps_events e JOIN app.trace_holds h ON h.id=e.hold_id
              WHERE h.incident_id=$1 AND e.command_id=c.id))`,
        [row.id],
      );
      await client.query(
        `UPDATE app.trace_holds SET incident_id=NULL,reason='Redacted after release',
          release_reason='Redacted after release',updated_at=clock_timestamp(),version=version+1
        WHERE incident_id=$1 AND state='released'`,
        [row.id],
      );
      await client.query(
        `INSERT INTO app.incident_redactions(incident_id,actor_user_id,category)
        VALUES ($1,$2,$3)`,
        [row.id, actorUserId, row.category],
      );
    }
    const stats = (
      await client.query(
        `SELECT
          count(*) FILTER (WHERE ${activeHold})::int AS held,
          count(*) FILTER (WHERE NOT ${activeHold})::int AS eligible,
          min(i.handled_at+make_interval(days=>app.incident_retention_days(i.category)))
            FILTER (WHERE NOT ${activeHold}) AS oldest
        FROM app.driver_incidents i WHERE ${due}`,
      )
    ).rows[0];
    await client.query('COMMIT');
    return {
      considered: rows.length,
      redacted: rows.length,
      held: stats.held,
      remainingEligible: stats.eligible,
      oldestEligibleAt: stats.oldest?.toISOString() ?? null,
    };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}
