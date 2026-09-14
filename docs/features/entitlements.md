# Ride entitlements and Ride Credits

**Owner:** Godfred Awuku · **Last verified:** 2026-09-12

**Status:** Period-scoped allocation, boarding/no-show deduction, atomic
period-end conversion, balance reporting, checkout holds and renewal capture
are implemented.

## Ledgers

The Hybrid Subscription Model uses two append-only ledgers:

- Entitlement ledger in ride counts. Allocation is positive; boarding,
  no-show, conversion and refund revocation are negative.
- Ride Credit ledger in pesewas. Period conversion, compensation, loyalty and
  refund restoration are positive; renewal capture is negative.

Balances are sums of immutable entries. Every write has a unique idempotency
key. New entitlement mutations carry `subscription_period_id`, so one period
cannot consume or convert another period's rides.

`credit_holds` is deliberately not a balance ledger. Checkout reserves available
credit there, success captures the exact hold into the ledger, and terminal
failure releases it. A rider lock prevents concurrent checkouts from promising
the same credit twice.

## API

| Endpoint                                 | Role                | Behaviour                                                     |
| ---------------------------------------- | ------------------- | ------------------------------------------------------------- |
| `GET /me/rides`                          | authenticated rider | Current ride and Ride Credit balances plus renewal time       |
| `GET /me/subscription`                   | authenticated rider | Current membership, pinned route and next renewal date        |
| `POST /admin/close-subscription-periods` | admin               | Canonical atomic conversion and close                         |
| `POST /admin/convert-credits`            | admin               | Legacy alias to the canonical close in production wiring      |
| `POST /admin/expire-subscriptions`       | admin               | Legacy alias to the same canonical close in production wiring |

## Lifecycle

1. Fulfilment creates an immutable period and appends
   `alloc:<payment-reference>` within the same transaction.
2. Boarding/no-show appends `-1` against the reservation's funding period.
3. Once the period ended and all its seats are terminal, close computes that
   period's ledger sum and applies its frozen `creditPesewasPerRide`.
4. The same transaction grants `close-credit:<period-id>`, retires rides with
   `close-rides:<period-id>`, closes the period and expires the membership.
5. Rider-initiated renewal reserves that balance, reuses the subscription, and
   creates the next immutable period after Paystack success.

This replaces the former two-job expiry/conversion ordering hazard and the
global rider balance calculation that could convert old rides at a later
period's rate.

## Deferred

- Provider-initiated automatic renewal.
- Standby ride purchases.
- Operator settlement ledger and payout execution.

## Code

- `services/api/src/modules/entitlements/`
- `services/api/src/modules/payments/payment-lifecycle.ts`
- `services/api/src/modules/payments/payment-lifecycle.pg.ts`
- migration `039`
