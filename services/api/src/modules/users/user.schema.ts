// Public (response) representation of a user. Drives both OpenAPI docs and
// response serialization via the zod type provider (ADR-0008).

import { z } from 'zod';
import { USER_ROLES } from './user.repository';

export const userResponseSchema = z.object({
  id: z.string().uuid(),
  displayName: z.string(),
  phone: z.string().nullable(),
  avatarUrl: z.string().nullable(),
  role: z.enum(USER_ROLES),
  createdAt: z.date(),
});
