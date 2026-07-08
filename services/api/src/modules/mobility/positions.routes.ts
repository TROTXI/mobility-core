// Live vehicle position — HTTP pilot (#25, system-design §7). The MQTT/Go/WS
// telemetry path (ADR-0006) is deferred; here a driver POSTs GPS fixes over HTTP
// and riders GET the latest fix with a deterministic ETA to each upcoming stop.
//
//   POST /trips/:id/position  driver-only AND must be THE trip's assigned driver.
//   GET  /trips/:id/position  any signed-in user (rider); returns position + ETA.
//
// The durable trip_positions store is the source of truth; the latest fix is also
// written through to the KV store (Redis when available) so rider polls read a
// hot cache instead of the DB. ETA is recomputed per read from the route's stops
// (see eta.ts) — cheap and always reflects the current route configuration.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import type { KvStore } from '../../kv/kv.store';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { DriverRepository } from './driver.repository';
import { computeEtas, type RouteStopPoint } from './eta';
import {
  livePositionResponseSchema,
  recordedPositionResponseSchema,
  reportPositionBodySchema,
} from './mobility.schema';
import type { RouteStopRepository } from './route-stop.repository';
import type { StopRepository } from './stop.repository';
import type { TripPositionRepository } from './trip-position.repository';
import type { TripRepository } from './trip.repository';

/** Latest fix as cached in the KV store (recordedAt is an ISO string over JSON). */
interface CachedFix {
  latitude: number;
  longitude: number;
  recordedAt: string;
}

/** How long the KV store keeps a trip's latest fix (refreshed on every report). */
const POSITION_CACHE_TTL_SECONDS = 300;
const cacheKey = (tripId: string): string => `trip:position:${tripId}`;

/**
 * Register the live-position routes (`POST` / `GET /trips/:id/position`).
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies (503 when the repos they need are unwired).
 * @param opts.trips - trip lookup (existence + assignedDriverId).
 * @param opts.drivers - resolves the signed-in user to their driver record (authz).
 * @param opts.routeStops - the route's ordered stop placements (for ETA).
 * @param opts.stops - stop coordinates (for ETA).
 * @param opts.tripPositions - durable fix store (source of truth).
 * @param opts.kv - latest-fix cache (Redis when available).
 * @param opts.rateLimit - per-user rate-limit config.
 */
