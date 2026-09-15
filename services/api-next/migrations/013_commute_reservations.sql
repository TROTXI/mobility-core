-- 013 owns commute choices, funded reservations and period pauses. 014 is GPS;
-- 015 owns boarding proofs and settlement. Applied 001--012 remain unchanged.
-- A selection is an immutable paired commute shared by a slot, request or
-- assignment. It is NOT a purchase: moving it never rewrites purchased terms.
CREATE TABLE app.commute_selections (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 route_id uuid NOT NULL REFERENCES app.routes(id) ON DELETE RESTRICT
);
CREATE TABLE app.commute_selection_legs (
 selection_id uuid NOT NULL REFERENCES app.commute_selections(id) ON DELETE RESTRICT,
 direction text NOT NULL CHECK(direction IN ('outbound','return')),
 schedule_id uuid NOT NULL,
 pattern_version_id uuid NOT NULL,
 pickup_occurrence_id uuid NOT NULL,
 dropoff_occurrence_id uuid NOT NULL,
 PRIMARY KEY(selection_id,direction),
 UNIQUE(selection_id,direction,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id),
 FOREIGN KEY(schedule_id,pattern_version_id) REFERENCES app.service_schedules(id,pattern_version_id) ON DELETE RESTRICT,
 FOREIGN KEY(pickup_occurrence_id,pattern_version_id) REFERENCES app.route_pattern_stops(id,pattern_version_id) ON DELETE RESTRICT,
 FOREIGN KEY(dropoff_occurrence_id,pattern_version_id) REFERENCES app.route_pattern_stops(id,pattern_version_id) ON DELETE RESTRICT
);
CREATE FUNCTION app.validate_commute_selection() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE sid uuid; total integer; valid integer; windows integer;
BEGIN
 IF TG_TABLE_NAME='commute_selections' THEN sid:=NEW.id; ELSE sid:=NEW.selection_id; END IF;
 SELECT count(*),count(*) FILTER(WHERE p.route_id=s.route_id AND p.direction=l.direction AND a.ordinal<b.ordinal),
 count(DISTINCT d.service_window) INTO total,valid,windows
 FROM app.commute_selection_legs l JOIN app.commute_selections s ON s.id=l.selection_id
 JOIN app.service_schedules d ON d.id=l.schedule_id
 JOIN app.route_pattern_versions v ON v.id=l.pattern_version_id JOIN app.route_patterns p ON p.id=v.pattern_id
 JOIN app.route_pattern_stops a ON a.id=l.pickup_occurrence_id JOIN app.route_pattern_stops b ON b.id=l.dropoff_occurrence_id
 WHERE l.selection_id=sid;
 IF total<>2 OR valid<>2 OR windows<>2 THEN RAISE EXCEPTION 'invalid_commute_selection' USING ERRCODE='23514'; END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER complete_commute_selection AFTER INSERT ON app.commute_selections
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION app.validate_commute_selection();
CREATE CONSTRAINT TRIGGER valid_commute_legs AFTER INSERT ON app.commute_selection_legs
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION app.validate_commute_selection();
CREATE TRIGGER immutable_commute_selection BEFORE UPDATE OR DELETE ON app.commute_selections FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE TRIGGER immutable_commute_legs BEFORE UPDATE OR DELETE ON app.commute_selection_legs FOR EACH ROW EXECUTE FUNCTION app.append_only();

