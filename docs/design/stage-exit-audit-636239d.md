# Replacement-plan exit audit — 636239d

Reviewed 2026-09-16. This is a local review artifact, not an implementation PR or cutover approval.

## Verdict

The replacement is substantially implemented, but stage 3 is not ready for an unconditional completion sign-off. Account/privacy defects, maintenance behavior and preservation-evidence gaps need closing. Stage 4 is not complete: generating a client is not migrating the apps. Stages 5 and 6 remain separate gates.

No additional legacy compatibility layer or speculative new ops endpoints are required to fix these findings. The 13 explicitly deferred operations remain deferred.

## Evidence and limits

- Reviewed the integration checkout at `636239d` against the replacement proposal, invariant inventory, harness requirements, GPS/access policy, completion report and client handoff.
- Independently ran **271 Postgres tests, 33 pure tests, 21 contract checks and 9 harness unit tests**, all passing with no skips. Regenerated the reviewed contract: **119 operations, 179 schemas**, no generated drift.
- Inspected the green CI compare artifact from run `35108545594`, head `8a3252c981f7fad3db4a54b0240a272188f62059`. It records 15 payment comparisons plus the declared PAY-08 replacement and recovery substitutions. The complete differential run was not rerun locally in this audit.
- Added five deterministic, local-only Postgres review probes in `services/api-next/tests/stage-exit-review.pg.test.ts` (not committed). All five reproduce the behavior below. They assert observed defects, not desired acceptance behavior. The exit-fix branch instead commits proper regression tests in `account-recovery.pg.test.ts` and the existing suites. External object storage and revocation are controlled test adapters, not real provider calls.
- This is a plan-compliance review with targeted adversarial checks, not a claim that every line of every merged slice was independently re-reviewed.
- Review ran in a separate worktree and disposable local database. No staging, main-branch implementation, provider configuration or GitHub state was changed.

## A. Backend corrections before stage-3 sign-off

### A1 — P1: an avatar can survive account erasure without a cleanup task

**Reproduced: AUDIT-02.** `src/account/service.ts`, `upload()` around lines 282–333.

The upload checks the user, calls object storage outside the transaction, then checks the user again. If erasure commits while the upload is in flight, erasure sees no avatar pointer. The upload then creates the object, fails its second authorization check and leaves one object with zero erasure tasks.

Acceptance:

- Persist enough upload intent to recover objects after erasure or a crash between external success and local commit.
- Preserve the rule against putting provider calls inside a long database transaction.
- A barrier test must erase the account while upload is pending, release the upload, and prove either removal or durable, recoverable cleanup ownership.
- Cover simultaneous same-key uploads and response-loss retries as well as the erase race.

### A2 — P1: completed erasure retains the original provider identity

**Reproduced: AUDIT-03.** `src/account/service.ts` around lines 397–402 and `migrations/017_account_privacy.sql`.

The identity row is scrubbed, but its original provider subject is copied into `erasure_tasks.reference`. After successful external completion, that reference remains. The table's guard rejects scrubbing it, including after the task is done. This unnecessarily preserves the identity the operation was supposed to remove.

Acceptance:

- Separate a non-sensitive durable task identifier from transient revocation data.
- Erase transient subject/credential material after successful completion, including recovery after a crash during finalization; retain only justified completion/audit facts.
- Add an append-only migration; do not edit 017 or other installed migrations.
- Test stored rows, not just whether the provider was called.
- Correct the Google ID-token path: `runtime/compose.ts` currently throws `provider_revocation_unsupported` for every Google task even though that path holds no revocable grant. Represent “no grant to revoke” honestly as a terminal not-applicable outcome rather than a permanently failing retry task. This last point is source-verified, not a separate provider integration reproduction.

### A3 — P2: account-command replay is not reliably idempotent

**Reproduced: AUDIT-05.** `AccountService.rename()` calls `receipt()` but ignores its returned receipt. Execute name A with key A, then name B with key B, then retry key A: the persisted name becomes A again.

**Reproduced at the service boundary: AUDIT-01.** Erasure succeeds with 204, but the exact key subsequently returns 401 even though its receipt exists. The approved access policy explicitly permits a narrowly authenticated lost-response replay for deletion.

Acceptance:

- Completed receipts must prevent another mutation and return the declared replay outcome. Audit `registerDevice` and avatar upload for the same pattern.
- Add the deletion exception exactly as designed: an unexpired, cryptographically valid original credential bound to the deleted session/account and exact completed key may replay 204. Do not restore general access, refresh or accept arbitrary deleted-account tokens.
- Prove this through HTTP as well as the service. Include wrong key, wrong session, expired credential and ordinary post-erasure requests.
- Bring account receipt replay/expiry behavior into line with the approved contract. `account_commands` currently has no logical expiry field/check; blanket documentation that all command stores already enforce logical expiry is inaccurate.

