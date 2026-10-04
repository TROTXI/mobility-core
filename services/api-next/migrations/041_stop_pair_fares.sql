-- Preserve corridor-wide fares for existing purchases and legacy transfers.
-- New subscription offers will quote an explicit, directional stop pair.
ALTER TABLE app.route_fares
  ADD COLUMN pattern_version_id uuid REFERENCES app.route_pattern_versions(id) ON DELETE RESTRICT,
  ADD COLUMN pickup_occurrence_id uuid,
  ADD COLUMN dropoff_occurrence_id uuid,
  ADD FOREIGN KEY(pickup_occurrence_id,pattern_version_id)
    REFERENCES app.route_pattern_stops(id,pattern_version_id) ON DELETE RESTRICT,
  ADD FOREIGN KEY(dropoff_occurrence_id,pattern_version_id)
    REFERENCES app.route_pattern_stops(id,pattern_version_id) ON DELETE RESTRICT,
  ADD CONSTRAINT fare_pair_complete CHECK (
    num_nonnulls(pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id) IN (0,3)
  );
-- The original exclusion grouped every journey on a route together.
DO $$ DECLARE constraint_name text;
BEGIN
  SELECT conname INTO STRICT constraint_name FROM pg_constraint
    WHERE conrelid='app.route_fares'::regclass AND contype='x';
  EXECUTE format('ALTER TABLE app.route_fares DROP CONSTRAINT %I', constraint_name);
END $$;
ALTER TABLE app.route_fares
  ADD CONSTRAINT legacy_route_fare_window EXCLUDE USING gist
    (route_id WITH =, tstzrange(effective_from,effective_to,'[)') WITH &&)
    WHERE (pattern_version_id IS NULL),
  ADD CONSTRAINT stop_pair_fare_window EXCLUDE USING gist
    (pattern_version_id WITH =,pickup_occurrence_id WITH =,dropoff_occurrence_id WITH =,
     tstzrange(effective_from,effective_to,'[)') WITH &&)
    WHERE (pattern_version_id IS NOT NULL);

CREATE FUNCTION app.validate_stop_pair_fare() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.pattern_version_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM app.route_pattern_versions v JOIN app.route_patterns p ON p.id=v.pattern_id
    JOIN app.route_pattern_stops a ON a.pattern_version_id=v.id AND a.id=NEW.pickup_occurrence_id
    JOIN app.route_pattern_stops b ON b.pattern_version_id=v.id AND b.id=NEW.dropoff_occurrence_id
    WHERE v.id=NEW.pattern_version_id AND p.route_id=NEW.route_id AND a.ordinal<b.ordinal
      AND v.state='published'
  ) THEN
    RAISE EXCEPTION 'invalid_fare_stop_pair' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER validate_stop_pair_fare BEFORE INSERT ON app.route_fares
  FOR EACH ROW EXECUTE FUNCTION app.validate_stop_pair_fare();
COMMENT ON COLUMN app.route_fares.pattern_version_id IS
  'NULL means legacy corridor pricing. A non-null value identifies a directional stop-pair fare on this immutable pattern version. Never sum intermediate segments implicitly.';
