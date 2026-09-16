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

Neither app has switched API contracts in this foundation change. The current
token-storage keys are still the old unscoped keys; session isolation remains
mandatory app work, not something this document or header interceptor enforces.
No emulator account, backend secret, deployment or database reset is changed.
