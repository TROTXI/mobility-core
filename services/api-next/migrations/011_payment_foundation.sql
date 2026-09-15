-- Financial foundation after 010. No provider or HTTP composition is enabled.
-- Reviewed draft is promoted byte-for-byte; applied migration history is immutable.
CREATE TABLE app.memberships (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 user_id uuid NOT NULL UNIQUE REFERENCES app.users(id) ON DELETE RESTRICT,
 lifecycle text NOT NULL DEFAULT 'open' CHECK(lifecycle IN ('open','ended')),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 ended_at timestamptz,
 UNIQUE(id,user_id),
 CHECK((lifecycle='open' AND ended_at IS NULL) OR (lifecycle='ended' AND ended_at IS NOT NULL))
);
CREATE TABLE app.purchases (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 membership_id uuid NOT NULL,
 user_id uuid NOT NULL,
 route_id uuid NOT NULL REFERENCES app.routes(id) ON DELETE RESTRICT,
 plan text NOT NULL CHECK(plan IN ('monthly','annual')),
 state text NOT NULL DEFAULT 'awaiting_payment' CHECK(state IN ('awaiting_payment','processing','fulfilled','failed','cancelled','review_required')),
 price_pesewas integer NOT NULL CHECK(price_pesewas>=100),
 applied_credit_pesewas integer NOT NULL CHECK(applied_credit_pesewas>=0),
 cash_due_pesewas integer NOT NULL CHECK(cash_due_pesewas>=100),
 currency text NOT NULL CHECK(currency='GHS'),
 rides_granted integer NOT NULL CHECK(rides_granted>0),
 fare_pesewas integer NOT NULL CHECK(fare_pesewas>0),
 price_multiplier_bp integer NOT NULL CHECK(price_multiplier_bp>0),
 conversion_rate_pesewas integer NOT NULL CHECK(conversion_rate_pesewas>=0),
 checkout_key_hash text NOT NULL CHECK(checkout_key_hash ~ '^[a-f0-9]{64}$'),
 input_hash text NOT NULL CHECK(input_hash ~ '^[a-f0-9]{64}$'),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 failure_code text,
 FOREIGN KEY(membership_id,user_id) REFERENCES app.memberships(id,user_id) ON DELETE RESTRICT,
 UNIQUE(id,membership_id,user_id), UNIQUE(id,user_id), UNIQUE(user_id,checkout_key_hash),
 CHECK(price_pesewas::bigint=applied_credit_pesewas::bigint+cash_due_pesewas::bigint),
 CHECK(price_pesewas::numeric=floor((fare_pesewas::numeric*rides_granted*price_multiplier_bp+5000)/10000)),
 CHECK(conversion_rate_pesewas::bigint*rides_granted<=2147483647)
);
CREATE UNIQUE INDEX one_unresolved_purchase_per_rider ON app.purchases(user_id)
 WHERE state IN ('awaiting_payment','processing','review_required');
