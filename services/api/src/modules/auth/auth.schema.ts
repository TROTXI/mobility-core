import { z } from 'zod';
import { userResponseSchema } from '../users/user.schema';

export const googleSignInBodySchema = z.object({
  idToken: z.string().min(1),
});

/**
 * Apple carries less in its token than Google does, so the client supplies the
 * rest. `fullName` is Apple's one-time gift: returned on the first authorization
 * only, never in the token, and gone forever if we don't store it then. `nonce`
 * is the raw value the client hashed into the authorization request, letting us
 * reject a replayed token.
 */
export const appleSignInBodySchema = z.object({
  idToken: z.string().min(1),
  fullName: z.string().max(200).optional(),
  nonce: z.string().max(200).optional(),
});

export const refreshBodySchema = z.object({
  refreshToken: z.string().min(1),
});

export const logoutBodySchema = refreshBodySchema;

export const tokensSchema = z.object({
  accessToken: z.string(),
  refreshToken: z.string(),
});

export const authResultSchema = tokensSchema.extend({
  user: userResponseSchema,
});

export const sessionSchema = z.object({
  id: z.string(),
  createdAt: z.string(), // ISO 8601
  expiresAt: z.string(), // ISO 8601
});

export const sessionListResponseSchema = z.object({
  sessions: z.array(sessionSchema),
});

export const sessionIdParamsSchema = z.object({
  id: z.string().uuid(),
});
