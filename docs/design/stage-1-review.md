# Stage 1 review package

Status: technical design ready for review; **not approval to implement or cut over**.
PR #293 remains draft. Baseline runtime source: `43cdae0`. No runtime module,
migration, deployed configuration, generated app client or database was changed.

## Read in this order

1. [Database model](database-redesign-proposal.md): authoritative domain ownership.
2. [Payment invariants](database-redesign-invariants.md) and
   [50 non-payment scenario groups](stage-1-invariants.md): evidence and limits.
3. [103 current endpoint mappings](stage-1-endpoints.md): every documented local
   operation mapped; Swagger/metrics/CORS infrastructure accounted separately.
4. [Access and GPS decisions](stage-1-access-and-gps.md): eligibility, retry,
   bootstrap, retention, storage choice and engineering defaults for review.
5. [Executable target OpenAPI](contracts/target.openapi.json), generated from
   [named Zod schemas and operations](contracts/target-contract.mjs): 132 proposed
   operations, including target-only versioned route/schedule/hold/review resources.
   [Validated examples](contracts/examples.json) show absence, pause+dispute,
   missing GPS, boarding and conflict shapes. No staging URL or secrets included.

The JSON is generated review material. Edit the Zod/catalog source, not 20,000
lines of emitted schemas. Field/schema validation does not implement eligibility,
financial atomicity, entitlement or retention. The access document identifies
those cross-field/database requirements explicitly.

## What is now decided versus proposed

Already approved: clean replacement; no legacy aliases/dual writes; period-scoped
historical disputes by default; public map/restricted live coordinates; explicit
reassignment on removed stops; 30-day raw GPS retention from receipt; narrowly
scoped incident holds. Adom and ops availability is **not** a blocker to this
backend design/harness work, as directed by Godfred.

New engineering choices submitted in this package for Claude/product review:

- Live eligibility matrix, including unbooked eligible corridor members and
  funded trips that cross their coverage end. Do not call this previously agreed.
- Stable `/flags` and per-app/platform build floors; 426 unsupported build and
  safe refusal before mutation. #40 is a real-user release gate, not a blocker
  to reinstalling disposable staging test apps.
- 120-second maximum positive capture skew, clamped effective capture; 24-hour
  upload/collection bound; 30-second live and 120-second ETA freshness cutoffs.
- Indexed bounded purge initially, with an explicit 13M-row prelaunch load gate;
  partitioning is the documented alternative if the gate fails, not assumed free.
- Seven-day ordinary command replay storage, shorter encrypted secret replay,
  complete 500-row/15-minute read-only offline manifest, bounded list windows.
- No-show/boarding cache/audit fail-open behavior remains separate from durable
  financial success; a database failure still returns 503.

These are proposed contract defaults, not deployment changes. The only confirmed
routine GPS purpose is route/ETA learning. “Recent operational diagnosis” is
not treated as a separately approved justification. Backup retention enforcement
must be verified with the provider before any full-deletion claim.

## Entity-to-rule and transaction checklist

| Model boundary                                                         | Requirement / invariants                          | Storage and transaction requirements                                                                                                                                                |
| ---------------------------------------------------------------------- | ------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| User, provider identity, session, driver credential                    | ID-01–10; existing social/driver auth and erasure | Unique provider+subject and linked driver/user; hashed credentials; refresh-family transaction; scrub without cascading money/history                                               |
| Membership, purchase, attempt, period                                  | PAY-01–16, OWN-01                                 | One unresolved purchase per rider; immutable agreed terms; unique period.purchase; constrained rider ownership; no editable reverse current-period pointer                          |
| Period adjustments/pauses, access blocks                               | COM-03/06, API-02                                 | Pause consent and elapsed extension; independent block scope/source; clearing one block cannot clear another                                                                        |
| Ride/credit entries, holds, period closure                             | PAY concurrency/refund rules, BRD-01–04           | Typed source FKs; one source mutation; credit hold <= available; row/advisory locks; allocation/settlement/close rollback; no conversion counted as consumption                     |
| Refunds, disputes, reversal review                                     | PAY-10–16, API-02                                 | Provider identity/environment, monotonic events, exact-once reversal/credit restoration, old-period attribution; review decisions do not collect money                              |
| Route, directional pattern/version, stop occurrence, geometry revision | VER-01/02, TRP-04/05, GPS-04–07/10/11             | Published definitions immutable; stops/progress belong to version; geometry+distances same revision; no cascade deletion of operated history; loops need traversal-aware algorithm  |
| Schedule, commute assignment/legs/request/slot/events                  | COM-01–09, VER-02                                 | Effective intervals; one leg each direction; ordered version stops; one open request; last-slot and apply lock; different fares/unsettled trips block; keep original purchase terms |
| Trip, assignment history, reservation/charge                           | RES-01–05, BRD-01–10, TRP-01–05                   | One actionable rider/date/direction; route/version/owner funding checks; capacity + charge concurrency; current assignment at action; cancellation settles dependent records        |
| Raw fixes, latest projection, learned results, incident holds          | GPS-01–11                                         | Stable fix uniqueness independent of receipt; monotonic latest; 30-day expiry and hold race; no consumer GPS; no anonymous-by-removing-ID assumption                                |
| Incident, driver request, ops decision                                 | OPS-01–05                                         | Own driver scope; no forced trip on yard report; decision does not reassign fleet; append audit and prevent overwrites                                                              |
| Bootstrap/config, scoped maintenance                                   | ID-12, API-01, PAY-08                             | App+platform version key; worker audience/allowlist; bounded jobs; unsafe aliases removed; no silent successful no-op when persistence is absent                                    |

