// Incident routes (#226).
//
//   POST /me/incidents            file a report (driver)
//   GET  /me/incidents            my reports and where they got to (driver)
//   GET  /admin/incidents         the operations queue
//   PATCH /admin/incidents/:id    acknowledge or resolve one
//
// There is no emergency endpoint here, and that is the design's rule rather than
// an omission: EMERGENCY HELP dials the operations number from GET /flags (#234).
// A crash must not queue behind a broken wiper.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { DriverIncidentRepository } from './driver-incident.repository';
import type { IncidentRefusal, IncidentService } from './incident.service';
import {
  adminIncidentResponseSchema,
  decideIncidentBodySchema,
  fileIncidentBodySchema,
  incidentResponseSchema,
  listIncidentsQuerySchema,
} from './incidents.schema';

/**
 * Map a refusal to its status code.
 *
 * @param reason - why the service refused.
 * @returns the HTTP status and body.
 */
function refusal(reason: IncidentRefusal): {
  code: 403 | 404;
  body: { error: string; message: string };
} {
  switch (reason) {
    case 'trip_not_found':
      return { code: 404, body: { error: 'not_found', message: 'Trip not found' } };
    case 'not_assigned_driver':
      return {
        code: 403,
        body: { error: 'forbidden', message: 'Not the assigned driver for this trip' },
      };
    case 'not_a_driver':
      return {
        code: 403,
        body: { error: 'forbidden', message: 'This account is not linked to a driver record' },
      };
  }
}

/**
 * Register the incident routes.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.incidentService - files and lists a driver's reports (503 when absent).
 * @param opts.incidents - the store, for the ops queue (503 when absent).
 * @param opts.rateLimit - rate-limit config (applied per user).
 */
export async function incidentRoutes(
  app: FastifyInstance,
  opts: {
    incidentService?: IncidentService;
    incidents?: DriverIncidentRepository;
    rateLimit: RateLimitConfig;
  },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();
  const UNAVAILABLE = { error: 'unavailable', message: 'Incident reporting is not configured' };
  const driverOnly = [
    app.authenticate,
    app.rateLimit({ ...opts.rateLimit, by: 'user' }),
    app.requireRole('driver'),
  ];
  const adminOnly = [
    app.authenticate,
    app.rateLimit({ ...opts.rateLimit, by: 'user' }),
    app.requireRole('admin'),
  ];

  r.post(
    '/me/incidents',
    {
      schema: {
        tags: ['incidents'],
        summary: 'File an incident report (driver)',
        description:
          'The server attaches the vehicle from the named trip rather than trusting the ' +
          'app to send it. A report with no trip is accepted — a fault found in the yard ' +
          'is exactly the one worth filing.',
        security: [{ bearerAuth: [] }],
        body: fileIncidentBodySchema,
        response: {
          201: incidentResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: driverOnly,
    },
    async (request, reply) => {
      if (!opts.incidentService) return reply.code(503).send(UNAVAILABLE);
      const result = await opts.incidentService.file({
        userId: request.user!.id,
        tripId: request.body.tripId,
        category: request.body.category,
        note: request.body.note,
        lat: request.body.lat,
        lng: request.body.lng,
      });
      if (!result.ok) {
        const { code, body } = refusal(result.reason);
        return reply.code(code).send(body);
      }
      return reply.code(201).send(result.incident);
    },
  );

  r.get(
    '/me/incidents',
    {
      schema: {
        tags: ['incidents'],
        summary: 'My incident reports and what operations did with them (driver)',
        security: [{ bearerAuth: [] }],
        response: {
          200: z.object({ incidents: z.array(incidentResponseSchema) }),
          401: errorResponseSchema,
          403: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: driverOnly,
    },
    async (request, reply) => {
      if (!opts.incidentService) return reply.code(503).send(UNAVAILABLE);
      return { incidents: await opts.incidentService.listMine(request.user!.id) };
    },
  );

  // The operations queue. A table is the floor, not the goal: #226 asks whether
  // operations should be pushed at live, and the ops console (#170) is where
  // that lands. Until then this is what someone refreshes.
  r.get(
    '/admin/incidents',
    {
      schema: {
        tags: ['admin'],
        summary: 'Driver incident reports, newest first',
        security: [{ bearerAuth: [] }],
        querystring: listIncidentsQuerySchema,
        response: {
          200: z.object({ incidents: z.array(adminIncidentResponseSchema) }),
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.incidents) return reply.code(503).send(UNAVAILABLE);
      return { incidents: await opts.incidents.list({ status: request.query.status }) };
    },
  );

  r.patch(
    '/admin/incidents/:id',
    {
      schema: {
        tags: ['admin'],
        summary: 'Acknowledge or resolve a driver incident report',
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        body: decideIncidentBodySchema,
        response: {
          200: adminIncidentResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.incidents) return reply.code(503).send(UNAVAILABLE);
      const updated = await opts.incidents.decide(request.params.id, {
        status: request.body.status,
        handledBy: request.user!.id,
        resolution: request.body.resolution,
      });
      if (!updated) {
        return reply.code(404).send({ error: 'not_found', message: 'Incident not found' });
      }
      return updated;
    },
  );
}
