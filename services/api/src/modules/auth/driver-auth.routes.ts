// Driver sign-in routes (#223, blocks #41). `/auth/driver` is public and takes
// the same strict per-IP limit as the other credential endpoints; the rest is
// the ops-side credential lifecycle, admin-gated like every other `/admin/*`.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import type { ObjectStore } from '../../storage/object-store';
import { toUserResponse } from '../users/user.presenter';
import {
  changePinBodySchema,
  credentialPatchBodySchema,
  driverAuthResultSchema,
  driverSignInBodySchema,
  issuedCredentialSchema,
  resetPinResponseSchema,
} from './driver-auth.schema';
import {
  DriverAuthService,
  DriverCredentialLockedError,
  DriverCredentialSuspendedError,
  DriverNotFoundError,
  InvalidDriverCredentialsError,
  WeakPinError,
} from './driver-auth.service';

/** Same strict per-IP budget the social sign-in routes use. */
const AUTH_RATE_LIMIT = { max: 10, windowSeconds: 60 } as const;

/**
 * Register driver sign-in and the ops credential endpoints.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.driverAuth - the driver auth service (routes 503 when absent).
 * @param opts.objectStore - avatar storage, to sign the user's avatar URL.
 * @param opts.rateLimit - rate-limit config for the authenticated routes.
 */
