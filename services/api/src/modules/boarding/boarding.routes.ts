// Boarding routes (#20). GET /me/pass issues the rider's rotating QR pass;
// POST /boarding/scan lets a DRIVER verify a scanned pass (integrity) and logs
// the scan. Both are authed + per-user rate limited; scan additionally requires
// the driver role.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { TripRepository } from '../mobility/trip.repository';
import type { DriverRepository } from '../mobility/driver.repository';
import type { BoardingService } from './boarding.service';
import type { ManifestService } from './manifest.service';
import {
  boardRiderBodySchema,
  boardRiderResponseSchema,
  manifestQuerySchema,
  manifestResponseSchema,
  markNoShowBodySchema,
  markNoShowResponseSchema,
  passResponseSchema,
  resolveNoShowsBodySchema,
  resolveNoShowsResponseSchema,
  scanBodySchema,
  scanResponseSchema,
  verifyPinBodySchema,
  verifyPinResponseSchema,
} from './boarding.schema';

/**
 * Register the boarding routes (`GET /me/pass`, `POST /boarding/scan`,
 * `GET /boarding/manifest`).
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.boardingService - issues passes + verifies scans.
 * @param opts.manifestService - builds a trip's driver manifest (503 when absent).
 * @param opts.trips - trip lookup for the manifest assigned-driver authz.
 * @param opts.drivers - resolves the signed-in user to their driver record (authz).
 * @param opts.rateLimit - per-user rate-limit config.
 */
