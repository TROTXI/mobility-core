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
  /** True when the scan consumed a ride (the rider had a confirmed reservation
   * for today). False for a valid pass with no reservation to board. */
  deducted: z.boolean(),
});

export const verifyPinBodySchema = z.object({
  /** The reservation the driver picked off the manifest. */
  reservationId: z.string().uuid(),
  /** The rider's daily 4-digit PIN. */
  pin: z.string().regex(/^\d{4}$/, 'expected a 4-digit PIN'),
});

export const verifyPinResponseSchema = z.object({
  valid: z.boolean(),
  riderId: z.string().nullable(),
  reason: z.enum(['ok', 'invalid', 'not_found', 'already_boarded']),
  deducted: z.boolean(),
});

export const manifestQuerySchema = z.object({
  tripId: z.string().uuid(),
});

export const manifestResponseSchema = z.object({
  tripId: z.string().uuid(),
  riders: z.array(
    z.object({
      reservationId: z.string().uuid(),
      userId: z.string().uuid(),
      name: z.string().nullable(),
      /** Short-lived signed avatar URL, or null when the rider has no photo. */
      avatarUrl: z.string().nullable(),
      direction: z.enum(['morning', 'evening']),
      boarded: z.boolean(),
    }),
  ),
});
