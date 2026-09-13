# Payments, pricing and subscription periods

**Owner:** Godfred Awuku · **Last verified:** 2026-09-12

**Status:** Fare-derived checkout, credit netting, Paystack activation and
period expiry are live. The filename is retained for stable links; there is no
prepaid wallet or top-up API in the current product.

## Current model

A rider buys a ride entitlement for one corridor and billing period. The
checkout price is derived rather than typed into a plan table:

```text
price = corridor fare × rides per period × price multiplier
Paystack charge = price − applied Ride Credit
```

Money is integer pesewas. Multipliers and the operator take rate are integer
basis points (`10000 = 1.0`). The current plan keys are `monthly` and `annual`;
the strategy document's standard/premium/corporate/student tier taxonomy has
not been implemented.

Fares are effective-dated per route. Plan levers are ops-editable:
`ridesPerPeriod`, `priceMultiplierBp`, `takeRateBp` and
`creditPesewasPerRide`. Checkout snapshots the fare, price, rides, credit rate,
stops and applied credit so later configuration changes cannot rewrite what was
sold.

## Rider and webhook API

| Endpoint                   | Auth           | Behaviour                                                                                              |
| -------------------------- | -------------- | ------------------------------------------------------------------------------------------------------ |
| `POST /payments/subscribe` | bearer         | Validate route/stops, derive price, net credit, create pending payment and initialize Paystack         |
| `POST /webhooks/paystack`  | HMAC signature | Validate settlement, activate subscription, allocate rides, debit applied credit and mark payment paid |

`POST /payments/subscribe` accepts a plan, `routeId` and optional pickup/drop-off
stop IDs. A corridor without a fare in force returns `409 not_priced`; stops not
on the corridor return `400`.

The webhook verifies HMAC-SHA512 over the raw request body. A
`charge.success` event grants value only when its reference, status, amount and
currency agree with the stored payment. Each effect is independently
idempotent, so Paystack retries converge after partial failure.

## Admin pricing and period API

| Endpoint                           | Purpose                                                  |
| ---------------------------------- | -------------------------------------------------------- |
| `GET /admin/routes/:id/fares`      | Effective-dated fare history                             |
| `PUT /admin/routes/:id/fare`       | Close the previous fare and create the new one           |
| `GET /admin/plan-pricing`          | Current levers for monthly and annual plans              |
| `PATCH /admin/plan-pricing/:plan`  | Update multiplier, take rate, ride count or credit value |
| `POST /admin/expire-subscriptions` | Mark active subscriptions whose period ended as expired  |

The expiry sweep does not auto-renew. Recurring charging needs a stored payment
mandate, which the system does not yet have.

## Credit netting

At checkout, available Ride Credit can reduce the price, but the Paystack
charge never drops below `MIN_CHARGE_PESEWAS` (currently 100). Unused credit
remains in the ledger. Applied credit is debited only after a valid successful
payment webhook.

## Deferred

- Automatic renewal and stored mandates.
- Nightly Paystack reconciliation, automated refunds and circuit breaking.
- Standby single-journey checkout.
- Fare bands from ADR-0015; current pricing is per corridor.
- Credit conversion still uses the app-wired fallback rate instead of the
  subscription's stored rate snapshot.
- Final commercial values. The database is ops-editable but seeded values remain
  placeholders until approved.

## Code and data

- `services/api/src/modules/payments/`
- `services/api/src/modules/subscriptions/`
- migrations `027` through `031`
- [ADR-0014](../adr/0014-hybrid-subscription-model.md) and
  [ADR-0015](../adr/0015-fare-derived-pricing.md)
