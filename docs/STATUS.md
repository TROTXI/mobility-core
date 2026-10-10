# Current implementation status

Source audit: 2026-10-09, commuter phone/password branch. This change is not deployed.
This records code support, not proof of production configuration, device
acceptance, or a successful live-provider transaction.

Authentication update: migration 048 adds phone/password commuter registration.
Signup collects full name, phone, email and password. Phone OTP completes
registration; the separate contact email proof enables password recovery.
The commuter entry screen exposes phone/password sign-in only. Legacy provider,
OTP sign-in and email sign-in API operations remain for older clients during the
staging transition, but are not offered by the current commuter entry screen.
Driver PIN and Ops Google/passkey access are unchanged. This update does not
re-audit the other surfaces below. See [authentication](features/authentication.md)
for rollout and acceptance checks.

## Implemented surfaces

| Surface      | Current capability                                                                                                                                                                                                                                                                     |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| API          | Fastify/TypeScript service in `services/api-next`; PostgreSQL/PostGIS migration chain through 048                                                                                                                                                                                      |
| Commuter     | Phone/password sign-in, phone verification at signup, verified contact email and recovery, subscription requests/offers, Paystack checkout/recovery, current/upcoming coverage, reservations, passes, live tracking, inbox, preferences, pauses, commute requests, profile and erasure |
| Driver       | Code/PIN sign-in, forced temporary-PIN replacement, assigned trips, readiness checks, boarding, manifests, incidents/work requests, background GPS with bounded durable queue, profile and support                                                                                     |
| Ops          | Invite-only Google plus passkey access; superadmin team management; dispatch/map, routes/stops/patterns/schedules/fares, fleet/drivers, riders, standby offers, support, payments/reviews/refunds and card-renewal review, reports, delivery/audit and platform controls               |
| Integrations | Paystack, mNotify, Resend, FCM, private R2 avatars, public MapLibre/PMTiles basemap, OTel and Firebase instrumentation                                                                                                                                                                 |

## Product rules implemented

- Phone OTP proves number possession, not Ghana Card identity. A new account
  cannot leave registration until phone proof succeeds. Contact email proof is
  separate, but recovery by email requires it.
- Standby currently means the subscription request/offer queue. It is not an
  automatic released-seat cascade or single-journey ticket market.
- Ops publishes exact pickup/drop-off fares and sends immutable package terms.
  Travel dates, selected weekdays and schedules determine directional ride
  counts. Ops sets package price and discloses each journey's unused-ride credit.
- One prepaid upcoming renewal can coexist with current coverage without
  overlap. Day-ahead booking uses the period covering the departure, while the
  wallet reports upcoming coverage separately.
- Automatic card renewal has API, commuter opt-in/turn-off/remove-card controls,
  payment-worker and Ops review support. It requires explicit rider consent
  and a verified reusable Paystack card. Mobile money is not automatically
  charged. End-to-end product acceptance is still pending.
- Superadmins invite administrators by email, manage superadmin capability and
  delete administrator accounts through Team & access. Invitations require the
  matching Google identity and a passkey. Sensitive operational and financial
  decisions require attributed reasons.
- Boarding/no-show settlement is transactional. Operator cancellation does not
  consume a ride. Ride Credits are renewal discounts, not withdrawable cash.
- Account closure revokes access and scrubs identity while retaining restricted
  financial/audit records. Provider cleanup and restore protection are separate
  tracked processes.

## Operating boundaries

The checked-in deployment workflow installs migrations with a protected owner
connection, then deploys staging API and Ops. Runtime uses a restricted login.
Production services and paid Render cron examples remain commented out.

The protected main-only GitHub workflows declare payments/email retries every
15 minutes and daily service maintenance. The nightly group generates seven
days of trips, resumes personal pauses, learns segment speeds, retains GPS
evidence according to policy and processes card renewals. Separate daily groups
handle asks, unanswered reservation defaults and no-shows. See
[the schedule](DEPLOY.md#scheduling) for times and jobs not covered.
Workflow definitions do not prove that environment secrets, provider delivery
or a recent run are healthy.

Route learning uses completed traces against published geometry to update
segment-speed estimates; it does not draw or map-match the route automatically.
Real-trip learning quality and physical-device capture still need acceptance
evidence. Basic tracking and manually published geometry do not depend on
finishing that acceptance exercise.

## Not delivered or not certified by this audit

- Production provisioning, store releases, provider live-mode acceptance and
  physical-device acceptance across supported phones.
- Ghana Card/NIA verification, automatic account merging by phone number.
- End-to-end card-renewal product acceptance, automated operator payouts and
  corporate billing.
- One-way subscription offers, holiday calendars and mid-period offer replacement.
- Automated released-seat standby cascade and single-journey checkout.
- MQTT/Go/WebSocket telemetry, Redis serving infrastructure, automatic road
  map-matching and offline boarding.
- Production SLOs, current hosting bills, legal approval and console-side
  provider restrictions. These need evidence outside source code.

See [features](features/README.md) for behavior and source references.
