# ADR-0017 — Transactional payment lifecycle and provider inbox

**Status:** accepted · **Date:** 2026-09-12

## Context

The first Paystack path performed subscription activation, Ride Credit debit,
ride allocation and payment state updates as separate operations. Retried or
concurrent callbacks could therefore grant value twice, capture a different
credit balance from the one quoted, or leave money and entitlement on opposite
sides of a partial failure. Expiry and credit conversion were separate admin
jobs over a rider-global balance, so their ordering could revalue old rides at a
new period's rate.

Webhooks are delivery notifications, not a transaction coordinator. They can be
duplicated, delayed, arrive out of order or never arrive.

## Decision

Use PostgreSQL as the single accounting boundary for the payment lifecycle:

- serialize money changes with a per-rider transaction advisory lock;
- create one unresolved subscription payment and one Ride Credit hold at
  checkout;
- persist an immutable `subscription_periods` snapshot for every fulfilled
  payment;
- atomically transition `pending → processing → fulfilled` together with
  subscription activation, credit capture and ride allocation;
- attach reservations and every entitlement mutation to the funding period;
- close, convert and expire a due period in one transaction, using its frozen
  rate and only after its reservations are terminal;
- retain provider transaction identity, environment, channel, fees and payment
  timestamps for reconciliation.

Accept a Paystack webhook only after timing-safe HMAC-SHA512 verification over
the raw body and a durable inbox insert. Acknowledge immediately; workers claim
events with `FOR UPDATE SKIP LOCKED`. Recover missing success callbacks by
calling Paystack Verify for stale unresolved references.

Refund and dispute notifications use the same inbox. Only
`refund.processed` proves cash reversed. Partial refunds remain audit facts; a
full cash reversal revokes unconsumed period rides, restores captured Ride
Credit and reverses the current purchased period. A dispute freezes the period
and subscription so another checkout cannot bypass it. An explicit declined
resolution restores service; an accepted dispute waits for the processed refund
notification and resumes service after a processed partial settlement.

Run recovery in this order: inbox, Verify, period close. The operation is
idempotent and exposed as one admin endpoint and one compiled cron entrypoint.

## Consequences

- A provider callback cannot leave a paid row without its value or grant value
  from a failed row.
- Concurrent checkouts cannot promise the same credit or create two active
  periods.
- Renewal advances the existing subscription while retaining immutable period
  history.
- Old rows without trustworthy period linkage remain explicit reconciliation
  work; the migration does not fabricate financial relationships.
- The canonical period-close operation replaces the former independent expiry
  and conversion behavior. Legacy endpoints are aliases in production wiring.
- Scheduling requires one paid Render cron service. It remains disabled until
  recurring spend is approved; the admin endpoint is the manual equivalent.

## Alternatives considered

**Do work directly in the webhook request.** Rejected: slow responses trigger
provider retries and a process crash can lose or partially apply the event.

**Mark paid before fulfilment.** Rejected: a crash would take payment while
granting no subscription value.

**Fulfil before marking paid.** Rejected: retries and failed rows can grant value
more than once.

**Use independent idempotency keys without one transaction.** Rejected:
idempotency prevents duplicate individual writes but does not make a group of
writes atomic or preserve their required order.

Refs: ADR-0014 · ADR-0015 · #243–#249
