# Current implementation status

Source audit: 2026-10-03, mobility-core main at `2d5e063`.
This records code support, not proof of production configuration, device
acceptance, or a successful live-provider transaction.

Authentication update, 2026-10-08: migration 047 adds commuter email/password
sign-in, verified email setup, forgotten-password recovery and session-revoking
password changes. Full name parts produce the app's `displayName`. Email sign-in
does not verify a phone: standby still requires account-bound phone verification.
Driver PIN and Ops Google/passkey access are unchanged. This update does not
re-audit the other surfaces below. See [authentication](features/authentication.md)
for rollout and acceptance checks.

## Implemented surfaces

| Surface      | Current capability                                                                                                                                                                                                                                       |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| API          | Fastify/TypeScript service in `services/api-next`; PostgreSQL/PostGIS migration chain through 042                                                                                                                                                        |
| Commuter     | Google/optional Apple and phone sign-in, phone verification, subscription requests/offers, Paystack checkout/recovery, current/upcoming coverage, reservations, passes, live tracking, inbox, preferences, pauses, commute requests, profile and erasure |
| Driver       | Code/PIN sign-in, forced temporary-PIN replacement, assigned trips, readiness checks, boarding, manifests, incidents/work requests, background GPS with bounded durable queue, profile and support                                                       |
| Ops          | Google plus passkey access; dispatch/map, routes/stops/patterns/schedules/fares, fleet/drivers, riders, standby offers, support, payments/reviews/refunds, reports, delivery/audit and platform controls                                                 |
| Integrations | Paystack, mNotify, Resend, FCM, private R2 avatars, public MapLibre/PMTiles basemap, OTel and Firebase instrumentation                                                                                                                                   |

## Product rules implemented

- Phone OTP proves number possession, not Ghana Card identity. Google sign-in
  is not blocked by unverified phone; standby enrollment and acceptance are.
- Standby currently means the subscription request/offer queue. It is not an
  automatic released-seat cascade or single-journey ticket market.
- Ops publishes exact pickup/drop-off fares and sends immutable package terms.
  Travel dates, selected weekdays and schedules determine directional ride
  counts. Ops sets package price and discloses each journey's unused-ride credit.
- One prepaid upcoming renewal can coexist with current coverage without
  overlap. Day-ahead booking uses the period covering the departure, while the
  wallet reports upcoming coverage separately.
- Boarding/no-show settlement is transactional. Operator cancellation does not
  consume a ride. Ride Credits are renewal discounts, not withdrawable cash.
- Account closure revokes access and scrubs identity while retaining restricted
  financial/audit records. Provider cleanup and restore protection are separate
  tracked processes.

## Operating boundaries

The checked-in deployment workflow installs migrations with a protected owner
connection, then deploys staging API and Ops. Runtime uses a restricted login.
Production services and paid Render cron examples remain commented out.

The GitHub maintenance workflow declares payments and email retries every
15 minutes on main. This does not schedule all workers: trip generation, asks,
defaults, no-shows, push and retention need their own approved invocation.
Workflow definitions do not prove that environment secrets or a recent run
are healthy.

## Not delivered or not certified by this audit

- Production provisioning, store releases, provider live-mode acceptance and
  physical-device acceptance across supported phones.
- Ghana Card/NIA verification, automatic account merging by phone number.
- Stored payment mandates, automatic recurring charges, card-payment product
  rollout, automated operator payouts and corporate billing.
- One-way subscription offers, holiday calendars and mid-period offer replacement.
- Automated released-seat standby cascade and single-journey checkout.
- MQTT/Go/WebSocket telemetry, Redis serving infrastructure, automatic road
  map-matching and offline boarding.
- Production SLOs, current hosting bills, legal approval and console-side
  provider restrictions. These need evidence outside source code.

See [features](features/README.md) for behavior and source references.
