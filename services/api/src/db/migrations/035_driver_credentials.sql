-- 035_driver_credentials: driver sign-in with a code and a PIN (#223, blocks #41).
--
-- Drivers are issued by an operator, not self-registered. There is no promise a
-- driver holds a Google account or an email they read, and ops has to be able to
-- hand someone credentials at a depot and revoke them the same afternoon. Social
-- sign-in answers none of that, which is why `drivers.user_id` has sat nullable
-- since 015 with the note "until driver sign-in lands".
--
-- Its own table rather than columns on `drivers`: that is a fleet record ops
-- browses and edits freely, and credential material has a lifecycle of its own
-- (issued, rotated, locked, suspended) that has no business living in it.
--
-- Also NOT an auth_identity row. That table maps an external provider's subject
-- to one of our users; this credential is ours, and widening its CHECK would put
-- a secret in a table that has never held one.
CREATE TABLE IF NOT EXISTS driver_credentials (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id       uuid NOT NULL UNIQUE REFERENCES drivers (id) ON DELETE CASCADE,

  -- What the driver types on the sign-in screen. Issued by ops and readable
  -- aloud over a bad phone line. An identifier, not a secret: the PIN is the
  -- credential.
  driver_code     text NOT NULL UNIQUE,

  -- HMAC-SHA256 of the PIN keyed by the server secret, the same construction the
  -- daily boarding code already uses. A database leak yields no usable PIN.
  pin_hash        text NOT NULL,
  pin_set_at      timestamptz NOT NULL DEFAULT now(),

  -- Ops issues the first PIN, so the driver has to replace it before the
  -- credential is theirs alone.
  must_change_pin boolean NOT NULL DEFAULT true,

  -- Lockout state, kept HERE rather than in the KV store. The boarding-code
  -- attempt budget fails open because a rider must never be stranded at the
  -- kerb, but a credential check has to fail closed, and a counter that lives in
  -- a cache can be cleared by flushing it. Postgres is already required for
  -- sign-in, so this also avoids putting the depot's 05:40 behind a second
  -- piece of infrastructure.
  failed_attempts integer NOT NULL DEFAULT 0,
  locked_until    timestamptz,

  -- Suspended by ops without destroying the record (leave, investigation).
  status          text NOT NULL DEFAULT 'active'
                  CHECK (status IN ('active', 'suspended')),

  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

-- Sign-in looks a driver up by code; suspended rows never need to be found.
CREATE INDEX IF NOT EXISTS idx_driver_credentials_active_code
  ON driver_credentials (driver_code) WHERE status = 'active';

COMMENT ON COLUMN driver_credentials.driver_code IS
  'Ops-issued identifier the driver types at sign-in. Not secret.';
COMMENT ON COLUMN driver_credentials.pin_hash IS
  'HMAC-SHA256 of the PIN keyed by the server secret. Never the PIN itself.';
COMMENT ON COLUMN driver_credentials.locked_until IS
  'Set by the lockout after repeated wrong PINs. Durable on purpose: a cache flush must not reset it.';
