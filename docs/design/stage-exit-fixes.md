# Replacement exit fixes

Implementation branch: `codex/replacement-exit-fixes`, based on `636239d`.
Sole implementation and verification: Codex. No staging deployment, reset,
provider payment or traffic switch is performed by this change.

## Backend corrections

| Audit gap                                                    | Change                                                                                                                                                                 | Regression evidence               |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| Upload finishes after erasure; abandoned upload has no owner | Reserve the object key and durable cleanup intent before PUT; serialize same-key uploads; recover abandoned intents after a grace period                               | ACR-02, ACR-05, ACR-07            |
| Erasure tasks retain provider subjects                       | Encrypt actual revocation payloads; terminal tasks physically clear payload and reference; ID-token-only Google sign-in is explicitly not an OAuth grant               | ACR-03, ACR-08                    |
| Stale account/device retry reapplies mutation                | Store encrypted command outcomes, validate input and expiry, replay without another mutation                                                                           | ACR-01, ACR-07, ACR-09            |
| Deletion retry loses its acknowledgment                      | Permit only the original, still-valid signed session and exact deletion key; no other authorization exception                                                          | ACR-06                            |
| Two erasure workers call the provider together               | Commit a bounded claim lease before network I/O; conditional completion; recover abandoned claims                                                                      | ACR-04, ACR-05                    |
| HTTP 200 masks partial job failure                           | Validate job-specific outcomes and fail the worker on failed items or response drift, not on expected blocked periods                                                  | Assembly pure job-outcome tests   |
| GPS purge cannot drain; delayed purge leaks an old marker    | Bounded multi-batch drain, held/deletable backlog and lag metrics, logical live-position expiry independent of physical purge                                          | ASM-23, TRP-12                    |
| Receipt payloads remain forever                              | Approved migration 021 permits only one-way payload cleanup; retain tombstones, audit links, decisions and ledger history; refuse expired review replays               | ACR-09/10, REC-13, BRD-28         |
| PAY-08 fails before doing any work                           | Reject invalid terms directly, then inject a test fault after closure and conversion writes are visible; a nontransactional witness proves the write point was reached | Candidate PAY-08R                 |
| Candidate revision/hash does not bind executed files         | Verify Git blob bytes against the declared commit independently before import and after all scenarios; reject untracked runtime inputs                                 | Harness source-verification tests |

Migrations 001–019 stay unchanged. Migration 020 refuses an upgrade with outstanding
old-format provider-revocation tasks rather than discarding a grant or guessing
how to encrypt it. Resolve those tasks with the old service before applying 020,
or design an explicitly reviewed encrypted backfill. An empty replacement
database needs no repair.

Migration 021 was explicitly approved for this fix branch. This is not approval
to apply it to staging. Runtime gains only response-column UPDATE privileges;
triggers reject identity edits, premature cleanup and restoring erased payloads.
PIN ciphertext retains its existing five-minute logical expiry and physical
cleanup path. Provider retry effects must be idempotent: leases do not make a
remote API and Postgres one atomic transaction.

The GPS schedule in `render.yaml` remains commented out. The proposed five-minute
cadence and bounded drain must be measured on the intended database tier before
enabling it. A green small-fixture test is not the 12.96-million-row load gate.

## Not a claim that the replacement is launched

The 119 reviewed operations and 13 deferred operations are unchanged. No new ops
UI or legacy compatibility layer is introduced. These remain separate work:

- Stage 4: migrate both actual apps to one canonical replacement client, verify
  refresh/offline and upgrade behavior, and remove obsolete client duplicates.
- Stage 5: full-size retention/read/write load evidence on the intended tier;
  real private-object and hosted Paystack **TEST** checkout/reconciliation flows;
  device walkthroughs against the assembled replacement.
- Stage 6: replacement-specific deployment workflow and target configuration,
  exact disposable database approval, zero-real-user/data tripwire, coordinated
  app/backend release, and before/after-external-write abort rehearsal.

The current deploy workflow still invokes the old API migrator. Do not turn it
on for this replacement or reinterpret unchanged health/webhook URLs as evidence
that the workflow is ready. A successful backend comparison alone cannot approve
cutover.

## Verification

Verified locally on 2026-09-16:

- **284 Postgres, 34 pure, 21 contract and 10 harness tests passed**, none skipped.
  The full Postgres suite ran against `3236766`; subsequent `b8a7580` changes only
  the harness's expected sanitized error name, not any API source or migration.
- Typecheck, format and generated-artifact drift checks passed. The generators
  still emit **119 reviewed operations / 179 schemas**, with 50 exact historical
  non-payment test references verified. That historical-reference count is not
  a claim that all 50 have independent replacement comparator scenarios.
- Fresh comparison: candidate `b8a7580b9d968fc83034358db47ea35374f8ad9d`
  versus frozen baseline `43cdae0b437e70ca146704eb4201a2325c9d9327`.
  All 16 required payment cases (including the declared PAY-08R substitution),
  four recovery cases on each implementation and four negative controls passed.
  The original pinned Postgres suite also passed. All comparison databases were
  cleaned up by the runner.
- PAY-08R records both `invalidRateRejected: true` and
  `closeWriteObserved: true`; the failed period stays open with 44 rides and no
  closure or conversion effects, while the next period closes for 1,980 pesewas.
  The first run caught an incorrect test expectation (`unexpected_error` rather
  than the production mapper's `internal_error`). The correction did not remove
  either witness or weaken the rollback assertions; the whole run was repeated.
- Candidate verification checked **109 files** against the commit before and
  after execution; baseline verification checked **1,255 files**. Candidate
  source SHA-256: `8a0819d2deea7460444cfcc06375786255b80540b57724203a6cbdd38f25c80c`.
- Local evidence: `.harness-artifacts/run-85c6b7f632d3/report.json`, SHA-256
  `410257db4f4c0e7b1dd814a7d6171755c44c010e9478e2271b6dfbfac4936ea1`.
  These are local results, not a claim of remote CI approval or staging evidence.

Earlier counts in the stage-3 report describe its original reviewed revision,
not this fix branch. The historical review probes remain local only; the proper
regression cases above, not tests asserting old defects, are wired into CI.
