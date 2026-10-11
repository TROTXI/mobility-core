-- One private, rider-owned rating per completed, boarded reservation.
-- A separate table leaves the terminal reservation and its financial history immutable.
CREATE TABLE app.ride_ratings (
  reservation_id uuid PRIMARY KEY REFERENCES app.reservations(id),
  stars smallint CHECK (stars BETWEEN 1 AND 5),
  rated_at timestamptz,
  CHECK ((stars IS NULL) = (rated_at IS NULL))
);

-- Null values are reserved for account erasure. No free text or driver identity
-- is collected, and ratings do not affect ride charges or eligibility.

ALTER TABLE app.membership_commands DROP CONSTRAINT membership_commands_operation_check;
ALTER TABLE app.membership_commands ADD CONSTRAINT membership_commands_operation_check CHECK (
  operation IN ('createCommuteRequest','withdrawCommuteRequest','decideCommuteRequest',
    'createCommuteSlot','retireCommuteSlot','decideReservation','createAccountRestriction',
    'releaseAccountRestriction','createPersonalPause','resumePersonalPause','rateReservation')
);
