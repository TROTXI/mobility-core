# Stage 4 progress

Owner: Codex alone, as requested. Base: integration merge `b606ef3` (PR #318,
all 16 checks green). Main and staging are unchanged.

## Shared-client foundation

Branch: `codex/stage-4-client-foundation`.

- Replacement metadata is validated in release code, not only assertions.
  The interceptor owns client/build/platform headers and removes incompatible
  request-level values, including case variants.
- Refresh metadata is checked independently of the normal interceptor; generated
  headers are compared case-insensitively and build values by their wire text.
- Sign-in recognition uses exact endpoint paths. An unrelated resource whose
  name contains `auth/driver` does not bypass refresh.
- Business errors preserve the server's stable code and message for app decisions.
  Social sign-in failures no longer tell a commuter to check a driver PIN or
  assume every 403 means driver suspension.
- A 426 upgrade response never refreshes or deletes the session. This is client
  transport coverage; the driver now also wires the blocking app-level state
  described below. The commuter has not yet moved.

Local verification: **44 shared-client tests passed**, `flutter analyze --no-pub`
reported no issues. Metadata assertions run outside the transport adapter so a
test assertion cannot be wrapped as an expected offline failure.

## Driver session boundary (wired into the driver app)

`apps/trotxi_client_next/lib/driver_session_client.dart` uses the generated
replacement sign-in, account, logout and PIN-change operations. It deliberately
does not accept the old flat sign-in payload or substitute an account ID for a
fleet driver ID. An account-only restore leaves fleet ID, driver code and the
credential-change flag unknown. Offline/upgrade errors are not swallowed as a
signed-out result. PIN changes require a caller-owned retry key; PIN values are
not persisted or derived into that key.

`ScopedTokenStore` supplies the secure-storage implementation for the driver
composition root, shared by all its repositories and HTTP clients:

- One record holds both tokens, namespaced by app, replacement generation,
  canonical backend URL and an explicit database realm. No old unscoped token
  is read/imported, and neither build upgrades nor URL spelling changes reset
  a session. A disposable database reset must choose a new realm.
- The refresh interceptor uses conditional rotation and clearing inside the
  store's serialization boundary. A separate asynchronous read then write is
  not sufficient when a new login can arrive between them.
- Local logout removes credentials before network I/O; its detached public
  request cannot refresh or clear the next login. Failure reports no remote
  acknowledgement. A corrupt record can still be explicitly discarded.
- Generation and attempt guards cover delayed sign-in/account responses,
  including logout/new sign-in **during** a pending storage write. Storage
  failures do not poison the queue or falsely announce successful clearing.

Verification: **81 shared-client tests passed**, including 37 new session/store
cases; `flutter analyze --no-pub` clean. Tests exercise actual generated
serializers and the factory's interceptor chain with controlled HTTP/storage
boundaries. They do **not** prove native keychain/keystore behavior on a device
or sign-in against the replacement server. The existing Flutter CI matrix
already runs the whole `trotxi_client_next` suite, so these files are not a
separate, unregistered test command.

## Driver application migration

The driver composition root now uses only the replacement client and scoped
storage. Startup requires `API_BASE_URL` and `API_SESSION_REALM`; the platform
and build metadata come from the installed package, not a test constant. No
deployed-API fallback or old-token import is present.

- Sign-in, account restore, local-first logout and configuration use replacement
  shapes. Storage failure is visible and retryable rather than silently erasing
  a session. Late responses cannot restore the previous driver's identity.
- An explicit 426, including from refresh, or an applicable bootstrap build
  floor blocks the navigator and stops GPS publishing. Back cannot dismiss it.
  Clearing the session removes pushed screens from the previous driver.
- Assigned trips follow every cursor with the original filters. The agenda
  groups by stored service date, including midnight delays. Arrivals carry
  trip-owned occurrence IDs and the edit token the driver actually viewed;
  stale writes are not automatically retried with a new token. Backward arrival
  correction requires explicit confirmation.
- Manifest and boarding use reservation identities, QR/code/photo proofs and
  replacement no-show/summary responses. Run-wide code results identify the
  boarded seat; a previously selected rider is not assumed to be that person.
- GPS submissions carry fix IDs, capture timestamps and accuracy, and only a
  matching receipt accepted for live projection confirms live sharing. Existing
  foreground-only collection and readiness permission gates remain.
- Maps use the assigned trip's pattern version and occurrence identities,
  never the newest route revision. Live reads preserve observed/fallback basis
  and server freshness; predictions disappear locally after 120 seconds. This
  does not add continuous map polling or prove live delivery on a device.
