# Mobile release readiness

Scope: issues #273 and #276. Applies to both apps. Source changes do not prove
production provider setup, delivery on physical devices, or store acceptance.

## Environment contract

`apps/trotxi_client/lib/mobile_build_config.dart` is used by app startup and
`tool/validate_mobile_build.dart`. Android invokes the validator before native
resources/Flutter compilation; Xcode invokes it before its Flutter build phase.
These are build gates, not just a recommended wrapper command.

| Environment | API and realm                                        | Firebase                               | Build mode                           |
| ----------- | ---------------------------------------------------- | -------------------------------------- | ------------------------------------ |
| staging     | Exact reviewed staging origin and `staging-1`        | `trotxi-501218`, sender `431341307838` | Debug, profile or release            |
| local       | Loopback/emulator origin and explicit `local-` realm | Staging provider only                  | Debug only                           |
| production  | Exact separately approved origin, site and realm     | Separately approved project and sender | No production policy yet, so blocked |

Production cannot be enabled by renaming a staging file or supplying a single
`APP_ENVIRONMENT=production` override. It requires a reviewed production policy,
complete public Firebase configuration and matching native provider file.
API/site URLs cannot contain credentials, paths, query strings or fragments.
Staging and production require HTTPS. Both apps display version/build and
environment in Profile; they never display provider keys, tokens or URLs there.

Each app has a complete `config/staging.json`. Firebase keys in this file are
public client configuration, not Admin credentials or authorization. Restrict
them in Firebase/Google Cloud to their intended APIs and app identities. Never
put service-account keys, APNs private keys, signing passwords or server secrets
in a Dart definition or mobile asset.

Android selects only `config/<environment>/google-services.json`, mapping local
to staging. Its project, sender, app ID, package and API key must match the Dart
configuration. Old root/source-set provider files cannot override that choice.
iOS uses the selected Dart Firebase options and validates its bundle ID. No
hardcoded Firebase options remain in app code. APNs registration/signing for the
production Firebase project remains a separate device acceptance check.

### Build and validate

Run from either `apps/trotxi_commuter` or `apps/trotxi_driver`:

```sh
flutter pub get
dart ../../tool/validate_mobile_build.dart . release config/staging.json
flutter run --dart-define-from-file=config/staging.json
flutter build apk --release --dart-define-from-file=config/staging.json
flutter build appbundle --release --dart-define-from-file=config/staging.json
flutter build ios --simulator --debug --dart-define-from-file=config/staging.json
flutter build ios --release --no-codesign --dart-define-from-file=config/staging.json
```

Local: copy the staging JSON to ignored `config/local.json`, change environment
to `local`, realm to `local-development` and API to `http://10.0.2.2:3001`
(Android) or `http://127.0.0.1:3001` (iOS simulator). Retain the staging public
site and Firebase fields. Use `flutter run --dart-define-from-file=config/local.json`.

Production, **after** reviewed policy and provider setup:

```sh
dart ../../tool/validate_mobile_build.dart . release config/production.json
flutter build appbundle --release --dart-define-from-file=config/production.json
flutter build ipa --release --dart-define-from-file=config/production.json
```

Native signing remains issue #278. A successful staging APK or unsigned iOS
build is not a store-ready, production-signed artifact.

## Mobile telemetry policy

Crashlytics and targeted Performance reporting are approved for release builds
in the selected, validated Firebase project. This includes native crash stacks,
native exception messages and device/app metadata, not only filtered Dart data.
Firebase Analytics and Auth remain absent. The old URL-reporting HTTP interceptor
and debug interceptor that logged headers, bodies, tokens and errors stay removed.
Backend operational monitoring is separate and unchanged.

The shared `apps/trotxi_diagnostics` package implements these boundaries:

- Dart errors: fixed error category, source (framework/platform/zone), fatality
  and filtered source stack. No original exception text, Flutter context or
  information collector, arbitrary custom keys, user ID or breadcrumbs. AOT
  addresses/build IDs remain available for symbolication. At most 20 reports
  per session, four simultaneously awaited provider calls, three-second timeout.
  A timeout cannot cancel native SDK work; the session budgets still bound the
  total number of attempts even if native calls never complete.
- Crashlytics automatic uploads are OFF in both native configurations and Dart.
  On a policy/project/build-mode transition, existing queued reports are discarded.
  An empty queue must be observed before recording approval locally. If deletion
  was requested, this requires a later clean launch because the native delete API
  acknowledges scheduling, not completion. Until then, application reporting stays
  disabled and queued reports are discarded rather than sent. Subsequent release
  launches explicitly send the previous session's reports. Debug/profile runs
  do not send or record Dart reports.
  Failed initialization, cleanup or local storage prevents the upload step.
  This intentionally means new reports may appear only after the next launch.
- Native reports are SDK-generated, not passed through the Dart filter. They may
  include exception text and technical metadata. Do not promise that every native
  field is scrubbed. Review native crash payloads on devices before release.
- Performance: 10% sampling of allowlisted API operations, at most 100 timings
  per session and 32 outstanding request measurements. Fixed trace/operation
  names and outcome enum only. No URL, headers, body, account ID, payment data or
  coordinates. `duration_ms` is the actual measured request time; the Firebase
  custom trace's default duration is only measurement-emission overhead.
