# Grafana: Trotxi API health

The API sends metrics, traces and logs to Grafana Cloud over OTLP
(`services/api-next/src/observability/telemetry.ts`). This folder turns the
metrics into one dashboard and a set of alert rules, both applied by a script.

- [`dashboards/trotxi-api-health.json`](dashboards/trotxi-api-health.json): the dashboard.
- [`alerts/trotxi-api.json`](alerts/trotxi-api.json): the alert rules.
- [`apply.mjs`](apply.mjs): puts both into a Grafana stack. Safe to rerun.

## Apply

1. In Grafana Cloud: **Administration → Users and access → Service accounts →
   Add service account**, role **Admin**, then **Add service account token**.
   Admin is needed because alert rule provisioning is an admin action.
2. Keep the token in your shell, never in the repo or a chat:

   ```sh
   export GRAFANA_URL=https://<stack>.grafana.net
   export GRAFANA_TOKEN=<token>
   node ops/grafana/apply.mjs --job staging/trotxi-api
   ```

3. It prints the dashboard link. Rerun it after changing anything here.

`--job` is the service to watch. Every series carries
`job="<environment>/<service>"`: the environment comes from the
`service.namespace` resource attribute the API sets, so staging and production
never share a graph or an alert. Run the script once per environment; each gets
its own alert group (`trotxi-api-staging`, `trotxi-api-production`).

Alerts go to the stack's default notification policy, which on a new Grafana
Cloud stack emails the account owner. To route `severity=page` somewhere
louder, add a contact point and a notification policy matching that label in
**Alerting → Notification policies**.

## What the dashboard answers

| Row                           | Question                                                                      |
| ----------------------------- | ----------------------------------------------------------------------------- |
| Service level                 | Is it up, fast and correct right now? Which commit is running?                |
| Latency                       | How long do requests take, and which routes are slow or busy?                 |
| Reliability                   | What fails, where, and which scheduled jobs failed?                           |
| Responsiveness and saturation | Is the single JavaScript thread keeping up? Is the database pool exhausted?   |
| Memory                        | Resident memory against the 256 MB plan, heap, and garbage collection time.   |
| Dependencies                  | Latency and failures of calls to Paystack, Google, email, push and storage.   |
| Operations                    | Paystack inbox age, unresolved purchases, live runs, stale GPS, riders today. |

Deploys appear as annotations when a new `service_version` (the Render commit)
starts reporting.

## Alerts

| Alert                                           | Severity | Fires when                                                                                                                |
| ----------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------- |
| API is not reporting                            | page     | no metrics for about 5 minutes                                                                                            |
| Server errors above 2%                          | page     | 5xx share over 2% for 10 minutes, with real traffic                                                                       |
| Paystack payments are not being applied         | page     | oldest unapplied Paystack event older than 15 minutes                                                                     |
| Payment and trip state is not being reported    | page     | the API reports but its state query has returned nothing for 5 minutes, which blinds the payment, purchase and GPS alerts |
| Memory near the plan limit                      | notify   | resident memory over 200 MB for 10 minutes                                                                                |
| Requests are slow (p95 over 1s)                 | notify   | for 15 minutes, with real traffic                                                                                         |
| Event loop is blocked                           | notify   | p99 delay over 200 ms for 10 minutes                                                                                      |
| Requests are waiting for a database connection  | notify   | any request queued for a connection for 5 minutes                                                                         |
| A scheduled job failed                          | notify   | any failed maintenance run in the last 30 minutes                                                                         |
| A purchase has been unresolved for over an hour | notify   | for 10 minutes                                                                                                            |
| A bus on a live run has stopped reporting       | notify   | any run in progress without recent GPS for 10 minutes                                                                     |
| A third-party service is failing                | notify   | outbound 5xx or connection errors for 10 minutes                                                                          |

These thresholds are pilot starting points. Recalibrate after a few weeks of
real traffic; the rules stay editable in the Grafana UI, and the next apply puts
back what is committed here, so commit any threshold you keep.

## Things to know

- **Metrics arrive once a minute.** The SDK exports every 60 seconds, which
  keeps the free tier's data-points-per-minute allowance. Every graph therefore
  has a 2 minute minimum interval, so each rate window holds two samples;
  anything shorter draws nothing.
- **Grafana Cloud keeps only `job` and `instance` as labels** from the resource.
  Version, host and environment live on `target_info`. Queries filter on `job`
  and `instance` only.
- **Silence is detected with `absent_over_time` on memory**, which is reported
  every export whether or not there is traffic, so a quiet night is not an
  outage. For an independent check from outside, add a Grafana Cloud Synthetic
  Monitoring HTTP check on `https://trotxi-api-staging.onrender.com/healthz`
  (free tier).
- **Mobile crash and performance data** stays in Firebase Crashlytics and
  Performance, per `docs/design/observability.md`.
- **Checking changes locally**: run `grafana/otel-lgtm` in Docker, point
  `OTEL_EXPORTER_OTLP_ENDPOINT` at it, and run `apply.mjs` against
  `http://localhost:3000` with a local service account token.
