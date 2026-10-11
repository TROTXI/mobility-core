-- Keep historical annual purchases and pricing evidence intact. New requests
-- are restricted by the API to weekly, biweekly and monthly offers. Prices and
-- ride allowances still come from the explicitly reviewed Ops offer.
ALTER TABLE app.purchases DROP CONSTRAINT purchases_plan_check;
ALTER TABLE app.purchases ADD CONSTRAINT purchases_plan_check
  CHECK (plan IN ('weekly', 'biweekly', 'monthly', 'annual'));
ALTER TABLE app.plan_pricing DROP CONSTRAINT plan_pricing_plan_check;
ALTER TABLE app.plan_pricing ADD CONSTRAINT plan_pricing_plan_check
  CHECK (plan IN ('weekly', 'biweekly', 'monthly', 'annual'));

-- Do not invent weekly/biweekly fares, rides or conversion rates here. The
-- supported offer workflow prices exact journeys and dates, not this legacy
-- plan-pricing table. Existing paid annual coverage is not shortened.
