# Subscription offers, payments and renewal

Source audit: 2026-10-08. New purchases require an Ops offer. There is no
public fixed-price checkout or cash top-up wallet. The backend supports
consent-based card renewal; commuter controls remain frontend work.
See [Automatic card renewal](#automatic-card-renewal).

## Request to payment

1. A signed-in commuter completes their name and verifies a Ghana phone.
2. They request a route, outbound and return journeys, monthly/annual preference
   and travel weekdays through `POST /v1/me/standby`.
3. Ops reviews the queue and sends an offer with coverage dates, package price,
   payment deadline and unused-ride credit for both directions.
4. The app displays the terms. Acceptance creates one purchase and opens
   customer-authorized Paystack checkout, optionally applying available credit.
5. Verified provider evidence fulfils the purchase. A return URL or checkout
   screen is not proof of payment. The app reads the purchase to recover status.

`POST /v1/me/purchases` cannot bypass the offer requirement. An offer does not
reserve fleet capacity; Ops must verify supply and reservations still enforce
capacity. Standby is the subscription request queue, not a single-seat market.

## Pricing and dates

Ops publishes an effective-dated fare for each ordered stop-occurrence pair on
a published route version. B-to-C and C-to-D may differ; B-to-D needs its own
fare, not their sum. Return journeys have separate prices.

The offer freezes route/version, stops, schedules, applicable weekdays, fares,
directional allowances, package price and credit values. Ride counts come from
actual coverage dates intersected with requested and scheduled weekdays, not a
fixed 44. Coverage starts at midnight Ghana time and excludes the end date.
Each direction must have service; one-way offers and holiday exclusions are
not implemented. Coverage lasts at most 366 days.

Ops chooses the package total. Each unused-ride credit is no greater than its
journey fare; all potential credits together cannot exceed the package price.
Money is integer pesewas in storage and API `amountMinor`; UI renders GHS.
There is no fixed 264/2640 product price. Historical plan-pricing controls remain
for compatibility, not the price source for newly offered packages.

## Renewal

One future paid period may coexist with current coverage without overlap. A
new offer can start exactly at the current period's midnight end. Legacy
mid-day boundaries require a later date. The wallet separates upcoming coverage
from current spendable rides.

Reservations and day-ahead asks select the paid period covering departure.
A rider can confirm the first renewal trip before midnight without spending
current-period rides. Old-period settlement is not required to switch coverage.

Only already-created available Ride Credit can reduce early renewal payment.
Unused current rides are not projected into credit. Pending/paid renewals block
pauses and commute changes that could extend the preceding period into them.
This applies to Ops too; resolve/refund the upcoming renewal before changing dates.

## Automatic card renewal

The API supports reading renewal state (`GET /v1/me/auto-renewal`) and explicit
opt-in or opt-out (`PUT /v1/me/auto-renewal` with `enabled: true` or `false`).
The generated Dart client exists, but the commuter app does not yet expose
opt-in, turn-off or remove-card controls. Do not describe this as a completed
mobile flow or enable it on a rider's behalf without consent.

The intended app flow asks for consent before offer checkout. Consent alone
does not save a card: a verified reusable card payment is required. Mobile
money cannot be charged later, so it never enables renewal.

1. Fulfilment of a verified card payment that Paystack marks reusable saves
   the card (code and bound email sealed under a key derived for cards only;
   brand, last four and expiry readable) and schedules the renewal of the
   period it bought.
2. Five days before the period ends the rider is emailed the card and amount.
   The generic "renew it yourself" reminder is not sent for that period.
3. From three days before the end, the nightly worker rebuilds the terms with
   the offer builder: same journeys, travel days, package price and unused-ride
   credit, for a period of the same length starting at the old end. Rides are
   recounted for the new dates. Available Ride Credit is applied as at checkout.
4. If a fare changed or the service no longer covers the new dates, nothing is
   charged: the renewal becomes `needs_offer`, the rider is told, and Ops sends
   a new offer.
5. Otherwise it creates the renewal purchase and charges the card through
   Paystack. Only verified, persisted evidence fulfils it, exactly as for any
   payment. A decline fails that purchase; the worker retries daily with a new
   one until the period ends, emailing the rider each time.
6. A charge that never settles expires when the coverage it buys begins, so it
   cannot hold the rider's purchase slot.

The API lets the rider turn renewal off or remove the card
(`DELETE /v1/me/auto-renewal/card` destroys the stored authorization code).
Removing the local copy does not deactivate the authorization at Paystack.
Account erasure does
both. The database refuses a renewal purchase that differs from the purchase
it renews in rider, route or price, or that does not start where it ends.

## Settlement and recovery

The API verifies Paystack signatures and persists deduplicated provider events.
Workers process evidence, verify unresolved attempts and close eligible periods.
Collections must match the expected purchase, amount, currency and environment.
Idempotency and transactional fulfilment prevent duplicate allocations.

An expired offer may leave an open Paystack page. Late or conflicting collections
go to Ops review rather than activating invalid coverage. Local expiry releases
holds but does not prove that the provider collected nothing. Check the original
collection before advising another payment.

Ops can initiate a TEST refund and inspect accepted/unknown intent; a submitted
refund is not settled cash. Processed refund and dispute evidence drive the
financial effects. Refunds of upcoming coverage affect that purchased period,
not unrelated current rides. Partial/consumed-value cases require review.

The checked-in GitHub workflows schedule payment recovery and email retry every
15 minutes and card renewal in nightly service maintenance, subject to
environment configuration. See [deployment](../DEPLOY.md#scheduling) for the
full schedule and its boundaries.

Ops has **More > Payments > Card renewals**, showing renewal status, failure
reason, masked card, price and next attempt. `needs_offer` entries link to
Standby for a new offer. This review screen does not supply rider consent.

## Limits and verification

Operator payouts, corporate invoicing and automatic standby-seat cascades
remain separate work. Mobile money cannot renew automatically.
Staging uses Paystack TEST only.

Sources: `membership/standby.ts`, `membership/offer-terms.ts`,
`payments/{pricing,foundation,purchases,recovery,auto-renewal}.ts` under
`services/api-next/src`; migrations 041/042/044; `tests/pricing.pg.test.ts`.
Use the [staging runbook](../runbooks/rider-services-staging.md) for acceptance.

## Who does what

```mermaid
sequenceDiagram
  participant Commuter
  participant API
  participant Ops
  participant Paystack
  participant Worker
  Commuter->>API: Submit verified service request
  Ops->>API: Read request and send priced offer
  Commuter->>API: Read terms and accept
  API->>Paystack: Initialize checkout
  API-->>Commuter: Purchase and checkout instructions
  Commuter->>Paystack: Authorize TEST payment
  Paystack->>API: Signed payment evidence
  API-->>Paystack: Persisted webhook acknowledgement
  Worker->>API: Process inbox and reconciliation
  Commuter->>API: Read purchase and membership
  API-->>Commuter: Fulfilled or actionable state
```

This is the successful path. Webhook timing can differ, and duplicate callbacks
are expected. The worker's verified transactional result, not message order or
the return URL, establishes coverage.

Ops selects terms; the commuter explicitly accepts/pays; the API freezes and
enforces them; Paystack reports collection; workers process evidence; Ops
resolves review/refund cases. Frontend code must not allocate rides itself.

## State and recovery

| Resource/state                             | Meaning                                   | Correct next step                                                |
| ------------------------------------------ | ----------------------------------------- | ---------------------------------------------------------------- |
| Application `submitted`                    | Request exists, no payable offer yet      | Ops checks supply and prepares terms                             |
| Application `offered`                      | Terms can be reviewed                     | Commuter accepts before expiry or withdraws                      |
| Offer `accepting`                          | One acceptance key owns checkout creation | Retry the same logical request/key after an uncertain response   |
| `checkout_open`                            | Purchase is linked                        | Read that purchase; do not create another direct checkout        |
| Purchase `awaiting_payment` / `processing` | No confirmed fulfilment yet               | Recover the same purchase and check processing                   |
| Purchase `fulfilled`                       | Its service value was granted             | Read membership; future coverage still shows upcoming            |
| Purchase `review_required`                 | Automated fulfilment cannot safely finish | Ops reviews evidence; do not instruct another payment            |
| Purchase `failed` / `cancelled`            | Purchase does not provide new coverage    | Inspect failure/collection evidence before replacement or refund |

Application completion is not proof of payment: it can also follow a failed
purchase. Always read the purchase state and current membership.

| Refusal                           | Resolution                                                            |
| --------------------------------- | --------------------------------------------------------------------- |
| `phone_verification_required`     | Verify the current account's phone                                    |
| `standby_profile_incomplete`      | Complete rider name                                                   |
| `invalid_offer_expiry`            | Use an allowed future deadline no later than coverage start           |
| `coverage_active`                 | Set non-overlapping coverage dates                                    |
| `offer_expired`                   | Review any existing collection before requesting a fresh offer        |
| `idempotency_conflict`            | Do not change payload beneath an existing command key                 |
| Uncertain provider/network result | Keep original identity and reconcile, never assume “nothing happened” |

## Worked price and renewal

For coverage from 5 October through the exclusive 2 November 2026 boundary,
Monday-Friday service gives 20 rides per direction. Example fares are GHS 10
each, package price GHS 400 and unused credit GHS 5 per ride. API values are
1000, 40000 and 500 pesewas. Total potential unused credit is GHS 200.
These are illustrative terms, not a product default.

A renewal starting 2 November can be paid before that date. The evening before,
confirmation of a covered departure uses the renewal period. The wallet still
shows it as upcoming until midnight. Closing the old period converts only its
unused value; it must not consume or close the renewal.

Requests: [offer/payment examples](../api/worked-examples.md#3-request-offer-and-pay).
Code: [standby](../../services/api-next/src/membership/standby.ts),
[offer terms](../../services/api-next/src/membership/offer-terms.ts),
[purchases](../../services/api-next/src/payments/purchases.ts),
[foundation](../../services/api-next/src/payments/foundation.ts),
[recovery](../../services/api-next/src/payments/recovery.ts).
UI: [Ops offers](../../apps/ops/src/screens/Standby.tsx),
[commuter offers](../../apps/trotxi_commuter/lib/Features/Home/widgets/Tabs/standby_page.dart).
Tests: [pricing and prepaid renewals](../../services/api-next/tests/pricing.pg.test.ts).
