# Database redesign: differential verification harness

Status: stage-2 baseline implementation is available for review in
[`tools/redesign-harness`](../../tools/redesign-harness/README.md).
The original 16-test suite, PAY-01–16 harness, four recovery cases and two
persisted-state negative controls have run against disposable Postgres.
No candidate business adapter or replacement schema exists yet. The sections
below remain the acceptance design; the implementation runbook states current
coverage and candidate-extension limits explicitly.

Related: [invariants](database-redesign-invariants.md) and
[schema/rollout proposal](database-redesign-proposal.md).

## Purpose and first gate

Build the measuring instrument before changing the domain models. Pin the old
implementation to `43cdae0b437e70ca146704eb4201a2325c9d9327`, including its
migrations and dependency lockfile. Preserve its original Postgres suite as a
separate baseline check.

The old adapter and migration chain are test-only, running in a disposable
database. They do not become deployed compatibility handlers, dual writers or
transitional tables. Staging receives one clean replacement model.

Stage 2 is complete only after the harness exercises the existing implementation
against real Postgres and reproduces all 16 mapped scenarios' expected outcomes.
Then add the candidate implementation adapter as the redesign progresses.
Running old versus old tests comparator plumbing, but is not independent evidence
that the model is correct; fixed expectations and negative controls are also
required.

## Components

| Component               | Responsibility                                                                                                      |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Scenario catalog        | Reviewed inputs, logical actors, action order/concurrency, observations and expected results, keyed by invariant ID |
| Baseline adapter        | Run pinned old application/domain operations and build/query fixtures using its schema                              |
| Candidate adapter       | Run redesigned operations and build/query fixtures using its schema                                                 |
| Provider/clock controls | Identical fake Paystack facts and explicit business times for both runs; no live credentials                        |
| Outcome normalizer      | Map generated IDs and implementation-specific representations to stable domain observations                         |
| Comparator              | Require each implementation to satisfy fixed expectations; compare compatible normalized outcomes                   |
| Evidence report         | Record revision, scenario, database migrations, inputs, normalized results, failures and required coverage count    |

Scenario definitions and expected outcomes live outside the adapters. The
adapter may translate a result, but may not return hard-coded expected balances
or alter expectations for its implementation. Storage observers must derive
results from persisted evidence after operations commit, including relevant
transaction status, period attribution, money and entitlement effects.

## Isolation and repeatability

- Use separate disposable Postgres databases for old and candidate code. Each
  runs only its own migrations and uses its own connection pool and provider
  state. Require compatible PostGIS support.
- Isolate scenarios that scan globally: resetting a dedicated scenario database
  or equivalent proven isolation is preferable to relying on historic cutoffs
  to avoid another test's rows. No other suite may share that state concurrently.
- Use logical names such as `riderA`, `purchaseFirst`, `periodSecond` in inputs.
  Each adapter maps those to its own physical IDs. Preserve distinctness and
  ownership when normalizing; collapsing all generated IDs would hide defects.
- Use explicit times for boundary and renewal scenarios. The old implementation
  also calls database `now()` and system time: inject time where supported and
  verify all remaining time-sensitive paths. Do not promise deterministic time
  merely because fake JavaScript timers are enabled. Fixture deadline adjustment
  may be adapter-specific, documented and independently checked.
- Generate isolated provider transaction IDs and signatures for each run while
  retaining the same logical event identity, amounts, statuses and timestamps.

## What is compared

Observations include agreed cash/credit amounts, available versus held credit,
ride balances per purchase, actual consumption, conversion/reversal effects,
period coverage and closure, current purchase identity, independent access
blocks, processed refund totals and review estimates.

Do not compare generated UUID bytes, database row order, wall-clock execution
duration, or physical table counts when a representation intentionally changes.
Compare one financial effect and its logical attribution instead. Preserve raw
evidence for debugging, including storage-specific integrity assertions.

Concurrent scenarios may have more than one legal winner. Compare invariant
properties and approved outcome sets, rather than requiring the same worker to
win in both independent runs. For PAY-02, either checkout may win but exactly
one succeeds and only 1,000 pesewas is held. For PAY-04, either close path may
perform conversion but it must happen once and renewal must receive 1,980.

