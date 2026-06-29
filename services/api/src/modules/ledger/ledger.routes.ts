// Wallet routes. GET /me/balance exposes the rider's derived balance in pesewas
// (the home screen, app #35; the client formats GHS). Read-only here; grants come
// from payments (#21b), debits from boarding (#20).

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { LedgerRepository } from './ledger.repository';
import { balanceResponseSchema } from './ledger.schema';

export async function ledgerRoutes(
  app: FastifyInstance,
  opts: { ledger?: LedgerRepository; rateLimit: RateLimitConfig },
): Promise<void> {
  app.withTypeProvider<ZodTypeProvider>().get(
    '/me/balance',
    {
      schema: {
        tags: ['wallet'],
        summary: 'Get the authenticated rider token balance (pesewas)',
        security: [{ bearerAuth: [] }],
        response: {
          200: balanceResponseSchema,
          401: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request) => {
      const balancePesewas = opts.ledger ? await opts.ledger.balanceOf(request.user!.id) : 0;
      return { balancePesewas };
    },
  );
}
