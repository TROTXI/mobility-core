// Mobility route handlers. Browse endpoints are intentionally public (no auth)
// so the mobile app can display routes before a user signs in — this mirrors
// how transit apps work (you browse routes, then authenticate to board/pay).
// GET /routes/:id resolves stops in a single async fan-out rather than a JOIN
// so the domain model stays decoupled from the DB schema.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RouteStopRepository } from './route-stop.repository';
import type { RouteGeometryRepository } from './route-geometry.repository';
import type { RouteRepository } from './route.repository';
import {
  routeGeometryResponseSchema,
  routeResponseSchema,
  routeWithStopsResponseSchema,
} from './mobility.schema';
import type { StopRepository } from './stop.repository';

/**
 * Register the public mobility browse routes: `GET /routes`, `GET /routes/:id`.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.routes - the route repository.
 * @param opts.stops - the stop repository.
 * @param opts.routeStops - the route-stop join repository.
 * @param opts.routeGeometry - derived route shapes (#179); absent -> stop fallback.
 */
export async function mobilityRoutes(
  app: FastifyInstance,
  opts: {
    routes?: RouteRepository;
    stops?: StopRepository;
    routeStops?: RouteStopRepository;
    /** Derived route shapes (#179). Absent -> the stop fallback is always used. */
    routeGeometry?: RouteGeometryRepository;
  },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();

  r.get(
    '/routes',
    {
      schema: {
        tags: ['mobility'],
        summary: 'List all routes',
        response: {
          200: z.array(routeResponseSchema),
        },
      },
    },
    async () => {
      return opts.routes ? await opts.routes.findAll() : [];
    },
  );

  r.get(
    '/routes/:id',
    {
      schema: {
        tags: ['mobility'],
        summary: 'Get a route with its stops in order',
        params: z.object({ id: z.string().uuid() }),
        response: {
          200: routeWithStopsResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      if (!opts.routes || !opts.stops || !opts.routeStops) {
        return reply.code(404).send({ error: 'not_found', message: 'Route not found' });
      }

      const route = await opts.routes.findById(request.params.id);
      if (!route) {
        return reply.code(404).send({ error: 'not_found', message: 'Route not found' });
      }

      // Resolve stops in parallel — route_stops gives the ordered IDs, then we
      // fetch each stop. Order is guaranteed by findByRoute (sorted by seq).
      const routeStops = await opts.routeStops.findByRoute(route.id);
      const stops = await Promise.all(
        routeStops.map(async (rs) => {
          const stop = await opts.stops!.findById(rs.stopId);
          return { ...stop!, seq: rs.seq };
        }),
      );

      return { ...route, stops };
    },
  );

  r.get(
    '/routes/:id/geometry',
    {
      schema: {
        tags: ['mobility'],
        summary: 'The path a route follows, for drawing it on a map',
        description:
          'Returns the road-following path learned from completed runs (#179) when we ' +
          'have one, and a straight line through the stops when we do not. `source` ' +
          'tells you which you got, so a client can render the fallback differently ' +
          'rather than pretending it follows the road.',
        params: z.object({ id: z.string().uuid() }),
        response: {
          200: routeGeometryResponseSchema,
          404: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      if (!opts.routes || !opts.routeStops || !opts.stops) {
        return reply
          .code(503)
          .send({ error: 'unavailable', message: 'Mobility is not configured' });
      }
      const route = await opts.routes.findById(request.params.id);
      if (!route) {
        return reply.code(404).send({ error: 'not_found', message: 'Route not found' });
      }

      const learned = opts.routeGeometry ? await opts.routeGeometry.findByRoute(route.id) : null;
      if (learned && learned.points.length > 0) {
        return {
          routeId: route.id,
          points: learned.points.map((p) => ({ latitude: p.latitude, longitude: p.longitude })),
          source: learned.source as 'traces' | 'matched' | 'manual',
          runCount: learned.runCount,
        };
      }

      // Cold start: a corridor we have never completed a run on still has to
      // draw something, so fall back to the stops in order.
      const routeStops = await opts.routeStops.findByRoute(route.id);
      const points = (await Promise.all(routeStops.map((rs) => opts.stops!.findById(rs.stopId))))
        .filter((s) => s !== null)
        .map((s) => ({ latitude: s.latitude, longitude: s.longitude }));

      return { routeId: route.id, points, source: 'stops' as const, runCount: 0 };
    },
  );
}
