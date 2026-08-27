-- 029_subscription_periods: give a subscription a billing period (#162).
--
-- Until now a subscription had a plan ('monthly' | 'annual') and nothing acting
-- on it. Three things follow from that, and all three are broken:
--
-- 1. THE APPS CANNOT RENDER THE BALANCE CARD. "renews 1 Sep", "23 of 40" and
--    "of 40 · renews 1 Sep" all appear in the commuter designs. None of it is
--    computable.
--
-- 2. CREDIT CONVERSION IS KEYED WRONG, AND THAT IS WHY IT IS NOT ON CRON.
--    credit.service.ts builds its idempotency key as `convert:${sub.id}`.
--    Keyed on the SUBSCRIPTION rather than the PERIOD, conversion can only ever
--    run once in the lifetime of a subscription: scheduling it would zero a
--    rider who subscribed three days earlier, then no-op forever from month
--    two. This is the sole reason /admin/convert-credits is excluded from the
--    cron blueprint.
--
-- 3. NOTHING EXPIRES. status can be 'expired' but no job ever sets it, so a
--    lapsed subscription stays 'active' indefinitely — and the partial unique
--    index (003) means that stale row also blocks the rider from ever
--    subscribing again.
--
-- Periods are half-open [period_start, period_end): the instant period_end
-- arrives the period is over. Avoids the off-by-one-second arguments that
-- inclusive ends invite when a rider subscribes at 23:59:59.

ALTER TABLE subscriptions
  ADD COLUMN IF NOT EXISTS period_start timestamptz,
  ADD COLUMN IF NOT EXISTS period_end   timestamptz;

COMMENT ON COLUMN subscriptions.period_start IS
  'Start of the current billing period, inclusive. Set on activation from the plan.';
COMMENT ON COLUMN subscriptions.period_end IS
  'End of the current billing period, EXCLUSIVE. Drives renewal, expiry, and the idempotency key for month-end credit conversion.';

-- Backfill so nothing is left null and existing riders behave sensibly. Derived
-- from created_at rather than guessed: a subscription created on 12 Aug on a
-- monthly plan is treated as running 12 Aug -> 12 Sep, which is what the rider
-- was actually sold.
UPDATE subscriptions
   SET period_start = created_at,
       period_end   = created_at + CASE WHEN plan = 'annual'
                                        THEN interval '1 year'
                                        ELSE interval '1 month' END
 WHERE period_start IS NULL;

-- Finding whose period has ended is the whole job of the renewal/expiry sweep,
-- and it runs over every active subscription.
CREATE INDEX IF NOT EXISTS idx_subscriptions_period_end
  ON subscriptions (period_end) WHERE status = 'active';
