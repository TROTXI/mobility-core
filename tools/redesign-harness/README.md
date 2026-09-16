# Preservation harness: pinned baseline versus the replacement

Test infrastructure only. Nothing here is imported by the API or deployed workers.
No replacement business tables, staging fixtures or app clients are changed.

## Run

Use Node 24 and pnpm. Start an **explicitly disposable** PostGIS 16 instance on a
loopback port, with a login allowed to create databases. Never pass a staging
connection string. The runner refuses remote hosts, application databases,
connection-string options and missing creation consent.

```sh
node --test tools/redesign-harness/harness.test.mjs
node tools/redesign-harness/prepare.mjs
HARNESS_ADMIN_DATABASE_URL=postgres://harness:harness-local-only@127.0.0.1:5432/postgres \
HARNESS_ALLOW_CREATE_DATABASES=1 \
node --import ./.harness-artifacts/baseline/services/api/node_modules/tsx/dist/loader.mjs \
  tools/redesign-harness/run.mjs --mode=baseline
```

Use the actual credentials/port of your disposable instance; the example does not
start one. CI supplies a dedicated service container with no external credentials.

Preparation exports **43cdae0b437e70ca146704eb4201a2325c9d9327** into the ignored
`.harness-artifacts/baseline` directory, verifies every tracked file against Git
blob hashes, and installs its own frozen lockfile using pinned pnpm 11.5.2.
Dependency lifecycle scripts are disabled. It does not symlink current app code
or current dependencies into the old implementation. A baseline `.env` is refused;
child processes receive only a small environment allowlist and the disposable DB.

## What the gate proves

1. Run the original, unchanged 16-test payment PG suite against the original
   migration chain. Require exactly 16 passing assertions, not an exit code from
   a silently skipped suite. Apply migrations twice and verify the full inventory.
2. Independently execute PAY-01–16 using the domain actions and numeric/identity
   expectations in `catalog.mjs`. The adapter neither imports those expectations
   nor implements arithmetic assertions. Observations come from committed rows.
3. Run four additional real-adapter cases: terminate a backend after an allocation
   is visible inside its uncommitted transaction; fail acknowledgement after
   committed fulfilment; recover a durable inbox claim after its lease; refund
   conversion credit already held by a pending renewal, then fulfil that renewal.
4. Mutate persisted state in fresh scenarios to prove the observer/comparator
   rejects an 88-ride balance where 44 was purchased, and rejects a current-period
   pointer to the first purchase where the renewal should be current. Only the
   exact expected `InvariantFailure` path counts as detection. SQL, connection,
   import and setup failures do not count.

`PAY-01` is a storage-unit check, not behavior equivalence. The remaining payment
scenarios preserve the reviewed baseline. REC-01–04 are newly established baseline
evidence, not assumptions from the original 16 tests. They do not cover every
possible crash or payment ordering.

## Isolation, clocks and races

- Migrate one pristine template with the original runner, then clone a unique
  database for each scenario, each negative control and the original suite.
  Global close/reconciliation queries cannot see another scenario's records.
  Run names use a random 12-hex namespace. Cleanup only drops names created by
  that process; no user table truncation, wildcard drop or shared DB reset.
- All pools are closed before ordinary `DROP DATABASE`. An abnormal process kill
  can leave only run-owned databases in the disposable container; destroy that
  container to clean up, not arbitrary databases on another server.
- Checkout/settlement/close use explicit business times. The boundary scenario
  reads the persisted period end and tests end−1 ms/end. Database audit timestamps
  remain real. Reconciliation explicitly sets its own fixture's creation time;
  stale-claim recovery backdates `processing_at` past the real five-minute lease.
  Those adjustments are test setup, not changes to the frozen implementation.
- Checkout, close/renewal, close/close and refund/refund races use separate worker
  connections held behind the rider's real advisory lock. The harness requires
  two distinct blocked PIDs in `pg_locks` before releasing the blocker. Merely
  constructing `Promise.all` does not satisfy the instrumentation.
