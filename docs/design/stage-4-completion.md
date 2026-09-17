# Stage 4 completion: existing app flows and replacement requirements

Owner: Codex. Scope confirmed by Godfred: finish what the old apps actually did
and what the replacement model requires; hand new frontend features over
separately. This is implementation completion, **not deployment approval**.

## Delivered

The implementation record is `stage-4-progress.md`; this is its exit summary.

| Surface                 | Replacement implementation                                                                                                                                           |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Driver access           | PIN sign-in/change, guarded session restore, local-first logout, offline refresh preservation, account switching, blocking minimum-build admission                   |
| Driver operations       | Assigned trips, readiness/start/arrival/complete, reservation-based manifest and QR/code/photo boarding, incidents and work requests                                 |
| Driver location         | Foreground-only capture, stable fix identity and receipt confirmation, trip-owned geometry and occurrence IDs, labelled live/stale/fallback data                     |
| Commuter access/profile | Google sign-in, guarded restore/logout, profile name and existing avatar display, sessions/revocation, account erasure, blocking minimum-build admission             |
| Commuter membership     | Explicit outbound/return departures and version-owned stops, commute requests/history/withdrawal, reservation decisions, selected-reservation QR/code passes         |
| Commuter money          | Membership and separate ride/credit balances, Paystack hosted checkout, durable retry journal and server-side purchase discovery/recovery; no auto-charge assumption |
| Commuter trips          | Paged service-date catalogue and authorized bus tracking; configured Ghana/R2 basemap, driver position only, no commuter location permission or collection           |
| Shared contract         | Required client metadata, pagination, command keys/edit tokens, stable errors, session-generation guards and secure storage scoped to app/backend/database realm     |

### Final catalogue correction

`Schedule`, `Trip`, `DriverTrip` and `OpsTrip` now expose `patternId`, derived
from their database ownership chain, alongside the immutable `patternVersionId`.
No migration or new operation is needed. The picker and both maps use that
explicit owner rather than searching today's `Route.patternIds`. Pattern reads
allow published future and retired owners on unarchived corridors; draft-only
owners remain hidden. `publishedVersionId` still means current and may be null.
The optional current-route label cannot hide a trip's exact stop occurrences.

CAT-16 exercises a future owner absent from the current route projection,
schedule/create-trip/public-trip serialization, exact version resolution,
draft refusal and retired-owner lookup. Restoring the old current-only lookup
makes this test fail with **404 instead of 200** at the owner read. Client
regressions cover missing current links, mismatched schedule ownership and
trip-owned stops surviving an unavailable current route label.

### One canonical client

- `apps/api_client` / `trotxi_api_client`: generated replacement SDK.
- `apps/trotxi_client` / `trotxi_client`: shared handwritten client used by both apps.
- Removed the unused legacy clients and temporary `_next` package paths. They
  remain recoverable in Git; no deployed backend or stored account was removed.
- `pnpm codegen` delegates to `codegen:replacement`, using only the checked-in
  `replacement.openapi.json`. It cannot overwrite the SDK from old staging.
- Both apps and the shared package remain in the Flutter CI matrix. Contract
  tests pin their canonical dependencies and offline code-generation source.
- The rename does not change token/journal storage namespaces, backend URLs,
  database realms, native Google configuration or application bundle IDs.

## Frontend handoff, not migration blockers

Checked against old `main` at `1a46ad0`:

| Follow-up                                                      | What the old commuter actually implemented                                                                                                  |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Native avatar selection/upload                                 | `personal_info.dart::_onChangePhoto` was a TODO/debug print. Existing avatar display is retained.                                           |
| Push token registration, delivery and notification preferences | `profile_notification.dart` toggles were local-only, with no persisted preference or native push integration.                               |
| Native Apple sign-in                                           | `onboard_page.dart::_signInWithApple` was a pending-implementation debug print. The replacement button explicitly states it is unavailable. |
| Biometric app lock and other new UI polish                     | Not an implemented security boundary; do not count a placeholder toggle as protection.                                                      |

The backend having avatar/device/Apple endpoints does not mean the old mobile
features existed. Frontend can complete these separately, using the replacement
contracts. Notification preference semantics still need an agreed backend
contract; registering a push device does not by itself persist alert choices.
Unimplemented controls must not be represented as working launch features.

## Verification boundary and remaining release work

Local verification on this branch:

- **285 Postgres, 34 backend unit and 24 contract checks**, none skipped.
- **167 shared-client, 35 commuter and 188 driver tests**; all three analyzers clean.
- Android debug and iOS simulator compilation for both apps with explicit local
  replacement URLs/realm; no staging fallback.
- Contract emission, canonical SDK generation and serializer rebuild reproduce
  the staged artifacts without drift. No migration bytes changed.
- The first full Postgres run exposed ASM-22 assuming all six requests fall in
  one wall-clock minute. Its fixture now observes the database window, requires
  six alternating requests in one window within a bounded attempt count, checks
  the shared counter after each request and still requires exactly four 200s
  followed by two 429s. No production admission behavior changed. The full rerun
  passes all 285 cases; the initial failure is not treated as successful evidence.

Automated app tests use real generated serializers with controlled HTTP/storage.
Native compilation is not a successful login or a delivered GPS fix. No native
provider login, R2 annotation rendering or hosted checkout is claimed here.

Before switching traffic:

1. **Stage 5:** walk both apps against the isolated assembled replacement on
   Android/iOS; exercise real secure storage, Google sign-in, boarding, GPS and
   map delivery, minimum-build refusal, hosted Paystack **TEST** automatic
   delivery/reconciliation, private-object cleanup and the full-size retention
   load gate. These are release verification, not new frontend screen work.
2. **Stage 6:** select the replacement migrator/database/runtime role/service in
   deployment automation; recheck the zero-real-user/data tripwire; obtain exact
   disposable-database approval; rehearse abort before/after external writes;
   coordinate backend and app release. The old deployment workflow must not be
   pointed at the replacement database.

Main, staging, secrets, Paystack settings and databases are unchanged by this
branch. No provider payment or deployment has been performed.
