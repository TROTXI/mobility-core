-- Only an authentication assertion proves possession of an existing passkey.
-- Existing sessions get no assertion timestamp and must authenticate again
-- before enrolling another credential.
ALTER TABLE app.auth_sessions ADD COLUMN admin_passkey_authenticated_at timestamptz;

-- Names belong to the verification link that was issued for them. Old
-- signup links have no bound names and the new API asks for a fresh link.
-- Nullable columns let the previous API keep writing during rollout.
ALTER TABLE app.email_auth_challenges
  ADD COLUMN signup_first_name text,
  ADD COLUMN signup_last_name text,
  ADD COLUMN signup_other_names text,
  ADD CONSTRAINT signup_challenge_names CHECK (
    (signup_first_name IS NULL AND signup_last_name IS NULL AND signup_other_names IS NULL)
    OR (purpose='signup' AND token_hash IS NOT NULL AND consumed_at IS NULL
      AND signup_first_name IS NOT NULL AND length(signup_first_name) BETWEEN 1 AND 60
      AND signup_last_name IS NOT NULL AND length(signup_last_name) BETWEEN 1 AND 60
      AND (signup_other_names IS NULL OR length(signup_other_names) BETWEEN 1 AND 80))
  );

CREATE FUNCTION app.clear_consumed_signup_names() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.token_hash IS NULL OR NEW.consumed_at IS NOT NULL THEN
    NEW.signup_first_name:=NULL;
    NEW.signup_last_name:=NULL;
    NEW.signup_other_names:=NULL;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER email_challenge_clear_signup_names BEFORE UPDATE ON app.email_auth_challenges
  FOR EACH ROW EXECUTE FUNCTION app.clear_consumed_signup_names();

-- Remove historical copies while preserving append-only audit metadata.
ALTER TABLE app.fleet_events DISABLE TRIGGER fleet_events_append_only;
UPDATE app.fleet_events SET reason=NULL WHERE incident_id IS NOT NULL AND reason IS NOT NULL;
ALTER TABLE app.fleet_events ENABLE TRIGGER fleet_events_append_only;

-- Keep the same trigger identity and protection. Older API instances may
-- still supply a reason during rollout, so enforce minimization at insert.
CREATE OR REPLACE FUNCTION app.guard_fleet_event_privacy() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='INSERT' THEN
    IF NEW.incident_id IS NOT NULL THEN
      NEW.before_state:=app.minimal_incident_event(NEW.before_state);
      NEW.after_state:=app.minimal_incident_event(NEW.after_state);
      NEW.reason:=NULL;
    END IF;
    RETURN NEW;
  END IF;
  RAISE EXCEPTION 'append_only_history' USING ERRCODE='23514';
END $$;
