import { z } from 'zod';

export const passResponseSchema = z.object({
  pass: z.string(),
  expiresInSeconds: z.number().int(),
});

export const scanBodySchema = z.object({
  /** The token decoded from the scanned QR. Our passes are ~300 bytes; the cap
   * keeps oversized input away from jwtVerify. */
  pass: z.string().min(1).max(512),
  tripId: z.string().uuid().optional(),
});

export const scanResponseSchema = z.object({
  valid: z.boolean(),
  riderId: z.string().nullable(),
  reason: z.enum(['ok', 'invalid', 'expired', 'reused']),
});
