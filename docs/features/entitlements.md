# Ride entitlements & credits

**Owner:** Godfred Awuku · **Last updated:** 2026-07-08 · **Issue:** #100 (epic E1) · #104 (E5)

The money core of the **Hybrid Subscription Model** (ADR-0014). A subscription
buys a **ride entitlement** (a count of rides for the period); unused rides
become **Ride Credits** (pesewas) that reduce the next renewal. Both are modelled
as **append-only, idempotent ledgers** — the same no-lost-update pattern the old
token wallet used (system-design §4.1), reused twice.

> **Scope (E1):** the two ledgers, allocation-on-subscription, and `GET /me/rides`.
> **E5 (built):** month-end **credit conversion** — unused rides → Ride Credits.
> Deferred: plan tiers/prices (E1b); **credit-netted renewal + auto-renew (E5b,
> #104)** — applying credit to reduce a renewal charge, incl. the "credit covers
> the whole fee" (zero-charge) edge.

---

## Concepts

- **Entitlement ledger — ride counts.** `remainingRides = SUM(delta_rides)`.
  `+N` on allocation, `-1` on boarding/no-show, `+1` on operator-cancel return.
- **Credit ledger — pesewas.** `balance = SUM(delta_pesewas)`. Credit is granted
  (month-end conversion, compensation, loyalty) and spent against a renewal.
- **Exactly-once.** Every append carries a unique `idempotency_key`; a retry is a
  no-op. Allocation is keyed by the payment reference, so a re-delivered Paystack
  webhook never double-allocates.
- **Allocation happens on payment.** The Paystack `charge.success` webhook, on
  activating a subscription, also allocates the period's rides — one flow, both
  idempotent.

---

## API

#### `GET /me/rides`

The rider's balance (replaces the removed wallet `GET /me/balance`; FE #35).

- **Auth:** `Bearer`. **Rate limit:** per user.
- **200:** `{ "remainingRides": 44, "creditPesewas": 0 }`
- **401** · **429** · **503** not configured

#### `POST /admin/convert-credits` (E5)

Month-end job: convert **every active rider's** unused rides to Ride Credits.
A Render cron hits this with an admin token at each period end.

- **Auth:** `Bearer` **admin**. **Rate limit:** per user.
- **200:** `{ "riders": <n>, "ridesConverted": <n>, "creditPesewas": <n> }`
- **401** · **403** (non-admin) · **503** (no subscription store wired)

---

## Credit conversion (E5)

At period end a rider's remaining rides are worth a credit toward their next
renewal; the rides are then **retired** so they don't carry forward.

- `creditPesewas = remainingRides × creditPesewasPerRide`, keyed by the rider's
  subscription id (the ending period) — re-running is a no-op.
- **Credit is granted before the rides are retired**, so a crash mid-way
  converges exactly-once: a retry re-reads the full remaining, recomputes the
  identical amount, no-ops the already-granted credit, and applies the debit.
- `creditPesewasPerRide` is a **placeholder** (`PLACEHOLDER_CREDIT_PESEWAS_PER_RIDE
= 45`, ~ fee ÷ rides) until E5 pricing is decided (#104) — same posture as
  `PLACEHOLDER_RIDES_PER_PERIOD`.
- **Not yet built (E5b):** applying the accrued credit to _reduce_ a renewal
  charge, and card auto-renew.

## Data

```
entitlement_ledger(id, user_id, delta_rides, reason, ref_type, ref_id,
  idempotency_key unique, created_at)
  -- reason ∈ allocation | boarding | no_show | returned | refund | converted
credit_ledger(id, user_id, delta_pesewas, reason, ref_type, ref_id,
  idempotency_key unique, created_at)
  -- reason ∈ month_end_conversion | compensation | loyalty | renewal_applied
```

`remainingRides(user) = SUM(delta_rides)` · `balancePesewas(user) = SUM(delta_pesewas)`.

## How allocation works

```
POST /payments/subscribe → Paystack checkout → charge.success webhook:
  activate subscription (idempotent, one-active-per-user index)
  allocate rides       (idempotent, key = alloc:<payment reference>)
  mark payment paid
```

The rides granted per period is a **placeholder constant**
(`PLACEHOLDER_RIDES_PER_PERIOD = 44`) until the `plans` table lands (E1b) — the
same posture as `SUBSCRIPTION_FEES_PESEWAS`.

## Security / integrity notes

- **Derived balances, never a mutable counter** — no lost updates under
  concurrency; full audit trail.
- **Server-authoritative** — allocation amount comes from the server, keyed to a
  verified (signed) Paystack webhook.
- **Idempotent everywhere** — safe to replay activation, allocation, and future
  deductions.

## Where the code lives

```
services/api/src/modules/entitlements/
  entitlement-ledger.repository.ts(.pg)  # ride counts (append-only)
  credit-ledger.repository.ts(.pg)       # Ride Credit pesewas (append-only)
  entitlements.routes.ts                 # GET /me/rides
  entitlements.schema.ts
  credit.service.ts                      # E5 conversion (unused rides → credit)
  credit.routes.ts                       # POST /admin/convert-credits
services/api/src/modules/payments/payments.service.ts  # allocation on webhook
services/api/src/db/migrations/011_entitlement_ledger.sql · 012_credit_ledger.sql
services/api/src/db/migrations/020_entitlement_converted.sql  # 'converted' reason
```

## Related

- [ADR-0014 — Hybrid Subscription Model](../adr/0014-hybrid-subscription-model.md)
- [ADR-0011 — append-only ledger pattern](../adr/0011-token-ledger.md) (reused here)
- `strategy/docs/hybrid-subscription-model.md` (epics E1–E7)
