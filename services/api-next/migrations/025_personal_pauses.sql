-- Personal breaks are finite calendar intervals, not the open-ended,
-- consented waitlist pauses owned by 013. All dates use Africa/Accra.
CREATE FUNCTION app.personal_pause_now() RETURNS timestamptz LANGUAGE sql VOLATILE
 AS $$ SELECT clock_timestamp() $$;
CREATE TABLE app.personal_pauses (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 period_id uuid NOT NULL UNIQUE REFERENCES app.billing_periods(id) ON DELETE RESTRICT,
 user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
 start_date date NOT NULL CHECK(isfinite(start_date)),
 original_resume_date date NOT NULL CHECK(isfinite(original_resume_date)),
 resume_date date NOT NULL CHECK(isfinite(resume_date)),
 ends_before timestamptz NOT NULL CHECK(isfinite(ends_before)),
 state text NOT NULL DEFAULT 'planned' CHECK(state IN ('planned','completed','terminated')),
 settled_at timestamptz,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 CHECK(original_resume_date-start_date BETWEEN 3 AND 14),
 CHECK(resume_date>start_date AND resume_date<=original_resume_date),
 CHECK((state='planned')=(settled_at IS NULL))
);
COMMENT ON TABLE app.personal_pauses IS 'One personal break per paid period. Start inclusive, resume exclusive, calendar days in Ghana. No new rides, credit or refund. Shortening never restores cancelled reservations automatically.';
CREATE FUNCTION app.personal_pause_blocks(pid uuid, at_time timestamptz) RETURNS boolean LANGUAGE sql STABLE AS $$
 SELECT EXISTS(SELECT 1 FROM app.personal_pauses WHERE period_id=pid AND state<>'terminated'
 AND start_date<=(at_time AT TIME ZONE 'Africa/Accra')::date AND (at_time AT TIME ZONE 'Africa/Accra')::date<resume_date)
$$;
CREATE FUNCTION app.personal_service_day(pid uuid, day date) RETURNS boolean LANGUAGE sql STABLE AS $$
 SELECT EXISTS(SELECT 1 FROM app.commute_assignments a JOIN app.commute_selection_legs l ON l.selection_id=a.selection_id
 JOIN app.service_schedules s ON s.id=l.schedule_id WHERE a.period_id=pid AND a.effective_from<=day
 AND (a.effective_to IS NULL OR day<a.effective_to) AND s.effective_from<=day
 AND (s.effective_to IS NULL OR day<=s.effective_to) AND extract(isodow FROM day)::integer=ANY(s.weekdays))
