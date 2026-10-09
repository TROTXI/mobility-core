# Current architecture

Source audit: 2026-10-08. This describes the implemented system, not a future
scale diagram.

## Runtime

The Flutter apps use `apps/trotxi_client` over generated `apps/api_client`.
Ops uses generated TypeScript types and an HTTP client. All use the current
`services/api-next` Fastify API and its reviewed versioned contract.

`src/server.ts` validates configuration and composes domain services in
`src/runtime/compose.ts`. Services use parameterized PostgreSQL queries,
transactions, row/advisory locks, guarded migrations and durable command
receipts. There is no production in-memory repository fallback or required
Redis service. Mocks belong in tests.

The executable schema source is `docs/design/contracts/target-contract.mjs`.
Generators emit the full design contract and the implemented replacement
subset, copied into `src/http/contract.json`. Fastify compiles the emitted
JSON schemas for HTTP validation/serialization. Zod is the schema authoring
source, not a claim that every handler runs Zod parsing directly.

## Domain boundaries

- Auth: provider/phone/PIN verification, current database sessions and roles,
  refresh rotation, invite-only Ops accounts, superadmin controls and passkey elevation.
- Transport: catalog versions, schedules, trips, assignment, GPS/ETA and Ops reads.
- Membership: commute assignments, reservations, pauses, changes and priced offers.
- Payments: purchase snapshots, credit holds, verified collections, fulfilment,
  refunds/disputes, reviews, consent-based card renewals and period close.
- Boarding: reservation-specific proof and atomic ride settlement.
- Account: profile/avatar lifecycle, erasure, external cleanup and recovery journal.
- Notifications: durable inbox/outboxes and provider delivery.

Financial and authorization state stays in PostgreSQL. Client caches and local
GPS markers never establish entitlement, payment success or server receipt.

## Providers and background work

Paystack hosts customer-authorized checkout; signed webhook evidence and
verification/reconciliation determine fulfilment. mNotify sends phone codes and
temporary driver instructions. Resend sends transactional email; FCM sends
privacy-limited push messages. Provider acceptance is not handset delivery.

Private R2 objects hold avatars. Public basemap files are separate from private
storage. GPS uses authenticated HTTP uploads and scoped polling; there is no
active MQTT, Go, TimescaleDB or WebSocket path.

`src/worker.ts` runs explicit maintenance jobs through the same authorization
and transaction boundaries or bounded physical sweeps. Protected GitHub workflows
schedule staging payments/email and selected service jobs. Push deliveries use
bounded concurrency across accounts and remain a separately invoked worker.
A worker implementation is not an enabled schedule. See [deployment](DEPLOY.md).

## Safety and recovery

The API and maintenance logins do not own the schema. The protected installer
applies checksum-verified migrations and grants. Database guards reinforce
ownership, immutable money terms, receipt attribution and retention rules.

Account deletion has an independent closure journal and fenced restore workflow.
A restored snapshot must replay later closures before it can serve traffic.
See [recovery](design/account-erasure-recovery.md) and
[staging security](operations/staging-security.md).

Production readiness needs configuration and operational evidence beyond these
controls. No architecture document certifies legal compliance or measured capacity.