ALTER TABLE app.billing_periods ADD UNIQUE(id,membership_id,user_id);
CREATE TABLE app.commute_slots (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 selection_id uuid NOT NULL REFERENCES app.commute_selections(id) ON DELETE RESTRICT,
 available_from date NOT NULL CHECK(isfinite(available_from)),
 state text NOT NULL DEFAULT 'available' CHECK(state IN ('available','held','assigned','retired')),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(), updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 version integer NOT NULL DEFAULT 1 CHECK(version>0)
);
CREATE TABLE app.commute_requests (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 user_id uuid NOT NULL, membership_id uuid NOT NULL, period_id uuid NOT NULL,
 selection_id uuid NOT NULL REFERENCES app.commute_selections(id) ON DELETE RESTRICT,
 requested_date date NOT NULL CHECK(isfinite(requested_date)),
 pause_consent boolean NOT NULL DEFAULT false,
 note text CHECK(length(note)<=2000), decision_note text CHECK(length(decision_note)<=2000),
 status text NOT NULL DEFAULT 'submitted' CHECK(status IN ('submitted','waitlisted','approved','applied','rejected','cancelled')),
 slot_id uuid REFERENCES app.commute_slots(id) ON DELETE RESTRICT,
 effective_date date CHECK(isfinite(effective_date)),
 decided_by uuid REFERENCES app.users(id) ON DELETE RESTRICT,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(), updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 version integer NOT NULL DEFAULT 1 CHECK(version>0),
 FOREIGN KEY(period_id,membership_id,user_id) REFERENCES app.billing_periods(id,membership_id,user_id) ON DELETE RESTRICT,
 UNIQUE(id,period_id,user_id),
 CHECK((status IN ('approved','applied'))=(slot_id IS NOT NULL AND effective_date IS NOT NULL)),
 CHECK(effective_date IS NULL OR effective_date>=requested_date),
 CHECK(status='submitted' OR decided_by IS NOT NULL)
);
CREATE UNIQUE INDEX one_open_commute_request ON app.commute_requests(user_id) WHERE status IN ('submitted','waitlisted','approved');
CREATE UNIQUE INDEX one_slot_pending_claim ON app.commute_requests(slot_id) WHERE status='approved';
CREATE TABLE app.commute_assignments (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), user_id uuid NOT NULL, membership_id uuid NOT NULL, period_id uuid NOT NULL,
 selection_id uuid NOT NULL REFERENCES app.commute_selections(id) ON DELETE RESTRICT,
 purchase_id uuid UNIQUE REFERENCES app.purchases(id) ON DELETE RESTRICT,
 request_id uuid UNIQUE,
 effective_from date NOT NULL CHECK(isfinite(effective_from)), effective_to date CHECK(isfinite(effective_to)),
 FOREIGN KEY(period_id,membership_id,user_id) REFERENCES app.billing_periods(id,membership_id,user_id) ON DELETE RESTRICT,
 FOREIGN KEY(purchase_id,user_id) REFERENCES app.purchases(id,user_id) ON DELETE RESTRICT,
 FOREIGN KEY(request_id,period_id,user_id) REFERENCES app.commute_requests(id,period_id,user_id) ON DELETE RESTRICT,
 UNIQUE(id,period_id,user_id,selection_id),
 CHECK((purchase_id IS NOT NULL)::integer+(request_id IS NOT NULL)::integer=1),
 CHECK(effective_to IS NULL OR effective_to>=effective_from),
 EXCLUDE USING gist(membership_id WITH =,daterange(effective_from,effective_to,'[)') WITH &&)
);
CREATE TABLE app.membership_pauses (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), request_id uuid NOT NULL, period_id uuid NOT NULL, user_id uuid NOT NULL,
 started_at timestamptz NOT NULL CHECK(isfinite(started_at)), ended_at timestamptz CHECK(isfinite(ended_at)),
 ends_before timestamptz NOT NULL, ends_after timestamptz,
 end_reason text CHECK(end_reason IN ('resumed','period_ended')),
 FOREIGN KEY(request_id,period_id,user_id) REFERENCES app.commute_requests(id,period_id,user_id) ON DELETE RESTRICT,
 CHECK(started_at<ends_before),
 CHECK((ended_at IS NULL AND ends_after IS NULL AND end_reason IS NULL) OR
 (ended_at>=started_at AND end_reason IS NOT NULL AND ends_after IS NOT NULL AND
 ((end_reason='resumed' AND ends_after=ends_before+(ended_at-started_at)) OR (end_reason='period_ended' AND ends_after=ends_before))))
);
CREATE UNIQUE INDEX one_active_membership_pause ON app.membership_pauses(period_id) WHERE ended_at IS NULL;
CREATE TABLE app.account_restrictions (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
 actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
 reason text NOT NULL CHECK(length(btrim(reason)) BETWEEN 1 AND 2000), review_at timestamptz NOT NULL CHECK(isfinite(review_at)),
 released_at timestamptz, released_by uuid REFERENCES app.users(id) ON DELETE RESTRICT,
 release_reason text CHECK(length(btrim(release_reason)) BETWEEN 1 AND 2000),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(), updated_at timestamptz NOT NULL DEFAULT clock_timestamp(), version integer NOT NULL DEFAULT 1,
 CHECK((released_at IS NULL AND released_by IS NULL AND release_reason IS NULL) OR
 (released_at IS NOT NULL AND released_by IS NOT NULL AND release_reason IS NOT NULL))
);
CREATE INDEX active_account_restrictions ON app.account_restrictions(user_id) WHERE released_at IS NULL;

