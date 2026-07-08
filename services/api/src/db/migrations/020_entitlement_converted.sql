-- 020_entitlement_converted: allow the 'converted' reason on the entitlement
-- ledger — the debit side of month-end credit conversion (E5). When a period's
-- unused rides convert to Ride Credits (credit_ledger, month_end_conversion),
-- the rides are retired with a negative entitlement entry so they don't carry
-- into the next period. (credit_ledger already permits month_end_conversion.)
ALTER TABLE entitlement_ledger DROP CONSTRAINT IF EXISTS entitlement_ledger_reason_check;
ALTER TABLE entitlement_ledger
  ADD CONSTRAINT entitlement_ledger_reason_check
  CHECK (reason IN ('allocation', 'boarding', 'no_show', 'returned', 'refund', 'converted'));
