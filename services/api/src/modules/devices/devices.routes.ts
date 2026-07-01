// Device routes. POST /me/devices registers the caller's FCM push token (#84) —
// the foundation for push notifications. Auth + per-user rate limited.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { DeviceTokenRepository } from './device-token.repository';
import { registerDeviceBodySchema, registerDeviceResponseSchema } from './devices.schema';

/**
 * Register the device routes (`POST /me/devices`).
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.deviceTokens - the device-token repository.
 * @param opts.rateLimit - per-user rate-limit config.
 */
export async function deviceRoutes(
  app: FastifyInstance,
  opts: { deviceTokens: DeviceTokenRepository; rateLimit: RateLimitConfig },
): Promise<void> {
  app.withTypeProvider<ZodTypeProvider>().post(
    '/me/devices',
    {
      schema: {
        tags: ['auth'],
        summary: 'Register this device FCM push token for the authenticated user',
        security: [{ bearerAuth: [] }],
        body: registerDeviceBodySchema,
        response: {
          200: registerDeviceResponseSchema,
          401: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request) => {
      await opts.deviceTokens.register(
        request.user!.id,
        request.body.fcmToken,
        request.body.platform,
      );
      return { registered: true };
    },
  );
}
