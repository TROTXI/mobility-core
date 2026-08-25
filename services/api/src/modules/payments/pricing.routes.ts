// Admin pricing routes (#103, ADR-0015). The point of this module: the numbers
// we charge real people are data an admin can correct in seconds, not constants
// requiring a code review and a deploy.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import { PLANS } from './payments.schema';
import type { PricingRepository } from './pricing.repository';

const fareResponseSchema = z.object({
  id: z.string().uuid(),
  routeId: z.string().uuid(),
  farePesewas: z.number().int(),
  effectiveFrom: z.date(),
  effectiveTo: z.date().nullable(),
  note: z.string().nullable(),
});

const planPricingResponseSchema = z.object({
  plan: z.enum(PLANS),
  ridesPerPeriod: z.number().int(),
  priceMultiplierBp: z.number().int(),
  takeRateBp: z.number().int(),
  creditPesewasPerRide: z.number().int(),
});

const setFareBodySchema = z.object({
  farePesewas: z.number().int().positive(),
  /** Why it changed — a union announcement, a fuel adjustment, a correction. */
  note: z.string().max(500).optional(),
});

const updatePlanBodySchema = z
  .object({
    ridesPerPeriod: z.number().int().positive(),
    priceMultiplierBp: z.number().int().positive(),
    takeRateBp: z.number().int().min(0).max(10_000),
    creditPesewasPerRide: z.number().int().min(0),
  })
  .partial();

/**
 * Register the admin pricing routes.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.pricing - the pricing repository (503 when absent).
 * @param opts.rateLimit - rate-limit config (applied per user).
 */
export async function pricingRoutes(
  app: FastifyInstance,
  opts: { pricing?: PricingRepository; rateLimit: RateLimitConfig },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();
  const UNAVAILABLE = { error: 'unavailable', message: 'Pricing is not configured' };
  const adminOnly = [
    app.authenticate,
    app.rateLimit({ ...opts.rateLimit, by: 'user' }),
    app.requireRole('admin'),
  ];

  r.get(
    '/admin/routes/:id/fares',
    {
      schema: {
        tags: ['admin'],
        summary: "A corridor's fare history, newest first",
        description:
          'The audit trail behind every price. Fares are effective-dated because ' +
          'government and the transport unions set them, so a subscription sold in ' +
          'August has to stay explainable in October.',
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        response: {
          200: z.object({ fares: z.array(fareResponseSchema) }),
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.pricing) return reply.code(503).send(UNAVAILABLE);
      return { fares: await opts.pricing.fareHistory(request.params.id) };
    },
  );

  r.put(
    '/admin/routes/:id/fare',
    {
      schema: {
        tags: ['admin'],
        summary: "Set a corridor's fare (closes the previous one)",
        description:
          'Records a new fare and closes the one it replaces rather than overwriting ' +
          'it. Every plan price on this corridor recomputes from it; existing ' +
          'subscriptions keep the price they were sold at until renewal.',
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        body: setFareBodySchema,
        response: {
          200: fareResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.pricing) return reply.code(503).send(UNAVAILABLE);
      return opts.pricing.setFare(request.params.id, request.body.farePesewas, request.body.note);
    },
  );

  r.get(
    '/admin/plan-pricing',
    {
      schema: {
        tags: ['admin'],
        summary: 'The pricing levers for every plan',
        security: [{ bearerAuth: [] }],
        response: {
          200: z.object({ plans: z.array(planPricingResponseSchema) }),
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (_request, reply) => {
      if (!opts.pricing) return reply.code(503).send(UNAVAILABLE);
      return { plans: await opts.pricing.allPlanPricing() };
    },
  );

  r.patch(
    '/admin/plan-pricing/:plan',
    {
      schema: {
        tags: ['admin'],
        summary: 'Update a plan’s multiplier, take rate, ride count or credit value',
        description:
          'Rates are basis points: 10000 = 1.0. priceMultiplierBp is what the rider ' +
          'pays relative to spot (10000 = parity); takeRateBp is our share of the ' +
          'fare. Changes apply to new subscriptions and renewals, never to an ' +
          'active period.',
        security: [{ bearerAuth: [] }],
        params: z.object({ plan: z.enum(PLANS) }),
        body: updatePlanBodySchema,
        response: {
          200: planPricingResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.pricing) return reply.code(503).send(UNAVAILABLE);
      const updated = await opts.pricing.updatePlanPricing(request.params.plan, request.body);
      if (!updated) return reply.code(404).send({ error: 'not_found', message: 'Unknown plan' });
      return { plan: request.params.plan, ...updated };
    },
  );
}
