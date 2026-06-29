// Metrics. Exposes GET /metrics in Prometheus text format for scraping into
// Grafana Cloud (docs/design/observability.md, #28) — Phase 1:
//   - RED: http_request_duration_seconds histogram {method, route, status_code}
//   - Node runtime (USE): heap/RSS memory, event-loop lag, GC (prom-client defaults)
// Not public: when a token is configured the endpoint requires
// `Authorization: Bearer <token>`; in production with no token it is disabled
// (404) rather than left open (same fail-safe posture as payments/sign-in).

import { timingSafeEqual } from 'node:crypto';
import type { FastifyReply, FastifyRequest } from 'fastify';
import fp from 'fastify-plugin';
import { collectDefaultMetrics, Histogram, Registry } from 'prom-client';

export interface MetricsOptions {
  /** When set, GET /metrics requires `Authorization: Bearer <token>`. */
  token?: string;
  /** Allow /metrics without a token (dev/test). Set false in production. */
  allowUnprotected: boolean;
}

// Seconds buckets tuned for API latency (5ms … 5s).
const DURATION_BUCKETS = [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5];

function tokenMatches(provided: string, expected: string): boolean {
  const a = Buffer.from(provided);
  const b = Buffer.from(expected);
  return a.length === b.length && timingSafeEqual(a, b);
}

export const metricsPlugin = fp<MetricsOptions>(async (app, opts) => {
  // A fresh registry per app instance (tests build many apps; the default global
  // registry would throw "already registered").
  const register = new Registry();
  collectDefaultMetrics({ register });

  const httpDuration = new Histogram({
    name: 'http_request_duration_seconds',
    help: 'HTTP request duration in seconds (RED: rate, errors, duration).',
    labelNames: ['method', 'route', 'status_code'] as const,
    buckets: DURATION_BUCKETS,
    registers: [register],
  });

  // Record every response except the scrape itself. Use the route TEMPLATE
  // (e.g. /payments/topup), never the raw URL, to bound label cardinality;
  // unmatched requests (404) have no template, so we skip them.
  app.addHook('onResponse', async (request: FastifyRequest, reply: FastifyReply) => {
    const route = request.routeOptions.url;
    if (!route || route === '/metrics') return;
    httpDuration.observe(
      { method: request.method, route, status_code: reply.statusCode },
      reply.elapsedTime / 1000,
    );
  });

  // No token + not allowed unprotected (i.e. production) → don't expose at all.
  if (!opts.token && !opts.allowUnprotected) return;

  app.get('/metrics', { schema: { hide: true } }, async (request, reply) => {
    if (opts.token) {
      const header = request.headers.authorization;
      const provided = header?.startsWith('Bearer ') ? header.slice(7) : '';
      if (!provided || !tokenMatches(provided, opts.token)) {
        return reply.code(401).send({ error: 'unauthorized', message: 'Invalid metrics token' });
      }
    }
    reply.header('content-type', register.contentType);
    return register.metrics();
  });
});
