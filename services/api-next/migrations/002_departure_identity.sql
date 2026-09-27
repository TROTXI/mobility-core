-- Append-only correction to the unlaunched replacement, not to the deployed API.
-- There is no sound way to infer which existing schedule revisions represent
-- the same recurring departure. Refuse populated experimental transport rather
-- than silently inventing identities or deleting somebody's fixtures.
LOCK TABLE app.service_schedules, app.trips IN ACCESS EXCLUSIVE MODE;
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM app.service_schedules) OR EXISTS (SELECT 1 FROM app.trips) THEN
    RAISE EXCEPTION 'departure_identity_requires_empty_transport' USING ERRCODE = '23514';
  END IF;
END $$;

-- Identity only; clock time and operating details belong to schedule revisions.
-- Multiple actual departures on a pattern have distinct IDs. A new revision of
-- an existing departure must reuse its ID, never allocate an implicit new one.
CREATE TABLE app.service_departures (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pattern_id uuid NOT NULL REFERENCES app.route_patterns(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE (id, pattern_id)
);
CREATE TRIGGER immutable_departure BEFORE UPDATE OR DELETE ON app.service_departures
  FOR EACH ROW EXECUTE FUNCTION app.append_only();

ALTER TABLE app.route_pattern_versions ADD CONSTRAINT pattern_version_owner
  UNIQUE (id, pattern_id);
ALTER TABLE app.service_schedules
  ADD COLUMN departure_id uuid NOT NULL,
  ADD COLUMN pattern_id uuid NOT NULL,
  ADD CONSTRAINT schedule_departure_owner FOREIGN KEY (departure_id, pattern_id)
    REFERENCES app.service_departures(id, pattern_id) ON DELETE RESTRICT,
  ADD CONSTRAINT schedule_pattern_version_owner FOREIGN KEY (pattern_version_id, pattern_id)
    REFERENCES app.route_pattern_versions(id, pattern_id) ON DELETE RESTRICT,
  ADD CONSTRAINT schedule_departure_version UNIQUE (id, departure_id, pattern_version_id);

ALTER TABLE app.trips
  ADD COLUMN departure_id uuid NOT NULL,
  ADD COLUMN service_date date NOT NULL CHECK (isfinite(service_date)),
  ADD COLUMN run_number smallint NOT NULL DEFAULT 1,
  ADD CONSTRAINT one_bus_per_departure_at_launch CHECK (run_number = 1),
  ADD CONSTRAINT trip_departure_occurrence UNIQUE (departure_id, service_date, run_number),
  ADD CONSTRAINT trip_schedule_departure_owner FOREIGN KEY (schedule_id, departure_id, pattern_version_id)
    REFERENCES app.service_schedules(id, departure_id, pattern_version_id) ON DELETE RESTRICT;

-- These columns are business identity, including after cancellation. Not a
-- generated date(scheduled_at), and not a partial unique index on live trips.
CREATE FUNCTION app.guard_trip_identity() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE s app.service_schedules;
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF NEW.departure_id IS DISTINCT FROM OLD.departure_id
      OR NEW.service_date IS DISTINCT FROM OLD.service_date
      OR NEW.run_number IS DISTINCT FROM OLD.run_number THEN
      RAISE EXCEPTION 'immutable_departure_occurrence' USING ERRCODE = '23514';
    END IF;
  ELSE
    SELECT * INTO s FROM app.service_schedules WHERE id = NEW.schedule_id;
    IF FOUND AND (NEW.service_date < s.effective_from
      OR (s.effective_to IS NOT NULL AND NEW.service_date > s.effective_to)
      OR NOT (extract(isodow FROM NEW.service_date)::smallint = ANY(s.weekdays))) THEN
      RAISE EXCEPTION 'service_date_not_in_schedule' USING ERRCODE = '23514';
    END IF;
  END IF;
  -- Do not compare service_date with the date of scheduled_at: a late evening
  -- service can be delayed past midnight and still belong to its original day.
  -- The existing trip guard still checks the operational timestamp against the
  -- selected pattern version and prevents edits after the trip has started.
  RETURN NEW;
END $$;
CREATE TRIGGER preserve_trip_identity BEFORE INSERT OR UPDATE ON app.trips
  FOR EACH ROW EXECUTE FUNCTION app.guard_trip_identity();

COMMENT ON TABLE app.service_departures IS 'Stable recurring departure within a directional pattern, independent of schedule/pattern revisions.';
COMMENT ON COLUMN app.service_schedules.departure_id IS 'Reuse for a new revision of the same departure; do not infer identity from clock time.';
COMMENT ON COLUMN app.trips.service_date IS 'Stored, immutable business service date in the Ghana timetable, NOT date(scheduled_at). Midnight delays retain it.';
COMMENT ON COLUMN app.trips.run_number IS 'Explicit run slot within a departure/service date. Launch permits exactly run 1; multi-bus allocation is not implemented.';
COMMENT ON CONSTRAINT trip_departure_occurrence ON app.trips IS 'Includes cancelled trips: retry/generation cannot resurrect a cancelled departure, even through another schedule revision.';