## Three test categories

### A. Behavior preservation

Use identical domain scenarios and fixed expectations against both adapters.
Include PAY-02 through PAY-07 and PAY-09 through PAY-16, subject to the documented
fixture and representation limits. Preserve the original PAY-08 rollback/batch
scenario on the baseline and equivalent failure containment on the candidate,
as explained below. Reuse the same expectations rather than copying and editing
two test files independently.

### B. Storage and integrity guarantees

PAY-01 is principally a schema metadata check. Each schema must explicitly
document its money fields and units, using its own field inventory. It is not
meaningful to demand byte-identical column names.

PAY-08 currently forces a missing rate into an otherwise fulfilled period. The
candidate should reject that invalid state at write time if its new constraints
make it impossible. Test that rejection directly. Separately inject a controlled
failure during period close, after an observable write point, and assert full
rollback plus progress for a later valid period. Record the approved substitution
so fault containment is preserved without weakening a NOT NULL constraint to
accommodate an old fixture.

Cross-rider funding rejection, correct stop/version ownership, unique driver
identity, archival/delete restrictions and required purchase terms must be
exercised by direct SQL against the candidate. These tests must not rely solely
on an API refusing invalid input before it reaches the database.

### C. Approved new guarantees and known baseline defects

A target requirement may deliberately fail on the baseline, such as rejecting a
cross-rider link that the old schema permits. Give it an explicit target-only
label with its requirement and observed baseline limitation. Do not weaken it to
obtain equality and do not silently count it as preserved behavior.

The same treatment applies if the expanded inventory reveals an existing
payment/commute interaction defect. Review the intended outcome before adding
it as a target-only requirement; the baseline is evidence, not infallible policy.

## Concurrency, failure and replay

Use separate database connections for competing operations. Where repeatable
ordering matters, synchronize at explicit transaction/action barriers or verify
lock contention; `Promise.all` alone is not proof that a race occurred.

Run the existing concurrent checkout, webhook worker, period close and full
refund scenarios. Add selected fault cases from the invariant gaps: interrupted
fulfilment, paused processing with a durable inbox, recovery/replay, and refunded
conversion credit already held by another checkout. Fault injection belongs in
test infrastructure and must not expose a production bypass endpoint.

Negative controls must demonstrate the measuring instrument catches selected
known defects. Examples are double allocation, treating conversion as
consumption, and using unscoped period ownership. At least one arithmetic and
one attribution/identity control must fail the expected invariant assertion.
A compile error or a database connection failure does not count as detection.

## Proposed CI gates

1. Baseline original suite passes against its pinned migration chain.
2. Harness baseline mode exercises all 16 mapped scenarios, with storage-specific
   checks reported separately from domain comparisons.
3. Candidate preservation mode requires both real databases and the expected
   scenario inventory. Missing database configuration, missing adapters or skipped
   required tests fail CI instead of producing a green empty run.
4. Candidate integrity and target-only suites pass with their requirement IDs.
5. Reports identify old/candidate commit IDs and migration hashes. Failed
   comparisons show the input sequence and smallest differing observations,
   without credentials or live personal data.

Stage 3 extends this gate for every replaced domain; stage 4 adds consumer
contract checks. Keep the baseline immutable; intentional rule changes need
their own reviewed acceptance entry. Stage 5 adds real app journeys and stage 6
staging cutover checks, neither replacing isolated transaction/concurrency tests.

## Stage 2 deliverables

- Versioned scenario catalog and expectation set for PAY-01 through PAY-16.
- Executable baseline adapter and separate-database provisioning/cleanup.
- Comparator and persistence observers, including identity normalization.
- Passing baseline report plus meaningful failing negative controls.
- CI that cannot silently skip required database coverage.
- Candidate adapter interface and explicit treatment of schema-specific checks
  and target-only improvements.

No migrations that reshape the business domains begin before this baseline gate
works. Clean-schema migration tooling can be developed alongside the harness.
Leave the pinned baseline untouched; build integrity safeguards in the target
schema rather than retrofitting tables that will be removed.
