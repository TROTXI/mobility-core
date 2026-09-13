# ADR-0014 — Hybrid Subscription Model supersedes the wallet/top-up money model

**Status:** accepted · **Date:** 2026-07-04 · **Supersedes the money semantics of** ADR-0011 (the ledger _pattern_ stands)

## Context

The money system was built as: subscription = platform membership fee (no rides
included) + a separate prepaid GHS wallet funded by top-ups, with boarding
debiting the route's fare in pesewas (#66, #68). Further money work was then put
**on hold** pending the product team's commercial model.

That decision has landed: the **Trotxi Hybrid Subscription Model** ("Mobility
Membership" master doc, June 2026; engineering plan in
`strategy/docs/hybrid-subscription-model.md`). Target market per the investor
strategy: **corporate commuters** on scheduled, reserved-seat shuttles —
asset-light, demand-aggregated.

## Decision

Adopt the Hybrid Subscription Model as the commercial/money model:

- **Subscription = the product.** Monthly plans (standard/premium/corporate/
  student) buy a **ride entitlement** (working days × 2 trips). No prepaid
  wallet; "tokens" are retired as a user-facing concept.
- **Deduct one ride only when it commits:** on successful boarding verification
  (any of driver-manifest / daily 4-digit PIN / QR scan), or on a confirmed-yes
  **no-show**. Operator failure never deducts (optional compensation credit).
- **Daily ride confirmation** (push, evening + midday windows; no response =
  travelling by default) drives seat reservation and the driver manifest.
- **Ride Credits:** unused rides convert at month end to a GHS value (stored in
  pesewas) that discounts the next renewal. Loyalty may also issue credits.
- **Standby pool** (KYC'd non-subscribers) takes released seats and pays per
  single journey instantly — the only pay-per-ride path.

Two append-only ledgers replace the wallet: an **entitlement ledger** (ride
counts) and a **credit ledger** (pesewas) — the same exactly-once,
derived-balance pattern as ADR-0011.

## Consequences

- **Foundations stand:** boarding QR core (#93) becomes the verification layer
  (plus PIN + manifest/photo); FCM device tokens (#84) power the confirmation
  notifications; Paystack module extends (variable renewals, `standby_fare`);
  pesewas storage and idempotency discipline are unchanged.
- **Retired (E7 complete):** `POST /payments/topup`, `GET /me/balance` and the
  `token_ledger` table no longer exist.
- **Core phases shipped:** ride/credit ledgers, daily confirmation, capacity,
  boarding, credit conversion, fare-derived pricing and credit-netted checkout.
- **Still open:** approved commercial values, tier taxonomy, corporate billing,
  standby KYC/offer flow, recurring mandates and payout execution.

## Current implementation — 2026-09-12

The core model is live: effective-dated corridor fares, ops-editable plan
levers, checkout snapshots, billing periods, ride allocation, capacity-aware
confirmation, QR/code/photo boarding, no-show deduction, period-end conversion
and credit-netted renewal checkout. Pickup/drop-off stops are snapshotted onto
payments, subscriptions and reservations.

The current plan keys remain `monthly` and `annual`; the proposed
standard/premium/corporate/student taxonomy is not implemented. Standby KYC,
seat-offer cascade, single-journey payment, automatic renewal mandates,
corporate billing and payout execution remain deferred. The operator take rate
is now configurable, but commercial values still require approval.

### Payment lifecycle amendment — 2026-09-12

Each successful payment now owns an immutable `subscription_periods` row. Ride
allocations, reservations, boarding/no-show debits and period conversion carry
that period id. Renewal reactivates the same subscription with a new period
instead of attempting to create a second active row.

Ride Credit is held transactionally at checkout and captured only inside the
successful fulfilment transaction. Period conversion and expiry are one atomic
operation, use the sold period's frozen conversion rate, and wait for all funded
reservations to settle. The two legacy admin triggers delegate to that same
operation.

Paystack delivery is a durable inbox plus independent Verify reconciliation.
Refunds change entitlement only at `refund.processed`; disputes freeze the
purchased period until explicitly declined or followed by an authoritative
refund. These are accounting state transitions, not best-effort webhook side
effects.
