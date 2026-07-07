-- 008_payment_purpose: separate two distinct money flows.
--   subscription = a membership fee to be on the platform (does NOT grant tokens)
--   topup        = loading GHS into the wallet to pay ride fares
-- So a payment now carries a `purpose`, `plan` only applies to subscriptions, and
-- the ledger's grant reason is `topup` (the old `subscription_grant` was wrong).

ALTER TABLE payments
  ADD COLUMN IF NOT EXISTS purpose text NOT NULL DEFAULT 'subscription'
  CHECK (purpose IN ('subscription', 'topup'));

-- plan is meaningful only for subscription payments; top-ups have none.
ALTER TABLE payments ALTER COLUMN plan DROP NOT NULL;

-- Subscriptions no longer grant tokens; top-ups do.
ALTER TABLE token_ledger DROP CONSTRAINT IF EXISTS token_ledger_reason_check;
ALTER TABLE token_ledger
  ADD CONSTRAINT token_ledger_reason_check CHECK (reason IN ('topup', 'boarding', 'refund'));
