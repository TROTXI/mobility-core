-- Admission is a shared fact, not a per-process one. A budget counted in one
-- process's memory is a different budget in every other process, so two
-- instances admit twice what one does and the limit stops meaning anything the
-- moment the service scales. Postgres holds it until a cheaper shared store is
-- worth its cost; the adapter boundary is what makes that swap small.
CREATE TABLE app.admission_counters (
 subject text PRIMARY KEY CHECK(length(subject) BETWEEN 1 AND 200),
 window_started_at timestamptz NOT NULL CHECK(isfinite(window_started_at)),
 count integer NOT NULL CHECK(count>0)
);
CREATE INDEX admission_counters_expiry ON app.admission_counters(window_started_at);
COMMENT ON TABLE app.admission_counters IS 'Shared per-subject request budget over a fixed clock-aligned window. Not audit and not history: rows are disposable once their window has closed, and carry no identity beyond the subject key they are counted under.';

-- The runtime may remove a counter only once its window is over. A live window
-- is somebody''s spent budget, and deleting it hands them a fresh one.
CREATE FUNCTION app.guard_expired_admission() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF OLD.window_started_at > clock_timestamp() - interval '2 minutes' THEN
  RAISE EXCEPTION 'admission_window_live' USING ERRCODE='23514';
 END IF;
 RETURN OLD;
END $$;
CREATE TRIGGER expire_admission BEFORE DELETE ON app.admission_counters
 FOR EACH ROW EXECUTE FUNCTION app.guard_expired_admission();
