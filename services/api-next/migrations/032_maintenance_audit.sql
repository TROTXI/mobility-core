-- A worker session is minted by the server, never inferred from caller-controlled
-- client metadata. Existing sessions remain interactive.
ALTER TABLE app.auth_sessions ADD COLUMN issued_for text NOT NULL DEFAULT 'interactive'
  CHECK (issued_for IN ('interactive','maintenance'));
CREATE FUNCTION app.guard_session_origin() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.issued_for IS DISTINCT FROM OLD.issued_for THEN
    RAISE EXCEPTION 'session_origin_immutable' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER immutable_session_origin BEFORE UPDATE ON app.auth_sessions
  FOR EACH ROW EXECUTE FUNCTION app.guard_session_origin();

CREATE TABLE app.maintenance_run_starts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  operation text NOT NULL CHECK (length(operation) BETWEEN 1 AND 80),
  origin text NOT NULL CHECK (origin IN ('api','worker')),
  started_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX maintenance_run_starts_recent ON app.maintenance_run_starts(started_at DESC,id DESC);
CREATE TRIGGER immutable_maintenance_starts BEFORE UPDATE OR DELETE ON app.maintenance_run_starts
  FOR EACH ROW EXECUTE FUNCTION app.append_only();

-- An absent outcome is itself evidence that the process stopped mid-run. A
-- separate append-only row preserves the start timestamp without a rewrite.
CREATE TABLE app.maintenance_run_outcomes (
  run_id uuid PRIMARY KEY REFERENCES app.maintenance_run_starts(id) ON DELETE RESTRICT,
  state text NOT NULL CHECK (state IN ('completed','no_work','failed')),
  status_code integer NOT NULL CHECK (status_code BETWEEN 100 AND 599),
  considered_count integer CHECK (considered_count >= 0),
  failed_count integer CHECK (failed_count >= 0),
  completed_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TRIGGER immutable_maintenance_outcomes BEFORE UPDATE OR DELETE ON app.maintenance_run_outcomes
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
