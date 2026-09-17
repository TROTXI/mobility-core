-- New database only. This is NOT migration 046 for the deployed model.
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS btree_gist;
CREATE SCHEMA app;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA app FROM PUBLIC;

-- Identity anchors, not a replacement authentication implementation yet.
CREATE TABLE app.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  role text NOT NULL CHECK (role IN ('commuter', 'driver', 'admin')),
  display_name text,
  deleted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE app.drivers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid UNIQUE REFERENCES app.users(id) ON DELETE RESTRICT,
  name text NOT NULL CHECK (length(btrim(name)) > 0),
  archived_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE app.vehicles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  label text NOT NULL CHECK (length(btrim(label)) > 0),
  capacity integer NOT NULL CHECK (capacity BETWEEN 1 AND 500),
  archived_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE app.stops (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL CHECK (length(btrim(name)) > 0),
  latitude double precision NOT NULL CHECK (latitude BETWEEN -90 AND 90),
  longitude double precision NOT NULL CHECK (longitude BETWEEN -180 AND 180),
  archived_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE app.routes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL CHECK (length(btrim(name)) > 0),
  description text,
  accepts_driver_requests boolean NOT NULL DEFAULT false,
  archived_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE app.route_patterns (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id uuid NOT NULL REFERENCES app.routes(id) ON DELETE RESTRICT,
  direction text NOT NULL CHECK (direction IN ('outbound', 'return')),
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE (route_id, direction)
);
CREATE TABLE app.route_pattern_versions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pattern_id uuid NOT NULL REFERENCES app.route_patterns(id) ON DELETE RESTRICT,
  revision integer NOT NULL CHECK (revision > 0),
  state text NOT NULL DEFAULT 'draft' CHECK (state IN ('draft', 'published', 'retired')),
  effective_from timestamptz,
  effective_to timestamptz,
  geometry_id uuid,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE (pattern_id, revision),
  CHECK ((state = 'draft' AND effective_from IS NULL AND effective_to IS NULL)
    OR (state = 'published' AND effective_from IS NOT NULL)
    OR (state = 'retired' AND effective_from IS NOT NULL AND effective_to IS NOT NULL)),
  CHECK (effective_to IS NULL OR effective_to > effective_from),
  EXCLUDE USING gist (pattern_id WITH =, tstzrange(effective_from, effective_to, '[)') WITH &&)
    WHERE (state <> 'draft') DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE app.route_pattern_stops (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pattern_version_id uuid NOT NULL REFERENCES app.route_pattern_versions(id) ON DELETE RESTRICT,
  stop_id uuid NOT NULL REFERENCES app.stops(id) ON DELETE RESTRICT,
  ordinal integer NOT NULL CHECK (ordinal BETWEEN 0 AND 499),
  name text NOT NULL CHECK (length(btrim(name)) > 0),
  latitude double precision NOT NULL CHECK (latitude BETWEEN -90 AND 90),
  longitude double precision NOT NULL CHECK (longitude BETWEEN -180 AND 180),
  UNIQUE (pattern_version_id, ordinal),
  UNIQUE (id, pattern_version_id)
  -- No UNIQUE(version, stop): a loop may visit the same physical stop twice.
);
CREATE TABLE app.route_geometries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pattern_version_id uuid NOT NULL REFERENCES app.route_pattern_versions(id) ON DELETE RESTRICT,
  source text NOT NULL CHECK (source IN ('observed', 'configured')),
  state text NOT NULL DEFAULT 'draft' CHECK (state IN ('draft', 'published')),
  line geometry(LineString, 4326) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE (id, pattern_version_id),
  CHECK (NOT ST_IsEmpty(line) AND ST_NPoints(line) >= 2 AND ST_IsValid(line)),
  CHECK (ST_XMin(Box3D(line)) >= -180 AND ST_XMax(Box3D(line)) <= 180
    AND ST_YMin(Box3D(line)) >= -90 AND ST_YMax(Box3D(line)) <= 90)
);
CREATE TABLE app.geometry_stop_distances (
  geometry_id uuid NOT NULL,
  pattern_version_id uuid NOT NULL,
  stop_occurrence_id uuid NOT NULL,
  distance_meters double precision NOT NULL CHECK (distance_meters >= 0 AND distance_meters < 'Infinity'::float8),
  PRIMARY KEY (geometry_id, stop_occurrence_id),
  FOREIGN KEY (geometry_id, pattern_version_id) REFERENCES app.route_geometries(id, pattern_version_id) ON DELETE RESTRICT,
  FOREIGN KEY (stop_occurrence_id, pattern_version_id) REFERENCES app.route_pattern_stops(id, pattern_version_id) ON DELETE RESTRICT
);
ALTER TABLE app.route_pattern_versions ADD CONSTRAINT selected_geometry_belongs_to_version
  FOREIGN KEY (geometry_id, id) REFERENCES app.route_geometries(id, pattern_version_id) ON DELETE RESTRICT;

