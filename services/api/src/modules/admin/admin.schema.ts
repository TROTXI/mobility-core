// Request-body schemas for the admin/ops endpoints (#26). Responses reuse the
// domain schemas from mobility.schema.ts. Create bodies mirror the repositories'
// New* inputs; update bodies are partial (every field optional) — the handler
// merges the patch over the existing row, so an omitted field is left unchanged
// and an explicit null clears a nullable field. Timestamps are ISO-8601 strings
// on the wire and converted to Date at the handler boundary.

import { z } from 'zod';
import { TRIP_STATUSES } from '../mobility/trip.repository';
import { USER_ROLES } from '../users/user.repository';

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

// List filters for GET /admin/trips — `date` is the UTC calendar day, the shape
// the E3 ask-dispatch needs ("tomorrow's scheduled trips").
export const listTripsAdminQuerySchema = z.object({
  routeId: z.string().uuid().optional(),
  status: z.enum(TRIP_STATUSES).optional(),
  date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'expected YYYY-MM-DD')
    .optional(),
});

// --- users (role grant) ---
// Changing users.role is what turns a signed-in account into a driver/admin —
// the JWT carries the role, so it takes effect on the next refresh/sign-in.
export const setRoleBodySchema = z.object({
  role: z.enum(USER_ROLES),
});
// Slim admin view of a user (no avatar URL — that needs the object store and
// belongs to the profile endpoints).
export const adminUserResponseSchema = z.object({
  id: z.string().uuid(),
  displayName: z.string(),
  phone: z.string().nullable(),
  role: z.enum(USER_ROLES),
  createdAt: z.date(),
});

// Driver↔trip (and vehicle) assignment — the field that authorizes GPS
// reporting (#25). Both optional so a call can assign either or both; an
// explicit null unassigns.
export const assignTripBodySchema = z.object({
  vehicleId: z.string().uuid().nullable().optional(),
  assignedDriverId: z.string().uuid().nullable().optional(),
});

// --- feature flags (#27) ---
// The flag key is the path param; the body carries the editable fields. Every
// field is optional so PUT /admin/flags/:key both creates (defaults applied) and
// updates (patch merged over the existing row). See flags/feature-flag.repository.
export const upsertFeatureFlagBodySchema = z.object({
  enabled: z.boolean().optional(),
  rolloutPercentage: z.number().int().min(0).max(100).optional(),
  description: z.string().nullable().optional(),
});

// Set the minimum supported app version for a platform (the force-update floor).
export const setMinVersionBodySchema = z.object({
  version: z.string().min(1),
});
