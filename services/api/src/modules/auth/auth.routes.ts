// Auth routes. `GET /me` is the first protected endpoint — it proves the guard
// end-to-end (token -> request.user -> repository lookup). Sign-in/refresh land
// in Slice 2. Registered after authPlugin so `app.authenticate` is available.

import type { FastifyInstance } from 'fastify';
import type { UserRepository } from '../users/user.repository';

export async function authRoutes(
  app: FastifyInstance,
  opts: { users?: UserRepository },
): Promise<void> {
  app.get('/me', { preHandler: app.authenticate }, async (request, reply) => {
    // `authenticate` guarantees request.user is set before we reach here.
    const principal = request.user!;
    const user = opts.users ? await opts.users.findById(principal.id) : null;
    if (!user) {
      return reply.code(404).send({ error: 'not_found', message: 'User not found' });
    }
    return user;
  });
}
