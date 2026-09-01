-- 033_unseated_reservations: a terminal status for riders the cutoff could not
-- seat (#210). The capacity-aware default-yes skipped them and left them
-- `pending`, which is indistinguishable from a rider who never answered — so
-- the app kept asking them to confirm a trip they could not be on.
--
-- Distinct from the neighbours on purpose: `declined` is the rider's choice,
-- `released` frees a seat to the standby pool (E6), and `operator_cancelled`
-- means the whole run was pulled. This one is "the van filled up first".
ALTER TABLE reservations DROP CONSTRAINT IF EXISTS reservations_status_check;
ALTER TABLE reservations
  ADD CONSTRAINT reservations_status_check CHECK (
    status IN ('pending', 'reserved', 'declined', 'boarded', 'no_show',
               'released', 'operator_cancelled', 'unseated')
  );
