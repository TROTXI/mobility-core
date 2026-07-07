-- 009_device_tokens: FCM push-token registry per user/device (#84).
-- One row per push token. UNIQUE(fcm_token) so re-registering just re-points the
-- token (e.g. after an account switch on the same device) — one token, one owner.
-- Tokens cascade with the user. Foundation for push notifications.
CREATE TABLE IF NOT EXISTS device_tokens (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  fcm_token  text NOT NULL UNIQUE,
  platform   text NOT NULL CHECK (platform IN ('android', 'ios', 'web')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_device_tokens_user ON device_tokens (user_id);
