// Shared response schemas reused across routes (and rendered into the OpenAPI
// spec via the zod type provider — see ADR-0008).

import { z } from 'zod';

/** Standard error body: a stable machine code plus a human-readable message. */
export const errorResponseSchema = z.object({
  error: z.string(),
  message: z.string(),
});
