ALTER TABLE app.standby_applications ADD COLUMN travel_days smallint[]
  CHECK(travel_days IS NULL OR app.valid_weekdays(travel_days));
ALTER TABLE app.standby_applications DROP CONSTRAINT standby_applications_state_check,
  ADD CHECK(state IN ('submitted','offered','withdrawn','checkout_open','completed'));
ALTER TABLE app.standby_offers ADD COLUMN terms jsonb CHECK(terms IS NULL OR jsonb_typeof(terms)='object');
ALTER TABLE app.standby_offers ADD COLUMN input_hash text CHECK(input_hash IS NULL OR input_hash ~ '^[a-f0-9]{64}$');
ALTER TABLE app.purchases ADD COLUMN offer_id uuid UNIQUE REFERENCES app.standby_offers(id) ON DELETE RESTRICT;
ALTER TABLE app.purchases ADD COLUMN offer_terms jsonb;
ALTER TABLE app.purchases ADD CHECK((offer_id IS NULL)=(offer_terms IS NULL));
DO $$ DECLARE n text;
BEGIN
 SELECT conname INTO STRICT n FROM pg_constraint WHERE conrelid='app.purchases'::regclass
   AND contype='c' AND pg_get_constraintdef(oid) LIKE '%floor(%';
 EXECUTE format('ALTER TABLE app.purchases DROP CONSTRAINT %I',n);
END $$;
ALTER TABLE app.purchases ADD CHECK(offer_id IS NOT NULL OR
 price_pesewas::numeric=floor((fare_pesewas::numeric*rides_granted*price_multiplier_bp+5000)/10000));

-- Recover old acceptance crashes before enforcing the new priced-offer flow.
-- A committed old purchase is preserved and remains recoverable by its owner.
UPDATE app.standby_offers o SET purchase_id=p.id,state='checkout_open'
FROM app.standby_applications a,app.purchases p
WHERE o.application_id=a.id AND o.terms IS NULL AND o.purchase_id IS NULL
  AND o.state='accepting' AND p.user_id=a.user_id AND p.checkout_key_hash=o.acceptance_key_hash;
UPDATE app.standby_applications a SET state='checkout_open',updated_at=clock_timestamp()
FROM app.standby_offers o WHERE o.application_id=a.id AND o.purchase_id IS NOT NULL AND o.terms IS NULL;
UPDATE app.standby_offers SET state='offered',acceptance_key_hash=NULL
WHERE terms IS NULL AND state='accepting' AND purchase_id IS NULL;

CREATE FUNCTION app.guard_subscription_offer() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF (NEW.application_id,NEW.expires_at,NEW.offer_key_hash,NEW.terms,NEW.input_hash) IS DISTINCT FROM
    (OLD.application_id,OLD.expires_at,OLD.offer_key_hash,OLD.terms,OLD.input_hash) THEN
   RAISE EXCEPTION 'immutable_offer_terms' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER immutable_offer_terms BEFORE UPDATE ON app.standby_offers FOR EACH ROW EXECUTE FUNCTION app.guard_subscription_offer();
CREATE FUNCTION app.guard_offered_purchase() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE o record;
BEGIN
 IF NEW.offer_id IS NULL THEN RETURN NEW; END IF;
 SELECT s.*,a.user_id,a.route_id INTO o FROM app.standby_offers s
 JOIN app.standby_applications a ON a.id=s.application_id WHERE s.id=NEW.offer_id FOR UPDATE OF s;
 IF NOT FOUND OR o.terms IS NULL OR o.state<>'accepting' OR o.acceptance_key_hash IS DISTINCT FROM NEW.checkout_key_hash
   OR o.user_id<>NEW.user_id OR o.route_id<>NEW.route_id OR NEW.offer_terms IS DISTINCT FROM o.terms
   OR NEW.price_pesewas IS DISTINCT FROM (o.terms->'price'->>'amountMinor')::integer
   OR NEW.rides_granted IS DISTINCT FROM (SELECT sum((l->>'ridesGranted')::integer) FROM jsonb_array_elements(o.terms->'legs') l)
   OR NEW.conversion_rate_pesewas<>0 THEN
   RAISE EXCEPTION 'invalid_offered_purchase' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER offered_purchase BEFORE INSERT ON app.purchases FOR EACH ROW EXECUTE FUNCTION app.guard_offered_purchase();

-- One directional balance, with immutable grant and conversion values.
CREATE FUNCTION app.offer_ride_balances(pid uuid)
RETURNS TABLE(direction text,granted integer,charged integer,held integer,credit_rate integer)
LANGUAGE sql STABLE AS $$
 SELECT l->>'direction',(l->>'ridesGranted')::integer,
   (SELECT count(*)::integer FROM app.reservation_charges c JOIN app.reservations r ON r.id=c.reservation_id
    WHERE c.period_id=b.id AND r.direction=l->>'direction'),
   (SELECT count(*)::integer FROM app.reservations r WHERE r.period_id=b.id AND r.direction=l->>'direction' AND r.status='reserved'),
   (l->'creditPerUnusedRide'->>'amountMinor')::integer
 FROM app.billing_periods b JOIN app.purchases p ON p.id=b.purchase_id
 CROSS JOIN LATERAL jsonb_array_elements(p.offer_terms->'legs') l WHERE b.id=pid