CREATE TABLE app.purchase_legs (
 purchase_id uuid NOT NULL REFERENCES app.purchases(id) ON DELETE RESTRICT,
 direction text NOT NULL CHECK(direction IN ('outbound','return')),
 schedule_id uuid NOT NULL,
 pattern_version_id uuid NOT NULL,
 pickup_occurrence_id uuid NOT NULL,
 dropoff_occurrence_id uuid NOT NULL,
 PRIMARY KEY(purchase_id,direction),
 FOREIGN KEY(schedule_id,pattern_version_id) REFERENCES app.service_schedules(id,pattern_version_id) ON DELETE RESTRICT,
 FOREIGN KEY(pickup_occurrence_id,pattern_version_id) REFERENCES app.route_pattern_stops(id,pattern_version_id) ON DELETE RESTRICT,
 FOREIGN KEY(dropoff_occurrence_id,pattern_version_id) REFERENCES app.route_pattern_stops(id,pattern_version_id) ON DELETE RESTRICT,
 CHECK(pickup_occurrence_id<>dropoff_occurrence_id)
);
CREATE TABLE app.payment_attempts (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 purchase_id uuid NOT NULL,
 user_id uuid NOT NULL,
 provider text NOT NULL CHECK(provider='paystack'),
 environment text NOT NULL CHECK(environment IN ('test','live')),
 reference text NOT NULL CHECK(length(reference) BETWEEN 1 AND 100),
 state text NOT NULL DEFAULT 'pending' CHECK(state IN ('pending','unknown','successful','failed')),
 amount_pesewas integer NOT NULL CHECK(amount_pesewas>=100),
 currency text NOT NULL CHECK(currency='GHS'),
 provider_transaction_id text,
 channel text,
 fees_pesewas integer CHECK(fees_pesewas>=0),
 paid_at timestamptz,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 FOREIGN KEY(purchase_id,user_id) REFERENCES app.purchases(id,user_id) ON DELETE RESTRICT,
 UNIQUE(id,purchase_id,user_id),
 UNIQUE(provider,environment,reference), UNIQUE(provider,environment,provider_transaction_id),
 CHECK((state='successful' AND provider_transaction_id IS NOT NULL AND length(provider_transaction_id)>0 AND paid_at IS NOT NULL)
   OR (state<>'successful' AND provider_transaction_id IS NULL AND paid_at IS NULL)),
 CHECK(paid_at IS NULL OR isfinite(paid_at))
);
CREATE UNIQUE INDEX one_unresolved_attempt_per_purchase ON app.payment_attempts(purchase_id) WHERE state IN ('pending','unknown');
CREATE TABLE app.billing_periods (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 purchase_id uuid NOT NULL UNIQUE,
 membership_id uuid NOT NULL,
 user_id uuid NOT NULL,
 starts_at timestamptz NOT NULL CHECK(isfinite(starts_at)),
 original_ends_at timestamptz NOT NULL CHECK(isfinite(original_ends_at)),
 effective_ends_at timestamptz NOT NULL CHECK(isfinite(effective_ends_at)),
 state text NOT NULL DEFAULT 'open' CHECK(state IN ('open','closed','reversed')),
 FOREIGN KEY(purchase_id,membership_id,user_id) REFERENCES app.purchases(id,membership_id,user_id) ON DELETE RESTRICT,
 UNIQUE(id,user_id), UNIQUE(id,purchase_id,user_id),
 CHECK(original_ends_at>starts_at AND effective_ends_at>=original_ends_at),
 EXCLUDE USING gist (membership_id WITH =,tstzrange(starts_at,effective_ends_at,'[)') WITH &&)
   WHERE(state<>'reversed') DEFERRABLE INITIALLY DEFERRED
);
CREATE UNIQUE INDEX one_open_period_per_membership ON app.billing_periods(membership_id) WHERE state='open';
CREATE TABLE app.credit_adjustments (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
 actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
 delta_pesewas integer NOT NULL CHECK(delta_pesewas<>0),
 reason text NOT NULL CHECK(length(btrim(reason)) BETWEEN 1 AND 2000),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 UNIQUE(id,user_id)
);
CREATE TABLE app.credit_holds (
 purchase_id uuid PRIMARY KEY,
 user_id uuid NOT NULL,
 amount_pesewas integer NOT NULL CHECK(amount_pesewas>0),
 state text NOT NULL DEFAULT 'held' CHECK(state IN ('held','captured','released')),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 settled_at timestamptz,
 FOREIGN KEY(purchase_id,user_id) REFERENCES app.purchases(id,user_id) ON DELETE RESTRICT,
 UNIQUE(purchase_id,user_id),
 CHECK((state='held' AND settled_at IS NULL) OR (state<>'held' AND settled_at IS NOT NULL))
);
CREATE TABLE app.period_closures (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 period_id uuid NOT NULL UNIQUE,
 user_id uuid NOT NULL,
 rides_converted integer NOT NULL CHECK(rides_converted>=0),
 conversion_rate_pesewas integer NOT NULL CHECK(conversion_rate_pesewas>=0),
 credit_granted_pesewas integer NOT NULL CHECK(credit_granted_pesewas>=0),
 closed_at timestamptz NOT NULL CHECK(isfinite(closed_at)),
 FOREIGN KEY(period_id,user_id) REFERENCES app.billing_periods(id,user_id) ON DELETE RESTRICT,
 UNIQUE(id,period_id,user_id), UNIQUE(id,user_id),
 CHECK(credit_granted_pesewas::bigint=rides_converted::bigint*conversion_rate_pesewas)
);
CREATE TABLE app.ride_entries (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 user_id uuid NOT NULL,
 period_id uuid NOT NULL,
 reason text NOT NULL CHECK(reason IN ('allocation','converted')),
 delta_rides integer NOT NULL CHECK(delta_rides<>0),
 closure_id uuid,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 FOREIGN KEY(period_id,user_id) REFERENCES app.billing_periods(id,user_id) ON DELETE RESTRICT,
 FOREIGN KEY(closure_id,period_id,user_id) REFERENCES app.period_closures(id,period_id,user_id) ON DELETE RESTRICT,
 CHECK((reason='allocation' AND delta_rides>0 AND closure_id IS NULL)
   OR (reason='converted' AND delta_rides<0 AND closure_id IS NOT NULL))
);
CREATE UNIQUE INDEX one_period_allocation ON app.ride_entries(period_id) WHERE reason='allocation';
CREATE UNIQUE INDEX one_closure_ride_effect ON app.ride_entries(closure_id) WHERE reason='converted';
CREATE TABLE app.credit_entries (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
 reason text NOT NULL CHECK(reason IN ('adjustment','purchase_applied','month_end_conversion')),
 delta_pesewas integer NOT NULL CHECK(delta_pesewas<>0),
 adjustment_id uuid,
 purchase_id uuid,
 closure_id uuid,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 FOREIGN KEY(adjustment_id,user_id) REFERENCES app.credit_adjustments(id,user_id) ON DELETE RESTRICT,
 FOREIGN KEY(purchase_id,user_id) REFERENCES app.credit_holds(purchase_id,user_id) ON DELETE RESTRICT,
 FOREIGN KEY(closure_id,user_id) REFERENCES app.period_closures(id,user_id) ON DELETE RESTRICT,
 CHECK((reason='adjustment' AND adjustment_id IS NOT NULL AND purchase_id IS NULL AND closure_id IS NULL)
   OR (reason='purchase_applied' AND purchase_id IS NOT NULL AND delta_pesewas<0 AND adjustment_id IS NULL AND closure_id IS NULL)
   OR (reason='month_end_conversion' AND closure_id IS NOT NULL AND delta_pesewas>0 AND adjustment_id IS NULL AND purchase_id IS NULL))
);
CREATE UNIQUE INDEX one_adjustment_effect ON app.credit_entries(adjustment_id) WHERE adjustment_id IS NOT NULL;
CREATE UNIQUE INDEX one_purchase_credit_effect ON app.credit_entries(purchase_id) WHERE purchase_id IS NOT NULL;
CREATE UNIQUE INDEX one_closure_credit_effect ON app.credit_entries(closure_id) WHERE closure_id IS NOT NULL;
CREATE INDEX credit_entries_owner ON app.credit_entries(user_id);
CREATE INDEX ride_entries_period ON app.ride_entries(period_id);
CREATE INDEX credit_holds_available ON app.credit_holds(user_id) WHERE state='held';
CREATE INDEX purchases_owner_page ON app.purchases(user_id,created_at,id);

