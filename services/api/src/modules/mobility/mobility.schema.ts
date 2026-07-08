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
});
