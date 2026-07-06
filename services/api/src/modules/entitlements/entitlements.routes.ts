// Entitlement routes (#100, epic E1). `GET /me/rides` is the rider's balance
// under the Hybrid Subscription Model — remaining rides + carried Ride Credit —
// and replaces the removed wallet `GET /me/balance` (unblocks FE #35).

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { CreditLedgerRepository } from './credit-ledger.repository';
import type { EntitlementLedgerRepository } from './entitlement-ledger.repository';
import { ridesResponseSchema } from './entitlements.schema';

/**
 * Register the entitlement routes: `GET /me/rides`.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.entitlements - the ride-entitlement ledger (503 when absent).
 * @param opts.credits - the Ride Credit ledger (503 when absent).
 * @param opts.rateLimit - rate-limit config (applied per user).
 */
export async function entitlementRoutes(
  app: FastifyInstance,
  opts: {
    entitlements?: EntitlementLedgerRepository;
    credits?: CreditLedgerRepository;
    rateLimit: RateLimitConfig;
  },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();

  r.get(
    '/me/rides',
    {
      schema: {
        tags: ['rides'],
        summary: 'Remaining ride entitlement + Ride Credit balance',
        security: [{ bearerAuth: [] }],
        response: {
          200: ridesResponseSchema,
          401: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.entitlements || !opts.credits) {
        return reply
          .code(503)
          .send({ error: 'unavailable', message: 'Entitlements are not configured' });
      }
      const userId = request.user!.id;
      const [remainingRides, creditPesewas] = await Promise.all([
        opts.entitlements.remainingRides(userId),
        opts.credits.balancePesewas(userId),
      ]);
      return { remainingRides, creditPesewas };
    },
  );
}