ALTER TABLE app.trips ADD UNIQUE(id,schedule_id,pattern_version_id);
CREATE TABLE app.reservations (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
 period_id uuid, assignment_id uuid, selection_id uuid,
 direction text NOT NULL CHECK(direction IN ('outbound','return')), service_date date NOT NULL CHECK(isfinite(service_date)),
 trip_id uuid, schedule_id uuid, pattern_version_id uuid, pickup_occurrence_id uuid, dropoff_occurrence_id uuid,
 status text NOT NULL CHECK(status IN ('pending','reserved','declined','unseated','boarded','no_show','operator_cancelled')),
 source text NOT NULL CHECK(source IN ('confirmation','default')),
 settled_at timestamptz,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(), updated_at timestamptz NOT NULL DEFAULT clock_timestamp(), version integer NOT NULL DEFAULT 1,
 FOREIGN KEY(assignment_id,period_id,user_id,selection_id) REFERENCES app.commute_assignments(id,period_id,user_id,selection_id) ON DELETE RESTRICT,
 FOREIGN KEY(selection_id,direction,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id)
 REFERENCES app.commute_selection_legs(selection_id,direction,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id) ON DELETE RESTRICT,
 FOREIGN KEY(trip_id,schedule_id,pattern_version_id) REFERENCES app.trips(id,schedule_id,pattern_version_id) ON DELETE RESTRICT,
 CHECK((period_id IS NULL AND assignment_id IS NULL AND selection_id IS NULL AND trip_id IS NULL AND schedule_id IS NULL
 AND pattern_version_id IS NULL AND pickup_occurrence_id IS NULL AND dropoff_occurrence_id IS NULL AND status IN ('declined','pending','unseated')) OR
 (period_id IS NOT NULL AND assignment_id IS NOT NULL AND selection_id IS NOT NULL AND trip_id IS NOT NULL AND schedule_id IS NOT NULL
 AND pattern_version_id IS NOT NULL AND pickup_occurrence_id IS NOT NULL AND dropoff_occurrence_id IS NOT NULL)),
 CHECK(settled_at IS NULL OR status IN ('boarded','no_show'))
);
CREATE UNIQUE INDEX one_reservation_intent ON app.reservations(user_id,service_date,direction) WHERE status<>'operator_cancelled';
CREATE INDEX reservations_trip_seats ON app.reservations(trip_id) WHERE status IN ('reserved','boarded','no_show');
CREATE INDEX reservations_period_unsettled ON app.reservations(period_id) WHERE status='reserved' OR (status IN ('boarded','no_show') AND settled_at IS NULL);
CREATE TABLE app.reservation_prompts (
 reservation_id uuid PRIMARY KEY REFERENCES app.reservations(id) ON DELETE RESTRICT,
 requested_by uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TRIGGER immutable_reservation_prompts BEFORE UPDATE OR DELETE ON app.reservation_prompts FOR EACH ROW EXECUTE FUNCTION app.append_only();
COMMENT ON TABLE app.reservation_prompts IS 'Durable ask intent, exactly one per reservation. Not evidence of external notification delivery. Delivery composition must recheck current reservation/account eligibility.';

-- App commands share the rider lock with payments. The additional trip lock
-- serializes seat acquisition with trip edits; cancellation takes no rider lock.
CREATE FUNCTION app.guard_reservation() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE t app.trips; capacity integer; used integer;
BEGIN
 IF TG_OP='UPDATE' AND (OLD.user_id,OLD.service_date,OLD.direction) IS DISTINCT FROM (NEW.user_id,NEW.service_date,NEW.direction) THEN
 RAISE EXCEPTION 'reservation_identity_immutable' USING ERRCODE='23514'; END IF;
 IF TG_OP='UPDATE' AND OLD.status IN ('boarded','no_show','operator_cancelled') AND
 (to_jsonb(NEW)-ARRAY['settled_at','updated_at','version']) IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['settled_at','updated_at','version']) THEN
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
CREATE TRIGGER protect_reservation BEFORE INSERT OR UPDATE ON app.reservations FOR EACH ROW EXECUTE FUNCTION app.guard_reservation();

