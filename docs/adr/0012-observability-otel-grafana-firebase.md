# ADR-0012 — Observability: OpenTelemetry + Grafana Cloud + Firebase (free-tier)

**Status:** accepted · **Date:** 2026-06-28

## Context

We need to track **latency, memory, responsiveness, and reliability** across the
Fastify API and its dependencies, the infra, and both Flutter apps (#28).
Constraints: **cost** — free tiers only (we pay only for DB, Paystack, and cloud
hosting), a **small team** (no SRE), and **no PII/secrets** in telemetry (a money
product under Act 843). Full design: [`docs/design/observability.md`](../design/observability.md).

## Decision

- **Instrumentation standard: OpenTelemetry (OTel)** — vendor-neutral; auto-
  instruments Fastify/`pg`/`ioredis`/`http`. We can repoint at a different
  backend without re-instrumenting the code.
- **Backend metrics / traces / logs: Grafana Cloud free tier** (managed — not
  self-hosted, so no extra paid Render services).
- **Mobile RUM + crashes: Firebase Crashlytics + Performance** (free).
- **Sentry deferred**; a paid APM (Datadog / New Relic) is a later, deliberate
  choice only if scale demands it.
- **Phase 1 (this slice):** expose `GET /metrics` via `prom-client` — a RED
  histogram (`http_request_duration_seconds`) plus Node runtime metrics
  (memory, event-loop lag, GC). Token-gated; disabled (404) in production when no
  token is set, same fail-safe posture as payments/sign-in.

## Consequences

- All four signals are covered end-to-end at **$0** on top of existing spend.
- One standard (OTel) scales to the future Go telemetry service + MQTT.
- We must **stay inside free-tier limits** (sampling + short retention; alert and
  revisit before any paid threshold) and **scrub PII/secrets** from telemetry.
- `/metrics` is kept out of the public OpenAPI and is token-gated; scrapers
  (Grafana Agent) authenticate with `Authorization: Bearer <METRICS_TOKEN>`.
- Remaining for Phase 1: a Grafana Cloud account + scrape config + dashboards and
  the first alerts (external account setup, like Google/Paystack).
