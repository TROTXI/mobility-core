// Subscription route handlers. Both endpoints require a valid bearer token —
// anonymous access is rejected by app.authenticate before reaching the handler.
// POST /subscriptions enforces one-active-per-user at the API layer (409 on
// duplicate) in addition to the DB-level constraint, so callers get a clear
// error rather than a constraint violation from Postgres.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { SubscriptionRepository } from './subscription.repository';
import { createSubscriptionBodySchema, subscriptionResponseSchema } from './subscription.schema';

export async function subscriptionRoutes(
  app: FastifyInstance,
  opts: { subscriptions?: SubscriptionRepository },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();

  r.post(
    '/subscriptions',
    {
      schema: {
        tags: ['subscriptions'],
        summary: 'Create a subscription for the authenticated user',
        security: [{ bearerAuth: [] }],
        body: createSubscriptionBodySchema,
        response: {
          201: subscriptionResponseSchema,
          401: errorResponseSchema,
          409: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate],
    },
    async (request, reply) => {
      const principal = request.user!;

      const existing = opts.subscriptions
        ? await opts.subscriptions.findActiveByUser(principal.id)
        : null;

      if (existing) {
        return reply.code(409).send({
          error: 'conflict',
          message: 'User already has an active subscription',
        });
      }

      const subscription = opts.subscriptions
        ? await opts.subscriptions.create({ userId: principal.id, plan: request.body.plan })
        : null;

      if (!subscription) {
        return reply
          .code(409)
          .send({ error: 'unavailable', message: 'Subscription service unavailable' });
      }

      return reply.code(201).send(subscription);
    },
  );

  r.get(
    '/subscriptions/me',
    {
      schema: {
        tags: ['subscriptions'],
        summary: 'Get the active subscription for the authenticated user',
        security: [{ bearerAuth: [] }],
        response: {
          200: subscriptionResponseSchema,
          401: errorResponseSchema,
          404: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate],
    },
    async (request, reply) => {
      const principal = request.user!;

      const subscription = opts.subscriptions
        ? await opts.subscriptions.findActiveByUser(principal.id)
        : null;

      if (!subscription) {
        return reply
          .code(404)
          .send({ error: 'not_found', message: 'No active subscription found' });
      }

      return subscription;
    },
  );
}
