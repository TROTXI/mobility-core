// OpenTelemetry bootstrap (#28, docs/design/observability.md). Auto-instruments
// HTTP, Fastify, pg and ioredis; pushes traces, metrics and logs to an OTLP
// endpoint (Grafana Cloud). Logs carry trace_id/span_id so they correlate.
//
// GATED: a no-op unless OTEL_EXPORTER_OTLP_ENDPOINT is set, so dev/tests stay
// zero-infra. Must load BEFORE the libraries it instruments — production uses
// `node --import ./dist/observability/tracing.live.js`.

import { OTLPLogExporter } from '@opentelemetry/exporter-logs-otlp-proto';
import { OTLPMetricExporter } from '@opentelemetry/exporter-metrics-otlp-proto';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-proto';
import { FastifyInstrumentation } from '@opentelemetry/instrumentation-fastify';
import { HttpInstrumentation } from '@opentelemetry/instrumentation-http';
import { IORedisInstrumentation } from '@opentelemetry/instrumentation-ioredis';
import { PgInstrumentation } from '@opentelemetry/instrumentation-pg';
import { PinoInstrumentation } from '@opentelemetry/instrumentation-pino';
import { RuntimeNodeInstrumentation } from '@opentelemetry/instrumentation-runtime-node';
import { resourceFromAttributes } from '@opentelemetry/resources';
import { BatchLogRecordProcessor } from '@opentelemetry/sdk-logs';
import { PeriodicExportingMetricReader } from '@opentelemetry/sdk-metrics';
import { NodeSDK } from '@opentelemetry/sdk-node';
import { ATTR_SERVICE_NAME, ATTR_SERVICE_VERSION } from '@opentelemetry/semantic-conventions';

let sdk: NodeSDK | undefined;

export function startTracing(): void {
  if (sdk) return; // idempotent: --import and the server.ts import both load this
  // The OTLP exporter reads OTEL_EXPORTER_OTLP_ENDPOINT / _HEADERS from the
  // environment itself; we only gate on an endpoint being configured.
  const configured =
    process.env['OTEL_EXPORTER_OTLP_ENDPOINT'] ?? process.env['OTEL_EXPORTER_OTLP_TRACES_ENDPOINT'];
  if (!configured) return;

  sdk = new NodeSDK({
    resource: resourceFromAttributes({
      [ATTR_SERVICE_NAME]: process.env['OTEL_SERVICE_NAME'] ?? 'trotxi-api',
      [ATTR_SERVICE_VERSION]: process.env['GIT_SHA'] ?? 'dev',
    }),
    traceExporter: new OTLPTraceExporter(),
    metricReader: new PeriodicExportingMetricReader({ exporter: new OTLPMetricExporter() }),
    logRecordProcessors: [new BatchLogRecordProcessor(new OTLPLogExporter())],
    instrumentations: [
      new HttpInstrumentation(),
      new FastifyInstrumentation(),
      new PgInstrumentation(),
      new IORedisInstrumentation(),
      new RuntimeNodeInstrumentation(), // Node runtime metrics: event loop, GC, heap
      new PinoInstrumentation(), // inject trace_id/span_id into pino logs + ship to Loki
    ],
  });
  sdk.start();
  console.log('OpenTelemetry traces + metrics + logs started (OTLP).');
}

export async function stopTracing(): Promise<void> {
  // Telemetry must never crash the app — swallow flush/export failures.
  try {
    await sdk?.shutdown();
  } catch (err) {
    console.warn('OpenTelemetry shutdown error (ignored):', err);
  }
  sdk = undefined;
}

// Run on import so `node --import ./dist/tracing.live.js` activates tracing
// before any instrumented module loads.
startTracing();

// Safety net: a failed span export (e.g. the OTLP collector is unreachable) must
// degrade gracefully, never take the process down. Only swallow OTLP/exporter
// connection errors; rethrow anything else so real bugs still surface.
if (sdk) {
  process.on('unhandledRejection', (reason) => {
    const code = (reason as { code?: string } | undefined)?.code;
    const msg = String((reason as { message?: string } | undefined)?.message ?? reason);
    if (code === 'ECONNREFUSED' || code === 'ETIMEDOUT' || /OTLP|otlp|exporter/.test(msg)) {
      console.warn('OpenTelemetry export failed (ignored):', msg);
      return;
    }
    throw reason;
  });
}
