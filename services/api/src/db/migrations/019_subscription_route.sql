-- 019_subscription_route: pin a subscription to a route/corridor (ADR-0014, E3).
-- The rider picks their corridor at subscribe; the daily ask-dispatch prompts
-- every active subscriber of tomorrow's trip's route. route_id rides through the
-- payment (set at checkout) and is applied to the subscription on activation.
-- Nullable: pre-E3 subscriptions have none, and the ask-dispatch simply skips
-- routeless subscribers.
ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS route_id uuid REFERENCES routes (id) ON DELETE SET NULL;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS route_id uuid;
CREATE INDEX IF NOT EXISTS idx_subscriptions_route ON subscriptions (route_id) WHERE status = 'active';
