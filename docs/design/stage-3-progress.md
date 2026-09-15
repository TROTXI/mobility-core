# Stage 3 implementation checkpoint

Stage 2 is approved and merged as PR #294, merge `1a46ad0`. The source/lockfile
baseline remains pinned to `43cdae0`; it is not advanced to the merge commit.
Stage 3 is **in progress**, not complete and not ready for a staging cutover.

## First review slice: transport storage

Integration branch: `codex/backend-replacement`, initially at the stage-2 merge.
First implementation branch: `codex/stage-3-transport-foundation`.
The integration branch is not connected to the staging deployment. Its PRs
receive CI without merging an incomplete replacement onto deploying `main`.

Read [the replacement package](../../services/api-next/README.md), then its
[new migration](../../services/api-next/migrations/001_transport_foundation.sql),
[installer](../../services/api-next/src/db/migrate.ts) and
[real Postgres tests](../../services/api-next/tests/transport.pg.test.ts).

| Requirement               | Evidence in this slice                                                                                       | Not yet claimed                                                      |
| ------------------------- | ------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------- |
| Clean migration baseline  | Hash inventory, two serialized installers, repeat no-op, drift refusal, rollback, old-model refusal          | Rehearsed staging reset/cutover                                      |
| Unique driver linkage     | Direct duplicate-link rejection, null provisioning allowed                                                   | Sign-in, PIN, session or erasure replacement                         |
| VER-01 immutable versions | Complete geometry/stops, zero-based occurrence identities, overlap rejection, editing/publication contention | Publish/reassignment API and its actor/consent workflow              |
| VER-01 ownership/history  | Composite stop/geometry/schedule/trip FKs, archival restrictions, actual attribution negative control        | Full commute/reservation ownership graph                             |
| VER-02 direction          | Reschedule a return trip across noon; direction and explicit window unchanged                                | Commute leg pairing or replacement ETA learning                      |
| TRP-01 coherent states    | Direct SQL rejects illegal transitions, missing/rewritten timestamps and terminal rewrites                   | Preserved driver-service behavior, authorization or HTTP idempotency |
| Narrow runtime role       | No owner membership, DDL, DELETE, TRUNCATE, history UPDATE or migration access                               | Final deployment credential provisioning                             |

The expected proof remains unchanged: each replaced domain gets preservation
scenarios plus storage/target-only checks. This first storage slice does not
claim a two-database payment comparison or mark any of the 50 non-payment
scenario groups fully ported merely because a related CHECK constraint passes.

## Contract correction found during implementation

The approved model requires an explicit service window independent of direction
and clock time. `Schedule` and `ScheduleInput` omitted it. Both now require
`serviceWindow: morning | evening`, with a Zod/OpenAPI regression test. The
generated spec changes with its source; no deployed endpoint/client is changed.
This is fulfilling VER-02, not introducing a new departure inference or product.

## Next slices / stage exit

Continue with transactional transport commands and baseline/candidate observers,
then the membership/accounting candidate and cross-domain commute/boarding.
Payments may proceed independently once shared identities are fixed, but its
16 preserved scenarios and four recovery cases still must pass unchanged except
for explicitly approved representation/fixture substitutions. GPS provenance,
retention and learning, auth/privacy, all cutover endpoint handlers and their
authorization/replay rules remain stage-3 work.

Stage 4 is consumer integration; stages 5–6 are rehearsal and explicitly approved
cutover. No staging DB was inspected, modified or declared empty by this local
work. The zero-real-user/non-disposable-data tripwire still must be rechecked at
stage exit and before any reset; this review does not authorize a reset.
