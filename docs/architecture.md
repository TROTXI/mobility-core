# Architecture

## System context

Three user-facing surfaces and a small set of external integrations:

- **Commuter app** (Flutter) — subscribe, browse routes/trips, board with a QR
  pass, watch the vehicle live.
- **Driver app** (Flutter) — see assigned trips, scan rider passes, publish GPS.
- **Ops dashboard** (web, later) — manage routes, trips, vehicles, drivers.
- **External**: mobile-money aggregator (MTN MoMo / Telecel / AirtelTigo via
  Paystack or Hubtel), SMS/OTP provider, map tiles.

## Two decoupled paths

The defining decision (see [ADR-0002](adr/0002-two-path-architecture.md)):
latency-critical telemetry never blocks on business logic, and product
iteration never destabilises the live map.

```
TRANSACTIONAL PATH                      TELEMETRY PATH (post-MVP)
apps                                    driver app (GPS)
  │ HTTPS/JSON                            │ MQTT, QoS 1
  ▼                                       ▼
Node.js + TypeScript API (Fastify)      EMQX broker
  │                                       │
  ▼                                       ▼
PostgreSQL + PostGIS                    Go geo-processor
                                          │
                              ┌───────────┴───────────┐
                              ▼                       ▼
                            Redis  ◄── read by API  WebSocket fan-out
                         (live cache)               → commuter app
```

Until pilot scale demands the right-hand path, the API serves vehicle
positions over plain HTTP polling — same endpoints, simpler engine. The
interfaces are designed so the telemetry path can replace the implementation
without touching clients.

## Transactional API

Layered: **routes → services → repositories**, dependencies injected through
`buildApp(deps)`.

- Routes validate input (zod) and translate domain errors to HTTP.
- Services own business rules (subscription guards, boarding rules, payment
  lifecycle) and are unit-tested in isolation.
- Repositories come in pairs: in-memory (tests, zero-infra dev) and Postgres
  (real runs). The choice happens once, at startup, by environment.

## Environments & delivery

```
PR → CI (typecheck · lint · unit · e2e) → merge to main
   → staging deploys automatically → smoke test
   → production after manual approval
```

`main` is protected: all checks must pass on an up-to-date branch. See
[DEPLOY.md](DEPLOY.md).

## Data protection & compliance

Ghana Data Protection Act, 2012 (Act 843) applies: minimal PII, encrypted in
transit and at rest, audit log on money-touching mutations. Mobile-money flows
ride on a licensed aggregator — we never hold value ourselves.