CREATE FUNCTION app.valid_weekdays(days smallint[]) RETURNS boolean LANGUAGE sql IMMUTABLE AS $$
  SELECT cardinality(days) BETWEEN 1 AND 7 AND array_position(days, NULL) IS NULL
    AND days <@ ARRAY[1,2,3,4,5,6,7]::smallint[]
    AND cardinality(days) = (SELECT count(DISTINCT d) FROM unnest(days) d)
$$;
CREATE TABLE app.service_schedules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pattern_version_id uuid NOT NULL REFERENCES app.route_pattern_versions(id) ON DELETE RESTRICT,
  service_window text NOT NULL CHECK (service_window IN ('morning', 'evening')),
  local_departure time NOT NULL,
  time_zone text NOT NULL DEFAULT 'Africa/Accra' CHECK (time_zone = 'Africa/Accra'),
  weekdays smallint[] NOT NULL CHECK (app.valid_weekdays(weekdays)),
  effective_from date NOT NULL,
  effective_to date CHECK (effective_to IS NULL OR effective_to >= effective_from),
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE (id, pattern_version_id)
);
CREATE TABLE app.trips (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  schedule_id uuid NOT NULL,
  pattern_version_id uuid NOT NULL,
  scheduled_at timestamptz NOT NULL,
  assigned_driver_id uuid REFERENCES app.drivers(id) ON DELETE RESTRICT,
  vehicle_id uuid REFERENCES app.vehicles(id) ON DELETE RESTRICT,
  status text NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'active', 'completed', 'cancelled')),
  current_stop_occurrence_id uuid,
  started_at timestamptz,
  completed_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  FOREIGN KEY (schedule_id, pattern_version_id) REFERENCES app.service_schedules(id, pattern_version_id) ON DELETE RESTRICT,
  FOREIGN KEY (current_stop_occurrence_id, pattern_version_id) REFERENCES app.route_pattern_stops(id, pattern_version_id) ON DELETE RESTRICT,
  CHECK ((status IN ('scheduled', 'cancelled') AND started_at IS NULL AND completed_at IS NULL)
    OR (status = 'active' AND started_at IS NOT NULL AND completed_at IS NULL)
    OR (status = 'completed' AND started_at IS NOT NULL AND completed_at IS NOT NULL AND completed_at >= started_at)),
  CHECK (status NOT IN ('scheduled', 'cancelled') OR current_stop_occurrence_id IS NULL),
  CHECK (status NOT IN ('active', 'completed') OR assigned_driver_id IS NOT NULL)
);
CREATE INDEX trips_driver_schedule ON app.trips(assigned_driver_id, scheduled_at, id);
CREATE INDEX trips_pattern_schedule ON app.trips(pattern_version_id, scheduled_at, id);
CREATE TABLE app.trip_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id uuid NOT NULL REFERENCES app.trips(id) ON DELETE RESTRICT,
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  operation text NOT NULL CHECK (operation IN ('assign', 'reschedule', 'start', 'complete', 'cancel', 'arrive', 'correct_arrival', 'reassign_version')),
  reason text,
  before_state jsonb NOT NULL,
  after_state jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE FUNCTION app.append_only() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN RAISE EXCEPTION 'append_only_history' USING ERRCODE = '23514'; END
$$;
CREATE TRIGGER trip_events_append_only BEFORE UPDATE OR DELETE ON app.trip_events
  FOR EACH ROW EXECUTE FUNCTION app.append_only();

