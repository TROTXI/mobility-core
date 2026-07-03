// Boarding routes (#20). GET /me/pass issues the rider's rotating QR pass;
// POST /boarding/scan lets a DRIVER verify a scanned pass (integrity) and logs
// the scan. Both are authed + per-user rate limited; scan additionally requires
// the driver role.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { BoardingService } from './boarding.service';
import { passResponseSchema, scanBodySchema, scanResponseSchema } from './boarding.schema';

/**
 * Register the boarding routes (`GET /me/pass`, `POST /boarding/scan`).
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.boardingService - issues passes + verifies scans.
 * @param opts.rateLimit - per-user rate-limit config.
 */
export async function boardingRoutes(
  app: FastifyInstance,
  opts: { boardingService: BoardingService; rateLimit: RateLimitConfig },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();

  r.get(
    '/me/pass',
    {
      schema: {
        tags: ['boarding'],
        summary: 'Issue the rider a short-lived boarding pass (render as a QR)',
        security: [{ bearerAuth: [] }],
        response: { 200: passResponseSchema, 401: errorResponseSchema },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request) => opts.boardingService.issuePass(request.user!.id),
  );

  r.post(
    '/boarding/scan',
    {
      schema: {
        tags: ['boarding'],
        summary: 'Verify a scanned rider pass (driver only) and record the scan',
        security: [{ bearerAuth: [] }],
        body: scanBodySchema,
        response: {
          200: scanResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
        },
      },
      // Throttle BEFORE the role check — otherwise non-driver tokens could
      // hammer 403s without ever being rate limited.
      preHandler: [
        app.authenticate,
        app.rateLimit({ ...opts.rateLimit, by: 'user' }),
        app.requireRole('driver'),
      ],
    },
    async (request) =>
      opts.boardingService.verifyScan({
        pass: request.body.pass,
        scannedBy: request.user!.id,
        tripId: request.body.tripId,
      }),
  );
}
