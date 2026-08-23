// User profile + avatar routes (#24). Profile edits and the avatar upload live
// here; the canonical `GET /me` stays in auth.routes.ts. Uploads are proxied
// through the API (not presigned direct-to-R2) so the server always resizes and
// re-encodes — stripping EXIF/PII — before anything is stored (security.md §7).

import type { FastifyInstance } from 'fastify';
import fastifyMultipart from '@fastify/multipart';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { errorResponseSchema } from '../../lib/schemas';
import type { ObjectStore } from '../../storage/object-store';
import type { RateLimitConfig } from '../ratelimit/ratelimit.plugin';
import {
  ACCEPTED_MIME,
  InvalidImageError,
  MAX_UPLOAD_BYTES,
  processAvatar,
  PROCESSED_MIME,
} from './avatar';
import type { AccountDeletionService } from './account-deletion.service';
import { toUserResponse } from './user.presenter';
import type { UserRepository } from './user.repository';
import { avatarResponseSchema, updateProfileBodySchema, userResponseSchema } from './user.schema';

/**
 * Register user profile + avatar routes: `PATCH /me`, `POST /me/avatar`,
 * `GET /me/avatar`.
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies.
 * @param opts.users - the user repository.
 * @param opts.objectStore - avatar storage (R2 in prod, in-memory in dev/tests).
 * @param opts.rateLimit - rate-limit config (applied per user).
 * @param opts.accountDeletion - account erasure service (503 when absent).
 */
export async function userRoutes(
  app: FastifyInstance,
  opts: {
    users?: UserRepository;
    objectStore: ObjectStore;
    rateLimit: RateLimitConfig;
    accountDeletion?: AccountDeletionService;
  },
): Promise<void> {
  await app.register(fastifyMultipart, { limits: { fileSize: MAX_UPLOAD_BYTES, files: 1 } });
  const r = app.withTypeProvider<ZodTypeProvider>();
  const UNAVAILABLE = { error: 'unavailable', message: 'User store is not configured' };
  const NOT_FOUND = { error: 'not_found', message: 'User not found' };

  r.patch(
    '/me',
    {
      schema: {
        tags: ['auth'],
        summary: "Update the authenticated user's profile",
        security: [{ bearerAuth: [] }],
        body: updateProfileBodySchema,
        response: {
          200: userResponseSchema,
          401: errorResponseSchema,
          404: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.users) return reply.code(503).send(UNAVAILABLE);
      const user = await opts.users.updateProfile(request.user!.id, {
        displayName: request.body.displayName,
      });
      if (!user) return reply.code(404).send(NOT_FOUND);
      return toUserResponse(user, opts.objectStore);
    },
  );

  r.post(
    '/me/avatar',
    {
      schema: {
        tags: ['auth'],
        summary: 'Upload the authenticated user avatar (resized + EXIF-stripped server-side)',
        consumes: ['multipart/form-data'],
        security: [{ bearerAuth: [] }],
        response: {
          200: avatarResponseSchema,
          400: errorResponseSchema,
          401: errorResponseSchema,
          404: errorResponseSchema,
          413: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.users) return reply.code(503).send(UNAVAILABLE);

      const part = await request.file();
      if (!part) return reply.code(400).send({ error: 'bad_request', message: 'No file uploaded' });
      if (!ACCEPTED_MIME.has(part.mimetype)) {
        return reply
          .code(400)
          .send({ error: 'bad_request', message: 'Unsupported image type (use JPEG/PNG/WebP)' });
      }

      let raw: Buffer;
      try {
        raw = await part.toBuffer();
      } catch (err) {
        if ((err as { code?: string }).code === 'FST_REQ_FILE_TOO_LARGE') {
          return reply
            .code(413)
            .send({ error: 'payload_too_large', message: 'Image exceeds 5 MB' });
        }
        throw err;
      }

      let processed: Buffer;
      try {
        processed = await processAvatar(raw);
      } catch (err) {
        if (err instanceof InvalidImageError) {
          return reply.code(400).send({ error: 'bad_request', message: err.message });
        }
        throw err;
      }

      const userId = request.user!.id;
      const key = await opts.objectStore.putAvatar(userId, processed, PROCESSED_MIME);
      const user = await opts.users.setAvatarKey(userId, key);
      if (!user) return reply.code(404).send(NOT_FOUND);
      return { avatarUrl: await opts.objectStore.signedUrl(key) };
    },
  );

  r.get(
    '/me/avatar',
    {
      schema: {
        tags: ['auth'],
        summary: 'Get a short-lived signed URL for the authenticated user avatar',
        security: [{ bearerAuth: [] }],
        response: {
          200: avatarResponseSchema,
          401: errorResponseSchema,
          404: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.users) return reply.code(503).send(UNAVAILABLE);
      const user = await opts.users.findById(request.user!.id);
      if (!user) return reply.code(404).send(NOT_FOUND);
      if (!user.avatarUrl) {
        return reply.code(404).send({ error: 'not_found', message: 'No avatar set' });
      }
      return { avatarUrl: await opts.objectStore.signedUrl(user.avatarUrl) };
    },
  );

  r.delete(
    '/me',
    {
      schema: {
        tags: ['users'],
        summary: 'Delete my account (erases personal data; keeps financial records)',
        description:
          'Revokes every session, unregisters push devices, unlinks sign-in providers, ' +
          'deletes the avatar, and clears personal data. Payment and ride-ledger rows ' +
          'are retained in anonymised form because they are accounting records. ' +
          'Signing in again creates a new account.',
        security: [{ bearerAuth: [] }],
        response: {
          204: z.null(),
          401: errorResponseSchema,
          429: errorResponseSchema,
          503: errorResponseSchema,
        },
      },
      preHandler: [app.authenticate, app.rateLimit({ ...opts.rateLimit, by: 'user' })],
    },
    async (request, reply) => {
      if (!opts.accountDeletion) {
        return reply
          .code(503)
          .send({ error: 'unavailable', message: 'Account deletion is not configured' });
      }
      // Idempotent by design: a client retrying after a timeout gets 204 again
      // rather than a 404 that would read as "deletion failed".
      await opts.accountDeletion.deleteAccount(request.user!.id);
      return reply.code(204).send(null);
    },
  );
}
