// Credit-conversion trigger (E5). A scheduled Render cron hits this with an admin
// token at each period end to convert every active rider's unused rides into Ride
// Credits. Admin-role gated, like the rest of the ops surface (#26) and the E3
// ask-dispatch triggers. The cron schedule itself is infra.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { CreditService } from './credit.service';
import { convertCreditsResponseSchema } from './credit.schema';

/**
 * Register the credit-conversion trigger: `POST /admin/convert-credits`.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.creditService - the credit service (503 when unwired).
 * @param opts.rateLimit - rate-limit config (per user).
 */
export async function creditRoutes(
  app: FastifyInstance,
  opts: { creditService?: CreditService; rateLimit: RateLimitConfig },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();
  const UNAVAILABLE = { error: 'unavailable', message: 'Credit conversion is not configured' };
  const adminOnly = [
    app.authenticate,
    app.rateLimit({ ...opts.rateLimit, by: 'user' }),
    app.requireRole('admin'),
  ];

  r.post(
    '/admin/convert-credits',
    {
      schema: {
        tags: ['admin'],
        summary: "Month-end: convert every active rider's unused rides to Ride Credits",
        security: [{ bearerAuth: [] }],
        response: {
          200: convertCreditsResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (_request, reply) => {
      if (!opts.creditService) return reply.code(503).send(UNAVAILABLE);
      return opts.creditService.convertAllActive();
    },
  );
}
