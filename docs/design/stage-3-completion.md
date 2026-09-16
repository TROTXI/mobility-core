# Stage 3 completion report

What the replacement backend does, what proves it, and what it still does not do.

Read this against [the stage-2 operation scope](stage-2-operation-scope.md), which
decided which operations are in the cutover, and [the stage-1 invariant
inventory](stage-1-invariants.md), which decided what behaviour must survive.

## What is claimed

The replacement in `services/api-next` implements **all 119 reviewed cutover
operations**, on a contiguous migration chain `001`–`018`, and passes the
preservation harness against the pinned baseline in compare mode.

## What is not claimed

Nothing is deployed. The blueprint entries are commented out, no schedule is
enabled, no staging database has been touched and no deployed endpoint has
changed. The service will not start at all until Apple provisioning exists, and
it refuses to start rather than run without it. Passing this gate is evidence
for a cutover decision; it is not the cutover, and it is not a claim that the
replacement has handled a real rider.

## The 119 operations

Each group names the module that implements it and the suite that exercises it.
Suites are in `services/api-next/tests`; the identifiers are the test names.

| Group                     | Operations                                                                                                                                                                                                                                                                                 | Implementation                                         | Evidence                                                                                             |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------- |
| Public bootstrap (5)      | `getRoot`, `getHealth`, `getReadiness`, `getBuild`, `getBootstrap`                                                                                                                                                                                                                         | `src/config/service.ts`                                | `config.pg` CFG-01..12; `assembly.pg` ASM-11                                                         |
| Identity, sign-in (6)     | `signInGoogle`, `signInApple`, `signInDriver`, `refreshSession`, `logoutSession`, `changeDriverPin`                                                                                                                                                                                        | `src/auth/service.ts`, `src/auth/driver-service.ts`    | `auth.pg` AUTH-01..17; `auth.test` (pure)                                                            |
| Identity, account (5)     | `getAccount`, `updateAccount`, `eraseAccount`, `listSessions`, `revokeSession`                                                                                                                                                                                                             | `src/auth/service.ts`, `src/account/service.ts`        | `auth.pg`, `account.pg` ACC-01..13                                                                   |
| Account privacy (3)       | `getAvatar`, `uploadAvatar`, `registerDevice`                                                                                                                                                                                                                                              | `src/account/service.ts`, `src/runtime/avatars.ts`     | `account.pg` ACC-*; `assembly` ASM-06..08                                                            |
| Rider money, commute (10) | `listPurchases`, `createPurchase`, `getPurchase`, `getMembership`, `listCommuteRequests`, `createCommuteRequest`, `withdrawCommuteRequest`, `listReservations`, `decideReservation`, `issuePass`                                                                                           | `src/payments/*`, `src/membership/service.ts`          | `payment-foundation.pg` FIN-_, `membership.pg` COM-_/RES-_, `pricing.pg` PRC-_, `assembly.pg` ASM-20 |
| Public catalogue (9)      | `listRoutes`, `getRoute`, `getPattern`, `getPatternVersion`, `getGeometry`, `listRouteSchedules`, `listTrips`, `getTrip`, `getLiveTrip`                                                                                                                                                    | `src/transport/catalog.ts`, `src/transport/trips.ts`   | `catalog.pg` CAT-*, `trips.pg` TRP-01..11                                                            |
| Driver (15)               | `listDriverTrips`, `startTrip`, `completeTrip`, `recordArrival`, `recordPosition`, `listDriverAvailableRoutes`, `listDriverIncidents`, `reportIncident`, `listDriverRequests`, `createDriverRequest`, `withdrawDriverRequest`, `getManifest`, `getTripSummary`, `boardRider`, `markNoShow` | `src/transport/*`, `src/boarding/service.ts`           | `transport-commands.pg` CMD-_, `gps.pg` GPS-_, `boarding.pg` BRD-01..26                              |
| Ops catalogue (14)        | `listOpsRoutes`, `createRoute`, `updateRoute`, `listOpsStops`, `createStop`, `updateStop`, `listPatterns`, `createPattern`, `listPatternVersions`, `createPatternVersion`, `getOpsPatternVersion`, `publishPatternVersion`, `listFares`, `createFare`                                      | `src/transport/catalog.ts`, `src/payments/pricing.ts`  | `catalog.pg` CAT-_/VER-_, `pricing.pg` PRC-*; `assembly.pg` ASM-16                                   |
| Ops fleet (3)             | `listOpsVehicles`, `createVehicle`, `updateVehicle`                                                                                                                                                                                                                                        | `src/transport/fleet.ts`                               | `fleet.pg` FLT-01..14                                                                                |
| Ops drivers (8)           | `listOpsDrivers`, `createDriver`, `updateDriver`, `issueDriverCredential`, `resetDriverPin`, `changeCredentialState`, `listOpsDriverRequests`, `decideDriverRequest`                                                                                                                       | `src/auth/driver-service.ts`                           | `driver-credentials.pg` DRV-01..16; `assembly.pg` ASM-14                                             |
| Ops service (7)           | `listSchedules`, `createSchedule`, `listOpsTrips`, `createTrip`, `assignTrip`, `rescheduleTrip`, `cancelTrip`                                                                                                                                                                              | `src/transport/service.ts`                             | `transport.pg` DEP-_/VER-_, `transport-commands.pg` CMD-*; `assembly.pg` ASM-16/17                   |
| Ops commute (8)           | `listOpsCommuteRequests`, `decideCommuteRequest`, `listCommuteEvents`, `listCommuteSlots`, `createCommuteSlot`, `retireCommuteSlot`, `listOpsIncidents`, `decideIncident`                                                                                                                  | `src/membership/service.ts`, `src/transport/fleet.ts`  | `membership.pg` COM-_, `fleet.pg` FLT-_                                                              |
| Ops pricing (4)           | `listPlanPricing`, `updatePlanPricing`, `listOpsPurchases`, `getOpsPurchase`                                                                                                                                                                                                               | `src/payments/pricing.ts`, `src/payments/purchases.ts` | `pricing.pg` PRC-01..08                                                                              |
| Ops configuration (7)     | `listFlags`, `setFlag`, `listMinimumVersions`, `setMinimumVersion`, `changeRole`, `createAccountRestriction`, `releaseAccountRestriction`                                                                                                                                                  | `src/config/service.ts`, `src/membership/service.ts`   | `config.pg` CFG-01..12, `membership.pg` COM-*                                                        |
| Trace holds (3)           | `listTraceHolds`, `createTraceHold`, `releaseTraceHold`                                                                                                                                                                                                                                    | `src/transport/gps.ts`                                 | `gps.pg` GPS-01..16                                                                                  |
| Payments (3)              | `receivePaystackWebhook`, `listPaymentReviews`, `resolvePaymentReview`                                                                                                                                                                                                                     | `src/payments/recovery.ts`, `src/payments/provider.ts` | `payment-recovery.pg` REC-01..16, `payment-provider.test` PROV-*; harness PAY-01..16                 |
| Maintenance (9)           | `runPayments`, `runPaymentInbox`, `runPaymentReconciliation`, `runPeriodClose`, `runAskDispatch`, `runReservationDefaults`, `runNoShows`, `runRouteLearning`, `runGpsRetention`                                                                                                            | `src/runtime/maintenance.ts` over the routes above     | `assembly.pg` ASM-12/13/18/20, `gps.pg`, `membership.pg`, `boarding.pg`                              |

