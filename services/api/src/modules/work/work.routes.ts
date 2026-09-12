// Driver work routes and requests (#232).
//
//   GET  /me/work/routes                 corridors open to reassignment requests
//   POST /me/work/requests               ask for a route change or leave
//   GET  /me/work/requests               my requests and their outcomes
//   POST /me/work/requests/:id/withdraw  take one back
//   GET  /admin/driver-requests          the operations queue
//   PATCH /admin/driver-requests/:id     approve or decline one
//
// Approving writes a decision and nothing else. No handler here touches
// `trips.assigned_driver_id`, which is the design's rule made structural rather
// than remembered: moving a driver stays a deliberate act at
// PUT /admin/trips/:id/assignment, where the capacity check lives.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { DriverRequestRepository } from './driver-request.repository';
import type { WorkRequestRefusal, WorkRequestService } from './work-request.service';
import {
  adminRequestResponseSchema,
  availableRouteSchema,
  decideRequestBodySchema,
  listRequestsQuerySchema,
  requestResponseSchema,
  submitRequestBodySchema,
} from './work.schema';

/**
 * Map a refusal to its status code.
 *
 * @param reason - why the service refused.
 * @returns the HTTP status and body.
 */
function refusal(reason: WorkRequestRefusal): {
  code: 403 | 404 | 409;
  body: { error: string; message: string };
} {
  switch (reason) {
    case 'route_not_found':
      return { code: 404, body: { error: 'not_found', message: 'Route not found' } };
    case 'route_closed':
      return {
        code: 409,
        body: {
          error: 'route_closed',
          message: 'Operations is not accepting reassignment requests for this route',
        },
      };
    case 'not_a_driver':
      return {
        code: 403,
        body: { error: 'forbidden', message: 'This account is not linked to a driver record' },
      };
  }
}

/**
 * Register the driver work routes.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.workRequests - submits and lists a driver's requests (503 when absent).
 * @param opts.requests - the store, for the ops queue (503 when absent).
 * @param opts.rateLimit - rate-limit config (applied per user).
 */
export async function workRoutes(
  app: FastifyInstance,
  opts: {
    workRequests?: WorkRequestService;
    requests?: DriverRequestRepository;
    rateLimit: RateLimitConfig;
  },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();
  const UNAVAILABLE = { error: 'unavailable', message: 'Driver requests are not configured' };
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
  const idParam = z.object({ id: z.string().uuid() });

  r.get(
    '/me/work/routes',
    {
      schema: {
        tags: ['work'],
        summary: 'Routes operations will accept reassignment requests for',
        description:
          'Not every corridor. A route appears only once operations opens it, so a driver ' +
          'never asks for something that could only ever be declined.',
        security: [{ bearerAuth: [] }],
        response: {
          200: z.object({ routes: z.array(availableRouteSchema) }),
          401: errorResponseSchema,
          403: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: driverOnly,
    },
    async (_request, reply) => {
      if (!opts.workRequests) return reply.code(503).send(UNAVAILABLE);
      return { routes: await opts.workRequests.availableRoutes() };
    },
  );

  r.post(
    '/me/work/requests',
    {
      schema: {
        tags: ['work'],
        summary: 'Ask operations for a route change or leave',
        description:
          'A proposal, not an edit. Nothing about the driver’s published assignment ' +
          'changes when this succeeds, or when it is later approved.',
        security: [{ bearerAuth: [] }],
        body: submitRequestBodySchema,
        response: {
          201: requestResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
          409: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: driverOnly,
    },
    async (request, reply) => {
      if (!opts.workRequests) return reply.code(503).send(UNAVAILABLE);
      const result = await opts.workRequests.submit({
        ...request.body,
        userId: request.user!.id,
      });
      if (!result.ok) {
        const { code, body } = refusal(result.reason);
        return reply.code(code).send(body);
      }
      return reply.code(201).send(result.request);
    },
  );

  r.get(
    '/me/work/requests',
    {
      schema: {
        tags: ['work'],
        summary: 'My requests and what operations decided',
        security: [{ bearerAuth: [] }],
        response: {
          200: z.object({ requests: z.array(requestResponseSchema) }),
          401: errorResponseSchema,
          403: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: driverOnly,
    },
    async (request, reply) => {
      if (!opts.workRequests) return reply.code(503).send(UNAVAILABLE);
      return { requests: await opts.workRequests.listMine(request.user!.id) };
    },
  );

  r.post(
    '/me/work/requests/:id/withdraw',
    {
      schema: {
        tags: ['work'],
        summary: 'Take back a request operations has not answered yet',
        security: [{ bearerAuth: [] }],
        params: idParam,
        response: {
          200: requestResponseSchema,
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
      if (!opts.workRequests) return reply.code(503).send(UNAVAILABLE);
      const withdrawn = await opts.workRequests.withdraw(request.params.id, request.user!.id);
      // One 404 for "no such request", "not yours" and "already decided". The
      // first two must not be distinguishable — otherwise the endpoint tells a
      // driver whether another driver's request id exists.
      if (!withdrawn) {
        return reply.code(404).send({
          error: 'not_found',
          message: 'No pending request of yours with that id',
        });
      }
      return withdrawn;
    },
  );

  r.get(
    '/admin/driver-requests',
    {
      schema: {
        tags: ['admin'],
        summary: 'Driver route-change and leave requests, newest first',
        security: [{ bearerAuth: [] }],
        querystring: listRequestsQuerySchema,
        response: {
          200: z.object({ requests: z.array(adminRequestResponseSchema) }),
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.requests) return reply.code(503).send(UNAVAILABLE);
      return { requests: await opts.requests.list({ status: request.query.status }) };
    },
  );

  r.patch(
    '/admin/driver-requests/:id',
    {
      schema: {
        tags: ['admin'],
        summary: 'Approve or decline a driver request',
        description:
          'Records the decision only. Approving a route change does not reassign the ' +
          'driver — do that at PUT /admin/trips/:id/assignment, which checks capacity.',
        security: [{ bearerAuth: [] }],
        params: idParam,
        body: decideRequestBodySchema,
        response: {
          200: adminRequestResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.requests) return reply.code(503).send(UNAVAILABLE);
      const updated = await opts.requests.decide(request.params.id, {
        status: request.body.status,
        decidedBy: request.user!.id,
        decisionNote: request.body.decisionNote,
      });
      // Also the answer when someone else decided it first — the store only
      // updates a `pending` row, so a second admin gets this rather than
      // overwriting the first decision.
      if (!updated) {
        return reply
          .code(404)
          .send({ error: 'not_found', message: 'No pending request with that id' });
      }
      return updated;
    },
  );
}
