# Staging security cutover

PR #408 retires the staging seed workflow and separates installation from runtime
database access. These configuration steps are required before deployment. A code
merge alone does not apply GitHub environment policies or Render settings.

## Code controls

- The API refuses owner credentials and uses a `trotxi_runtime_*` login. Startup
  reads the migration inventory and fails if it differs from the checked-in files.
  Only the protected deployment installer runs migrations and refreshes grants.
- External staging database connections verify both the certificate chain and
  hostname. Insecure URL options are rejected. An optional PEM CA certificate can
  extend the trust configuration; it cannot turn verification off.
- Payment and email maintenance use separate jobs. Neither retrieves Render
  settings or receives the staging root key. Each receives only its purpose key
  and a restricted database connection.
- Maintenance uses an explicitly configured non-human administrator with no
  email, phone, sign-in identity, driver record or interactive session history.
  Payment sessions are marked `maintenance`, sent as the `worker` client and
  revoked afterward. Both scheduled jobs write starts and outcomes to the audit.
- Public logs contain counts, HTTP statuses and fixed failure categories only.
  They never include raw database/provider exceptions, tokens, PINs or payloads.
- Maintenance requires `main`, the `staging` environment and read-only repository
  permissions. Actions are pinned to reviewed commits. Local infrastructure ports
  bind to loopback; existing containers need recreation for that change to apply.

## Prepare without interrupting the running service

1. Confirm the live database already has migration `032_maintenance_audit.sql`.
   The existing staging deployment must be current before this cutover; the new
   installer checks the service identity before applying further migrations.
2. Provision two independent logins, for example `trotxi_runtime_api` and
   `trotxi_runtime_worker`. Neither may own objects, inherit another role, create
   roles/databases/schemas, bypass row security or replicate. Do not reuse the
   database owner's password. Supply passwords privately, not as shell arguments
   or SQL printed in logs. Run the existing `grantRuntime` procedure as the owner
   against each login, then verify the logins actually connect.
3. Create one dedicated `app.users` row with role `admin` and a descriptive
   service name such as `Staging maintenance`. Leave email and phone null. Do not
   attach Google, phone, passkey or driver credentials. Record its UUID as
   `STAGING_MAINTENANCE_USER_ID`. Do not select a human operator's UUID.
4. Restrict the GitHub `staging` environment to the branch `main` only, with no
   matching tag rule. Protect main against direct unreviewed changes. Repository
   administrators remain trusted; environment rules are not a sandbox against
   someone authorized to change the rules or merge arbitrary code.
5. Populate these **environment-scoped** secrets, not repository-scoped secrets:

   | Secret                             | Consumer                                                             |
   | ---------------------------------- | -------------------------------------------------------------------- |
   | `STAGING_DATABASE_URL`             | Protected deployment installer, existing manual payment verification |
   | `STAGING_RUNTIME_DATABASE_URL`     | Installer role validation; same restricted URL used by API           |
   | `STAGING_MAINTENANCE_DATABASE_URL` | Scheduled maintenance and installer role validation                  |
   | `STAGING_DATABASE_CA_CERT`         | Optional PEM CA for verified external database connections           |
   | `STAGING_ACCESS_SECRET`            | Payment maintenance only                                             |
   | `STAGING_EMAIL_ENCRYPTION_KEY`     | Email retry only                                                     |
   | `STAGING_RESEND_API_KEY`           | Email retry only                                                     |
   | `RENDER_API_KEY`                   | Deployment and the existing manual verification workflow             |

   Set the environment variable `STAGING_MAINTENANCE_USER_ID` to the dedicated
   account UUID. The two purpose keys must match the API's existing derivations:
   HKDF-SHA256, root `JWT_SECRET`, salt `trotxi:replacement:staging:v1`, 32 bytes,
   info `ACCESS_SECRET` and `DEVICE_KEY` respectively, encoded as base64. Derive
   them privately once and upload directly as secrets. Do not print them or
   rotate the root; changing it would also change keys for existing ciphertext.

6. Validate verified TLS using the external database hostname, not Render's
   internal hostname. Use the trusted CA if required. Never work around a trust
   failure with `no-verify`, `require` or `rejectUnauthorized: false`.
7. Confirm the protected environment has the required secrets before removing
   their repository-scoped duplicates. Review all consumers first. Do not remove
   the owner credential from the database itself: the installer still needs it.

## Coordinated deployment

1. Pause the old scheduled maintenance workflow and wait for any in-flight run
   to finish. Record the interruption so a delayed payment is not mistaken for
   successful processing. Do not enable an additional paid cron service.
2. Keep the old API running while preparing configuration. Save the restricted
   external URL as `REPLACEMENT_RUNTIME_DATABASE_URL` on the staging API, with
   the optional CA. Remove `DATABASE_URL` and any `REPLACEMENT_DATABASE_URL` from
   that service only when ready to deploy the new code. **Do not redeploy the old
   code with these new settings.** It still expects the owner URL.
3. Run the protected installer for the reviewed commit. It validates the two
   restricted roles and service identity, applies migrations and refreshes grants.
   A manual Render deploy alone does not run this installer.
4. Deploy the same commit. Check readiness and build revision. Verify that the
   API login cannot create an `app` object, update append-only history, change
   triggers or write to the migration inventory. Startup must reject the owner.
5. Enable the updated maintenance workflow and dispatch it once. Confirm both
   jobs, worker-origin audit records under the dedicated identity, session
   revocation, and continued payment processing. Email retry only drains existing
   due mail; running it may send those messages. Obtain approval before a live run.
6. Retire the unused `trotxi-cron-staging` environment group only after confirming
   no active service depends on it. Applying `render.yaml` is separate from code
   deployment and must not enable commented paid cron examples.

If cutover fails, keep traffic on the last healthy deployment. Restoring the old
owner-based configuration is a temporary rollback that reopens the finding, not
a successful security rollout. Do not rotate encryption keys as a rollback.

## Historical exposure cleanup

- Inventory runs of the retired `.github/workflows/seed-staging.yml` by ID and
  date without downloading or reposting their sensitive logs. Delete the exact
  approved runs and associated artifacts. GitHub run deletion is irreversible.
- Identify drivers whose credentials were exposed, then reset their PINs through
  Ops. This revokes sessions and may send email/SMS, so confirm the exact driver
  list and delivery choice first. Deleting logs does not invalidate credentials.
- Review affected rider information and payment metadata as a privacy incident.
  Public copies cannot be recalled merely by deleting the original logs.

## Closure evidence

Keep the PR open until the code is tested. Keep the live findings open until the
restricted-role/TLS checks, main-only environment policy, secret migration,
maintenance run, historical log removal and credential resets are recorded.
No account, PIN, historical run, secret or live infrastructure setting is changed
by the checked-in code alone.

The wider review's OTP-abuse policy, driver lockout policy, API documentation
hardening and Firebase console restrictions need their own verified evidence.
This cutover does not certify those controls or a complete SQL-injection audit.
