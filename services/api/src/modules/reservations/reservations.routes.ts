// Reservation routes (#101, epic E3). The rider answers the daily "travelling?"
// prompt here (confirm/decline) and lists their upcoming reservations. The
// scheduled ask-dispatch + default-yes cron and the FCM push are deferred until
// trips (#18) land — see the module header.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { Reservation, ReservationRepository } from './reservation.repository';
import {
  listReservationsQuerySchema,
  reservationListResponseSchema,
  reservationResponseSchema,
  respondBodySchema,
} from './reservations.schema';

// Map a stored reservation to its public (client-facing) shape.
function toResponse(r: Reservation): {
  id: string;
  tripId: string | null;
  travelDate: string;
  direction: Reservation['direction'];
  status: Reservation['status'];
  source: Reservation['source'];
} {
  return {
    id: r.id,
    tripId: r.tripId,
    travelDate: r.travelDate,
    direction: r.direction,
    status: r.status,
    source: r.source,
  };
}

/**
 * Register reservation routes: `POST /me/reservations` and `GET /me/reservations`.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.reservations - the reservation repository (503 when absent).
 * @param opts.rateLimit - rate-limit config (applied per user).
 */
export async function reservationRoutes(
  app: FastifyInstance,
  opts: { reservations?: ReservationRepository; rateLimit: RateLimitConfig },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();
  const UNAVAILABLE = { error: 'unavailable', message: 'Reservations are not configured' };

  r.post(
    '/me/reservations',
    {
      schema: {
        tags: ['reservations'],
        summary: 'Confirm or decline the daily ride (upsert per day + direction)',
        security: [{ bearerAuth: [] }],
        body: respondBodySchema,
        response: {
          200: reservationResponseSchema,
          401: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.reservations) return reply.code(503).send(UNAVAILABLE);
      const reservation = await opts.reservations.respond({
        userId: request.user!.id,
        tripId: request.body.tripId ?? null,
        travelDate: request.body.travelDate,
        direction: request.body.direction,
        travelling: request.body.travelling,
      });
      return toResponse(reservation);
    },
  );

  r.get(
    '/me/reservations',
    {
      schema: {
        tags: ['reservations'],
        summary: "List the rider's reservations (newest travel day first)",
        security: [{ bearerAuth: [] }],
        querystring: listReservationsQuerySchema,
        response: {
          200: reservationListResponseSchema,
          401: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.reservations) return reply.code(503).send(UNAVAILABLE);
      const rows = await opts.reservations.listForUser(request.user!.id, {
        fromDate: request.query.from,
      });
      return { reservations: rows.map(toResponse) };
    },
  );
}
