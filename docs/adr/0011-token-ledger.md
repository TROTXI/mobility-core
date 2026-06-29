# ADR-0011 — Append-only token ledger (the GHS wallet)

**Status:** accepted · **Date:** 2026-06-27

## Context

Trotxi is a prepaid product: a subscription payment grants **GHS-denominated
tokens** (1 token = 1 GHS) that a rider spends on trotro fares. This is money, so
correctness and auditability are non-negotiable. A mutable `token_balance`
column is the classic way to lose money — concurrent boardings race, a crash
mid-update corrupts it, and there is no audit trail. Full rationale lives in the
strategy repo (`system-design §4.1`, `security §7`); this ADR records the
decision in the repo where the code lives (#21).

## Decision

Model the wallet as an **append-only `token_ledger`**, not a balance column:

- Every grant (+) and spend (−) is **one immutable row**; **balance = `SUM(delta)`**
  (derived; may be cached later but is never the source of truth).
- **Exactly-once writes** via a unique `idempotency_key` — a retried grant/debit
  is a no-op, never a double-write.
- **Fail-safe money** (lands with the consumers, not this PR):
  - **Debits** (boarding, #20) run a `balance ≥ 0` guard **inside one
    serializable transaction**.
  - **Payments** (#21b) are a state machine (`pending → paid|failed`), **never
    mutated once `paid`**, fed by **signature-verified, idempotent webhooks**;
    nightly reconciliation against the aggregator.
- Full money history is reconstructable per user (audit + Act 843).

**Scope:** this PR (#21a) ships the **ledger + derived balance** (`GET
/me/balance`). **Grants** come from payments (#21b); **debits** from boarding
(#20). The earlier "hold-half / charge-at-scan split" is **dropped** — we charge
once, at commit (system-design §4.3).

## Consequences

- Reads compute `SUM(delta)`; introduce a cached balance only as an optimization,
  never as the truth.
- The `idempotency_key` unique constraint is the backbone of no-double-spend /
  no-double-grant — every money mutation must supply a meaningful key.
- The in-memory repo mirrors the shape for tests/dev but the **database enforces**
  the uniqueness + checks (ADR-0009); money paths are validated against real
  Postgres (e2e), not the in-memory stand-in.

## Update — 2026-06-28

Correction to the model: **a subscription is a platform membership fee, not a
token grant** (the original `subscription_grant` reason, copied from
system-design §4.1, conflated the two). There are two separate money flows:

- **subscription** payment → activates platform membership; grants **no** tokens.
- **topup** payment → grants ride tokens (GHS) to the wallet.

Boarding requires **both** an active subscription and sufficient balance
(system-design §4.3) — two gates, not one. The ledger grant reason is now
`topup` (migration `008`); `subscription_grant` is removed. The strategy
`system-design §4.1/§4.2` should be updated to match.

## Update — 2026-06-28 (units + on hold)

- **Units:** amounts are stored and handled in **pesewas** (minor units;
  1 GHS = 100 pesewas), matching Paystack — integers only, no sub-cedi precision
  loss (#68). "1 token = 1 GHS" still holds at the GHS level; the client formats
  GHS for display.
- **On hold:** further money work is **paused** pending the product team's
  **commission model** (how Trotxi charges its cut). The current build is
  rider-side only (subscription + token wallet); commissions, driver payouts, and
  the boarding debit (#20) are blocked on that decision because it shapes the
  ledger and payout design. Full status:
  `docs/features/payments-and-wallet.md` → "Status & roadmap (ON HOLD)".
