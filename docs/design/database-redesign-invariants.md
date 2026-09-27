# Database redesign: behavioral invariants

Status: draft for review, before target-schema design.

Evidence baseline: merged `main` at `43cdae0` (PR #292), inspected on
2026-09-14. This document records existing assertions; it does not claim a new
test run, a staging audit, or confirmation that any database is empty.

## Purpose and scope

Preserve business behavior while allowing tables, columns, repositories and API
representations to change. The first completed inventory below covers all 16
tests in `services/api/tests/payment-lifecycle.pg.test.ts`. It is the payment
acceptance baseline. The companion [non-payment inventory](stage-1-invariants.md)
now records transport, identity, boarding and commute scenario groups and gaps;
neither inventory claims exhaustive runtime proof.

An existing assertion is evidence of current behavior, not automatic approval
of a permanent product rule. Any intentional behavior change must identify the
invariant it changes, explain why, and receive review separately from the
storage refactor.

Rules use domain terms. Test names and current SQL details are evidence links,
not requirements that the redesigned database retain the same representation.

This is a clean prelaunch replacement, not a compatibility program. Preserve
the old implementation in Git and an isolated test baseline only; the invariant
catalog carries its relevant guarantees into the new schema and API.

## Domain vocabulary

- **Membership:** the rider's ongoing relationship with the service.
- **Purchased period:** one bounded purchase of service, including agreed price,
  ride allowance and conversion terms. Purchase terms must remain explainable;
  lifecycle state and a documented pause extension may change.
- **Funding relationship:** which purchase funds a reservation or ride movement.
- **Ride Credit:** non-cash value available for a later purchase.
- **Held credit:** credit reserved for an unresolved checkout, unavailable to a
  competing checkout but not yet spent.
- **Fulfilment:** recording a successful purchase and granting its service value.
- **Consumption:** ride use or a chargeable no-show, adjusted for returned rides.
  Converting unused rides into credit is a different operation.
- **Reversal review:** an estimate of value requiring an ops decision. It is not
  authorization to automatically charge or collect a debt.

Money examples below use integer pesewas. The fixture uses a 26,400-pesewa price,
44 rides and 45 pesewas per converted ride. These are test inputs, not approved
production pricing or an entitlement formula.

## Payment acceptance baseline

### PAY-01 — Monetary units are explicit

Cash, full purchase price, applied credit, fare, conversion rate, fees and
refunded cash must have explicit, consistent monetary units.

Current evidence checks that every selected payment money field has a database
comment containing `pesewas`. It does not prove arithmetic correctness, rounding
policy or currency conversion. Preserve the unit guarantee; the exact column
names and catalog-query implementation may change.

### PAY-02 — Concurrent checkouts cannot promise the same credit

Given a rider with 1,000 pesewas of credit and two simultaneous subscription
checkout attempts, the current policy accepts one and rejects one. Exactly one
checkout reserves the 1,000 pesewas.

Coverage limit: the pending-checkout restriction participates in this result.
This test does not independently prove reservation of credit if that restriction
is relaxed. A different checkout policy needs its own contention scenario.

### PAY-03 — Duplicate successful delivery fulfils once

Given one checkout, two identical authenticated success deliveries and two
concurrent inbox workers, the result is one fulfilled purchase, one purchased
period, one ride allocation, and an active membership with a current period.

Coverage limit: this exercises concurrent processing and identical-payload
deduplication. It does not simulate process termination between transaction
steps or semantically duplicate events with different payload bytes.

### PAY-04 — Renewal and scheduled close agree on conversion

Given an ended purchase with 44 unused rides valued at 45 pesewas each, a close
worker racing renewal checkout must close it and convert its unused rides once.
The renewal must apply 1,980 pesewas of credit and produce one pending purchase.

Neither operation may miss or repeat the conversion because the other won the
race. Which worker reports the successful close is incidental.

### PAY-05 — A renewed purchase is distinct and becomes current

After a normal renewal, both purchases remain attributable to distinct periods:
one ended and one current. Membership is active and its effective current
purchase is the new open period. Each purchase grants rides once; the old period
converts once. Replaying renewal fulfilment reports it was already fulfilled.

The fixture applies 1,980 pesewas from the old purchase. Preserve history,
distinctness and the correct current purchase, without requiring a particular
pointer column or number of membership-storage rows.

### PAY-06 — Concurrent close workers convert once

Two workers closing the same ended purchase must produce one conversion of 44
rides into 1,980 pesewas and one closed outcome. Duplicate processing must not
mint additional credit or remove rides twice.

### PAY-07 — Close is eligible at the end boundary; zero rides yield zero credit

A period remains open one millisecond before its end and can close at exactly
its end. When all 44 rides have been consumed, closure grants no credit and
records zero rides converted.

Current storage emits no conversion ledger entries for this zero-value case.
The invariant is zero financial effect and an auditable closed outcome, not a
requirement to retain that exact choice of zero-entry representation.

### PAY-08 — One malformed period cannot partially close or stop the batch

Given an earlier malformed period with no conversion rate and a later valid
period, a batch reports two considered, one failed and one closed. The malformed
period and its membership remain unchanged; it receives no conversion entries
or completed-conversion totals. The valid period closes and converts normally.

The failure identifies the affected period and a bounded reason
(`missing_conversion_rate` in this fixture). Raw internal errors must not become
public response content. The SQL assertions prove rollback for this scenario;
they do not cover every possible failure point.

### PAY-09 — Unsettled funded reservations block close and renewal

An ended purchase with an unsettled funded reservation must remain open, with
membership state unchanged and no credit conversion. Renewal checkout rejects
with a blocked-close outcome.

The Postgres fixture covers a `reserved` reservation. Other unsettled states and
the race between boarding settlement and closure need explicit coverage.

### PAY-10 — Missing callbacks do not make successful payments unrecoverable

Given a stale unresolved checkout whose provider verification reports success,
reconciliation fulfils it and creates one period and one ride allocation even
though no success callback arrived.

The test uses real Postgres and a fake Paystack adapter. It proves application
recovery, not external Paystack availability or sandbox delivery. Its historic
cutoff isolates a global reconciliation query; that date is test plumbing, not
a business rule.

### PAY-11 — A full cash refund reverses value once

Given a purchase funded partly by 1,000 pesewas of captured credit, two concurrent
deliveries of the same processed full cash refund must produce one refund
record, zero remaining rides, restored credit of 1,000 pesewas, a reversed
purchase and ended membership in this single-period scenario.

This scenario has no consumed rides. It does not prove behavior when an older
purchase is refunded after the rider has acquired a newer current period.

### PAY-12 — A declined dispute removes its payment freeze

Creating a dispute freezes the purchased period and suspends membership in the
fixture. Resolving it as `declined` restores the fulfilled purchase, open period
and active membership. A repeated resolution leaves one recorded dispute.

This fixture has one dispute and no independent pause. It must not be read as
permission to override another suspension, voluntary pause, expiry or reversal.

### PAY-13 — An accepted partial dispute waits for its processed refund

Given a 26,400-pesewa purchase with 44 rides and a merchant-accepted dispute for
1,000 pesewas, acceptance alone leaves access frozen, zero cash refunded and all
44 rides unchanged. Processing the corresponding 1,000-pesewa partial refund
clears the payment freeze and retains the 44 rides.

Coverage limit: this tests one accepted dispute and an exactly covering partial
refund. It does not prove behavior with insufficient refunds, multiple disputes,
reverse arrival order or a full cash refund. A full refund must instead satisfy
the reversal rules.

### PAY-14 — Consumed value is exposed for review without negative rides

Given a 26,400-pesewa purchase of 44 rides, ten consumed rides and a full cash
refund, the remaining rides become zero. One review reports ten consumed rides,
zero unrecovered conversion credit and an estimated 6,000 pesewas requiring
review. The operations review's monetary amount is that estimate.

This pins a divisible-price example. It does not establish rounding for other
prices or authorize collection from the rider.

### PAY-15 — Month-end conversion is not ride consumption

Given zero rides consumed, closing a period converts its 44 unused rides into
1,980 pesewas. A later full cash refund claws back that available conversion
credit, leaves zero rides and zero credit, reverses the period, and creates no
consumed-value review.

Coverage limit: this Postgres test has all conversion credit available. Spent or
held conversion credit is a separate case, not proven by this assertion.

### PAY-16 — Older refund and dispute events do not regress known state

A `pending` refund event following a known `failed` refund must not replace the
failed state. A `created` dispute event following a known `reminded` dispute must
not replace the reminded state. Ops continues to see the later known states.

These two event pairs are the Postgres evidence. They do not prove every status
transition or contradictory resolutions at the same processing rank.

## Exact traceability to the baseline

All names below are from
[`payment-lifecycle.pg.test.ts` at 43cdae0](https://github.com/TROTXI/mobility-core/blob/43cdae0/services/api/tests/payment-lifecycle.pg.test.ts).
Line numbers refer to that fixed revision.

| Invariant | Line | Existing test name                                                                 |
| --------- | ---- | ---------------------------------------------------------------------------------- |
| PAY-01    | 193  | documents every payment money snapshot as pesewas                                  |
| PAY-02    | 214  | lets only one concurrent checkout reserve a rider credit balance                   |
| PAY-03    | 243  | fulfils one reference once under concurrent webhook workers                        |
| PAY-04    | 295  | closes an ended period exactly once while renewal checkout races it                |
| PAY-05    | 340  | fulfils a normal renewal once and advances to a second immutable period            |
| PAY-06    | 412  | closes one period once when two close workers race                                 |
| PAY-07    | 452  | closes exactly at period end and mints no credit when no rides remain              |
| PAY-08    | 510  | rolls back a malformed period and continues closing later valid periods            |
| PAY-09    | 591  | keeps an ended period open while a funded reservation is unsettled                 |
| PAY-10    | 637  | reconciles a successful provider charge when its webhook never arrived             |
| PAY-11    | 684  | applies a full refund once and restores captured Ride Credit                       |
| PAY-12    | 747  | freezes a disputed period and restores it after a declined resolution              |
| PAY-13    | 814  | restores a merchant-accepted dispute after its partial refund is processed         |
| PAY-14    | 890  | records consumed-value debt and keeps entitlement non-negative on full refund      |
| PAY-15    | 957  | excludes month-end conversion from consumption and claws its credit back on refund |
| PAY-16    | 999  | keeps refund and dispute state monotonic under out-of-order delivery               |

## Supporting evidence and gaps to carry into the redesign

Do not turn an untested requirement into a claim of existing Postgres proof.

- **Spent conversion credit:** the service test `reports spent month-end credit
as debt without inventing consumed rides` uses the in-memory implementation.
  It expects zero consumed rides and 1,980 pesewas of unrecovered credit when all
  converted credit was spent. Port this case to Postgres, including credit
  already reserved by another checkout. Define available credit consistently.
- **Settlement validation:** service tests cover mismatched amounts, currency,
  missing fields, unsuccessful provider verdicts and already-failed payments.
  Preserve these scenarios in the acceptance inventory and real-adapter tests.
- **Independent access blockers:** no dispute resolution should erase an
  unrelated commute pause. Add a combined pause-and-dispute scenario; passing
  separate suites does not prove their interaction.
- **Ownership:** a rider's purchase must not fund another rider's reservation;
  a membership's current purchase must belong to it. These are required target
  guarantees identified by the schema audit, not proven by the 16 tests above.
- **Price changes:** preserve agreed purchase and conversion terms when current
  fares change. The 45-pesewa fixtures alone do not prove isolation between two
  periods with different rates.
- **Recovery:** add controlled failure and retry scenarios around durable inbox
  acceptance, fulfilment and acknowledgement. Concurrency tests are not
  crash-recovery tests.
- **History:** refund or dispute delivery for an older period must not
  accidentally end, reactivate or consume the newer period's value.
- **Test isolation:** existing PG fixtures use direct SQL, synthetic `test`
  reference types and shared global sweeps. Replace fixture plumbing as needed
  without making those shortcuts requirements of the new schema.

Supporting source:
[`payments.service.test.ts` at 43cdae0](https://github.com/TROTXI/mobility-core/blob/43cdae0/services/api/tests/payments.service.test.ts).

## How these rules survive a schema change

1. Review and freeze this behavioral baseline before accepting target tables.
   Record approved rule changes explicitly; do not infer policy from a test name.
2. Keep the old commit and its tests available. Build a small scenario harness
   whose actions and observations use domain terms: purchase, fulfil, consume,
   close, refund, dispute, inspect balances and service availability.
   Build and validate that harness in stage 2, before domain-schema changes.
   The implementation contract is in the
   [differential harness design](database-redesign-harness.md).
3. Run the same inputs and expected outcomes through the old and new
   implementations using separate databases. Storage-specific fixture builders
   and observation queries may differ; expected arithmetic, event order and
   concurrency scenarios stay independent of those adapters.
   First prove the baseline alone satisfies the fixed expectations. Then require
   both implementations to satisfy them and compare normalized outcomes. New
   guarantees may intentionally fail on the baseline; label and review those
   separately instead of changing preservation expectations to make them pass.
4. Keep direct Postgres assertions for the redesigned constraints and transaction
   boundaries. API-only tests cannot prove that invalid ownership is rejected or
   that a failed operation left no hidden accounting mutations.
5. Use negative controls where practical: reintroducing duplicate allocation,
   classifying conversion as consumption, or removing a required ownership
   check should make the corresponding acceptance test fail.
6. Require each replacement test to cite its invariant ID. Explain removed
   assertions and distinguish storage changes from changed behavior.

Prose is the review contract, not executable proof. Rewritten tests can preserve
behavior when their scenarios and expected outcomes are independently fixed;
rewriting expected results merely to match the new implementation cannot.

## Remaining invariant inventory before the full target schema is approved

The [stage-1 non-payment inventory](stage-1-invariants.md) now traces commute,
boarding, identity, transport and ops scenarios to exact baseline tests, with
evidence limits and target-only gaps. The [review package](stage-1-review.md)
maps model boundaries to these rules. Approval and full-schema candidate tests
remain required; a generated reference table does not prove implementation.

For every proposed entity, name the existing feature or approved requirement it
serves and the invariants it enforces. Membership, billing, commute changes,
direction-specific routes and accounting are in scope. This document neither
defers their redesign nor justifies unrelated future capabilities.
