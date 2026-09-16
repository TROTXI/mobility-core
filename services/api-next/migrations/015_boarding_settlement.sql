-- One durable charge per funded reservation, independent of verification method.
-- Reviewed 001--014 are unchanged. No invented return/refund endpoint: late
-- attendance corrects no_show to boarded without reversing/recharging a ride.
LOCK TABLE app.reservations, app.ride_entries IN ACCESS EXCLUSIVE MODE;
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM app.reservations WHERE status IN ('boarded','no_show') OR settled_at IS NOT NULL) THEN
 RAISE EXCEPTION 'boarding_history_requires_explicit_migration'; END IF;
END $$;
CREATE TABLE app.boarding_commands (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
 operation text NOT NULL CHECK(operation IN ('boardRider','markNoShow','runNoShows')),
 target uuid NOT NULL REFERENCES app.trips(id) ON DELETE RESTRICT,
 key_hash text NOT NULL CHECK(key_hash ~ '^[a-f0-9]{64}$'),
 input_hash text NOT NULL CHECK(input_hash ~ '^[a-f0-9]{64}$'),
 response_body jsonb NOT NULL CHECK (
  jsonb_typeof(response_body)='object' AND response_body ?& ARRAY['reservationId','status','alreadyApplied','chargedRides']
  AND response_body-ARRAY['reservationId','status','alreadyApplied','chargedRides']='{}'::jsonb
  AND jsonb_typeof(response_body->'reservationId')='string'
  AND response_body->>'reservationId' ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
  AND jsonb_typeof(response_body->'status')='string' AND response_body->>'status' IN ('boarded','no_show')
  AND jsonb_typeof(response_body->'alreadyApplied')='boolean'
  AND response_body->'chargedRides' IN ('0'::jsonb,'1'::jsonb)),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 UNIQUE(actor_user_id,operation,target,key_hash), UNIQUE(id,actor_user_id), UNIQUE(id,target)
);
COMMENT ON COLUMN app.boarding_commands.input_hash IS 'Keyed HMAC, never bare SHA of a guessable boarding code. Response contains outcome only, never pass/code/name/photo.';
CREATE TRIGGER immutable_boarding_commands BEFORE UPDATE OR DELETE ON app.boarding_commands
 FOR EACH ROW EXECUTE FUNCTION app.append_only();

ALTER TABLE app.reservations ADD UNIQUE(id,period_id,user_id,trip_id);
CREATE INDEX reservations_no_show_candidates ON app.reservations(service_date,direction,id) WHERE status='reserved';
CREATE TABLE app.reservation_charges (
 reservation_id uuid PRIMARY KEY, period_id uuid NOT NULL, user_id uuid NOT NULL, trip_id uuid NOT NULL,
 reason text NOT NULL CHECK(reason IN ('boarding','no_show')),
 command_id uuid NOT NULL,
 charged_at timestamptz NOT NULL,
 FOREIGN KEY(reservation_id,period_id,user_id,trip_id) REFERENCES app.reservations(id,period_id,user_id,trip_id) ON DELETE RESTRICT,
 UNIQUE(reservation_id,period_id,user_id), UNIQUE(reservation_id,trip_id),
 FOREIGN KEY(command_id,trip_id) REFERENCES app.boarding_commands(id,target) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED
);
CREATE TRIGGER immutable_reservation_charges BEFORE UPDATE OR DELETE ON app.reservation_charges
 FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE FUNCTION app.guard_reservation_charge() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE r app.reservations; b app.billing_periods; t app.trips;
BEGIN
 PERFORM id FROM app.users WHERE id=NEW.user_id AND deleted_at IS NULL FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'boarding_account_unavailable' USING ERRCODE='23514'; END IF;
 SELECT * INTO b FROM app.billing_periods WHERE id=NEW.period_id FOR UPDATE;
 SELECT * INTO t FROM app.trips WHERE id=NEW.trip_id FOR UPDATE;
 SELECT * INTO r FROM app.reservations WHERE id=NEW.reservation_id FOR UPDATE;
 IF r.status IS DISTINCT FROM 'reserved' OR b.state IS DISTINCT FROM 'open' OR t.status='cancelled'
 OR NOT EXISTS(SELECT 1 FROM app.memberships WHERE id=b.membership_id AND lifecycle='open')
 OR EXISTS(SELECT 1 FROM app.membership_pauses WHERE period_id=b.id AND ended_at IS NULL)
 OR EXISTS(SELECT 1 FROM app.payment_access_blocks WHERE period_id=b.id AND released_at IS NULL)
 OR EXISTS(SELECT 1 FROM app.account_restrictions WHERE user_id=NEW.user_id AND released_at IS NULL)
 THEN RAISE EXCEPTION 'boarding_ineligible' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER valid_reservation_charge BEFORE INSERT ON app.reservation_charges
 FOR EACH ROW EXECUTE FUNCTION app.guard_reservation_charge();
