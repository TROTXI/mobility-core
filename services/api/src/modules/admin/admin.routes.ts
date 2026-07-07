// Admin/ops endpoints (#26). Operations manages the mobility fleet here rather
// than via seed scripts: CRUD for routes/stops/vehicles/drivers/trips plus the
// driver↔trip assignment that authorizes GPS reporting (#25). Every route is
// gated by `requireRole('admin')` (401 unauth → 403 non-admin). Handlers call
// repositories directly (no service layer yet) and 503 when a repo is unwired,
// matching the rest of the API. Update bodies are partial; the repository merges
// the patch over the existing row (see admin.schema.ts).

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { DriverRepository } from '../mobility/driver.repository';
import type { RouteStopRepository } from '../mobility/route-stop.repository';
import type { RouteRepository } from '../mobility/route.repository';
import type { StopRepository } from '../mobility/stop.repository';
import type { TripRepository } from '../mobility/trip.repository';
import type { VehicleRepository } from '../mobility/vehicle.repository';
import {
  driverResponseSchema,
  routeResponseSchema,
  stopResponseSchema,
  tripResponseSchema,
  vehicleResponseSchema,
} from '../mobility/mobility.schema';
import {
  assignTripBodySchema,
  attachStopBodySchema,
  createDriverBodySchema,
  createRouteBodySchema,
  createStopBodySchema,
  createTripBodySchema,
  createVehicleBodySchema,
  updateDriverBodySchema,
  updateRouteBodySchema,
  updateStopBodySchema,
  updateTripBodySchema,
  updateVehicleBodySchema,
} from './admin.schema';

const idParam = z.object({ id: z.string().uuid() });

const routeStopResponseSchema = z.object({
  id: z.string().uuid(),
  routeId: z.string().uuid(),
  stopId: z.string().uuid(),
  seq: z.number().int(),
  createdAt: z.date(),
});

// Shared error-response maps. Spread into a route's `response` — this only
// affects the (error) response shapes, never request body/param inference.
const authErrors = {
  401: errorResponseSchema,
  403: errorResponseSchema,
  503: errorResponseSchema,
};
const authErrorsNF = { ...authErrors, 404: errorResponseSchema };

/** Dependencies for the admin router — the full mobility repository set. */
export interface AdminDeps {
  routes?: RouteRepository;
  stops?: StopRepository;
  routeStops?: RouteStopRepository;
  vehicles?: VehicleRepository;
  drivers?: DriverRepository;
  trips?: TripRepository;
  rateLimit: RateLimitConfig;
}

/**
 * Register the admin/ops endpoints under `/admin/*`, all admin-role guarded.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - the mobility repositories and rate-limit config.
 */