export async function boardingRoutes(
  app: FastifyInstance,
  opts: {
    boardingService: BoardingService;
    manifestService?: ManifestService;
    /** Trip lookup (existence + assignedDriverId) for the manifest authz. */
    trips?: TripRepository;
    /** Resolves the signed-in user to their driver record (manifest authz). */
    drivers?: DriverRepository;
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

  // Verification layer 2 — board a rider by the daily PIN they present (driver
  // types it against the manifest row). Boards + debits like the QR scan.
  r.post(
    '/boarding/verify-pin',
    {
      schema: {
        tags: ['boarding'],
        summary: 'Board a rider via their daily boarding code (driver only)',
        security: [{ bearerAuth: [] }],
        body: verifyPinBodySchema,
        response: {
          200: verifyPinResponseSchema,
          400: errorResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
        },
      },
      preHandler: [
        app.authenticate,
        app.rateLimit({ ...opts.rateLimit, by: 'user' }),
        app.requireRole('driver'),
      ],
    },
    async (request, reply) => {
      const result = await opts.boardingService.verifyPin({
        reservationId: request.body.reservationId,
        pin: request.body.pin,
        scannedBy: request.user!.id,
      });
      // Not this driver's run. A real status rather than a 200 body, matching
      // the manifest and GPS routes, so the app can tell "wrong code" from
      // "wrong bus" without parsing a reason string.
      if (result.reason === 'forbidden') {
        return reply
          .code(403)
          .send({ error: 'forbidden', message: 'Not the assigned driver for this trip' });
      }
      return result;
    },
  );

  // Board a rider straight off the manifest (#227) — the photo-pass path. The
  // frame's BOARD PASSENGER sits on a rider the driver has already matched to
  // the photo the SERVER supplied, so there is no code to ask for; the
  // assigned-driver check is the gate.
  r.post(
    '/boarding/board',
    {
      schema: {
        tags: ['boarding'],
        summary: 'Board a rider identified from the manifest photo (assigned driver only)',
        description:
          'The fallback for when a code will not scan or the rider cannot produce one. ' +
          'Idempotent per reservation, and shares boarding’s ledger key, so a rider ' +
          'previously marked a no-show is charged once rather than twice.',
        security: [{ bearerAuth: [] }],
        body: boardRiderBodySchema,
        response: {
          200: boardRiderResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
        },
      },
      preHandler: [
        app.authenticate,
        app.rateLimit({ ...opts.rateLimit, by: 'user' }),
        app.requireRole('driver'),
      ],
    },
    async (request, reply) => {
      const result = await opts.boardingService.boardRider({
        reservationId: request.body.reservationId,
        actedBy: request.user!.id,
      });
      if (result.reason === 'forbidden') {
        return reply
          .code(403)
          .send({ error: 'forbidden', message: 'Not the assigned driver for this trip' });
      }
      return result;
    },
  );

  // Per-rider no-show (#227). The bulk cutoff at /admin/resolve-no-shows stays
  // as it was; this is the driver at the stop, who is the one who actually
  // knows. Both share the `board:<reservationId>` ledger key, so a seat is
  // charged once no matter which of them gets there first.
  r.post(
    '/boarding/no-show',
    {
      schema: {
        tags: ['boarding'],
        summary: 'Mark one rider as not having turned up (assigned driver only)',
        description:
          'Deducts the ride now rather than at the cutoff. Reversible by boarding the ' +
          'rider afterwards — the shared ledger key means that costs nothing extra.',
        security: [{ bearerAuth: [] }],
        body: markNoShowBodySchema,
        response: {
          200: markNoShowResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
        },
      },
      preHandler: [
        app.authenticate,
        app.rateLimit({ ...opts.rateLimit, by: 'user' }),
        app.requireRole('driver'),
      ],
    },
    async (request, reply) => {
      const result = await opts.boardingService.markNoShow({
        reservationId: request.body.reservationId,
        actedBy: request.user!.id,
      });
      if (result.reason === 'forbidden') {
        return reply
          .code(403)
          .send({ error: 'forbidden', message: 'Not the assigned driver for this trip' });
      }
      return result;
    },
  );

  // Driver manifest for a trip — name + photo + boarded status of confirmed
  // riders (the "photo pass"). Restricted to the trip's ASSIGNED driver: it
  // exposes rider PII (names + faces), so a driver role alone is not enough —
  // the signed-in user must be the driver this trip is assigned to (same authz
  // as GPS reporting #25).
  r.get(
    '/boarding/manifest',
    {
      schema: {
        tags: ['boarding'],
        summary: "A trip's manifest — confirmed riders with name + photo (assigned driver only)",
        security: [{ bearerAuth: [] }],
        querystring: manifestQuerySchema,
        response: {
          200: manifestResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
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
      if (!opts.manifestService || !opts.trips || !opts.drivers) {
        return reply
          .code(503)
          .send({ error: 'unavailable', message: 'Manifest is not configured' });
      }
      const trip = await opts.trips.findById(request.query.tripId);
      if (!trip) return reply.code(404).send({ error: 'not_found', message: 'Trip not found' });

      // Assigned-driver authz: the signed-in user must be linked to the driver
      // this trip is assigned to. A driver role alone is not enough.
      const driver = await opts.drivers.findByUserId(request.user!.id);
      if (!driver || trip.assignedDriverId !== driver.id) {
        return reply
          .code(403)
          .send({ error: 'forbidden', message: 'Not the assigned driver for this trip' });
      }

      const riders = await opts.manifestService.getManifest(request.query.tripId);
      return { tripId: request.query.tripId, riders };
    },
  );

  // Cutoff no-show resolution (E4). A scheduled Render cron hits this with an
  // admin token after each travel window: every still-reserved seat that was
  // never boarded is deducted as a no-show. Admin-role gated, like the rest of
  // the ops surface (#26) and the E3/E5 cutoff triggers.
  r.post(
    '/admin/resolve-no-shows',
    {
      schema: {
        tags: ['admin'],
        summary: 'Cutoff: deduct confirmed-but-unboarded seats as no-shows',
        security: [{ bearerAuth: [] }],
        body: resolveNoShowsBodySchema,
        response: {
          200: resolveNoShowsResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
        },
      },
      preHandler: [
        app.authenticate,
        app.rateLimit({ ...opts.rateLimit, by: 'user' }),
        app.requireRole('admin'),
      ],
    },
    async (request) =>
      opts.boardingService.resolveNoShows(request.body.travelDate, request.body.direction),
  );
}
