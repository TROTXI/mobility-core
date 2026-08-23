# ADR-0015 — Subscription prices are derived from regulated fares, never stored

**Status:** accepted · **Date:** 2026-08-23 · **Refines** ADR-0014 (the Hybrid Subscription Model stands; this decides how its prices are set)

## Context

E1b (#103) has been blocked since June on "the pricing decision", framed as:
pick a price for each of four tiers. On a per-corridor service that framing does
not work, and waiting on it has held up #103, #104 and the plans screen.

Two facts make a stored price table the wrong shape:

**Fares are exogenous.** Trotro fares in Ghana are regulated — government and the
transport unions set them, and they move with fuel, typically as an across-the-
board percentage. We do not choose them and we do not control when they change.

**Every corridor has a different one.** Madina–Circle and Kasoa–Kaneshie are not
the same product at the same cost. A flat national price either loses money on
long corridors or overcharges on short ones.

Together those mean a literal price column is stale the moment the unions
announce, and re-pricing means hand-editing one row per corridor per tier — a
migration every time fuel moves.

## Decision

**Store the fare. Derive the price. Snapshot at purchase.**

### 1. The fare is the input, the price is computed

```
plan price = corridor fare × rides per period × (1 − subscription discount)
```

Fares are held per corridor with an **effective-dated** validity window, so a
fare change is one insert per corridor — or one multiplier across all of them —
and every plan price recomputes. No price is ever typed in.

History is required, not optional: a subscription sold in August has to be
explainable in October, and "what did this rider pay and why" must be answerable
after the fare has moved twice.

### 2. Riders see bands, not forty numbers

Corridors group into three or four **fare bands**. A rider sees "Zone B —
GHS X", which absorbs small differences between corridors and keeps the plans
screen legible. Rebanding is rare; band boundaries are a product decision made
once, not per corridor.

### 3. Price, ride count and credit rate are snapshotted onto the subscription

At activation the subscription records the price paid, the rides granted, and
the pesewa value of a Ride Credit **as they were at that moment**.

A fare rise must not change what an active subscriber owes, nor retroactively
revalue credit they already hold. Without the snapshot both would move under
them, which is unfair, hard to explain, and legally uncomfortable.

New prices therefore apply at **renewal**, which makes the billing periods in
#162 load-bearing: without a period boundary there is no moment at which to
reprice.

## Consequences

**The entitlement model already absorbs the shock.** ADR-0014 sells _rides_, not
cedis of travel. A rider holding 23 rides holds 23 rides whatever happens to
fares on Tuesday. A mid-period rise does not force a re-price; we absorb the
delta until renewal.

That exposure is bounded and computable, which is the point:

```
exposure = (new fare − old fare) × unused rides × active subscribers
```

A number that can be put in front of the CEO and hedged, rather than a risk
nobody can size. It is also a marketing position: competitors charging per trip
pass a fare rise straight to the passenger on the day it lands; we hold to
renewal.

**Cost:** more schema than a price column — fares, effective dates, bands, and
three snapshot fields on the subscription. Worth it. The alternative is a
migration every time fuel moves.

**What this does not decide.** The architecture is settled; three product
numbers remain, and they are now the only blockers:

1. **The discount** versus paying per trip. One percentage.
2. **The entitlement formula** — working days × 2, holiday handling, one-way
   commuters. One formula.
3. **Band boundaries.** Three or four numbers.

None of them move when the government moves fares. That is the unblock: #103 was
waiting on per-corridor prices that can never be stable, when it was only ever
waiting on a discount.

The survey instrument (Q11 spend, Q17 willingness-to-pay) should be read as
measuring **what discount converts a per-trip commuter into a subscriber**, not
as finding a price.

## Alternatives considered

**Flat national price.** Simplest, and cross-subsidises: riders on short
corridors fund long ones. Rejected — it only holds while the corridor mix is
stable, and the mix is exactly what changes as ops opens routes on demand.

**Per-corridor stored prices.** Accurate and unmaintainable. Forty rows to edit
on every fare announcement, with no history and nothing stopping two corridors
drifting out of sync.

**Track fares automatically.** Attractive, but there is no machine-readable feed
of Ghanaian transport fares. Ops enters them; the effective dating is what makes
that safe.

Refs: ADR-0014 · #103 · #104 · #162 · `strategy/docs/hybrid-subscription-model.md`
