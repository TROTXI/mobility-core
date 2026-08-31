-- #205: what a rider needs to recognise the van pulling up.
--
-- We stored a plate and an internal label. The designs show "GT 1234-20 ·
-- Toyota Hiace · Green | White", because on a corridor where several vans look
-- alike the plate alone is not much help at 6am.
--
-- Nullable: the fleet already exists and ops can fill these in over time.
ALTER TABLE vehicles
  ADD COLUMN IF NOT EXISTS make   text,
  ADD COLUMN IF NOT EXISTS colour text;

COMMENT ON COLUMN vehicles.make IS
  'Model as a rider would say it, e.g. "Toyota Hiace". Shown on the boarding card.';
COMMENT ON COLUMN vehicles.colour IS
  'Livery as a rider would describe it, e.g. "Green / White".';