CREATE FUNCTION app.guard_membership_identity() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF (NEW.id,NEW.user_id,NEW.created_at) IS DISTINCT FROM (OLD.id,OLD.user_id,OLD.created_at) THEN
  RAISE EXCEPTION 'immutable_membership_identity' USING ERRCODE='23514';
 END IF; RETURN NEW;
END $$;
CREATE TRIGGER immutable_membership_identity BEFORE UPDATE ON app.memberships
 FOR EACH ROW EXECUTE FUNCTION app.guard_membership_identity();

CREATE FUNCTION app.guard_purchase_terms() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF (to_jsonb(NEW)-ARRAY['state','failure_code','updated_at']) IS DISTINCT FROM
    (to_jsonb(OLD)-ARRAY['state','failure_code','updated_at']) THEN
  RAISE EXCEPTION 'immutable_purchase_terms' USING ERRCODE='23514';
 END IF;
 IF NEW.state<>OLD.state AND NOT (
   (OLD.state='awaiting_payment' AND NEW.state IN ('processing','fulfilled','failed','cancelled','review_required')) OR
   (OLD.state='processing' AND NEW.state IN ('fulfilled','failed','review_required')) OR
   (OLD.state IN ('failed','cancelled') AND NEW.state='review_required')
 ) THEN RAISE EXCEPTION 'invalid_purchase_transition' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER immutable_purchase_terms BEFORE UPDATE ON app.purchases FOR EACH ROW EXECUTE FUNCTION app.guard_purchase_terms();
