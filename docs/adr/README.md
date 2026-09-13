# Architecture decision record

**Current-state review:** 2026-09-12

ADRs preserve the context and decision that existed when they were accepted.
They are not rewritten into feature documentation: a later decision supersedes
an earlier one, and implementation-status notes may be appended without
changing the original rationale. Current HTTP behaviour lives in
[`../features/`](../features/); generated `GET /docs/json` is the API contract.

## Decision map

| ADR                                                 | Decision                                   | Status in the current system                                                  |
| --------------------------------------------------- | ------------------------------------------ | ----------------------------------------------------------------------------- |
| [0001](0001-record-architecture-decisions.md)       | Record significant decisions               | Accepted; this index is the current navigation layer                          |
| [0002](0002-two-path-architecture.md)               | Separate transactional and telemetry paths | Accepted; HTTP position path live, dedicated telemetry path deferred          |
| [0003](0003-typescript-fastify-api.md)              | TypeScript/Fastify API                     | Accepted; Node 24, Fastify 5 and strict TypeScript live                       |
| [0004](0004-flutter-mobile.md)                      | Flutter mobile clients                     | Accepted; commuter and driver apps plus shared client/map packages exist      |
| [0005](0005-postgres-postgis.md)                    | PostgreSQL/PostGIS system of record        | Accepted; schema is at migration 038                                          |
| [0006](0006-mqtt-emqx-go-telemetry.md)              | MQTT/EMQX/Go telemetry                     | Accepted architecture, implementation deferred                                |
| [0007](0007-jwt-auth-guard.md)                      | JWT access tokens and route guards         | Accepted; social and driver session flows now build on it                     |
| [0008](0008-zod-openapi-contract.md)                | Zod drives validation and OpenAPI          | Accepted; generated Dart client consumes the contract                         |
| [0009](0009-repository-pattern.md)                  | Environment-selected repositories          | Accepted across current domain modules                                        |
| [0010](0010-kv-redis.md)                            | Redis-compatible KV with memory fallback   | Accepted; rate limits, boarding budgets and position cache use it             |
| [0011](0011-token-ledger.md)                        | Prepaid wallet ledger                      | Superseded by 0014; append-only pattern retained                              |
| [0012](0012-observability-otel-grafana-firebase.md) | OTel/Grafana/Firebase                      | Accepted; backend and both app SDK integrations live                          |
| [0013](0013-apiclient-error-handling.md)            | Generated Dio client and typed errors      | Accepted and implemented                                                      |
| [0014](0014-hybrid-subscription-model.md)           | Subscription entitlements and Ride Credits | Accepted; core live, standby deferred                                         |
| [0015](0015-fare-derived-pricing.md)                | Derive price from corridor fare            | Accepted and implemented; fare bands deferred                                 |
| [0016](0016-flutter-app-state.md)                   | Provider-scoped ChangeNotifier controllers | Accepted and implemented in driver app; commuter adoption remains incremental |

## Current architecture baseline

- The Fastify API is a modular monolith: routes → services → repositories.
- PostgreSQL/PostGIS is authoritative. Redis/KV is best-effort cache and abuse
  control, never financial truth.
- The commercial model is subscription ride entitlement plus Ride Credits. No
  wallet/top-up API exists.
- Prices are derived from effective-dated corridor fares and ops-editable plan
  levers, then snapshotted at checkout.
- Reservations enforce entitlement, route coverage and vehicle capacity.
- Boarding by QR, daily code or photo consumes one ride at most once.
- Drivers have first-party code/PIN credentials and assigned-run authorization.
- Live positions use HTTP polling for the pilot and feed batch route learning.
- All route schemas generate OpenAPI and the shared Dart client.
