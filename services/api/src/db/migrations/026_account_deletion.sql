-- 026_account_deletion: support erasing a rider without destroying the books (#30).
--
-- Required by App Store and Play before either app can ship.
--
-- A hard DELETE FROM users is the obvious implementation and the wrong one.
-- Every money table cascades off users:
--   payments, entitlement_ledger, credit_ledger  ON DELETE CASCADE
-- so deleting the row would silently erase the financial record of what someone
-- paid and what they were charged. Those have to survive a deletion request —
-- they are our books, not the rider's personal data.
--
-- So deletion ANONYMISES: the personal data goes, the row and its id stay, and
-- the ledgers remain balanced and attributable to an account that can no longer
-- be linked to a person. The auth_identity rows are removed separately, so a
-- returning user signs up fresh rather than resurrecting the old account.

ALTER TABLE users ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

COMMENT ON COLUMN users.deleted_at IS
  'Set when the account is erased on request. PII columns are cleared; the row survives so payments and ledger history stay intact.';

-- Deleted accounts are excluded from every operational query, so keep the
-- lookup cheap rather than scanning.
CREATE INDEX IF NOT EXISTS idx_users_active ON users (id) WHERE deleted_at IS NULL;
