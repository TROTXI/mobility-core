# Applications

Current implementation: 2026-10-03.

- [Commuter](trotxi_commuter/README.md): sign-in and phone verification,
  subscription requests/offers, Paystack checkout, reservations, passes,
  wallet, live trips, notifications and account controls.
- [Driver](trotxi_driver/README.md): code/PIN sign-in, assigned trips,
  boarding, durable background GPS, incidents and work requests.
- [Ops](../docs/features/ops-console.md): React operations console.
- `trotxi_client`: shared mobile session/domain layer.
- `api_client`: generated Dart contract client.
- `trotxi_map`: shared mobile map surface.

## Configuration and builds

Both mobile apps require an explicit environment file, including
`APP_ENVIRONMENT`, `API_BASE_URL`, `API_SESSION_REALM`, `PUBLIC_SITE_URL` and
Firebase project/application identifiers. Android and Xcode validate these
before compilation; startup repeats the same checks. `PUBLIC_SITE_URL` serves
the privacy notice and deletion-request pages. There is no implicit backend or
old-token fallback. A database replacement needs a reviewed realm-policy update.

Each app keeps its staging values in `config/staging.json`:

```sh
cd apps/trotxi_commuter
flutter run --dart-define-from-file=config/staging.json
flutter build apk --dart-define-from-file=config/staging.json
```

Production remains blocked until its distinct API, public site, session realm,
Firebase project and sender are approved in the shared environment policy.
It then uses `config/production.json` and
`config/production/google-services.json`, not staging provider defaults.
For local debug builds copy staging.json to ignored `config/local.json`, select
`APP_ENVIRONMENT=local`, `API_SESSION_REALM=local-development`, and use
`http://10.0.2.2:3001` on Android or `http://127.0.0.1:3001` on an iOS simulator.
Keep staging Firebase for local testing. Local release/profile builds are refused.
See [mobile release readiness](../docs/mobile-release-readiness.md) for commands,
the SDK inventory, privacy-review evidence and remaining release gates.

Regenerate the replacement client using `pnpm codegen:replacement`, then
`dart run build_runner build` in `apps/api_client`. The checked-in
replacement contract is the source, not a captured staging response.

Flutter analysis and tests are CI gates. Native builds, store signing,
provider configuration and physical-device acceptance are separate checks.
Do not treat passing widget tests as proof of background GPS or push delivery.

Android map builds need JDK 21. On macOS:

```sh
brew install --cask temurin@21
flutter config --jdk-dir="/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home"
```

Production needs its own API/session realm, Firebase identity, signing and
provider configuration. See [deployment](../docs/DEPLOY.md).
