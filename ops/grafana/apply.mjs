#!/usr/bin/env node
/**
 * Puts the Trotxi API dashboard and its alert rules into a Grafana stack.
 *
 *   GRAFANA_URL=https://<stack>.grafana.net GRAFANA_TOKEN=<service account token> \
 *     node ops/grafana/apply.mjs --job staging/trotxi-api
 *
 * The token is a Grafana service account token with the Admin role (alert rule
 * provisioning needs it). Keep it in your shell, never in the repo or a chat.
 *
 * Safe to rerun: the dashboard is overwritten by uid, the alert group is
 * replaced as a whole, and the folder is created only once. Rules stay
 * editable in the Grafana UI; the next run puts back what is in this folder.
 */
import { readFile } from 'node:fs/promises';

const args = Object.fromEntries(
  process.argv
    .slice(2)
    .join(' ')
    .split('--')
    .filter(Boolean)
    .map((part) => part.trim().split(/\s+/)),
);
const job = args.job;
const url = process.env.GRAFANA_URL?.replace(/\/$/, '');
const token = process.env.GRAFANA_TOKEN;
if (!url || !token || !job) {
  console.error(
    'Usage: GRAFANA_URL=… GRAFANA_TOKEN=… node ops/grafana/apply.mjs --job staging/trotxi-api',
  );
  process.exit(2);
}
if (!/^[a-z]+\/[a-z0-9-]+$/.test(job)) {
  console.error('--job must look like <environment>/<service>, for example staging/trotxi-api');
  process.exit(2);
}
const environment = job.split('/')[0];
const FOLDER = 'trotxi';

async function grafana(method, path, body, headers = {}) {
  const response = await fetch(`${url}${path}`, {
    method,
    headers: {
      authorization: `Bearer ${token}`,
      'content-type': 'application/json',
      ...headers,
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await response.text();
  if (!response.ok && !(method === 'GET' && response.status === 404))
    throw new Error(`${method} ${path} → ${response.status}: ${text.slice(0, 400)}`);
  return { status: response.status, body: text ? JSON.parse(text) : null };
}

// The stack's Prometheus (Mimir) data source. Grafana Cloud names it
// grafanacloud-<stack>-prom; GRAFANA_PROMETHEUS_UID picks one explicitly.
const sources = (await grafana('GET', '/api/datasources')).body.filter(
  (source) => source.type === 'prometheus',
);
const prometheus = process.env.GRAFANA_PROMETHEUS_UID
  ? sources.find((source) => source.uid === process.env.GRAFANA_PROMETHEUS_UID)
  : (sources.find((source) => /^grafanacloud-.+-prom$/.test(source.name)) ??
    (sources.length === 1 ? sources[0] : undefined));
if (!prometheus) {
  console.error(
    `Could not choose a Prometheus data source from: ${sources.map((s) => `${s.name} (${s.uid})`).join(', ') || 'none'}. Set GRAFANA_PROMETHEUS_UID.`,
  );
  process.exit(1);
}

if ((await grafana('GET', `/api/folders/${FOLDER}`)).status === 404)
  await grafana('POST', '/api/folders', { uid: FOLDER, title: 'Trotxi' });

const dashboard = JSON.parse(
  await readFile(new URL('./dashboards/trotxi-api-health.json', import.meta.url), 'utf8'),
);
for (const variable of dashboard.templating.list) {
  if (variable.name === 'datasource')
    variable.current = { text: prometheus.name, value: prometheus.uid };
  if (variable.name === 'job') variable.current = { text: job, value: job };
}
const saved = await grafana('POST', '/api/dashboards/db', {
  dashboard: { ...dashboard, id: null },
  folderUid: FOLDER,
  overwrite: true,
  message: 'Applied from mobility-core ops/grafana',
});

const { rules } = JSON.parse(
  await readFile(new URL('./alerts/trotxi-api.json', import.meta.url), 'utf8'),
);
const group = `trotxi-api-${environment}`;
const seconds = (duration) => {
  const match = /^(\d+)([smh])$/.exec(duration);
  if (!match) throw new Error(`Unreadable duration ${duration}`);
  return Number(match[1]) * { s: 1, m: 60, h: 3600 }[match[2]];
};
await grafana(
  'PUT',
  `/api/v1/provisioning/folder/${FOLDER}/rule-groups/${group}`,
  {
    title: group,
    folderUid: FOLDER,
    interval: 60,
    rules: rules.map((rule) => ({
      uid: `trotxi-${environment}-${rule.key}`.slice(0, 40),
      title: `${rule.title} (${environment})`,
      ruleGroup: group,
      folderUID: FOLDER,
      condition: 'C',
      for: rule.for,
      noDataState: rule.noData,
      execErrState: 'Error',
      labels: { severity: rule.severity, service: job },
      annotations: {
        summary: rule.summary,
        description: rule.description,
        dashboardUId: dashboard.uid,
      },
      data: [
        {
          refId: 'A',
          datasourceUid: prometheus.uid,
          relativeTimeRange: { from: Math.max(600, seconds(rule.for) + 300), to: 0 },
          model: {
            refId: 'A',
            expr: rule.expr.replaceAll('$job', job),
            instant: true,
            range: false,
          },
        },
        {
          refId: 'C',
          datasourceUid: '__expr__',
          relativeTimeRange: { from: 0, to: 0 },
          model: {
            refId: 'C',
            type: 'threshold',
            expression: 'A',
            conditions: [{ evaluator: { type: 'gt', params: [rule.above] } }],
          },
        },
      ],
    })),
  },
  // Leaves the rules editable in the UI for tuning thresholds on the spot.
  { 'X-Disable-Provenance': 'true' },
);

console.log(
  JSON.stringify(
    {
      dashboard: `${url}${saved.body.url}?var-job=${encodeURIComponent(job)}`,
      alertRules: rules.length,
      group,
      datasource: prometheus.name,
    },
    null,
    2,
  ),
);
