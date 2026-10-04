# ADR-0015 - Subscription fares and immutable Ops offers

## Current decision: Ops-priced offers (2026-10-03)

This amendment supersedes the corridor-wide automatic purchase model below for
new subscriptions and renewals. Historical paid subscriptions keep their terms.

Operations publishes an effective-dated fare for an ordered pickup/drop-off
pair on a published route version. B to C and C to D can have different prices.
B to D needs its own explicit fare, not an automatic sum. The reverse journey
is priced separately. Repeated visits to the same physical stop use distinct
stop occurrences.

A phone-verified commuter requests a route, outward/return journeys and travel
weekdays. Operations sends an offer containing:

- Fixed coverage dates, with the end date excluded, in Africa/Accra.
- Each journey, schedule, applicable weekdays and ride count. Counts use actual
  calendar dates intersected with the schedule, not a fixed 44-ride allowance.
- The applicable journey fare and an agreed total package price in GHS.
- A separately chosen unused-ride credit value for each direction, disclosed
  before acceptance. Each value is at most that journey's fare, and the total
  possible credit cannot exceed the package price.
- A payment deadline no later than the coverage start.

Acceptance freezes these terms in the purchase before opening Paystack. Later
fare changes cannot reprice sent offers, purchases or unused-ride credits.
The public direct-purchase endpoint refuses new checkouts without an offer.
The rider reviews terms, then the final cash due after any opted-in account
credit. Only verified provider settlement grants coverage and rides.

Outbound and return balances are separate. Reservations must use the offered
journey and weekdays. At period close, each direction's unconsumed rides convert
at its frozen credit value. Existing booking cutoffs, capacity checks and
no-show charging still apply. An offer does not reserve vehicle capacity.

Renewals require a new request and offer. One upcoming renewal can be paid in
advance, starting exactly when current coverage ends without a gap. Current and
upcoming periods remain separate, non-overlapping accounting records. Current
ride balances and booking access exclude upcoming periods until their start.
The date boundary selects coverage without depending on the old period's
settlement job completing. Unused-ride credits are only available after actual
period closure, never projected into an early renewal payment.

Resolve pauses before buying a renewal. Once a renewal checkout or paid renewal
exists, pauses and commute changes on its preceding period are blocked so they
cannot extend coverage into the frozen start. Refunding an upcoming period
reverses only that period. One-way packages, holidays and mid-period offer
replacement are not implemented. Calendar-date offers can meet an existing
midnight boundary exactly; legacy periods ending mid-day need a later date.

Payment recorded after the deadline does not activate expired terms. The
purchase is failed, reserved credit is released, and collection evidence goes
to the existing late-payment review/refund workflow. Do not ask the rider to
pay again until Operations has checked the collected payment.

On the rider's next offer refresh, request or checkout, unpaid expired offers
release their credit hold and open application slot. This is local service
expiry, not proof that Paystack collected nothing. The pending provider attempt
stays reconcilable. A collection discovered after local expiry is retained for
Ops review/refund, including a delayed confirmation of an earlier payment.

Before enabling the updated apps, apply migrations 041 and 042 and publish
stop-pair fares. Legacy unpriced offers with no purchase must be withdrawn and
requested again with travel days. Already-created historical purchases retain
their recovery path. Deploy the API contract and both regenerated clients
together; old direct-checkout clients receive `offer_required`.

### Staging acceptance loop

1. In Routes & stops, publish distinct B-to-C and C-to-D fares, then separate
   return fares. Confirm B-to-D is unavailable until explicitly configured.
2. Sign in as a phone-verified commuter. Request Monday/Wednesday/Friday travel.
   Repeat with an unverified Google account and confirm verification is required.
3. In the standby queue, send an offer with dates, package price and two
   different unused-ride credit values. Confirm the actual dated ride counts.
4. Review it in the commuter app. Check all terms before continuing to Paystack
   TEST. Retry the same acceptance and confirm one checkout, not another charge.
5. Complete TEST payment and process its verified provider event. Confirm the
   fixed coverage period, correct directional allowances and completed request.
6. Change a published fare. Confirm the accepted offer and purchase do not change.
7. Reserve/board only covered dates and journeys. Confirm another journey,
   weekday or exhausted directional allowance is refused.
8. Close the period in a disposable test database. Confirm each direction's
   unused rides use the disclosed credit value, with no duplicate close credit.
9. Exercise late payment and historical checkout recovery. Verify no expired
   service is granted, held credit is released, and Ops can review the collection.

## Historical decision

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

1. **The price multiplier.** One number.
2. **The entitlement formula** — working days × 2, holiday handling, one-way
   commuters. One formula.
3. **Band boundaries.** Three or four numbers.

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

## Current implementation — 2026-09-12

Migration 027 and the pricing module implement effective-dated corridor fares,
ops-editable monthly/annual plan levers and checkout/subscription snapshots.
Credit netting landed in migration 030, with a minimum 100-pesewa Paystack
charge. Fare bands are not implemented: current checkout derives directly from
the selected `routeId`. Seeded values remain placeholders until operations
approves the commercial configuration.

Migration 039 makes the snapshot period-specific rather than relying on the
mutable subscription pointer. Checkout reserves the exact available Ride Credit
under a rider lock; fulfilment captures that hold. Period close reads the
immutable period's `credit_pesewas_per_ride`, so a later price or credit-rate
change cannot revalue rides sold earlier.
