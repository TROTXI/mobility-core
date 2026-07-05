// Payment routes. /payments/subscribe (membership fee) and /payments/topup (load
// ride tokens) start a Paystack checkout — both auth + per-user rate limit.
// /webhooks/paystack is public but signature-verified inside the service; it uses
// the RAW body (fastify-raw-body) because the HMAC must be over the exact bytes
// Paystack sent — a re-serialized JSON would not match.

import type { FastifyInstance } from 'fastify';
import fastifyRawBody from 'fastify-raw-body';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import {
  checkoutResponseSchema,
  subscribeBodySchema,
  topupBodySchema,
  webhookResponseSchema,
} from './payments.schema';
import {
  InvalidWebhookError,
  PaymentsNotConfiguredError,
  type PaymentsService,
} from './payments.service';

// Webhooks come from Paystack's IPs, not users — a generous per-IP cap is enough.
const WEBHOOK_RATE_LIMIT = { max: 60, windowSeconds: 60 } as const;

/**
 * Register the payment routes: `POST /payments/subscribe`, `POST /payments/topup`,
 * and `POST /webhooks/paystack`.
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
          401: errorResponseSchema,
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
        );
      } catch (err) {
        if (err instanceof PaymentsNotConfiguredError) return reply.code(503).send(UNAVAILABLE);
        throw err;
      }
    },
  );

  r.post(
    '/payments/topup',
    {
      schema: {
        tags: ['payments'],
        summary:
          '[LEGACY — do not build against] Wallet top-up. Superseded by ride entitlements (ADR-0014); retired in E7',
        deprecated: true,
        security: [{ bearerAuth: [] }],
        body: topupBodySchema,
        response: {
          200: checkoutResponseSchema,
          401: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.paymentsService) return reply.code(503).send(UNAVAILABLE);
      try {
        return await opts.paymentsService.initializeTopup(
          request.user!.id,
          request.body.amountPesewas,
        );
      } catch (err) {
        if (err instanceof PaymentsNotConfiguredError) return reply.code(503).send(UNAVAILABLE);
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
      preHandler: [app.rateLimit({ ...WEBHOOK_RATE_LIMIT, by: 'ip' })],
    },
    async (request, reply) => {
      if (!opts.paymentsService) return reply.code(503).send(UNAVAILABLE);
      const rawBody = typeof request.rawBody === 'string' ? request.rawBody : '';
      const signature = request.headers['x-paystack-signature'];
      try {
        await opts.paymentsService.handleWebhook(
          rawBody,
          typeof signature === 'string' ? signature : undefined,
        );
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
}
