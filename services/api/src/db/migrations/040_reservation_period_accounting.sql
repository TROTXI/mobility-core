-- 040_reservation_period_accounting: attribute seats to their funding period.
--
-- This migration intentionally follows 039 rather than amending it. Production
-- migration history is filename-based, so applied migrations are immutable.

ALTER TABLE reservations
  ADD COLUMN IF NOT EXISTS subscription_period_id uuid
    REFERENCES subscription_periods (id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_reservations_subscription_period
  ON reservations (subscription_period_id)
  WHERE subscription_period_id IS NOT NULL;
