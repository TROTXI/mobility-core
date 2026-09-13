# Driver simulator walkthrough — 2026-09-13

## Scope

Full Flutter driver app, disposable fixtures, real API code with in-memory
repositories on loopback (Android port 3089; iOS port 3088). These results are
not staging, production, physical-device, database-persistence, or background
location verification. No map-tile configuration was supplied to these APIs.

Base: main `f643407`, including the merged removal of forced PIN setup (#259).
Fix branch: `codex/driver-walkthrough-fixes`.

## Android observations before the fixes

| Flow                                 | Observed result                                                                                                                                       |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| Today → pre-trip → readiness → start | Explicit start reaches API; trip becomes active. Location/camera already granted in this pass.                                                        |
| Code boarding                        | First disposable rider boards; repeating the code returns Already boarded. API and manifest remain at one boarding.                                   |
| Manifest boarding                    | Second rider boards from manifest. API reports two boarded: one PIN and one photo/manifest.                                                           |
| Native GPS                           | Emulator fix reaches the API, including the simulated Accra location. This does not prove background or offline delivery.                             |
| Stop arrivals                        | Defect: Circle displayed first but sent sequence 1 (API's second stop). Last displayed stop sent 5 and returned Not Found; actual last sequence is 4. |
| Completion                           | All four checks required. Completion reaches API; Today shows Done and Scan is disabled.                                                              |
| Summary                              | Correct boarded/not-boarded totals; photo/manifest method missing. Final-GPS-save promise unsupported: stored fix predates completion.                |
| Schedule                             | Selected following day shows its two assigned runs.                                                                                                   |
| Work requests                        | No routes accepting requests is shown and send is disabled. Disposable one-day leave request creates Waiting, then withdrawal shows Withdrawn.        |
| Incident/support                     | Missing operator/emergency numbers are stated explicitly. Disposable vehicle incident submitted without an active trip; My reports shows Sent.        |

The fixtures have no rider photos. Manifest boarding still permits boarding
without one. Whether that is an acceptable identification fallback needs a
product/operations decision; this patch does not silently change that rule.

## Fix batch

- Preserve and sort actual route stop sequences in `DriverStop`. Derive the
  one-based display number independently. Use server sequences for arrivals and
  ETA matching, and display ordinals for names, progress and completion labels.
- A subsequent iOS recheck exposed the matching backend gap: the HTTP arrival
  validator and migration 036's constraint rejected sequence zero. The validator
  now accepts zero and migration 042 widens the constraint forward-only. Earlier
  migrations are unchanged. Deploy 042 and the API before the updated app.
- Match the next-stop name to the same API ETA and navigation target.
- Multi-hour lateness uses hours and minutes instead of hundreds of minutes.
- Include photo/manifest boarding counts in the completion summary.
- Remove statements promising that completion saves a final GPS fix; it does
  not perform that operation.
- Failed completion stays on the checklist with an error and permits retry,
  rather than navigating to a success summary. A successful completion remains
  completed even if the following detail refresh fails.
- Move foreground location ownership from RunPage to the signed-in active trip;
  show live only for a recent, matching API receipt. Stop on background/sign-out
  and protect against stale responses. No durable offline queue is implemented.

Regression coverage includes zero-based, one-based and gapped sequences,
generated-client route/arrival serialization, all three boarding methods,
light/dark summary rendering, and multi-hour lateness.

Final checks for this batch: 144 driver tests passed; app-source analysis and
`git diff --check` were clean; 31 targeted API tests, API typecheck and targeted
ESLint passed. The forward migration test passed on real local PostgreSQL using
only a transaction-scoped temporary table. Full staging migrations were not run.

Unscoped local analysis also scans generated iOS
dependency example projects under `build/ios/SourcePackages` and reports their
missing dependencies; that is not an app-source analysis result.

Targeted iOS GPS recheck after the user's walkthrough: the API received a new
simulator fix on Today and a second fix on Manifest. A changed coordinate while
backgrounded did not replace the saved fix; returning to Manifest resumed
delivery. The Trip screen displayed the acknowledged-location label. This is
an iOS simulator/local-API check, not physical-device certification.

## Remaining walkthrough work

- Re-run the corrected first and final stop taps and completion summary on
  Android. The Mac locked before post-fix interactive verification.
- The user reported their walkthrough complete. Targeted iOS checks above are
  independently verified; unobserved parts of that walkthrough are not counted
  as automated or agent-verified coverage.
- Fresh-install permission denial and recovery on both platforms; camera QR
  decoding with a valid disposable pass; no-show/catch-up handling.
- Test location continuity when switching tabs, opening boarding screens,
  locking/backgrounding the app, losing connectivity and restoring it.
  Screen lifetime and acknowledgement defects are now covered by regression
  tests and the targeted iOS check above. Android post-fix GPS continuity and
  physical-device coverage remain outstanding.
- Verify map tiles with an explicitly configured environment. Local Map
  unavailable is expected and is not evidence of a staging map failure.
- Fix the staging-seed script's outdated synthetic Paystack success payload in
  a separate fixture-focused change. Temporary loopback seeding used the strict
  adapter's required provider facts; production payment behaviour was not tested.

Do not close the broader driver, map or offline issues based on this partial
simulator pass.
