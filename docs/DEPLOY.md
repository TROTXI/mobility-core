# Deployment

Source audit: 2026-10-08. This is the current staging procedure.
It replaces the retired backend/owner-runtime cutover instructions.

## What the repository configures

`render.yaml` declares the existing staging API with
`services/api-next/Dockerfile`, paid staging PostgreSQL and the Ops static site.
The API plan is declared free. This document does not verify dashboard plan
overrides, current billing or production deployment. Production services and
paid cron examples remain commented out.

`.github/workflows/deploy.yml` is staging-only. For eligible successful
same-repository main CI, with `DEPLOY_ENABLED=true`, it:

1. Checks out the exact tested commit.
2. Runs `scripts/migrate-staging.ts` with the protected installation credential,
   validating restricted API/maintenance roles and applying migrations/grants.
3. Verifies that the required Ops CSP has already been applied.
4. Deploys the API commit and checks health, readiness and version.
5. Deploys Ops from the same commit and checks the website/legal pages.

Manual workflow dispatch is also guarded to main and the staging environment.
A direct Render deploy does not substitute for the installer.

## Credentials and configuration

The API must use `REPLACEMENT_RUNTIME_DATABASE_URL`, not the database owner.
API startup verifies restricted permissions and the migration inventory rather
than installing migrations. Maintenance uses a separate restricted connection
and a non-human identity. External database connections verify TLS.

The named staging profile maps existing provider settings and derives
purpose-separated internal keys from its staging root. Do not casually rotate
that root: stored ciphertext also depends on it. Scheduled payment/email jobs
receive only their needed derived key and provider configuration, not the root
or Render credential.

Use [staging security](operations/staging-security.md) for the exact secret,
role and environment setup. Provider configuration remains in
`services/api-next/src/runtime/config.ts` and `staging-profile.ts`.
Never put server secrets in Vite variables, mobile build definitions or docs.

## Headers and static pages

Merging `render.yaml` does not apply settings to an existing Render service.
Apply reviewed headers/rewrites through the Blueprint or service settings,
without enabling unrelated commented services. Verify actual response headers.

- [CSP apply/check procedure](operations/ops-csp.md).
- [Hashed-asset cache rule](operations/request-performance.md).
- [Privacy, deletion and terms pages](runbooks/public-privacy-pages.md).

## Scheduling

Two main-only workflows use the protected staging environment:

| Workflow / group               | UTC (Accra)      | Work                                                                                                                 |
| ------------------------------ | ---------------- | -------------------------------------------------------------------------------------------------------------------- |
| Payments and email maintenance | Every 15 minutes | Payment recovery and due email retries in separate jobs                                                              |
| Service maintenance / nightly  | 01:30 daily      | Generate trips for the next seven days, resume personal pauses, route learning, GPS retention and card auto-renewals |
| Service maintenance / ask      | 21:00 daily      | Tomorrow's reservation prompts, both directions                                                                      |
| Service maintenance / defaults | 00:00 daily      | Today's unanswered reservation defaults, both directions                                                             |
| Service maintenance / no-shows | 23:30 daily      | Today's no-show settlement, both directions                                                                          |

Actual execution depends on Actions and configured secrets; schedule timing
is not a strict delivery SLA. The service workflow also supports manual
dispatch by group. Its runner calls authenticated maintenance endpoints with
the restricted maintenance identity, not an owner database credential.

These schedules do not invoke every available worker. Push delivery, erasure
processing and retention/cleanup jobs other than those explicitly included
need their own approved invocation. Creating reservation prompts does not
itself send FCM notifications.
Sources: `.github/workflows/{payments,service}-maintenance.yml` and
`services/api-next/scripts/maintain-staging.ts`.
See [manual rider operations](runbooks/rider-services-staging.md).
Do not assume comments in Render examples enable a job or grant spending approval.

## Release gates

Staging uses Paystack TEST credentials and synthetic/test accounts. Production
needs separately approved infrastructure, database/keys/provider credentials,
environment-specific mobile configuration, live payment acceptance, store
signing/privacy declarations and physical-device testing.

No production deployment job or automatic mobile store release is claimed here.
A simulator pass does not prove lock-screen GPS, push delivery or real-device
network recovery.

## Recovery

Do not reset a database or weaken its role to make a deployment pass.
Use the [replacement runbook](runbooks/replace-staging-database.md) for approved
database replacement, and [erasure recovery](design/account-erasure-recovery.md)
before releasing any restored snapshot. Later account closures must be replayed
with source-write fencing and writer-generation checks.

## First superadmin setup

Deploy migration 043 and its runtime grants, then the API, then Ops from the
same release. The new UI calls `/v1/auth/ops/google`. Existing admins keep their
operational access, but cannot invite administrators or reset another operator's
passkeys until an initial superadmin has been bootstrapped.

Use an existing approved Google administrator with at least one active passkey
and a successful passkey check within the current eight-hour session window.
Confirm the exact account UUID and database name from trusted administrative
records. Staging and production are separate decisions. This command does not
create infrastructure, select an account by email or provision a brand-new
environment's first identity.

With explicit approval, an installer can run from `services/api-next`:

```sh
pnpm exec tsx scripts/bootstrap-superadmin.ts \
  '<EXACT_ACCOUNT_UUID>' '<EXACT_DATABASE_NAME>' 'confirm:<EXACT_ACCOUNT_UUID>'
```

Supply the approved installer connection through `REPLACEMENT_DATABASE_URL`
using the protected secret mechanism. Do not put credentials in the command,
logs or repository. The command ignores ordinary `DATABASE_URL`, checks the
database name, refuses if bootstrap already happened or a superadmin exists,
and records the promotion atomically. The API runtime role cannot write the
bootstrap marker. Sign out and back in to refresh the menu afterwards.

Invitation mail uses the existing Resend settings and configured Ops origin.
Missing mail configuration refuses invitation creation rather than reporting
success. Test with an explicitly approved recipient before rollout. Check
wrong-account refusal, first passkey setup, resend invalidation, cancellation,
and immediate loss of access after account deletion. Confirm the erased profile,
attributed audit event and queued external cleanup. No live delivery is proved by
local tests.

The bootstrap command is not a reusable recovery backdoor. If the sole
superadmin loses every passkey, stop and use a separately reviewed, audited
installer recovery procedure after identity verification. Never remove the
bootstrap marker to rerun setup. Prefer two enrolled passkeys and a separately
approved backup superadmin before relying on this workflow.
