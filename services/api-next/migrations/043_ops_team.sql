-- Superadmin is an additional administrative capability, not a new app role.
ALTER TABLE app.users ADD COLUMN is_superadmin boolean NOT NULL DEFAULT false;
ALTER TABLE app.users ADD COLUMN ops_invite_pending boolean NOT NULL DEFAULT false;
ALTER TABLE app.users ADD CONSTRAINT ops_capabilities CHECK (
  (NOT is_superadmin OR (role='admin' AND deleted_at IS NULL AND NOT ops_invite_pending))
  AND (NOT ops_invite_pending OR (role='admin' AND deleted_at IS NULL)));

CREATE TABLE app.ops_bootstrap (
  singleton boolean PRIMARY KEY DEFAULT true CHECK (singleton),
  user_id uuid NOT NULL REFERENCES app.users(id),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TRIGGER immutable_ops_bootstrap BEFORE UPDATE OR DELETE ON app.ops_bootstrap
  FOR EACH ROW EXECUTE FUNCTION app.append_only();

CREATE TABLE app.ops_invitations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text,
  name text,
  token_hash text UNIQUE,
  version integer NOT NULL DEFAULT 1,
  inviter_id uuid NOT NULL REFERENCES app.users(id),
  user_id uuid REFERENCES app.users(id),
  state text NOT NULL DEFAULT 'pending' CHECK (state IN ('pending','claimed','accepted','cancelled')),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  expires_at timestamptz NOT NULL,
  CHECK (expires_at > created_at),
  CHECK (state NOT IN ('pending','claimed') OR (email IS NOT NULL AND token_hash IS NOT NULL))
);
CREATE UNIQUE INDEX ops_invitation_email ON app.ops_invitations(lower(email)) WHERE state IN ('pending','claimed');
CREATE INDEX ops_invitation_user ON app.ops_invitations(user_id);
CREATE INDEX ops_invitation_page ON app.ops_invitations(created_at,id);

CREATE TABLE app.ops_team_commands (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id uuid NOT NULL REFERENCES app.users(id),
  key_hash text NOT NULL UNIQUE,
  input_hash text NOT NULL,
  result_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TRIGGER immutable_ops_team_commands BEFORE UPDATE OR DELETE ON app.ops_team_commands
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE TABLE app.ops_team_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id uuid NOT NULL REFERENCES app.users(id),
  target_id uuid NOT NULL,
  action text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TRIGGER immutable_ops_team_events BEFORE UPDATE OR DELETE ON app.ops_team_events
  FOR EACH ROW EXECUTE FUNCTION app.append_only();

CREATE FUNCTION app.guard_last_superadmin() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.is_superadmin AND (NOT NEW.is_superadmin OR NEW.role<>'admin' OR NEW.deleted_at IS NOT NULL) THEN
    PERFORM pg_advisory_xact_lock(hashtextextended('trotxi:ops-team',0));
    IF NOT EXISTS (SELECT 1 FROM app.users WHERE id<>OLD.id AND is_superadmin AND deleted_at IS NULL) THEN
      RAISE EXCEPTION 'last_superadmin' USING ERRCODE='23514';
    END IF;
  END IF;
  IF NEW.deleted_at IS NOT NULL THEN
    NEW.is_superadmin:=false;
    NEW.ops_invite_pending:=false;
    UPDATE app.ops_invitations SET state='cancelled',email=NULL,name=NULL,token_hash=NULL
      WHERE user_id=OLD.id OR lower(email)=lower(OLD.email);
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER guard_ops_owner BEFORE UPDATE ON app.users
  FOR EACH ROW EXECUTE FUNCTION app.guard_last_superadmin();

ALTER TABLE app.email_outbox DROP CONSTRAINT email_outbox_kind_check;
ALTER TABLE app.email_outbox ADD CONSTRAINT email_outbox_kind_check CHECK (kind IN (
 'subscription_active','subscription_expiring','erasure_requested','driver_credentials_issued','driver_pin_reset','ops_invitation'));
CREATE INDEX ops_invitation_email_status ON app.email_outbox(source_id,created_at DESC,id DESC)
  WHERE kind='ops_invitation';
