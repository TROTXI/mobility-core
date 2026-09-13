-- 041_payment_refunds_disputes: add refund accounting and freeze disputed value.
--
-- Some development databases briefly ran a pre-review version of migration 039
-- that already used provider_refund_reference. The conditional conversion keeps
-- those databases recoverable while preserving append-only migration history.

ALTER TABLE credit_ledger DROP CONSTRAINT IF EXISTS credit_ledger_reason_check;
ALTER TABLE credit_ledger
  ADD CONSTRAINT credit_ledger_reason_check
  CHECK (reason IN ('month_end_conversion', 'compensation', 'loyalty', 'renewal_applied', 'refund'));

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
      FROM information_schema.columns
     WHERE table_schema = current_schema()
       AND table_name = 'payment_refunds'
       AND column_name = 'provider_refund_id'
  ) THEN
    ALTER TABLE payment_refunds
      DROP CONSTRAINT IF EXISTS payment_refunds_provider_refund_id_key;
    ALTER TABLE payment_refunds
      RENAME COLUMN provider_refund_id TO provider_refund_reference;
    ALTER TABLE payment_refunds
      ALTER COLUMN provider_refund_reference TYPE text
      USING provider_refund_reference::text;
  END IF;
END $$;

ALTER TABLE payment_refunds
  DROP CONSTRAINT IF EXISTS payment_refunds_payment_id_provider_refund_reference_key;
ALTER TABLE payment_refunds
  ADD CONSTRAINT payment_refunds_payment_id_provider_refund_reference_key
  UNIQUE (payment_id, provider_refund_reference);

CREATE INDEX IF NOT EXISTS idx_reservations_unsettled_period
  ON reservations (subscription_period_id)
  WHERE subscription_period_id IS NOT NULL AND status IN ('pending', 'reserved');

-- A disputed membership is frozen, not made renewable. Keeping it inside the
-- one-current-subscription index prevents a second checkout from bypassing the
-- dispute while Paystack/bank resolution is pending.
ALTER TABLE subscriptions DROP CONSTRAINT IF EXISTS chk_subscriptions_status;
ALTER TABLE subscriptions
  ADD CONSTRAINT chk_subscriptions_status
  CHECK (status IN ('active', 'suspended', 'cancelled', 'expired'));
DROP INDEX IF EXISTS idx_subscriptions_one_active_per_user;
CREATE UNIQUE INDEX IF NOT EXISTS idx_subscriptions_one_current_per_user
  ON subscriptions (user_id)
  WHERE status IN ('active', 'suspended');

ALTER TABLE subscription_periods DROP CONSTRAINT IF EXISTS subscription_periods_status_check;
ALTER TABLE subscription_periods
  ADD CONSTRAINT subscription_periods_status_check
  CHECK (status IN ('open', 'frozen', 'closed', 'reversed'));
DROP INDEX IF EXISTS idx_subscription_periods_one_open;
CREATE UNIQUE INDEX IF NOT EXISTS idx_subscription_periods_one_current
  ON subscription_periods (subscription_id)
  WHERE status IN ('open', 'frozen');