export async function driverAuthRoutes(
  app: FastifyInstance,
  opts: {
    driverAuth?: DriverAuthService;
    objectStore: ObjectStore;
    rateLimit: RateLimitConfig;
  },
): Promise<void> {
  const r = app.withTypeProvider<ZodTypeProvider>();
  const UNAVAILABLE = { error: 'unavailable', message: 'Driver sign-in is not configured' };
  const idParam = z.object({ id: z.string().uuid() });

  const adminOnly = [
    app.authenticate,
    app.rateLimit({ ...opts.rateLimit, by: 'user' }),
    app.requireRole('admin'),
  ];

  r.post(
    '/auth/driver',
    {
      schema: {
        tags: ['auth'],
        summary: 'Sign in with an ops-issued driver code and PIN',
        description:
          'A wrong code and a wrong PIN both answer 401, on purpose: a driver code is ' +
          'written on depot whiteboards and read down phone lines, so telling them ' +
          'apart would hand out a list of which codes exist. `rememberDevice` chooses ' +
          'the refresh lifetime: omit it on a shared handset and the session lasts a ' +
          'shift rather than a month.',
        body: driverSignInBodySchema,
        response: {
          200: driverAuthResultSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          423: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.rateLimit({ ...AUTH_RATE_LIMIT, by: 'ip' })],
    },
    async (request, reply) => {
      if (!opts.driverAuth) return reply.code(503).send(UNAVAILABLE);
      try {
        const result = await opts.driverAuth.signIn(request.body.driverCode, request.body.pin, {
          rememberDevice: request.body.rememberDevice,
        });
        return {
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
          user: await toUserResponse(result.user, opts.objectStore),
          driver: result.driver,
          mustChangePin: result.mustChangePin,
        };
      } catch (err) {
        if (err instanceof DriverCredentialLockedError) {
          reply.header('Retry-After', String(err.retryAfterSeconds));
          return reply.code(423).send({
            error: 'locked',
            message: 'Too many incorrect PINs. Try again later or call operations.',
          });
        }
        if (err instanceof DriverCredentialSuspendedError) {
          return reply
            .code(403)
            .send({ error: 'suspended', message: 'This driver account is suspended' });
        }
        // DriverNotFoundError lands here too. A credential whose driver link is
        // broken is our data problem, but answering 401 keeps it from becoming a
        // way to probe which codes resolve to a real account.
        if (err instanceof InvalidDriverCredentialsError || err instanceof DriverNotFoundError) {
          return reply
            .code(401)
            .send({ error: 'unauthorized', message: 'Invalid driver code or PIN' });
        }
        throw err;
      }
    },
  );

  r.post(
    '/auth/driver/pin',
    {
      schema: {
        tags: ['auth'],
        summary: 'Change my driver PIN',
        description:
          'Replaces the PIN and revokes every other session on the account. A rotation ' +
          'that leaves the old sessions alive has not evicted whoever prompted it.',
        security: [{ bearerAuth: [] }],
        body: changePinBodySchema,
        response: {
          204: z.null(),
          400: errorResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [
        app.authenticate,
        app.rateLimit({ ...opts.rateLimit, by: 'user' }),
        app.requireRole('driver'),
      ],
    },
    async (request, reply) => {
      if (!opts.driverAuth) return reply.code(503).send(UNAVAILABLE);
      try {
        await opts.driverAuth.changePin(
          request.user!.id,
          request.body.currentPin,
          request.body.newPin,
        );
        return reply.code(204).send(null);
      } catch (err) {
        if (err instanceof InvalidDriverCredentialsError) {
          return reply
            .code(401)
            .send({ error: 'unauthorized', message: 'Current PIN is incorrect' });
        }
        if (err instanceof WeakPinError) {
          return reply.code(400).send({ error: 'weak_pin', message: err.message });
        }
        if (err instanceof DriverNotFoundError) {
          return reply.code(404).send({ error: 'not_found', message: err.message });
        }
        throw err;
      }
    },
  );

  r.post(
    '/admin/drivers/:id/credentials',
    {
      schema: {
        tags: ['admin'],
        summary: 'Issue a driver code and one-time PIN',
        description:
          'Returns the PIN ONCE. It is stored only as a keyed hash and cannot be read ' +
          'back; a driver who loses it needs a reset, not a lookup. Also creates and ' +
          "links the driver's auth account if they do not have one yet.",
        security: [{ bearerAuth: [] }],
        params: idParam,
        response: {
          201: issuedCredentialSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
          409: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.driverAuth) return reply.code(503).send(UNAVAILABLE);
      try {
        return reply.code(201).send(await opts.driverAuth.issueCredential(request.params.id));
      } catch (err) {
        if (err instanceof DriverNotFoundError) {
          return reply.code(404).send({ error: 'not_found', message: err.message });
        }
        if ((err as { code?: string }).code === '23505') {
          return reply
            .code(409)
            .send({ error: 'conflict', message: 'This driver already has a credential' });
        }
        throw err;
      }
    },
  );

  r.post(
    '/admin/drivers/:id/credentials/reset-pin',
    {
      schema: {
        tags: ['admin'],
        summary: "Reset a driver's PIN and revoke their sessions",
        description:
          'The recovery path the sign-in screen points at. There is no self-service ' +
          'reset because a driver phone number is optional, so there is no verified ' +
          'channel to send one to.',
        security: [{ bearerAuth: [] }],
        params: idParam,
        response: {
          200: resetPinResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.driverAuth) return reply.code(503).send(UNAVAILABLE);
      try {
        return await opts.driverAuth.resetPin(request.params.id);
      } catch (err) {
        if (err instanceof DriverNotFoundError) {
          return reply.code(404).send({ error: 'not_found', message: err.message });
        }
        throw err;
      }
    },
  );

  r.patch(
    '/admin/drivers/:id/credentials',
    {
      schema: {
        tags: ['admin'],
        summary: 'Suspend, reinstate, or unlock a driver credential',
        description:
          'Suspending revokes live sessions: the point is to stop someone driving now, ' +
          'not whenever their access token happens to expire.',
        security: [{ bearerAuth: [] }],
        params: idParam,
        body: credentialPatchBodySchema,
        response: {
          204: z.null(),
          400: errorResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: adminOnly,
    },
    async (request, reply) => {
      if (!opts.driverAuth) return reply.code(503).send(UNAVAILABLE);
      try {
        if (request.body.status) {
          await opts.driverAuth.setStatus(request.params.id, request.body.status);
        }
        if (request.body.unlock) await opts.driverAuth.unlock(request.params.id);
        return reply.code(204).send(null);
      } catch (err) {
        if (err instanceof DriverNotFoundError) {
          return reply.code(404).send({ error: 'not_found', message: err.message });
        }
        throw err;
      }
    },
  );
}
