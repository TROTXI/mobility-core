-- Keep reviewed/checksummed 001-008 unchanged. Match transport command scope bounds.
ALTER TABLE app.driver_commands
  ADD CONSTRAINT driver_commands_target_length CHECK (length(target) BETWEEN 1 AND 128);
