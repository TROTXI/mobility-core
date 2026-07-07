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