export async function adminRoutes(app: FastifyInstance, opts: AdminDeps): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();
  const UNAVAILABLE = { error: 'unavailable', message: 'Admin ops are not configured' };
  const notFound = (message: string) => ({ error: 'not_found', message });

  // authenticate → requireRole('admin') → rate limit. Reused by every route.
  const adminOnly = [
    app.authenticate,
    app.requireRole('admin'),
    app.rateLimit({ ...opts.rateLimit, by: 'user' }),
  ];

  // ---------------------------------------------------------------- routes ---
  r.post(
    '/admin/routes',
    {
      schema: {
        tags: ['admin'],
        summary: 'Create a route',
        security: [{ bearerAuth: [] }],
        body: createRouteBodySchema,
        response: { 200: routeResponseSchema, ...authErrors },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.routes) return reply.code(503).send(UNAVAILABLE);
      return opts.routes.create(request.body);
    },
  );

  r.get(
    '/admin/routes',
    {
      schema: {
        tags: ['admin'],
        summary: 'List all routes',
        security: [{ bearerAuth: [] }],
        response: { 200: z.array(routeResponseSchema), ...authErrors },
      },
      preHandler: adminOnly,
    },
    async (_request, reply) => {
      if (!opts.routes) return reply.code(503).send(UNAVAILABLE);
      return opts.routes.findAll();
    },
  );

  r.patch(
    '/admin/routes/:id',
    {
      schema: {
        tags: ['admin'],
        summary: 'Update a route',
        security: [{ bearerAuth: [] }],
        params: idParam,
        body: updateRouteBodySchema,
        response: { 200: routeResponseSchema, ...authErrorsNF },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.routes) return reply.code(503).send(UNAVAILABLE);
      const updated = await opts.routes.update(request.params.id, request.body);
      if (!updated) return reply.code(404).send(notFound('Route not found'));
      return updated;
    },
  );

  // Attach an existing stop to a route at a sequence position (route_stops).
  r.post(
    '/admin/routes/:id/stops',
    {
      schema: {
        tags: ['admin'],
        summary: 'Attach a stop to a route at a sequence position',
        security: [{ bearerAuth: [] }],
        params: idParam,
        body: attachStopBodySchema,
        response: { 200: routeStopResponseSchema, ...authErrorsNF },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.routes || !opts.stops || !opts.routeStops) {
        return reply.code(503).send(UNAVAILABLE);
      }
      if (!(await opts.routes.findById(request.params.id))) {
        return reply.code(404).send(notFound('Route not found'));
      }
      if (!(await opts.stops.findById(request.body.stopId))) {
        return reply.code(404).send(notFound('Stop not found'));
      }
      return opts.routeStops.create({
        routeId: request.params.id,
        stopId: request.body.stopId,
        seq: request.body.seq,
      });
    },
  );

  // ----------------------------------------------------------------- stops ---
  r.post(
    '/admin/stops',
    {
      schema: {
        tags: ['admin'],
        summary: 'Create a stop',
        security: [{ bearerAuth: [] }],
        body: createStopBodySchema,
        response: { 200: stopResponseSchema, ...authErrors },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.stops) return reply.code(503).send(UNAVAILABLE);
      return opts.stops.create(request.body);
    },
  );

  r.get(
    '/admin/stops',
    {
      schema: {
        tags: ['admin'],
        summary: 'List all stops',
        security: [{ bearerAuth: [] }],
        response: { 200: z.array(stopResponseSchema), ...authErrors },
      },
      preHandler: adminOnly,
    },
    async (_request, reply) => {
      if (!opts.stops) return reply.code(503).send(UNAVAILABLE);
      return opts.stops.findAll();
    },
  );

  r.patch(
    '/admin/stops/:id',
    {
      schema: {
        tags: ['admin'],
        summary: 'Update a stop',
        security: [{ bearerAuth: [] }],
        params: idParam,
        body: updateStopBodySchema,
        response: { 200: stopResponseSchema, ...authErrorsNF },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.stops) return reply.code(503).send(UNAVAILABLE);
      const updated = await opts.stops.update(request.params.id, request.body);
      if (!updated) return reply.code(404).send(notFound('Stop not found'));
      return updated;
    },
  );

  // -------------------------------------------------------------- vehicles ---
  r.post(
    '/admin/vehicles',
    {
      schema: {
        tags: ['admin'],
        summary: 'Create a vehicle',
        security: [{ bearerAuth: [] }],
        body: createVehicleBodySchema,
        response: { 200: vehicleResponseSchema, ...authErrors },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.vehicles) return reply.code(503).send(UNAVAILABLE);
      return opts.vehicles.create(request.body);
    },
  );

  r.get(
    '/admin/vehicles',
    {
      schema: {
        tags: ['admin'],
        summary: 'List all vehicles',
        security: [{ bearerAuth: [] }],
        response: { 200: z.array(vehicleResponseSchema), ...authErrors },
      },
      preHandler: adminOnly,
    },
    async (_request, reply) => {
      if (!opts.vehicles) return reply.code(503).send(UNAVAILABLE);
      return opts.vehicles.findAll();
    },
  );

  r.patch(
    '/admin/vehicles/:id',
    {
      schema: {
        tags: ['admin'],
        summary: 'Update a vehicle',
        security: [{ bearerAuth: [] }],
        params: idParam,
        body: updateVehicleBodySchema,
        response: { 200: vehicleResponseSchema, ...authErrorsNF },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.vehicles) return reply.code(503).send(UNAVAILABLE);
      const updated = await opts.vehicles.update(request.params.id, request.body);
      if (!updated) return reply.code(404).send(notFound('Vehicle not found'));
      return updated;
    },
  );

  // --------------------------------------------------------------- drivers ---
  r.post(
    '/admin/drivers',
    {
      schema: {
        tags: ['admin'],
        summary: 'Create a driver',
        security: [{ bearerAuth: [] }],
        body: createDriverBodySchema,
        response: { 200: driverResponseSchema, ...authErrors },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.drivers) return reply.code(503).send(UNAVAILABLE);
      return opts.drivers.create(request.body);
    },
  );

  r.get(
    '/admin/drivers',
    {
      schema: {
        tags: ['admin'],
        summary: 'List all drivers',
        security: [{ bearerAuth: [] }],
        response: { 200: z.array(driverResponseSchema), ...authErrors },
      },
      preHandler: adminOnly,
    },
    async (_request, reply) => {
      if (!opts.drivers) return reply.code(503).send(UNAVAILABLE);
      return opts.drivers.findAll();
    },
  );

  r.patch(
    '/admin/drivers/:id',
    {
      schema: {
        tags: ['admin'],
        summary: 'Update a driver',
        security: [{ bearerAuth: [] }],
        params: idParam,
        body: updateDriverBodySchema,
        response: { 200: driverResponseSchema, ...authErrorsNF },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.drivers) return reply.code(503).send(UNAVAILABLE);
      const updated = await opts.drivers.update(request.params.id, request.body);
      if (!updated) return reply.code(404).send(notFound('Driver not found'));
      return updated;
    },
  );

  // ----------------------------------------------------------------- trips ---
  r.post(
    '/admin/trips',
    {
      schema: {
        tags: ['admin'],
        summary: 'Create a trip',
        security: [{ bearerAuth: [] }],
        body: createTripBodySchema,
        response: { 200: tripResponseSchema, ...authErrorsNF },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.trips || !opts.routes || !opts.vehicles || !opts.drivers) {
        return reply.code(503).send(UNAVAILABLE);
      }
      const { routeId, vehicleId, assignedDriverId, status, scheduledAt } = request.body;
      // Validate FK targets up front so the client gets a clean 404 rather than
      // a DB constraint error (and so it works in the in-memory adapter too).
      if (!(await opts.routes.findById(routeId))) {
        return reply.code(404).send(notFound('Route not found'));
      }
      if (vehicleId && !(await opts.vehicles.findById(vehicleId))) {
        return reply.code(404).send(notFound('Vehicle not found'));
      }
      if (assignedDriverId && !(await opts.drivers.findById(assignedDriverId))) {
        return reply.code(404).send(notFound('Driver not found'));
      }
      return opts.trips.create({
        routeId,
        vehicleId: vehicleId ?? null,
        assignedDriverId: assignedDriverId ?? null,
        status,
        scheduledAt: new Date(scheduledAt),
      });
    },
  );

  r.get(
    '/admin/trips',
    {
      schema: {
        tags: ['admin'],
        summary: 'List all trips',
        security: [{ bearerAuth: [] }],
        response: { 200: z.array(tripResponseSchema), ...authErrors },
      },
      preHandler: adminOnly,
    },
    async (_request, reply) => {
      if (!opts.trips) return reply.code(503).send(UNAVAILABLE);
      return opts.trips.findAll();
    },
  );

  r.patch(
    '/admin/trips/:id',
    {
      schema: {
        tags: ['admin'],
        summary: 'Update a trip (status / schedule)',
        security: [{ bearerAuth: [] }],
        params: idParam,
        body: updateTripBodySchema,
        response: { 200: tripResponseSchema, ...authErrorsNF },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.trips) return reply.code(503).send(UNAVAILABLE);
      const updated = await opts.trips.update(request.params.id, {
        status: request.body.status,
        scheduledAt: request.body.scheduledAt ? new Date(request.body.scheduledAt) : undefined,
      });
      if (!updated) return reply.code(404).send(notFound('Trip not found'));
      return updated;
    },
  );

  // Driver↔trip (and vehicle) assignment — the field that authorizes GPS
  // reporting (#25). Validates the targets exist; explicit null unassigns.
  r.put(
    '/admin/trips/:id/assignment',
    {
      schema: {
        tags: ['admin'],
        summary: 'Assign a vehicle and/or driver to a trip',
        security: [{ bearerAuth: [] }],
        params: idParam,
        body: assignTripBodySchema,
        response: { 200: tripResponseSchema, ...authErrorsNF },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.trips || !opts.vehicles || !opts.drivers) {
        return reply.code(503).send(UNAVAILABLE);
      }
      const { vehicleId, assignedDriverId } = request.body;
      if (vehicleId && !(await opts.vehicles.findById(vehicleId))) {
        return reply.code(404).send(notFound('Vehicle not found'));
      }
      if (assignedDriverId && !(await opts.drivers.findById(assignedDriverId))) {
        return reply.code(404).send(notFound('Driver not found'));
      }
      const updated = await opts.trips.update(request.params.id, { vehicleId, assignedDriverId });
      if (!updated) return reply.code(404).send(notFound('Trip not found'));
      return updated;
    },
  );
}