CREATE TABLE app.boarding_events (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), command_id uuid NOT NULL, actor_user_id uuid NOT NULL,
 reservation_id uuid NOT NULL REFERENCES app.reservation_charges(reservation_id) ON DELETE RESTRICT,
 method text NOT NULL CHECK(method IN ('qr','code','photo','no_show')),
 occurred_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 FOREIGN KEY(command_id,actor_user_id) REFERENCES app.boarding_commands(id,actor_user_id) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED,
 UNIQUE(command_id)
);
CREATE TRIGGER immutable_boarding_events BEFORE UPDATE OR DELETE ON app.boarding_events
 FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE TABLE app.boarding_qr_uses (
 jti uuid PRIMARY KEY, reservation_id uuid NOT NULL REFERENCES app.reservation_charges(reservation_id) ON DELETE RESTRICT,
 command_id uuid NOT NULL REFERENCES app.boarding_commands(id) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED
);
CREATE TRIGGER immutable_boarding_qr_uses BEFORE UPDATE OR DELETE ON app.boarding_qr_uses
 FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE TABLE app.boarding_code_attempts (
 trip_id uuid NOT NULL REFERENCES app.trips(id) ON DELETE RESTRICT,
 actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
 window_start timestamptz NOT NULL, attempts integer NOT NULL CHECK(attempts BETWEEN 1 AND 31),
 PRIMARY KEY(trip_id,actor_user_id)
);
COMMENT ON TABLE app.boarding_code_attempts IS 'Thirty code attempts per assigned driver/trip per fifteen minutes. Failures consume budget in a separate authorized admission transaction; no codes or token payloads are retained.';

ALTER TABLE app.ride_entries ADD COLUMN reservation_id uuid;
ALTER TABLE app.ride_entries ADD FOREIGN KEY(reservation_id,period_id,user_id)
 REFERENCES app.reservation_charges(reservation_id,period_id,user_id) ON DELETE RESTRICT;
ALTER TABLE app.ride_entries DROP CONSTRAINT ride_entries_reason_check, DROP CONSTRAINT ride_entries_check;
ALTER TABLE app.ride_entries ADD CHECK(reason IN ('allocation','converted','refund','boarding','no_show'));
ALTER TABLE app.ride_entries ADD CHECK(
 (reason='allocation' AND delta_rides>0 AND closure_id IS NULL AND reversal_id IS NULL AND reservation_id IS NULL) OR
 (reason='converted' AND delta_rides<0 AND closure_id IS NOT NULL AND reversal_id IS NULL AND reservation_id IS NULL) OR
 (reason='refund' AND delta_rides<0 AND closure_id IS NULL AND reversal_id IS NOT NULL AND reservation_id IS NULL) OR
 (reason IN ('boarding','no_show') AND delta_rides=-1 AND reservation_id IS NOT NULL AND closure_id IS NULL AND reversal_id IS NULL));
CREATE UNIQUE INDEX one_reservation_charge_effect ON app.ride_entries(reservation_id) WHERE reservation_id IS NOT NULL;
DROP TRIGGER guard_ride_source ON app.ride_entries;
CREATE TRIGGER guard_ride_source BEFORE INSERT ON app.ride_entries FOR EACH ROW
 WHEN (NEW.reversal_id IS NULL AND NEW.reservation_id IS NULL) EXECUTE FUNCTION app.guard_financial_sources();
CREATE FUNCTION app.guard_boarding_ride() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE charge app.reservation_charges; balance bigint;
BEGIN
 PERFORM id FROM app.users WHERE id=NEW.user_id FOR UPDATE;
 PERFORM id FROM app.billing_periods WHERE id=NEW.period_id AND state='open' FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'boarding_period_not_open' USING ERRCODE='23514'; END IF;
 SELECT * INTO charge FROM app.reservation_charges WHERE reservation_id=NEW.reservation_id;
 IF charge.reason IS DISTINCT FROM NEW.reason OR NEW.delta_rides<>-1 THEN
 RAISE EXCEPTION 'boarding_source_mismatch' USING ERRCODE='23514'; END IF;
 SELECT coalesce(sum(delta_rides),0) INTO balance FROM app.ride_entries WHERE period_id=NEW.period_id;
 IF balance<1 THEN RAISE EXCEPTION 'boarding_insufficient_rides' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER guard_boarding_ride BEFORE INSERT ON app.ride_entries FOR EACH ROW
 WHEN(NEW.reservation_id IS NOT NULL) EXECUTE FUNCTION app.guard_boarding_ride();

