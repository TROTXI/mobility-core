// Driver-owned trip lifecycle routes (#163).
//
//   GET  /me/trips              the runs assigned to me — a day, or a range
//   POST /trips/:id/start       begin the run
//   POST /trips/:id/arrive      report reaching a stop
//   POST /trips/:id/complete    end it
//   GET  /trips/:id/summary     what the run did
//
// All four are assigned-driver only: holding the `driver` role is not enough,
// the caller must be linked to the driver THIS trip is assigned to. Same rule
// as position reporting and the manifest.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import { arriveBodySchema, myTripsQuerySchema, tripResponseSchema } from './mobility.schema';
import type {
  AccessRefusal,
  ArrivalRefusal,
  LifecycleRefusal,
  TripLifecycleService,
} from './trip-lifecycle.service';

const runSummarySchema = z.object({
  tripId: z.string().uuid(),
  boarded: z.number().int(),
  notBoarded: z.number().int(),
  byMethod: z.object({
    qr: z.number().int(),
    pin: z.number().int(),
    photo: z.number().int(),
  }),
  startedAt: z.date().nullable(),
  completedAt: z.date().nullable(),
  stopCount: z.number().int(),
});

/**
 * Map a refusal to its status code.
 *
 * `not_assigned_driver` is 403 rather than 404: the caller is authenticated and
 * the trip exists, they simply are not driving it. Hiding that behind a 404
 * would leave a driver who tapped the wrong run with no way to tell.
 *
 * @param reason - why the service refused.
 * @returns the HTTP status and body.
 */
function refusal(reason: LifecycleRefusal): {
  code: 403 | 404 | 409;
  body: { error: string; message: string };
} {
  switch (reason) {
    case 'not_found':
      return { code: 404, body: { error: 'not_found', message: 'Trip not found' } };
    case 'not_assigned_driver':
      return {
        code: 403,
        body: { error: 'forbidden', message: 'Not the assigned driver for this trip' },
      };
    case 'illegal_transition':
      return {
        code: 409,
        body: {
          error: 'illegal_transition',
          message: 'A trip must be started before it can be completed',
        },
      };
  }
}

/**
 * Arrival adds one refusal the others cannot produce: a seq that is not on this
 * trip's route. 404 on the STOP rather than 400 — the body is well formed, it
 * names something that does not exist.
 *
 * @param reason - why the service refused.
 * @returns the HTTP status and body.
 */
function arrivalRefusal(reason: ArrivalRefusal): {
  code: 403 | 404 | 409;
  body: { error: string; message: string };
} {
  if (reason === 'no_such_stop') {
    return {
      code: 404,
      body: { error: 'not_found', message: 'No stop with that seq on this route' },
    };
  }
  if (reason === 'illegal_transition') {
    return {
      code: 409,
      body: { error: 'illegal_transition', message: 'A trip must be active to report a stop' },
    };
  }
  return accessRefusal(reason);
}

/**
 * Narrower variant for reads, which can only fail on existence or access.
 *
 * @param reason - why the service refused.
 * @returns the HTTP status and body.
 */
function accessRefusal(reason: AccessRefusal): {
  code: 403 | 404;
  body: { error: string; message: string };
} {
  return reason === 'not_found'
    ? { code: 404, body: { error: 'not_found', message: 'Trip not found' } }
    : {
        code: 403,
        body: { error: 'forbidden', message: 'Not the assigned driver for this trip' },
      };
}

/**
 * Register the driver lifecycle routes.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.lifecycle - the lifecycle service (503 when absent).
 * @param opts.rateLimit - rate-limit config (applied per user).
 */
