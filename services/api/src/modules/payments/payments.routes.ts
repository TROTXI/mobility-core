// Payment routes. /payments/initialize starts a checkout (auth, per-user limit).
// /webhooks/paystack is public but signature-verified inside the service; it uses
// the RAW body (fastify-raw-body) because the HMAC must be over the exact bytes
// Paystack sent — a re-serialized JSON would not match.

import type { FastifyInstance } from 'fastify';
import fastifyRawBody from 'fastify-raw-body';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import {
  initializePaymentBodySchema,
  initializePaymentResponseSchema,
  webhookResponseSchema,
} from './payments.schema';
import {
  InvalidWebhookError,
  PaymentsNotConfiguredError,
  type PaymentsService,
} from './payments.service';

// Webhooks come from Paystack's IPs, not users — a generous per-IP cap is enough.
const WEBHOOK_RATE_LIMIT = { max: 60, windowSeconds: 60 } as const;

export async function paymentRoutes(
  app: FastifyInstance,
  opts: { paymentsService?: PaymentsService; rateLimit: RateLimitConfig },
): Promise<void> {
  // rawBody only for routes that opt in via config.rawBody (the webhook).
  await app.register(fastifyRawBody, { global: false });
  const r = app.withTypeProvider<ZodTypeProvider>();

  r.post(
    '/payments/initialize',
    {
      schema: {
        tags: ['payments'],
        summary: 'Start a Paystack checkout for a subscription plan',
        security: [{ bearerAuth: [] }],
        body: initializePaymentBodySchema,
        response: {
          200: initializePaymentResponseSchema,
          401: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.paymentsService) {
        return reply
          .code(503)
          .send({ error: 'unavailable', message: 'Payments are not configured' });
      }
      try {
        return await opts.paymentsService.initialize(request.user!.id, request.body.plan);
      } catch (err) {
        if (err instanceof PaymentsNotConfiguredError) {
          return reply
            .code(503)
            .send({ error: 'unavailable', message: 'Payments are not configured' });
        }
        throw err;
      }
    },
  );

  r.post(
    '/webhooks/paystack',
    {
      // rawBody (fastify-raw-body) so we can verify the HMAC over exact bytes.
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
      if (!opts.paymentsService) {
        return reply
          .code(503)
          .send({ error: 'unavailable', message: 'Payments are not configured' });
      }
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
        if (err instanceof PaymentsNotConfiguredError) {
          return reply
            .code(503)
            .send({ error: 'unavailable', message: 'Payments are not configured' });
        }
        throw err;
      }
    },
  );
}
