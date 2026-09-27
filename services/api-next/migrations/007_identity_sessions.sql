-- Clean replacement, not a backfill of the deployed public.* identity model.
ALTER TABLE app.users ADD COLUMN email text, ADD COLUMN phone text,
  ADD COLUMN avatar_object_key text;

CREATE TABLE app.auth_identities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  provider text NOT NULL CHECK (provider IN ('google','apple')),
  subject text NOT NULL CHECK (length(subject) BETWEEN 1 AND 1024),
  provider_token_ciphertext text,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE(provider,subject),
  CHECK (provider_token_ciphertext IS NULL OR provider='apple')
);
CREATE INDEX auth_identities_user ON app.auth_identities(user_id);

-- One stable session per sign-in/device. JWT sid refers to this row, not to a
-- disposable refresh generation. Current DB revocation gates every API read/write.
CREATE TABLE app.auth_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  expires_at timestamptz NOT NULL,
  refresh_ttl_seconds integer CHECK (refresh_ttl_seconds BETWEEN 1 AND 7776000),
  revoked_at timestamptz,
  CHECK (expires_at > created_at)
);
CREATE INDEX auth_sessions_user ON app.auth_sessions(user_id,created_at,id);
CREATE TABLE app.refresh_credentials (
  token_hash text PRIMARY KEY CHECK (token_hash ~ '^[a-f0-9]{64}$'),
  session_id uuid NOT NULL REFERENCES app.auth_sessions(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  expires_at timestamptz NOT NULL,
  consumed_at timestamptz,
  CHECK (expires_at > created_at)
);
CREATE UNIQUE INDEX refresh_one_unconsumed ON app.refresh_credentials(session_id)
  WHERE consumed_at IS NULL;
COMMENT ON TABLE app.refresh_credentials IS 'Hash-only generations. Consume and replace atomically. Retain consumed hashes for replay detection until their own credential expiry; lost-response retry deliberately retains the baseline rejection policy.';
COMMENT ON COLUMN app.auth_sessions.refresh_ttl_seconds IS 'Remembered devices preserve baseline rolling refresh lifetime. NULL means a shared-device session whose fixed shift expiry must not extend during rotation. Each refresh credential retains its own expiry for bounded replay detection.';

CREATE TABLE app.driver_credentials (
  driver_id uuid PRIMARY KEY REFERENCES app.drivers(id) ON DELETE RESTRICT,
  driver_code text NOT NULL UNIQUE CHECK (driver_code ~ '^DR-[A-Z2-9]{4}$'),
  pin_hash text NOT NULL CHECK (pin_hash ~ '^[a-f0-9]{64}$'),
  must_change_pin boolean NOT NULL DEFAULT true,
  failed_attempts integer NOT NULL DEFAULT 0 CHECK (failed_attempts >= 0),
  locked_until timestamptz,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended')),
  pin_set_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
COMMENT ON TABLE app.driver_credentials IS 'Existing six-digit keyed PIN format and five-attempt/15-minute lockout. must_change_pin is metadata, not a mandatory app navigation gate. Ops issue/reset/suspension commands land separately.';

CREATE TABLE app.auth_commands (
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  target_session_id uuid NOT NULL,
  key_hash text NOT NULL CHECK (key_hash ~ '^[a-f0-9]{64}$'),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  replay_expires_at timestamptz NOT NULL,
  PRIMARY KEY(actor_user_id,target_session_id,key_hash),
  CHECK(replay_expires_at > created_at)
);
CREATE TRIGGER auth_commands_append_only BEFORE UPDATE OR DELETE ON app.auth_commands
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
COMMENT ON TABLE app.auth_commands IS 'Completed self session-revocation receipts, fixed 204 response, no input or output credentials. Authorization always precedes replay. Target is deliberately not an FK: revoking an unknown/foreign session is a non-enumerating no-op.';
