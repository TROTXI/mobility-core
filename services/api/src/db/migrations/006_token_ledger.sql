-- 006_token_ledger: the rider's GHS wallet as an append-only ledger.
-- Balance is SUM(delta), never a mutable column (system-design §4.1). Tokens are
-- pegged 1:1 to GHS. Every grant (+) and spend (-) is one immutable row.

CREATE TABLE IF NOT EXISTS token_ledger (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  delta           integer NOT NULL,        -- GHS-denominated: +250 grant, -3 fare
  reason          text NOT NULL CHECK (reason IN ('subscription_grant', 'boarding', 'refund')),
  ref_type        text NOT NULL CHECK (ref_type IN ('payment', 'boarding')),
  ref_id          uuid,
  idempotency_key text NOT NULL UNIQUE,     -- exactly-once writes (retries are no-ops)
  created_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_token_ledger_user ON token_ledger (user_id);