- Incident and work-request repositories send the reviewed unions and dates.
  Uncertain command delivery retains a random retry key within the session.
  There is no durable offline command queue; after restart, reload authoritative
  state rather than assuming the previous command was never received.

Contract limits remain visible: vehicle labels are not asserted to be plates;
capacity, reservation-source breakdowns and assignment-change timestamps are
not served, so this app does not manufacture them. No new backend fields or
Figma layouts were introduced for these gaps.

Verification at this checkpoint: **188 driver tests and 81 shared-client tests
passed**, both analyzers report no issues, and Android debug/iOS simulator
builds succeed. Tests use real generated serializers with controlled
transport/storage; they do not replace the pending replacement-server and
native-device walkthrough. The two final regressions cover stored service-day
grouping across midnight and assigned-trip refresh without a public archived
route lookup. Boarding refusals preserve eligibility/funding messages rather
than claiming an existing reservation is absent.

Local build configuration (requires a separately running replacement server):

```sh
# Android emulator
flutter build apk --debug --target-platform android-x64 \
  --dart-define=API_BASE_URL=http://10.0.2.2:3001 \
  --dart-define=API_SESSION_REALM=local-replacement-stage4
# iOS simulator
flutter build ios --simulator --debug \
  --dart-define=API_BASE_URL=http://127.0.0.1:3001 \
  --dart-define=API_SESSION_REALM=local-replacement-stage4
```

Use a new realm after replacing the disposable database. Simulator compilation
is not device sign-off, store compliance, or a staging cutover.

## Commuter session foundation (not wired into the app yet)

Work continues on `codex/stage-4-commuter`. `CommuterSessionClient` now exchanges
Google and Apple provider credentials through the generated replacement
operations, accepts only a commuter account, restores account identity, and
performs local-first logout with independent remote acknowledgement. Provider
proofs are transient and never written into session storage.

The attempt starts before opening the native provider prompt: logout while that
prompt is open prevents even a late token exchange. Tests also cover backend
responses and OS writes arriving after logout/new sign-in, failed storage,
wrong roles, old response envelopes, offline restore, authoritative refresh
rejection and remote logout failure. **19 new tests; 100 shared tests pass;
shared analyzer clean.** This is not native Google/Apple SDK or device evidence.

The commuter app intentionally still uses its existing client until the rest
of its repositories and screens can move coherently. In particular:

- `home_page_provider.dart` currently selects a reservation by device-local
  morning/evening. Replacement selection must use explicit service day,
  direction, reservation and trip identities, with full pagination.
- `commuter_preference.dart` currently selects physical stops and times. It
  needs schedule/version/occurrence selection for both commute legs, not a
  mechanical field rename. Request history must use the new envelopes/statuses.
- `pass_tab.dart` currently requests an unscoped pass with a relative TTL. The
  replacement pass is reservation-scoped and expiry must come from its contract.
- `wallet_tab.dart` contains a sample Visa card, sample credit activity and a
  local auto-renew toggle. These are not backend capabilities or real account
  facts: remove the samples from the integrated account view rather than
  presenting them as the rider's payment method/history/settings.
- Profile, sessions and erasure still call old endpoints. Account updates,
  session revocation, erasure acknowledgement and external-resource completion
  must remain distinct; clearing local tokens is not proof of completed erasure.

The existing iOS Google configuration fix stays intact. No commuter location
permission/collection is introduced, and Apple SDK/store setup is not claimed
complete merely because the server token exchange can be tested.

## Remaining implementation sequence

1. **Driver walkthrough:** the coherent migration above is implemented. Verify
   actual replacement sign-in, secure storage, trip lifecycle, boarding, GPS
   receipt/live reads, upgrade admission and session changes on both platforms.
2. **Commuter app:** same session/build isolation, then account/paged reads,
   explicit outbound/return schedule/version/stop-occurrence selection,
   purchases and pending-payment recovery, membership/pause/commute requests,
   reservations/pass/live map and account/device/avatar/erasure flows.
3. **Canonical client and release checks:** remove unused legacy package copies
   once both apps have moved, regenerate from the reviewed contract, and verify
   both app suites and builds. Do not mix old and replacement sessions/data to
   make an incompletely migrated build appear usable.
4. **Rehearsal:** local and isolated staging walkthroughs, actual hosted Paystack
   TEST payment and automatic delivery/reconciliation, private-object erasure,
   minimum-version enforcement, and the full-size retention/load gate.

The driver has switched on this branch only. The commuter still uses the old
contract and unscoped store; it must move coherently before cutover. Neither
the driver builds nor this document switch traffic to the replacement backend.
No emulator account, backend secret, deployment or database reset is changed.
