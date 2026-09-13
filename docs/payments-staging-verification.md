# Staging payment verification

The **Payments staging verification** GitHub Actions workflow is manually
dispatched from `main`; pushes and pull requests do not run sandbox payments.
It never deploys, migrates, enables cron, edits Paystack settings, closes periods,
or deletes data. All fixture records remain in staging for inspection.

## Prerequisites

- Review and merge this workflow before dispatching it from Actions.
- Configure the `staging` environment's deployment-branch restrictions to `main`
  and appropriate required reviewers. The job also checks its branch, but the
  environment restrictions are the credential boundary against modified branches.
- Existing secrets: `RENDER_API_KEY`, `STAGING_DATABASE_URL`. The latter must
  identify staging, never production. The workflow cannot prove which database
  an incorrectly configured secret identifies.
- Existing variables: `STAGING_URL=https://trotxi-api-staging.onrender.com` and
  `RENDER_STAGING_SERVICE_ID=srv-d8suhkn7f7vs73bigd40`. Scripts fail closed for
  other API/service targets and for a non-`sk_test_` Paystack key.
- PostgreSQL TLS certificate verification is required. If the database chain is
  not trusted by the runner, set `STAGING_DATABASE_CA_CERT` to its trusted CA PEM
  obtained from the database operator. Do not bypass validation. The one-off
  verification used relaxed TLS; this reusable version intentionally does not.
- Paystack **Test Webhook URL** must be
  `https://trotxi-api-staging.onrender.com/webhooks/paystack`.

Credentials are read from Render only inside the runner and masked. JWT signing
configuration is fetched only for `setup`; it creates a ten-minute commuter JWT
for the synthetic rider, never an admin JWT. Input values are passed as environment
variables rather than interpolated into shell source. Summaries contain only
synthetic fixture IDs, test checkout URLs, references and verification results.

## Run sequence

1. Dispatch `audit-contract`. Inspect the audit query results in the logs. SQL
   errors fail the job, but returned anomaly rows are a report, **not an automatic
   failure gate**. This phase also initializes and verifies one unpaid provider-only
   test transaction; it does not create a staging payment or charge real money.
2. Dispatch `setup`, leaving `fixture_id` blank for a fresh UUID (or supply a fresh
   UUID v4). Keep the UUID and hosted checkout URL from the job summary. Setup
   creates a labelled rider, route, 600-pesewa fixture fare and monthly checkout,
   and verifies that a duplicate checkout returns 409. It is not a fulfilment test.
3. Open the hosted URL, confirm it says **TEST**, and complete the payment using
   Paystack's official sandbox details. Never use live payment credentials.
4. Dispatch `verify-delivery` with that fixture UUID. It waits up to 30 seconds for
   fulfilment, independently verifies the provider amount/currency/reference/domain
   and transaction ID, checks a processed non-replay inbox event, one allocation
   matching the frozen ride grant, and the matching open subscription period.
   It performs no application writes, manual webhooks or reconciliation calls.
5. Optionally dispatch `replay` with the same UUID. It first requires the delivery
   check to pass, posts two identical signed test replays, waits for their inbox
   event to be processed, then asserts there is still exactly one allocation.
   Replays carry a marker so they cannot alone satisfy `verify-delivery`.

Each new setup UUID gets isolated records and a synthetic `example.com` email.
Reusing a setup UUID fails without upserting or modifying the existing fixture.
After an interrupted setup, inspect its summary and database records before
deciding whether to create a new UUID; no automatic cleanup/recovery is attempted.

Do not run external manual replays or reconciliation against a fixture while
testing automatic delivery. The inbox verifies a shared HMAC, not independent
sender provenance; this tool's marker only distinguishes its own signed replays.

## Scope and prior evidence

The original sandbox runs also verified period close, conversion at the frozen
rate, duplicate-close idempotency, exact credit reservation/capture and renewal
into a new immutable period. They deliberately moved a labelled fixture's clock
and used a global admin close endpoint. That operation is excluded here: a preflight
query cannot prevent an unrelated period becoming due before a global close.
The real-Postgres lifecycle tests remain in normal CI for those invariants.

- Original renewal and audit: https://github.com/TROTXI/mobility-core/actions/runs/34750132362
- Automatic provider delivery after fixing the empty test webhook URL:
  https://github.com/TROTXI/mobility-core/actions/runs/34750674114

Those runs validated the one-off scripts against staging, not this refactored
manual workflow. Its first post-merge dispatch must confirm the trusted-CA setup
and reusable fixture flow. A passing staging run is not a production-readiness
approval or authorization to enable maintenance scheduling.