Two sweeps have no reviewed operation and are deliberately not HTTP-reachable:
physical credential-secret cleanup and erasure's external retry. They run only
from the worker (`assembly.pg` ASM-14, ASM-15).

## The 13 deferred operations, still deferred

None of these is implemented, and the contract build refuses to emit one by
accident (`build-transport-contract.mjs` throws on a deferred operation).

`deleteAvatar`, `getBillingPeriod`, `listBillingPeriods`, `getCommuteRequest`,
`listCommuteAssignments`, `listCreditEntries`, `listRideEntries`,
`getDriverTrip`, `getOpsDriver`, `getOpsRoute`, `getOpsStop`, `getOpsVehicle`,
`getReservation`.

Twelve are detail reads whose list form is implemented. `deleteAvatar` is the
one deferred **mutation**: a rider can replace an avatar but cannot remove one
without closing the account. That is a product gap, not an oversight, and it is
recorded here rather than quietly filled.

## Invariants

### Payment invariants, PAY-01 to PAY-16

All sixteen pass against the replacement and compare against the pinned
baseline, in one run with the original 16-test suite also passing unchanged.
See [the harness runbook](../../tools/redesign-harness/README.md) for the
normalisations and the two fixture substitutions, each with its reason.

### Non-payment scenario groups

The stage-1 inventory lists 50 groups across seven domains. Each domain's rules
are implemented and exercised by the suite named below; the mapping is by
domain, and a group's specific expectation is the named test.

| Groups       | Domain                                                                                                     | Where it lives                                      | Evidence                                                  |
| ------------ | ---------------------------------------------------------------------------------------------------------- | --------------------------------------------------- | --------------------------------------------------------- |
| COM-01..09   | Commute transfers and pauses                                                                               | `src/membership/service.ts`, migration `013`        | `membership.pg` COM-01..21                                |
| RES-01..05   | Reservation intent and seats                                                                               | `src/membership/service.ts`, migration `013`        | `membership.pg` RES-01, RES-03, RES-04, RES-06, RES-07    |
| BRD-01..09   | Boarding and settlement                                                                                    | `src/boarding/service.ts`, migration `015`          | `boarding.pg` BRD-01..26                                  |
| TRP-01..05   | Trip state and driver actions                                                                              | `src/transport/service.ts`, migrations `001`–`005`  | `transport.pg`, `transport-commands.pg`                   |
| GPS-01..07   | Position, retention, learning                                                                              | `src/transport/gps.ts`, migration `014`             | `gps.pg` GPS-01..16                                       |
| OPS-01..05   | Incidents and driver requests                                                                              | `src/transport/fleet.ts`, migration `010`           | `fleet.pg` FLT-01..14                                     |
| ID-01..08    | Sign-in, sessions, driver lock                                                                             | `src/auth/service.ts`, `src/auth/driver-service.ts` | `auth.pg` AUTH-01..17, `driver-credentials.pg` DRV-01..16 |
| ID-09, ID-10 | Erasure scrubs without deleting accountable history, and removes the avatar, provider link and push tokens | `src/account/service.ts`, migration `017`           | `account.pg` ACC-01..13; `assembly.pg` ASM-15             |

