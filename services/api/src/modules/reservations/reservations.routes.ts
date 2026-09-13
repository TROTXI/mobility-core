// Reservation routes (#101, E3). The rider answers the daily "travelling?"
// prompt here and lists upcoming reservations. Capacity is enforced on confirm
// (#161), and so is the membership: confirming a seat is the paywall.
//
// The gate lives HERE and not at boarding on purpose. Boarding fails open by
// design (boarding.service.ts) because a rider stuck at the kerb with a queue
// behind them is a worse outcome than an unpaid ride, so the seat has to be
// refused at the point it is claimed, hours earlier, where a refusal costs
// nothing but a message on a phone.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { EntitlementLedgerRepository } from '../entitlements/entitlement-ledger.repository';
import type { TripRepository } from '../mobility/trip.repository';
import type { VehicleRepository } from '../mobility/vehicle.repository';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { SubscriptionRepository } from '../subscriptions/subscription.repository';
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
  pickupStopId: string | null;
  dropoffStopId: string | null;
  travelDate: string;
  direction: Reservation['direction'];
  status: Reservation['status'];
  source: Reservation['source'];
  pin?: string;
} {
  return {
    id: r.id,
    tripId: r.tripId,
    pickupStopId: r.pickupStopId,
    dropoffStopId: r.dropoffStopId,
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
 * @param opts.subscriptions - memberships, for the paywall; absent -> not enforced.
 * @param opts.entitlements - the ride ledger, for the balance check.
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
    /** Memberships. Absent -> the paywall is not enforced (dev/tests only). */
    subscriptions?: SubscriptionRepository;
    /** Ride entitlement ledger, for the remaining-rides check. */
    entitlements?: EntitlementLedgerRepository;
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

  /**
   * Why this rider may not claim a seat, or null when they may.
   *
   * Three questions, cheapest first: are they a member, do they have a ride
   * left, and is this run even on the corridor they bought. The route check is
   * skipped when either side is unknown, so trips created before riders were
   * pinned to a corridor still confirm.
   *
   * @param userId - the authenticated rider.
   * @param tripId - the run they are claiming a seat on, if they named one.
   * @returns an error code and message to refuse with, or null to allow.
   */
  const refusalFor = async (
    userId: string,
    tripId: string | null,
  ): Promise<{ error: string; message: string } | null> => {
    if (!opts.subscriptions) return null;

    const subscription = await opts.subscriptions.findActiveByUser(userId);
    if (!subscription) {
      return {
        error: 'no_subscription',
        message: 'An active membership is required to reserve a seat',
      };
    }

    // Counting the ledger rather than trusting the period's grant: credit
    // conversion and no-show deductions both move this number mid-period.
    if (opts.entitlements && (await opts.entitlements.remainingRides(userId)) <= 0) {
      return {
        error: 'no_rides_left',
        message: 'No rides remaining on your membership for this period',
      };
    }

    // A membership is bought for one corridor at one price (ADR-0015), so it
    // cannot claim seats on another. Without this the paywall is per-rider but
    // not per-route, and the cheapest corridor buys the whole city.
    if (tripId && subscription.routeId && opts.trips) {
      const trip = await opts.trips.findById(tripId);
      if (trip && trip.routeId !== subscription.routeId) {
        return {
          error: 'route_not_covered',
          message: 'Your membership does not cover this route',
        };
      }
    }

    return null;
  };

  r.post(
    '/me/reservations',
    {
      schema: {
        tags: ['reservations'],
        summary: 'Confirm or decline the daily ride (upsert per day + direction)',
        description:
          'Confirming requires an active membership with a ride left on the corridor ' +
          'the run belongs to; 402 says which of the three is missing. Declining is ' +
          'always allowed.',
        security: [{ bearerAuth: [] }],
        body: respondBodySchema,
        response: {
          200: reservationResponseSchema,
          401: errorResponseSchema,
          402: errorResponseSchema,
          409: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.reservations) return reply.code(503).send(UNAVAILABLE);

      // Only confirming is gated. Declining stays open to everyone: it consumes
      // nothing, and a rider whose membership just lapsed should still be able
      // to tell the driver not to wait for them.
      if (request.body.travelling) {
        const refusal = await refusalFor(request.user!.id, request.body.tripId ?? null);
        if (refusal) return reply.code(402).send(refusal);
      }

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
        subscriptionPeriodId: request.body.travelling
          ? (await opts.subscriptions?.findActiveByUser(request.user!.id))?.currentPeriodId
          : undefined,
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
