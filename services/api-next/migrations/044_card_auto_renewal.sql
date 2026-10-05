-- Card auto-renewal: a rider opts in, a verified card payment saves the card,
-- and the renewal worker charges it for the next period on the same terms.

-- The rider's choice, kept apart from any card: it can be set before the first
-- card payment, which is when the card that honours it is saved.
CREATE TABLE app.auto_renewal_preferences (
  user_id uuid PRIMARY KEY REFERENCES app.users(id) ON DELETE RESTRICT,
  enabled boolean NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

-- A reusable Paystack card authorization. The authorization code and the
-- customer email Paystack bound it to are sealed together; only the details a
-- rider needs to recognise the card are readable. One usable card per rider.
CREATE TABLE app.card_authorizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  environment text NOT NULL CHECK (environment IN ('test','live')),
  ciphertext bytea,
  signature text NOT NULL CHECK (length(signature) BETWEEN 1 AND 200),
  last4 text NOT NULL CHECK (last4 ~ '^[0-9]{4}$'),
  brand text NOT NULL CHECK (length(brand) BETWEEN 1 AND 50),
  exp_month smallint NOT NULL CHECK (exp_month BETWEEN 1 AND 12),
  exp_year smallint NOT NULL CHECK (exp_year BETWEEN 2000 AND 2100),
  bank text CHECK (bank IS NULL OR length(bank) BETWEEN 1 AND 100),
  source_attempt_id uuid NOT NULL REFERENCES app.payment_attempts(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  removed_at timestamptz,
  -- A removed card keeps its display details for history, never its code.
  CHECK ((removed_at IS NULL) = (ciphertext IS NOT NULL))
);
CREATE UNIQUE INDEX one_usable_card_per_rider ON app.card_authorizations(user_id) WHERE removed_at IS NULL;

-- A renewal purchase carries frozen terms like an offer purchase, but its
-- source is the purchase it renews rather than an Ops offer.
ALTER TABLE app.purchases ADD COLUMN renewal_of uuid REFERENCES app.purchases(id) ON DELETE RESTRICT;
-- A declined charge fails its purchase and the next day's retry makes another,
-- so only one live renewal of a purchase may exist at a time.
CREATE UNIQUE INDEX one_live_renewal_per_purchase ON app.purchases(renewal_of)
  WHERE renewal_of IS NOT NULL AND state IN ('awaiting_payment','processing','review_required','fulfilled');
-- 042's "offer terms exactly when an offer" becomes "exactly when an offer or a
-- renewal", and a renewal is priced by its frozen terms as an offer is, not by
-- the historical plan formula. Both checks are found by definition, not name.
DO $$ DECLARE n text;
BEGIN
 SELECT conname INTO STRICT n FROM pg_constraint WHERE conrelid='app.purchases'::regclass AND contype='c'
  AND pg_get_constraintdef(oid)='CHECK (((offer_id IS NULL) = (offer_terms IS NULL)))';
 EXECUTE format('ALTER TABLE app.purchases DROP CONSTRAINT %I',n);
 SELECT conname INTO STRICT n FROM pg_constraint WHERE conrelid='app.purchases'::regclass AND contype='c'
  AND pg_get_constraintdef(oid) LIKE 'CHECK (((offer_id IS NOT NULL) OR ((price_pesewas)::numeric = floor(%';
 EXECUTE format('ALTER TABLE app.purchases DROP CONSTRAINT %I',n);
END $$;
ALTER TABLE app.purchases ADD CONSTRAINT purchases_terms_source CHECK (
  NOT (offer_id IS NOT NULL AND renewal_of IS NOT NULL)
  AND (offer_terms IS NOT NULL) = (offer_id IS NOT NULL OR renewal_of IS NOT NULL));
ALTER TABLE app.purchases ADD CONSTRAINT purchases_formula_price CHECK (
  offer_terms IS NOT NULL
  OR price_pesewas::numeric = floor((fare_pesewas::numeric * rides_granted * price_multiplier_bp + 5000) / 10000));

-- One renewal per paid period. The worker reminds, then charges from three
-- days before the period ends, retrying daily until it ends.
CREATE TABLE app.auto_renewals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  period_id uuid NOT NULL UNIQUE REFERENCES app.billing_periods(id) ON DELETE RESTRICT,
  state text NOT NULL DEFAULT 'scheduled' CHECK (state IN
    ('scheduled','reminded','charging','paid','failed','needs_offer','lapsed','cancelled')),
  renewal_purchase_id uuid REFERENCES app.purchases(id) ON DELETE RESTRICT,
  attempts smallint NOT NULL DEFAULT 0 CHECK (attempts BETWEEN 0 AND 30),
  next_attempt_at timestamptz,
  failure_code text CHECK (failure_code IS NULL OR failure_code IN
    ('card_declined','charge_unconfirmed','fare_changed','service_changed','no_card',
     'coverage_conflict','renewal_blocked')),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX auto_renewals_open ON app.auto_renewals(state)
  WHERE state IN ('scheduled','reminded','charging','failed');

-- A renewal purchase is a pending renewal exactly as an offer purchase is.
CREATE OR REPLACE FUNCTION app.has_pending_renewal(pid uuid) RETURNS boolean LANGUAGE sql STABLE AS $$
 SELECT EXISTS(SELECT 1 FROM app.billing_periods current_period
 JOIN app.purchases p ON p.membership_id=current_period.membership_id
 LEFT JOIN app.billing_periods next_period ON next_period.purchase_id=p.id
 WHERE current_period.id=pid AND (p.offer_id IS NOT NULL OR p.renewal_of IS NOT NULL)
 AND ((p.offer_terms->>'coverageStart')::date::timestamp AT TIME ZONE 'Africa/Accra')>current_period.starts_at
 AND (p.state IN ('awaiting_payment','processing') OR (p.state='fulfilled' AND next_period.state='open')))
$$;

-- 042 told fixed-calendar purchases apart by offer_id. A renewal has frozen
-- terms without an offer, so both guards now key on the terms themselves:
-- its period keeps the calendar dates, and it closes by journey credit.
CREATE OR REPLACE FUNCTION app.guard_billing_period() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE p app.purchases;
BEGIN
 SELECT * INTO p FROM app.purchases WHERE id=NEW.purchase_id;
 IF p.state<>'fulfilled' THEN RAISE EXCEPTION 'period_requires_fulfilled_purchase' USING ERRCODE='23514'; END IF;
 IF TG_OP='INSERT' THEN
   IF p.offer_terms IS NULL THEN
     IF NOT EXISTS(SELECT 1 FROM app.payment_attempts WHERE purchase_id=p.id AND state='successful' AND paid_at=NEW.starts_at)
       THEN RAISE EXCEPTION 'period_requires_successful_attempt' USING ERRCODE='23514'; END IF;
   ELSE
     IF NEW.starts_at IS DISTINCT FROM ((p.offer_terms->>'coverageStart')::date::timestamp AT TIME ZONE 'Africa/Accra')
       OR NEW.original_ends_at IS DISTINCT FROM ((p.offer_terms->>'coverageEnd')::date::timestamp AT TIME ZONE 'Africa/Accra')
       OR NOT EXISTS(SELECT 1 FROM app.payment_attempts WHERE purchase_id=p.id AND state='successful' AND paid_at<=NEW.starts_at)
       THEN RAISE EXCEPTION 'offered_period_mismatch' USING ERRCODE='23514'; END IF;
   END IF;
 END IF;
 IF TG_OP='UPDATE' AND ((to_jsonb(NEW)-ARRAY['state','effective_ends_at']) IS DISTINCT FROM
   (to_jsonb(OLD)-ARRAY['state','effective_ends_at']) OR
   (OLD.state IN ('closed','reversed') AND NEW.state='open') OR NEW.effective_ends_at<OLD.effective_ends_at)
   THEN RAISE EXCEPTION 'immutable_period_identity_or_history' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE OR REPLACE FUNCTION app.guard_offer_closure() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE offered boolean; breakdown jsonb; rides integer; credit bigint;
BEGIN
 SELECT p.offer_terms IS NOT NULL INTO offered FROM app.billing_periods b JOIN app.purchases p ON p.id=b.purchase_id WHERE b.id=NEW.period_id;
 IF NOT offered THEN
   IF NEW.journey_breakdown IS NOT NULL THEN RAISE EXCEPTION 'legacy_closure_breakdown' USING ERRCODE='23514'; END IF;
   RETURN NEW;
 END IF;
 SELECT jsonb_agg(jsonb_build_object('direction',direction,'rides',granted-charged,'creditPerRide',credit_rate) ORDER BY direction),
   sum(granted-charged),sum((granted-charged)::bigint*credit_rate)
 INTO breakdown,rides,credit FROM app.offer_ride_balances(NEW.period_id);
 IF NEW.journey_breakdown IS DISTINCT FROM breakdown OR NEW.rides_converted IS DISTINCT FROM rides
   OR NEW.credit_granted_pesewas IS DISTINCT FROM credit OR NEW.conversion_rate_pesewas<>0 THEN
   RAISE EXCEPTION 'offered_closure_mismatch' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;

-- The database's own check that a renewal is the purchase it renews, again:
-- same rider and route, same price, rides that are the sum of its journeys,
-- and coverage that starts exactly where the renewed period ends.
CREATE FUNCTION app.guard_renewal_purchase() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE src app.purchases; ends timestamptz;
BEGIN
 IF NEW.renewal_of IS NULL THEN RETURN NEW; END IF;
 SELECT * INTO src FROM app.purchases WHERE id=NEW.renewal_of;
 SELECT effective_ends_at INTO ends FROM app.billing_periods WHERE purchase_id=src.id AND state='open';
 IF src.id IS NULL OR src.offer_terms IS NULL OR ends IS NULL
   OR src.user_id<>NEW.user_id OR src.route_id<>NEW.route_id
   OR NEW.price_pesewas IS DISTINCT FROM src.price_pesewas
   OR NEW.price_pesewas IS DISTINCT FROM (NEW.offer_terms->'price'->>'amountMinor')::integer
   OR NEW.rides_granted IS DISTINCT FROM (SELECT sum((l->>'ridesGranted')::integer) FROM jsonb_array_elements(NEW.offer_terms->'legs') l)
   OR NEW.conversion_rate_pesewas<>0
   OR ((NEW.offer_terms->>'coverageStart')::date::timestamp AT TIME ZONE 'Africa/Accra') IS DISTINCT FROM ends THEN
   RAISE EXCEPTION 'invalid_renewal_purchase' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER renewal_purchase BEFORE INSERT ON app.purchases FOR EACH ROW EXECUTE FUNCTION app.guard_renewal_purchase();

ALTER TABLE app.email_outbox DROP CONSTRAINT email_outbox_kind_check;
ALTER TABLE app.email_outbox ADD CONSTRAINT email_outbox_kind_check CHECK (kind IN (
 'subscription_active','subscription_expiring','erasure_requested','driver_credentials_issued',
 'driver_pin_reset','ops_invitation','renewal_upcoming','renewal_failed','renewal_needs_offer'));
