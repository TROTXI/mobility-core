-- A second factor for operations accounts.
--
-- Admins sign in with Google, so an emailed code would land in the same inbox
-- the sign-in already controls: one factor dressed as two. The second factor is
-- an authenticator app instead, proving possession of a separate device.
--
-- Elevation belongs to the session, not the account. Every request re-reads its
-- session row, so an unelevated admin session is refused on the next call and a
-- reset takes effect immediately, with nothing to wait out in a token.
ALTER TABLE app.auth_sessions ADD COLUMN mfa_verified_at timestamptz;
COMMENT ON COLUMN app.auth_sessions.mfa_verified_at IS
  'When this session passed the authenticator check. Admin sessions without it, or with it older than the elevation window, are refused everywhere except the two-factor endpoints.';

CREATE TABLE app.admin_mfa (
  user_id uuid PRIMARY KEY REFERENCES app.users(id) ON DELETE RESTRICT,
  -- AES-256-GCM, bound to the user by associated data: a ciphertext copied onto
  -- another account does not open. Never stored or logged in plaintext.
  secret_ciphertext text NOT NULL CHECK (length(secret_ciphertext) BETWEEN 40 AND 400),
  -- Null while enrolment is pending: the secret has been shown but no code from
  -- it has been confirmed, so it does not yet protect anything.
  enabled_at timestamptz,
  -- When the current secret was shown. Null after a reset, when the stored
  -- secret is random and was never shown to anyone, so a reset admin is sent to
  -- enrol afresh rather than asked to confirm a code nobody can produce. A
  -- pending secret also expires, which narrows the window in which whoever
  -- holds the Google session first can claim the account's authenticator.
  secret_issued_at timestamptz,
  -- The last 30-second step accepted. A code is refused unless its step is later,
  -- so one code cannot be used twice even inside its validity window.
  last_used_step bigint CHECK (last_used_step >= 0),
  failed_attempts integer NOT NULL DEFAULT 0 CHECK (failed_attempts BETWEEN 0 AND 1000),
  locked_until timestamptz,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

-- Shown once at enrolment, stored only as a keyed hash, single use. The way back
-- for a lost phone that does not route through the Google account.
CREATE TABLE app.admin_mfa_recovery_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  code_hash text NOT NULL UNIQUE CHECK (code_hash ~ '^[a-f0-9]{64}$'),
  used_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX admin_mfa_recovery_unused ON app.admin_mfa_recovery_codes(user_id)
  WHERE used_at IS NULL;

-- Who did what to whose second factor. Append-only, like every other event log,
-- and it records no codes, secrets or recovery values.
CREATE TABLE app.admin_mfa_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  action text NOT NULL CHECK (action IN
    ('enrolment_started', 'enrolled', 'verified', 'recovery_used', 'failed', 'locked', 'reset')),
  occurred_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX admin_mfa_events_user ON app.admin_mfa_events(user_id, occurred_at DESC);
CREATE TRIGGER immutable_admin_mfa_events BEFORE UPDATE OR DELETE ON app.admin_mfa_events
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
