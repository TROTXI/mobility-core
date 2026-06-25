// Auth guard. Registered with fastify-plugin so the decorators live on the root
// instance and are available to every route. Provides:
//   - request.user        the authenticated principal (set by `authenticate`)
//   - app.authenticate    preHandler: require a valid bearer token -> 401 if not
//   - app.requireRole(..) preHandler factory: RBAC check -> 403 if role mismatch
//   - app.jwt             the token service (used by sign-in routes in Slice 2)

import type { FastifyReply, FastifyRequest, preHandlerHookHandler } from 'fastify';
import fp from 'fastify-plugin';
import type { UserRole } from '../users/user.repository';
import { createJwtService, type AuthConfig, type JwtService } from './jwt';

/** The authenticated principal attached to each request after `authenticate`. */
export interface AuthUser {
  id: string;
  role: UserRole;
}

declare module 'fastify' {
  interface FastifyRequest {
    user?: AuthUser;
  }
  interface FastifyInstance {
    jwt: JwtService;
    authenticate: preHandlerHookHandler;
    requireRole: (...roles: UserRole[]) => preHandlerHookHandler;
  }
}

const BEARER_PREFIX = 'Bearer ';

export const authPlugin = fp<{ config: AuthConfig }>(async (app, opts) => {
  const jwt = createJwtService(opts.config);
  app.decorate('jwt', jwt);
  app.decorateRequest('user', undefined);

  // Roles live in the (short-lived) token, so a role change takes effect on the
  // next token refresh rather than instantly — an accepted trade-off for keeping
  // the guard stateless. Long-lived/destructive actions re-check server-side.
  app.decorate('authenticate', async function (request: FastifyRequest, reply: FastifyReply) {
    const header = request.headers.authorization;
    if (!header || !header.startsWith(BEARER_PREFIX)) {
      return reply.code(401).send({ error: 'unauthorized', message: 'Missing bearer token' });
    }
    try {
      const claims = await jwt.verifyAccessToken(header.slice(BEARER_PREFIX.length).trim());
      request.user = { id: claims.userId, role: claims.role };
    } catch {
      return reply.code(401).send({ error: 'unauthorized', message: 'Invalid or expired token' });
    }
  });

  // Compose after `authenticate`: preHandler: [app.authenticate, app.requireRole('admin')]
  app.decorate('requireRole', (...roles: UserRole[]): preHandlerHookHandler => {
    return async function (request: FastifyRequest, reply: FastifyReply) {
      if (!request.user) {
        return reply.code(401).send({ error: 'unauthorized', message: 'Authentication required' });
      }
      if (!roles.includes(request.user.role)) {
        return reply.code(403).send({ error: 'forbidden', message: 'Insufficient role' });
      }
    };
  });
});
