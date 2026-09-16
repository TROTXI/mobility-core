-- Devices a rider is notified on, and what erasure leaves behind.
-- Reviewed 001--016 are unchanged.
--
-- Erasure is not a flag on a user row. Sessions and credentials stop working,
-- identity and device tokens stop existing, the commute triggers from 013 clear
-- what a rider had booked, and the work that lives outside this database is
-- written down so a provider failure is recoverable rather than forgotten.
-- Accounting that we are required to keep is kept, and says why.

CREATE TABLE app.push_devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  platform text NOT NULL CHECK (platform IN ('ios', 'android')),
  -- The token itself is a delivery credential, so it is sealed the way driver
  -- PINs and Apple refresh tokens are. The digest is what identifies a device
  -- across re-registration; it is never the token.
  token_digest text NOT NULL CHECK (token_digest ~ '^[a-f0-9]{64}$'),
  token_ciphertext bytea,
  revoked_at timestamptz,
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE (token_digest),
  CHECK ((token_ciphertext IS NULL) = (revoked_at IS NOT NULL))
);
CREATE INDEX push_devices_owner ON app.push_devices (user_id) WHERE revoked_at IS NULL;
COMMENT ON TABLE app.push_devices IS
  'One row per device install. A token that reappears under another account moves to it, so a handset never keeps receiving a previous owner''s notifications.';

CREATE FUNCTION app.guard_push_device() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN RAISE EXCEPTION 'append_only_history' USING ERRCODE = '23514'; END IF;
  -- A revoked device stays revoked and keeps nothing.
  IF OLD.revoked_at IS NOT NULL AND
    (NEW.revoked_at IS NULL OR NEW.token_ciphertext IS NOT NULL) THEN
    RAISE EXCEPTION 'device_revoked' USING ERRCODE = '23514';
  END IF;
  IF NEW.id <> OLD.id OR NEW.token_digest <> OLD.token_digest OR NEW.created_at <> OLD.created_at THEN
    RAISE EXCEPTION 'immutable_identity' USING ERRCODE = '23514';
  END IF;
  NEW.updated_at := clock_timestamp();
  RETURN NEW;
END $$;
CREATE TRIGGER protect_push_device BEFORE UPDATE OR DELETE ON app.push_devices
  FOR EACH ROW EXECUTE FUNCTION app.guard_push_device();

-- What was erased, when, and by whose request. One per account, append-only:
-- an account is erased once and the record of it is not editable afterwards.
CREATE TABLE app.account_erasures (
  user_id uuid PRIMARY KEY REFERENCES app.users(id) ON DELETE RESTRICT,
  session_id uuid NOT NULL,
  sessions_revoked integer NOT NULL CHECK (sessions_revoked >= 0),
  devices_revoked integer NOT NULL CHECK (devices_revoked >= 0),
  identities_scrubbed integer NOT NULL CHECK (identities_scrubbed >= 0),
  erased_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TRIGGER immutable_account_erasures BEFORE UPDATE OR DELETE ON app.account_erasures
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
COMMENT ON TABLE app.account_erasures IS
  'Local completion only. Accounting rows that must be retained are retained and are not counted here; work outside this database is tracked in erasure_tasks.';

-- The part of erasure this database cannot finish by committing: revoking a
-- provider grant, removing a stored object. A failure leaves a row to retry,
-- never a silently incomplete erasure.
CREATE TABLE app.erasure_tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app.account_erasures(user_id) ON DELETE RESTRICT,
  kind text NOT NULL CHECK (kind IN ('provider_revocation', 'avatar_object')),
  reference text NOT NULL CHECK (length(reference) BETWEEN 1 AND 1024),
  state text NOT NULL DEFAULT 'pending' CHECK (state IN ('pending', 'done', 'unavailable')),
  attempts integer NOT NULL DEFAULT 0 CHECK (attempts BETWEEN 0 AND 1000),
  last_failure text CHECK (last_failure IS NULL OR length(last_failure) BETWEEN 1 AND 200),
  completed_at timestamptz,
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE (user_id, kind, reference),
  CHECK ((state = 'done') = (completed_at IS NOT NULL))
);
CREATE INDEX erasure_tasks_outstanding ON app.erasure_tasks (created_at, id)
  WHERE state <> 'done';
CREATE FUNCTION app.guard_erasure_task() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN RAISE EXCEPTION 'append_only_history' USING ERRCODE = '23514'; END IF;
  IF OLD.state = 'done' THEN RAISE EXCEPTION 'erasure_task_settled' USING ERRCODE = '23514'; END IF;
  IF (to_jsonb(NEW) - ARRAY['state', 'attempts', 'last_failure', 'completed_at', 'updated_at'])
    IS DISTINCT FROM (to_jsonb(OLD) - ARRAY['state', 'attempts', 'last_failure', 'completed_at', 'updated_at'])
    OR NEW.attempts < OLD.attempts THEN
    RAISE EXCEPTION 'immutable_erasure_task' USING ERRCODE = '23514';
  END IF;
  NEW.updated_at := clock_timestamp();
  RETURN NEW;
END $$;
CREATE TRIGGER protect_erasure_task BEFORE UPDATE OR DELETE ON app.erasure_tasks
  FOR EACH ROW EXECUTE FUNCTION app.guard_erasure_task();

-- An erased account keeps no identity of its own, and closing one is what
-- takes it away rather than something a caller must remember to do. Whoever
-- marks the row deleted, by whatever path, it stops holding a name, an email,
-- a phone number or an avatar from that moment.
CREATE FUNCTION app.guard_erased_user() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.deleted_at IS NOT NULL AND NEW.deleted_at IS NULL THEN
    RAISE EXCEPTION 'erasure_is_final' USING ERRCODE = '23514';
  END IF;
  IF NEW.deleted_at IS NOT NULL THEN
    NEW.display_name := NULL;
    NEW.email := NULL;
    NEW.phone := NULL;
    NEW.avatar_object_key := NULL;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER protect_erased_user BEFORE UPDATE ON app.users
  FOR EACH ROW EXECUTE FUNCTION app.guard_erased_user();
