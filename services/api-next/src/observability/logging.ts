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

/**
 * Why a request failed, in the same safe-to-keep terms as the request log.
 *
 * Our own error code says why a request was refused, so a 409 no longer
 * needs guessing. A 5xx adds where it broke: the stack frames and, for a
 * database error, its SQLSTATE and constraint name. What an error says is
 * never kept: driver, database and fetch messages can quote what was sent
 * (a duplicate email, a provider URL holding an API key, a PIN in a value
 * that failed a cast), so the message line of the stack, pg's detail and
 * where fields, and validation params are all left out.
 */
export function failureLog(error: unknown, status: number, code: string) {
  const e = error as {
    stack?: unknown;
    code?: unknown;
    constraint?: unknown;
    validation?: unknown;
  };
  const pg = typeof e.code === 'string' && /^[0-9A-Z]{5}$/.test(e.code);
  const name = (value: unknown) =>
    typeof value === 'string' && /^[a-z_][a-z0-9_$]{0,62}$/i.test(value) ? value : undefined;
  return {
    status,
    code,
    ...(pg ? { sqlState: e.code, constraint: name(e.constraint) } : {}),
    ...(Array.isArray(e.validation)
      ? {
          invalid: e.validation.slice(0, 5).map(
            (v: { instancePath?: unknown; keyword?: unknown }) =>
              // A path can carry a client-chosen object key: keep it short.
              `${typeof v.instancePath === 'string' && v.instancePath ? v.instancePath.slice(0, 80) : '/'} ${String(v.keyword).slice(0, 40)}`,
          ),
        }
      : {}),
    ...(status >= 500
      ? {
          errorType: error instanceof Error ? error.constructor.name : typeof error,
          frames: String(e.stack ?? '')
            .split('\n')
            .filter((line) => /^\s+at /.test(line))
            .slice(0, 12)
            .map((line) => line.trim()),
        }
      : {}),
  };
}
