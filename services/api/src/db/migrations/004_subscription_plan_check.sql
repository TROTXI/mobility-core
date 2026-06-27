-- 004_subscription_plan_check: enforce allowed plan values.

ALTER TABLE subscriptions
  ADD CONSTRAINT chk_subscriptions_plan
  CHECK (plan IN ('monthly', 'annual'));
