# ADR-0004 — Flutter for the mobile apps

**Status:** accepted · **Date:** 2026-06-12

## Context

Two apps (commuter, driver) must ship on Android first (dominant in Accra) and
iOS, render a smooth live map on mid-range hardware, and share as much code as
possible with a small team.

## Decision

Flutter/Dart for both apps, one codebase each, shared packages where duplication
appears.

Technical grounds:

- **Compiles to native ARM** — no JavaScript bridge; the live map and QR flows
  stay at 60 fps on the mid-range Android devices our riders actually own.
- **One codebase, two platforms** — a two-app product (rider + driver) doubles
  the payoff versus native development.
- **Consistent rendering** — Flutter draws its own UI, so visual QA on Ghana's
  fragmented Android landscape doesn't multiply.
- **Tooling**: hot reload for iteration, widget tests in CI, `flutter analyze`
  as a lint gate.

## Consequences

- Native-plugin needs (camera/QR scanning, background GPS) ride on maintained
  plugins (`mobile_scanner`, `geolocator`); we accept that dependency.
- App size is larger than native baseline — acceptable for our distribution
  model.
