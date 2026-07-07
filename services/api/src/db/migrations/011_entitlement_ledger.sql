-- 011_entitlement_ledger: a rider's ride entitlement as an append-only ledger
-- (ADR-0014, Hybrid Subscription Model). Remaining rides = SUM(delta_rides),
-- never a mutable column. A subscription activation allocates rides (+); a
-- boarding or confirmed no-show consumes one (-); an operator cancellation
-- returns one (+). Every change is one immutable, idempotent row.
CREATE TABLE IF NOT EXISTS entitlement_ledger (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  delta_rides     integer NOT NULL,        -- +44 allocation, -1 boarding/no_show
  reason          text NOT NULL CHECK (reason IN ('allocation', 'boarding', 'no_show', 'returned', 'refund')),
  ref_type        text,                    -- 'payment' | 'reservation' (no FK yet)
  ref_id          text,
  idempotency_key text NOT NULL UNIQUE,     -- exactly-once writes (retries are no-ops)
  created_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_entitlement_ledger_user ON entitlement_ledger (user_id);
