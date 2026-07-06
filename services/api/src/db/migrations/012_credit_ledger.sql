-- 012_credit_ledger: a rider's Ride Credit balance (in PESEWAS) as an
-- append-only ledger (ADR-0014). Credits arise from unused rides converted at
-- month end, operator compensation, or loyalty rewards, and reduce a future
-- renewal. Balance = SUM(delta_pesewas). The month-end conversion job that mints
-- credits is E5; this migration is the store.
CREATE TABLE IF NOT EXISTS credit_ledger (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  delta_pesewas   integer NOT NULL,        -- +4000 credit, -4000 applied to renewal
  reason          text NOT NULL CHECK (reason IN ('month_end_conversion', 'compensation', 'loyalty', 'renewal_applied')),
  ref_type        text,
  ref_id          text,
  idempotency_key text NOT NULL UNIQUE,     -- exactly-once writes (retries are no-ops)
  created_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_credit_ledger_user ON credit_ledger (user_id);
