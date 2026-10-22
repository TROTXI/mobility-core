# Mobile signing and release artifacts

Tracks the repository implementation for #278 and #280. This is not evidence of
Play/App Store enrollment, protected environment setup, a signed production build,
or a successful installation. Keep those issues open until the acceptance steps
below are recorded. Production is still blocked by the reviewed policy in
`apps/trotxi_client/lib/mobile_build_config.dart` under #273.

## What runs automatically

`Mobile artifacts` builds both apps on relevant PRs and main changes:

- Flutter 3.44.1, Java 21 (required by MapLibre), Android compile/target API at least 36.
- Unsigned staging Android AABs. No debug-key substitution.
- Unsigned device `.xcarchive` bundles on `macos-26`, with Xcode >= 26 checked.
- Artifact checks for package/bundle IDs, names, version/build, Android target
  API, permissions, diagnostics defaults, iOS purpose strings, background modes,
  required SDK privacy manifests and declared required-reason entries.
- A native pre-build receipt embedded from the same validated Flutter definitions
  checks environment, public origins, realm, Firebase project and version. It
  contains no keys. This is configuration provenance, not a proof against a
  malicious compiler or arbitrary hard-coded networking elsewhere in the app.
- Reports, symbols/mappings and unsigned artifacts are retained for seven days.
  These are validation artifacts, not installable store releases.

No PR job has signing secrets, a production environment or write permissions.
There is no `pull_request_target` or privileged artifact-consumption workflow.
Compilation never uploads diagnostics to Firebase. APKs/archives built outside
the workflow still hit native environment gates; Android release signing also
fails without an approved non-debug key and matching SHA-256 fingerprint.
Normal debug builds and Android Studio model sync do not require that key.

For an explicit local unsigned staging check, from either app directory:

```sh
ORG_GRADLE_PROJECT_trotxiUnsignedValidation=true flutter build appbundle --release --dart-define-from-file=config/staging.json
flutter build ipa --release --no-codesign --dart-define-from-file=config/staging.json
```

Use a debug build for simulator/emulator installs. An unsigned AAB is not an
installable APK. Production rejects the unsigned Android validation escape hatch.
Legacy `android/key.properties` files are no longer read; there is no debug fallback.

## Owner setup before enabling store builds

Do not put credentials in the repository, chat, Dart definitions or artifacts.
No keys, paid services or secrets are created by this change.

1. Finish #273's reviewed production API/site/realm and isolated Firebase policy.
   Validate public legal/deletion pages before approving the site origin. Prepare
   matching per-app `production.json` and Android `google-services.json` inputs.
2. Enroll both permanent package IDs in Play App Signing. Generate a separate
   upload key per app in an approved secure environment. Record its SHA-256
   certificate fingerprint and verify it matches Play Console. The upload key is
   not the Google-managed app-signing key used on installed Play builds.
3. Provision Apple distribution certificates and explicit App Store profiles for
   `com.trotxi.trotxiCommuter` and `com.trotxi.trotxiDriver`, with push enabled.
   Approve the Apple team ID and distribution certificate SHA-256. Configure
   production APNs/FCM separately. Debug/profile push uses development; release
   distribution uses production. Neither configuration alone proves delivery.
4. Create GitHub environments `mobile-release`, `mobile-production-commuter`
   and `mobile-production-driver`. Require independent reviewers, prevent
   self-review, restrict deployment branches to `main` only, and disallow bypass
   where supported. Protect main and changes to workflows/release tooling.
   A YAML `environment:` name does NOT create these protections. Verify your
   repository plan supports them before storing keys; otherwise keep signing
   disabled and use a controlled manual release process. Do not buy a plan here.
5. In `mobile-release`, set variable `MOBILE_STORE_BUILD_FLOOR` to the highest
   already used build number across both apps and both stores (explicit `0` for
   new listings). Check the consoles, not a local pubspec. All later release
   numbers must go through this workflow. Protect `mobile-build-*` tags against
   deletion/update; allow only the release automation to create reservations.
6. Store the following separately in EACH app's production environment, never
   as repository-wide secrets. Android/iOS steps receive only their own signing
   credentials. Do not expose these environments to PR branches.

| Setting                         | Kind     | Purpose                                                              |
| ------------------------------- | -------- | -------------------------------------------------------------------- |
| `MOBILE_CONFIG_JSON`            | Secret   | Approved production Flutter definitions                              |
| `ANDROID_FIREBASE_JSON`         | Secret   | Matching native provider configuration, also checked by the iOS gate |
| `ANDROID_UPLOAD_KEY_BASE64`     | Secret   | Upload keystore, not a debug keystore                                |
| `ANDROID_UPLOAD_STORE_PASSWORD` | Secret   | Keystore password                                                    |
| `ANDROID_UPLOAD_KEY_ALIAS`      | Secret   | Private-key alias                                                    |
| `ANDROID_UPLOAD_KEY_PASSWORD`   | Secret   | Private-key password                                                 |
| `ANDROID_UPLOAD_CERT_SHA256`    | Variable | Independently approved upload certificate fingerprint                |
| `IOS_CERTIFICATE_BASE64`        | Secret   | Distribution certificate and private key in a password-protected P12 |
| `IOS_CERTIFICATE_PASSWORD`      | Secret   | P12 password                                                         |
| `IOS_PROFILE_BASE64`            | Secret   | This app's App Store provisioning profile                            |
| `IOS_CERT_SHA256`               | Variable | Independently approved distribution certificate fingerprint          |
| `APPLE_TEAM_ID`                 | Variable | Approved organization team ID                                        |

