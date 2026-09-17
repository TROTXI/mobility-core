-- Authoritative pricing: what a corridor costs and what a plan grants. Until
-- now the price came from an injected quote adapter, which meant the only real
-- numbers lived in test fixtures. Reviewed 001--015 are unchanged.
--
-- Every figure seeded here is the placeholder the fixtures already used. They
-- are carried over so behaviour does not change with the wiring, not because
-- they are the agreed prices; ops sets the real ones through the endpoints.

CREATE TABLE app.plan_pricing (
  plan text PRIMARY KEY CHECK (plan IN ('monthly', 'annual')),
  rides_per_period integer NOT NULL CHECK (rides_per_period BETWEEN 1 AND 1000),
  price_multiplier_bp integer NOT NULL CHECK (price_multiplier_bp BETWEEN 1 AND 1000000),
  -- Recorded because the reviewed contract carries it. Nothing computes with
  -- it yet: the reviewed price formula is fare x rides x multiplier, and an
  -- operator share belongs to settlement, which is not designed.
  take_rate_bp integer NOT NULL CHECK (take_rate_bp BETWEEN 0 AND 10000),
  credit_per_ride_pesewas integer NOT NULL CHECK (credit_per_ride_pesewas BETWEEN 0 AND 2147483647),
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  CHECK (credit_per_ride_pesewas::bigint * rides_per_period <= 2147483647)
);
INSERT INTO app.plan_pricing(plan, rides_per_period, price_multiplier_bp, take_rate_bp, credit_per_ride_pesewas)
VALUES ('monthly', 44, 10000, 0, 45), ('annual', 44, 10000, 0, 45);
COMMENT ON COLUMN app.plan_pricing.credit_per_ride_pesewas IS
  'Integer pesewas returned per unused ride at period close. A placeholder, not an agreed rate.';
COMMENT ON TABLE app.plan_pricing IS
  'Placeholder figures carried from the existing fixtures, not agreed prices. take_rate_bp is stored for the contract and consumed by nothing; an operator share requires a settlement design that does not exist.';

CREATE FUNCTION app.touch_plan_pricing() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.plan <> OLD.plan OR NEW.created_at <> OLD.created_at THEN
    RAISE EXCEPTION 'immutable_identity' USING ERRCODE = '23514';
  END IF;
  NEW.version := OLD.version + 1;
  NEW.updated_at := clock_timestamp();
  RETURN NEW;
END $$;
CREATE TRIGGER bump_plan_pricing BEFORE UPDATE ON app.plan_pricing
  FOR EACH ROW EXECUTE FUNCTION app.touch_plan_pricing();

-- One fare per corridor at any moment. A new fare closes its predecessor
-- rather than overwriting it, so a purchase can always be read back against
-- the fare that was in force when it was priced.
CREATE TABLE app.route_fares (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id uuid NOT NULL REFERENCES app.routes(id) ON DELETE RESTRICT,
  amount_pesewas integer NOT NULL CHECK (amount_pesewas BETWEEN 1 AND 2147483647),
  effective_from timestamptz NOT NULL CHECK (isfinite(effective_from)),
  effective_to timestamptz CHECK (effective_to IS NULL OR isfinite(effective_to)),
  note text CHECK (note IS NULL OR length(btrim(note)) BETWEEN 1 AND 2000),
  created_by uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  command_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  CHECK (effective_to IS NULL OR effective_to > effective_from),
  EXCLUDE USING gist (route_id WITH =, tstzrange(effective_from, effective_to, '[)') WITH &&)
);
CREATE INDEX route_fares_current ON app.route_fares (route_id, effective_from DESC, id DESC);
COMMENT ON COLUMN app.route_fares.amount_pesewas IS
  'Integer pesewas charged per ride on this corridor while this fare is in force.';
CREATE FUNCTION app.guard_route_fare() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN RAISE EXCEPTION 'append_only_history' USING ERRCODE = '23514'; END IF;
  -- Closing an open fare is the only edit: a fare that has already applied to
  -- a purchase can never be restated.
  IF OLD.effective_to IS NOT NULL
    OR (to_jsonb(NEW) - 'effective_to') IS DISTINCT FROM (to_jsonb(OLD) - 'effective_to')
    OR NEW.effective_to IS NULL THEN
    RAISE EXCEPTION 'immutable_fare' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER protect_route_fare BEFORE UPDATE OR DELETE ON app.route_fares
  FOR EACH ROW EXECUTE FUNCTION app.guard_route_fare();

CREATE TABLE app.pricing_commands (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  operation text NOT NULL CHECK (operation IN ('createFare', 'updatePlanPricing')),
  target text NOT NULL CHECK (length(target) BETWEEN 1 AND 128),
  key_hash text NOT NULL CHECK (key_hash ~ '^[a-f0-9]{64}$'),
  input_hash text NOT NULL CHECK (input_hash ~ '^[a-f0-9]{64}$'),
  resource_id text NOT NULL CHECK (length(resource_id) BETWEEN 1 AND 128),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE (actor_user_id, operation, target, key_hash),
  UNIQUE (id, actor_user_id)
);
CREATE TABLE app.pricing_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  command_id uuid NOT NULL,
  actor_user_id uuid NOT NULL,
  resource_id text NOT NULL CHECK (length(resource_id) BETWEEN 1 AND 128),
  action text NOT NULL CHECK (action IN ('createFare', 'updatePlanPricing')),
  before_state jsonb NOT NULL,
  after_state jsonb NOT NULL,
  occurred_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  FOREIGN KEY (command_id, actor_user_id) REFERENCES app.pricing_commands(id, actor_user_id)
    ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED
);
CREATE TRIGGER immutable_pricing_commands BEFORE UPDATE OR DELETE ON app.pricing_commands
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE TRIGGER immutable_pricing_events BEFORE UPDATE OR DELETE ON app.pricing_events
  FOR EACH ROW EXECUTE FUNCTION app.append_only();

-- Where a rider is sent to pay. The provider is called outside the checkout
-- transaction, so this is written separately and never rewritten: a second
-- initialisation of the same attempt is a conflict, not an overwrite.
CREATE TABLE app.checkout_sessions (
  attempt_id uuid PRIMARY KEY,
  purchase_id uuid NOT NULL,
  user_id uuid NOT NULL,
  authorization_url text NOT NULL CHECK (
    length(authorization_url) BETWEEN 9 AND 480
    AND authorization_url ~ '^https://[^[:space:]]+$'),
  expires_at timestamptz CHECK (expires_at IS NULL OR isfinite(expires_at)),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  FOREIGN KEY (attempt_id, purchase_id, user_id)
    REFERENCES app.payment_attempts(id, purchase_id, user_id) ON DELETE RESTRICT
);
CREATE TRIGGER immutable_checkout_sessions BEFORE UPDATE OR DELETE ON app.checkout_sessions
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
COMMENT ON TABLE app.checkout_sessions IS
  'Provider authorization target for one attempt. Written after the checkout transaction commits, because a network call has no place inside it.';