CREATE TRIGGER immutable_purchase_legs BEFORE UPDATE OR DELETE ON app.purchase_legs FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE FUNCTION app.validate_purchase_legs() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE pid uuid; total integer; valid integer; windows integer;
BEGIN
 IF TG_TABLE_NAME='purchases' THEN pid:=NEW.id; ELSE pid:=NEW.purchase_id; END IF;
 SELECT count(*),count(*) FILTER(WHERE p.route_id=rp.route_id AND l.direction=rp.direction
    AND a.ordinal<b.ordinal),count(DISTINCT s.service_window)
 INTO total,valid,windows FROM app.purchase_legs l JOIN app.purchases p ON p.id=l.purchase_id
 JOIN app.route_pattern_versions v ON v.id=l.pattern_version_id JOIN app.route_patterns rp ON rp.id=v.pattern_id
 JOIN app.service_schedules s ON s.id=l.schedule_id
 JOIN app.route_pattern_stops a ON a.id=l.pickup_occurrence_id
 JOIN app.route_pattern_stops b ON b.id=l.dropoff_occurrence_id WHERE l.purchase_id=pid;
 IF total<>2 OR valid<>2 OR windows<>2 THEN
  RAISE EXCEPTION 'purchase_requires_matching_paired_legs' USING ERRCODE='23514';
 END IF; RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER validate_purchase_legs AFTER INSERT ON app.purchases
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION app.validate_purchase_legs();
CREATE CONSTRAINT TRIGGER validate_new_purchase_leg AFTER INSERT ON app.purchase_legs
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION app.validate_purchase_legs();