The Firebase client fields are public identifiers but are environment-scoped here
to prevent accidental reuse across projects. They are never Admin credentials.
GitHub masks whole secrets, not necessarily individual JSON fields, so the scripts
do not print provider input or raw exceptions. Avoid verbose environment dumps.

## Manual release

Run `Mobile store release` from **main**, with a new integer build number (1..9999)
and a marketing version such as `1.0.0`. These limits deliberately keep one shared
Android/iOS number within the single-component Apple build-number format.

The workflow serializes releases, checks the configured store floor and every
previous `mobile-build-*` tag, then atomically reserves the new number against the
selected commit. A failed/cancelled run burns its number. Reruns are rejected;
dispatch a new run with a higher number. This prevents duplicates in this release
process. It does not query the store consoles or detect out-of-band uploads: if
one occurs, update the floor from the consoles before releasing again.

After independent environment approval, the four jobs package both apps for both
stores. Android verifies the private key, expiry, non-debug identity and approved
fingerprint before packaging, then inspects the AAB signature. iOS checks the
distribution profile, team, app identity, expiry and certificate, signs in a
temporary keychain, exports the IPA, then checks its signature/certificate and
production push/debugging entitlements. Files and keychain state are cleaned up
in `finally`; use ephemeral hosted runners, not a shared developer machine.

Artifacts and reports are retained for 14 days. Before submission, copy the approved
release and corresponding symbols/mappings to the company's restricted release
archive with its commit, version, SHA-256 and test evidence. Retain symbols for the
lifetime of supported builds. Do not rely on GitHub's short retention for recovery.

There is **no automatic upload to App Store Connect, Play, Firebase or production**.
Download the approved artifacts, verify their report/hash, and submit first to
TestFlight and Play internal testing using organization-controlled accounts.
Do not mark packaging complete if only one of the four jobs succeeded.

## Diagnostics are a separate release step

Packaging sets `TROTXI_UPLOAD_DIAGNOSTICS=false`, retains Android mapping files and
iOS dSYMs, and never calls a Firebase symbol endpoint. A provider outage cannot
turn a successfully compiled package into a compiler failure.

After explicit approval to send code-derived symbol files, use the matching
Firebase project's supported symbol-upload procedure against the retained files.
For Android, the existing Gradle `uploadCrashlyticsMappingFileRelease` task can be
run separately with `TROTXI_UPLOAD_DIAGNOSTICS=true`, the same validated Flutter
definitions and original build workspace. Never rebuild a different binary and
label its mapping as the original. Record upload failure separately and retry the
same files; do not hide it or ship unverified crash symbolication unnoticed.

This PR does not automate or authorize that upload. Native/Dart crash collection
policy remains unchanged. Verify a deliberate staging crash on a dedicated test
device and its symbolicated report before claiming diagnostics acceptance.

## Custody, recovery and rollback

- Godfred, as CTO, owns release authorization. Appoint and record a second
  authorized maintainer before closure. Both need organization recovery access;
  do not share personal store accounts.
- Keep encrypted upload-key backups and recovery instructions in the company's
  approved secret store, with access limited to those maintainers. Test recovery
  without exposing or committing the key. GitHub is a delivery copy, not the sole
  backup. Record fingerprints, expiry and the date/owner of the recovery drill.
- If an Android upload key is lost/compromised, request an upload-key reset through
  Play App Signing, then update the approved fingerprint and protected secret.
  Do not change package IDs or substitute a debug key. Follow the separate Apple
  certificate revocation/profile renewal procedure for Apple credentials.
- Stop a bad rollout in the relevant console. Rebuild a known-good source commit
  through a reviewed revert on main, using a NEW higher build number. Never
  overwrite artifacts, move a reserved tag, or try to downgrade an installed
  production app. Database/backend rollback remains a separate deployment plan.

## Evidence required to close #278 and #280

- GitHub unsigned AAB and device archive builds pass for both apps.
- Production configuration and protected environments reviewed; key custody and
  backup/recovery assigned to two maintainers.
- Four signed production artifacts generated and their validation reports retained.
- Inspect Xcode's aggregate privacy report and the Android merged permission and
  native dependency reports for those exact artifacts. This script's manifest
  checks do not certify the legal correctness of reason codes or store disclosures.
- Play internal-track first install AND upgrade pass for both apps; verify actual
  installed signing identity from Play, not just the upload certificate.
- TestFlight install/upgrade, APNs/FCM push, driver background GPS and diagnostic
  payload/symbolication checks pass on physical devices.
- Final store forms, legal links, SDK declarations and review warnings are resolved.

References: [Flutter Android releases](https://docs.flutter.dev/deployment/android),
[Flutter Apple releases](https://docs.flutter.dev/deployment/ios),
[Firebase Android mapping files](https://firebase.google.com/docs/crashlytics/android/get-deobfuscated-reports),
[GitHub macOS runner inventory](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-Readme.md).
