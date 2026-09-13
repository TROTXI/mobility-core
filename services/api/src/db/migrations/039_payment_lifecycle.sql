-- 039_payment_lifecycle: the accounting spine for subscription payments.
--
-- Additive by design: the currently deployed service may continue writing the
-- legacy `paid` state while the worker/fulfilment code rolls out. Historical
-- payment-to-subscription relationships are not guessed; nullable linkage is
-- more honest than a plausible but wrong financial record.

-- `amount` has been Paystack's smallest unit since the integration landed.
-- Correct the stale 007 comment, which called it GHS and was wrong by 100x.
COMMENT ON COLUMN payments.amount IS
  'Cash requested from Paystack, in pesewas (GHS x 100), after Ride Credit.';

ALTER TABLE payments
  ADD COLUMN IF NOT EXISTS subscription_id uuid REFERENCES subscriptions (id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS provider text NOT NULL DEFAULT 'paystack',
  ADD COLUMN IF NOT EXISTS provider_transaction_id bigint,
  ADD COLUMN IF NOT EXISTS provider_domain text,
  ADD COLUMN IF NOT EXISTS channel text,
  ADD COLUMN IF NOT EXISTS fees_pesewas integer,
  ADD COLUMN IF NOT EXISTS paid_at timestamptz,
  ADD COLUMN IF NOT EXISTS processing_started_at timestamptz,
  ADD COLUMN IF NOT EXISTS fulfilled_at timestamptz,
  ADD COLUMN IF NOT EXISTS failure_code text,
  ADD COLUMN IF NOT EXISTS failure_message text,
  ADD COLUMN IF NOT EXISTS refunded_pesewas integer NOT NULL DEFAULT 0;

ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_status_check;
ALTER TABLE payments
  ADD CONSTRAINT payments_status_check
  CHECK (status IN ('pending', 'processing', 'paid', 'fulfilled', 'failed', 'refunded', 'disputed')),
  ADD CONSTRAINT payments_provider_check CHECK (provider = 'paystack'),
  ADD CONSTRAINT payments_provider_domain_check
    CHECK (provider_domain IS NULL OR provider_domain IN ('test', 'live')),
  ADD CONSTRAINT payments_fees_check CHECK (fees_pesewas IS NULL OR fees_pesewas >= 0),
  ADD CONSTRAINT payments_refunded_check
    CHECK (refunded_pesewas >= 0 AND refunded_pesewas <= amount);

CREATE UNIQUE INDEX IF NOT EXISTS idx_payments_provider_transaction
  ON payments (provider, provider_transaction_id)
  WHERE provider_transaction_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_payments_unresolved
  ON payments (created_at)
  WHERE status IN ('pending', 'processing');
CREATE INDEX IF NOT EXISTS idx_payments_subscription
  ON payments (subscription_id, created_at DESC)
  WHERE subscription_id IS NOT NULL;

-- One immutable row per billing period. `subscriptions` remains the convenient
-- pointer to current membership state; this table is the historical accounting
-- boundary that stops one period's rides being converted at another's rate.
CREATE TABLE IF NOT EXISTS subscription_periods (
  id                       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id          uuid NOT NULL REFERENCES subscriptions (id) ON DELETE CASCADE,
  payment_id               uuid UNIQUE REFERENCES payments (id) ON DELETE SET NULL,
  plan                     text NOT NULL CHECK (plan IN ('monthly', 'annual')),
  route_id                 uuid REFERENCES routes (id) ON DELETE SET NULL,
  pickup_stop_id           uuid REFERENCES stops (id) ON DELETE SET NULL,
  dropoff_stop_id          uuid REFERENCES stops (id) ON DELETE SET NULL,
  period_start             timestamptz NOT NULL,
  period_end               timestamptz NOT NULL,
  price_pesewas            integer,
  cash_pesewas             integer,
  applied_credit_pesewas   integer NOT NULL DEFAULT 0,
  rides_granted            integer,
  fare_pesewas             integer,
  credit_pesewas_per_ride  integer,
  status                   text NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed', 'reversed')),
  rides_converted          integer,
  credit_granted_pesewas   integer,
  closed_at                timestamptz,
  created_at               timestamptz NOT NULL DEFAULT now(),
  CHECK (period_end > period_start),
  CHECK (price_pesewas IS NULL OR price_pesewas >= 0),
  CHECK (cash_pesewas IS NULL OR cash_pesewas >= 0),
  CHECK (applied_credit_pesewas >= 0),
  CHECK (rides_granted IS NULL OR rides_granted >= 0),
  CHECK (fare_pesewas IS NULL OR fare_pesewas > 0),
  CHECK (credit_pesewas_per_ride IS NULL OR credit_pesewas_per_ride >= 0),
  CHECK (rides_converted IS NULL OR rides_converted >= 0),
  CHECK (credit_granted_pesewas IS NULL OR credit_granted_pesewas >= 0),
  UNIQUE (subscription_id, period_start, period_end)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_subscription_periods_one_open
  ON subscription_periods (subscription_id) WHERE status = 'open';
CREATE INDEX IF NOT EXISTS idx_subscription_periods_due
  ON subscription_periods (period_end) WHERE status = 'open';

-- Backfill only facts already present on the subscription. Payment linkage is
-- deliberately left null because payments historically had no subscription id.
INSERT INTO subscription_periods (
  subscription_id, plan, route_id, pickup_stop_id, dropoff_stop_id,
  period_start, period_end, price_pesewas, rides_granted, fare_pesewas,
  credit_pesewas_per_ride, status, closed_at
)
SELECT id, plan, route_id, pickup_stop_id, dropoff_stop_id,
       period_start, period_end, price_pesewas, rides_granted, fare_pesewas,
       credit_pesewas_per_ride,
       CASE WHEN status = 'active' THEN 'open' ELSE 'closed' END,
       CASE WHEN status = 'active' THEN NULL ELSE COALESCE(period_end, created_at) END
  FROM subscriptions
 WHERE period_start IS NOT NULL AND period_end IS NOT NULL
ON CONFLICT (subscription_id, period_start, period_end) DO NOTHING;

ALTER TABLE subscriptions
  ADD COLUMN IF NOT EXISTS current_period_id uuid REFERENCES subscription_periods (id) ON DELETE SET NULL;

UPDATE subscriptions s
   SET current_period_id = p.id
  FROM subscription_periods p
 WHERE p.subscription_id = s.id
   AND p.period_start = s.period_start
   AND p.period_end = s.period_end
   AND s.current_period_id IS NULL;

ALTER TABLE payments
  ADD COLUMN IF NOT EXISTS subscription_period_id uuid
    REFERENCES subscription_periods (id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_payments_subscription_period
  ON payments (subscription_period_id)
  WHERE subscription_period_id IS NOT NULL;

-- Every new entitlement mutation is attributed to the period that funded it.
-- Legacy rows stay null: inferring a period from user + timestamp would turn an
-- auditability gap into fabricated accounting data.
ALTER TABLE entitlement_ledger
  ADD COLUMN IF NOT EXISTS subscription_period_id uuid
    REFERENCES subscription_periods (id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_entitlement_ledger_period
  ON entitlement_ledger (subscription_period_id)
  WHERE subscription_period_id IS NOT NULL;

-- Credit is reserved at checkout and captured only on successful fulfilment.
-- Active holds reduce available balance but do not mutate the append-only
-- ledger, so abandoning or failing a checkout cannot burn rider value.
CREATE TABLE IF NOT EXISTS credit_holds (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id  uuid NOT NULL UNIQUE REFERENCES payments (id) ON DELETE CASCADE,
  user_id     uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  amount_pesewas integer NOT NULL CHECK (amount_pesewas > 0),
  status      text NOT NULL DEFAULT 'held' CHECK (status IN ('held', 'captured', 'released')),
  created_at  timestamptz NOT NULL DEFAULT now(),
  captured_at timestamptz,
  released_at timestamptz
);
CREATE INDEX IF NOT EXISTS idx_credit_holds_available
  ON credit_holds (user_id) WHERE status = 'held';

-- Webhooks are acknowledged after this durable insert. Processing happens from
-- the inbox, so retries and provider bursts never re-run business operations in
-- the request and a crash cannot lose the event.
CREATE TABLE IF NOT EXISTS payment_webhook_events (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  provider        text NOT NULL DEFAULT 'paystack' CHECK (provider = 'paystack'),
  payload_sha256  text NOT NULL UNIQUE,
  event_type      text NOT NULL,
  reference       text,
  raw_body        text NOT NULL,
  payload         jsonb NOT NULL,
  status          text NOT NULL DEFAULT 'received'
                    CHECK (status IN ('received', 'processing', 'processed', 'failed')),
  attempts        integer NOT NULL DEFAULT 0 CHECK (attempts >= 0),
  last_error      text,
  received_at     timestamptz NOT NULL DEFAULT now(),
  processing_at   timestamptz,
  processed_at    timestamptz
);
CREATE INDEX IF NOT EXISTS idx_payment_webhook_events_work
  ON payment_webhook_events (received_at)
  WHERE status IN ('received', 'failed');

CREATE TABLE IF NOT EXISTS payment_refunds (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id          uuid NOT NULL REFERENCES payments (id) ON DELETE RESTRICT,
  provider_refund_id  bigint NOT NULL UNIQUE,
  amount_pesewas      integer NOT NULL CHECK (amount_pesewas > 0),
  status              text NOT NULL
                        CHECK (status IN ('pending', 'processing', 'needs_attention', 'failed', 'processed')),
  payload             jsonb NOT NULL,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  processed_at        timestamptz
);
CREATE INDEX IF NOT EXISTS idx_payment_refunds_payment ON payment_refunds (payment_id);

CREATE TABLE IF NOT EXISTS payment_disputes (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id            uuid NOT NULL REFERENCES payments (id) ON DELETE RESTRICT,
  provider_dispute_id   bigint NOT NULL UNIQUE,
  amount_pesewas        integer NOT NULL CHECK (amount_pesewas > 0),
  status                text NOT NULL CHECK (status IN ('created', 'reminded', 'resolved')),
  resolution            text,
  payload               jsonb NOT NULL,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now(),
  resolved_at           timestamptz
);
CREATE INDEX IF NOT EXISTS idx_payment_disputes_payment ON payment_disputes (payment_id);

COMMENT ON COLUMN payments.provider_transaction_id IS
  'Paystack transaction id; unique with provider and required for independent reconciliation.';
COMMENT ON COLUMN payments.provider_domain IS
  'Paystack environment from the settled transaction: test or live.';
COMMENT ON COLUMN payments.subscription_period_id IS
  'The exact billing period purchased by this payment; set during fulfilment.';
COMMENT ON COLUMN subscriptions.current_period_id IS
  'Pointer to the current period snapshot; history lives in subscription_periods.';