export async function positionRoutes(
  app: FastifyInstance,
  opts: {
    trips?: TripRepository;
    drivers?: DriverRepository;
    routeStops?: RouteStopRepository;
    stops?: StopRepository;
    tripPositions?: TripPositionRepository;
    kv: KvStore;
    rateLimit: RateLimitConfig;
  },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();
  const UNAVAILABLE = { error: 'unavailable', message: 'Live positions are not configured' };
  const notFound = (message: string) => ({ error: 'not_found', message });
  const idParam = z.object({ id: z.string().uuid() });

  r.post(
    '/trips/:id/position',
    {
      schema: {
        tags: ['mobility'],
        summary: 'Report a GPS fix for a trip (assigned driver only)',
        security: [{ bearerAuth: [] }],
        params: idParam,
        body: reportPositionBodySchema,
        response: {
          200: recordedPositionResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      // Throttle BEFORE the role check (house convention, cf. boarding/admin) so
      // non-driver tokens can't hammer 403s without being rate limited.
      preHandler: [
        app.authenticate,
        app.rateLimit({ ...opts.rateLimit, by: 'user' }),
        app.requireRole('driver'),
      ],
    },
    async (request, reply) => {
      if (!opts.trips || !opts.drivers || !opts.tripPositions) {
        return reply.code(503).send(UNAVAILABLE);
      }
      const trip = await opts.trips.findById(request.params.id);
      if (!trip) return reply.code(404).send(notFound('Trip not found'));

      // Assigned-driver authz: the signed-in user must be linked to the driver
      // this trip is assigned to. A driver role alone is not enough.
      const driver = await opts.drivers.findByUserId(request.user!.id);
      if (!driver || trip.assignedDriverId !== driver.id) {
        return reply
          .code(403)
          .send({ error: 'forbidden', message: 'Not the assigned driver for this trip' });
      }

      const fix = await opts.tripPositions.record({
        tripId: trip.id,
        latitude: request.body.latitude,
        longitude: request.body.longitude,
      });

      // Write-through: warm the latest-fix cache riders read from.
      const cached: CachedFix = {
        latitude: fix.latitude,
        longitude: fix.longitude,
        recordedAt: fix.recordedAt.toISOString(),
      };
      await opts.kv.set(cacheKey(trip.id), JSON.stringify(cached), POSITION_CACHE_TTL_SECONDS);

      return {
        tripId: trip.id,
        position: {
          latitude: fix.latitude,
          longitude: fix.longitude,
          recordedAt: fix.recordedAt,
        },
      };
    },
  );

  r.get(
    '/trips/:id/position',
    {
      schema: {
        tags: ['mobility'],
        summary: "Get a trip's latest position with a deterministic ETA to each upcoming stop",
        security: [{ bearerAuth: [] }],
        params: idParam,
        response: {
          200: livePositionResponseSchema,
          401: errorResponseSchema,
          404: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.trips || !opts.tripPositions || !opts.routeStops || !opts.stops) {
        return reply.code(503).send(UNAVAILABLE);
      }
      const trip = await opts.trips.findById(request.params.id);
      if (!trip) return reply.code(404).send(notFound('Trip not found'));

      const position = await latestFix(opts.kv, opts.tripPositions, trip.id);
      if (!position) return reply.code(404).send(notFound('No live position for this trip'));

      // Resolve the route's stops in seq order (route_stops → stops), mirroring
      // GET /routes/:id. Drop any stop that no longer resolves (defensive).
      const routeStops = await opts.routeStops.findByRoute(trip.routeId);
      const stopPoints = (
        await Promise.all(
          routeStops.map(async (rs): Promise<RouteStopPoint | null> => {
            const stop = await opts.stops!.findById(rs.stopId);
            return stop
              ? {
                  stopId: stop.id,
                  name: stop.name,
                  seq: rs.seq,
                  latitude: stop.latitude,
                  longitude: stop.longitude,
                }
              : null;
          }),
        )
      ).filter((s): s is RouteStopPoint => s !== null);

      return {
        tripId: trip.id,
        position,
        etaToStops: computeEtas(position, stopPoints),
      };
    },
  );
}

/**
 * Latest fix for a trip: KV cache first, falling back to the durable store and
 * warming the cache on a miss.
 *
 * @param kv - the latest-fix cache.
 * @param tripPositions - the durable fix store (source of truth).
 * @param tripId - the trip whose latest fix to read.
 * @returns the latest position, or null when no fix has ever been reported.
 */
async function latestFix(
  kv: KvStore,
  tripPositions: TripPositionRepository,
  tripId: string,
): Promise<{ latitude: number; longitude: number; recordedAt: Date } | null> {
  const cached = await kv.get(cacheKey(tripId));
  if (cached) {
    const fix = JSON.parse(cached) as CachedFix;
    return {
      latitude: fix.latitude,
      longitude: fix.longitude,
      recordedAt: new Date(fix.recordedAt),
    };
  }

  const stored = await tripPositions.findLatest(tripId);
  if (!stored) return null;

  const toCache: CachedFix = {
    latitude: stored.latitude,
    longitude: stored.longitude,
    recordedAt: stored.recordedAt.toISOString(),
  };
  await kv.set(cacheKey(tripId), JSON.stringify(toCache), POSITION_CACHE_TTL_SECONDS);
  return {
    latitude: stored.latitude,
    longitude: stored.longitude,
    recordedAt: stored.recordedAt,
  };
}
