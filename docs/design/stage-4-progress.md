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
  transport coverage, **not an implemented app-level upgrade screen**.

Local verification: **44 shared-client tests passed**, `flutter analyze --no-pub`
reported no issues. Metadata assertions run outside the transport adapter so a
test assertion cannot be wrapped as an expected offline failure.

## Driver session boundary (implemented, not yet wired into the app)

`apps/trotxi_client_next/lib/driver_session_client.dart` uses the generated
replacement sign-in, account, logout and PIN-change operations. It deliberately
does not accept the old flat sign-in payload or substitute an account ID for a
fleet driver ID. An account-only restore leaves fleet ID, driver code and the
credential-change flag unknown. Offline/upgrade errors are not swallowed as a
signed-out result. PIN changes require a caller-owned retry key; PIN values are
not persisted or derived into that key.

`ScopedTokenStore` supplies the secure-storage implementation for the eventual
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

Repository reconnaissance for the next driver slice is complete. Preserve the
replacement identities rather than translating requests back to legacy shapes:
trip-owned stop occurrences (not a route-wide integer), service date/direction,
per-row edit tokens, cursor pages, position fix IDs/capture time/acceptance, and
reservation IDs in boarding results. Manifest reads no longer disclose a rider
user ID or the old source/morning-evening labels; UI mappings must not invent
those fields. Route geometry is available through the version's geometry ID.

## Remaining implementation sequence

1. **Driver app, as one coherent replacement build:** isolate stored sessions
   by backend generation/environment; attach actual app build/platform; port
   sign-in/session/config, trips/occurrences, GPS receipts, manifest/boarding,
   incidents and work requests. Wire a blocking upgrade state without inventing
   unrelated screen designs. Keep existing domain/widget regression behavior.
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

Neither app has switched API contracts yet. Their composition roots still use
the old unscoped token stores. The new scoped store/session client is implemented
and tested but not wired into those roots; that wiring must land together with
the coherent repository migration, not as a mixed old/new app build.
No emulator account, backend secret, deployment or database reset is changed.
