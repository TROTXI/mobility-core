import type { Pool } from 'pg';

/**
 * Raw Paystack bodies are not the accounting record. Keep their immutable hash,
 * outcome, references and structured financial effects, but remove the richer
 * encrypted body after 180 days. Quarantined/unprocessed events need review and
 * are deliberately not silently discarded. Open financial work holds all raw
 * events linked to its purchase, not only the event that opened the review.
 */
export async function redactExpiredPaymentEvidence(pool: Pool, limit = 100) {
  if (!Number.isInteger(limit) || limit < 1 || limit > 100)
    throw new Error('Payment evidence batch size must be between 1 and 100');
  const c = await pool.connect();
  try {
    await c.query('BEGIN');
    await c.query("SET LOCAL lock_timeout='3s'");
    await c.query("SET LOCAL statement_timeout='10s'");
    const result = await c.query<{ id: string }>(
      `WITH eligible AS (
        SELECT e.id FROM app.payment_events e
        WHERE e.state='processed' AND e.ciphertext IS NOT NULL
          AND e.processed_at < clock_timestamp()-interval '180 days'
          AND NOT EXISTS (
            SELECT 1 FROM app.payment_reviews direct_review
            WHERE direct_review.event_id=e.id AND direct_review.state='open'
          )
          AND NOT EXISTS (
            SELECT 1 FROM (
              SELECT purchase_id FROM app.payment_collections WHERE event_id=e.id
              UNION SELECT purchase_id FROM app.payment_refunds WHERE event_id=e.id
              UNION SELECT purchase_id FROM app.payment_disputes WHERE event_id=e.id
              UNION SELECT purchase_id FROM app.payment_reviews WHERE event_id=e.id
            ) linked
            WHERE EXISTS (SELECT 1 FROM app.payment_reviews r
                          WHERE r.purchase_id=linked.purchase_id AND r.state='open')
               OR EXISTS (SELECT 1 FROM app.payment_refunds r
                          WHERE r.purchase_id=linked.purchase_id
                            AND r.state IN ('pending','processing','needs_attention'))
               OR EXISTS (SELECT 1 FROM app.payment_disputes d
                          WHERE d.purchase_id=linked.purchase_id AND d.state<>'resolved')
          )
        ORDER BY e.processed_at,e.id LIMIT $1 FOR UPDATE OF e SKIP LOCKED
      )
      UPDATE app.payment_events e SET ciphertext=NULL,redacted_at=clock_timestamp()
      FROM eligible WHERE e.id=eligible.id RETURNING e.id`,
      [limit],
    );
    await c.query('COMMIT');
    return { redacted: result.rowCount ?? 0 };
  } catch (error) {
    await c.query('ROLLBACK').catch(() => undefined);
    throw error;
  } finally {
    c.release();
  }
}
