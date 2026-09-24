import type { FastifyServerOptions } from 'fastify';

/**
 * Request logs that are safe to keep in Loki.
 *
 * A log line outlives the request by months and is readable by anyone with
 * Grafana access, so what it holds is chosen, not defaulted. The path is kept
 * and the query string dropped: the riders search carries names, phone numbers
 * and email addresses in it. Bodies are never logged, which is where PINs and
 * refresh tokens travel. Headers are not in Fastify's request log at all; the
 * redaction below is there for the day someone adds them.
 */
export function loggerOptions(
  destination?: NodeJS.WritableStream,
): Exclude<FastifyServerOptions['logger'], boolean | undefined> {
  return {
    level: 'info',
    ...(destination ? { stream: destination } : {}),
    redact: {
      paths: [
        'req.headers.authorization',
        'req.headers.cookie',
        'req.headers["idempotency-key"]',
        'req.headers["x-paystack-signature"]',
        'res.headers["set-cookie"]',
      ],
      censor: '[redacted]',
    },
    serializers: {
      req: (request: { id?: string; method?: string; url?: string }) => ({
        id: request.id,
        method: request.method,
        path: (request.url ?? '').split('?')[0],
      }),
    },
  } as Exclude<FastifyServerOptions['logger'], boolean | undefined>;
}
