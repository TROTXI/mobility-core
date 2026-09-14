import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import { CommuteConflict, type PgCommuteService } from './commute.service.pg';
import {
  commuteSubmit,
  commuteDecision,
  commuteResponse,
  commuteSlotInput,
  commuteSlotResponse,
  commuteEvent,
} from './commute.schema';

/** Register authenticated rider requests and the admin decision queue.
 * @param app - HTTP server.
 * @param opts - Durable workflow and per-user request limits.
 * @param opts.service - Postgres-backed workflow; absent means unavailable.
 * @param opts.rateLimit - Per-user rate limiting.
 */
export async function commuteRoutes(
  app: FastifyInstance,
  opts: { service?: PgCommuteService; rateLimit: RateLimitConfig },
) {
  const r = app.withTypeProvider<ZodTypeProvider>();
  const auth = (role: 'admin' | 'commuter') => [
    app.authenticate,
    app.rateLimit({ ...opts.rateLimit, by: 'user' }),
    app.requireRole(role),
  ];
  const errors = {
    401: errorResponseSchema,
    403: errorResponseSchema,
    404: errorResponseSchema,
    409: errorResponseSchema,
    429: errorResponseSchema,
    503: errorResponseSchema,
  };
  const common = { tags: ['commute'], security: [{ bearerAuth: [] }] };
  const query = z.object({
    status: z
      .enum(['pending', 'waitlisted', 'approved', 'rejected', 'cancelled', 'applied'])
      .optional(),
    limit: z.coerce.number().int().min(1).max(200).default(100),
    offset: z.coerce.number().int().min(0).max(100000).default(0),
  });
  const service = () => {
    if (!opts.service)
      throw Object.assign(new Error('Commute requests require the database'), { statusCode: 503 });
    return opts.service;
  };
  r.setErrorHandler((error, _request, reply) => {
    if (error instanceof CommuteConflict)
      return reply.code(error.httpStatus).send({ error: error.code, message: error.message });
    const code = error instanceof Error && 'code' in error ? error.code : undefined;
    if (code === '23503')
      return reply.code(409).send({
        error: 'reference_changed',
        message: 'A referenced route, account or stop is no longer available',
      });
    if (code === '23505')
      return reply.code(409).send({
        error: 'conflict',
        message: 'A request or allocation already exists; refresh before retrying',
      });
    throw error;
  });
  for (const scope of ['me', 'admin'] as const) {
    r.get(
      `/${scope}/commute-requests`,
      {
        schema: {
          ...common,
          querystring: query,
          response: { 200: z.object({ requests: z.array(commuteResponse) }), ...errors },
        },
        preHandler: auth(scope === 'me' ? 'commuter' : 'admin'),
      },
      async (request) => ({
        requests: await service().list(
          scope === 'me' ? request.user!.id : undefined,
          request.query,
        ),
      }),
    );
  }
  r.post(
    '/me/commute-requests',
    {
      schema: {
        ...common,
        body: commuteSubmit,
        response: { 200: z.object({ id: z.string().uuid() }), ...errors },
      },
      preHandler: auth('commuter'),
    },
    async (request) => service().submit(request.user!.id, request.body),
  );
  r.post(
    '/me/commute-requests/:id/withdraw',
    {
      schema: {
        ...common,
        params: z.object({ id: z.string().uuid() }),
        response: {
          200: z.object({ id: z.string().uuid(), status: z.string().optional() }),
          ...errors,
        },
      },
      preHandler: auth('commuter'),
    },
    async (request) =>
      service().decide(
        request.params.id,
        request.user!.id,
        { action: 'cancel', note: 'Withdrawn by rider' },
        true,
      ),
  );
  r.post(
    '/admin/commute-requests/:id/decision',
    {
      schema: {
        ...common,
        params: z.object({ id: z.string().uuid() }),
        body: commuteDecision,
        response: {
          200: z.object({ id: z.string().uuid(), status: z.string().optional() }),
          ...errors,
        },
      },
      preHandler: auth('admin'),
    },
    async (request) => service().decide(request.params.id, request.user!.id, request.body),
  );
  r.get(
    '/admin/commute-slots',
    {
      schema: {
        ...common,
        response: { 200: z.object({ slots: z.array(commuteSlotResponse) }), ...errors },
      },
      preHandler: auth('admin'),
    },
    async () => ({ slots: await service().slots() }),
  );
  r.post(
    '/admin/commute-slots',
    {
      schema: {
        ...common,
        body: commuteSlotInput,
        response: { 200: z.object({ id: z.string().uuid() }), ...errors },
      },
      preHandler: auth('admin'),
    },
    async (request) => service().createSlot(request.user!.id, request.body),
  );
  r.post(
    '/admin/commute-slots/:id/retire',
    {
      schema: {
        ...common,
        params: z.object({ id: z.string().uuid() }),
        response: { 200: z.object({ id: z.string().uuid() }), ...errors },
      },
      preHandler: auth('admin'),
    },
    async (request) => service().retireSlot(request.params.id, request.user!.id),
  );
  r.get(
    '/admin/commute-requests/:id/events',
    {
      schema: {
        ...common,
        params: z.object({ id: z.string().uuid() }),
        response: { 200: z.object({ events: z.array(commuteEvent) }), ...errors },
      },
      preHandler: auth('admin'),
    },
    async (request) => ({ events: await service().events(request.params.id) }),
  );
}
