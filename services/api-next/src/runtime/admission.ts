import type { Pool } from 'pg';

/**
 * A request budget every instance of the service shares.
 *
 * The window is aligned to the clock rather than to first contact, so two
 * instances counting the same subject agree on which window they are in
 * without talking to each other. One statement does the whole thing: the
 * upsert either starts a new window at one or adds to the window already
 * open, and returns what the subject has now spent.
 *
 * This costs a round trip on the admission path. That is the price of a limit
 * that survives a second instance, and the adapter boundary is what keeps
 * moving it to a cheaper shared store small.
 */
export function sharedAdmission(pool: Pool, windowSeconds = 60) {
  if (!Number.isInteger(windowSeconds) || windowSeconds < 1 || windowSeconds > 3600)
    throw new Error('Admission window must be between one second and an hour');
  return {
    windowSeconds,
    async spend(subject: string): Promise<{ count: number; resetsInSeconds: number }> {
      const row = (
        await pool.query<{ count: number; resets_in: number }>(
          `WITH bucket AS (
            SELECT to_timestamp(floor(extract(epoch FROM clock_timestamp()) / $2) * $2) AS started
          )
          INSERT INTO app.admission_counters(subject, window_started_at, count)
          SELECT $1, bucket.started, 1 FROM bucket
          ON CONFLICT (subject) DO UPDATE SET
            count = CASE
              WHEN app.admission_counters.window_started_at = EXCLUDED.window_started_at
              THEN app.admission_counters.count + 1 ELSE 1 END,
            window_started_at = EXCLUDED.window_started_at
          RETURNING count,
            ceil(extract(epoch FROM window_started_at + make_interval(secs => $2) - clock_timestamp()))::int AS resets_in`,
          [subject, windowSeconds],
        )
      ).rows[0]!;
      return { count: row.count, resetsInSeconds: Math.max(1, row.resets_in) };
    },
    /**
     * Drop counters whose window is over. The guard refuses a live one, so a
     * sweep cannot hand anybody a fresh budget by running at the wrong moment.
     */
    async sweep(limit = 1000): Promise<number> {
      if (!Number.isInteger(limit) || limit < 1 || limit > 10000)
        throw new Error('Invalid admission sweep limit');
      const done = await pool.query(
        `DELETE FROM app.admission_counters WHERE subject = ANY (
          SELECT subject FROM app.admission_counters
          WHERE window_started_at <= clock_timestamp() - interval '2 minutes'
          ORDER BY window_started_at LIMIT $1 FOR UPDATE SKIP LOCKED)`,
        [limit],
      );
      return done.rowCount ?? 0;
    },
  };
}
export type Admission = ReturnType<typeof sharedAdmission>;
