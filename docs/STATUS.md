# Current implementation status

Source audit: 2026-10-08, mobility-core main at `e53c79e`.
This records code support, not proof of production configuration, device
acceptance, or a successful live-provider transaction.

## Implemented surfaces

| Surface      | Current capability                                                                                                                                                                                                                                                       |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| API          | Fastify/TypeScript service in `services/api-next`; PostgreSQL/PostGIS migration chain through 046                                                                                                                                                                        |
| Commuter     | Google/optional Apple and phone sign-in, phone verification, subscription requests/offers, Paystack checkout/recovery, current/upcoming coverage, reservations, passes, live tracking, inbox, preferences, pauses, commute requests, profile and erasure                 |
| Driver       | Code/PIN sign-in, forced temporary-PIN replacement, assigned trips, readiness checks, boarding, manifests, incidents/work requests, background GPS with bounded durable queue, profile and support                                                                       |
| Ops          | Invite-only Google plus passkey access; superadmin team management; dispatch/map, routes/stops/patterns/schedules/fares, fleet/drivers, riders, standby offers, support, payments/reviews/refunds and card-renewal review, reports, delivery/audit and platform controls |
| Integrations | Paystack, mNotify, Resend, FCM, private R2 avatars, public MapLibre/PMTiles basemap, OTel and Firebase instrumentation                                                                                                                                                   |

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
- Automatic card renewal has API, generated-client, payment-worker and Ops
  review support. It requires explicit rider consent and a verified reusable
  Paystack card. Commuter opt-in, turn-off and remove-card controls are not yet
  implemented. Mobile money is not automatically charged.
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
- Commuter card-renewal controls and end-to-end card-renewal product acceptance;
  automated operator payouts and corporate billing.
- One-way subscription offers, holiday calendars and mid-period offer replacement.
- Automated released-seat standby cascade and single-journey checkout.
- MQTT/Go/WebSocket telemetry, Redis serving infrastructure, automatic road
  map-matching and offline boarding.
- Production SLOs, current hosting bills, legal approval and console-side
  provider restrictions. These need evidence outside source code.

See [features](features/README.md) for behavior and source references.
