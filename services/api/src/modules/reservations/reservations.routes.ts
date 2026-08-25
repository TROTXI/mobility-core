// Reservation routes (#101, epic E3). The rider answers the daily "travelling?"
// prompt here (confirm/decline) and lists their upcoming reservations. The
// scheduled ask-dispatch + default-yes cron and the FCM push are deferred until
// trips (#18) land — see the module header.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { TripRepository } from '../mobility/trip.repository';
import type { VehicleRepository } from '../mobility/vehicle.repository';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { Reservation, ReservationRepository } from './reservation.repository';
import { generatePin, hashPin } from './pin';
import {
  listReservationsQuerySchema,
  reservationListResponseSchema,
  reservationResponseSchema,
  respondBodySchema,
} from './reservations.schema';

// Map a stored reservation to its public (client-facing) shape. Never includes
// the PIN hash; `pin` (plaintext) is added only on the confirming response.
function toResponse(
  r: Reservation,
  pin?: string,
): {
  id: string;
  tripId: string | null;
  travelDate: string;
  direction: Reservation['direction'];
  status: Reservation['status'];
  source: Reservation['source'];
  pin?: string;
} {
  return {
    id: r.id,
    tripId: r.tripId,
    travelDate: r.travelDate,
    direction: r.direction,
    status: r.status,
    source: r.source,
    ...(pin ? { pin } : {}),
  };
}

/**
 * Register reservation routes: `POST /me/reservations` and `GET /me/reservations`.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.reservations - the reservation repository (503 when absent).
 * @param opts.trips - trip lookup, to resolve the assigned vehicle (#161).
 * @param opts.vehicles - the fleet, for the seat ceiling; absent -> not enforced.
 * @param opts.secret - server key for hashing the daily boarding PIN.
 * @param opts.rateLimit - rate-limit config (applied per user).
 */
export async function reservationRoutes(
  app: FastifyInstance,
  opts: {
    reservations?: ReservationRepository;
    /** Trip lookup, to resolve the assigned vehicle's seat ceiling (#161). */
    trips?: TripRepository;
    /** Fleet, for that ceiling. Absent -> capacity is not enforced. */
    vehicles?: VehicleRepository;
    secret: string;
    rateLimit: RateLimitConfig;
  },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();
  const UNAVAILABLE = { error: 'unavailable', message: 'Reservations are not configured' };

  /**
   * The seat ceiling for a trip, or null when there is none to enforce.
   *
   * @param tripId - the trip being reserved on, if any.
   * @returns the vehicle's capacity, or null for unlimited.
   */
  const seatCeiling = async (tripId: string | null): Promise<number | null> => {
    if (!tripId || !opts.trips || !opts.vehicles) return null;
    const trip = await opts.trips.findById(tripId);
    if (!trip?.vehicleId) return null;
    const vehicle = await opts.vehicles.findById(trip.vehicleId);
    // capacity 0 means "not recorded" in the fleet data, not "no seats".
    return vehicle && vehicle.capacity > 0 ? vehicle.capacity : null;
  };

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
          409: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.reservations) return reply.code(503).send(UNAVAILABLE);
      // Confirming issues a fresh daily PIN; only the hash is stored, the
      // plaintext is returned once here for the rider to show at boarding.
      const pin = request.body.travelling ? generatePin() : undefined;
      const input = {
        userId: request.user!.id,
        tripId: request.body.tripId ?? null,
        travelDate: request.body.travelDate,
        direction: request.body.direction,
        travelling: request.body.travelling,
        pinHash: pin ? hashPin(pin, opts.secret) : null,
      };

      const capacity = request.body.travelling
        ? await seatCeiling(request.body.tripId ?? null)
        : null;

      // null ceiling = no vehicle assigned yet, or capacity not recorded. Ops
      // routinely creates trips before crewing them, so that means unlimited
      // rather than zero — otherwise nobody could reserve on a run until a bus
      // was attached.
      const reservation =
        capacity === null
          ? await opts.reservations.respond(input)
          : await opts.reservations.respondWithinCapacity(input, capacity);

      if (!reservation) {
        // Its own error code, not a bare 409: the app has to tell "this run is
        // full" from a generic conflict to show the right thing. This is also
        // where the standby offer cascade attaches (#105).
        return reply.code(409).send({ error: 'trip_full', message: 'This run is full' });
      }
      return toResponse(reservation, pin);
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
      return { reservations: rows.map((row) => toResponse(row)) };
    },
  );
}
