-- Phishing-resistant administrator elevation for the Ops website.
--
-- Google establishes the person's Trotxi identity. A WebAuthn passkey then
-- proves possession of a credential scoped by the browser to the exact Ops
-- relying-party domain. There are no shared TOTP secrets, email codes or
-- recovery codes that can be typed into a phishing page.
--
-- Elevation belongs to one server-side session and lasts one shift. Every
-- protected request re-reads this column, so resetting passkeys and revoking
-- sessions takes effect immediately without waiting for a JWT to expire.
ALTER TABLE app.auth_sessions ADD COLUMN admin_verified_at timestamptz;
COMMENT ON COLUMN app.auth_sessions.admin_verified_at IS
  'When this session last completed a user-verified WebAuthn assertion. Admin sessions outside the elevation window are refused everywhere except passkey endpoints.';

CREATE TABLE app.admin_passkeys (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  credential_id text NOT NULL UNIQUE
    CHECK (length(credential_id) BETWEEN 16 AND 2048 AND credential_id ~ '^[A-Za-z0-9_-]+$'),
  public_key bytea NOT NULL CHECK (octet_length(public_key) BETWEEN 32 AND 4096),
  signature_counter bigint NOT NULL DEFAULT 0 CHECK (signature_counter >= 0),
  transports text[] NOT NULL DEFAULT '{}',
  device_type text NOT NULL CHECK (device_type IN ('singleDevice','multiDevice')),
  backed_up boolean NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  last_used_at timestamptz,
  revoked_at timestamptz,
  CHECK (last_used_at IS NULL OR last_used_at >= created_at),
  CHECK (revoked_at IS NULL OR revoked_at >= created_at)
);
CREATE INDEX admin_passkeys_active_user ON app.admin_passkeys(user_id, created_at)
  WHERE revoked_at IS NULL;

-- Challenges are server-generated, session-bound, purpose-bound and short
-- lived. One row per ceremony means asking for fresh options invalidates the
-- earlier page. A completed ceremony marks its challenge consumed so signed
-- responses cannot be replayed while the evidence remains auditable.
CREATE TABLE app.admin_passkey_challenges (
  session_id uuid NOT NULL REFERENCES app.auth_sessions(id) ON DELETE RESTRICT,
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  purpose text NOT NULL CHECK (purpose IN ('registration','authentication')),
  challenge text NOT NULL
    CHECK (length(challenge) BETWEEN 32 AND 512 AND challenge ~ '^[A-Za-z0-9_-]+$'),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  expires_at timestamptz NOT NULL,
  consumed_at timestamptz,
  PRIMARY KEY (session_id,purpose),
  CHECK (expires_at > created_at AND expires_at <= created_at + interval '5 minutes'),
  CHECK (consumed_at IS NULL OR consumed_at >= created_at)
);

-- No credential material is copied into the event log. Reset attribution is
-- retained even though credentials themselves are revoked.
CREATE TABLE app.admin_passkey_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  action text NOT NULL CHECK (action IN
    ('registration_started','registered','verified','reset')),
  occurred_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX admin_passkey_events_user
  ON app.admin_passkey_events(user_id, occurred_at DESC);
CREATE TRIGGER immutable_admin_passkey_events
  BEFORE UPDATE OR DELETE ON app.admin_passkey_events
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
