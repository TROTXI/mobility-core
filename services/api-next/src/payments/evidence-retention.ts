import type { Pool } from 'pg';

// The purchase association is written once when a provider event is processed.
// Legacy events without a provable association remain encrypted until reviewed.
const eligible = `e.state='processed' AND e.ciphertext IS NOT NULL
  AND e.purchase_id IS NOT NULL
  AND e.processed_at < clock_timestamp()-interval '180 days'
  AND NOT EXISTS (SELECT 1 FROM app.payment_attempts a
                  WHERE a.purchase_id=e.purchase_id AND a.state IN ('pending','unknown'))
  AND NOT EXISTS (SELECT 1 FROM app.payment_reviews r
                  WHERE r.purchase_id=e.purchase_id AND r.state='open')
  AND NOT EXISTS (SELECT 1 FROM app.payment_refunds r
                  WHERE r.purchase_id=e.purchase_id
                    AND r.state IN ('pending','processing','needs_attention'))
  AND NOT EXISTS (SELECT 1 FROM app.refund_initiations i
                  WHERE i.purchase_id=e.purchase_id)
  AND NOT EXISTS (SELECT 1 FROM app.payment_disputes d
                  WHERE d.purchase_id=e.purchase_id AND d.state<>'resolved')`;

/** Remove raw bodies, never financial facts, in bounded and auditable batches. */
export async function redactExpiredPaymentEvidence(
  pool: Pool,
  limit = 100,
  maxBatches = 100,
  maxRunMs = 45_000,
) {
  if (!Number.isInteger(limit) || limit < 1 || limit > 100)
    throw new Error('Payment evidence batch size must be between 1 and 100');
  if (!Number.isInteger(maxBatches) || maxBatches < 1 || maxBatches > 1000)
    throw new Error('Payment evidence batch count must be between 1 and 1000');
  if (!Number.isInteger(maxRunMs) || maxRunMs < 1 || maxRunMs > 60_000)
    throw new Error('Payment evidence run budget must be between 1 and 60000 ms');
  const started = Date.now();
  let redacted = 0;
  let batches = 0;
  while (batches < maxBatches && Date.now() - started < maxRunMs) {
    const c = await pool.connect();
    let count = 0;
    try {
      await c.query("BEGIN; SET LOCAL lock_timeout='3s'; SET LOCAL statement_timeout='10s'");
      const candidates = (
        await c.query<{ id: string; purchase_id: string }>(
          `SELECT e.id,e.purchase_id FROM app.payment_events e WHERE ${eligible}
           ORDER BY e.processed_at,e.id LIMIT $1`,
          [limit],
        )
      ).rows;
      if (candidates.length) {
        const purchases = [...new Set(candidates.map((row) => row.purchase_id))];
        // Case writers take this same row lock in a trigger. The subsequent
        // UPDATE is a new READ COMMITTED statement, so a writer that won the
        // lock first is visible when eligibility is rechecked.
        await c.query(
          'SELECT id FROM app.purchases WHERE id=ANY($1::uuid[]) ORDER BY id FOR UPDATE',
          [purchases],
        );
        const result = await c.query(
          `WITH selected AS (
             SELECT e.id FROM app.payment_events e
             WHERE e.id=ANY($1::uuid[]) AND ${eligible}
             FOR UPDATE OF e SKIP LOCKED
           )
           UPDATE app.payment_events e SET ciphertext=NULL,redacted_at=clock_timestamp()
           FROM selected WHERE e.id=selected.id`,
          [candidates.map((row) => row.id)],
        );
        count = result.rowCount ?? 0;
      }
      await c.query('COMMIT');
      if (!candidates.length) break;
    } catch (error) {
      await c.query('ROLLBACK').catch(() => undefined);
      throw error;
    } finally {
      c.release();
    }
    redacted += count;
    batches++;
  }
  const backlogRemaining = (
    await pool.query<{ remaining: boolean }>(
      `SELECT EXISTS(SELECT 1 FROM app.payment_events e WHERE ${eligible} LIMIT 1) AS remaining`,
    )
  ).rows[0]!.remaining;
  return { redacted, batches, backlogRemaining };
}
