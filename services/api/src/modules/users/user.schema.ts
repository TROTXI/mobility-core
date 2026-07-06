// Public (response) representation of a user. Drives both OpenAPI docs and
// response serialization via the zod type provider (ADR-0008).

import { z } from 'zod';
import { USER_ROLES } from './user.repository';

export const userResponseSchema = z.object({
  id: z.string().uuid(),
  displayName: z.string(),
  phone: z.string().nullable(),
  // A short-lived signed URL when the user has an avatar (the raw object key is
  // never exposed); null otherwise.
  avatarUrl: z.string().nullable(),
  role: z.enum(USER_ROLES),
  createdAt: z.date(),
});

export const updateProfileBodySchema = z.object({
  displayName: z.string().trim().min(1).max(80),
});

export const avatarResponseSchema = z.object({
  avatarUrl: z.string(),
});