CREATE FUNCTION app.touch_version() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.id <> OLD.id OR NEW.created_at <> OLD.created_at THEN
    RAISE EXCEPTION 'immutable_identity' USING ERRCODE = '23514';
  END IF;
  NEW.version := OLD.version + 1;
  NEW.updated_at := clock_timestamp();
  RETURN NEW;
END $$;
DO $$ DECLARE t text; BEGIN
  FOREACH t IN ARRAY ARRAY['drivers','vehicles','stops','routes','route_patterns','route_pattern_versions','trips'] LOOP
    EXECUTE format('CREATE TRIGGER bump_version BEFORE UPDATE ON app.%I FOR EACH ROW EXECUTE FUNCTION app.touch_version()', t);
  END LOOP;
END $$;

CREATE FUNCTION app.guard_pattern() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.route_id <> OLD.route_id OR NEW.direction <> OLD.direction THEN
    RAISE EXCEPTION 'immutable_pattern_direction' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER immutable_pattern BEFORE UPDATE ON app.route_patterns FOR EACH ROW EXECUTE FUNCTION app.guard_pattern();

CREATE FUNCTION app.guard_stop_snapshot() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v uuid; state text;
BEGIN
  v := CASE WHEN TG_OP = 'DELETE' THEN OLD.pattern_version_id ELSE NEW.pattern_version_id END;
  IF TG_OP = 'UPDATE' AND (NEW.pattern_version_id <> OLD.pattern_version_id OR NEW.id <> OLD.id) THEN
    RAISE EXCEPTION 'immutable_occurrence_identity' USING ERRCODE = '23514';
  END IF;
  -- Same lock as publication: a writer cannot observe draft, wait through a
  -- concurrent publish, and then rewrite the now-published stop snapshot.
  SELECT p.state INTO state FROM app.route_pattern_versions p WHERE id = v FOR UPDATE;
  IF state <> 'draft' OR EXISTS (SELECT 1 FROM app.route_geometries g WHERE g.pattern_version_id = v AND g.state = 'published') THEN
    RAISE EXCEPTION 'immutable_published_stops' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER protect_stop_snapshot BEFORE INSERT OR UPDATE OR DELETE ON app.route_pattern_stops
  FOR EACH ROW EXECUTE FUNCTION app.guard_stop_snapshot();

CREATE FUNCTION app.guard_geometry_distance() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v uuid; state text;
BEGIN
  v := CASE WHEN TG_OP = 'DELETE' THEN OLD.geometry_id ELSE NEW.geometry_id END;
  IF TG_OP = 'UPDATE' AND (NEW.geometry_id <> OLD.geometry_id OR NEW.stop_occurrence_id <> OLD.stop_occurrence_id OR NEW.pattern_version_id <> OLD.pattern_version_id) THEN
    RAISE EXCEPTION 'immutable_distance_identity' USING ERRCODE = '23514';
  END IF;
  SELECT g.state INTO state FROM app.route_geometries g WHERE id = v FOR UPDATE;
  IF state = 'published' THEN RAISE EXCEPTION 'immutable_published_geometry' USING ERRCODE = '23514'; END IF;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER protect_geometry_distances BEFORE INSERT OR UPDATE OR DELETE ON app.geometry_stop_distances
  FOR EACH ROW EXECUTE FUNCTION app.guard_geometry_distance();

CREATE FUNCTION app.guard_geometry() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND (NEW.id <> OLD.id OR NEW.pattern_version_id <> OLD.pattern_version_id) THEN
    RAISE EXCEPTION 'immutable_geometry_identity' USING ERRCODE = '23514';
  END IF;
  IF TG_OP <> 'INSERT' AND OLD.state = 'published' THEN
    RAISE EXCEPTION 'immutable_published_geometry' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  -- Lock version before publishing geometry so draft-stop edits serialize.
  PERFORM 1 FROM app.route_pattern_versions WHERE id = NEW.pattern_version_id FOR UPDATE;
  RETURN NEW;
END $$;
CREATE TRIGGER protect_geometry BEFORE INSERT OR UPDATE OR DELETE ON app.route_geometries
  FOR EACH ROW EXECUTE FUNCTION app.guard_geometry();

