# Trotxi API

This is the current backend used by the apps and Ops, not an undeployed
replacement experiment. Source audit: 2026-10-03.

## Entry points and boundaries

- `src/server.ts`: validated configuration, composition and HTTP listener.
- `src/runtime/compose.ts`: production adapters and domain services.
- `src/http/app.ts`: metadata, admission, auth, routing and schemas.
- `src/worker.ts`: explicit maintenance invocation.
- `src/erasure-recovery-cli.ts`: controlled restore/closure replay.
- `src/db/` and `migrations/`: checksum-verified migration/install/grant logic.

PostgreSQL/PostGIS is authoritative for sessions, transport, membership,
financial state, admission and outboxes. Runtime uses restricted credentials.
There is no Redis or in-memory persistence fallback in deployed composition.

## Implemented domains

Catalog versions/schedules and fleet; social/phone/driver auth and Ops passkeys;
driver credentials via email/SMS; profile/avatars/erasure; trip lifecycle/GPS;
reservation-based boarding; subscription requests and priced offers; Paystack
collections, refunds/disputes/recovery; period-owned rides and credit; prepaid
renewals; pauses/commute changes; notifications; Ops read models/audit/config.

Start at the [feature index](../../docs/features/README.md) and
[architecture](../../docs/architecture.md). Use the [developer guide](../../docs/development.md) for code locations and
verification. Contract tooling retains generated inventories used by CI.

## Contract

Author schemas in `docs/design/contracts/target-contract.mjs` and regenerate
from the repository root:

```sh
node docs/design/scripts/build-contract.mjs
node docs/design/scripts/build-transport-contract.mjs
node --test docs/design/scripts/contract.test.mjs
pnpm --filter @trotxi/ops codegen
pnpm codegen:replacement
```

Follow Dart generation with `dart run build_runner build` in
`apps/api_client`, and format generated clients. Never hand-edit emitted JSON.
Most product operations use `/v1`; see the implemented contract for exceptions,
cursor parameters, metadata, idempotency keys and edit preconditions.

## Local checks

Use Node 24 and the repository's pinned pnpm.

```sh
pnpm --filter @trotxi/api-next typecheck
pnpm --filter @trotxi/api-next test
pnpm --filter @trotxi/api-next build
```

Postgres tests require an explicitly disposable loopback PostGIS instance.
Supply `HARNESS_ADMIN_DATABASE_URL` privately and set
`HARNESS_ALLOW_CREATE_DATABASES=1`, then run
`pnpm --filter @trotxi/api-next test:postgres`. Tests run serially and create
their own databases. Never point the harness at staging or production.

## Installation and maintenance

The protected deployment installer uses the owner connection to apply migrations
and refresh grants. API startup verifies the expected migration inventory and
restricted permissions; it does not provision roles or apply migrations.
See [deployment](../../docs/DEPLOY.md) and
[staging security](../../docs/operations/staging-security.md).

`node dist/worker.js <job>` runs a job, not a scheduler. Service-day jobs
add the date and outbound/return direction. The authoritative job list is
`src/runtime/maintenance.ts`: payments, personal-pause-resumes, ask-dispatch,
reservation-defaults, no-shows, route-learning, gps-retention,
incident-retention, payment-evidence-retention, erasures, driver-secrets,
admission, emails, trip-generation and push.

Workers use a configured non-human maintenance identity and restricted login.
Receipts/audit and bounded failure results matter even when no human pressed
a button. The GitHub 15-minute workflow covers payment recovery and email
retry only; other workers require explicit invocation or approved scheduling.
