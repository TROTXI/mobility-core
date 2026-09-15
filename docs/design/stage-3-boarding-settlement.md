# Stage 3 — 015 boarding and settlement

Target: `codex/backend-replacement`, not deploying `main`. Reviewed migrations
001–014 are unchanged. This slice adds six already-reviewed operations: pass
issuance, manifest, trip summary, boarding, manual no-show, and bounded no-show
maintenance. The executable contract grows from 86 to 92 operations.

## Durable outcome, not proof-as-payment

Every verification method converges on one `reservation_charges` row, linked
to the exact reservation, rider, funded period and trip. Its one ride debit is
unique by reservation. Deferred checks require charge, attendance and exact
ledger effect to commit together; a status-only or source-only settlement is
refused. Receipt, source, debit and required attendance event share the same
transaction. Auxiliary telemetry runs only after commit and may fail without
changing the result. Required financial failures do not report boarding success.

The charge's original economic reason is immutable. Late boarding changes
`no_show` to `boarded` without a second debit, ledger rewrite, or a manufactured
return/refund. No new ride-return policy or endpoint is introduced: the baseline
has a `returned` ledger reason but no implemented return command to port.

015 retains 013's complete seat/eligibility guard and changes only its terminal
attendance rule. Existing identity/funding fields and an established settlement
timestamp remain immutable. Funding/receipt ownership and a nonnegative ride
balance are checked in PostgreSQL as well as the service. A populated 014
database with legitimate pending/funded reservations upgrades without rewriting
them. An experimental pre-015 boarded/no-show history cannot be attributed
soundly; the migration locks first and refuses it rather than guessing charges.

Lock order is authenticated actor/session, command retry lock, then affected
rider → funded period → trip → reservation. Initial driver ownership lookup is
nonlocking; assignment is rechecked after obtaining the trip lock. Rider pass
issuance locks only its authenticated own-user before session authorization,
matching the established identity/financial ordering. Erasure, restrictions,
disputes, cancellation and period changes are rechecked from database facts.

## Proofs and privacy

- QR tokens have a 60-second lifetime, bounded five-second verification leeway,
  dedicated audience/issuer/algorithm, and explicit rider/reservation/trip claims.
  They are not API access tokens. Signing requires a dedicated 32-byte key.
- Four-character fallback codes are keyed, stable for one reservation/trip,
  case-insensitive and searched only within the assigned driver's bounded run.
  Collisions refuse rather than choose a rider. No code/token is stored in a
  receipt; even the input digest is HMAC to prevent offline code enumeration.
- The code attempt budget is 30 per driver/trip per fifteen minutes, including
  failed attempts. Its authorized admission transaction commits independently
  of proof rejection. The photo fallback remains available after code throttling.
- QR reuse is durable in PostgreSQL; there is no Redis/KV dependency to fail.
  The BRD-08 cache-outage availability intent is preserved by removing that
  dependency, not by pretending that database settlement can fail open.
  Same-key retry replays its result; a fresh key with a consumed QR is refused.
  A newly issued QR for an already charged seat never charges it again.
- Manifests are assigned-driver-only, complete (never silently truncated),
  short-lived and contain only approved display fields. Avatars are signed from
  server-stored object keys, never accepted from a pass. Object keys are omitted.
- Summaries count durable attendance and distinct reservations by verification
  method, not failed scan attempts or duplicated HTTP deliveries.

## Integration and remaining work

Configure `BoardingService` with the same runtime pool and current-session
authorizer as membership/identity and provide the private-avatar signer. An
unconfigured app does not register these routes. Confirmation may continue to
return `pass: null`; the rider obtains/refreshes a pass through the explicit
`issuePass` operation. This keeps fresh credentials out of membership receipts.

No-show maintenance is explicitly scoped to business date, direction and
optional route, bounded to 100 candidates. It rechecks authorization and state
per item; future departures, cancelled/ineligible seats and already-settled
reservations are not charged. The operation is on-demand here. No cron, device
build, staging deployment, production key or external Paystack request is enabled.

Remaining stage-3 boundaries include authoritative pricing and purchase HTTP
composition, account/privacy/device/configuration endpoints, commuter map reads,
worker and listener composition, and the full pinned-baseline/candidate harness.
These local Postgres tests are not a claim that stage 3 or cutover is complete.

## Verification for review

The combined replacement suite passes 211 Postgres tests with none skipped,
including 26 boarding cases. The unit suite passes 23 tests and the design
contract suite passes 21. Typecheck, build, formatting and artifact regeneration
also pass. These are local results; GitHub checks remain a separate gate.

The stage-1 BRD invariants are covered as follows (case names below are in
`boarding.pg.test.ts`, not a renumbering of the original invariant inventory):

| Stage-1 rule                                                      | Replacement evidence                                                                                          |
| ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| BRD-01–03: one charge, fresh proof, late attendance               | Cases 01–03 and observed three-way contention in 10                                                           |
| BRD-04: bounded no-show scope                                     | Cases 14, 22 and 25; future/other-direction/other-route and unfunded exclusions                               |
| BRD-05–07: scoped proof, manifest ownership, distinct credentials | Cases 04–07, 16 and 24; key separation in BRD-U01                                                             |
| BRD-08–09: auxiliary availability, durable financial outcome      | Case 08/09 removes the cache dependency and injects auxiliary failure; case 11 proves required-write rollback |

Additional target-only checks cover SQL settlement completeness, immutable
attribution, no debit without its source, period-close/refund contention,
restriction/dispute/cancellation/erasure invalidation, and the populated upgrade.
Concurrency cases wait for blocked database sessions before releasing the lock;
`Promise.all` alone is not the contention evidence. The HTTP domain fixtures use
the established test session adapter; BRD-U02 separately exercises the real app
composition's unauthenticated refusal. This is not yet the full two-database
preservation comparison or a physical-device boarding walkthrough.

The initial CodeQL run flagged client-selected QR verification. The resolver
dispatch now explicitly separates the three supported evidence methods from
mandatory session/driver authorization. Strict variant validation also applies
to direct service callers: QR cannot smuggle a photo reservation field and a
photo decision cannot carry an unchecked token. BRD-27 covers malformed/mixed
variants and foreign-driver refusal for each legitimate variant. There is no
CodeQL suppression or lowered gate threshold.
The resolver registry is a closed `Map`, not a dynamic object-method lookup;
unknown/inherited names cannot resolve to executable handlers. BRD-27 includes
`constructor` and `__proto__` rejection. Both follow-up changes retain the full
211-test Postgres result.