CREATE TABLE app.membership_commands (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
 operation text NOT NULL CHECK(operation IN ('createCommuteRequest','withdrawCommuteRequest','decideCommuteRequest','createCommuteSlot','retireCommuteSlot','decideReservation','createAccountRestriction','releaseAccountRestriction')),
 target text NOT NULL CHECK(length(target) BETWEEN 1 AND 128), key_hash text NOT NULL CHECK(key_hash ~ '^[a-f0-9]{64}$'),
 input_hash text NOT NULL CHECK(input_hash ~ '^[a-f0-9]{64}$'), resource_id uuid NOT NULL,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(), UNIQUE(actor_user_id,operation,target,key_hash), UNIQUE(id,actor_user_id)
);
CREATE TABLE app.membership_events (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), command_id uuid NOT NULL, actor_user_id uuid NOT NULL,
 resource_id uuid NOT NULL, action text NOT NULL CHECK(length(action) BETWEEN 1 AND 100),
 occurred_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 FOREIGN KEY(command_id,actor_user_id) REFERENCES app.membership_commands(id,actor_user_id) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED
);
CREATE TRIGGER immutable_membership_commands BEFORE UPDATE OR DELETE ON app.membership_commands FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE TRIGGER immutable_membership_events BEFORE UPDATE OR DELETE ON app.membership_events FOR EACH ROW EXECUTE FUNCTION app.append_only();
COMMENT ON TABLE app.membership_commands IS 'Receipt stores identity and input digest, never free-text or response snapshots. Replay re-authorizes and renders current resource state, not stale access.';
COMMENT ON TABLE app.membership_events IS 'Attributable action history without rider notes. Erasable notes live on requests; events never claim note retention.';
COMMENT ON COLUMN app.reservations.settled_at IS '015 settlement boundary: reserved/boarded/no_show without settlement blocks period close. Unseated and declined are never chargeable.';
COMMENT ON TABLE app.commute_slots IS 'Ops-managed recurring transfer quota for an exact paired commute. Not initial purchase capacity or one-trip seating.';

DO $$ DECLARE t text; BEGIN
 FOREACH t IN ARRAY ARRAY['commute_slots','commute_requests','account_restrictions','reservations'] LOOP
 EXECUTE format('CREATE TRIGGER bump_version BEFORE UPDATE ON app.%I FOR EACH ROW EXECUTE FUNCTION app.touch_version()',t);
 END LOOP;
END $$;
CREATE FUNCTION app.guard_membership_pause() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF TG_OP='INSERT' THEN
 IF NOT EXISTS(SELECT 1 FROM app.commute_requests r JOIN app.billing_periods b ON b.id=r.period_id
 WHERE r.id=NEW.request_id AND r.pause_consent AND r.status='waitlisted' AND b.state='open'
 AND b.starts_at<=NEW.started_at AND b.effective_ends_at=NEW.ends_before) THEN
 RAISE EXCEPTION 'pause_requires_consent_and_coverage' USING ERRCODE='23514'; END IF;
 ELSIF OLD.ended_at IS NOT NULL OR (to_jsonb(NEW)-ARRAY['ended_at','ends_after','end_reason']) IS DISTINCT FROM
 (to_jsonb(OLD)-ARRAY['ended_at','ends_after','end_reason']) THEN
 RAISE EXCEPTION 'pause_history_immutable' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER protect_membership_pause BEFORE INSERT OR UPDATE ON app.membership_pauses FOR EACH ROW EXECUTE FUNCTION app.guard_membership_pause();
