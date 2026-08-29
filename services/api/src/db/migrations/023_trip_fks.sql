-- 023_trip_fks: give reservations.trip_id and scan_events.trip_id the foreign
-- key they were always meant to have (#183).
--
-- Both columns carry a comment explaining the omission: "no FK yet (trips are
-- #18)". Trips arrived in 015_mobility_trips.sql; the columns never caught up,
-- leaving the only two holes in an otherwise complete reference graph.
--
-- This matters more than it looks. reservations drives the no-show sweep, which
-- DEBITS RIDES. A reservation pointing at a trip that no longer exists is a
-- rider who could be charged for a run that never happened.
--
-- ON DELETE SET NULL, deliberately not CASCADE: a reservation is the rider's
-- record and entitlement_ledger entries reference it, so deleting a trip must
-- never erase the history that money decisions were made against. scan_events
-- already uses SET NULL for rider_id and scanned_by, so this keeps that table
-- internally consistent too.
--
-- Trips are not normally deleted at all (cancellation is a status, and
-- reservations has operator_cancelled for the rider side). SET NULL is the
-- safety net for the case that should not happen, not the intended path.

-- Staging carries pilot data from trips created and dropped during testing.
-- ALTER TABLE ... ADD CONSTRAINT fails outright against orphaned rows, so clear
-- them first — and report the counts rather than nulling in silence, because a
-- large number here says something about the data we would want to know before
-- it disappears.
DO $$
DECLARE
  orphaned_reservations integer;
  orphaned_scans        integer;
BEGIN
  UPDATE reservations SET trip_id = NULL
   WHERE trip_id IS NOT NULL
     AND NOT EXISTS (SELECT 1 FROM trips t WHERE t.id = reservations.trip_id);
  GET DIAGNOSTICS orphaned_reservations = ROW_COUNT;

  UPDATE scan_events SET trip_id = NULL
   WHERE trip_id IS NOT NULL
     AND NOT EXISTS (SELECT 1 FROM trips t WHERE t.id = scan_events.trip_id);
  GET DIAGNOSTICS orphaned_scans = ROW_COUNT;

  RAISE NOTICE '023_trip_fks: nulled % orphaned reservations.trip_id, % orphaned scan_events.trip_id',
    orphaned_reservations, orphaned_scans;
END $$;

-- Idempotent: the CI migrations job runs every migration twice and the second
-- pass must be a clean no-op. ADD CONSTRAINT has no IF NOT EXISTS, so guard on
-- the catalogue.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_reservations_trip'
  ) THEN
    ALTER TABLE reservations
      ADD CONSTRAINT fk_reservations_trip
      FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE SET NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_scan_events_trip'
  ) THEN
    ALTER TABLE scan_events
      ADD CONSTRAINT fk_scan_events_trip
      FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE SET NULL;
  END IF;
END $$;