### Target-only requirements

These were listed as unproven by the baseline and had to be established here.

| Requirement                                                        | Status           | Evidence                                                                                                                                                          |
| ------------------------------------------------------------------ | ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| OWN-01 cross-rider links fail in Postgres, including direct writes | Met              | Composite foreign keys throughout `011`–`015`; `payment-foundation.pg` FIN-_, `membership.pg` COM-_                                                               |
| VER-01 immutable published versions; explicit reassignment         | Met, fail-closed | `transport.pg` VER-_, `catalog.pg` CAT-_; `assembly.pg` ASM-16/17. A bulk reassignment command does not exist and has no contract operation — see Gaps            |
| VER-02 direction and window independent of clock inference         | Met              | `transport.pg` DEP-*, schedule `service_window` in `003`                                                                                                          |
| GPS-08 eligibility before cached live reads                        | Met              | `trips.pg` TRP-04, TRP-08                                                                                                                                         |
| GPS-09 receipt-time retention, purge/hold races, clock clamping    | Met              | `gps.pg` GPS-* and migration `014`'s deletion guard                                                                                                               |
| GPS-10 atomic latest position under real contention                | Met              | `gps.pg` GPS-* with observed blocked backends                                                                                                                     |
| GPS-11 loop projection follows traversal, not coordinates          | Met              | `trips.pg` TRP-09, TRP-10                                                                                                                                         |
| BRD-10 QR scope, capacity and close concurrency on full Postgres   | Met              | `boarding.pg` BRD-01..26                                                                                                                                          |
| ID-11 erasure across traces, holds and provider revocation         | Partly met       | `account.pg` ACC-*; `assembly.pg` ASM-15. The external half is wired and retried, and reports what it could not finish. It has never been exercised against Apple |
| ID-12 app+platform minimum build policy                            | Met server-side  | `config.pg` CFG-*; `assembly.pg` ASM-18. Both apps' upgrade flows are stage 4                                                                                     |
| API-01 scope before pagination; no cached bypass of authorization  | Met              | Signed cursors bind owner, sort and normalised filters; every list suite covers a foreign cursor                                                                  |
| API-02 old-period dispute cannot rewrite current access            | Met              | `payment-recovery.pg` REC-*; harness PAY-12, PAY-13                                                                                                               |

## Preservation result

One compare-mode run, against the pinned baseline at `43cdae0`:

- Original pinned payment suite: 16 assertions, 16 passing, none skipped.
- PAY-01..16: passed on the baseline, passed on the replacement, and compared.
- REC-01 and REC-04: passed on both. REC-02 and REC-03 passed on the baseline
  and are replaced on the candidate by REC-02R and REC-03R, which passed.
- Negative controls: detected on both sides, on their exact assertion paths.

The replacement's own suites: 32 pure checks and 267 real-Postgres checks,
none skipped.

Running the harness against the replacement found two defects in it, both
fixed: period close reported a period blocked by unsettled funded service as
failed, and batch close reported every failure as `unexpected_error`.

## Gaps, flagged rather than filled

1. **Bulk future-version reassignment.** Publication still refuses to orphan a
   non-cancelled trip, and a trip's version cannot be repointed directly. With
   the reservation coordinator composed, ops can clear affected runs
   attributably and then publish (ASM-16). A single command that moves many
   trips at once has no operation in the approved contract, not even a deferred
   one. That is a contract decision to review, not an endpoint to invent.
2. **Receipts for the two physical sweeps.** Credential-secret cleanup and
   erasure retry run under the operations account but write no receipt. There
   is no command store for them and no reviewed operation; adding one is a
   contract and schema decision.
3. **Distributed admission.** The per-user budget is process-local. More than
   one instance needs a shared one.
4. **Physical receipt expiry** for the command stores other than driver
   credentials. Logical expiry already refuses replay; deletion is not claimed.
5. **Apple provisioning.** The Services ID, team id and `.p8` do not exist. The
   service refuses to start without them.
6. **`deleteAvatar`** remains deferred, as above.
7. **Live provider traffic.** Paystack initialize, verify and webhook signing
   are implemented and unit-tested against synthetic evidence. Nothing here has
   been exercised against Paystack's sandbox from this service.

## Before a cutover

Provision the replacement database and its narrow runtime role, run the
installer once with the owner credentials, create the operations account, set
every dashboard secret, and only then uncomment the blueprint. Enable the web
service and the maintenance schedules together: retention, erasure and period
close are not optional parts of running this backend.