CREATE FUNCTION app.check_geometry() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE g app.route_geometries; n integer; total integer; bad boolean;
BEGIN
  SELECT * INTO g FROM app.route_geometries WHERE id = NEW.id;
  IF g.state <> 'published' THEN RETURN NULL; END IF;
  SELECT count(*) INTO n FROM app.geometry_stop_distances WHERE geometry_id = g.id;
  SELECT count(*) INTO total FROM app.route_pattern_stops WHERE pattern_version_id = g.pattern_version_id;
  SELECT EXISTS (SELECT 1 FROM (
    SELECT d.distance_meters, lag(d.distance_meters) OVER (ORDER BY s.ordinal) previous
    FROM app.geometry_stop_distances d JOIN app.route_pattern_stops s ON s.id = d.stop_occurrence_id
    WHERE d.geometry_id = g.id
  ) q WHERE q.distance_meters < q.previous OR q.distance_meters > ST_Length(g.line::geography) + 1) INTO bad;
  IF total < 2 OR n <> total OR bad THEN
    RAISE EXCEPTION 'incomplete_or_unordered_geometry_distances' USING ERRCODE = '23514';
  END IF;
  RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER complete_geometry AFTER INSERT OR UPDATE ON app.route_geometries
  DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION app.check_geometry();

CREATE FUNCTION app.guard_pattern_version() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF NEW.pattern_id <> OLD.pattern_id OR NEW.revision <> OLD.revision THEN
      RAISE EXCEPTION 'immutable_pattern_version_identity' USING ERRCODE = '23514';
    END IF;
    IF OLD.state <> 'draft' AND (NEW.state = 'draft' OR NEW.effective_from IS DISTINCT FROM OLD.effective_from
      OR (OLD.effective_to IS NOT NULL AND NEW.effective_to IS DISTINCT FROM OLD.effective_to)
      OR (OLD.state = 'retired' AND NEW.state <> 'retired')) THEN
      RAISE EXCEPTION 'immutable_published_version' USING ERRCODE = '23514';
    END IF;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER protect_pattern_version BEFORE UPDATE ON app.route_pattern_versions
  FOR EACH ROW EXECUTE FUNCTION app.guard_pattern_version();
CREATE FUNCTION app.check_pattern_version() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v app.route_pattern_versions; n integer; low integer; high integer;
BEGIN
  SELECT * INTO v FROM app.route_pattern_versions WHERE id = NEW.id;
  IF v.state = 'draft' THEN RETURN NULL; END IF;
  SELECT count(*), min(ordinal), max(ordinal) INTO n, low, high FROM app.route_pattern_stops WHERE pattern_version_id = v.id;
  IF n < 2 OR low <> 0 OR high <> n - 1 OR v.geometry_id IS NULL OR NOT EXISTS (
    SELECT 1 FROM app.route_geometries WHERE id = v.geometry_id AND state = 'published'
  ) THEN RAISE EXCEPTION 'incomplete_published_version' USING ERRCODE = '23514'; END IF;
  IF EXISTS (SELECT 1 FROM app.trips WHERE pattern_version_id = v.id AND status <> 'cancelled'
    AND (scheduled_at < v.effective_from OR (v.effective_to IS NOT NULL AND scheduled_at >= v.effective_to))) THEN
    RAISE EXCEPTION 'reassignment_required' USING ERRCODE = '23514';
  END IF;
  RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER complete_pattern_version AFTER INSERT OR UPDATE ON app.route_pattern_versions
  DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION app.check_pattern_version();

CREATE FUNCTION app.guard_schedule() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE s text; archived timestamptz;
BEGIN
  IF TG_OP <> 'INSERT' THEN RAISE EXCEPTION 'immutable_schedule_revision' USING ERRCODE = '23514'; END IF;
  SELECT state INTO s FROM app.route_pattern_versions WHERE id = NEW.pattern_version_id FOR UPDATE;
  IF s NOT IN ('published', 'retired') THEN RAISE EXCEPTION 'unpublished_pattern_version' USING ERRCODE = '23514'; END IF;
  SELECT r.archived_at INTO archived FROM app.routes r JOIN app.route_patterns p ON p.route_id=r.id
    JOIN app.route_pattern_versions v ON v.pattern_id=p.id WHERE v.id=NEW.pattern_version_id FOR SHARE OF r;
  IF archived IS NOT NULL THEN RAISE EXCEPTION 'archived_route' USING ERRCODE = '23514'; END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER protect_schedule BEFORE INSERT OR UPDATE OR DELETE ON app.service_schedules
  FOR EACH ROW EXECUTE FUNCTION app.guard_schedule();

