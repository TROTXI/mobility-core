-- 003_subscriptions_constraints: enforce one active subscription per user + status check.

ALTER TABLE subscriptions
  ADD CONSTRAINT chk_subscriptions_status
  CHECK (status IN ('active', 'cancelled', 'expired'));

CREATE UNIQUE INDEX IF NOT EXISTS idx_subscriptions_one_active_per_user
  ON subscriptions (user_id)
  WHERE status = 'active';
