// Auth routes — thin HTTP layer over AuthService (ADR-0009 layering). `GET /me`
// reads the principal; `/auth/*` handle social sign-in, refresh, and logout.
// Sign-in/refresh are rate-limited per IP (they take untrusted input pre-auth).

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import { userResponseSchema } from '../users/user.schema';
import type { UserRepository } from '../users/user.repository';
import {
  authResultSchema,
  googleSignInBodySchema,
  logoutBodySchema,
  refreshBodySchema,
  tokensSchema,
} from './auth.schema';
import {
  type AuthService,
  InvalidRefreshTokenError,
  SignInNotConfiguredError,
} from './auth.service';

// Strict per-IP limit for the credential endpoints (brute-force / abuse guard).
const AUTH_RATE_LIMIT = { max: 10, windowSeconds: 60 } as const;

export async function authRoutes(
  app: FastifyInstance,
  opts: { users?: UserRepository; authService?: AuthService; rateLimit: RateLimitConfig },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();

  r.get(
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
      const principal = request.user!;
      const user = opts.users ? await opts.users.findById(principal.id) : null;
      if (!user) {
        return reply.code(404).send({ error: 'not_found', message: 'User not found' });
      }
      return user;
    },
  );

  r.post(
    '/auth/google',
    {
      schema: {
        tags: ['auth'],
        summary: 'Sign in with a Google ID token (creates the account on first use)',
        body: googleSignInBodySchema,
        response: {
          200: authResultSchema,
          401: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.rateLimit({ ...AUTH_RATE_LIMIT, by: 'ip' })],
    },
    async (request, reply) => {
      if (!opts.authService) {
        return reply.code(503).send({ error: 'unavailable', message: 'Sign-in is not configured' });
      }
      try {
        return await opts.authService.signIn(request.body.idToken);
      } catch (err) {
        if (err instanceof SignInNotConfiguredError) {
          return reply
            .code(503)
            .send({ error: 'unavailable', message: 'Sign-in is not configured' });
        }
        return reply.code(401).send({ error: 'unauthorized', message: 'Invalid ID token' });
      }
    },
  );

  r.post(
    '/auth/refresh',
    {
      schema: {
        tags: ['auth'],
        summary: 'Exchange a refresh token for a new token pair (rotates the session)',
        body: refreshBodySchema,
        response: {
          200: tokensSchema,
          401: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.rateLimit({ ...AUTH_RATE_LIMIT, by: 'ip' })],
    },
    async (request, reply) => {
      if (!opts.authService) {
        return reply.code(503).send({ error: 'unavailable', message: 'Sign-in is not configured' });
      }
      try {
        return await opts.authService.refresh(request.body.refreshToken);
      } catch (err) {
        if (err instanceof InvalidRefreshTokenError) {
          return reply
            .code(401)
            .send({ error: 'unauthorized', message: 'Invalid or expired refresh token' });
        }
        throw err;
      }
    },
  );

  r.post(
    '/auth/logout',
    {
      schema: {
        tags: ['auth'],
        summary: 'Revoke a refresh token (idempotent)',
        body: logoutBodySchema,
      },
    },
    async (request, reply) => {
      if (opts.authService) {
        await opts.authService.logout(request.body.refreshToken);
      }
      return reply.code(204).send();
    },
  );
}
