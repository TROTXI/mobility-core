# Platform status & gap analysis

**Snapshot:** 2026-07-08 · a point-in-time map of `mobility-core`. Update as
areas land; it is not authoritative once the code moves.

## Architecture (what exists)

`services/api` — Fastify 5 + TypeScript (Node 24), single process, layered
`server.ts → buildApp (app.ts) → plugins → routes → services → repositories`.
The **service layer now exists** (business logic no longer lives in routes):
`AuthService`, `PaymentsService`, `BoardingService`, `ManifestService`,
`AskDispatchService`, `CreditService`.

| Layer         | Modules                                                                                                                                                                                                      |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Config        | `config/env.ts` (zod-validated env), `config/dotenv.ts`                                                                                                                                                      |
| Data          | `db/migrate.ts` (runner + `_migrations` table), `db/pool.ts`; migrations `001`–`020` (auth, subscriptions, mobility, payments, ledgers, reservations, boarding PIN, flags, route pinning, credit conversion) |
| KV            | `kv/kv.store.ts` (interface + in-memory), `kv.store.redis.ts` (ADR-0010)                                                                                                                                     |
| Object store  | `storage/object-store.ts` (Fake) + `object-store.r2.ts` (Cloudflare R2, #24)                                                                                                                                 |
| Auth          | `auth/jwt.ts`, `auth/auth.plugin.ts` (`authenticate`/`requireRole`), `auth.service.ts`, Google verifier (ADR-0007)                                                                                           |
| Rate limit    | `ratelimit/ratelimit.plugin.ts` (#23)                                                                                                                                                                        |
| Observability | `observability/tracing.live.ts` (OTel → Grafana/Tempo), `metrics/metrics.plugin.ts` (Prometheus `/metrics`, RED) (#28, ADR-0012)                                                                             |
| Contract      | zod schemas per module, OpenAPI via zod type-provider (ADR-0008), Swagger UI at `/docs`                                                                                                                      |

**Cross-cutting (in place):** repository pattern (ADR-0009, InMemory + Pg
selected by `DATABASE_URL`), KV fallback (ADR-0010), readiness pings DB+KV,
rate limiting, typed OpenAPI, OTel tracing + Prometheus metrics, push
notifications (FCM), CI + security gates (gitleaks/CodeQL/pnpm-audit), CD
(migrate→deploy, staging auto / prod gated), CODEOWNERS reviews.

**Live HTTP surface (main):**

- **Public:** `/`, `/version`, `/healthz`, `/readyz`, `/docs`, `/flags`, `/routes`, `/routes/:id`, `/webhooks/paystack`
- **Auth:** `/auth/google`, `/auth/refresh`, `/auth/logout`, `/me`, `/me/sessions`, `DELETE /me/sessions/:id`
- **Rider:** `/me/avatar`, `/me/devices`, `/me/rides`, `/me/reservations`, `/me/pass`, `/payments/subscribe`, `/trips`, `/trips/:id`, `/trips/:id/position`
- **Driver:** `/boarding/scan`, `/boarding/verify-pin`, `/boarding/manifest`
- **Admin/ops:** `/admin/{routes,stops,vehicles,drivers,trips}` CRUD + `/admin/trips/:id/assignment`, `/admin/users/:id/role`, `/admin/flags`, `/admin/min-versions`, `/admin/ask-dispatch`, `/admin/resolve-defaults`, `/admin/convert-credits`
- **Metrics:** `/metrics` (token-gated)

## Status by domain

### 🟢 Auth (ADR-0007)

Google **sign-in** (`/auth/google`, ID-token verification), **refresh** tokens
(`/auth/refresh`, rotation), **logout**, **sessions** (`/me/sessions`), and
**role grant** (`PATCH /admin/users/:id/role`). JWT HS256 + `requireRole` RBAC.
_Missing:_ Apple sign-in (#34 covers the app side).

### 🟢 Mobility

Routes/stops (public browse, PostGIS), **trips** (#18 — `/trips`, `/trips/:id`),
**admin fleet CRUD + trip assignment** (#26), **live positions** (#25 —
`POST/GET /trips/:id/position`, assigned-driver-gated, deterministic ETA).
_Missing:_ nearest-stop spatial endpoint (GiST index is in place).

### 🟢 Users / media

`/me`, avatar upload → **Cloudflare R2** (#24, sharp resize + EXIF strip).

### 🟡 Money — Hybrid Subscription Model (ADR-0014, epics E1–E7)

The wallet model was dropped for the **Hybrid Subscription Model**: a
subscription buys a **ride entitlement**; unused rides become **Ride Credits**
against renewal; **no prepaid wallet**. Append-only, idempotent ledgers.

| Epic         | Area                                                                                                                                                                                                                      | State                                            |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| **E1**       | Entitlement + credit ledgers, `/me/rides`, allocation on paid webhook                                                                                                                                                     | ✅ live                                          |
| **Payments** | Paystack `/payments/subscribe` + `/webhooks/paystack` (HMAC-verified)                                                                                                                                                     | ✅ live                                          |
| **E3**       | Reservations (`/me/reservations` confirm/decline + daily PIN), scheduled **ask-dispatch** (`/admin/ask-dispatch`, `/admin/resolve-defaults`), rider↔route pinning, **FCM push** (real, behind `FIREBASE_SERVICE_ACCOUNT`) | ✅ live                                          |
| **E4**       | Boarding: QR scan + daily PIN + manifest (assigned-driver-gated), ride **deduction**                                                                                                                                      | ✅ live · **no-show deduction in review (#132)** |
| **E5**       | Month-end **credit conversion** (`/admin/convert-credits`)                                                                                                                                                                | ✅ live (placeholder per-ride value)             |
| **E1b**      | Plan tiers + pricing (#103)                                                                                                                                                                                               | 🔴 **blocked: product pricing**                  |
| **E5b**      | Credit-netted renewal + auto-renew (#128)                                                                                                                                                                                 | 🔴 **blocked: credit value**                     |
| **E6**       | Standby pool (KYC + offer cascade + instant fare, #105)                                                                                                                                                                   | 🔴 **blocked: fare + KYC**                       |
| **E7**       | Drop legacy `token_ledger` table (#106)                                                                                                                                                                                   | **in review (#130)**                             |

Fees, rides-per-period, and per-ride credit value are **placeholder constants**
(`payments.service.ts`, `credit.service.ts`) until pricing is decided — the
mechanisms are built; only the numbers change.

### 🟢 Notifications / devices

FCM device-token registry (`/me/devices`, #84), real `FcmNotificationSender`
behind `FIREBASE_SERVICE_ACCOUNT` (set + confirmed live on staging), recording
fake otherwise.

### 🟢 Flags / force-update (#27)

Public `/flags` (feature flags + min supported version), admin `/admin/flags`
and `/admin/min-versions`.

### 🟢 Observability (#28, ADR-0012)

OTel tracing → Grafana Cloud (Tempo), Prometheus `/metrics` (RED, token-gated),
structured pino logs.

## In review (open PRs)

- **#130** — E7: drop legacy `token_ledger` table (+ ADR-0011 marked superseded).
- **#131** — chore: bump vitest 2 → 4 (coordinated with coverage-v8 + vite).
- **#132** — E4: confirmed-yes no-show deduction (`/admin/resolve-no-shows`).

## Not started / other lanes

| Area                                                      | Issue         | Owner / note                              |
| --------------------------------------------------------- | ------------- | ----------------------------------------- |
| Account deletion (data-subject rights)                    | #30           | Foyade                                    |
| Apple sign-in                                             | #34           | FE lane                                   |
| Flutter apps (auth, home, subscribe, board, map, history) | #34–41        | adomfosugit / FE                          |
| Commuter app: handle ask-dispatch push                    | #125          | adomfosugit                               |
| Activate ask-dispatch cron on Render                      | #126          | CTO (ops)                                 |
| Convert-credits / no-show **cron schedules**              | —             | needs a product-timing decision           |
| Paystack nightly reconciliation                           | —             | deferred with the money work              |
| MQTT→Go telemetry pipeline                                | ADR-0002/0006 | deferred (HTTP polling is the pilot path) |

## ADR status

- **0007** (JWT) — sign-in + refresh + rate limiting have all landed.
- **0009** (repository pattern), **0010** (KV/Redis) — in force across the codebase.
- **0011** (token wallet ledger) — **superseded by 0014** (wallet dropped; the
  append-only-ledger _pattern_ is reused by the entitlement + credit ledgers).
- **0014** (Hybrid Subscription Model) — the active money ADR (epics E1–E7).

## Highest-leverage next step

**Pilot pricing decisions** (per-ride credit value, plan tiers/prices, standby
fare) unblock **E1b, E5b, and E6** at once — the mechanisms are already built and
only need real numbers.
