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
  `flutter` job matrix turns on when the first app lands.
- Shared code (API client, models, theme) gets extracted to
  `packages/trotxi_shared` the second time it is duplicated.
