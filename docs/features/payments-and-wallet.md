# Payments, pricing and subscription periods

**Owner:** Godfred Awuku · **Last verified:** 2026-09-12

**Status:** Fare-derived checkout, transactional Ride Credit holds, durable
Paystack processing, renewal, reconciliation, refund/dispute accounting and
atomic period close are implemented. Staging uses a Paystack test key. The
filename is retained for stable links; there is no prepaid wallet or top-up API.

## Current model

A rider buys one route-bound entitlement period:

```text
price = corridor fare × rides per period × price multiplier
Paystack charge = price − reserved Ride Credit
```

Money is integer pesewas and rates are integer basis points. Fares are
effective-dated per route. Checkout freezes the fare, price, ride count,
conversion rate, route/stops and applied credit; later configuration changes do
not rewrite a sold period.

The current plan keys are `monthly` and `annual`. Automatic recurring charges
are not implemented because Trotxi does not hold a reusable payment mandate;
renewal is a rider-initiated checkout that advances the existing subscription.

## State and transaction boundaries

```text
checkout: pending + credit hold
provider success: pending → processing → fulfilled
provider terminal Verify result: pending|processing → failed + hold released
full processed refund: fulfilled|disputed → refunded + period reversed
dispute: fulfilled → disputed; current period/subscription frozen
```

One PostgreSQL transaction owns subscription activation/reactivation, immutable
period creation, credit capture, ride allocation, provider metadata and final
fulfilment. Per-rider advisory locks serialize checkout and lifecycle changes.
A second unresolved checkout is rejected and an active or disputed membership
cannot be bypassed with another purchase.

## Rider, webhook and recovery API

| Endpoint                                | Auth           | Behaviour                                                                      |
| --------------------------------------- | -------------- | ------------------------------------------------------------------------------ |
| `POST /payments/subscribe`              | bearer         | Validate/price, reserve credit, create pending payment and initialize Paystack |
| `POST /webhooks/paystack`               | HMAC signature | Verify raw body, durably enqueue, acknowledge, then process asynchronously     |
| `POST /admin/payments/process-webhooks` | admin          | Drain retryable/stale inbox work                                               |
| `POST /admin/payments/reconcile`        | admin          | Verify stale pending/processing references directly with Paystack              |
| `POST /admin/payments/maintenance`      | admin          | Inbox → Verify → safe period close, in dependency order                        |

`charge.success` grants value only when provider reference, status, amount,
currency, environment, transaction id and paid time pass the strict adapter
contract. The public webhook has no shared-IP rate-limit bucket: Paystack bursts
are absorbed by the durable, SHA-256-deduplicated inbox and competing workers
claim rows with `FOR UPDATE SKIP LOCKED`.

Paystack references use only provider-supported characters. HTTP calls have
timeouts and initialization verifies Paystack echoed the reference. Verify is
the recovery path when a success webhook does not arrive.

The live adapter contract has an opt-in sandbox test that rejects live keys:

```bash
RUN_PAYSTACK_SANDBOX=1 PAYSTACK_SECRET_KEY=sk_test_... \
  pnpm --filter @trotxi/api exec vitest run tests/paystack.sandbox.test.ts
```

## Refunds and disputes

Refund status notifications are recorded, but rider value changes only after
`refund.processed`. Partial refunds update the audit total without silently
cancelling the period. Once processed refunds equal the payment's cash amount,
the transaction atomically:

- revokes only rides still unconsumed in that purchased period;
- restores Ride Credit captured for the reversed purchase;
- marks the period `reversed`, the payment `refunded`, and the current
  subscription `expired`.

`charge.dispute.create` and reminders freeze the exact purchased period and
suspend the current membership. A `declined` resolution restores service. A
merchant-accepted resolution stays frozen until Paystack's authoritative
processed-refund event covers the accepted amount, then service resumes for a
partial refund or reverses for a full refund. Resolution alone is not treated as
proof that cash moved.

## Period close

`POST /admin/close-subscription-periods` is the canonical operation. Both legacy
admin paths delegate to it. For each immutable period it converts only that
period's remaining rides at that period's frozen rate, retires those rides, then
closes the period and expires the membership in one transaction.

A period with `pending` or `reserved` seats is reported as `blocked`; closing it
before boarding/no-show settlement would let a later ride debit occur after its
value had already become credit.

The compiled `payments-maintenance-cron` runs inbox recovery, Verify and close
hourly. Its Render declaration is ready but commented because Render applies a
minimum monthly charge per cron service. Until approved, operators call the
maintenance endpoint manually.

## Deferred

- Automatic provider-initiated renewal and stored mandates.
- Automated evidence upload or merchant decisions for disputes.
- Standby single-journey checkout and operator payouts.
- Fare bands and final commercial values; current values remain ops-editable
  placeholders until approved.

## Code and data

- `services/api/src/modules/payments/`
- `services/api/src/modules/subscriptions/`
- `services/api/src/cron/payments-maintenance-cron.ts`
- `services/api/scripts/payments-audit.sql` (read-only rollout/reconciliation audit)
- migrations `027`–`031` and `039`
- [ADR-0014](../adr/0014-hybrid-subscription-model.md) and
  [ADR-0015](../adr/0015-fare-derived-pricing.md)