- Android deliberately omits the Performance Gradle instrumentation plugin,
  disabling automatic HTTP instrumentation. App lifecycle/start/frame metrics
  can still be recorded by the SDK in release. Debug/profile manifests deactivate
  Performance. On iOS, instrumentation and custom collection are disabled before
  Firebase initialization; only custom collection is enabled for release.
- Reporting setup runs independently of startup. Hung, throwing and late-failing
  providers cannot fail or delay application requests. Failure reporting does not
  recursively report telemetry errors. Flutter diagnostics remain local in debug.

No analytics opt-in or advertising tracking is introduced. Public notices and
store disclosures must describe reliability diagnostics. Production privacy and
retention review still applies; this implementation is not legal approval.

Firebase Core and Messaging remain for notifications. Provider initialization
is bounded to five seconds and failure cannot prevent normal startup. Both
notification controllers handle unavailable providers; riders still have their
inbox and drivers can refresh assignments. This does not claim push works
without Firebase, APNs or device permission.

Removing an SDK does not erase historical provider data or stop old installed
builds reporting it. Inventory and handle that data separately under
[account erasure operations](design/account-erasure-operations-checklist.md).
There is no app-side remote Crashlytics/Performance deletion or verified
provider-retention override. Do not promise immediate or retroactive erasure.

## SDK inventory

The app `pubspec.lock` files are the complete version-pinned Dart inventory.
Native resolutions are also recorded in each iOS `Package.resolved` and Android
dependency reports. The following focuses on data-relevant SDKs, not UI helpers:

| SDK                                                                                               | Apps    | Dependency and purpose                                      | Disclosure consideration                                                                       |
| ------------------------------------------------------------------------------------------------- | ------- | ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Firebase Core 4.15.0                                                                              | Both    | Direct, initializes selected project                        | Native Core utilities; not an analytics feature                                                |
| Firebase Messaging 16.7.0                                                                         | Both    | Direct, push delivery                                       | Installation/device identifiers, push tokens, service metadata                                 |
| Firebase Crashlytics 5.4.0, Performance 0.11.6                                                    | Both    | Via shared diagnostics package, crashes and bounded timings | Native crash text, stack traces, device/app metadata and performance measurements              |
| Firebase Installations, Sessions, GoogleDataTransport, GoogleUtilities, interop/support libraries | Both    | Native transitive dependencies of Firebase SDKs             | Provider SDK metadata remains without Analytics; inspect linked manifests                      |
| MapLibre GL 0.27.1                                                                                | Both    | Transitive via `trotxi_map`, bus maps                       | Tile requests expose network address to map hosting; commuter does not collect device location |
| Geolocator 14.0.3 and native implementations                                                      | Driver  | Direct, active-trip GPS                                     | Precise location, including supported background operation                                     |
| Mobile Scanner 7.4.1 and native scanning dependencies                                             | Driver  | Direct, QR boarding                                         | Camera and boarding proof processing; inspect native scanner SDK disclosures                   |
| Image Picker 1.2.3 and native implementations                                                     | Both    | Direct, optional profile photos                             | User-selected photo/camera data uploaded to Trotxi                                             |
| Flutter Secure Storage 10.3.1 and native implementations                                          | Both    | Direct and shared-client dependency                         | Local credentials/preferences; driver offline GPS queue                                        |
| Package Info Plus, URL Launcher and native implementations                                        | Both    | Direct, version/build and external links                    | Local app metadata; browser destinations have separate processing                              |
| Analytics, Firebase Auth, advertising/ATT Flutter SDKs                                            | Neither | Absent from resolved Dart dependency graph                  | No collection through these absent SDKs                                                        |

Swift package resolution may still list products not linked into Runner, because
Firebase's repository declares multiple products. A lockfile name alone is not
proof of collection or absence. Inspect the final link map, privacy manifests
and Android merged manifest. Android explicitly removes AD_ID and AdServices
advertising/attribution/topics permissions from merged manifests.

## Store disclosure working draft

Do not submit this table as a completed store questionnaire. Match each answer
to the actual production artifact and enabled features, then obtain privacy
review. It covers Trotxi functionality as well as third-party SDK behavior.

| Data                                             | Commuter        | Driver                              | Draft purpose/linkage                                                                                                                       |
| ------------------------------------------------ | --------------- | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Name, phone/email and account identifier         | Yes             | Yes                                 | Account/service functionality, linked                                                                                                       |
| Installation/device IDs and push tokens          | Yes             | Yes                                 | Notifications, linked through device registration                                                                                           |
| Selected profile photo                           | Optional        | Optional                            | Profile/identity functionality, linked                                                                                                      |
| Purchases/payment references                     | Yes             | Not a driver salary/payment feature | Payment and accounting functionality, linked; Paystack checkout handles financial entry                                                     |
| Routes, rides, boarding, support content         | Yes             | Yes                                 | Service operation, linked                                                                                                                   |
| Precise device location                          | No              | During active trips                 | Driver tracking/safety, linked; background disclosure needed                                                                                |
| Crash reports and performance measurements       | Release builds  | Release builds                      | App reliability; SDK installation identifiers and device/app metadata. No app account ID supplied; review linkage against the final payload |
| App screen/event analytics                       | Not implemented | Not implemented                     | Firebase Analytics remains absent; other Firebase SDKs still declare diagnostic purposes                                                    |
| Advertising identifiers / cross-company tracking | Not implemented | Not implemented                     | No advertising purpose, no ATT request                                                                                                      |

