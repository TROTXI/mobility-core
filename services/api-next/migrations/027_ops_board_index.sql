-- The ops board is polled every ten seconds during a service window and reads
-- one service day. No index led with service_date, so every poll scanned every
-- trip ever run, and trips only accumulate. Plain rather than CONCURRENTLY
-- because each migration runs inside a transaction.
CREATE INDEX trips_service_day ON app.trips(service_date, id);
