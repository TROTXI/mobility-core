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
- **Backend metrics:** export HTTP RED, Node runtime and business metrics over
  OTLP alongside traces and logs. The replacement API does not expose
  `GET /metrics` or use `prom-client`.

## Consequences

- All four signals are covered end-to-end at **$0** on top of existing spend.
- One standard (OTel) scales to the future Go telemetry service + MQTT.
- We must **stay inside free-tier limits** (sampling + short retention; alert and
  revisit before any paid threshold) and **scrub PII/secrets** from telemetry.
- No metrics HTTP endpoint or scraper credential is needed. Keep the OTLP
  exporter endpoint and authentication header in Render's secret configuration.
- Remaining: import the committed dashboard and alert rules into Grafana Cloud
  and test notification delivery.
- **In-house dashboards / a self-hosted stack stay a deferred, open option** — we
  own the data via OTel/Prometheus, so no lock-in. Managed free tiers are chosen
  now because a dashboard is the easy part; the storage/query/alerting (and, for
  mobile, the crash SDK + symbolication) is the costly 90%, and self-hosting it
  would cost more (ops + Render spend) than the free managed tiers. Revisit only
  if scale makes a paid tier costlier than running our own. (Grafana itself is the
  OSS tool we author our own dashboards in.)

## Update — 2026-06-28 (implemented & live)

Built and live on staging (Phases 0–2): **traces, metrics, and logs all push to
Grafana Cloud over a single OTLP endpoint** — no Grafana Alloy/scraper. So the
scrape configuration is unnecessary: metrics go over OTLP push too (the only env
vars needed are `OTEL_EXPORTER_OTLP_ENDPOINT` + `OTEL_EXPORTER_OTLP_HEADERS`).
The protobuf exporter is used (Grafana's default); `protobufjs`'s build script is
skipped (works from prebuilt dist). There is no local/debug pull path or
`METRICS_TOKEN` in the replacement implementation.
The dashboard and alert definitions are committed under `ops/grafana`; import
and production notification wiring remain. Firebase Crashlytics and Performance
are now integrated in both Flutter apps, subject to valid release-project
configuration. See `docs/design/observability.md` for the operating guide.
