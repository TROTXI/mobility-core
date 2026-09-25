import assert from 'node:assert/strict';
import test from 'node:test';
import { Writable } from 'node:stream';
import Fastify from 'fastify';
import { Pool } from 'pg';
import { loggerOptions } from '../src/observability/logging.js';
import { createTransportApp } from '../src/http/app.js';
import type { ConfigService } from '../src/config/service.js';
import { readFile } from 'node:fs/promises';
import { metrics } from '@opentelemetry/api';
import {
  AggregationTemporality,
  InMemoryMetricExporter,
  MeterProvider,
  PeriodicExportingMetricReader,
} from '@opentelemetry/sdk-metrics';
import { batchFailed, observeProcess, recordJob } from '../src/observability/metrics.js';
import { startTelemetry } from '../src/observability/telemetry.js';

test('OBS-01 no collector configured means no telemetry, not an error', () => {
  assert.equal(startTelemetry({}), false);
});

test('OBS-02 a job only succeeded if nothing inside it failed', () => {
  const clean = { data: { considered: 3, succeeded: 3, blocked: 0, failed: 0, failures: [] } };
  assert.equal(batchFailed(200, clean), false);
  // A 200 means the batch ran, not that every item in it did.
  assert.equal(batchFailed(200, { data: { ...clean.data, failed: 1 } }), true);
  assert.equal(
    batchFailed(200, { data: { ...clean.data, failures: [{ resourceId: 'x', reason: 'y' }] } }),
    true,
  );
  // The combined payments job nests its three batches.
  assert.equal(
    batchFailed(200, {
      data: {
        inbox: clean.data,
        reconciliation: clean.data,
        periods: { ...clean.data, failed: 2 },
      },
    }),
    true,
  );
  assert.equal(batchFailed(500, clean), true, 'a refused run failed');
  assert.equal(batchFailed(403, null), true);
});

test('OBS-03 request logs keep the path and never the search, the token or a PIN', async () => {
  let written = '';
  const sink = new Writable({
    write(chunk, _encoding, done) {
      written += chunk.toString();
      done();
    },
  });
  const app = Fastify({ logger: loggerOptions(sink) });
  app.post('/v1/auth/driver', async () => ({ ok: true }));
  app.get('/v1/ops/riders', async () => ({ data: [] }));
  await app.inject({
    method: 'GET',
    url: '/v1/ops/riders?q=ama%40example.com',
    headers: { authorization: 'Bearer live-session-token', 'idempotency-key': 'key-123' },
  });
  await app.inject({
    method: 'POST',
    url: '/v1/auth/driver',
    payload: { code: 'DR-7Q4M', pin: '918273', ownDevice: false },
  });
  await app.close();

  assert.match(written, /"path":"\/v1\/ops\/riders"/, 'the route is logged');
  for (const secret of [
    'ama%40',
    'example.com',
    'live-session-token',
    'key-123',
    '918273',
    'DR-7Q4M',
  ])
    assert.equal(written.includes(secret), false, `${secret} reached the log`);
});

test('OBS-06 liveness probes do not flood logs, while ordinary requests still log', async () => {
  let written = '';
  const sink = new Writable({
    write(chunk, _encoding, done) {
      written += chunk.toString();
      done();
    },
  });
  const pool = new Pool();
  const app = await createTransportApp({
    pool,
    coordinateReservations: async () => {
      throw new Error('no booking work in this test');
    },
    cursorSecret: Buffer.alloc(32, 9),
    verifyAccess: async () => null,
    authorizeSession: async () => {
      throw new Error('no session work in this test');
    },
    minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
    config: {
      health: () => ({ status: 200, body: { status: 'ok' }, headers: {} }),
      readiness: async () => ({ status: 200, body: { status: 'ok' }, headers: {} }),
      root: () => ({ status: 200, body: { docs: '/docs', health: '/healthz' }, headers: {} }),
    } as unknown as ConfigService,
    logRequests: true,
    requestLogStream: sink,
  });
  try {
    assert.equal((await app.inject('/healthz')).statusCode, 200);
    assert.equal((await app.inject('/readyz')).statusCode, 200);
    assert.equal((await app.inject('/')).statusCode, 200);
  } finally {
    await app.close();
    await pool.end();
  }
  assert.equal(written.includes('"path":"/healthz"'), false);
  assert.match(written, /"path":"\/readyz"/, 'readiness remains logged');
  assert.match(written, /"path":"\/"/, 'ordinary requests remain logged');
});

test('OBS-04 job runs are labelled by operation, and memory is what the plan limit sees', async () => {
  const exporter = new InMemoryMetricExporter(AggregationTemporality.CUMULATIVE);
  const reader = new PeriodicExportingMetricReader({ exporter, exportIntervalMillis: 3_600_000 });
  const provider = new MeterProvider({ readers: [reader] });
  metrics.setGlobalMeterProvider(provider);
  try {
    observeProcess();
    recordJob('runPaymentsMaintenance', 200, { inbox: { failed: 1 } });
    await reader.forceFlush();
    const points = new Map(
      exporter
        .getMetrics()
        .flatMap((r) => r.scopeMetrics.flatMap((s) => s.metrics))
        .map((m) => [m.descriptor.name, m.dataPoints] as const),
    );
    // `job` would be overwritten by the service's own job label in Prometheus,
    // folding every scheduled job into one series.
    assert.deepEqual(points.get('trotxi_job_runs')?.[0]?.attributes, {
      operation: 'runPaymentsMaintenance',
      outcome: 'failed',
    });
    const rss = points.get('process.memory.usage')?.[0]?.value as number;
    assert.ok(rss > 10 * 2 ** 20 && rss < 64 * 2 ** 30, `resident memory ${rss}`);
    assert.deepEqual(
      points
        .get('process.cpu.time')
        ?.map((p) => p.attributes['cpu.mode'])
        .sort(),
      ['system', 'user'],
    );
  } finally {
    await provider.shutdown();
    metrics.disable();
  }
});

test('OBS-05 every dashboard query and alert is scoped to one service', async () => {
  const dashboard = JSON.parse(
    await readFile(
      new URL('../../../ops/grafana/dashboards/trotxi-api-health.json', import.meta.url),
      'utf8',
    ),
  );
  const expressions = dashboard.panels.flatMap((p: { targets?: { expr: string }[] }) =>
    (p.targets ?? []).map((t) => t.expr),
  );
  assert.ok(expressions.length > 30);
  // An unscoped query would mix staging and production on one graph.
  for (const expr of expressions) assert.match(expr, /job="\$job"/, expr);

  const { rules } = JSON.parse(
    await readFile(new URL('../../../ops/grafana/alerts/trotxi-api.json', import.meta.url), 'utf8'),
  );
  assert.equal(new Set(rules.map((r: { key: string }) => r.key)).size, rules.length);
  for (const rule of rules) {
    assert.match(rule.expr, /job="\$job"/, rule.key);
    assert.ok(['page', 'notify'].includes(rule.severity), rule.key);
    // Grafana rule uids are at most 40 characters: trotxi-<environment>-<key>.
    assert.ok(`trotxi-production-${rule.key}`.length <= 40, rule.key);
    assert.equal(typeof rule.above, 'number', rule.key);
  }
});
