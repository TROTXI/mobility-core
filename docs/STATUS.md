# Platform status & gap analysis

**Snapshot:** 2026-06-26 · a point-in-time map of `mobility-core`. Update as
areas land; it is not authoritative once the code moves.

## Architecture (what exists)

`services/api` — Fastify 5 + TypeScript (Node 24), single process, layered
`server.ts → buildApp (app.ts) → plugins/routes → repositories`.

| Layer        | Modules                                                                                                                                   |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
| Config       | `config/env.ts` (zod-validated env), `config/dotenv.ts`                                                                                   |
| Data         | `db/migrate.ts` (runner), `db/pool.ts`; migrations `001_init` (users, auth_identity, sessions), `002`/`003` (subscriptions + constraints) |
| KV           | `kv/kv.store.ts` (interface + in-memory), `kv.store.redis.ts` (ADR-0010)                                                                  |
| Auth         | `auth/jwt.ts`, `auth/auth.plugin.ts` (`authenticate`/`requireRole`), `auth/auth.routes.ts` (`/me`) (ADR-0007)                             |
| Rate limit   | `ratelimit/ratelimit.plugin.ts` (#23)                                                                                                     |
| Domain repos | `users/*`, `subscriptions/*` — **repos only, no routes**                                                                                  |
| Contract     | `lib/schemas.ts`, `user.schema.ts`, OpenAPI via zod type-provider (ADR-0008)                                                              |

**Live HTTP surface:** `/`, `/version`, `/healthz`, `/readyz`, `/me`, `/docs`.

**Cross-cutting (in place):** repository pattern (ADR-0009), KV fallback
(ADR-0010), readiness pings DB+KV, rate limiting, typed OpenAPI, ~100% unit
coverage, CI + security gates (gitleaks/CodeQL/audit), CD (migrate→deploy,
staging auto / prod gated), CODEOWNERS + code-owner reviews.

## Gaps

### 🔴 Auth is half-built (highest impact)

- **No sign-in** — no `/auth/google` / `/auth/apple`, no ID-token verification
  (slice 2). Blocks the mobile login flow (#34).
- **`sessions` and `auth_identity` tables exist but are unused** — no refresh
  tokens, rotation, revoke, or logout. The refresh half of ADR-0007 is unbuilt.

### 🟡 Subscriptions

- Data layer only — **no endpoint** (e.g. `GET /me/subscription`); not usable
  over HTTP. `plan` is free-text (no enum/CHECK). In-memory repo does not enforce
  one-active-per-user (the DB does — see ADR-0009).

### ❌ Not started (mapped to issues)

| Area                                    | Issue         | Notes                                   |
| --------------------------------------- | ------------- | --------------------------------------- |
| Mobility (routes/stops/trips, PostGIS)  | #17/#18/#25   | PostGIS enabled, no spatial tables      |
| Token ledger & payments (Paystack)      | #21           | no tables/logic (CTO)                   |
| QR boarding / passes / scan_events      | #20           | none (CTO)                              |
| Avatar upload → R2                      | #24           | none                                    |
| Observability (RED metrics, `/metrics`) | #28           | only default pino logs                  |
| Feature flags + force-update            | #27           | none                                    |
| Account deletion                        | #30           | none                                    |
| Flutter apps                            | #32+          | `apps/` is a README — no scaffold       |
| Telemetry (MQTT→Go)                     | ADR-0002/0006 | EMQX in compose, no pipeline (deferred) |

### 🟡 Architecture notes

- **No service layer** yet — routes call repositories directly. Fine at this size;
  introduce `routes → services → repositories` before real business logic lands.
- e2e is minimal — no DB-backed flows (ci.yml has a TODO for a postgis service
  container + seed).

## ADR status

- **0003** (TS+Fastify) — amended for Node 24 (was 22).
- **0007** (JWT) — accurate; rate limiting it cited as "slice 3" has since landed (#23).
- **0009** (repository pattern), **0010** (KV/Redis) — added to record patterns
  that were previously only in code comments.

## Suggested next

1. **Auth slice 2** (sign-in + refresh) — the biggest unblock; needs Google OAuth
   setup.
2. `GET /me/subscription` — make subscriptions a real, secured, documented API.
3. Observability (#28) — `/metrics` + structured fields, before traffic grows.
