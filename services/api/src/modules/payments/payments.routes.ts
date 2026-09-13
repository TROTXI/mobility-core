// Payment routes. /payments/subscribe (membership fee) starts a Paystack
// checkout — auth + per-user rate limit. /webhooks/paystack is public but
// signature-verified inside the service; it uses the RAW body (fastify-raw-body)
// because the HMAC must be over the exact bytes Paystack sent — a re-serialized
// JSON would not match. (The wallet top-up route is removed — ADR-0014.)

import type { FastifyInstance } from 'fastify';
import fastifyRawBody from 'fastify-raw-body';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import {
  checkoutResponseSchema,
  subscribeBodySchema,
  webhookResponseSchema,
} from './payments.schema';
import {
  AlreadySubscribedError,
  CheckoutInProgressError,
  InvalidStopsError,
  InvalidWebhookError,
  NotPricedError,
  PeriodSettlementPendingError,
  PaymentsNotConfiguredError,
  type PaymentsService,
} from './payments.service';

/**
 * Register the payment routes: `POST /payments/subscribe` and
 * `POST /webhooks/paystack`.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.paymentsService - the payments orchestrator (routes 503 when absent).
 * @param opts.rateLimit - rate-limit config (applied per user).
 */
export async function paymentRoutes(
  app: FastifyInstance,
  opts: { paymentsService?: PaymentsService; rateLimit: RateLimitConfig },
): Promise<void> {
  // rawBody only for routes that opt in via config.rawBody (the webhook).
  await app.register(fastifyRawBody, { global: false });
  const r = app.withTypeProvider<ZodTypeProvider>();
  const UNAVAILABLE = { error: 'unavailable', message: 'Payments are not configured' };

  r.post(
    '/payments/subscribe',
    {
      schema: {
        tags: ['payments'],
        summary: 'Start a Paystack checkout for the platform membership fee',
        security: [{ bearerAuth: [] }],
        body: subscribeBodySchema,
        response: {
          200: checkoutResponseSchema,
          400: errorResponseSchema,
          401: errorResponseSchema,
          409: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.paymentsService) return reply.code(503).send(UNAVAILABLE);
      try {
        return await opts.paymentsService.initializeSubscription(
          request.user!.id,
          request.body.plan,
          request.body.routeId,
          { pickupStopId: request.body.pickupStopId, dropoffStopId: request.body.dropoffStopId },
        );
      } catch (err) {
        if (err instanceof PaymentsNotConfiguredError) return reply.code(503).send(UNAVAILABLE);
        // 400: the rider picked stops that are not both on the route, or the
        // wrong way round. Their choice is wrong, not our state.
        if (err instanceof InvalidStopsError) {
          return reply.code(400).send({ error: 'invalid_stops', message: err.message });
        }
        if (err instanceof AlreadySubscribedError) {
          return reply.code(409).send({ error: 'already_subscribed', message: err.message });
        }
        if (err instanceof CheckoutInProgressError) {
          return reply.code(409).send({ error: 'checkout_in_progress', message: err.message });
        }
        if (err instanceof PeriodSettlementPendingError) {
          return reply.code(409).send({ error: 'period_settlement_pending', message: err.message });
        }
        // 409, not 500: the request is well-formed, the corridor simply has no
        // fare set yet. Deliberately not falling back to a default — charging a
        // number nobody chose is what #103 exists to prevent.
        if (err instanceof NotPricedError) {
          return reply.code(409).send({ error: 'not_priced', message: err.message });
        }
        throw err;
      }
    },
  );

  r.post(
    '/webhooks/paystack',
    {
      config: { rawBody: true },
      schema: {
        tags: ['payments'],
        summary: 'Paystack payment webhook (signature-verified)',
        response: {
          200: webhookResponseSchema,
          401: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      if (!opts.paymentsService) return reply.code(503).send(UNAVAILABLE);
      const rawBody = typeof request.rawBody === 'string' ? request.rawBody : '';
      const signature = request.headers['x-paystack-signature'];
      try {
        await opts.paymentsService.acceptWebhook(
          rawBody,
          typeof signature === 'string' ? signature : undefined,
        );
        setImmediate(() => {
          void opts.paymentsService!.processWebhookInbox().catch((error) => {
            request.log.error({ error }, 'payment webhook inbox processing failed');
          });
        });
        return { received: true };
      } catch (err) {
        if (err instanceof InvalidWebhookError) {
          return reply
            .code(401)
            .send({ error: 'unauthorized', message: 'Invalid webhook signature' });
        }
        if (err instanceof PaymentsNotConfiguredError) return reply.code(503).send(UNAVAILABLE);
        throw err;
      }
    },
  );

  const adminOnly = [
    app.authenticate,
    app.rateLimit({ ...opts.rateLimit, by: 'user' }),
    app.requireRole('admin'),
  ];
  r.post(
    '/admin/payments/process-webhooks',
    {
      schema: {
        tags: ['admin', 'payments'],
        summary: 'Process durable Paystack webhook events',
        security: [{ bearerAuth: [] }],
        response: {
          200: z.object({ processed: z.number().int(), failed: z.number().int() }),
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (_request, reply) => {
      if (!opts.paymentsService) return reply.code(503).send(UNAVAILABLE);
      return opts.paymentsService.processWebhookInbox(100);
    },
  );

  r.post(
    '/admin/payments/reconcile',
    {
      schema: {
        tags: ['admin', 'payments'],
        summary: 'Verify unresolved payments directly with Paystack',
        security: [{ bearerAuth: [] }],
        response: {
          200: z.object({
            considered: z.number().int(),
            fulfilled: z.number().int(),
            failed: z.number().int(),
            unresolved: z.number().int(),
            errors: z.number().int(),
          }),
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (_request, reply) => {
      if (!opts.paymentsService) return reply.code(503).send(UNAVAILABLE);
      try {
        return await opts.paymentsService.reconcileUnresolved();
      } catch (error) {
        if (error instanceof PaymentsNotConfiguredError) return reply.code(503).send(UNAVAILABLE);
        throw error;
      }
    },
  );

  r.post(
    '/admin/payments/maintenance',
    {
      schema: {
        tags: ['admin', 'payments'],
        summary: 'Run webhook recovery, payment reconciliation, and safe period close',
        security: [{ bearerAuth: [] }],
        response: {
          200: z.object({
            webhooks: z.object({ processed: z.number().int(), failed: z.number().int() }),
            reconciliation: z.object({
              considered: z.number().int(),
              fulfilled: z.number().int(),
              failed: z.number().int(),
              unresolved: z.number().int(),
              errors: z.number().int(),
            }),
            periods: z.object({
              considered: z.number().int(),
              closed: z.number().int(),
              blocked: z.number().int(),
              riders: z.number().int(),
              ridesConverted: z.number().int(),
              creditPesewas: z.number().int(),
            }),
          }),
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (_request, reply) => {
      if (!opts.paymentsService) return reply.code(503).send(UNAVAILABLE);
      try {
        return await opts.paymentsService.runMaintenance();
      } catch (error) {
        if (error instanceof PaymentsNotConfiguredError) return reply.code(503).send(UNAVAILABLE);
        throw error;
      }
    },
  );
}
