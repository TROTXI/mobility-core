// OpenTelemetry tracing bootstrap (Phase 2, docs/design/observability.md, #28).
// Auto-instruments HTTP, Fastify, Postgres (pg) and Redis (ioredis) and pushes
// spans to an OTLP endpoint (Grafana Cloud Tempo) over OTLP/HTTP (protobuf —
// Grafana Cloud's default, so its generated OTEL_* config works as a copy-paste).
//
// GATED: a no-op unless OTEL_EXPORTER_OTLP_ENDPOINT is set, so dev/tests stay
// zero-infra. It must load BEFORE the libraries it instruments, so production
// runs it via `node --import ./dist/tracing.live.js` (see package.json `start`);
// importing it from server.ts also triggers it as a fallback. `*.live.ts` is
// excluded from unit coverage (it needs a real collector to verify).

import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-proto';
import { FastifyInstrumentation } from '@opentelemetry/instrumentation-fastify';
import { HttpInstrumentation } from '@opentelemetry/instrumentation-http';
import { IORedisInstrumentation } from '@opentelemetry/instrumentation-ioredis';
import { PgInstrumentation } from '@opentelemetry/instrumentation-pg';
import { resourceFromAttributes } from '@opentelemetry/resources';
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
    instrumentations: [
      new HttpInstrumentation(),
      new FastifyInstrumentation(),
      new PgInstrumentation(),
      new IORedisInstrumentation(),
    ],
  });
  sdk.start();
  console.log('OpenTelemetry tracing started (OTLP).');
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
