-- Runtime configuration: which builds are still admitted, what clients are
-- told at start-up, and who changed a role. Reviewed 001--017 are unchanged.
--
-- A stored setting that admission ignores is not configuration, so the build
-- floor lives here and the gate reads it. Flags are served to clients; nothing
-- server-side is gated by one, because no reviewed operation declares a flag.

ALTER TABLE app.users ADD COLUMN version integer NOT NULL DEFAULT 1 CHECK (version > 0);
CREATE FUNCTION app.touch_user_version() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.id <> OLD.id OR NEW.created_at <> OLD.created_at THEN
    RAISE EXCEPTION 'immutable_identity' USING ERRCODE = '23514';
  END IF;
  NEW.version := OLD.version + 1;
  RETURN NEW;
END $$;
CREATE TRIGGER bump_user_version BEFORE UPDATE ON app.users
  FOR EACH ROW EXECUTE FUNCTION app.touch_user_version();
COMMENT ON COLUMN app.users.version IS
  'Optimistic concurrency for the ops role change. The approved contract has no ops account read, so a caller who has not seen the account can only supply If-Match: *.';

CREATE TABLE app.minimum_versions (
  app text NOT NULL CHECK (app IN ('commuter', 'driver')),
  platform text NOT NULL CHECK (platform IN ('ios', 'android')),
  min_supported_build integer NOT NULL CHECK (min_supported_build BETWEEN 1 AND 999999999),
  api_major integer NOT NULL CHECK (api_major = 1),
  store_url text NOT NULL CHECK (
    length(store_url) BETWEEN 9 AND 480 AND store_url ~ '^https://[^[:space:]]+$'),
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  PRIMARY KEY (app, platform)
);
COMMENT ON TABLE app.minimum_versions IS
  'Read by admission on every request. An app and platform with no row falls back to the floor the deployment was composed with, so a fresh database still refuses an ancient build.';
CREATE FUNCTION app.touch_minimum_version() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.app <> OLD.app OR NEW.platform <> OLD.platform OR NEW.created_at <> OLD.created_at THEN
    RAISE EXCEPTION 'immutable_identity' USING ERRCODE = '23514';
  END IF;
  NEW.version := OLD.version + 1;
  NEW.updated_at := clock_timestamp();
  RETURN NEW;
END $$;
CREATE TRIGGER bump_minimum_version BEFORE UPDATE ON app.minimum_versions
  FOR EACH ROW EXECUTE FUNCTION app.touch_minimum_version();

CREATE TABLE app.feature_flags (
  key text PRIMARY KEY CHECK (key ~ '^[a-z][a-z0-9_.-]{0,199}$'),
  enabled boolean NOT NULL,
  -- A percentage, not a count: the same rider gets the same answer every time,
  -- decided by hashing them with the key rather than by a coin toss per call.
  rollout_percentage numeric(5, 2) NOT NULL CHECK (rollout_percentage BETWEEN 0 AND 100),
  description text NOT NULL CHECK (length(description) <= 2000),
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE FUNCTION app.touch_feature_flag() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.key <> OLD.key OR NEW.created_at <> OLD.created_at THEN
    RAISE EXCEPTION 'immutable_identity' USING ERRCODE = '23514';
  END IF;
  NEW.version := OLD.version + 1;
  NEW.updated_at := clock_timestamp();
  RETURN NEW;
END $$;
CREATE TRIGGER bump_feature_flag BEFORE UPDATE ON app.feature_flags
  FOR EACH ROW EXECUTE FUNCTION app.touch_feature_flag();

CREATE TABLE app.config_commands (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  operation text NOT NULL CHECK (operation IN ('setFlag', 'setMinimumVersion', 'changeRole')),
  target text NOT NULL CHECK (length(target) BETWEEN 1 AND 200),
  key_hash text NOT NULL CHECK (key_hash ~ '^[a-f0-9]{64}$'),
  input_hash text NOT NULL CHECK (input_hash ~ '^[a-f0-9]{64}$'),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE (actor_user_id, operation, target, key_hash),
  UNIQUE (id, actor_user_id)
);
CREATE TABLE app.config_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  command_id uuid NOT NULL,
  actor_user_id uuid NOT NULL,
  action text NOT NULL CHECK (action IN ('setFlag', 'setMinimumVersion', 'changeRole')),
  target text NOT NULL CHECK (length(target) BETWEEN 1 AND 200),
  -- A role change states its reason. Ops actions are attributable or they are
  -- not ops actions.
  reason text CHECK (reason IS NULL OR length(btrim(reason)) BETWEEN 1 AND 2000),
  before_state jsonb NOT NULL,
  after_state jsonb NOT NULL,
  occurred_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  FOREIGN KEY (command_id, actor_user_id) REFERENCES app.config_commands(id, actor_user_id)
    ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED,
  CHECK ((action = 'changeRole') = (reason IS NOT NULL))
);
CREATE TRIGGER immutable_config_commands BEFORE UPDATE OR DELETE ON app.config_commands
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE TRIGGER immutable_config_events BEFORE UPDATE OR DELETE ON app.config_events
  FOR EACH ROW EXECUTE FUNCTION app.append_only();

-- A role change never reaches an account that has been closed.
--
-- Deliberately not here: a rule refusing to demote the last administrator.
-- It is a real operational hazard and worth having, but it is a product
-- decision rather than an integrity one, and imposing it would change how
-- two unrelated suites are allowed to arrange their fixtures. Raised for
-- review instead of shipped.
CREATE FUNCTION app.guard_role_change() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.role <> OLD.role AND (NEW.deleted_at IS NOT NULL OR OLD.deleted_at IS NOT NULL) THEN
    RAISE EXCEPTION 'role_change_requires_open_account' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER protect_role_change BEFORE UPDATE ON app.users
  FOR EACH ROW EXECUTE FUNCTION app.guard_role_change();
