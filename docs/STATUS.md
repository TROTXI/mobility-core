# Current implementation status

**Verified against `main`:** 2026-09-12

This is a point-in-time implementation map, not a roadmap. Feature contracts
live in [`features/`](features/), decisions in [`adr/`](adr/) and the generated
HTTP contract at `GET /docs/json`.

## Platform

| Surface                   | State                                                                                                                                 |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| Fastify transactional API | Live and covered by unit/e2e/OpenAPI tests                                                                                            |
| PostgreSQL/PostGIS schema | Migrations 001–038                                                                                                                    |
| Driver Flutter app        | Sign-in, schedule, run lifecycle, maps/GPS, manifest, QR/code/photo boarding, completion, incidents and work requests are implemented |
| Commuter Flutter app      | Shell, authentication/client integration and mock/UI flows exist; end-to-end rider lifecycle remains incomplete                       |
| Operations web console    | Repository/design-system seam only; production React application not built                                                            |
| Basemap                   | PMTiles/styles/glyphs live at `tiles.trotxi.com`; shared Flutter map and driver integration live                                      |
| Observability             | API OTel → Grafana Cloud live on staging; Firebase Crashlytics/Performance wired in both apps                                         |
| Deployment                | Paid staging PostgreSQL + free staging API declared; production and paid cron services disabled                                       |

## Backend domains

| Domain                                                                     | State                                             |
| -------------------------------------------------------------------------- | ------------------------------------------------- |
| Google auth, sessions, refresh rotation/reuse detection                    | Live                                              |
| Apple auth, code exchange and deletion revocation                          | Implemented; production Apple credentials pending |
| Driver code/PIN credentials, lockout and suspension                        | Live                                              |
| Profile, private avatars and account erasure                               | Live                                              |
| Routes, stops, fleet CRUD, trips and assignment                            | Live                                              |
| Driver lifecycle, stop progress and run summary                            | Live                                              |
| HTTP GPS reporting, polling, ETA and rider pickup ETA                      | Live                                              |
| Route geometry and morning/evening segment-speed learning                  | Live; scheduled job disabled                      |
| Effective-dated fares and ops-editable plan levers                         | Live; seeded commercial values are placeholders   |
| Paystack checkout/webhook, subscription periods and credit-netted checkout | Live                                              |
| Ride entitlement and Ride Credit ledgers                                   | Live                                              |
| Daily ask, confirmation/default-yes and capacity/unseated handling         | Live; scheduled jobs disabled                     |
| QR, code and photo boarding plus no-shows                                  | Live                                              |
| Driver incidents and work requests                                         | Live                                              |
| Feature flags, force-update, basemap and operations contact config         | Live                                              |

## Current operating constraints

- Render cron services are commented out to avoid approximately $7/month, so
  ask/default/no-show/expiry/conversion/learning jobs need manual triggers or an
  approved scheduler.
- Production API/database definitions are commented out until production spend
  and configuration are approved.
- Apple sign-in cannot operate in production until the Apple Developer IDs and
  private key are configured.
- Operations contact values intentionally default to `null`; the driver app must
  not display a plausible placeholder emergency number.
- Paystack, Firebase, R2 and Grafana features depend on their production secrets.
- Period-end credit conversion still uses the app-wired 45-pesewa fallback
  rather than each subscription's stored conversion-rate snapshot.

## Deferred product/engineering work

- Standby KYC, released-seat offer cascade and single-journey payment.
- Automatic subscription renewal and stored payment mandates.
- Paystack reconciliation, refunds and operator payout execution.
- Final tier taxonomy, price/take-rate/credit values and corporate billing.
- Complete commuter lifecycle and build the operations console.
- Driver offline GPS/boarding queue and the MQTT/EMQX/Go/WebSocket telemetry path.
- Import Grafana dashboards/alerts and connect production notification channels.