CREATE FUNCTION app.guard_trip() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v app.route_pattern_versions; archived timestamptz;
BEGIN
  IF TG_OP = 'INSERT' AND NEW.status <> 'scheduled' THEN
    RAISE EXCEPTION 'new_trip_must_be_scheduled' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'UPDATE' THEN
    IF NEW.pattern_version_id <> OLD.pattern_version_id OR NEW.schedule_id <> OLD.schedule_id THEN
      -- Deliberately unavailable until the attributable reassignment command
      -- also handles commute assignments/reservations in a later stage-3 slice.
      RAISE EXCEPTION 'explicit_reassignment_required' USING ERRCODE = '23514';
    END IF;
    IF OLD.status IN ('completed', 'cancelled') THEN
      RAISE EXCEPTION 'immutable_terminal_trip' USING ERRCODE = '23514';
    END IF;
    IF OLD.status = 'active' AND (NEW.scheduled_at <> OLD.scheduled_at
      OR NEW.assigned_driver_id IS DISTINCT FROM OLD.assigned_driver_id OR NEW.vehicle_id IS DISTINCT FROM OLD.vehicle_id
      OR NEW.started_at IS DISTINCT FROM OLD.started_at) THEN
      RAISE EXCEPTION 'immutable_operated_trip' USING ERRCODE = '23514';
    END IF;
    IF NEW.status <> OLD.status AND NOT ((OLD.status = 'scheduled' AND NEW.status IN ('active','cancelled'))
      OR (OLD.status = 'active' AND NEW.status = 'completed')) THEN
      RAISE EXCEPTION 'illegal_trip_transition' USING ERRCODE = '23514';
    END IF;
  END IF;
  IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND (OLD.status = 'scheduled' AND NEW.status <> 'cancelled')) THEN
    SELECT * INTO v FROM app.route_pattern_versions WHERE id = NEW.pattern_version_id FOR UPDATE;
    SELECT r.archived_at INTO archived FROM app.routes r JOIN app.route_patterns p ON p.route_id = r.id
      WHERE p.id = v.pattern_id FOR SHARE OF r;
    IF v.state NOT IN ('published','retired') OR NEW.scheduled_at < v.effective_from
      OR (v.effective_to IS NOT NULL AND NEW.scheduled_at >= v.effective_to) OR archived IS NOT NULL THEN
      RAISE EXCEPTION 'unavailable_pattern_version' USING ERRCODE = '23514';
    END IF;
    IF NEW.assigned_driver_id IS NOT NULL THEN
      PERFORM 1 FROM app.drivers WHERE id = NEW.assigned_driver_id AND archived_at IS NULL FOR SHARE;
      IF NOT FOUND THEN RAISE EXCEPTION 'unavailable_driver' USING ERRCODE = '23514'; END IF;
    END IF;
    IF NEW.vehicle_id IS NOT NULL THEN
      PERFORM 1 FROM app.vehicles WHERE id = NEW.vehicle_id AND archived_at IS NULL FOR SHARE;
      IF NOT FOUND THEN RAISE EXCEPTION 'unavailable_vehicle' USING ERRCODE = '23514'; END IF;
    END IF;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER protect_trip BEFORE INSERT OR UPDATE ON app.trips FOR EACH ROW EXECUTE FUNCTION app.guard_trip();
CREATE TRIGGER retain_trip_history BEFORE DELETE ON app.trips FOR EACH ROW EXECUTE FUNCTION app.append_only();

COMMENT ON TABLE app.route_pattern_stops IS 'Immutable published stop occurrences; ordinal is zero-based, physical stops can repeat on loops.';
COMMENT ON TABLE app.route_geometries IS 'Published geometry plus complete ordered distances is immutable; improvements create a new revision.';
COMMENT ON COLUMN app.service_schedules.service_window IS 'Explicit service window; direction belongs to the route pattern, never inferred from a timestamp.';
COMMENT ON TABLE app.trip_events IS 'Append-only attributable command history. No phone, PIN, tokens or raw GPS payloads.';
