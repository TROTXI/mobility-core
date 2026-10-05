import type { PoolClient } from 'pg';

/** Local service expiry is not a claim that Paystack did not collect money.
 * Pending attempts remain reconcilable; a later collection goes to Ops review.
 * Call with the rider lock, before application/purchase locks.
 */
export async function expireUnpaidOffers(c: PoolClient, userId: string, now = new Date()) {
  // An automatic renewal expires like an offer, once the coverage it was
  // buying has begun: a charge that never settled must not hold the slot.
  const rows = (
    await c.query(
      `SELECT p.id,p.renewal_of FROM app.purchases p LEFT JOIN app.standby_offers o ON o.id=p.offer_id
     WHERE p.user_id=$1 AND p.state IN ('awaiting_payment','processing')
       AND (o.expires_at<=$2 OR (p.renewal_of IS NOT NULL
         AND ((p.offer_terms->>'coverageStart')::date::timestamp AT TIME ZONE 'Africa/Accra')<=$2))
     ORDER BY p.id FOR UPDATE OF p`,
      [userId, now],
    )
  ).rows;
  for (const row of rows) {
    await c.query(
      "UPDATE app.credit_holds SET state='released',settled_at=clock_timestamp() WHERE purchase_id=$1 AND state='held'",
      [row.id],
    );
    await c.query(
      "UPDATE app.purchases SET state='failed',failure_code=$2,updated_at=clock_timestamp() WHERE id=$1",
      [row.id, row.renewal_of ? 'renewal_lapsed' : 'offer_expired'],
    );
  }
}
