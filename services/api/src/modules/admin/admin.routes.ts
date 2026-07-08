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
import type { UserRepository } from '../users/user.repository';
import type { FeatureFlagRepository } from '../flags/feature-flag.repository';
import { APP_PLATFORMS, type MinVersionRepository } from '../flags/min-version.repository';
import {
  driverResponseSchema,
  routeResponseSchema,
  stopResponseSchema,
  tripResponseSchema,
  vehicleResponseSchema,
} from '../mobility/mobility.schema';
import { featureFlagResponseSchema, minVersionResponseSchema } from '../flags/flags.schema';
import {
  adminUserResponseSchema,
  assignTripBodySchema,
  attachStopBodySchema,
  createDriverBodySchema,
  createRouteBodySchema,
  createStopBodySchema,
  createTripBodySchema,
  createVehicleBodySchema,
  listTripsAdminQuerySchema,
  setMinVersionBodySchema,
  setRoleBodySchema,
  updateDriverBodySchema,
  updateRouteBodySchema,
  updateStopBodySchema,
  updateTripBodySchema,
  updateVehicleBodySchema,
  upsertFeatureFlagBodySchema,
} from './admin.schema';

// True when a repository error is a (Postgres-shaped) unique-constraint
// violation — SQLSTATE 23505. The in-memory route-stop adapter throws the same
// shape, so both paths map to a clean 409.
function isUniqueViolation(err: unknown): boolean {
  return (err as { code?: string }).code === '23505';
}

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
  /** For the role grant (PATCH /admin/users/:id/role) + driver user_id checks. */
  users?: UserRepository;
  /** Feature flags + force-update floor (#27), managed under /admin/flags + /admin/min-versions. */
  featureFlags?: FeatureFlagRepository;
  minVersions?: MinVersionRepository;
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

  // authenticate → rate limit → requireRole('admin'). Throttle BEFORE the role
  // check (house convention, cf. boarding #93) — otherwise non-admin tokens
  // could hammer 403s without ever being rate limited. Reused by every route.
  const adminOnly = [
    app.authenticate,
    app.rateLimit({ ...opts.rateLimit, by: 'user' }),
    app.requireRole('admin'),
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
        response: { 200: routeStopResponseSchema, 409: errorResponseSchema, ...authErrorsNF },
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
      try {
        return await opts.routeStops.create({
          routeId: request.params.id,
          stopId: request.body.stopId,
          seq: request.body.seq,
        });
      } catch (err) {
        // UNIQUE (route_id, seq) — the position is already taken on this route.
        if (isUniqueViolation(err)) {
          return reply.code(409).send({
            error: 'conflict',
            message: `Sequence position ${request.body.seq} is already taken on this route`,
          });
        }
        throw err;
      }
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
        response: { 200: driverResponseSchema, ...authErrorsNF },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.drivers) return reply.code(503).send(UNAVAILABLE);
      // Validate the linked auth principal exists — clean 404 instead of a DB
      // FK violation (consistent with trip create). users is only needed when a
      // link is actually being made.
      if (request.body.userId) {
        if (!opts.users) return reply.code(503).send(UNAVAILABLE);
        if (!(await opts.users.findById(request.body.userId))) {
          return reply.code(404).send(notFound('User not found'));
        }
      }
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
      if (request.body.userId) {
        if (!opts.users) return reply.code(503).send(UNAVAILABLE);
        if (!(await opts.users.findById(request.body.userId))) {
          return reply.code(404).send(notFound('User not found'));
        }
      }
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
        summary: 'List trips, filterable by route, status, and UTC day',
        security: [{ bearerAuth: [] }],
        querystring: listTripsAdminQuerySchema,
        response: { 200: z.array(tripResponseSchema), ...authErrors },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.trips) return reply.code(503).send(UNAVAILABLE);
      return opts.trips.findAll({
        routeId: request.query.routeId,
        status: request.query.status,
        date: request.query.date,
      });
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

  // ----------------------------------------------------------- users (role) ---
  // The missing half of "make a user a driver": creating a `drivers` fleet row
  // never touches users.role, but the JWT is signed from users.role at sign-in —
  // so without this, a linked driver still authenticates as a commuter and gets
  // 403 on POST /boarding/scan. The change takes effect on the user's next token
  // refresh/sign-in (existing access tokens keep their old role until expiry,
  // ≤15m). Bootstrap note: the FIRST admin cannot be created through this
  // endpoint (it requires an admin) — grant it once via SQL:
  //   UPDATE users SET role = 'admin' WHERE id = '<uuid>';
  r.patch(
    '/admin/users/:id/role',
    {
      schema: {
        tags: ['admin'],
        summary: "Change a user's role (commuter | driver | admin)",
        security: [{ bearerAuth: [] }],
        params: idParam,
        body: setRoleBodySchema,
        response: { 200: adminUserResponseSchema, ...authErrorsNF },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.users) return reply.code(503).send(UNAVAILABLE);
      const updated = await opts.users.setRole(request.params.id, request.body.role);
      if (!updated) return reply.code(404).send(notFound('User not found'));
      return updated;
    },
  );

  // --------------------------------------------------------- feature flags ---
  // The apps read these (kill-switch + %-rollout) on launch via public GET /flags;
  // ops flip them here without a deploy — the "deploy != release" keystone (#27).
  r.get(
    '/admin/flags',
    {
      schema: {
        tags: ['admin'],
        summary: 'List all feature flags',
        security: [{ bearerAuth: [] }],
        response: { 200: z.array(featureFlagResponseSchema), ...authErrors },
      },
      preHandler: adminOnly,
    },
    async (_request, reply) => {
      if (!opts.featureFlags) return reply.code(503).send(UNAVAILABLE);
      return opts.featureFlags.findAll();
    },
  );

  // Upsert (create or update) a flag by key. Idempotent — the kill-switch: PUT
  // { enabled: false } instantly hides a feature on the apps' next fetch.
  r.put(
    '/admin/flags/:key',
    {
      schema: {
        tags: ['admin'],
        summary: 'Create or update a feature flag',
        security: [{ bearerAuth: [] }],
        params: z.object({ key: z.string().min(1) }),
        body: upsertFeatureFlagBodySchema,
        response: { 200: featureFlagResponseSchema, ...authErrors },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.featureFlags) return reply.code(503).send(UNAVAILABLE);
      return opts.featureFlags.upsert(request.params.key, request.body);
    },
  );

  // ------------------------------------------------------- min app versions ---
  // The force-update floor per platform: bumping it forces older builds to update
  // on their next launch (they read it via public GET /flags).
  r.get(
    '/admin/min-versions',
    {
      schema: {
        tags: ['admin'],
        summary: 'List the minimum supported app version per platform',
        security: [{ bearerAuth: [] }],
        response: { 200: z.array(minVersionResponseSchema), ...authErrors },
      },
      preHandler: adminOnly,
    },
    async (_request, reply) => {
      if (!opts.minVersions) return reply.code(503).send(UNAVAILABLE);
      return opts.minVersions.findAll();
    },
  );

  r.put(
    '/admin/min-versions/:platform',
    {
      schema: {
        tags: ['admin'],
        summary: 'Set the minimum supported app version for a platform',
        security: [{ bearerAuth: [] }],
        params: z.object({ platform: z.enum(APP_PLATFORMS) }),
        body: setMinVersionBodySchema,
        response: { 200: minVersionResponseSchema, ...authErrors },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.minVersions) return reply.code(503).send(UNAVAILABLE);
      return opts.minVersions.set(request.params.platform, request.body.version);
    },
  );
}