$$;
CREATE FUNCTION app.guard_offered_reservation() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE terms jsonb; leg jsonb; used integer;
BEGIN
 IF NEW.period_id IS NULL OR NEW.status NOT IN ('pending','reserved','boarded','no_show') THEN RETURN NEW; END IF;
 PERFORM id FROM app.users WHERE id=NEW.user_id FOR UPDATE;
 PERFORM id FROM app.billing_periods WHERE id=NEW.period_id FOR UPDATE;
 SELECT p.offer_terms INTO terms FROM app.billing_periods b JOIN app.purchases p ON p.id=b.purchase_id WHERE b.id=NEW.period_id;
 IF terms IS NULL THEN RETURN NEW; END IF;
 SELECT l INTO leg FROM jsonb_array_elements(terms->'legs') l WHERE l->>'direction'=NEW.direction;
 IF leg IS NULL OR (leg->>'scheduleId')::uuid<>NEW.schedule_id
   OR (leg->>'patternVersionId')::uuid<>NEW.pattern_version_id
   OR (leg->>'pickupOccurrenceId')::uuid<>NEW.pickup_occurrence_id
   OR (leg->>'dropoffOccurrenceId')::uuid<>NEW.dropoff_occurrence_id
   OR NOT (leg->'travelDays') @> to_jsonb(ARRAY[extract(isodow FROM NEW.service_date)::integer]) THEN
   RAISE EXCEPTION 'journey_not_covered' USING ERRCODE='23514';
 END IF;
 IF NEW.status<>'pending' THEN
   SELECT count(*) INTO used FROM app.reservations WHERE period_id=NEW.period_id AND direction=NEW.direction
     AND id<>NEW.id AND status IN ('reserved','boarded','no_show');
   IF used >= (leg->>'ridesGranted')::integer THEN RAISE EXCEPTION 'journey_rides_exhausted' USING ERRCODE='23514'; END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER offered_reservation BEFORE INSERT OR UPDATE ON app.reservations FOR EACH ROW EXECUTE FUNCTION app.guard_offered_reservation();

-- Preserve the legacy arithmetic; offered closures disclose each direction.
ALTER TABLE app.period_closures ADD COLUMN journey_breakdown jsonb;
ALTER TABLE app.period_closures DROP CONSTRAINT period_closures_check;
ALTER TABLE app.period_closures ADD CHECK(journey_breakdown IS NOT NULL OR
 credit_granted_pesewas::bigint=rides_converted::bigint*conversion_rate_pesewas);
CREATE FUNCTION app.guard_offer_closure() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE offered boolean; breakdown jsonb; rides integer; credit bigint;
BEGIN
 SELECT p.offer_id IS NOT NULL INTO offered FROM app.billing_periods b JOIN app.purchases p ON p.id=b.purchase_id WHERE b.id=NEW.period_id;
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
CREATE TRIGGER offered_closure BEFORE INSERT ON app.period_closures FOR EACH ROW EXECUTE FUNCTION app.guard_offer_closure();

-- A paid offer has fixed calendar coverage, rather than starting at payment time.
DROP TRIGGER guard_period ON app.billing_periods;
CREATE FUNCTION app.guard_billing_period() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE p app.purchases;
BEGIN
 SELECT * INTO p FROM app.purchases WHERE id=NEW.purchase_id;
 IF p.state<>'fulfilled' THEN RAISE EXCEPTION 'period_requires_fulfilled_purchase' USING ERRCODE='23514'; END IF;
 IF TG_OP='INSERT' THEN
   IF p.offer_id IS NULL THEN
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
CREATE TRIGGER guard_period BEFORE INSERT OR UPDATE ON app.billing_periods FOR EACH ROW EXECUTE FUNCTION app.guard_billing_period();

CREATE FUNCTION app.complete_standby_checkout() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW.state IN ('fulfilled','failed','cancelled') THEN
   UPDATE app.standby_applications a SET state='completed',updated_at=clock_timestamp()
   FROM app.standby_offers o WHERE o.application_id=a.id AND o.purchase_id=NEW.id AND a.state='checkout_open';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER complete_standby_checkout AFTER UPDATE ON app.purchases FOR EACH ROW EXECUTE FUNCTION app.complete_standby_checkout();
-- Release historical completed checkout applications too.
UPDATE app.standby_applications a SET state='completed',updated_at=clock_timestamp()
FROM app.standby_offers o JOIN app.purchases p ON p.id=o.purchase_id
WHERE o.application_id=a.id AND a.state='checkout_open' AND p.state IN ('fulfilled','failed','cancelled');