-- Completeness at commit: neither a status-only settlement nor a source-only
-- charge may commit. Inserts are charge -> attendance -> exact ledger debit.
CREATE FUNCTION app.require_reservation_settlement() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE r app.reservations; charge app.reservation_charges; rid uuid;
BEGIN
 IF TG_TABLE_NAME='reservations' THEN rid=NEW.id; ELSE rid=NEW.reservation_id; END IF;
 SELECT * INTO r FROM app.reservations WHERE id=rid;
 SELECT * INTO charge FROM app.reservation_charges WHERE reservation_id=rid;
 IF r.status IN ('boarded','no_show') OR charge.reservation_id IS NOT NULL THEN
 IF charge.reservation_id IS NULL OR r.status NOT IN ('boarded','no_show') OR (r.status='no_show' AND charge.reason<>'no_show') OR r.settled_at IS DISTINCT FROM charge.charged_at
 OR NOT EXISTS(SELECT 1 FROM app.ride_entries e WHERE e.reservation_id=rid AND e.reason=charge.reason AND e.delta_rides=-1)
 THEN RAISE EXCEPTION 'reservation_settlement_incomplete' USING ERRCODE='23514'; END IF;
 END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER reservation_requires_settlement AFTER INSERT OR UPDATE ON app.reservations
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION app.require_reservation_settlement();
CREATE CONSTRAINT TRIGGER charge_requires_settlement AFTER INSERT ON app.reservation_charges
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION app.require_reservation_settlement();

-- Preserve 013's seat/eligibility guard, changing only terminal attendance:
-- no_show -> boarded is permitted with every other immutable field unchanged.
CREATE OR REPLACE FUNCTION app.guard_reservation() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE t app.trips; capacity integer; used integer;
BEGIN
 IF TG_OP='UPDATE' AND (OLD.user_id,OLD.service_date,OLD.direction) IS DISTINCT FROM (NEW.user_id,NEW.service_date,NEW.direction) THEN
 RAISE EXCEPTION 'reservation_identity_immutable' USING ERRCODE='23514'; END IF;
 IF TG_OP='UPDATE' AND OLD.settled_at IS NOT NULL AND NEW.settled_at IS DISTINCT FROM OLD.settled_at THEN
 RAISE EXCEPTION 'settlement_immutable' USING ERRCODE='23514'; END IF;
 IF TG_OP='UPDATE' AND OLD.status IN ('boarded','no_show','operator_cancelled') AND
 (to_jsonb(NEW)-ARRAY['settled_at','updated_at','version']) IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['settled_at','updated_at','version'])
 AND NOT (OLD.status='no_show' AND NEW.status='boarded' AND OLD.settled_at IS NOT NULL AND
 (to_jsonb(NEW)-ARRAY['status','updated_at','version'])=(to_jsonb(OLD)-ARRAY['status','updated_at','version'])) THEN
 RAISE EXCEPTION 'reservation_terminal' USING ERRCODE='23514'; END IF;
 IF NEW.status='reserved' AND (TG_OP='INSERT' OR OLD.status<>'reserved' OR OLD.trip_id IS DISTINCT FROM NEW.trip_id) THEN
 SELECT * INTO t FROM app.trips WHERE id=NEW.trip_id FOR UPDATE;
 IF t.status<>'scheduled' OR t.service_date<>NEW.service_date OR NOT EXISTS(
 SELECT 1 FROM app.billing_periods b JOIN app.commute_assignments a ON a.period_id=b.id
 JOIN app.memberships m ON m.id=b.membership_id JOIN app.users u ON u.id=b.user_id
 WHERE b.id=NEW.period_id AND b.state='open' AND m.lifecycle='open' AND u.deleted_at IS NULL AND b.starts_at<=t.scheduled_at AND t.scheduled_at<b.effective_ends_at
 AND a.id=NEW.assignment_id AND a.effective_from<=NEW.service_date AND (a.effective_to IS NULL OR NEW.service_date<a.effective_to))
 OR EXISTS(SELECT 1 FROM app.membership_pauses WHERE period_id=NEW.period_id AND ended_at IS NULL)
 OR EXISTS(SELECT 1 FROM app.payment_access_blocks WHERE period_id=NEW.period_id AND released_at IS NULL)
 OR EXISTS(SELECT 1 FROM app.account_restrictions WHERE user_id=NEW.user_id AND released_at IS NULL) THEN
 RAISE EXCEPTION 'reservation_ineligible' USING ERRCODE='23514'; END IF;
 SELECT v.capacity INTO capacity FROM app.vehicles v WHERE id=t.vehicle_id;
 SELECT count(*) INTO used FROM app.reservations WHERE trip_id=t.id AND status IN ('reserved','boarded','no_show') AND id<>NEW.id;
 IF capacity IS NULL OR used>=capacity THEN RAISE EXCEPTION 'reservation_capacity' USING ERRCODE='23514'; END IF;
 END IF;
 RETURN NEW;
END $$;
COMMENT ON FUNCTION app.require_reservation_settlement() IS 'Receipt/source/attendance/exact debit commit together. A later no-show correction never rewrites the original economic reason.';
