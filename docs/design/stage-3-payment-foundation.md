# Stage 3: financial foundation (011)

Status: **domain implementation and contiguous migration; not enabled in the replacement app**.
Integration base: merged #306 at `77f00c24c53376230618531f7a85640d73578916` on
`codex/backend-replacement`. No main/staging deployment or provider calls.

## Parallel-work boundary

Claude owns driver operations in **010**, then geospatial work in **014**.
Codex owns financial foundation **011**, recovery/refunds/disputes **012**,
commute/pauses/reservations **013**, then boarding/settlement **015**.
Numbers are reservations, not permission to install a discontinuous chain.

010 has merged. The captured-hold/debit hardening was committed separately while
011 was still a draft (`606b4ba`), then the file was promoted byte-for-byte to
`services/api-next/migrations/011_payment_foundation.sql` (Git blob
`1490457331a55218cd36073d5b027bccdeac7e91`). The hardening is an explicit review
delta, not claimed to have been approved in the earlier review. Tests now use
the real checksum runner for the complete chain; the special draft installer is
gone. No applied 001–010 bytes or operation allowlists were rewritten.

## Implemented domain behavior

- Server quote boundary, exact pesewa arithmetic and frozen purchase terms.
  Checkout input contains selections and `useCredit`, never a client price.
- Stable membership identity; independent purchases, provider attempts and
  funded periods. Current coverage is derived, with no writable current-period
  pointer and no duplicated subscription price/date columns.
- Purchase input normalization and key/payload conflict detection; same-key
  requests return the existing purchase, without recalculating its terms.
  Session authorization runs first. Replay returns current domain state, not
  an HTTP command-receipt body; HTTP integration remains outstanding.
- A user-row lock serializes checkout, settlement, close and credit mutation.
  Unresolved purchases and active paid coverage block a second checkout.
  An ended period closes in the renewal transaction, so its conversion credit
  can fund the next purchase without a conversion/expiry ordering hazard.
- Credit is held at checkout and captured exactly at fulfilment. The database
  also prevents other credit entries from consuming held value; there is no
  debit clamp. Net provider charge is at least 100 pesewas. A deferred constraint
  requires every captured hold to have its exact typed debit at commit; release
  needs no debit. Intermediate capture-before-debit remains valid in a transaction.
- A matching successful settlement records provider identity and cash facts,
  allocates one period and one ride grant, captures credit and invokes commute
  assignment in one transaction. A callback failure rolls everything back.
  Successful duplicate settlement is a no-op. Contradictory provider facts are
  refused; this service is **not** the durable provider inbox.
- Closing converts only that period's unused rides at its frozen rate, with a
  typed closure source and exactly-once ledger effects. The reservation/access
  check runs before mutation. Conversion is a distinct ride-entry reason,
  never a boarding-consumption estimate.

## Why these ten tables exist

| Table                | Existing requirement / invariant                                           |
| -------------------- | -------------------------------------------------------------------------- |
| `memberships`        | Stable rider membership across purchases and commute decisions             |
| `purchases`          | PAY-01/02/04: immutable gross/net/credit terms and checkout identity       |
| `purchase_legs`      | Approved paired outbound/return selection, owned version and ordered stops |
| `payment_attempts`   | PAY-03/10: provider reference, environment, cash facts and retry identity  |
| `billing_periods`    | PAY-04/05/07: one funded interval per purchase, derived current coverage   |
| `credit_adjustments` | Attributable ops credit source, not an untyped ledger reference            |
| `credit_holds`       | PAY-02: prevent promising or spending the same credit twice                |
| `period_closures`    | PAY-06/07/15: period-specific conversion provenance and amount             |
| `ride_entries`       | PAY-03/06/15: append-only ride grants/conversions with typed sources       |
| `credit_entries`     | PAY-02/06/15: append-only monetary effects with typed sources              |

Composite FKs enforce rider ownership on attempts, periods, holds and ledger
sources. Purchase terms and membership identity are immutable. Paid periods
cannot overlap, successful attempt facts cannot be rewritten, and runtime
roles cannot update/delete ledger history. Captured holds must have their debit
at commit. These are bounded guarantees: the schema does not yet require every
other source row to have a ledger effect at commit;
the service transaction supplies that completeness. Ops adjustment commands must
insert the adjustment and effect together, with authorization and audit.

## What is deliberately not claimed

There are **no new HTTP endpoints** in this slice. The replacement app still
exposes the 47 operations present after #306. The financial changes do not edit
routes or shared contract artifacts.

`FinancialDependencies` has explicit transaction-client boundaries for live
session authorization, server pricing, checkout eligibility, period-close
eligibility and commute assignment. Relevant missing adapters fail closed.
Tests supply named domain-isolation adapters (including an artificial session
table and no-op commute callbacks), not substitutes suitable for deployment.
The deployable composition must reject missing adapters at startup when these
routes are introduced, as transport commands already do.

Still required before enabling purchase endpoints:

1. **012:** durable provider inbox, Verify/reconciliation, late success review,
   hold release/recovery, monotonic refunds/disputes, period-scoped access blocks,
   converted-credit clawback and attributable review resolution.
2. **013:** real pricing/commute eligibility, current session integration,
   assignment materialization, pauses and funded-reservation close guard.
3. HTTP authentication/authorization, schema and idempotency response mapping,
   rider-owned purchase discovery/read endpoints and provider orchestration.
   Never perform Paystack network calls inside the financial transaction.
4. Batch-close isolation/diagnostics and actual operational worker composition.
   A single-period callback rollback is not PAY-08 batch-containment proof.
5. Candidate harness adapter and comparison of **all 16 fixed PAY scenarios**
   against pinned baseline `43cdae0b437e70ca146704eb4201a2325c9d9327`, including
   approved target-only constraints/fault-injection substitutions. No baseline
   expectations have been changed or weakened by this slice.

The ledger currently admits only the implemented typed sources. Later refund,
reservation and boarding migrations must add their concrete source columns,
ownership FKs and source-specific checks; do not replace these with arbitrary
`ref_type/ref_id` strings. Financial grant tightening is integrated into
`grantRuntime`; there is no separate helper that deployment can forget to call.

## Verification and promotion

The dedicated financial CI job fails if disposable Postgres configuration is
missing. Sixteen financial Postgres scenarios plus two pure arithmetic/calendar tests
exercise source constraints, real lock contention, duplicate checkout/delivery,
renewal with changed future pricing, exact end boundary, callback rollback,
provider mismatch, ownership, immutable terms, held-credit protection, deferred
capture/debit completeness and upgrading a populated 010 fleet without changes.
The ownership test requires FK error `23503`, not a duplicate-index failure.
Rollback injection asserts allocation already exists inside the transaction.
Contention scenarios record blocked backend PIDs before releasing the blocker.

This is **partial domain evidence**, not 16-scenario parity or end-to-end payment
proof. Existing transport/auth/driver gates continue to run separately.

The promotion gate includes clean installation, real 010-to-011 upgrade, unchanged
prior migration checksums and fleet rows, idempotent installer replay, and narrow
runtime grants. The schema inventory is 37 tables: the previous 27 plus the ten
financial tables listed above (also asserted by name in MIG-01).

Baseline negative controls remain unchanged and run against the pinned baseline
adapter, even in comparison mode. Replacement SQL rejecting a second allocation
is separate target integrity evidence, not a relabelled baseline `detected` result.
The sixteen FIN tests are not substitutes for the sixteen PAY harness scenarios.

Keep runtime/API composition disabled until the listed dependencies exist.

The zero-real-users/no-real-payments/no-retained-non-disposable-data precondition
still applies. This work does not reset or modify staging data.
