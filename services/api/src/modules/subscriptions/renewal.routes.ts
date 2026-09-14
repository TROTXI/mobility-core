// Admin trigger for the period-end sweep (#162).
//
// Mirrors the other daily-loop triggers: admin-only, idempotent, and callable
// both by hand and by a scheduled job once the crons are funded.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { RenewalService } from './renewal.service';
import type { PaymentsService } from '../payments/payments.service';
import { periodCloseFailureSchema, periodCloseResultSchema } from '../payments/payments.schema';

/**
 * Register `POST /admin/expire-subscriptions`.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.renewal - the renewal service (503 when absent).
 * @param opts.periodCloser - atomic close path used by the real server.
 * @param opts.rateLimit - rate-limit config (applied per user).
 */
export async function renewalRoutes(
  app: FastifyInstance,
  opts: {
    renewal?: RenewalService;
    periodCloser?: Pick<PaymentsService, 'closeEndedPeriods'>;
    rateLimit: RateLimitConfig;
  },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();

  r.post(
    '/admin/expire-subscriptions',
    {
      schema: {
        tags: ['admin'],
        summary: 'Expire subscriptions whose billing period has ended',
        description:
          'Nothing did this before #162: `status` could be `expired` but no job set it, ' +
          'so a lapsed subscription stayed `active` forever — and the one-active-per-user ' +
          'index meant that stale row blocked the rider from subscribing again. ' +
          'Deliberately does not auto-renew: charging without the rider initiating it ' +
          'needs a stored mandate we do not have (#128).',
        security: [{ bearerAuth: [] }],
        response: {
          200: z.object({
            expired: z.number().int(),
            considered: z.number().int(),
            failed: z.number().int(),
            failures: z.array(periodCloseFailureSchema),
          }),
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [
        app.authenticate,
        app.rateLimit({ ...opts.rateLimit, by: 'user' }),
        app.requireRole('admin'),
      ],
    },
    async (_request, reply) => {
      if (opts.periodCloser) {
        const result = await opts.periodCloser.closeEndedPeriods();
        return {
          expired: result.closed,
          considered: result.considered,
          failed: result.failed,
          failures: result.failures,
        };
      }
      if (!opts.renewal) {
        return reply.code(503).send({ error: 'unavailable', message: 'Renewal is not configured' });
      }
      const result = await opts.renewal.sweep();
      // The pre-atomic compatibility service throws on its first error; it
      // cannot produce partial failures, so these are compatibility fields.
      return { ...result, failed: 0, failures: [] };
    },
  );

  r.post(
    '/admin/close-subscription-periods',
    {
      schema: {
        tags: ['admin'],
        summary: 'Atomically close ended periods, convert rides, and expire memberships',
        security: [{ bearerAuth: [] }],
        response: {
          200: periodCloseResultSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [
        app.authenticate,
        app.rateLimit({ ...opts.rateLimit, by: 'user' }),
        app.requireRole('admin'),
      ],
    },
    async (_request, reply) => {
      if (!opts.periodCloser) {
        return reply
          .code(503)
          .send({ error: 'unavailable', message: 'Atomic period close is not configured' });
      }
      return opts.periodCloser.closeEndedPeriods();
    },
  );
}
