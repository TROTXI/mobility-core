# Feature documentation

**Owner:** Godfred Awuku · **Current-state review:** 2026-09-12

This directory documents the behaviour that exists on the current
`mobility-core` branch. The generated OpenAPI document at `GET /docs/json` is
the source of truth for HTTP shapes; the TypeScript implementation is the
source of truth when prose and code disagree. Update the relevant feature doc
in the same PR as a behavioural change.

The private `strategy` repository explains product intent. ADRs explain durable
technical decisions. These feature docs explain the system operators and app
developers can use today.

## Current feature map

| Area                                                | Document                                                 | Current state                                                   |
| --------------------------------------------------- | -------------------------------------------------------- | --------------------------------------------------------------- |
| Social, session and driver authentication           | [authentication.md](authentication.md)                   | Live; Apple backend complete, production credentials pending    |
| Profile, avatars and account erasure                | [profile-avatars.md](profile-avatars.md)                 | Live                                                            |
| Fare-derived pricing, Paystack checkout and renewal | [payments-and-wallet.md](payments-and-wallet.md)         | Live; auto-renew and reconciliation deferred                    |
| Ride entitlements and Ride Credits                  | [entitlements.md](entitlements.md)                       | Live, including conversion and credit netting                   |
| Daily confirmation and capacity                     | [reservations.md](reservations.md)                       | Live; standby allocation deferred                               |
| Boarding by QR, code or photo                       | [boarding.md](boarding.md)                               | Live                                                            |
| Routes, stops, trips and route learning             | [mobility.md](mobility.md)                               | Live                                                            |
| Pilot GPS reporting and ETA                         | [live-positions.md](live-positions.md)                   | Live over HTTP polling                                          |
| Self-hosted basemap                                 | [basemap.md](basemap.md)                                 | Assets/API live; driver integrated, other clients incomplete    |
| Driver incidents and work requests                  | [driver-operations.md](driver-operations.md)             | Live                                                            |
| Feature flags, force-update and operations contact  | [feature-flags.md](feature-flags.md)                     | Live                                                            |
| Rate limiting                                       | [rate-limiting.md](rate-limiting.md)                     | Live                                                            |
| Observability                                       | [../design/observability.md](../design/observability.md) | Backend and both mobile SDKs live; Grafana import/alerts remain |

## Cross-cutting conventions

- Routes validate with Zod and publish the same schemas through OpenAPI.
- Protected routes authenticate first, rate-limit second, then enforce role and
  relationship rules.
- Domain rules live in services; persistence lives behind repository interfaces.
- Production uses PostgreSQL/PostGIS, Redis-compatible KV and configured external
  adapters. Tests and zero-infrastructure development use in-memory adapters.
- Monetary values use integer pesewas; rates use basis points.
- Financial and boarding writes are append-only or idempotent where retries can
  occur.
- Optional integrations fail narrowly: an unwired feature returns `503` without
  preventing the rest of the API from starting.

## Deferred by design

- Standby-seat offer cascade and instant single-journey payment.
- Automatic recurring charges and stored payment mandates.
- Nightly Paystack reconciliation and refund automation.
- MQTT/EMQX/Go/WebSocket telemetry path; HTTP polling remains the pilot path.
- SMS/OTP fallback.
- Production Render service/database and paid scheduled jobs.
