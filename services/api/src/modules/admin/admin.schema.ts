// Request-body schemas for the admin/ops endpoints (#26). Responses reuse the
// domain schemas from mobility.schema.ts. Create bodies mirror the repositories'
// New* inputs; update bodies are partial (every field optional) — the handler
// merges the patch over the existing row, so an omitted field is left unchanged
// and an explicit null clears a nullable field. Timestamps are ISO-8601 strings
// on the wire and converted to Date at the handler boundary.

import { z } from 'zod';
import { TRIP_STATUSES } from '../mobility/trip.repository';

const latitude = z.number().min(-90).max(90);
const longitude = z.number().min(-180).max(180);

// --- routes ---
export const createRouteBodySchema = z.object({
  name: z.string().min(1),
  description: z.string().nullable().optional(),
});
export const updateRouteBodySchema = z.object({
  name: z.string().min(1).optional(),
  description: z.string().nullable().optional(),
});

// --- stops ---
export const createStopBodySchema = z.object({
  name: z.string().min(1),
  latitude,
  longitude,
});
export const updateStopBodySchema = z.object({
  name: z.string().min(1).optional(),
  latitude: latitude.optional(),
  longitude: longitude.optional(),
});

// Attach an existing stop to a route at a sequence position (route_stops).
export const attachStopBodySchema = z.object({
  stopId: z.string().uuid(),
  seq: z.number().int().nonnegative(),
});

// --- vehicles ---
export const createVehicleBodySchema = z.object({
  registration: z.string().min(1),
  label: z.string().nullable().optional(),
  capacity: z.number().int().nonnegative().optional(),
});
export const updateVehicleBodySchema = z.object({
  registration: z.string().min(1).optional(),
  label: z.string().nullable().optional(),
  capacity: z.number().int().nonnegative().optional(),
});

// --- drivers ---
export const createDriverBodySchema = z.object({
  fullName: z.string().min(1),
  phone: z.string().nullable().optional(),
  licenseNumber: z.string().nullable().optional(),
  userId: z.string().uuid().nullable().optional(),
});
export const updateDriverBodySchema = z.object({
  fullName: z.string().min(1).optional(),
  phone: z.string().nullable().optional(),
  licenseNumber: z.string().nullable().optional(),
  userId: z.string().uuid().nullable().optional(),
});

// --- trips ---
export const createTripBodySchema = z.object({
  routeId: z.string().uuid(),
  vehicleId: z.string().uuid().nullable().optional(),
  assignedDriverId: z.string().uuid().nullable().optional(),
  status: z.enum(TRIP_STATUSES).optional(),
  scheduledAt: z.string().datetime(),
});
export const updateTripBodySchema = z.object({
  status: z.enum(TRIP_STATUSES).optional(),
  scheduledAt: z.string().datetime().optional(),
});

// Driver↔trip (and vehicle) assignment — the field that authorizes GPS
// reporting (#25). Both optional so a call can assign either or both; an
// explicit null unassigns.
export const assignTripBodySchema = z.object({
  vehicleId: z.string().uuid().nullable().optional(),
  assignedDriverId: z.string().uuid().nullable().optional(),
});
