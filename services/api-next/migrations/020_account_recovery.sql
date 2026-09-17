-- Forward-only account recovery. Never discard an outstanding provider grant
-- whose old plaintext reference must first be encrypted by a reviewed repair.
LOCK TABLE app.erasure_tasks, app.account_commands IN ACCESS EXCLUSIVE MODE;
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM app.erasure_tasks WHERE kind='provider_revocation' AND state<>'done') THEN
    RAISE EXCEPTION 'drain_legacy_provider_tasks_before_account_upgrade';
  END IF;
END $$;

DROP TRIGGER protect_erasure_task ON app.erasure_tasks;
ALTER TABLE app.erasure_tasks
  DROP CONSTRAINT erasure_tasks_state_check,
  DROP CONSTRAINT erasure_tasks_check,
  ADD COLUMN payload_ciphertext bytea,
  ADD COLUMN command_key_hash text,
  ADD COLUMN input_hash text,
  ADD COLUMN available_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  ADD COLUMN claim_id uuid,
  ADD COLUMN lease_until timestamptz,
  ADD COLUMN disposition text CHECK (disposition IN ('removed','revoked','not_applicable','attached'));
UPDATE app.erasure_tasks SET reference=id::text WHERE state='done';
ALTER TABLE app.erasure_tasks
  ADD CONSTRAINT erasure_tasks_state_check CHECK (state IN ('uploading','pending','unavailable','done','cancelled')),
  ADD CONSTRAINT erasure_tasks_completion CHECK ((state IN ('done','cancelled')) = (completed_at IS NOT NULL)),
  ADD CONSTRAINT erasure_tasks_claim CHECK ((claim_id IS NULL) = (lease_until IS NULL)),
  ADD CONSTRAINT erasure_tasks_scrub CHECK (state NOT IN ('done','cancelled') OR
    (reference=id::text AND payload_ciphertext IS NULL AND claim_id IS NULL)),
  ADD CONSTRAINT erasure_tasks_upload CHECK ((command_key_hash IS NULL) = (input_hash IS NULL)),
  ADD CONSTRAINT erasure_tasks_key CHECK (command_key_hash IS NULL OR
    (kind='avatar_object' AND command_key_hash ~ '^[a-f0-9]{64}$' AND input_hash ~ '^[a-f0-9]{64}$'));
CREATE UNIQUE INDEX erasure_upload_identity ON app.erasure_tasks(user_id,command_key_hash)
  WHERE command_key_hash IS NOT NULL;
CREATE OR REPLACE FUNCTION app.guard_erasure_task() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'append_only_history' USING ERRCODE='23514'; END IF;
  IF OLD.state IN ('done','cancelled') THEN RAISE EXCEPTION 'erasure_task_settled' USING ERRCODE='23514'; END IF;
  IF (to_jsonb(NEW)-ARRAY['state','attempts','last_failure','completed_at','updated_at','claim_id','lease_until','available_at','disposition','reference','payload_ciphertext'])
    IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['state','attempts','last_failure','completed_at','updated_at','claim_id','lease_until','available_at','disposition','reference','payload_ciphertext'])
    OR NEW.attempts<OLD.attempts
    OR (NEW.state NOT IN ('done','cancelled') AND
      (NEW.reference IS DISTINCT FROM OLD.reference OR NEW.payload_ciphertext IS DISTINCT FROM OLD.payload_ciphertext)) THEN
    RAISE EXCEPTION 'immutable_erasure_task' USING ERRCODE='23514';
  END IF;
  NEW.updated_at:=clock_timestamp(); RETURN NEW;
END $$;
CREATE TRIGGER protect_erasure_task BEFORE UPDATE OR DELETE ON app.erasure_tasks
  FOR EACH ROW EXECUTE FUNCTION app.guard_erasure_task();
COMMENT ON TABLE app.erasure_tasks IS
  'Durable cleanup intent, including in-flight uploads. Claims survive transaction commit; external effects must remain retry-safe. Terminal tasks retain no provider subject or object key.';

DROP TRIGGER immutable_account_commands ON app.account_commands;
ALTER TABLE app.account_commands
  ADD COLUMN expires_at timestamptz,
  ADD COLUMN response_ciphertext bytea;
UPDATE app.account_commands SET expires_at=created_at+interval '7 days';
ALTER TABLE app.account_commands ALTER COLUMN expires_at SET NOT NULL,
  ALTER COLUMN expires_at SET DEFAULT clock_timestamp()+interval '7 days',
  ADD CONSTRAINT account_command_ttl CHECK (expires_at>created_at AND expires_at<=created_at+interval '7 days 1 second');
CREATE FUNCTION app.guard_account_command() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' OR NEW.response_ciphertext IS NOT NULL OR NEW.result IS NOT NULL OR
    (to_jsonb(NEW)-ARRAY['response_ciphertext','result']) IS DISTINCT FROM
    (to_jsonb(OLD)-ARRAY['response_ciphertext','result']) THEN
    RAISE EXCEPTION 'immutable_account_command' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER immutable_account_commands BEFORE UPDATE OR DELETE ON app.account_commands
  FOR EACH ROW EXECUTE FUNCTION app.guard_account_command();
COMMENT ON TABLE app.account_commands IS
  'Seven-day replay. Payloads are encrypted and may only be cleared; minimal key tombstones prevent expired keys from executing again. Erasure clears payloads immediately.';
