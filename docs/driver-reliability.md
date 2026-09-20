# Driver reliability completion

This change targets the driver app and its existing replacement backend. It
does not change commuter screens, deploy staging, introduce secrets or enable
scheduled/paid workers.

## Behaviour

- Active map and stop ETA reads refresh every five seconds while foregrounded.
  Returning to the app refreshes immediately; disposed screens stop polling.
- The signed-in shell refreshes assignments every 30 seconds and on resume.
  `assignmentChangedAt` comes from committed assignment/reschedule/cancel events.
  Vehicle registration uses the plate, falling back to the label if absent.
- Failed public configuration reads retain the last successful backend-scoped
  cache and show a retry banner. Foreground recovery retries every 30 seconds.
- GPS collection stays **while-in-use only**, and belongs to the signed-in trip
  rather than a tab. Five-second native reads support stationary buses; cached
  coordinates are never given manufactured timestamps.
- GPS fixes are saved before delivery in OS secure storage, scoped by backend
  and driver. Retries retain the original capture time and fix UUID. Only a
  matching server receipt removes a fix; a receipt not accepted for live display
  is not presented as live.
- The queue holds at most 1,440 fixes (roughly two hours at five-second cadence).
  Full/storage-error conditions are visible; unsent rows are not silently evicted
  to make room. Fixes older than 24 hours are removed on next queue access, with
  a persisted count and explicit acknowledgement notice. No background cleanup
  execution is claimed while the app is closed.
- Ending a trip first freezes capture and attempts a bounded queue flush. Failed
  delivery leaves the trip active and its fixes saved for retry. Logout/account
  switching clears private queued coordinates; logout warns about unsent fixes.
- Drivers can enable assignment alerts from Profile. Registration retries,
  account changes rotate the device token, and notification taps/foreground
  messages re-read the current roster. Push payloads contain only a generic
  schedule-change message and delivery identifier, not route/rider/driver facts.

## Backend support

Migration `026_driver_assignment_delivery.sql` extends the existing delivery
table; it creates no new worker or endpoint. The existing push worker fans out
committed assign/reschedule/cancel events to the removed and incoming drivers,
deduplicates deliveries and rechecks account, device and session eligibility.
Events older than 24 hours are not replayed as new driver alerts. Rollback and
command replay do not create duplicate events.

The worker is still **manual on staging**, as requested. Polling works without
it, but remote push delivery requires running the existing worker. No scheduling
or production configuration has been changed.

## Verification

- Driver regression suite: 201 tests passing; static analysis clean.
- Android debug APK builds after a clean build (Firebase native dependencies
  changed with the messaging plugin).
- Backend: 331 Postgres cases exercised. The first run's sole failure was the
  historical upgrade inventory missing 026; after updating that explicit
  expectation, all ten account-recovery cases pass. No required tests skipped.
- Backend unit and contract checks cover the privacy-safe FCM payload, real
  driver registration, concurrent delivery, revoked sessions, changed device
  ownership, rollback, and existing commuter prompts.
- App regressions cover live-map polling, preserved configuration and retry,
  stationary capture, stable-ID retries, trip-completion blocking, queue
  persistence/capacity/expiry, and notification registration/logout.

Not claimed: a real-device push delivery or a new native map/GPS walkthrough.
Apple push is explicitly deferred until an Apple Developer account and APNs
setup are available. It is not a blocker for this staging PR. The app reports
unavailable setup instead of claiming alerts are enabled; foreground assignment
refresh still works. Store-release signing is separate from these fixes.
