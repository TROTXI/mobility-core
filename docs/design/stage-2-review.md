# Stage 2 implementation review

The baseline measuring instrument is implemented. No business migration,
production endpoint, app client or deployment setting changes in this PR.
Staging was not accessed or reset. Replacement runtime work remains stage 3.

## Review order

1. [`catalog.mjs`](../../tools/redesign-harness/catalog.mjs): 16 preserved payment
   scenarios, independent fixed expectations, four new recovery scenarios and
   two deliberate negative controls. No SQL or baseline adapter import.
2. [`baseline-adapter.mjs`](../../tools/redesign-harness/baseline-adapter.mjs): pinned
   domain calls, SQL fixture translation and persisted-state observations.
3. [`assertions.mjs`](../../tools/redesign-harness/assertions.mjs): exact scalar/array
   comparison, logical identity preservation and contract projection.
4. [`run.mjs`](../../tools/redesign-harness/run.mjs) and
   [`support.mjs`](../../tools/redesign-harness/support.mjs): source pinning,
   isolated databases, original suite, fail-closed reporting and cleanup.
5. [Runbook and extension limits](../../tools/redesign-harness/README.md).

## Verification

- Original **16** payment Postgres tests pass unchanged at pinned `43cdae0`.
- **16/16** domain harness scenarios reproduce the fixed payment expectations.
- **4/4** additional real-Postgres recovery cases pass.
- **2/2** negative controls are detected by the exact intended invariant check:
  double allocation gives 88 rides rather than 44; a wrong current-period pointer
  resolves to `first` rather than `renewal`. A runtime exception is not accepted
  as successful negative-control detection.
- **7** harness unit/preflight checks cover missing DB/candidate, bad CLI flags,
  destructive-target restrictions, inventory completeness and comparator plumbing.
- **14** design-contract checks include coverage of all 35 predecessor-free
  operations. Generation remains deterministic and CI checks drift.

Runs record a pristine source/lockfile pin, per-migration hashes, independent
scenario databases, actions, normalized observations and raw synthetic rows.
The CI job publishes those artifacts on both success and failure. It does not
claim schema-independent runtime correctness merely because JSON validates.

Concurrency evidence includes distinct blocked PostgreSQL PIDs for checkout,
renewal/close, close/close and refund/refund. Inbox claim overlap has its own
explicit barrier and connection identities. Recovery kills a real backend after
an allocation exists inside its transaction, then proves rollback and later
inbox recovery. Lost acknowledgement and expired claim are separate scenarios.

The original fixture's permissive `>=1 blocked` becomes exactly one because each
scenario owns its entire database. Renewal and reconciliation no longer rely on
backdating one row to avoid other test files' globally scanned fixtures.

## Scope review follow-up

[All 35 new-operation decisions](stage-2-operation-scope.md) carry a requirement,
delivery decision and assessment of existing endpoints. **22 are cutover work;
13 convenience operations are deferred.** They remain marked proposals in the
132-operation design catalog, not part of the launch implementation commitment.
The shape of current operations is not weakened to avoid adding a required
command: trip cancellation and pending-purchase status reads remain required.

## Deliberate boundaries

- PAY-01 is storage metadata; PAY-02–16 are preserved behavior. REC-01–04 are new
  baseline evidence, not retroactive claims about the original suite's coverage.
- No candidate adapter has been tested. Compare mode requires explicit candidate
  code, SQL migrations and revision, otherwise it fails. Candidate runtime pinning,
  new ownership constraints and target-only cases must be added in stage 3.
- The PAY-08 candidate substitution still needs review when NOT NULL terms make
  the malformed baseline fixture impossible. Test rejection plus post-write
  rollback/continued batch progress; do not loosen the new constraint.
- The 50 non-payment references are not 50 newly ported database scenarios.
  Expand the harness per domain during stage 3; do not label memory fixtures as
  proof of database races or full-schema commute integration.
- Learning telemetry/retention backtests remain pre-pilot replacement-service
  work, keyed by explicit route version/direction. There is no extra raw-GPS
  retention permission or experimental publication to rider maps.

The zero-real-user tripwire remains operationally required before a cutover or
fixture reset. Local synthetic success does not establish staging emptiness or
authorize launching real users.

## Next stage

Review and merge this baseline gate, then implement the first replacement domain
and its candidate observer on a new branch. Keep the baseline Git pin unchanged.
Run old and candidate code in separate databases, satisfy the same expectations,
and add the approved target-only integrity tests rather than modifying expected
results to fit the new schema.
