/**
 * Traces, metrics and logs to Grafana Cloud over OTLP.
 *
 * Loaded with `node --import ./dist/observability/telemetry.js dist/server.js`,
 * so it is in place before Fastify and pg are imported. That ordering is the
 * whole trick: an instrumentation that loads after the library it patches
 * reports nothing, and says nothing about it.
 *
 * This service is ES modules. The old backend's setup relied on require hooks,
 * which never see an `import`, so the loader hook is registered here first.
 * Without it the SDK starts, the exporters connect, and every Fastify and pg
 * span is silently missing.
 *
 * Off unless OTEL_EXPORTER_OTLP_ENDPOINT is set, so local runs and tests need
 * no collector. The endpoint and its auth header are read by the exporters
 * themselves from OTEL_EXPORTER_OTLP_ENDPOINT and OTEL_EXPORTER_OTLP_HEADERS.
 */
import { register } from 'node:module';
import { FastifyOtelInstrumentation } from '@fastify/otel';
import { OTLPLogExporter } from '@opentelemetry/exporter-logs-otlp-proto';
import { OTLPMetricExporter } from '@opentelemetry/exporter-metrics-otlp-proto';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-proto';
import { HttpInstrumentation } from '@opentelemetry/instrumentation-http';
import { PgInstrumentation } from '@opentelemetry/instrumentation-pg';
import { PinoInstrumentation } from '@opentelemetry/instrumentation-pino';
import { RuntimeNodeInstrumentation } from '@opentelemetry/instrumentation-runtime-node';
import { resourceFromAttributes } from '@opentelemetry/resources';
import { BatchLogRecordProcessor } from '@opentelemetry/sdk-logs';
import { PeriodicExportingMetricReader } from '@opentelemetry/sdk-metrics';
import { NodeSDK } from '@opentelemetry/sdk-node';
import { ATTR_SERVICE_NAME, ATTR_SERVICE_VERSION } from '@opentelemetry/semantic-conventions';

let sdk: NodeSDK | undefined;

/** Probes the platform calls every few seconds. As traces they are only noise. */
const probes = new Set(['/healthz', '/readyz']);

export function startTelemetry(env: NodeJS.ProcessEnv = process.env): boolean {
  if (sdk) return true;
  if (!env.OTEL_EXPORTER_OTLP_ENDPOINT && !env.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT) return false;
  register('@opentelemetry/instrumentation/hook.mjs', import.meta.url);
  sdk = new NodeSDK({
    resource: resourceFromAttributes({
      [ATTR_SERVICE_NAME]: env.OTEL_SERVICE_NAME ?? 'trotxi-api',
      // Render sets the deployed commit, so a regression in Grafana points at
      // the deploy that introduced it.
      [ATTR_SERVICE_VERSION]: env.RENDER_GIT_COMMIT ?? 'local',
    }),
    traceExporter: new OTLPTraceExporter(),
    metricReader: new PeriodicExportingMetricReader({ exporter: new OTLPMetricExporter() }),
    logRecordProcessors: [new BatchLogRecordProcessor({ exporter: new OTLPLogExporter() })],
    instrumentations: [
      new HttpInstrumentation({
        ignoreIncomingRequestHook: (request) => probes.has((request.url ?? '').split('?')[0]!),
        // Spans record the query string, and the riders search puts names,
        // phone numbers and email addresses in it. Setting this replaces the
        // built-in list, so the usual credential names are kept alongside.
        redactedQueryParamsServer: [
          'q',
          'cursor',
          'token',
          'access_token',
          'code',
          'sig',
          'signature',
        ],
      }),
      new FastifyOtelInstrumentation({
        registerOnInitialization: true,
        // It sets url.path from the raw URL, query string included, which the
        // HTTP instrumentation's redaction above never sees. Keep the path.
        requestHook: (span, request) => span.setAttribute('url.path', request.url.split('?')[0]!),
      }),
      // Statement text is recorded, never parameter values: those carry PIN
      // hashes, tokens and personal data.
      new PgInstrumentation({ enhancedDatabaseReporting: false }),
      new RuntimeNodeInstrumentation(),
      // Puts trace_id and span_id on every log line and ships the logs, so a
      // line in Loki opens the request that wrote it.
      new PinoInstrumentation(),
    ],
  });
  sdk.start();
  return true;
}

/**
 * Flush what is buffered and stop. A failed flush is swallowed: the API is
 * shutting down either way, and telemetry must never decide how it exits.
 */
export async function stopTelemetry(): Promise<void> {
  try {
    await sdk?.shutdown();
  } catch {
    // Nothing useful to do with a failed final export.
  }
  sdk = undefined;
}

startTelemetry();
