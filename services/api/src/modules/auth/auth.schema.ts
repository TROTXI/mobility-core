import { z } from 'zod';
import { userResponseSchema } from '../users/user.schema';

export const googleSignInBodySchema = z.object({
  idToken: z.string().min(1),
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