CREATE FUNCTION app.guard_financial_sources() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE amount integer; available bigint; p app.purchases; bp app.billing_periods;
BEGIN
 IF TG_TABLE_NAME='payment_attempts' THEN
  SELECT * INTO p FROM app.purchases WHERE id=NEW.purchase_id;
  IF NEW.amount_pesewas<>p.cash_due_pesewas OR NEW.currency<>p.currency THEN
   RAISE EXCEPTION 'attempt_terms_mismatch' USING ERRCODE='23514'; END IF;
  IF TG_OP='UPDATE' AND ((to_jsonb(NEW)-ARRAY['state','provider_transaction_id','channel','fees_pesewas','paid_at']) IS DISTINCT FROM
    (to_jsonb(OLD)-ARRAY['state','provider_transaction_id','channel','fees_pesewas','paid_at']) OR
    (OLD.state='successful' AND NEW IS DISTINCT FROM OLD) OR (OLD.state='failed' AND NEW.state<>OLD.state)) THEN
   RAISE EXCEPTION 'immutable_attempt_identity_or_terminal_state' USING ERRCODE='23514'; END IF;
 ELSIF TG_TABLE_NAME='credit_holds' THEN
  PERFORM id FROM app.users WHERE id=NEW.user_id FOR UPDATE;
  SELECT applied_credit_pesewas INTO amount FROM app.purchases WHERE id=NEW.purchase_id;
  IF amount<>NEW.amount_pesewas THEN RAISE EXCEPTION 'hold_terms_mismatch' USING ERRCODE='23514'; END IF;
  IF TG_OP='INSERT' THEN
   SELECT COALESCE((SELECT SUM(delta_pesewas) FROM app.credit_entries WHERE user_id=NEW.user_id),0)-
    COALESCE((SELECT SUM(amount_pesewas) FROM app.credit_holds WHERE user_id=NEW.user_id AND state='held'),0) INTO available;
   IF NEW.state<>'held' OR NEW.amount_pesewas>available THEN
    RAISE EXCEPTION 'insufficient_available_credit' USING ERRCODE='23514'; END IF;
  END IF;
  IF TG_OP='UPDATE' AND ((to_jsonb(NEW)-ARRAY['state','settled_at']) IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['state','settled_at'])
     OR (OLD.state<>'held' AND NEW IS DISTINCT FROM OLD)) THEN
   RAISE EXCEPTION 'immutable_credit_hold' USING ERRCODE='23514'; END IF;
 ELSIF TG_TABLE_NAME='ride_entries' THEN
  IF NEW.reason='allocation' THEN
   SELECT purchase.rides_granted INTO amount FROM app.billing_periods b JOIN app.purchases purchase ON purchase.id=b.purchase_id WHERE b.id=NEW.period_id;
  ELSE SELECT -rides_converted INTO amount FROM app.period_closures WHERE id=NEW.closure_id; END IF;
  IF NEW.delta_rides<>amount THEN RAISE EXCEPTION 'ride_source_amount_mismatch' USING ERRCODE='23514'; END IF;
 ELSIF TG_TABLE_NAME='credit_entries' THEN
  PERFORM id FROM app.users WHERE id=NEW.user_id FOR UPDATE;
  IF NEW.reason='adjustment' THEN SELECT delta_pesewas INTO amount FROM app.credit_adjustments WHERE id=NEW.adjustment_id;
  ELSIF NEW.reason='purchase_applied' THEN SELECT -amount_pesewas INTO amount FROM app.credit_holds WHERE purchase_id=NEW.purchase_id AND state='captured';
  ELSE SELECT credit_granted_pesewas INTO amount FROM app.period_closures WHERE id=NEW.closure_id; END IF;
  IF amount IS NULL OR NEW.delta_pesewas<>amount THEN RAISE EXCEPTION 'credit_source_amount_mismatch' USING ERRCODE='23514'; END IF;
  SELECT COALESCE((SELECT SUM(delta_pesewas) FROM app.credit_entries WHERE user_id=NEW.user_id),0)+NEW.delta_pesewas-
   COALESCE((SELECT SUM(amount_pesewas) FROM app.credit_holds WHERE user_id=NEW.user_id AND state='held'),0) INTO available;
  IF available<0 THEN RAISE EXCEPTION 'credit_entry_consumes_held_or_missing_value' USING ERRCODE='23514'; END IF;
 ELSIF TG_TABLE_NAME='period_closures' THEN
  SELECT * INTO bp FROM app.billing_periods WHERE id=NEW.period_id;
  SELECT * INTO p FROM app.purchases WHERE id=bp.purchase_id;
  IF NEW.conversion_rate_pesewas<>p.conversion_rate_pesewas OR NEW.closed_at<bp.effective_ends_at OR NEW.rides_converted>p.rides_granted THEN
   RAISE EXCEPTION 'closure_terms_mismatch' USING ERRCODE='23514'; END IF;
 ELSIF TG_TABLE_NAME='billing_periods' THEN
  SELECT * INTO p FROM app.purchases WHERE id=NEW.purchase_id;
  IF p.state<>'fulfilled' THEN RAISE EXCEPTION 'period_requires_fulfilled_purchase' USING ERRCODE='23514'; END IF;
  IF TG_OP='INSERT' AND NOT EXISTS(SELECT 1 FROM app.payment_attempts WHERE purchase_id=NEW.purchase_id AND state='successful' AND paid_at=NEW.starts_at) THEN
   RAISE EXCEPTION 'period_requires_successful_attempt' USING ERRCODE='23514'; END IF;
  IF TG_OP='UPDATE' AND ((to_jsonb(NEW)-ARRAY['state','effective_ends_at']) IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['state','effective_ends_at'])
    OR (OLD.state IN ('closed','reversed') AND NEW.state='open')
    OR NEW.effective_ends_at<OLD.effective_ends_at) THEN
   RAISE EXCEPTION 'immutable_period_identity_or_history' USING ERRCODE='23514'; END IF;
 END IF; RETURN NEW;
