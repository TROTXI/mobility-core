-- 007_payments: Paystack payment records. A state machine (pending → paid|failed)
-- that is never mutated once paid; `reference` is unique and is both our handle
-- and Paystack's, so duplicate webhooks dedupe on it (system-design §4.2).

CREATE TABLE IF NOT EXISTS payments (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  reference  text NOT NULL UNIQUE,
  plan       text NOT NULL CHECK (plan IN ('monthly', 'annual')),
  amount     integer NOT NULL,                 -- GHS (1 token = 1 GHS)
  currency   text NOT NULL DEFAULT 'GHS',
  status     text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'failed')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_payments_user ON payments (user_id);
