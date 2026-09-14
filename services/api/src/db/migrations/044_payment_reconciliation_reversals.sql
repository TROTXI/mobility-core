-- 044_payment_reconciliation_reversals: close the remaining reconciliation
-- and reversal audit gaps without rewriting earlier migrations.

ALTER TABLE payments
  ADD COLUMN IF NOT EXISTS gross_amount_pesewas integer;

UPDATE payments
   SET gross_amount_pesewas = amount + applied_credit_pesewas
 WHERE gross_amount_pesewas IS NULL;

ALTER TABLE payments
  ALTER COLUMN gross_amount_pesewas SET NOT NULL,
  ADD CONSTRAINT payments_gross_amount_check
    CHECK (
      gross_amount_pesewas >= amount
      AND gross_amount_pesewas = amount + applied_credit_pesewas
    );

-- A processed full cash refund restores unused rides and Ride Credit. If rides
-- were already consumed, the append-only entitlement ledger must not go
-- negative; instead, record the consumed value for explicit operations review.
CREATE TABLE payment_reversal_reviews (
  id                       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id               uuid NOT NULL REFERENCES payments (id) ON DELETE RESTRICT,
  subscription_period_id   uuid REFERENCES subscription_periods (id) ON DELETE SET NULL,
  reason                   text NOT NULL
    CHECK (reason IN ('consumed_value_after_refund')),
  status                   text NOT NULL DEFAULT 'open'
    CHECK (status IN ('open', 'resolved')),
  consumed_rides           integer NOT NULL CHECK (consumed_rides >= 0),
  unrecovered_credit_pesewas integer NOT NULL DEFAULT 0
    CHECK (unrecovered_credit_pesewas >= 0),
  estimated_debt_pesewas   integer NOT NULL CHECK (estimated_debt_pesewas > 0),
  resolution_note          text,
  created_at               timestamptz NOT NULL DEFAULT now(),
  updated_at               timestamptz NOT NULL DEFAULT now(),
  resolved_at              timestamptz,
  UNIQUE (payment_id, reason),
  CHECK (consumed_rides > 0 OR unrecovered_credit_pesewas > 0)
);

CREATE INDEX idx_payment_reversal_reviews_open
  ON payment_reversal_reviews (updated_at DESC) WHERE status = 'open';

-- Every financial column states its unit at the database boundary. This is
-- deliberately exhaustive: ambiguous money columns are a 100x accounting risk.
COMMENT ON COLUMN payments.amount IS 'Cash requested from Paystack, in pesewas (GHS x 100), after Ride Credit.';
COMMENT ON COLUMN payments.gross_amount_pesewas IS 'Full checkout price in pesewas before Ride Credit.';
COMMENT ON COLUMN payments.applied_credit_pesewas IS 'Ride Credit applied to checkout, in pesewas.';
COMMENT ON COLUMN payments.fare_pesewas IS 'Frozen corridor fare in pesewas.';
COMMENT ON COLUMN payments.credit_pesewas_per_ride IS 'Frozen conversion value per unused ride, in pesewas.';
COMMENT ON COLUMN payments.fees_pesewas IS 'Provider fee in pesewas.';
COMMENT ON COLUMN payments.refunded_pesewas IS 'Processed cash refunds in pesewas.';
COMMENT ON COLUMN subscription_periods.price_pesewas IS 'Full period price in pesewas before Ride Credit.';
COMMENT ON COLUMN subscription_periods.cash_pesewas IS 'Cash paid for the period, in pesewas.';
COMMENT ON COLUMN subscription_periods.applied_credit_pesewas IS 'Ride Credit applied to the period, in pesewas.';
COMMENT ON COLUMN subscription_periods.fare_pesewas IS 'Frozen corridor fare in pesewas.';
COMMENT ON COLUMN subscription_periods.credit_pesewas_per_ride IS 'Frozen conversion value per unused ride, in pesewas.';
COMMENT ON COLUMN subscription_periods.credit_granted_pesewas IS 'Ride Credit granted at period close, in pesewas.';
COMMENT ON COLUMN credit_holds.amount_pesewas IS 'Ride Credit reserved during checkout, in pesewas.';
COMMENT ON COLUMN payment_refunds.amount_pesewas IS 'Provider refund amount in pesewas.';
COMMENT ON COLUMN payment_disputes.amount_pesewas IS 'Provider dispute amount in pesewas.';
COMMENT ON COLUMN payment_reversal_reviews.estimated_debt_pesewas IS 'Estimated consumed value requiring operations review, in pesewas.';
COMMENT ON COLUMN payment_reversal_reviews.unrecovered_credit_pesewas IS 'Month-end conversion credit not recoverable at refund time, in pesewas.';
