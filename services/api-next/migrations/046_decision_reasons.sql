-- Ops decisions keep their reason on the event, not only on the request row
-- that the next decision overwrites. Rows written before this keep null.
ALTER TABLE app.membership_events
  ADD COLUMN reason text CHECK (reason IS NULL OR length(btrim(reason)) BETWEEN 1 AND 2000);
ALTER TABLE app.fleet_events
  ADD COLUMN reason text CHECK (reason IS NULL OR length(btrim(reason)) BETWEEN 1 AND 2000);