CREATE FUNCTION app.guard_commute_assignment() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF TG_OP='UPDATE' AND ((to_jsonb(NEW)-'effective_to') IS DISTINCT FROM (to_jsonb(OLD)-'effective_to') OR OLD.effective_to IS NOT NULL) THEN
 RAISE EXCEPTION 'commute_assignment_immutable' USING ERRCODE='23514'; END IF;
 IF TG_OP='INSERT' AND NEW.purchase_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM app.billing_periods WHERE id=NEW.period_id AND purchase_id=NEW.purchase_id) THEN
 RAISE EXCEPTION 'assignment_purchase_mismatch' USING ERRCODE='23514'; END IF;
 IF TG_OP='INSERT' AND NEW.purchase_id IS NOT NULL AND (EXISTS(
 SELECT direction,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id FROM app.purchase_legs WHERE purchase_id=NEW.purchase_id
 EXCEPT SELECT direction,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id FROM app.commute_selection_legs WHERE selection_id=NEW.selection_id)
 OR (SELECT route_id FROM app.purchases WHERE id=NEW.purchase_id)<>(SELECT route_id FROM app.commute_selections WHERE id=NEW.selection_id)) THEN
 RAISE EXCEPTION 'assignment_purchase_legs_mismatch' USING ERRCODE='23514'; END IF;
 IF TG_OP='INSERT' AND NEW.request_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM app.commute_requests r JOIN app.commute_slots s ON s.id=r.slot_id
 WHERE r.id=NEW.request_id AND r.status='approved' AND r.selection_id=NEW.selection_id AND s.state='held' AND NEW.effective_from>=r.effective_date) THEN
 RAISE EXCEPTION 'assignment_requires_approved_request' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER protect_commute_assignment BEFORE INSERT OR UPDATE ON app.commute_assignments FOR EACH ROW EXECUTE FUNCTION app.guard_commute_assignment();
CREATE FUNCTION app.guard_commute_request() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF (to_jsonb(NEW)-ARRAY['status','slot_id','effective_date','decided_by','note','decision_note','updated_at','version']) IS DISTINCT FROM
 (to_jsonb(OLD)-ARRAY['status','slot_id','effective_date','decided_by','note','decision_note','updated_at','version']) THEN
 RAISE EXCEPTION 'request_terms_immutable' USING ERRCODE='23514'; END IF;
 IF OLD.status IN ('applied','cancelled','rejected') AND NEW.status<>OLD.status THEN RAISE EXCEPTION 'request_terminal' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER protect_commute_request BEFORE UPDATE ON app.commute_requests FOR EACH ROW EXECUTE FUNCTION app.guard_commute_request();

-- Every close/reversal writer gets the same cleanup. No callback may silently
-- close a paused or unsettled period. A reversal cancels only unused seats;
-- historical boarding remains for recovery review / 015 settlement.
CREATE FUNCTION app.end_period_commute() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW.state=OLD.state THEN RETURN NEW; END IF;
 IF NEW.state='closed' AND (EXISTS(SELECT 1 FROM app.membership_pauses WHERE period_id=NEW.id AND ended_at IS NULL)
 OR EXISTS(SELECT 1 FROM app.reservations WHERE period_id=NEW.id AND (status='reserved' OR (status IN ('boarded','no_show') AND settled_at IS NULL)))) THEN
 RAISE EXCEPTION 'period_has_unsettled_service' USING ERRCODE='23514'; END IF;
 IF NEW.state IN ('closed','reversed') THEN
 UPDATE app.membership_pauses SET ended_at=greatest(clock_timestamp(),started_at),ends_after=ends_before,end_reason='period_ended'
 WHERE period_id=NEW.id AND ended_at IS NULL;
 UPDATE app.commute_slots SET state='available' WHERE id IN (SELECT r.slot_id FROM app.commute_requests r WHERE r.period_id=NEW.id AND
 (r.status='approved' OR (r.status='applied' AND EXISTS(SELECT 1 FROM app.commute_assignments a WHERE a.request_id=r.id AND a.effective_to IS NULL))));
 UPDATE app.commute_requests SET status='cancelled',slot_id=NULL,effective_date=NULL,decided_by=coalesce(decided_by,user_id),decision_note=NULL
 WHERE period_id=NEW.id AND status IN ('submitted','waitlisted','approved');
 UPDATE app.commute_assignments SET effective_to=greatest(effective_from,(CASE WHEN NEW.state='closed' THEN NEW.effective_ends_at ELSE clock_timestamp() END AT TIME ZONE 'Africa/Accra')::date)
 WHERE period_id=NEW.id AND effective_to IS NULL;
 UPDATE app.reservations SET status='operator_cancelled' WHERE period_id=NEW.id AND status IN ('reserved','pending','unseated');
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER finish_period_commute BEFORE UPDATE ON app.billing_periods FOR EACH ROW EXECUTE FUNCTION app.end_period_commute();

