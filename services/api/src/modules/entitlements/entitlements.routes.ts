// Entitlement routes (#100, epic E1). `GET /me/rides` is the rider's balance
// under the Hybrid Subscription Model — remaining rides + carried Ride Credit —
// and replaces the removed wallet `GET /me/balance` (unblocks FE #35).

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { SubscriptionRepository } from '../subscriptions/subscription.repository';
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
 * @param opts.subscriptions - supplies renewsAt + ridesPerPeriod (#162).
 * @param opts.rateLimit - rate-limit config (applied per user).
 */
export async function entitlementRoutes(
  app: FastifyInstance,
  opts: {
    entitlements?: EntitlementLedgerRepository;
    credits?: CreditLedgerRepository;
    rateLimit: RateLimitConfig;
    /** Supplies renewsAt + ridesPerPeriod for the balance card (#162). */
    subscriptions?: SubscriptionRepository;
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
      // The subscription supplies what the balance card needs beyond the two
      // numbers: "23 of 40 · renews 1 Sep" is not computable from the ledgers
      // alone. Null when there is no active subscription, rather than invented.
      const sub = opts.subscriptions ? await opts.subscriptions.findActiveByUser(userId) : null;
      return {
        remainingRides,
        creditPesewas,
        ridesPerPeriod: sub?.ridesGranted ?? null,
        renewsAt: sub?.periodEnd ?? null,
      };
    },
  );
}