### A4 — P2: concurrent erasure workers do not have a durable claim

**Reproduced: AUDIT-04.** `AccountService.retryErasures()` around lines 483–515.

`FOR UPDATE SKIP LOCKED` protects the claim transaction, but its lock is released before the external call. A second worker claims the same task while the first call is still pending. A barrier test produces two simultaneous calls for one task.

Acceptance:

- Persist a bounded claim/lease before releasing the transaction; prevent concurrent claimants and support recovery after worker death.
- Keep provider operations retry-safe. A lease alone cannot guarantee exactly-once external effects after ambiguous network failure.
- Test true overlap, expired-lease reclamation and completion ownership.

### A5 — P2: the worker can report success for a failed maintenance batch

**Source-verified.** `src/worker.ts:21–34` fails only for HTTP status >=300. Batch endpoints legitimately return HTTP 200 with failure counts; erasure retries also always return status 200 with only considered/completed counts.

Acceptance:

- Validate the result contract for each job, emit bounded diagnostics and exit non-zero for actual failures or malformed responses.
- Do not confuse an expected business block, such as unsettled reservations, with an unexpected processing failure.
- Give erasure retries explicit failed/deferred outcomes so monitoring does not infer success from a 200 or a vague count difference.
- Test the actual worker exit policy with 200-plus-failure, clean success, permitted block and contract drift.

### A6 — P1 before enabling collection: retention cannot keep pace as configured

**Source-verified.** `runtime/maintenance.ts:95–103` defaults to one batch of 100, with a maximum of 100. `transport/gps.ts:604–618` applies that limit to individual fixes. The proposed `render.yaml` schedule invokes GPS retention once daily.

That combination removes at most **100 raw fixes/day**. Even one bus emitting every five seconds for twelve hours creates 8,640/day; the plan's fifty-bus case is 432,000/day. A bounded transaction is good; a scheduler that executes only one tiny transaction is not sufficient retention enforcement.

Acceptance:

- Drain multiple bounded batches with a bounded worker runtime, fresh transaction boundaries, hold protection and safe concurrency; choose schedule frequency from measured throughput.
- Expose oldest expired receipt, deletion lag, deletable backlog and held exclusions. Fail/alert if the agreed physical-deletion deadline is missed.
- Enforce logical expiry independently of cleanup. The live-position read currently has no 30-day receipt predicate; verify that a stale active trip cannot expose an expired marker when purge is delayed. This is a source-identified risk, not one of the five executed probes.
- Run the plan's approximately **12.96M-row** load gate and show sustained deletion faster than peak expiry while recording write/read latency. Do not choose partitioning by assumption or substitute a small fixture test for this gate.
- Inventory physical retention for command receipts and sensitive response payloads. Preserve the minimal retry/audit facts needed by FKs and business identity; do not solve cleanup with cascading history deletion.

## B. Preservation gate corrections

### B1 — PAY-08 substitution does not meet its approved fault-injection requirement

The stricter schema is good and should stay strict. `candidate-adapter.mjs:973–997` pre-inserts a closure against an open period. The close then fails on its **first write**, the closure INSERT in `payments/foundation.ts:422`. No close mutation has happened before the injected failure.

This proves early failure isolation and later-period progress, but not rollback after partial work. The harness design explicitly requires failure **after an observable write point**. A green comparison with this substitution therefore does not establish the full agreed PAY-08 property.

Acceptance:

- Keep direct SQL rejection of malformed purchase terms.
- Keep the current early-conflict test if useful, but do not label it as the entire rollback proof.
- Add controlled failure after a real closure/ledger mutation; prove zero residual close effects, unchanged period state and successful close of a later valid period.
- Demonstrate that removing the rollback behavior fails the intended invariant assertion, not merely setup or compilation.

### B2 — candidate source pinning does not enforce what its comments claim

`candidate-adapter.mjs:24` calculates `SOURCE` once at import. Every adapter reports that cached value. `run.mjs:373–385` compares these values to detect changes during the run, so the check cannot detect a subsequent source change. Resolving the supplied candidate Git SHA does not prove the imported working tree matches it.

Acceptance:

- Execute a verified candidate export at the declared revision, or verify a complete source manifest against that revision and recheck it after execution. Include relevant contracts/migrations/dependency lock state in reproducible provenance.
- Add controls for a mismatched declared revision and a source modification during execution; both must fail the evidence gate.
- Do not call the existing CI artifact invalid business evidence wholesale: it exercised the code. Its revision/change-detection guarantee is the part not established.

### B3 — update the completion claim from actual evidence

Replace broad non-payment “Met” ranges with precise scenario-to-test pointers or explicit approved differences, including lost-response erasure. Rerun the full comparison and all replacement suites after the corrections. Preserve the 13 deferred operations as deferred rather than padding operation counts.

