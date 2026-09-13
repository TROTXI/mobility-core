-- Payment lifecycle audit. Read only: no statement mutates data.
-- Run after migration 039 on staging, then production before live launch.

\echo '== 0. Payment totals =='
SELECT status, count(*) AS payments, sum(amount) AS cash_pesewas
FROM payments
GROUP BY status
ORDER BY status;

\echo '== 1. Settled subscription payments without exactly one allocation =='
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
  AND p.status IN ('fulfilled', 'refunded', 'disputed')
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