$$;
CREATE FUNCTION app.guard_personal_pause() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE b app.billing_periods; today date; t uuid;
BEGIN
 PERFORM id FROM app.users WHERE id=NEW.user_id FOR UPDATE;
 SELECT * INTO b FROM app.billing_periods WHERE id=NEW.period_id FOR UPDATE;
 today := (app.personal_pause_now() AT TIME ZONE 'Africa/Accra')::date;
 IF TG_OP='INSERT' THEN
  IF b.user_id IS DISTINCT FROM NEW.user_id OR b.state<>'open' OR b.starts_at>app.personal_pause_now()
  OR b.effective_ends_at<=app.personal_pause_now() OR NEW.ends_before<>b.effective_ends_at
  OR NEW.start_date<=today OR (NEW.start_date::timestamp AT TIME ZONE 'Africa/Accra')>=b.effective_ends_at
  OR NOT app.personal_service_day(b.id,NEW.start_date) OR NOT app.personal_service_day(b.id,NEW.resume_date)
  OR NEW.state<>'planned' OR NEW.resume_date<>NEW.original_resume_date
  OR EXISTS(SELECT 1 FROM app.users WHERE id=NEW.user_id AND deleted_at IS NOT NULL)
  OR NOT EXISTS(SELECT 1 FROM app.memberships WHERE id=b.membership_id AND lifecycle='open')
  OR EXISTS(SELECT 1 FROM app.account_restrictions WHERE user_id=NEW.user_id AND released_at IS NULL)
  OR EXISTS(SELECT 1 FROM app.payment_access_blocks WHERE period_id=b.id AND released_at IS NULL)
  OR EXISTS(SELECT 1 FROM app.membership_pauses WHERE period_id=b.id AND ended_at IS NULL)
  OR EXISTS(SELECT 1 FROM app.commute_requests WHERE period_id=b.id AND status IN ('submitted','waitlisted','approved'))
  THEN RAISE EXCEPTION 'personal_pause_not_allowed' USING ERRCODE='23514'; END IF;
  -- Serialize against trip edits, then change only unused reservations. Existing
  -- settlement history is never rewritten even on an anomalous future-day run.
  FOR t IN SELECT DISTINCT trip_id FROM app.reservations WHERE period_id=b.id
    AND service_date>=NEW.start_date AND service_date<NEW.resume_date AND trip_id IS NOT NULL ORDER BY trip_id LOOP
   PERFORM id FROM app.trips WHERE id=t FOR UPDATE;
  END LOOP;
  IF EXISTS(SELECT 1 FROM app.reservations r LEFT JOIN app.trips t ON t.id=r.trip_id WHERE r.period_id=b.id
    AND r.service_date>=NEW.start_date AND r.service_date<NEW.resume_date
    AND (r.status IN ('boarded','no_show') OR (r.status='reserved' AND t.status='active'))) THEN
   RAISE EXCEPTION 'personal_pause_service_started' USING ERRCODE='23514'; END IF;
  UPDATE app.reservations SET status='declined' WHERE period_id=b.id AND service_date>=NEW.start_date
    AND service_date<NEW.resume_date AND status IN ('pending','reserved','unseated');
 ELSE
  IF OLD.state<>'planned' OR (to_jsonb(NEW)-ARRAY['resume_date','state','settled_at']) IS DISTINCT FROM
    (to_jsonb(OLD)-ARRAY['resume_date','state','settled_at']) THEN
   RAISE EXCEPTION 'personal_pause_immutable' USING ERRCODE='23514'; END IF;
  IF NEW.resume_date<>OLD.resume_date AND (NEW.state<>'planned' OR NEW.resume_date>=OLD.resume_date OR NEW.resume_date<=today
    OR NOT app.personal_service_day(b.id,NEW.resume_date)) THEN
   RAISE EXCEPTION 'personal_resume_not_allowed' USING ERRCODE='23514'; END IF;
  IF NEW.state='completed' AND (today<NEW.resume_date OR b.state<>'open' OR b.effective_ends_at<>NEW.ends_before) THEN
   RAISE EXCEPTION 'personal_pause_not_due' USING ERRCODE='23514'; END IF;
  IF NEW.state='terminated' AND b.state='open' AND NOT EXISTS(SELECT 1 FROM app.users WHERE id=NEW.user_id AND deleted_at IS NOT NULL) THEN
   RAISE EXCEPTION 'personal_pause_termination_requires_end' USING ERRCODE='23514'; END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER protect_personal_pause BEFORE INSERT OR UPDATE ON app.personal_pauses FOR EACH ROW EXECUTE FUNCTION app.guard_personal_pause();
CREATE TRIGGER retain_personal_pause BEFORE DELETE ON app.personal_pauses FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE FUNCTION app.apply_personal_pause_extension() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW.state='completed' AND OLD.state='planned' THEN
  UPDATE app.billing_periods SET effective_ends_at=NEW.ends_before+make_interval(days=>NEW.resume_date-NEW.start_date) WHERE id=NEW.period_id;
 END IF;
 RETURN NULL;
END $$;
CREATE TRIGGER extend_personal_pause AFTER UPDATE ON app.personal_pauses FOR EACH ROW EXECUTE FUNCTION app.apply_personal_pause_extension();
CREATE FUNCTION app.settle_personal_pauses(subject uuid) RETURNS integer LANGUAGE plpgsql SECURITY INVOKER AS $$
DECLARE n integer;
BEGIN
 PERFORM id FROM app.users WHERE id=subject FOR UPDATE;
 PERFORM id FROM app.billing_periods WHERE user_id=subject AND state='open' ORDER BY id FOR UPDATE;
 UPDATE app.personal_pauses SET state='completed',settled_at=app.personal_pause_now()
 WHERE user_id=subject AND state='planned' AND resume_date<=(app.personal_pause_now() AT TIME ZONE 'Africa/Accra')::date;
 GET DIAGNOSTICS n=ROW_COUNT; RETURN n;
