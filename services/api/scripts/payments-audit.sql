-- Payment lifecycle audit. Read only: no statement mutates data.
-- Run after migration 044 on staging, then production before live launch.

\echo '== 0. Payment totals =='
SELECT status, count(*) AS payments, sum(amount) AS cash_pesewas
FROM payments
GROUP BY status
ORDER BY status;

\echo '== 0b. Gross, cash and Ride Credit snapshots disagree =='
SELECT reference, gross_amount_pesewas, amount AS cash_pesewas, applied_credit_pesewas
FROM payments
WHERE gross_amount_pesewas <> amount + applied_credit_pesewas;

\echo '== 1a. Legacy duplicate-checkout or broken-renewal candidates =='
-- Before immutable period links, two settled references for one rider could
-- each allocate rides while only one subscription snapshot existed. Restrict
-- this detector to unscoped historical rows: one subscription row is reused by
-- valid renewals now, so comparing all-time payment and subscription counts
-- would create a false positive after every legitimate renewal.
WITH legacy_settlement AS (
  SELECT p.user_id,
         count(DISTINCT p.reference) AS settled_payments,
         count(e.id) FILTER (WHERE e.id IS NOT NULL) AS allocations,
         COALESCE(sum(e.delta_rides), 0) AS rides_allocated
  FROM payments p
  LEFT JOIN entitlement_ledger e
    ON e.ref_type = 'payment'
   AND e.ref_id = p.reference
   AND e.reason = 'allocation'
  WHERE p.purpose = 'subscription'
    AND p.status IN ('paid', 'fulfilled')
    AND p.subscription_period_id IS NULL
  GROUP BY p.user_id
), subscription_snapshot AS (
  SELECT user_id, count(*) AS subscription_rows,
         COALESCE(sum(rides_granted), 0) AS rides_in_snapshots
  FROM subscriptions
  GROUP BY user_id
)
SELECT l.user_id, l.settled_payments,
       COALESCE(s.subscription_rows, 0) AS subscription_rows,
       l.allocations, l.rides_allocated,
       COALESCE(s.rides_in_snapshots, 0) AS rides_in_snapshots
FROM legacy_settlement l
LEFT JOIN subscription_snapshot s ON s.user_id = l.user_id
WHERE l.settled_payments > 1
   OR l.rides_allocated > COALESCE(s.rides_in_snapshots, 0)
ORDER BY l.settled_payments DESC, l.user_id;

\echo '== 1b. Settled subscription references without exactly one allocation =='
SELECT p.reference, p.user_id, p.status, count(e.id) AS allocations,
       COALESCE(sum(e.delta_rides), 0) AS rides_allocated
FROM payments p
LEFT JOIN entitlement_ledger e
  ON e.ref_type = 'payment'
 AND e.ref_id = p.reference
 AND e.reason = 'allocation'
WHERE p.purpose = 'subscription' AND p.status IN ('paid', 'fulfilled')
GROUP BY p.reference, p.user_id, p.status
HAVING count(e.id) <> 1;

\echo '== 2. Value allocated against an unsettled payment =='
SELECT p.reference, p.user_id, p.status, sum(e.delta_rides) AS rides_granted
FROM payments p
JOIN entitlement_ledger e
  ON e.ref_type = 'payment'
 AND e.ref_id = p.reference
 AND e.reason = 'allocation'
WHERE p.status IN ('pending', 'processing', 'failed')
GROUP BY p.reference, p.user_id, p.status;

\echo '== 3. Credit promise, hold and ledger capture disagree =='
SELECT p.reference, p.status, p.applied_credit_pesewas AS promised,
       COALESCE(h.amount_pesewas, 0) AS held,
       COALESCE(-sum(c.delta_pesewas), 0) AS ledger_debit
FROM payments p
LEFT JOIN credit_holds h ON h.payment_id = p.id
LEFT JOIN credit_ledger c
  ON c.ref_type = 'payment'
 AND c.ref_id = p.reference
 AND c.reason = 'renewal_applied'