export async function tripLifecycleRoutes(
  app: FastifyInstance,
  opts: { lifecycle?: TripLifecycleService; rateLimit: RateLimitConfig },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();
  const UNAVAILABLE = { error: 'unavailable', message: 'Trip lifecycle is not configured' };
  const driverOnly = [
    app.authenticate,
    app.rateLimit({ ...opts.rateLimit, by: 'user' }),
    app.requireRole('driver'),
  ];
  const idParam = z.object({ id: z.string().uuid() });

  r.get(
    '/me/trips',
    {
      schema: {
        tags: ['mobility'],
        summary: "The signed-in driver's assigned runs",
        description:
          'Scoped to the caller rather than taking a driver id, so one driver cannot ' +
          'enumerate another’s schedule. Takes either one `date` or an inclusive ' +
          '`from`/`to` range, so a month calendar is one request rather than thirty-one. ' +
          'Both filter on the UTC calendar day.',
        security: [{ bearerAuth: [] }],
        querystring: myTripsQuerySchema,
        response: {
          200: z.object({ trips: z.array(tripResponseSchema) }),
          401: errorResponseSchema,
          403: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: driverOnly,
    },
    async (request, reply) => {
      if (!opts.lifecycle) return reply.code(503).send(UNAVAILABLE);
      const trips = await opts.lifecycle.myTrips(request.user!.id, {
        date: request.query.date,
        from: request.query.from,
        to: request.query.to,
      });
      return { trips };
    },
  );

  for (const action of ['start', 'complete'] as const) {
    r.post(
      `/trips/:id/${action}`,
      {
        schema: {
          tags: ['mobility'],
          summary: action === 'start' ? 'Start my assigned run' : 'End my assigned run',
          description:
            action === 'start'
              ? 'Idempotent: starting an already-active trip succeeds. A driver whose ' +
                'phone dropped mid-tap will press it again, and an error at the roadside ' +
                'is a worse answer than "yes, it is running".'
              : 'Refuses a trip that never started — that means the wrong run was tapped, ' +
                'and a completed trip with no GPS trace would poison route learning.',
          security: [{ bearerAuth: [] }],
          params: idParam,
          response: {
            200: tripResponseSchema,
            401: errorResponseSchema,
            403: errorResponseSchema,
            404: errorResponseSchema,
            409: errorResponseSchema,
            503: errorResponseSchema,
          },
        },
        preHandler: driverOnly,
      },
      async (request, reply) => {
        if (!opts.lifecycle) return reply.code(503).send(UNAVAILABLE);
        const result = await opts.lifecycle[action](request.params.id, request.user!.id);
        if (!result.ok) {
          const { code, body } = refusal(result.reason);
          return reply.code(code).send(body);
        }
        return result.trip;
      },
    );
  }

  // Stop progress (#230). Driver-advanced: the app posts the seq the driver has
  // reached, and every trip frame's "Stop 3 of 11" reads it back. Not derived
  // from GPS — see the reasoning on arriveBodySchema.
  r.post(
    '/trips/:id/arrive',
    {
      schema: {
        tags: ['mobility'],
        summary: 'Report reaching a stop on my run',
        description:
          'Idempotent, and not monotonic: a driver who taps one stop too far can tap ' +
          'back. The seq must be one of the route’s own stops.',
        security: [{ bearerAuth: [] }],
        params: idParam,
        body: arriveBodySchema,
        response: {
          200: tripResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
          409: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: driverOnly,
    },
    async (request, reply) => {
      if (!opts.lifecycle) return reply.code(503).send(UNAVAILABLE);
      const result = await opts.lifecycle.arrive(
        request.params.id,
        request.user!.id,
        request.body.seq,
      );
      if (!result.ok) {
        const { code, body } = arrivalRefusal(result.reason);
        return reply.code(code).send(body);
      }
      return result.trip;
    },
  );

  r.get(
    '/trips/:id/summary',
    {
      schema: {
        tags: ['mobility'],
        summary: 'What my run did — boarded, not boarded, and by which method',
        description:
          'Reports notBoarded rather than "no-shows deducted": the debit is the ops ' +
          'cutoff’s decision, not this screen’s, and a driver should not read a ' +
          'deduction that has not happened yet.',
        security: [{ bearerAuth: [] }],
        params: idParam,
        response: {
          200: runSummarySchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: driverOnly,
    },
    async (request, reply) => {
      if (!opts.lifecycle) return reply.code(503).send(UNAVAILABLE);
      const result = await opts.lifecycle.summary(request.params.id, request.user!.id);
      if (!result.ok) {
        const { code, body } = accessRefusal(result.reason);
        return reply.code(code).send(body);
      }
      return result.summary;
    },
  );
}
