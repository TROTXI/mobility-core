// Admin trigger for route learning (#179, #181).
//
// Mirrors the other daily-loop admin triggers (/admin/ask-dispatch,
// /admin/resolve-no-shows): admin-only, idempotent, and callable both by hand
// and by a Render cron that mints a short-lived admin token.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { RouteLearningService } from './route-learning.service';

const learnBodySchema = z.object({
  /** Learn one route; omit to learn every route with completed runs. */
  routeId: z.string().uuid().optional(),
});

const learnResultSchema = z.object({
  routeId: z.string().uuid(),
  runsUsed: z.number().int(),
  geometryUpdated: z.boolean(),
  segmentsLearned: z.object({
    morning: z.number().int(),
    evening: z.number().int(),
  }),
});

const learnResponseSchema = z.object({
  routes: z.array(learnResultSchema),
});

/**
 * Register `POST /admin/learn-routes`.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.routeLearning - the learning service (503 when absent).
 * @param opts.rateLimit - rate-limit config (applied per user).
 */
export async function routeLearningRoutes(
  app: FastifyInstance,
  opts: { routeLearning?: RouteLearningService; rateLimit: RateLimitConfig },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();

  r.post(
    '/admin/learn-routes',
    {
      schema: {
        tags: ['admin'],
        summary: "Derive route geometry + segment speeds from completed trips' GPS traces",
        description:
          'Reads back the traces of recent completed runs and writes the corridor’s real ' +
          'road-following path and its observed per-segment speeds. Safe to re-run: geometry ' +
          'is overwritten and speeds are replaced per direction, so repeated passes converge.',
        security: [{ bearerAuth: [] }],
        body: learnBodySchema,
        response: {
          200: learnResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      // authenticate → rate limit → requireRole('admin'), matching the other
      // admin triggers: throttle before the role check so a flood of
      // unauthorised calls is cheap to reject.
      preHandler: [
        app.authenticate,
        app.rateLimit({ ...opts.rateLimit, by: 'user' }),
        app.requireRole('admin'),
      ],
    },
    async (request, reply) => {
      if (!opts.routeLearning) {
        return reply
          .code(503)
          .send({ error: 'unavailable', message: 'Route learning is not configured' });
      }
      const routes = request.body.routeId
        ? [await opts.routeLearning.learnRoute(request.body.routeId)]
        : await opts.routeLearning.learnAll();
      return { routes };
    },
  );
}
