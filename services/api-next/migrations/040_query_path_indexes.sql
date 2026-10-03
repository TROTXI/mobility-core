-- Indexes for request and maintenance paths that otherwise read a whole table
-- or a whole index whose leading column is something else. Each one was found
-- by planning the query with sequential scans disabled. Plain rather than
-- CONCURRENTLY because each migration runs inside a transaction.

-- The rider's membership read finds the current assignment for one period.
-- The only index containing period_id leads with id.
CREATE INDEX commute_assignments_period ON app.commute_assignments(period_id);

-- Trip summaries count every reservation status for one trip.
-- reservations_trip_seats is partial on three statuses and stays for the seat
-- and overview queries that filter on exactly those.
CREATE INDEX reservations_trip ON app.reservations(trip_id);

-- Trip summaries also count boarding methods per trip, joining events to
-- charges. Neither side had an index on the column the query reaches it by.
CREATE INDEX reservation_charges_trip ON app.reservation_charges(trip_id);
CREATE INDEX boarding_events_reservation ON app.boarding_events(reservation_id);

-- GPS retention deletes positions in batches, and each deleted row makes the
-- foreign key check that no live marker still points at it.
CREATE INDEX trip_live_positions_position ON app.trip_live_positions(position_id);

-- A rider's latest personal pause.
CREATE INDEX personal_pauses_user_latest ON app.personal_pauses(user_id, created_at DESC, id DESC);
