// Auth routes. `GET /me` is the first protected endpoint — it proves the guard
// end-to-end (token -> request.user -> repository lookup). Sign-in/refresh land
// in Slice 2. Registered after authPlugin so `app.authenticate` is available.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import { userResponseSchema } from '../users/user.schema';
import type { UserRepository } from '../users/user.repository';

export async function authRoutes(
  app: FastifyInstance,
  opts: { users?: UserRepository; rateLimit: RateLimitConfig },
): Promise<void> {
  // Authenticate first (sets request.user), then rate-limit per user.
  app.withTypeProvider<ZodTypeProvider>().get(
    '/me',
    {
      schema: {
        tags: ['auth'],
        summary: 'Get the currently authenticated user',
        security: [{ bearerAuth: [] }],
        response: {
          200: userResponseSchema,
          401: errorResponseSchema,
          404: errorResponseSchema,
          429: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      // `authenticate` guarantees request.user is set before we reach here.
      const principal = request.user!;
      const user = opts.users ? await opts.users.findById(principal.id) : null;
      if (!user) {
        return reply.code(404).send({ error: 'not_found', message: 'User not found' });
      }
      return user;
    },
  );
}
