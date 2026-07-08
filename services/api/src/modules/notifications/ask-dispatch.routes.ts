// Ask-dispatch trigger endpoints (E3). A scheduled Render cron hits these with
// an admin token at the confirmation windows: `ask-dispatch` in the ask window
// (evening for tomorrow morning; midday for the evening) and `resolve-defaults`
// at the cutoff. Admin-role gated, like the rest of the ops surface (#26).

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { AskDispatchService } from './ask-dispatch.service';
import {
  askDispatchBodySchema,
  askDispatchResponseSchema,
  resolveDefaultsBodySchema,
  resolveDefaultsResponseSchema,
} from './ask-dispatch.schema';

/**
 * Register the ask-dispatch triggers: `POST /admin/ask-dispatch` and
 * `POST /admin/resolve-defaults`.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.askDispatch - the ask-dispatch service (503 when unwired).
 * @param opts.rateLimit - rate-limit config (per user).
 */
export async function askDispatchRoutes(
  app: FastifyInstance,
  opts: { askDispatch?: AskDispatchService; rateLimit: RateLimitConfig },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();
  const UNAVAILABLE = { error: 'unavailable', message: 'Ask-dispatch is not configured' };
  const adminOnly = [
    app.authenticate,
    app.rateLimit({ ...opts.rateLimit, by: 'user' }),
    app.requireRole('admin'),
  ];

  r.post(
    '/admin/ask-dispatch',
    {
      schema: {
        tags: ['admin'],
        summary: "Prompt a day's route subscribers to confirm (seed pending + push)",
        security: [{ bearerAuth: [] }],
        body: askDispatchBodySchema,
        response: {
          200: askDispatchResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.askDispatch) return reply.code(503).send(UNAVAILABLE);
      return opts.askDispatch.dispatchAsks(request.body.travelDate, request.body.direction);
    },
  );

  r.post(
    '/admin/resolve-defaults',
    {
      schema: {
        tags: ['admin'],
        summary: 'Cutoff default-yes: flip still-pending reservations to reserved',
        security: [{ bearerAuth: [] }],
        body: resolveDefaultsBodySchema,
        response: {
          200: resolveDefaultsResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.askDispatch) return reply.code(503).send(UNAVAILABLE);
      return opts.askDispatch.resolveDefaults(request.body.travelDate, request.body.direction);
    },
  );
}
