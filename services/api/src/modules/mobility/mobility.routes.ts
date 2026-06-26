import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RouteStopRepository } from './route-stop.repository';
import type { RouteRepository } from './route.repository';
import { routeResponseSchema, routeWithStopsResponseSchema } from './mobility.schema';
import type { StopRepository } from './stop.repository';

export async function mobilityRoutes(
  app: FastifyInstance,
  opts: {
    routes?: RouteRepository;
    stops?: StopRepository;
    routeStops?: RouteStopRepository;
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
}