No operator payout engine, automatic collection mandate, generalized tenancy,
new fare products or standby marketplace is introduced. Existing plans remain
monthly/annual; pricing remains integer basis points and pesewas. A single
application owns domain transactions; database constraints enforce identity and
ownership, not duplicated independently implemented state machines.

## Material changes from current contracts

- All 103 current documented operations are accounted for. Consolidated boarding
  requires explicit trip/reservation scope; period-close aliases become one safe
  operation. Replacement paths intentionally break the old clients at cutover.
- Public catalog maps corridor → pattern → published version → geometry, with
  route schedules discoverable without exposing ops-only data. Stop IDs are not
  reused as occurrence IDs; published versions do not mutate in place.
- Responses compose user tasks, not database tables. Rider and ops schemas are
  distinct. Pause and dispute remain simultaneously representable; lapsed and
  never-subscribed differ; renewal is manual, not a promised auto-debit date.
- GPS payload collision returns 409 instead of silently ignoring a changed
  payload with the same fix ID. Future effective time cannot pin the live marker.
- Restricted live location and supported-client checks are target-only guarantees,
  not claims that the current implementation already enforces them.
- New ops restriction/trace-hold/review-decision endpoints implement approved
  scoped exceptions; no arbitrary payment status or ledger mutation is exposed.

## Validation and honest limits

Stage-1 tests validate reference completeness, schema emission, examples, bounded
typed inputs and declaration of auth/retry headers. Existing non-PG suites can
be rerun independently. Baseline PG evidence is reviewed from source, not
claimed newly exercised unless a run is separately reported. No replacement
adapter exists yet; there is no differential-harness success to claim.

Commands (Node 24 on PATH, workspace dependencies already installed):

```sh
node --import ./services/api/node_modules/tsx/dist/loader.mjs docs/design/scripts/export-baseline.mjs
node docs/design/scripts/build-invariants.mjs
node docs/design/scripts/build-contract.mjs
node --test docs/design/scripts/contract.test.mjs
java -jar node_modules/@openapitools/openapi-generator-cli/versions/7.23.0.jar validate -i docs/design/contracts/target.openapi.json
```

Exporting baseline uses buildApp with in-memory defaults and injection-free schema
inspection: no server listen, Paystack call or external database. It records the
baseline operation index and full-spec SHA-256, not generated Dart leftovers.
It refuses to label changed runtime source as the frozen baseline. Test evidence
is read directly from pinned Git objects, so later test rewrites cannot silently
move the historical references. Rebuild all artifacts after source
changes and verify no generated diff. The original 16 payment references remain
pinned to 43cdae0, not rewritten to match the target schema.

Verification on this branch: 252 existing non-PG tests passed across 23 selected
suites; 13 design-contract checks passed. OpenAPI Generator 7.23.0 validation
passed with one non-blocking unused `Coverage` component recommendation (nullable
OpenAPI 3.0 wrappers inline that shape). No Postgres suite was rerun for this
design-only change. CI now regenerates the design artifacts, checks drift and
runs the contract checks; that job has no credentials or deployment step.

## Next: implementation breakdown, not another design cycle

Backend responsibility remains Godfred, with Codex implementing and testing under
review. Frontend and ops continue independently; their readiness is checked for
end-to-end rehearsal/cutover, not used to defer harness construction.

| Work package after review                  | Exit evidence                                                                                                           | Initial effort range         |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| Stage 2 baseline harness                   | 16 payment + non-payment scenario adapters, isolated Postgres, explicit locks/faults, negative controls, fail-closed CI | 3–5 focused engineering days |
| Transport/GPS replacement                  | Versioned transport/assignment constraints, ingestion/learning, retention/hold tests and sizing gate                    | 4–6 days                     |
| Membership/purchase/accounting replacement | Full PG preservation and target ownership/refund/dispute tests; inbox/reconciliation                                    | 5–8 days                     |
| Commute/boarding/auth/config integration   | Full-schema capacity/close/transfer races, scoped endpoints, compatibility checks                                       | 3–5 days                     |
| Backend rehearsal and cutover tooling      | Reproducible clean install, seeds, replay/quarantine, runbook and recovery checks                                       | 3–5 days                     |

Total planning range: **18–29 focused backend engineering days**, not a calendar
promise or continuous-agent schedule. This excludes app/ops implementation time,
external review waits and any new product scope. Revise using actual throughput
at the end of stage 2; do not treat AI token speed as delivery capacity. The
estimate identifies work rather than assuming Kojo/Senanu availability.

Review acceptance: approve or amend the engineering choices above, confirm
coverage of the model/endpoint inventory and authorize stage 2. Stage 2 must
pass before target business-schema implementation. The zero-real-user tripwire
still applies before onboarding, real payments or retaining non-disposable data.
