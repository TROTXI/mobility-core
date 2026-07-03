import { z } from 'zod';

export const passResponseSchema = z.object({
  pass: z.string(),
  expiresInSeconds: z.number().int(),
});

export const scanBodySchema = z.object({
  /** The token decoded from the scanned QR. */
  pass: z.string().min(1),
  tripId: z.string().uuid().optional(),
});

export const scanResponseSchema = z.object({
  valid: z.boolean(),
  riderId: z.string().nullable(),
  reason: z.enum(['ok', 'invalid', 'expired']),
});
