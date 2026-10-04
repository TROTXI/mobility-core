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

Both mobile apps require explicit `API_BASE_URL`, `API_SESSION_REALM` and
`PUBLIC_SITE_URL` build definitions; an app missing one shows a start-up error
instead of falling back to staging. `PUBLIC_SITE_URL` is the site that serves
the privacy notice and deletion-request pages. Use a new realm after replacing
a disposable database; there is no implicit backend or old-token fallback.

The rider app keeps its staging values in `trotxi_commuter/config/staging.json`:

```sh
cd apps/trotxi_commuter
flutter run --dart-define-from-file=config/staging.json
flutter build apk --dart-define-from-file=config/staging.json
```

A production build passes its own file (for example `config/production.json`
with the production API, a new realm and the production site). No code
changes are needed to switch environments.
Android emulators reach a local backend at `http://10.0.2.2:3001`;
iOS simulators use `http://127.0.0.1:3001`. Release builds require HTTPS.

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
