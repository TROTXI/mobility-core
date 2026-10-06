-- Every human Ops action records why it was taken. Existing rows predate the
-- rule and keep a null reason; the API requires one on every new action.
ALTER TABLE app.ops_team_events
  ADD COLUMN reason text CHECK (reason IS NULL OR length(btrim(reason)) BETWEEN 1 AND 2000);
ALTER TABLE app.admin_passkey_events
  ADD COLUMN reason text CHECK (reason IS NULL OR length(btrim(reason)) BETWEEN 1 AND 2000);
ALTER TABLE app.standby_events
  ADD COLUMN reason text CHECK (reason IS NULL OR length(btrim(reason)) BETWEEN 1 AND 2000);
ALTER TABLE app.pricing_events
  ADD COLUMN reason text CHECK (reason IS NULL OR length(btrim(reason)) BETWEEN 1 AND 2000);
-- Configuration events allowed a reason only on role changes; flags and app
-- floors now carry one too. The old check is unnamed, so find it by its text.
DO $$
DECLARE name text;
BEGIN
  SELECT conname INTO STRICT name FROM pg_constraint
  WHERE conrelid = 'app.config_events'::regclass AND contype = 'c'
    AND pg_get_constraintdef(oid) LIKE '%changeRole%reason IS NOT NULL%';
  EXECUTE format('ALTER TABLE app.config_events DROP CONSTRAINT %I', name);
END $$;
ALTER TABLE app.config_events
  ADD CONSTRAINT config_events_role_reason CHECK (action <> 'changeRole' OR reason IS NOT NULL);
