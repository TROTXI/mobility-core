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
  described below. Both app roots now wire the blocking state.

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

## Commuter data and selection checkpoint

`CommuterDataClient` now uses the generated replacement operations for account,
membership, purchases, reservations, request history, route/schedule/version
catalogue and trip reads; commands cover commute submission/withdrawal,
reservation decisions and reservation-scoped passes. This is a tested data
boundary, **not yet the commuter app's composition root or screen wiring**.

- All paginated reads follow every cursor with unchanged filters. Reservations
  and purchases require explicit date bounds rather than adopting the backend's
  default window. Repeated cursors fail, never return a partial successful list.
- A generation check rejects late responses, cross-session pagination and
  requests queued during logout. Disposal leaves admission installed until
  in-flight requests settle. Already queued commands cannot leave as the next
  rider; the app root must also remove old screens on a session change.
- Random command keys survive uncertain delivery and invalid success payloads
  within the session. They are not stored on disk or derived from personal data.
  A changed intent or local identity gets a new key. A pass for the wrong
  reservation is refused while retaining the key for a safe retry.
- Generated membership models preserve simultaneous pause/dispute access blocks,
  manual renewal, nullable coverage dates, and monetary credit in minor units
  separately from ride counts. Unresolved purchases remain unresolved: the
  client does not infer fulfilment from a checkout or fabricate payment facts.
- `CommuteLegChoice` validates the selected route/pattern/version/schedule chain
  and downstream stop occurrences, including repeat visits to one physical
  stop. It uses the schedule's version, not the newest published revision.
  `buildCommuteRequest` requires explicit outbound/return legs with different
  service windows and defaults pause consent to false. These client checks do
  not replace server checks on availability, publication, price or approval.

Verification: **28 new tests; 128 shared-client tests pass; analyzer clean**.
Tests use generated serializers and the factory's real interceptor chain with
controlled HTTP. The existing CI matrix runs both new test files as part of the
whole shared-client suite. No emulator, native provider or replacement-server
walkthrough is claimed by this checkpoint. Screen migration and the catalogue
orchestration that presents these leg choices remain next.

## Commuter application migration (existing wired flows)

