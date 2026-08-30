-- E5b (#128): spend the Ride Credits that #162 started minting.
--
-- Until now the credit ledger was write-only: month-end conversion granted
-- credit, `GET /me/rides` displayed it, and no code path could ever spend it.
-- The balance was an accruing liability with no discharge.
--
-- What the rider pays on a checkout is now `price - applied_credit`. The applied
-- amount is frozen on the PAYMENT, alongside the other #103 snapshots, for the
-- same reason: minutes pass between checkout and charge.success, and the
-- amount sent to Paystack is fixed the moment we call them.
ALTER TABLE payments
  ADD COLUMN IF NOT EXISTS applied_credit_pesewas integer NOT NULL DEFAULT 0
    CHECK (applied_credit_pesewas >= 0);

COMMENT ON COLUMN payments.applied_credit_pesewas IS
  'Ride Credit netted off this checkout, frozen at initiation. The rider was charged amount; the ledger is debited this much on charge.success (reason renewal_applied, keyed by reference).';
