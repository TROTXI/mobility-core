// Live vehicle position — HTTP pilot (#25). The MQTT/WS path (ADR-0006) is
// deferred.
//
//   POST /trips/:id/position  must be THE trip's assigned driver
//   GET  /trips/:id/position  any signed-in user; returns position + ETA
//
// trip_positions is the source of truth; the latest fix is also cached in KV so
// rider polls skip the DB.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import type { KvStore } from '../../kv/kv.store';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { DriverRepository } from './driver.repository';
import { directionOf } from './direction';
import { computeEtas, type RouteStopPoint } from './eta';
import type { SegmentSpeedRepository } from './segment-speed.repository';
import type { RouteGeometryRepository } from './route-geometry.repository';
import {
  livePositionResponseSchema,
  recordedPositionResponseSchema,
  reportPositionBodySchema,
} from './mobility.schema';
import type { RouteStopRepository } from './route-stop.repository';
import type { ReservationRepository } from '../reservations/reservation.repository';
import type { StopRepository } from './stop.repository';
import {
  InactiveTripPositionError,
  type TripPosition,
  type TripPositionRepository,
} from './trip-position.repository';
import type { TripRepository } from './trip.repository';

/** Latest fix as cached in the KV store (recordedAt is an ISO string over JSON). */
interface CachedFix {
  latitude: number;
  longitude: number;
  recordedAt: string;
}

/** How long the KV store keeps a trip's latest fix (refreshed on every report). */
const POSITION_CACHE_TTL_SECONDS = 300;
/** Device clocks beyond this allowance are rejected instead of moving a bus into the future. */
export const MAX_POSITION_FUTURE_SKEW_MS = 2 * 60 * 1000;
const cacheKey = (tripId: string): string => `trip:position:${tripId}`;

/**
 * Register the live-position routes (`POST` / `GET /trips/:id/position`).
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies (503 when the repos they need are unwired).
 * @param opts.reservations - reservations, to resolve the caller's own stop (#204).
 * @param opts.trips - trip lookup (existence + assignedDriverId).
 * @param opts.drivers - resolves the signed-in user to their driver record (authz).
 * @param opts.routeStops - the route's ordered stop placements (for ETA).
 * @param opts.stops - stop coordinates (for ETA).
 * @param opts.tripPositions - durable fix store (source of truth).
 * @param opts.segmentSpeeds - observed segment speeds (#181); absent -> cold-start speed.
 * @param opts.routeGeometry - learned road-following route shape (#287).
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
    /** Observed segment speeds (#181). Absent -> ETAs use the cold-start speed. */
    segmentSpeeds?: SegmentSpeedRepository;
    routeGeometry?: RouteGeometryRepository;
    /** Reservations, to resolve the caller's own pickup stop (#204). */
    reservations?: ReservationRepository;
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
          409: errorResponseSchema,
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

      if (trip.status !== 'active') {
        return reply.code(409).send({
          error: 'trip_not_active',
          message: 'Positions can only be reported while the trip is active',
        });
      }

      const recordedAt = request.body.recordedAt ? new Date(request.body.recordedAt) : undefined;
      const now = new Date();
      if (recordedAt && recordedAt.getTime() > now.getTime() + MAX_POSITION_FUTURE_SKEW_MS) {
        return reply.code(409).send({
          error: 'invalid_capture_time',
          message: 'Position capture time is too far in the future',
        });
      }
      if (recordedAt && trip.startedAt && recordedAt < trip.startedAt) {
        return reply.code(409).send({
          error: 'invalid_capture_time',
          message: 'Position was captured before the trip started',
        });
      }

      let fix: TripPosition;
      try {
        fix = await opts.tripPositions.record({
          tripId: trip.id,
          latitude: request.body.latitude,
          longitude: request.body.longitude,
          ...(recordedAt ? { recordedAt } : {}),
          ...(request.body.clientFixId ? { clientFixId: request.body.clientFixId } : {}),
        });
      } catch (error) {
        if (error instanceof InactiveTripPositionError) {
          return reply.code(409).send({
            error: 'trip_not_active',
            message: 'Positions can only be reported while the trip is active',
          });
        }
        throw error;
      }

      // A queued replay may be older than a fix already stored. Cache the
      // durable latest row, never blindly replace it with the replayed row.
      const latest = (await opts.tripPositions.findLatest(trip.id)) ?? fix;
      const cached: CachedFix = {
        latitude: latest.latitude,
        longitude: latest.longitude,
        recordedAt: latest.recordedAt.toISOString(),
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
          409: errorResponseSchema,
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
      if (trip.status !== 'active') {
        return reply.code(409).send({
          error: 'trip_not_active',
          message: 'Live position is only available while the trip is active',
        });
      }

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

      // Observed medians where we have them, cold-start speed everywhere else.
      // Optional on purpose: a corridor with no run history still returns an
      // ETA on its first day rather than nothing at all.
      const speeds = opts.segmentSpeeds
        ? await opts.segmentSpeeds.findByRoute(trip.routeId, directionOf(trip.scheduledAt))
        : undefined;
      const geometry = opts.routeGeometry
        ? await opts.routeGeometry.findByRoute(trip.routeId)
        : undefined;

      const etaToStops = computeEtas(position, stopPoints, speeds, geometry ?? undefined);

      // Which of those stops is the caller's. Absent reservations store, no
      // reservation on this trip, or no stop recorded all mean null rather
      // than an error: the trip's ETAs are still useful without it.
      let riderStop = null;
      if (opts.reservations) {
        const mine = (await opts.reservations.listForTrip(trip.id)).find(
          (res) => res.userId === request.user!.id,
        );
        if (mine?.pickupStopId) {
          riderStop = etaToStops.find((e) => e.stopId === mine.pickupStopId) ?? null;
        }
      }

      return { tripId: trip.id, position, etaToStops, riderStop };
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
