-- Recovery authority is owner-managed, never a rider or runtime command.
CREATE TABLE app.erasure_recovery_control (
  singleton boolean PRIMARY KEY DEFAULT true CHECK (singleton),
  database_id uuid NOT NULL DEFAULT gen_random_uuid(),
  database_name text NOT NULL DEFAULT current_database(),
  mode text NOT NULL DEFAULT 'active' CHECK (mode IN ('active','fenced','isolated','ready')),
  journal_namespace uuid,
  replay_revision bigint,
  replay_hash text,
  CHECK ((replay_revision IS NULL) = (replay_hash IS NULL))
);
INSERT INTO app.erasure_recovery_control(singleton) VALUES (true);
COMMENT ON TABLE app.erasure_recovery_control IS
  'Owner-only source fence and isolated restore gate. Runtime may read but never change authority.';