## C. Stage 4: consumer work still required

Both app pubspecs still depend on the old `trotxi_client`; neither app has been migrated to the replacement package. Old app CI passing is not replacement integration evidence.

The `_next` names are not themselves a correctness defect and do not introduce a server-side legacy adapter. Keep them while useful on this integration branch, or regenerate in place; do not spend the day renaming packages instead of migrating consumers. At stage-4 exit choose one canonical generated client/wrapper and remove obsolete duplicates.

Required work:

1. Migrate commuter repositories and user journeys, including two-leg schedule/version/stop-occurrence selection, purchase discovery/recovery, paged reads, membership and commute requests, account/device/avatar/erasure flows and upgrade handling.
2. Migrate driver authentication, trip lifecycle, stop occurrences, manifest, QR/code/photo boarding, GPS acknowledgments, incidents/work requests and upgrade handling.
3. Verify the new wrapper's refresh/offline behavior and client metadata on real app calls. Generated methods still require metadata parameters even where an interceptor supplies headers; document or remove that caller burden deliberately.
4. Inventory actual ops/script/job consumers. Do not invent an ops UI that has not started; ensure the contract and integration tests cover the consumers that exist.
5. Update seeds, ERD, ADRs, runtime instructions and deployment workflow. The current deploy workflow still runs `pnpm --filter @trotxi/api run migrate`; unchanged health/webhook paths do **not** make that workflow replacement-ready.

Do not ship a partly migrated app that mixes unrelated old/replacement identities or data. No compatibility layer is needed: finish the app and rehearse against an isolated replacement backend.

## D. Stages 5–6: rehearsal and explicit cutover approval

- Clean installation with separate migrator/runtime roles and the real production-shaped composition, using staging/test resources only.
- Both mobile platforms: sign-in/refresh, purchase, renewal, pause/resume, transfer/waitlist, reservations, boarding/no-show, driver GPS and rider live map, account erasure and recovery.
- Complete an actual hosted **Paystack TEST** checkout and observe automatic delivery, not a manually signed replay alone. Exercise missing-webhook reconciliation and refund/dispute accounting, including settled boarding interactions. The report itself says no actually paid transaction has been exercised yet.
- Real private-object upload, authorized signed reads, expiry and post-erasure cleanup, including the upload race fixed above.
- Retention/load gate and maintenance failure/lag alerting. Record route/version/direction learning contributions and the retention-window backtest as explicit pilot evidence work; loaded-run counts are not valid segment contributions.
- Final cutover runbook: recheck zero real users/payments/non-disposable data; identify exact target database/service and explicitly approved fixture reset; stop old writers; deploy matching backend and consumers; smoke-test and reconcile before enabling scheduled processing. Include separate abort procedures before and after new external/payment facts.

No Apple developer account or production environment is required to complete a Google-only staging backend. Apple launch remains conditional on provisioning and end-to-end verification; do not turn it into today's unrelated blocker.

## E. Documentation and genuine decisions

The completion report is stale: 019/shared admission is implemented, Google-only composition can start without Apple credentials, and test/migration counts moved. Fix those statements rather than implementing already-delivered work again.

Keep these decisions explicit, without inventing functionality:

- `take_rate_bp` is not consumed by the agreed price formula; do not invent operator settlement to give it a use.
- Bulk future-version reassignment has no approved endpoint. Review the existing attributable cancel/replace workflow against the requirement; add a new operation only if that workflow is insufficient.
- Account receipt expiry is not currently implemented like its siblings; distinguish that bug from the broader physical-purge backlog.
- Internal cleanup attribution does not require a new public maintenance endpoint.

## Historical recommended finish order

Implementation was subsequently assigned solely to Codex. See
[the exit-fix record](stage-exit-fixes.md) for delivered corrections and remaining gates.

1. **Account/privacy correction PR:** A1–A4, plus exact replay/expiry behavior. Add migrations after the current chain; coordinate numbering with any concurrent implementation. Bring the five review probes into proper regression tests.
2. **Maintenance/retention correction PR:** A5–A6, durable retry outcomes, bounded draining and observable lag. Supply the load evidence separately if it cannot complete with the code change.
3. **Preservation/evidence PR:** B1–B3, accurate completion report, fresh comparison artifact tied to the reviewed revision.
4. **Consumer integration PRs:** commuter, driver and real existing scripts/ops consumers against stable contracts. This work need not wait for documentation polish, but cutover must wait for it.
5. **Rehearsal evidence and cutover runbook:** D, with explicit approval before any database reset or traffic switch.

The honest same-day target is to close and review the backend findings and advance consumer integration. “Finished today” is justified only when the relevant app, provider, retention and cutover gates have actually passed; merged backend PRs alone do not establish it.
