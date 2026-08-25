-- 027_pricing: move the money numbers out of code and into ops-editable rows
-- (#103, ADR-0015).
--
-- Until now the amounts charged to real people lived in TypeScript constants:
--
--   SUBSCRIPTION_FEES_PESEWAS = { monthly: 2000, annual: 20000 }
--   PLACEHOLDER_RIDES_PER_PERIOD = 44
--   PLACEHOLDER_CREDIT_PESEWAS_PER_RIDE = 45
--
-- Every one of those was invented to make the flow buildable, and all three are
-- wired to Paystack. Changing them needs a code review and a deploy, which is
-- what made "decide the prices" feel like an engineering blocker when it never
-- was. Here they are data.
--
-- The model (ADR-0015 §1, §5):
--   rider price     = corridor fare x rides per period x price multiplier
--   operator payout = corridor fare x rides DELIVERED x (1 - take rate)
--   trotxi revenue  = rider price - operator payout
--
-- Rates are stored in BASIS POINTS (10000 = 1.0), never floats. The rest of the
-- money system is integer pesewas for the same reason (ADR-0011): a rate that
-- cannot be represented exactly turns into a rounding argument with an operator
-- about a month of payouts.

-- ---------------------------------------------------------------------------
-- Corridor fares — the regulated input we do not control
-- ---------------------------------------------------------------------------
-- Effective-dated because fares are set by government and the transport unions
-- and move with fuel. A subscription sold in August has to be explainable in
-- October, after the fare has moved twice.
CREATE TABLE IF NOT EXISTS corridor_fares (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id       uuid NOT NULL REFERENCES routes (id) ON DELETE CASCADE,
  fare_pesewas   integer NOT NULL CHECK (fare_pesewas > 0),
  -- Half-open interval [effective_from, effective_to). NULL `to` = in force.
  effective_from timestamptz NOT NULL DEFAULT now(),
  effective_to   timestamptz,
  -- Why the fare moved: a union announcement, a fuel adjustment, a correction.
  note           text,
  created_at     timestamptz NOT NULL DEFAULT now(),
  CHECK (effective_to IS NULL OR effective_to > effective_from)
);

-- Exactly one fare in force per corridor at a time. A partial unique index does
-- what a plain constraint cannot: it lets history pile up while keeping the
-- present unambiguous, so "what is the fare right now" can never return two rows.
CREATE UNIQUE INDEX IF NOT EXISTS idx_corridor_fares_current
  ON corridor_fares (route_id) WHERE effective_to IS NULL;
CREATE INDEX IF NOT EXISTS idx_corridor_fares_route
  ON corridor_fares (route_id, effective_from DESC);

-- ---------------------------------------------------------------------------
-- Plan pricing — the levers that are ours to choose
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS plan_pricing (
  plan                    text PRIMARY KEY CHECK (plan IN ('monthly', 'annual')),
  -- Rides granted per period. Placeholder until the entitlement formula
  -- (working days x 2, holidays, one-way commuters) is decided.
  rides_per_period        integer NOT NULL CHECK (rides_per_period > 0),
  -- What the rider pays relative to spot, in basis points. 10000 = parity.
  -- Deliberately not called a discount: on these corridors the constraint is
  -- supply, not price, so parity or a premium is the expected answer and a
  -- column named discount_percent would insist otherwise (ADR-0015 §4).
  price_multiplier_bp     integer NOT NULL DEFAULT 10000 CHECK (price_multiplier_bp > 0),
  -- Our share of the fare, in basis points. The multiplier sets the top line;
  -- this sets whether anything is left once the vehicle has been paid.
  take_rate_bp            integer NOT NULL CHECK (take_rate_bp BETWEEN 0 AND 10000),
  -- What one unused ride converts to at period end (ADR-0014 Ride Credit).
  credit_pesewas_per_ride integer NOT NULL CHECK (credit_pesewas_per_ride >= 0),
  updated_at              timestamptz NOT NULL DEFAULT now()
);

-- Seeded with the values already in code, so this migration changes storage and
-- not behaviour. They remain placeholders — nobody has approved them — but they
-- are now a row an admin can correct in seconds rather than a constant needing
-- a deploy. take_rate_bp starts at 0: charging an operator a share nobody has
-- agreed would be worse than charging nothing.
INSERT INTO plan_pricing (plan, rides_per_period, price_multiplier_bp, take_rate_bp, credit_pesewas_per_ride)
VALUES ('monthly', 44, 10000, 0, 45),
       ('annual',  528, 10000, 0, 45)
ON CONFLICT (plan) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Snapshots — what the rider actually bought
-- ---------------------------------------------------------------------------
-- Captured on the PAYMENT at checkout, then copied to the subscription when the
-- webhook activates it. Not re-derived at activation: minutes pass between
-- checkout and charge.success, and if a fare moved in that window the rider
-- would be granted rides priced against a fare they never paid. The amount
-- charged is fixed the moment Paystack is called, so everything derived
-- alongside it must be fixed then too.
ALTER TABLE payments
  ADD COLUMN IF NOT EXISTS rides_granted           integer,
  ADD COLUMN IF NOT EXISTS fare_pesewas            integer,
  ADD COLUMN IF NOT EXISTS credit_pesewas_per_ride integer;

-- Frozen at activation so a fare rise cannot change what an active subscriber
-- owes, nor revalue credit they already hold (ADR-0015 §3). New prices apply at
-- renewal, which is why the billing periods in #162 are load-bearing.
--
-- The take rate is deliberately NOT snapshotted: operator payout is earned per
-- ride delivered and uses the rate in force then. Freezing it here would mean a
-- rate renegotiated in March still paying January's terms on April's rides.
ALTER TABLE subscriptions
  ADD COLUMN IF NOT EXISTS price_pesewas           integer,
  ADD COLUMN IF NOT EXISTS rides_granted           integer,
  ADD COLUMN IF NOT EXISTS fare_pesewas            integer,
  ADD COLUMN IF NOT EXISTS credit_pesewas_per_ride integer;

COMMENT ON COLUMN subscriptions.price_pesewas IS
  'What this rider actually paid, frozen at activation. NULL for pre-#103 rows.';
COMMENT ON COLUMN subscriptions.fare_pesewas IS
  'The corridor fare the price was derived from — answers "why did they pay this" after the fare has moved.';
