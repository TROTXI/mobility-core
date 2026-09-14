import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { SubscriptionRepository } from './subscription.repository';
import { currentSubscriptionResponseSchema } from './subscription.schema';

/**
 * Register the rider-facing current-subscription endpoint.
 *
 * @param app - Fastify instance.
 * @param opts - Route dependencies.
 * @param opts.subscriptions - Membership persistence; the route returns 503 when absent.
 * @param opts.rateLimit - Per-user rate-limit settings.
 */
export async function subscriptionRoutes(
  app: FastifyInstance,
  opts: { subscriptions?: SubscriptionRepository; rateLimit: RateLimitConfig },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();

  r.get(
    '/me/subscription',
    {
      schema: {
        tags: ['subscriptions'],
        summary: 'Current rider subscription, route and renewal date',
        security: [{ bearerAuth: [] }],
        response: {
          200: currentSubscriptionResponseSchema,
          401: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.subscriptions) {
        return reply
          .code(503)
          .send({ error: 'unavailable', message: 'Subscriptions are not configured' });
      }

      const current = await opts.subscriptions.findCurrentByUser(request.user!.id);
      if (!current) return { subscribed: false as const, subscription: null };

      return {
        subscribed: true as const,
        subscription: {
          id: current.id,
          plan: current.plan,
          status: current.paused ? ('paused' as const) : current.status,
          routeId: current.routeId,
          pickupStopId: current.pickupStopId,
          dropoffStopId: current.dropoffStopId,
          periodStart: current.periodStart,
          // The pause duration is added on resume, so the final renewal date is
          // deliberately unknown while an open pause exists.
          renewsAt: current.paused ? null : current.periodEnd,
        },
      };
    },
  );
}