WHERE p.applied_credit_pesewas > 0
GROUP BY p.reference, p.status, p.applied_credit_pesewas, h.amount_pesewas, h.status
HAVING COALESCE(h.amount_pesewas, 0) <> p.applied_credit_pesewas
    OR (p.status IN ('paid', 'fulfilled', 'refunded', 'disputed')
        AND COALESCE(-sum(c.delta_pesewas), 0) <> p.applied_credit_pesewas)
    OR (p.status IN ('pending', 'processing') AND h.status <> 'held')
    OR (p.status = 'failed' AND h.status <> 'released');

\echo '== 4. Fulfilled payments without an immutable period link =='
SELECT p.reference, p.user_id, p.subscription_id, p.subscription_period_id
FROM payments p
LEFT JOIN subscription_periods sp ON sp.id = p.subscription_period_id
WHERE p.purpose = 'subscription'
  AND p.status IN ('paid', 'fulfilled', 'refunded', 'disputed')
  AND (p.subscription_id IS NULL OR p.subscription_period_id IS NULL OR sp.id IS NULL);

\echo '== 5. Closed periods whose conversion does not match the frozen snapshot =='
SELECT sp.id AS period_id, sp.subscription_id, sp.period_end,
       sp.rides_converted, sp.credit_pesewas_per_ride,
       sp.credit_granted_pesewas,
       COALESCE(sum(c.delta_pesewas), 0) AS ledger_credit
FROM subscription_periods sp
LEFT JOIN credit_ledger c
  ON c.ref_type = 'period'
 AND c.ref_id = sp.id::text
 AND c.reason = 'month_end_conversion'
WHERE sp.status = 'closed'
GROUP BY sp.id
HAVING COALESCE(sp.rides_converted, 0) * COALESCE(sp.credit_pesewas_per_ride, 0)
         <> COALESCE(sp.credit_granted_pesewas, 0)
    OR COALESCE(sum(c.delta_pesewas), 0) <> COALESCE(sp.credit_granted_pesewas, 0);

\echo '== 6. Ended periods awaiting safe close =='
SELECT sp.id AS period_id, sp.subscription_id, sp.status, sp.period_end,
       count(r.id) FILTER (WHERE r.status IN ('pending', 'reserved')) AS unsettled_reservations
FROM subscription_periods sp
LEFT JOIN reservations r ON r.subscription_period_id = sp.id
WHERE sp.status IN ('open', 'frozen') AND sp.period_end <= now()
GROUP BY sp.id
ORDER BY sp.period_end;

\echo '== 7. Orphaned unresolved payments =='
SELECT date_trunc('day', created_at) AS day, status, count(*) AS payments,
       sum(amount) AS cash_pesewas
FROM payments
WHERE status IN ('pending', 'processing')
  AND created_at < now() - interval '1 hour'
GROUP BY 1, 2
ORDER BY 1, 2;

\echo '== 8. Fulfilled payments missing provider settlement identity =='
SELECT reference, status, provider, provider_transaction_id, provider_domain,
       paid_at, fulfilled_at
FROM payments
WHERE status IN ('fulfilled', 'refunded', 'disputed')
  AND (provider_transaction_id IS NULL OR provider_domain IS NULL
       OR paid_at IS NULL OR fulfilled_at IS NULL);

\echo '== 9. Refund and dispute audit trail =='
SELECT p.reference, p.status, p.amount AS cash_pesewas, p.refunded_pesewas,
       count(DISTINCT rf.id) AS refunds, count(DISTINCT d.id) AS disputes
FROM payments p
LEFT JOIN payment_refunds rf ON rf.payment_id = p.id
LEFT JOIN payment_disputes d ON d.payment_id = p.id
WHERE rf.id IS NOT NULL OR d.id IS NOT NULL
GROUP BY p.id
ORDER BY p.updated_at DESC;

\echo '== 10. Open consumed-value reversals requiring operations review =='
SELECT r.id, p.reference, p.user_id, r.consumed_rides,
       r.unrecovered_credit_pesewas, r.estimated_debt_pesewas, r.created_at
FROM payment_reversal_reviews r
JOIN payments p ON p.id = r.payment_id
WHERE r.status = 'open'
ORDER BY r.updated_at DESC;