The inspected simulator bundles contain 26 commuter and 29 driver privacy
manifests. None declares tracking. The checked-in
[manifest inventory](mobile-privacy-manifest-inventory.json) records SDK
contents, not a signed-archive approval. Reproduce it on macOS with
`node tool/mobile_privacy_report.mjs apps/trotxi_commuter/build/ios/iphonesimulator/Runner.app apps/trotxi_driver/build/ios/iphonesimulator/Runner.app`.
Firebase Installations and GoogleDataTransport declare other
diagnostic data for analytics; Messaging declares device IDs for app
functionality, other data for analytics and other diagnostic data for app
functionality. These SDK-purpose declarations remain after removing Firebase
Analytics. They are not evidence of Trotxi screen/event analytics or advertising.
They also do not override Trotxi's own linkage of push registration to accounts.
Crashlytics declares crash data and other diagnostic data for app functionality.
Performance brings additional Firebase support libraries, including ABTesting;
their presence is not evidence of Trotxi running product experiments.

GoogleDataTransport/provider metadata and any scanner diagnostics still need
classification under Diagnostics/App information on the actual store forms.
Decide required versus optional per feature; notification permission alone does
not prove no installation identifier was generated. Assess service-provider
sharing exceptions rather than claiming no sharing because data uses HTTPS.

References: [Firebase Apple disclosures](https://firebase.google.com/docs/ios/app-store-data-collection),
[Firebase Play disclosures](https://firebase.google.com/docs/android/play-data-disclosure),
[Firebase privacy and retention](https://firebase.google.com/support/privacy),
[installation data management](https://firebase.google.com/support/privacy/manage-iids).
Provider documentation describes SDK behavior, not a completed Trotxi audit.

## Acceptance still required before closing the issues

Re-run both app suites, shared-client and diagnostics tests after SDK/configuration
changes. Diagnostics tests cover payload filtering, AOT frames, legacy-report
cleanup, release/debug/project transitions, provider failure isolation, budgets,
sampling and request allowlists. Build both native platforms and regenerate the
manifest inventory. Older builds without Crashlytics/Performance are not evidence
for this revised dependency graph.

Local checks for this revision: 267 commuter tests, 326 driver tests, 219 shared
client tests, 21 diagnostics tests and six public-page tests passed. Static
analysis passed for all four Dart packages. Both platforms' native configurations
were inspected; final store/device acceptance below remains separate.
Both final iOS simulator builds and the commuter release APK passed. The final
driver Android run reached the Crashlytics mapping-upload task but failed with
a TLS `bad_record_mac` error. Its retry needs approval to send code-derived
symbol/mapping files to Firebase. An earlier driver APK build passed, but does
not replace verification of the final cleanup guard.

The Android Crashlytics Gradle plugin uploads release obfuscation mappings to
the configured Firebase project. These are code-derived build artifacts, not
user crash payloads. Approval for those uploads is distinct from crash reporting.

This evidence is staging/local only. The following remain open:

- Approve real production API/site/realm and isolated Firebase project/sender.
- Configure production APNs/FCM and signing; verify both apps on physical devices.
- Produce signed release archives and inspect Xcode's aggregate privacy report,
  linked SDK manifests and required-reason warnings. Add an app-owned
  `PrivacyInfo.xcprivacy` only for actual app-owned usage, not to hide a missing
  third-party declaration or copy speculative required-reason codes.
- Inspect Android release merged permissions/classes and native dependency
  report; confirm no advertising SDK, measurement collector or AD_ID permission.
- Capture device network evidence for startup, sign-in, consent, trip and push
  flows, including after upgrade from the previous build.
- Verify a deliberate crash and handled Dart error in staging on physical devices
  without a debugger, then relaunch and check Firebase. Confirm symbolication;
  upload matching iOS dSYMs and Dart symbols for obfuscated builds through the
  release process. Never intentionally crash a rider's or driver's live session.
- Verify `operation_*` traces using the `duration_ms` metric and outcome attribute.
  Inspect payloads for secrets, URLs and coordinates. Confirm legacy crash cleanup
  and no automatic HTTP traces on both platforms. Firebase reporting can be delayed.
- Complete store-form review against those exact artifacts and account for
  historical diagnostics from old versions. Neither issue is closed merely
  because source tests pass.

Control references: [Crashlytics Flutter collection and deletion](https://firebase.google.com/docs/crashlytics/customize-crash-reports?platform=flutter),
[Android Performance controls](https://firebase.google.com/docs/perf-mon/disable-sdk?platform=android),
[Apple Performance controls](https://firebase.google.com/docs/perf-mon/disable-sdk?platform=ios).
