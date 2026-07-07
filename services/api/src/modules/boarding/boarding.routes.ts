// Boarding routes (#20). GET /me/pass issues the rider's rotating QR pass;
// POST /boarding/scan lets a DRIVER verify a scanned pass (integrity) and logs
// the scan. Both are authed + per-user rate limited; scan additionally requires
// the driver role.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { BoardingService } from './boarding.service';
import type { ManifestService } from './manifest.service';
import {
  manifestQuerySchema,
  manifestResponseSchema,
  passResponseSchema,
  scanBodySchema,
  scanResponseSchema,
} from './boarding.schema';

/**
 * Register the boarding routes (`GET /me/pass`, `POST /boarding/scan`,
 * `GET /boarding/manifest`).
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.boardingService - issues passes + verifies scans.
 * @param opts.manifestService - builds a trip's driver manifest (503 when absent).
 * @param opts.rateLimit - per-user rate-limit config.
 */
export async function boardingRoutes(
  app: FastifyInstance,
  opts: {
    boardingService: BoardingService;
    manifestService?: ManifestService;
    rateLimit: RateLimitConfig;
  },
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

  // Driver manifest for a trip — name + photo + boarded status of confirmed
  // riders (the "photo pass"). Driver-role gated. (Restricting to the trip's
  // ASSIGNED driver is a security follow-up — it needs the driver↔user lookup
  // that GPS reporting #25 also requires; both land together.)
  r.get(
    '/boarding/manifest',
    {
      schema: {
        tags: ['boarding'],
        summary: "A trip's manifest — confirmed riders with name + photo (driver only)",
        security: [{ bearerAuth: [] }],
        querystring: manifestQuerySchema,
        response: {
          200: manifestResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [
        app.authenticate,
        app.rateLimit({ ...opts.rateLimit, by: 'user' }),
        app.requireRole('driver'),
      ],
    },
    async (request, reply) => {
      if (!opts.manifestService) {
        return reply
          .code(503)
          .send({ error: 'unavailable', message: 'Manifest is not configured' });
      }
      const riders = await opts.manifestService.getManifest(request.query.tripId);
      return { tripId: request.query.tripId, riders };
    },
  );
}
