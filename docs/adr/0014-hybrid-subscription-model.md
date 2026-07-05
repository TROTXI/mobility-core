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
- **To retire (E7):** `POST /payments/topup` and the wallet balance semantics of
  `GET /me/balance` — after entitlements land. Staging-only data; no migration
  of real funds needed.
- **Build phases** E1–E7 and the data-model sketch live in
  `strategy/docs/hybrid-subscription-model.md`; critical path is
  trips/capacity (#18) → daily confirmation → boarding v2.
- **Still open (product):** operator/fleet-partner revenue share %, tier
  pricing, per-ride credit value, corporate billing, standby KYC scope — none
  block E1–E4.
