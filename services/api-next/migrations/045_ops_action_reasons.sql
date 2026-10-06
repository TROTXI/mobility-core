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
