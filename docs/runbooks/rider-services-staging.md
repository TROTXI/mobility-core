# Rider services: manual staging operations

## Ops-priced subscription offer rollout

The offer flow is documented in
[Subscription offers, payments and renewal](../features/payments-and-wallet.md). It requires migrations 041 and 042, the regenerated API clients and the
updated Ops and commuter applications. The historical checks below are not
evidence that this new flow has been deployed or exercised with Paystack.

Publish exact stop-pair fares before sending offers. Set the agreed package
price and both journey credit rates explicitly. Confirm travel days and actual
calendar ride counts with the rider. Use Paystack TEST only during staging.
Retire old direct-checkout builds through the existing minimum-build controls
as part of the coordinated rollout; they cannot create purchases in this flow.

Expiry releases local held credit on the next rider offer refresh/request or
checkout. It does not prove that no money was collected. Check late-payment
reviews before advising another payment or initiating a refund. Existing paid
subscriptions and provider evidence are not reset by this change.

An already-open Paystack page may still accept a payment after the local offer
expires. Such a collection does not activate coverage: Ops must review the
provider evidence and arrange a refund or agree a fresh offer. A fresh offer
does not automatically transfer the late payment. Do not tell the rider to pay
again until the first collection is resolved.

Paid future coverage is not reported as current and has no spendable ride
balance before its start date. The paid purchase and its agreed coverage dates
remain visible in payment history. Waitlist entry is free and does not promise
a seat; monthly and annual are requested plans, with final dates and allowances
set in the Ops offer.

For continuous renewal, set the new start to the current end date and let the
rider pay before that boundary. The wallet shows paid upcoming coverage
separately. Only one future period may be prepaid. No job is needed to switch
current coverage at the start instant; settlement of old unused rides remains
separate and must finish before those credits can fund another payment.
Resolve any planned or active pause first. A pending or paid renewal locks
pause/commute changes on the preceding period. Do not extend coverage manually
into the new period: overlapping collections require Ops review. Refunds of an
upcoming purchase must leave current coverage and its ride balance untouched.
The pause restriction applies to Ops as well as riders, including during a
service disruption. Resolve the upcoming renewal through the refund/review
workflow before pausing current coverage and agreeing replacement dates; do
not edit frozen offer terms or extend one period into another.

On the evening before renewal, generate the next day's trips and run
ask-dispatch. The rider can confirm those departures immediately. Reservations
and prompts use the period covering the departure time, while the wallet keeps
the renewal marked upcoming until its start. Unused renewal rides cannot fund
departures outside that period.

## Deployment and operating decision

The checked-in GitHub Actions workflows run payment inbox/reconciliation and
email retry every 15 minutes on main, using the protected staging environment.
Service maintenance also schedules nightly trip generation, pause resumes,
route learning, GPS retention and card renewals, plus daily asks, defaults and
no-shows. Push, erasure and other unlisted cleanup jobs still need separate
invocation. See [the schedule](../DEPLOY.md#scheduling) and check the relevant
job result before claiming it ran.

Accepting a webhook stores evidence; inbox processing activates eligible
purchases. Lazy pause settlement on selected request paths is not a substitute
for maintenance. See [deployment](../DEPLOY.md) for configuration and permissions.
Record the deployed revision and job outcome separately for each test.

## Running existing workers manually

Use the approved maintenance runtime and its restricted database login, not
the API service's database credentials. Supply the configured non-human
maintenance account as `REPLACEMENT_MAINTENANCE_USER_ID`, never a human admin.
See [staging security](../operations/staging-security.md).

```sh
REPLACEMENT_MAINTENANCE_USER_ID='<maintenance account UUID>' node dist/worker.js trip-generation 2026-09-21
REPLACEMENT_MAINTENANCE_USER_ID='<maintenance account UUID>' node dist/worker.js personal-pause-resumes
REPLACEMENT_MAINTENANCE_USER_ID='<maintenance account UUID>' node dist/worker.js push
REPLACEMENT_MAINTENANCE_USER_ID='<maintenance account UUID>' node dist/worker.js emails
REPLACEMENT_MAINTENANCE_USER_ID='<maintenance account UUID>' node dist/worker.js erasures
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
actually resumed. Cleanup remains restricted maintenance work, not a public
endpoint.

For payment callbacks, authenticated ops can run the existing
`POST /v1/ops/maintenance/payment-inbox` with `{ "limit": 100 }`. This is distinct
from `/v1/ops/maintenance/payments`, which also reconciles and closes periods.
Do not use the broader endpoint when only inbox processing is intended.

## Client integration

The canonical package remains `apps/api_client` (`trotxi_api_client`), generated
from `docs/design/contracts/replacement.openapi.json`. No `_next` fork is used.
The [rider services guide](../backend-rider-services.md) describes business rules
and example requests; examples there are illustrative, not live captures.

Use the generated methods on:

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
