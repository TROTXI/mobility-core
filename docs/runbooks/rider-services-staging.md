# Rider services: manual staging operations

## Deployment and operating decision

PR #338 is deployed to `trotxi-api-staging` at `59041f1`, including migrations
023–025. On 2026-09-20 UTC, the owner chose **manual runs for now** instead of
adding paid Render cron services. No scheduler, credentials or environment
settings were changed for this verification.

Without a scheduler, these jobs do **not** run automatically. In particular,
accepting a payment webhook stores evidence; the inbox must be processed to
activate a purchase. Lazy pause settlement on selected request paths is not a
replacement for scheduled maintenance.

## Running existing workers manually

Use the staging service's shell and existing configuration. Each job needs the
UUID of the existing active operations account for attribution. If it is not
already configured, supply `REPLACEMENT_MAINTENANCE_USER_ID` for that invocation
only; it is an account identifier, not a new secret or database credential.

```sh
REPLACEMENT_MAINTENANCE_USER_ID='<existing operator UUID>' node dist/worker.js trip-generation 2026-09-21
REPLACEMENT_MAINTENANCE_USER_ID='<existing operator UUID>' node dist/worker.js personal-pause-resumes
REPLACEMENT_MAINTENANCE_USER_ID='<existing operator UUID>' node dist/worker.js push
REPLACEMENT_MAINTENANCE_USER_ID='<existing operator UUID>' node dist/worker.js emails
REPLACEMENT_MAINTENANCE_USER_ID='<existing operator UUID>' node dist/worker.js erasures
```

Replace the illustrative travel date before running. Trip generation defaults
to tomorrow when its date is omitted. Assign a driver and vehicle afterwards;
generation deliberately creates unassigned departures.

Run pause settlement before period-close processing. Push requires registered
devices and the existing Firebase service account. Email requires the existing
Resend configuration. Review pending recipients before sending staging mail;
test delivery is not permission to email unrelated recipients.

Jobs emit bounded results and exit unsuccessfully on failures. An empty batch
proves the worker can run, **not** that a notification was delivered or a pause
actually resumed. No public cleanup endpoint or new scheduler was added.

For payment callbacks, authenticated ops can run the existing
`POST /v1/ops/maintenance/payment-inbox` with `{ "limit": 100 }`. This is distinct
from `/v1/ops/maintenance/payments`, which also reconciles and closes periods.
Do not use the broader endpoint when only inbox processing is intended.

## Verification performed on 2026-09-20 UTC

- Confirmed deployed migrations 023–025 in staging.
- Read ride and credit histories and obtained an authoritative price preview
  through the deployed API using a seeded disposable rider.
- Previewed and confirmed a September 21–25 pause, replayed confirmation with
  the same key (same pause, HTTP 201), and shortened resume to September 24.
  The latest-pause response remained scheduled with no extension applied yet.
  This did not alter the owner's Google-linked subscription.
- Uploaded a probe avatar through the deployed multipart API on a separate
  disposable account, deleted it (204), confirmed avatar reads return 404,
  and ran the existing cleanup implementation scoped to that account.
  Its physical R2 object also returned 404 afterwards.
- Manually ran the current worker implementation against staging: generated
  six September 21 departures with zero failures; due-pause processing and
  push both completed with empty queues. These were local worker processes
  using the staging database/providers, not deployed Render cron executions.
- Created a separate disposable purchase through the staging API; the owner
  completed its GHS 264 Paystack TEST checkout. Its real signed charge callback
  was processed through the deployed inbox endpoint, fulfilling the purchase.
  The ops refund endpoint returned 202 and Paystack accepted the full TEST
  refund. Paystack's read-only refund lookup still reported `pending` at the
  final check; no completed-refund accounting result is claimed.

### Defect found by the real refund callback

The signed `refund.pending` event contains an assigned string `id` but
`refund_reference: null`. The deployed parser required a non-null reference.
This branch accepts the provider's refund ID, and uses it consistently even
if a later status carries a reference, to avoid splitting one refund into two
accounting rows. Malformed supplied IDs and absent identities still fail closed.
Reference-only historical evidence remains supported.

The pending callback was deliberately left queued on staging instead of
feeding it to the old parser, which would quarantine it. Merge/deploy the parser
fix before processing that inbox. The new regression uses the real field shape
with synthetic identifiers, then proves against Postgres that pending,
processed, replayed and out-of-order events produce one refund and one reversal.
The live check does not fabricate a processed callback while Paystack is pending.

## What remains unproven

- Actual pause activation/resumption on the future dates and its resulting
  coverage extension on staging. Automated database tests cover that rule;
  this check did not advance or rewrite the staging clock.
- Actual push presentation and tap navigation: staging has no active registered
  devices, and the commuter app has not implemented device registration and
  native message handling. A zero-delivery worker run is not a delivery pass.
- Recurring execution, deliberately deferred by the manual-run decision.
- Provider completion of the pending TEST refund and final accounting after
  its genuine callback. The initiation passed; completion remains outstanding.

## Frontend handoff

The canonical package remains `apps/api_client` (`trotxi_api_client`), generated
from `docs/design/contracts/replacement.openapi.json`. No `_next` fork is used.
The [rider services guide](../backend-rider-services.md) describes business rules
and example requests; examples there are illustrative, not live captures.

Adom can now use the generated methods on:

- `RiderOwnApi`: `previewPurchase`, `previewPersonalPause`, `createPersonalPause`,
  `getPersonalPause`, `resumePersonalPause`, `listRideEntries`, `listCreditEntries`.
- `SelfApi`: `deleteAvatar`; existing multipart upload/device registration APIs
  remain the integration boundaries for those features.
- `OpsApi`: refund initiation and refund-request inspection, for ops only.

Always retain the same idempotency key for a retry of the same mutation. Pause
dates are calendar dates, money is integer pesewas, a price preview is not a
reservation, and a 202 refund response is not completed repayment.

Regenerate serializers after code generation:

```sh
pnpm codegen:replacement
cd apps/api_client
dart pub get
dart run build_runner build
dart test test/rider_services_serialization_test.dart
```

The focused test checks nullable pause responses, date/extension serialization,
price-preview money/renewal semantics and signed ride deltas/pagination. CI runs
it alongside the shared Flutter client job.
