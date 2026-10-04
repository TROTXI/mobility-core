# Observability

Source audit: 2026-10-03. Configuration support is not evidence that an exporter,
dashboard, alert rule or contact point is enabled in a deployed environment.

## Implemented backend signals

`services/api-next/src/observability/telemetry.ts` initializes OpenTelemetry
before Fastify and Postgres imports. The ES module loader hook is required.
Configured OTLP exporters send traces, metrics and Pino logs; without an endpoint,
local/dev execution does not require a collector.

Instrumentation covers HTTP, Fastify, Postgres, Pino and Node runtime metrics.
Resources include environment namespace, service, deployed commit and instance.
Default service name is `trotxi-api`; use separate environment labels.

`metrics.ts` reads business state from the database: payment inbox count/age,
quarantined events, unresolved purchases, active/stale/unassigned trips and
boarding/no-show/reservation counts. Database-backed backlog metrics survive
restarts and can reveal a worker that never ran.

Maintenance results record `trotxi_job_runs` by operation and outcome.
An HTTP 200 containing failed items still counts as failure. Successful empty
batches do not establish delivery or completed financial work.

## Privacy

- Incoming health/readiness probes are excluded from HTTP traces.
- Search/cursor/token/code query parameters are redacted; Fastify paths omit
  query strings.
- mNotify outbound HTTP instrumentation is excluded because its key is in the URL.
- Postgres instrumentation does not report parameter values.
- Never add request bodies, PINs, OTPs, bearer tokens or personal details to
  diagnostic logs.

Inspect `logging.ts` and deployment redaction settings before adding new fields.
Telemetry shutdown cannot prevent process exit.

## Mobile and operations

The apps include Firebase instrumentation, subject to platform configuration.
Device delivery and crash-report visibility need separate verification.
Ops exposes operational state, audit events and payment reviews; it is not a
replacement for provider delivery receipts or infrastructure alerting.

The current API has no Go/MQTT service, Redis cache, or Timescale pipeline.
Do not configure alerts around those retired architecture assumptions.

## Operational checks

1. Verify the deployed commit and configured OTLP destination without printing secrets.
2. Confirm a safe request produces a trace, correlated log and database span.
3. Check payment inbox age and quarantine, not only API availability.
4. Check maintenance failures and missing executions, not only scheduler success.
5. Exercise an approved test alert and confirm the intended recipient receives it.
6. Measure latency, database waits, memory and event-loop delay before changing capacity.

Thresholds, SLOs and contact points need measured baselines and explicit
operations ownership. This source review does not certify existing Grafana setup.

See [performance](../operations/request-performance.md),
[deployment](../DEPLOY.md), [payments](../features/payments-and-wallet.md)
and [live positions](../features/live-positions.md).
