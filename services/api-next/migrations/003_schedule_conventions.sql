-- Documentation-only follow-up. Keep the reviewed 001/002 checksums intact.
-- The schedule reassignment guard already exists in 001; do not replace it
-- with permissive rescheduling or silently decide a cancel-and-replace policy.
COMMENT ON COLUMN app.service_schedules.weekdays IS
  'ISO weekdays: 1 = Monday, 2 = Tuesday, 3 = Wednesday, 4 = Thursday, 5 = Friday, 6 = Saturday, 7 = Sunday. Not JavaScript getDay() (0 = Sunday). Evaluated against stored service_date, not date(scheduled_at).';
COMMENT ON COLUMN app.trips.schedule_id IS
  'Selected immutable schedule revision. protect_trip / guard_trip reject direct schedule or pattern-version changes with explicit_reassignment_required, even within one departure. A future attributable reassignment command must revalidate business-date eligibility and affected reservations.';
COMMENT ON FUNCTION app.guard_trip_identity() IS
  'Checks business-date eligibility at insertion and keeps departure/date/run immutable. UPDATE also runs protect_trip / guard_trip from 001, which rejects any schedule or pattern-version change; this function is not the only trip guard.';
