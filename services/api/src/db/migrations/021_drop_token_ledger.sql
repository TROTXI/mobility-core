-- 021_drop_token_ledger: retire the legacy wallet ledger table (E7, #106).
-- The token wallet was superseded by the entitlement + credit ledgers
-- (ADR-0014); its code was removed in #99 and E1's ledgers are live, so the now
-- unused table can go. Historical migrations 006 (create) and 008 (alter its
-- reason CHECK) are left untouched so replay on an existing DB stays valid — the
-- table is created and altered as before, then dropped here at the end.
DROP TABLE IF EXISTS token_ledger;
