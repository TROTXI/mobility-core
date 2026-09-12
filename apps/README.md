# Mobile apps

Two Flutter apps live here once their work items start:

- `apps/commuter/` — rider app: subscribe, browse routes/trips, board with a
  QR pass, live map.
- `apps/driver/` — driver app: assigned trips, scan rider passes, publish GPS.

## Conventions (agree before scaffolding)

- Created with `flutter create --org com.trotxi <name>`.
- API base URL is platform-aware and overridable at build time:
  `flutter run --dart-define=API_BASE_URL=https://…` (Android emulator reaches
  the host via `10.0.2.2`, everything else via `localhost`).
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
