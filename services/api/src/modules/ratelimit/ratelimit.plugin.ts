// Rate limiting. Decorates the app with `rateLimit(opts)` — a preHandler factory
// backed by the KV store (Redis in prod, in-memory in dev/tests). Fixed-window
// counting via KvStore.increment. Routes opt in:
//   preHandler: [app.rateLimit({ max, windowSeconds })]                 // by IP
//   preHandler: [app.authenticate, app.rateLimit({ ..., by: 'user' })]  // by user
// Sign-in/refresh (slice 2) and sensitive writes use the strict per-IP variant.

import type { FastifyReply, FastifyRequest, preHandlerHookHandler } from 'fastify';
import fp from 'fastify-plugin';
import type { KvStore } from '../../kv/kv.store';

export interface RateLimitConfig {
  max: number;
  windowSeconds: number;
}

export interface RateLimitOptions extends RateLimitConfig {
  /** Bucket by client IP (default) or by authenticated user id. */
  by?: 'ip' | 'user';
}

/** Default thresholds; overridden per route and from env (config/env.ts). */
export const DEFAULT_RATE_LIMIT: RateLimitConfig = { max: 100, windowSeconds: 60 };

declare module 'fastify' {
  interface FastifyInstance {
    rateLimit: (options: RateLimitOptions) => preHandlerHookHandler;
  }
}

export const rateLimitPlugin = fp<{ kv: KvStore }>(async (app, opts) => {
  const { kv } = opts;

  app.decorate('rateLimit', (options: RateLimitOptions): preHandlerHookHandler => {
    const by = options.by ?? 'ip';

    return async function (request: FastifyRequest, reply: FastifyReply) {
      // Per-user limits assume `authenticate` ran first; fall back to IP if no
      // principal so the limit is never silently skipped.
      const subject = by === 'user' ? (request.user?.id ?? request.ip) : request.ip;
      const key = `ratelimit:${request.routeOptions.url}:${by}:${subject}`;

      let count: number;
      try {
        count = await kv.increment(key, options.windowSeconds);
      } catch (err) {
        // Fail open: a KV/Redis outage must not take the API down.
        request.log.warn({ err }, 'rate limit check failed; allowing request');
        return;
      }

      reply.header('X-RateLimit-Limit', String(options.max));
      reply.header('X-RateLimit-Remaining', String(Math.max(0, options.max - count)));

      if (count > options.max) {
        reply.header('Retry-After', String(options.windowSeconds));
        return reply
          .code(429)
          .send({ error: 'rate_limited', message: 'Too many requests. Try again later.' });
      }
    };
  });
});
