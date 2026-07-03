# Grafana — API dashboard & alerts (#28 Phase 4)

Backend telemetry (metrics/traces/logs) flows to Grafana Cloud over OTLP
(`docs/design/observability.md`). This folder turns the **metrics** into an
importable dashboard + the alert rules that make us _page_, not just observe.

- **Datasource:** the stack's Prometheus (`grafanacloud-…-prom`).
- **Metric names** are OTel-via-OTLP (verified in the metric browser):
  `http_server_duration_milliseconds_*` (RED, **milliseconds**),
  `nodejs_eventloop_delay_p99_seconds`, `v8js_memory_heap_{used,limit}_bytes`.
- **Verify once:** the 5xx filter assumes the label is `http_status_code`. If your
  metric browser shows `http_response_status_code`, swap it in the queries below.

## Import the dashboard

Grafana → **Dashboards → New → Import** → upload
[`dashboards/trotxi-api-overview.json`](dashboards/trotxi-api-overview.json) →
pick your Prometheus datasource when prompted.

## Panels (PromQL, if you'd rather build by hand)

| Panel                     | Query                                                                                                                                                                                         |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Request rate (req/s)      | `sum(rate(http_server_duration_milliseconds_count[5m]))`                                                                                                                                      |
| Error rate (%)            | `100 * (sum(rate(http_server_duration_milliseconds_count{http_status_code=~"5.."}[5m])) or vector(0)) / clamp_min(sum(rate(http_server_duration_milliseconds_count[5m])) or vector(0), 1e-6)` |
| Latency p95 (ms)          | `histogram_quantile(0.95, sum by (le) (rate(http_server_duration_milliseconds_bucket[5m])))`                                                                                                  |
| Latency p99 (ms)          | `histogram_quantile(0.99, sum by (le) (rate(http_server_duration_milliseconds_bucket[5m])))`                                                                                                  |
| Latency p95 by route (ms) | `histogram_quantile(0.95, sum by (le, http_route) (rate(http_server_duration_milliseconds_bucket[5m])))`                                                                                      |
| Event-loop lag p99 (ms)   | `nodejs_eventloop_delay_p99_seconds * 1000`                                                                                                                                                   |
| Heap used vs limit (%)    | `100 * v8js_memory_heap_used_bytes / v8js_memory_heap_limit_bytes`                                                                                                                            |

## Alert rules (create in Alerting → Alert rules)

Thresholds come from `docs/design/observability.md §7`. Route **page** alerts to
`#alerts`/on-call; **notify** to the same channel without paging.

| Alert                   | Expression                                                                                                                                                                                    | Fires when                                                         | For | Tier      |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | --- | --------- |
| **API not reporting**   | `absent(http_server_duration_milliseconds_count)`                                                                                                                                             | metric absent (no OTLP arriving — service down or exporter broken) | 5m  | 🔴 page   |
| **High 5xx error rate** | `100 * (sum(rate(http_server_duration_milliseconds_count{http_status_code=~"5.."}[5m])) or vector(0)) / clamp_min(sum(rate(http_server_duration_milliseconds_count[5m])) or vector(0), 1e-6)` | `> 0.5`                                                            | 5m  | 🔴 page   |
| **High latency (p95)**  | `histogram_quantile(0.95, sum by (le) (rate(http_server_duration_milliseconds_bucket[5m])))`                                                                                                  | `> 300` (ms)                                                       | 10m | 🟠 notify |
| **Event-loop lag**      | `nodejs_eventloop_delay_p99_seconds`                                                                                                                                                          | `> 0.07` (70 ms)                                                   | 10m | 🟠 notify |
| **Memory near limit**   | `100 * v8js_memory_heap_used_bytes / v8js_memory_heap_limit_bytes`                                                                                                                            | `> 80`                                                             | 10m | 🟠 notify |

Notes:

- **Absence, not `up`:** we **push** OTLP (no Prometheus scrape target), so there's
  no `up` metric — `absent(...)` is the down-detector.
- **`absent()` detects total silence only.** Adequate while we run **one
  instance** (current). With >1 replica, a single crash-looping instance won't
  trip it (the healthy replicas keep reporting). Before scaling out: set
  `OTEL_RESOURCE_ATTRIBUTES=service.instance.id=$RENDER_INSTANCE_ID` on the
  service so metrics carry a per-instance label, then alert per instance (e.g.
  `count by (service_instance_id) (rate(http_server_duration_milliseconds_count[5m]))`
  dropping below the replica count).
- **Division is NaN/No-Data-proof:** the error-rate query uses
  `or vector(0)` + `clamp_min(..., 1e-6)`, so a zero-traffic window (3am) reads
  **0%**, never `0/0 = NaN` or an empty result. Belt-and-braces: still set the
  alert rule's **"No data" state to OK** (Alerting → rule → "Configure no data
  and error handling") so a datasource hiccup can't page either — the
  **API-not-reporting** rule is the one that owns "nothing is arriving".
- Add an external **uptime monitor** on `/healthz` (UptimeRobot/Better Stack free)
  as a second, independent down-signal (design §6).
- These are starting SLOs — calibrate the thresholds after a week of real traffic.
