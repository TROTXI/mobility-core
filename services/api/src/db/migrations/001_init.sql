-- 001_init: extensions + identity core (users, auth identities, sessions).
-- Expand/contract discipline: additive, backward-compatible changes only.

CREATE EXTENSION IF NOT EXISTS postgis; -- geospatial (routes, stops, positions)
CREATE EXTENSION IF NOT EXISTS pgcrypto; -- gen_random_uuid()

-- Riders, drivers, admins. Phone is captured at profile and verified at payment
-- time (Paystack), not by SMS at signup (auth is social-first).
CREATE TABLE IF NOT EXISTS users (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name text NOT NULL,
  phone        text UNIQUE,
  avatar_url   text,
  role         text NOT NULL DEFAULT 'commuter' CHECK (role IN ('commuter', 'driver', 'admin')),
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);

-- One user can sign in via several providers (google | apple | phone). The
-- token/session machinery is the same regardless of method.
CREATE TABLE IF NOT EXISTS auth_identity (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  provider    text NOT NULL CHECK (provider IN ('google', 'apple', 'phone')),
  provider_id text NOT NULL, -- provider subject id (or the phone number)
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (provider, provider_id)
);
CREATE INDEX IF NOT EXISTS idx_auth_identity_user ON auth_identity (user_id);

-- Refresh tokens are stored hashed (never the raw token) and are rotated +
-- revocable, so a lost phone or suspended driver is cut off fast.
CREATE TABLE IF NOT EXISTS sessions (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id            uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  refresh_token_hash text NOT NULL,
  expires_at         timestamptz NOT NULL,
  revoked_at         timestamptz,
  rotated_from       uuid REFERENCES sessions (id) ON DELETE SET NULL,
  created_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions (user_id);