END $$;
CREATE TRIGGER guard_attempt BEFORE INSERT OR UPDATE ON app.payment_attempts FOR EACH ROW EXECUTE FUNCTION app.guard_financial_sources();
CREATE TRIGGER guard_hold BEFORE INSERT OR UPDATE ON app.credit_holds FOR EACH ROW EXECUTE FUNCTION app.guard_financial_sources();
CREATE TRIGGER guard_ride_source BEFORE INSERT ON app.ride_entries FOR EACH ROW EXECUTE FUNCTION app.guard_financial_sources();
CREATE TRIGGER guard_credit_source BEFORE INSERT ON app.credit_entries FOR EACH ROW EXECUTE FUNCTION app.guard_financial_sources();
CREATE TRIGGER guard_closure BEFORE INSERT ON app.period_closures FOR EACH ROW EXECUTE FUNCTION app.guard_financial_sources();
CREATE TRIGGER guard_period BEFORE INSERT OR UPDATE ON app.billing_periods FOR EACH ROW EXECUTE FUNCTION app.guard_financial_sources();
CREATE TRIGGER retain_ride_entries BEFORE UPDATE OR DELETE ON app.ride_entries FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE TRIGGER retain_credit_entries BEFORE UPDATE OR DELETE ON app.credit_entries FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE TRIGGER retain_credit_adjustments BEFORE UPDATE OR DELETE ON app.credit_adjustments FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE TRIGGER retain_period_closures BEFORE UPDATE OR DELETE ON app.period_closures FOR EACH ROW EXECUTE FUNCTION app.append_only();
-- Capture may precede its debit inside a transaction, but never at commit.
-- The unique source index already supplies "at most one"; this supplies
-- "at least one". Immediate source/amount/owner checks and append-only ledger
-- triggers prevent a matching debit from being rewritten or removed later.
CREATE FUNCTION app.require_captured_hold_debit() RETURNS trigger
 LANGUAGE plpgsql SECURITY INVOKER SET search_path = pg_catalog AS $$
BEGIN
 IF EXISTS (SELECT 1 FROM app.credit_holds h
   WHERE h.purchase_id=NEW.purchase_id AND h.state='captured'
     AND NOT EXISTS (SELECT 1 FROM app.credit_entries e
       WHERE e.purchase_id=h.purchase_id AND e.user_id=h.user_id
         AND e.reason='purchase_applied' AND e.delta_pesewas=-h.amount_pesewas)) THEN
  RAISE EXCEPTION 'captured_hold_requires_matching_debit'
   USING ERRCODE='23514', CONSTRAINT='captured_hold_requires_debit';
 END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER captured_hold_requires_debit
 AFTER INSERT OR UPDATE ON app.credit_holds DEFERRABLE INITIALLY DEFERRED
 FOR EACH ROW WHEN (NEW.state='captured') EXECUTE FUNCTION app.require_captured_hold_debit();
COMMENT ON FUNCTION app.require_captured_hold_debit() IS
 'At commit, captured credit requires its exact typed debit. Released/held credit does not. Does not prove complete purchase fulfilment or require every accounting source to have an effect.';
-- No runtime DDL privilege is added. grantRuntime removes broad UPDATE from
-- these append-only tables when provisioning the complete installed schema.
COMMENT ON COLUMN app.purchases.price_pesewas IS 'Full agreed price in integer pesewas before Ride Credit.';
COMMENT ON COLUMN app.purchases.applied_credit_pesewas IS 'Agreed Ride Credit contribution in integer pesewas.';
COMMENT ON COLUMN app.purchases.cash_due_pesewas IS 'Agreed provider collection in integer pesewas; minimum 100.';
COMMENT ON COLUMN app.purchases.fare_pesewas IS 'Frozen corridor fare in integer pesewas.';
COMMENT ON COLUMN app.purchases.conversion_rate_pesewas IS 'Frozen integer pesewas per unused ride, not current pricing.';
COMMENT ON COLUMN app.payment_attempts.amount_pesewas IS 'Requested collection in integer pesewas; must match purchase.';
COMMENT ON COLUMN app.payment_attempts.fees_pesewas IS 'Provider-reported fee in integer pesewas.';
COMMENT ON COLUMN app.credit_holds.amount_pesewas IS 'Reserved contribution in integer pesewas.';
COMMENT ON COLUMN app.credit_adjustments.delta_pesewas IS 'Attributable adjustment in integer pesewas.';
COMMENT ON COLUMN app.credit_entries.delta_pesewas IS 'Append-only signed Ride Credit movement in integer pesewas.';
COMMENT ON COLUMN app.period_closures.conversion_rate_pesewas IS 'Frozen conversion rate in integer pesewas per ride.';
COMMENT ON COLUMN app.period_closures.credit_granted_pesewas IS 'Exactly rides_converted times the frozen rate, in integer pesewas.';
COMMENT ON TABLE app.purchase_legs IS 'Immutable quoted paired commute. Initial assignment materialization belongs to 013; changing commute never rewrites these terms.';
COMMENT ON TABLE app.billing_periods IS 'One period per fulfilled purchase. Current coverage is derived; no independently writable membership.current_period pointer.';
