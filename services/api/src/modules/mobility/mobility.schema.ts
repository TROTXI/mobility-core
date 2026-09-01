// Zod schemas for the mobility domain. These serve dual purpose: runtime
// validation of responses and OpenAPI spec generation via the zod type
// provider (ADR-0008). stopResponseSchema exposes lat/lng as plain numbers
// rather than a PostGIS geometry — the Pg adapter handles the conversion.

import { z } from 'zod';
import { TRIP_STATUSES } from './trip.repository';

export const stopResponseSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  latitude: z.number(),
  longitude: z.number(),
  createdAt: z.date(),
});

export const routeResponseSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  description: z.string().nullable(),
  createdAt: z.date(),
});

// routeWithStopsResponseSchema extends the base route shape with an ordered
// list of stops. seq is included so clients can render the route in the correct
// direction without re-sorting.
export const routeWithStopsResponseSchema = routeResponseSchema.extend({
  stops: z.array(
    stopResponseSchema.extend({
      seq: z.number().int(),
    }),
  ),
});

// A trip is one scheduled run of a route. vehicleId/assignedDriverId are exposed
// as plain FK ids (nullable until ops assigns them, #26) rather than expanded
// objects — clients resolve the route via GET /routes/:id. status is the shared
// lifecycle enum (source of truth: trip.repository.ts + the migration CHECK).
export const tripResponseSchema = z.object({
  id: z.string().uuid(),
  routeId: z.string().uuid(),
  vehicleId: z.string().uuid().nullable(),
  assignedDriverId: z.string().uuid().nullable(),
  status: z.enum(TRIP_STATUSES),
  scheduledAt: z.date(),
  createdAt: z.date(),
});

/**
 * A trip as a rider sees it (#205): when it actually ran, and enough about the
 * van to recognise it at the kerb.
 *
 * Deliberately not the fleet record. A rider needs the plate, the model and the
 * colour; they do not need our internal label, seat count or vehicle id.
 */
export const riderTripResponseSchema = tripResponseSchema.extend({
  /** When the driver started the run; null while scheduled. */
  startedAt: z.date().nullable(),
  /** When the driver ended it; null until completed. */
  completedAt: z.date().nullable(),
  /** How long the run took. Null until it has both timestamps. */
  durationSeconds: z.number().int().nullable(),
  vehicle: z
    .object({
      registration: z.string(),
      make: z.string().nullable(),
      colour: z.string().nullable(),
    })
    .nullable(),
});

// GET /trips filters: routeId narrows to one route's runs (optional — omit to
// list all).
export const listTripsQuerySchema = z.object({
  routeId: z.string().uuid().optional(),
});

export const tripListResponseSchema = z.object({
  trips: z.array(tripResponseSchema),
});

// A vehicle (bus) in the fleet. Exposed by admin ops (#26); no public endpoint.
export const vehicleResponseSchema = z.object({
  id: z.string().uuid(),
  registration: z.string(),
  label: z.string().nullable(),
  make: z.string().nullable(),
  colour: z.string().nullable(),
  capacity: z.number().int(),
  createdAt: z.date(),
});

// A driver. userId links to an auth principal once driver sign-in lands (#25).
export const driverResponseSchema = z.object({
  id: z.string().uuid(),
  fullName: z.string(),
  phone: z.string().nullable(),
  licenseNumber: z.string().nullable(),
  userId: z.string().uuid().nullable(),
  createdAt: z.date(),
});

// A GPS fix reported by a trip's assigned driver (#25). recordedAt is assigned by
// the server, so the body carries only coordinates; ranges match WGS84 lat/lng.
export const reportPositionBodySchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
});

// Acknowledgement returned to the driver after a fix is recorded — the stored
// fix, no ETA (the driver knows the route; ETA is for riders via GET).
export const recordedPositionResponseSchema = z.object({
  tripId: z.string().uuid(),
  position: z.object({
    latitude: z.number(),
    longitude: z.number(),
    recordedAt: z.date(),
  }),
});

// The trip's latest live position plus a deterministic ETA to each upcoming stop
// along the route's ordered stops (system-design §7). etaToStops is empty when the
// route has fewer than two stops or the vehicle is past the last stop.
/**
 * The path a route actually follows (#206), for drawing a line on the map.
 *
 * `source` says where it came from and is meant to be shown, not hidden:
 * `traces` is the road-following path derived from completed runs (#179),
 * `stops` is the straight-line fallback for a corridor that has not run enough
 * times to have learned one yet. A client can render both; only one of them
 * follows the road.
 */
export const routeGeometryResponseSchema = z.object({
  routeId: z.string().uuid(),
  points: z.array(z.object({ latitude: z.number(), longitude: z.number() })),
  source: z.enum(['traces', 'matched', 'manual', 'stops']),
  /** Completed runs the path was derived from. 0 for the stop fallback. */
  runCount: z.number().int(),
});

export const livePositionResponseSchema = z.object({
  tripId: z.string().uuid(),
  position: z.object({
    latitude: z.number(),
    longitude: z.number(),
    recordedAt: z.date(),
  }),
  etaToStops: z.array(
    z.object({
      stopId: z.string().uuid(),
      seq: z.number().int(),
      name: z.string(),
      distanceMeters: z.number(),
      etaSeconds: z.number(),
    }),
  ),
  /**
   * The caller's own pickup stop on this trip (#204), already picked out of
   * `etaToStops`. Null when the rider has no reservation on this trip, has no
   * pickup stop recorded, or the van is already past it.
   *
   * Served rather than left to the client because every client would otherwise
   * reimplement the same "which of these is mine" lookup, and "your van is 6
   * minutes away" is the whole point of the screen.
   */
  riderStop: z
    .object({
      stopId: z.string().uuid(),
      seq: z.number().int(),
      name: z.string(),
      distanceMeters: z.number(),
      etaSeconds: z.number(),
    })
    .nullable(),
});
