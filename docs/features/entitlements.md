# Ride entitlements and Ride Credits

**Owner:** Godfred Awuku · **Last verified:** 2026-09-12

**Status:** Allocation, deduction, period-end conversion, balance reporting and
renewal credit netting are live.

## Ledgers

The Hybrid Subscription Model uses two append-only ledgers:

- Entitlement ledger in ride counts. Allocation is positive; boarding,
  no-show and conversion are negative; returns/refunds are positive.
- Credit ledger in pesewas. Period conversion and compensation are positive;
  renewal application is negative.

Balances are sums of immutable entries. Every write has a unique idempotency
key; no mutable balance column is authoritative.

## API

| Endpoint                      | Role                | Behaviour                                                                 |
| ----------------------------- | ------------------- | ------------------------------------------------------------------------- |
| `GET /me/rides`               | authenticated rider | Return `remainingRides`, `ridesPerPeriod`, `creditPesewas` and `renewsAt` |
| `POST /admin/convert-credits` | admin               | Convert unused rides for subscriptions whose period has ended             |

## Lifecycle

1. A verified Paystack webhook activates a subscription and appends the ride
   allocation using `alloc:<payment-reference>`.
2. Boarding or a confirmed no-show appends `-1` ride using
   `board:<reservation-id>`.
3. After a billing period ends, conversion appends Ride Credit using a key based
   on the subscription and period, then retires the remaining rides.
4. The next checkout snapshots available credit and, after payment succeeds,
   appends a `renewal_applied` debit.

Credit conversion writes the credit first and retires rides second. If the job
stops between them, replaying the same period key converges without losing value.

The subscription stores a snapshotted `creditPesewasPerRide`, but the current
`CreditService` does not read it: app wiring still supplies the legacy default
(45 pesewas) to the batch converter. Connecting conversion to each
subscription's snapshot is a known correctness gap before real renewals.

## Not implemented

- Automatic renewal initiation.
- Standby ride purchases.
- Operator settlement ledger and payout execution.
- Per-subscription conversion rate; the stored snapshot is not yet consumed by
  `CreditService`.

## Code

- `services/api/src/modules/entitlements/`
- `services/api/src/modules/payments/payments.service.ts`
- `services/api/src/modules/subscriptions/`
- migrations `011`, `012`, `020`, `027`, `029` and `030`