CREATE FUNCTION app.retire_rider_commute(subject uuid,erase_notes boolean) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
 UPDATE app.commute_slots SET state='available' WHERE id IN (SELECT r.slot_id FROM app.commute_requests r WHERE r.user_id=subject AND
 (r.status='approved' OR (r.status='applied' AND EXISTS(SELECT 1 FROM app.commute_assignments a WHERE a.request_id=r.id AND a.effective_to IS NULL))));
 UPDATE app.membership_pauses SET ended_at=greatest(started_at,clock_timestamp()),ends_after=ends_before,end_reason='period_ended' WHERE user_id=subject AND ended_at IS NULL;
 UPDATE app.commute_requests SET status='cancelled',slot_id=NULL,effective_date=NULL,decided_by=coalesce(decided_by,user_id) WHERE user_id=subject AND status IN ('submitted','waitlisted','approved');
 UPDATE app.commute_assignments SET effective_to=greatest(effective_from,(clock_timestamp() AT TIME ZONE 'Africa/Accra')::date) WHERE user_id=subject AND effective_to IS NULL;
 UPDATE app.reservations SET status='operator_cancelled' WHERE user_id=subject AND status IN ('pending','reserved','unseated');
 IF erase_notes THEN UPDATE app.commute_requests SET note=NULL,decision_note=NULL WHERE user_id=subject; END IF;
END $$;
CREATE FUNCTION app.retire_membership_commute() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF TG_TABLE_NAME='users' THEN
 IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN PERFORM app.retire_rider_commute(NEW.id,true); END IF;
 ELSE
 IF OLD.lifecycle='open' AND NEW.lifecycle='ended' THEN PERFORM app.retire_rider_commute(NEW.user_id,false); END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER erase_rider_commute AFTER UPDATE ON app.users FOR EACH ROW EXECUTE FUNCTION app.retire_membership_commute();
CREATE TRIGGER end_membership_commute AFTER UPDATE ON app.memberships FOR EACH ROW EXECUTE FUNCTION app.retire_membership_commute();

-- 012 could already have created disposable paid fixtures. Their initial
-- commute is unambiguous: frozen purchase legs, not mutable route defaults.
-- Installers serialize financial writes while materializing that exact source.
LOCK TABLE app.billing_periods,app.purchases,app.purchase_legs IN ACCESS EXCLUSIVE MODE;
DO $$ DECLARE period_row record; selection uuid; BEGIN
 FOR period_row IN SELECT b.*,p.route_id FROM app.billing_periods b JOIN app.purchases p ON p.id=b.purchase_id
 JOIN app.memberships m ON m.id=b.membership_id JOIN app.users u ON u.id=b.user_id
 WHERE b.state='open' AND m.lifecycle='open' AND u.deleted_at IS NULL ORDER BY b.id LOOP
 INSERT INTO app.commute_selections(route_id) VALUES (period_row.route_id) RETURNING id INTO selection;
 INSERT INTO app.commute_selection_legs SELECT selection,direction,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id FROM app.purchase_legs WHERE purchase_id=period_row.purchase_id;
 INSERT INTO app.commute_assignments(user_id,membership_id,period_id,selection_id,purchase_id,effective_from)
 VALUES (period_row.user_id,period_row.membership_id,period_row.id,selection,period_row.purchase_id,(period_row.starts_at AT TIME ZONE 'Africa/Accra')::date);
 END LOOP;
END $$;