Branch: `codex/stage-4-commuter`, based on integration `b56fde4` (merged #319).
The commuter composition root now uses only the replacement client and scoped
storage, with explicit `API_BASE_URL` and `API_SESSION_REALM`. Installed package
build/platform metadata replaces test constants. The existing iOS Google client
configuration is unchanged. No old tokens are imported and no deployed-API
fallback exists.

- Google sign-in starts the guarded attempt before opening the native prompt.
  Account restore waits for the server rather than routing on token presence.
  Offline restore offers retry without clearing credentials. Logout and local
  identity changes replace the navigator and provider container. Bootstrap
  minimum builds and 426 responses block pushed routes as well as the home page.
- Home reservations use an explicit outbound/return choice and Accra service
  dates, not the phone's clock to guess direction. Confirmation/decline uses the
  replacement decision command; no client-generated ETA is displayed.
- Commute requests select an actual outbound departure, its version-owned pickup
  and dropoff occurrences, then a return departure in a different service window.
  Repeat visits to a physical stop remain separate choices. Schedule versions,
  including eligible retired versions, are used instead of `publishedVersionId`.
  Arbitrary time pickers are gone. Waitlist/pause consent remains explicit and
  off by default; history and withdrawal use the replacement status vocabulary.
- Passes require an explicitly chosen reservation. QR payload, expiry and code
  come from that reservation's response, never a sample PIN. Selection changes,
  expiry and backgrounding remove old proofs; late responses cannot replace a
  newer selection. Refresh is foreground-only and uncertain retries retain keys.
- Wallet reads actual membership, credit/held/available monetary balances and
  rides separately. Simultaneous pause/dispute blocks remain visible. It labels
  manual renewal and its 90-day purchase window honestly; individual purchase
  reads can refresh unresolved results. Sample card/activity and the unsupported
  auto-charge switch were removed. This is **not checkout creation**.
- Profile update, paged sessions, revocation and account erasure use replacement
  commands. Confirmation dialogs cannot act on the next rider. Only an exact
  server acknowledgement clears the matching local identity; a newer login is
  preserved. An acknowledged erasure followed by keystore failure is explicitly
  distinguished from server refusal. The UI states that private-object cleanup
  may finish later and accounting records are retained; 204 is not proof that
  external erasure has completed. Biometric lock/photo-upload placeholders do
  not pretend to enable an unimplemented feature.

Verification: **138 shared-client, 22 commuter and 188 driver tests**, analyzers,
Android debug and iOS simulator compilation. Root/session tests keep the real
interceptor and serialized store boundaries; focused picker/pass/widget tests
use controlled HTTP and remove authentication only to isolate widget timing.
No native Google session, real keystore, replacement-server walkthrough, hosted
Paystack checkout, or device security sign-off is claimed. Native builds target
the local URLs/realm shown above, not staging. Android warns about existing
Firebase plugins and `package_info_plus` using Kotlin Gradle Plugin; compilation
succeeds, but a future Flutter toolchain upgrade needs re-verification.

Catalogue limitation: a schedule exposes its version ID but not parent pattern
ID. The picker resolves it through the route's listed patterns and scoped
version reads; an unresolvable schedule fails visibly, never guesses a revision.
Future-only patterns omitted from the route's current pattern list need a
contract-backed resolution path before promising those departures in the picker.

## Commuter Paystack checkout and durable recovery

Branch: `codex/stage-4-checkout`, following merged #320. Wallet opens the
purchase/recovery screen. A new purchase reuses the explicit two-leg commute
picker, requires a plan, and takes separate consent to apply Ride Credit.
Preparing checkout creates the server purchase/hold without charging. The
rider reviews the authoritative price, credit and cash due before opening
Paystack's hosted checkout in the platform browser. There is no client price
formula, embedded payment form or provider secret.

- A random retry key and exact input are persisted **before** the first POST.
  Recovery storage is scoped to app, backend/database realm and account, using
  the same secure-storage boundary as sessions. Two controllers serialize on
  that account's journal. Restart and uncertain delivery reuse the same key and
  body; an expired key is never silently replaced.
- Recovery follows all purchase pages without date filters, including old
  pending purchases after reinstall or on another device. Local recovery data
  is not necessary to discover a server purchase. The existing API already
  supports this; its inaccurate generic seven-day/31-day date-filter description
  has been corrected in source and regenerated artifacts, not its behavior.
- A committed purchase with no provider URL retains the saved request so an
  explicit retry can recover initialization. A purchase with no local retry
  record and no usable URL needs operations; the API has no rider cancellation
  command. The screen explains this restriction before preparation.
- Only a current, payable server purchase with an unexpired HTTPS link on the
  exact `checkout.paystack.com` host offers the browser action. Opening re-reads
  the purchase and refuses changed amounts. Returning from the browser merely
  refreshes authoritative state: neither a redirect nor successful collection
  alone announces fulfilment. The user can explicitly refresh while processing.
- Logout retains the account-scoped retry journal for later recovery, but old
  controllers cannot write or send requests as the next account. Acknowledged
  account erasure drains pending journal writes and removes that account's
  recovery record. Local cleanup failure is reported as local, not as a refusal
  of server erasure. No hosted URL or card data is persisted in the journal.

This follows Paystack's [hosted checkout flow](https://paystack.com/docs/payments/accept-payments/)
and [server verification requirement](https://paystack.com/docs/payments/verify-payments/).
TEST versus live mode belongs to the backend credential; the common checkout
hostname is not proof of TEST mode. No provider secret is bundled with the app.

Verification: **151 shared-client, 27 commuter and 188 driver tests pass**.
The 13 new coordinator tests and five widget cases cover restart recovery,
uncertain delivery, account isolation, storage failure, overlapping controllers,
erasure/write ordering, old server purchases, processing versus fulfilment,
browser failure, changed amounts and unsafe links. Contract checks now number
22; both analyzers are clean. Commuter Android debug and iOS simulator builds
succeed with the explicit local replacement URL/realm. These tests use controlled
transport/storage/browser boundaries and do not claim
a hosted TEST payment, native secure-storage behavior or automatic webhook
delivery against the replacement service.

## Remaining implementation sequence

1. **Driver walkthrough:** the coherent migration above is implemented. Verify
   actual replacement sign-in, secure storage, trip lifecycle, boarding, GPS
   receipt/live reads, upgrade admission and session changes on both platforms.
2. **Commuter remaining features:** actual trip catalogue/live map with
   authorized freshness-aware reads; native avatar
   selection/upload and device registration/notification handling. Native Apple
   sign-in is not wired (the button says so). Resolve the catalogue limitation
   above. Then verify both platforms against the isolated replacement server.
3. **Canonical client and release checks:** remove unused legacy package copies
   once both apps have moved, regenerate from the reviewed contract, and verify
   both app suites and builds. Do not mix old and replacement sessions/data to
   make an incompletely migrated build appear usable.
4. **Rehearsal:** local and isolated staging walkthroughs, actual hosted Paystack
   TEST payment and automatic delivery/reconciliation, private-object erasure,
   minimum-version enforcement, and the full-size retention/load gate.

Both apps now use replacement contracts on their Stage 4 branches. This is not
completion of every commuter feature or authorization to cut over. Neither
the builds nor this document switch traffic to the replacement backend.
No emulator account, backend secret, deployment or database reset is changed.