- Inbox workers use an explicit post-claim barrier. The first worker holds its
  connection after its claim is persisted; the second must use a distinct PID
  and find no claimable duplicate while the first remains paused.
- Fault interception wraps only test-owned pool clients. The production source
  is never patched, and there is no deployable fault endpoint. Backend termination
  is real; lease expiry and acknowledgement failure are controlled simulations.

## Observations and comparison

Logical `riderA`, `first` and `renewal` identities map independently to real UUIDs.
Period attribution comes from the actual period's funding payment; membership's
current purchase is resolved through its stored pointer. Unknown identities are
reported as unmapped, never collapsed into one placeholder. Raw synthetic rows
are retained alongside normalized checkpoints for review.

Fixed expectations select domain contract fields; arrays and scalar leaves are
exact. Extra diagnostic fields do not become accidental schema obligations.
Comparison uses the same contract projection after **both** sides satisfy those
expectations. Old-versus-old is tested only as comparator plumbing, not independent
correctness evidence. Real negative controls supply separate sensitivity checks.

## The replacement candidate

`candidate-adapter.mjs` runs the replacement backend in `services/api-next`. It
translates the same catalog actions into that model's own services and reads
observations back out of committed rows. It imports no expectation and asserts
no arithmetic of its own.

Run both sides:

```sh
node --import ./.harness-artifacts/baseline/services/api/node_modules/tsx/dist/loader.mjs \
  tools/redesign-harness/run.mjs --mode=compare \
  --candidate-adapter=tools/redesign-harness/candidate-adapter.mjs \
  --candidate-migrations=services/api-next/migrations \
  --candidate-commit=HEAD
```

In compare mode the gate now requires, on the candidate as well as the baseline:
all sixteen PAY scenarios passing **and** comparing, every supplemental recovery
case either run or substituted, and both negative controls detected on their
exact assertion paths. A candidate run that covered fewer cases than the
baseline is a failed gate, not a shorter one.

### What the two models call the same fact

The candidate normalizes where the representation differs and the fact does not.
Each mapping is in the adapter with its reason, and the raw rows stay in the
evidence:

| Fact                   | Baseline                                  | Replacement                                                        |
| ---------------------- | ----------------------------------------- | ------------------------------------------------------------------ |
| Membership status      | one `subscriptions.status` column         | membership lifecycle and whether any period is open, read together |
| Current purchase       | `subscriptions.current_period_id` pointer | the purchase whose coverage runs latest                            |
| Purchase `disputed`    | a purchase status                         | an unreleased access block on its period                           |
| Inbox `received`       | `status='received'`                       | `state='ready'` with no attempt yet                                |
| Inbox `failed`         | `status='failed'`                         | quarantined, or ready after a failed attempt                       |
| Inbox `processing`     | `status='processing'` plus a lease        | the row is locked by another worker, asked of the lock manager     |
| Inbox membership       | webhook deliveries                        | webhook deliveries; self-fetched Verify evidence is kept separate  |
| Consumption            | boarding, no-show and returned entries    | boarding and no-show entries; a refund removal is not consumption  |
| Operations review list | open work                                 | reviews still in state `open`                                      |

### Fixture substitutions, each with its reason

- **PAY-08's malformed period.** The baseline nulls the period's conversion
  rate. The replacement freezes that rate `NOT NULL` on the purchase, the
  purchase's terms are immutable by trigger, and a period carries no copy, so a
  missing or malformed rate is unrepresentable. The one unconvertible period
  this schema does permit is a half-written close: a closure row against a
  period that is still open. Both sides report the outcome as
  `unconvertible_period`; neither constraint was weakened to make this fit.
- **PAY-10's discovery cutoff.** The baseline backdates the payment row behind
  the cutoff. Attempt identity is immutable here, so the cutoff moves instead:
  the same attempt, the same "older than an hour" rule, no rewritten row.
