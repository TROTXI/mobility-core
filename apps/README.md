# Mobile apps

Two Flutter apps now use the replacement API on the integration branch:

- `apps/trotxi_commuter/` — rider app: subscribe, browse routes/trips, board with a
  QR pass, live map.
- `apps/trotxi_driver/` — driver app: assigned trips, scan rider passes, publish GPS.

Both depend on `trotxi_client`, the shared session/domain layer over the generated
`api_client`. Regenerate with `pnpm codegen`, then `dart run build_runner build`
inside `apps/api_client`. The source is the checked-in replacement contract,
not staging. See `docs/design/stage-4-completion.md` for scope and release gates.

## Conventions (agree before scaffolding)

- Created with `flutter create --org com.trotxi <name>`.
- Both `API_BASE_URL` and `API_SESSION_REALM` are required build definitions.
  For a local backend, Android emulators use `http://10.0.2.2:3001`; an iOS
  simulator uses `http://127.0.0.1:3001`. Choose a new realm after replacing the
  disposable database. There is no implicit staging or old-token fallback.
- `flutter analyze` clean and widget tests passing are CI gates — the CI
  `flutter` job matrix turns on when the first app lands. Note that neither
  gate builds for Android, so an Android-only break passes CI.
- **Android needs JDK 21.** `maplibre_gl` (the shared map surface, #180/#237)
  declares a Java 21 toolchain, and Flutter's default JDK on a stock macOS
  setup is 17. Without it `flutter build apk` fails with
  `:maplibre_gl:compileDebugJavaWithJavac — error: invalid source release: 21`,
  which reads like a plugin bug and is a toolchain mismatch. Overriding the
  plugin down to 17 does not work: it resets its own compile options in
  `afterEvaluate`, and Gradle then fails on the Java/Kotlin mismatch it was
  handed. Install it and point Flutter at it:

  ```
  brew install --cask temurin@21
  flutter config --jdk-dir="/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home"
  ```

- Shared code (API client, models, theme) gets extracted to
  `packages/trotxi_shared` the second time it is duplicated.
