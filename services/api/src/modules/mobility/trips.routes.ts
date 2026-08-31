// Trip routes (#18). Trips are the operational layer over routes — one scheduled
// run of a route by a vehicle and driver. Reads require authentication (unlike
// public route browsing): schedules are app-facing data for signed-in commuters
// and drivers, and this is the guard the issue calls out as a dependency. Write
// paths (create/assign) live in the admin/ops module (#26). GPS position
// reporting authorized by assignedDriverId lives in positions.routes.ts (#25).

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import {
  listTripsQuerySchema,
  riderTripResponseSchema,
  tripListResponseSchema,
} from './mobility.schema';
import type { Trip, TripRepository } from './trip.repository';
import type { VehicleRepository } from './vehicle.repository';

// Map a stored trip to its public (client-facing) shape.
function toResponse(t: Trip): {
  id: string;
  routeId: string;
  vehicleId: string | null;
  assignedDriverId: string | null;
  status: Trip['status'];
  scheduledAt: Date;
  createdAt: Date;
} {
  return {
    id: t.id,
    routeId: t.routeId,
    vehicleId: t.vehicleId,
    assignedDriverId: t.assignedDriverId,
    status: t.status,
    scheduledAt: t.scheduledAt,
    createdAt: t.createdAt,
  };
}

/**
 * Register trip routes: `GET /trips` (optional `?routeId`) and `GET /trips/:id`.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.trips - the trip repository (503 when absent).
 * @param opts.vehicles - vehicles, for the rider-facing van details (#205).
 * @param opts.rateLimit - rate-limit config (applied per user).
 */
export async function tripRoutes(
  app: FastifyInstance,
  opts: { trips?: TripRepository; vehicles?: VehicleRepository; rateLimit: RateLimitConfig },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();
  const UNAVAILABLE = { error: 'unavailable', message: 'Trips are not configured' };

  r.get(
    '/trips',
    {
      schema: {
        tags: ['mobility'],
        summary: 'List trips, optionally filtered by route',
        security: [{ bearerAuth: [] }],
        querystring: listTripsQuerySchema,
        response: {
          200: tripListResponseSchema,
          401: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.trips) return reply.code(503).send(UNAVAILABLE);
      const trips = await opts.trips.findAll({ routeId: request.query.routeId });
      return { trips: trips.map(toResponse) };
    },
  );

  r.get(
    '/trips/:id',
    {
      schema: {
        tags: ['mobility'],
        summary: 'Get a trip by id',
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        response: {
          200: riderTripResponseSchema,
          401: errorResponseSchema,
          404: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.trips) return reply.code(503).send(UNAVAILABLE);
      const trip = await opts.trips.findById(request.params.id);
      if (!trip) {
        return reply.code(404).send({ error: 'not_found', message: 'Trip not found' });
      }

      // Only what a rider needs to pick the van out at the kerb (#205). The
      // internal label, seat count and vehicle id stay on the fleet record.
      const vehicle =
        trip.vehicleId && opts.vehicles ? await opts.vehicles.findById(trip.vehicleId) : null;

      return {
        ...toResponse(trip),
        startedAt: trip.startedAt,
        completedAt: trip.completedAt,
        durationSeconds:
          trip.startedAt && trip.completedAt
            ? Math.round((trip.completedAt.getTime() - trip.startedAt.getTime()) / 1000)
            : null,
        vehicle: vehicle
          ? { registration: vehicle.registration, make: vehicle.make, colour: vehicle.colour }
          : null,
      };
    },
  );
}
