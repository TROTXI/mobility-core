-- A code issued before account closure must not create a fresh account after
-- its verified phone identity is scrubbed. Keep the 24-hour hashed rate-budget
-- tombstone, but make the challenge unusable and erase its encrypted phone.
CREATE INDEX phone_otp_cleanup ON app.phone_otp_challenges(created_at,id);
CREATE FUNCTION app.cancel_erased_phone_challenges() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.provider='phone' AND OLD.subject IS DISTINCT FROM NEW.subject
     AND NEW.subject LIKE 'erased:%' THEN
    UPDATE app.phone_otp_challenges SET state='failed',code_hash=NULL,phone_ciphertext=NULL
      WHERE phone_hash=OLD.subject AND state IN ('sending','sent');
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER cancel_erased_phone_challenges AFTER UPDATE OF subject ON app.auth_identities
  FOR EACH ROW EXECUTE FUNCTION app.cancel_erased_phone_challenges();

COMMENT ON FUNCTION app.cancel_erased_phone_challenges() IS
  'Account erasure invalidates outstanding phone codes before the identity scrub commits. Hashed rate-budget rows remain until their guarded 24-hour expiry.';

-- This is a machine-readable report of the deletion work we actually track,
-- not a certificate that every external provider or database backup is clear.
CREATE VIEW app.account_erasure_status AS
SELECT e.user_id,e.erased_at,e.sessions_revoked,e.devices_revoked,e.identities_scrubbed,
  count(t.id)::integer AS tracked_tasks,
  count(t.id) FILTER (WHERE t.state='done')::integer AS tracked_done,
  count(t.id) FILTER (WHERE t.state='cancelled')::integer AS tracked_cancelled,
  count(t.id) FILTER (WHERE t.state IN ('pending','uploading'))::integer AS tracked_pending,
  count(t.id) FILTER (WHERE t.state='unavailable')::integer AS tracked_unavailable,
  CASE
    WHEN count(t.id) FILTER (WHERE t.state='unavailable')>0 THEN 'retry_needed'
    WHEN count(t.id) FILTER (WHERE t.state IN ('pending','uploading'))>0 THEN 'pending'
    ELSE 'tracked_complete'
  END AS tracked_cleanup_state
FROM app.account_erasures e LEFT JOIN app.erasure_tasks t ON t.user_id=e.user_id
GROUP BY e.user_id,e.erased_at,e.sessions_revoked,e.devices_revoked,e.identities_scrubbed;
COMMENT ON VIEW app.account_erasure_status IS
  'Local deletion audit and tracked avatar/Apple grant cleanup only. Does not imply deletion from Paystack, Resend, mNotify, Firebase, Grafana, Render backups or other retained history.';