- **REC-02 and REC-03** are replaced by `REC-02R` and `REC-03R`, declared in
  `candidateSubstitutions`. REC-02 assumes a committed fulfilment with a missing
  acknowledgement; the replacement commits the effect and its receipt in one
  transaction, so that state cannot exist, and REC-02R proves the stronger thing
  instead: interrupting the acknowledgement grants nothing at all. REC-03
  assumes a processing lease to expire; the replacement claims by locking the
  row inside the processing transaction, and REC-03R proves another worker skips
  a held claim and that the claim dies with the worker holding it, with no
  interval to wait out.

A substitution names the case it replaces, states why that case's premise cannot
exist, and is itself a scenario with fixed expectations that has to pass.
`harness.test.mjs` enforces all three, and the runner refuses a gate where a
required case was neither run nor substituted.

### Negative controls on the replacement

Both controls test the measuring instrument, not the schema, and the replacement
refuses both corrupt states through triggers and a unique index. The adapter
therefore suspends exactly those protections on its own disposable database,
records what it suspended in the evidence, and restores them. Detection still
has to come from the observer and the comparator on the exact assertion path: a
SQL error does not count. `NEG-ARITHMETIC` is caught at
`$.riders.riderA.rides` (44 against a written 88) and `NEG-ATTRIBUTION` at
`$.riders.riderA.currentPurchase` (renewal against a coverage row moved to make
the first purchase look current).

### What running the replacement found

Two defects in the replacement, both fixed rather than normalized away:

- Period close reported a period blocked by unsettled funded service as
  `failed`, sending an operator to look for a fault that did not exist and
  burying the periods that genuinely could not close. PAY-09 is the test.
- Batch close reported every failure as `unexpected_error`, so the report could
  not say which period could not close or why. It now carries the refusal's own
  code.

And one thing the harness could not represent at all, which is recorded rather
than papered over: a period whose recorded terms are malformed. See PAY-08 above.

## Candidate extension and honest limits

`adapter-contract.ts` describes the interface. A future candidate module exports
`createAdapter({ databaseUrl })`; unknown actions must fail. Comparison mode also
requires a candidate SQL migration directory and resolvable commit:

```sh
# Same disposable DB configuration and tsx loader as above.
node --import ./.harness-artifacts/baseline/services/api/node_modules/tsx/dist/loader.mjs \
  tools/redesign-harness/run.mjs --mode=compare \
  --candidate-adapter=/absolute/path/candidate-adapter.mjs \
  --candidate-migrations=/absolute/path/candidate/sql \
  --candidate-commit=COMMIT
```

The candidate gets separate empty databases and only its own SQL migrations.
Missing options, files or adapters fail rather than skip. The revision is declared input for candidate reports;
stage 3 must pin/verify the candidate runtime tree, not mistake that label for
the byte-level baseline verification performed here. Comparison mode is an
extension point, **not yet a candidate release gate**.

PAY-08's invalid-rate fixture was baseline-specific; the approved substitution
is recorded above and no constraint was weakened to accommodate it.
Stage 3 must add full-schema candidate integrity/target-only tests and observers
for each replaced domain. The 50 non-payment references remain that expansion
inventory; this PR does not claim they have been ported to this adapter.

GPS contribution-age telemetry and truncated-input retention backtests belong to
the replacement explicit-direction/versioned learner, before pilot. They must
use fixed as-of times, avoid future-data leakage, compare held-out arrival error
as well as segment coverage, and never publish experimental outputs or retain
raw traces past the approved maximum.

## Evidence and CI

Each run writes `.harness-artifacts/run-<id>/report.json`, per-scenario evidence,
and the original Vitest JSON. `latest-report.json` starts as `running` and finishes
`passed` only after every required scenario, all four supplemental cases and both
negative controls succeed. Reports include source revision/hash, pinned lockfile,
migration SHA-256 inventory, PG/PostGIS version, actions, observations, fault/lock
evidence, assertion failures and cleanup names. No database URL or credential is
written into reports. All rows are synthetic; never run this against real data.

The `Redesign baseline harness (Postgres)` CI job runs the original and new gate
on its own PostGIS container and uploads synthetic evidence for 14 days even on
failure. It uses no repository/environment secrets and performs no deployment.