END $$;
CREATE FUNCTION app.personal_pause_period_end() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW.state='closed' AND EXISTS(SELECT 1 FROM app.personal_pauses WHERE period_id=NEW.id AND state='planned') THEN
  RAISE EXCEPTION 'personal_pause_unsettled' USING ERRCODE='23514'; END IF;
 IF NEW.state='reversed' THEN
  UPDATE app.personal_pauses SET state='terminated',settled_at=app.personal_pause_now() WHERE period_id=NEW.id AND state='planned';
 END IF;
 RETURN NULL;
END $$;
CREATE TRIGGER personal_pause_period_end AFTER UPDATE ON app.billing_periods FOR EACH ROW WHEN (OLD.state IS DISTINCT FROM NEW.state) EXECUTE FUNCTION app.personal_pause_period_end();
CREATE FUNCTION app.personal_pause_account_end() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 UPDATE app.personal_pauses SET state='terminated',settled_at=app.personal_pause_now() WHERE user_id=NEW.id AND state='planned';
 RETURN NULL;
END $$;
CREATE TRIGGER personal_pause_account_end AFTER UPDATE ON app.users FOR EACH ROW WHEN (OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL) EXECUTE FUNCTION app.personal_pause_account_end();
CREATE FUNCTION app.guard_personal_pause_access() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE pid uuid; service_day date;
BEGIN
 IF TG_TABLE_NAME='reservations' THEN
  pid:=NEW.period_id; service_day:=NEW.service_date;
  IF NEW.status NOT IN ('reserved','pending') THEN RETURN NEW; END IF;
  IF TG_OP='UPDATE' AND NEW.status=OLD.status AND NEW.trip_id IS NOT DISTINCT FROM OLD.trip_id THEN RETURN NEW; END IF;
 ELSE
  pid:=NEW.period_id;
  SELECT service_date INTO service_day FROM app.reservations WHERE id=NEW.reservation_id;
 END IF;
 PERFORM id FROM app.users WHERE id=NEW.user_id FOR UPDATE;
 PERFORM id FROM app.billing_periods WHERE id=pid FOR UPDATE;
 IF app.personal_pause_blocks(pid,service_day::timestamp AT TIME ZONE 'Africa/Accra')
 OR (TG_TABLE_NAME='reservation_charges' AND app.personal_pause_blocks(pid,app.personal_pause_now())) THEN
  RAISE EXCEPTION 'personal_pause_active' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER personal_pause_reservation BEFORE INSERT OR UPDATE ON app.reservations FOR EACH ROW EXECUTE FUNCTION app.guard_personal_pause_access();
CREATE TRIGGER personal_pause_charge BEFORE INSERT ON app.reservation_charges FOR EACH ROW EXECUTE FUNCTION app.guard_personal_pause_access();
CREATE FUNCTION app.guard_pause_overlap() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 PERFORM id FROM app.users WHERE id=NEW.user_id FOR UPDATE;
 IF EXISTS(SELECT 1 FROM app.personal_pauses WHERE period_id=NEW.period_id AND state='planned') THEN
  RAISE EXCEPTION 'personal_pause_pending' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER exclude_personal_pause BEFORE INSERT ON app.membership_pauses FOR EACH ROW EXECUTE FUNCTION app.guard_pause_overlap();
CREATE TRIGGER exclude_personal_pause BEFORE INSERT ON app.commute_requests FOR EACH ROW EXECUTE FUNCTION app.guard_pause_overlap();
ALTER TABLE app.membership_commands DROP CONSTRAINT membership_commands_operation_check;
ALTER TABLE app.membership_commands ADD CHECK(operation IN ('createCommuteRequest','withdrawCommuteRequest','decideCommuteRequest','createCommuteSlot','retireCommuteSlot','decideReservation','createAccountRestriction','releaseAccountRestriction','createPersonalPause','resumePersonalPause'));
