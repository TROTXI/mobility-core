# ADR-0015 — Subscription prices are derived from regulated fares, never stored

**Status:** accepted · **Date:** 2026-08-23 · **Amended:** 2026-08-24 · **Refines** ADR-0014 (the Hybrid Subscription Model stands; this decides how its prices are set)

> **Amendment, 2026-08-24.** As first written this said `(1 − subscription
discount)`, which assumed we compete on price. We do not: on these corridors
> there is frequently **no vehicle available at all**, so what we sell is
> certainty, and certainty in a supply-constrained market commands parity or a
> premium rather than a discount. The term is now a **price multiplier** that
> can sit below, at, or above 1. The architecture is unchanged; the assumption
> baked into the old name is removed before anything is built against it.

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
plan price = corridor fare × rides per period × price multiplier
```

The multiplier is deliberately not called a discount:

| Value | Meaning                                         |
| ----- | ----------------------------------------------- |
| `< 1` | discount — we compete on price                  |
| `= 1` | parity — same spend, guaranteed seat            |
| `> 1` | premium — certainty is worth more than the fare |

A column named `discount_percent` would quietly insist the answer is below 1,
and that framing would outlive whoever chose it.

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

The **operator take rate is deliberately not snapshotted onto the subscription.**
Payout is earned per ride delivered, so it uses the rate in force at delivery,
not at the rider's purchase. Freezing it on the subscription would mean a rate
renegotiated in March still paying January's terms on rides run in April, which
is not what either party agreed.

### 4. What we are actually selling

Worth stating plainly, because it decides the multiplier and was missing from
the first draft.

On these corridors the binding constraint is **supply, not price**. There is
frequently no vehicle available at all — a commuter's alternative is not a
cheaper trotro, it is waiting, and possibly not getting to work on time.

So the comparison a rider makes is not

> GHS 264 with a trotro versus GHS 238 with Trotxi

but

> GHS 264 **and uncertainty** versus a guaranteed seat on a scheduled departure

Every business selling guaranteed capacity into constrained supply — season
tickets, reserved parking, standing hotel rates — prices at or above spot, not
below. Discounting here means paying people to accept the thing they already
want most.

The revenue per ride is also not the prize. Prepayment gives us **a month of
fares as working capital** and, more valuably, **demand certainty**: we know how
many seats to put on which corridor tomorrow. That is what makes the model
asset-light, and we get it from the subscription existing at all, not from
pricing it below spot.

### 5. Revenue is a share of the fare, carved out — not a fee added on

The rider pays the fare-derived price and nothing more. Out of that, the
operator is paid their share and Trotxi keeps the rest. Uber's structure.

```
rider price     = corridor fare × rides per period × price multiplier
operator payout = corridor fare × rides delivered × (1 − take rate)
trotxi revenue  = rider price − operator payout
```

The alternative — a service fee added on top — was rejected. It makes us
visibly dearer than spot at exactly the moment we are pitching "the same fare
you already pay", and it invites a comparison we do not need to invite. Carved
out, the rider sees one number and it matches what they already spend.

**These are three independent levers and the schema must keep them apart.**
Collapse them into one and we cannot answer "are we profitable on
Kasoa–Kaneshie" separately from "is our price competitive on Kasoa–Kaneshie".
On a per-corridor service those answers will diverge: a long corridor can price
perfectly well and still earn nothing.

**Operator payout is on rides DELIVERED, not rides sold.** The rider buys 44
rides and may travel 31; the operator is paid for the seats actually run. That
asymmetry is where the model's margin lives, and it is also why the entitlement
ledger already distinguishes `boarding` from `no_show` — a no-show costs the
rider a ride and costs us nothing, because no vehicle carried them.

### 6. What this does to the fare-rise exposure

The exposure calculation below assumed only our revenue is fare-linked. With a
carved-out share, a fare rise moves **both sides**: we owe the operator more per
delivered ride, and we cannot re-price the rider until renewal.

```
exposure = (new fare − old fare) × (1 − take rate) × undelivered rides × active subscribers
```

Smaller than the naive figure by exactly the take rate, and computable per
corridor once the split is modelled. This is the number that says whether a
given multiplier is safe, rather than guessed.

## Consequences

**The entitlement model already absorbs the shock.** ADR-0014 sells _rides_, not
cedis of travel. A rider holding 23 rides holds 23 rides whatever happens to
fares on Tuesday. A mid-period rise does not force a re-price; we absorb the
delta until renewal.

That exposure is bounded and computable, which is the point:

```
exposure = (new fare − old fare) × (1 − take rate) × unused rides × active subscribers
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

1. **The price multiplier.** One number. Default 1.0 (parity).
2. **The operator take rate.** One percentage, possibly per operator agreement
   rather than global. This is the one that decides whether we have a business:
   the multiplier sets the top line, the take rate sets whether anything is left
   after the vehicle has been paid.
3. **The entitlement formula** — working days × 2, holiday handling, one-way
   commuters. One formula.
4. **Band boundaries.** Three or four numbers.

None of them move when the government moves fares. That is the unblock: #103 was
waiting on per-corridor prices that can never be stable, when it was only ever
waiting on one multiplier.

**Default to 1.0 — parity.** The pitch is "the same fare you already pay, except
your seat is waiting for you", which needs no justification, protects margin
entirely, and is far easier to sell than explaining a percentage. Ship that; the
pilot will say more about the right number than any amount of reasoning will.

A launch offer for the first cohort is a **separate, expiring promotion**, not
this multiplier. Keep them apart: one is pricing architecture, the other is
marketing with a sunset date. Conflating them is how a temporary incentive
becomes a permanent margin leak nobody can explain the origin of.

None of these three numbers should live in code. They belong in ops-editable
configuration, so setting them is data entry rather than a deploy — see #103.

The survey instrument (Q11 spend, Q17 willingness-to-pay) should be read as
measuring **what makes a commuter prepay a month**, not as finding a price.

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
