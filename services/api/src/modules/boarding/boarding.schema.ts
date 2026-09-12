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
  /**
   * The rider's daily boarding code, case-insensitive (for example `B7K9`).
   *
   * Deliberately looser than the generator's alphabet: codes issued before the
   * alphanumeric switch are four digits, including the `0` and `1` the new
   * alphabet omits, and rejecting those at the edge would strand riders holding
   * one. The HMAC comparison is the real gate.
   */
  pin: z.string().regex(/^[0-9A-Za-z]{4}$/, 'expected a 4-character boarding code'),
});

export const verifyPinResponseSchema = z.object({
  valid: z.boolean(),
  riderId: z.string().nullable(),
  reason: z.enum(['ok', 'invalid', 'not_found', 'already_boarded', 'forbidden']),
  deducted: z.boolean(),
});

export const resolveNoShowsBodySchema = z.object({
  travelDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'expected YYYY-MM-DD'),
  direction: z.enum(['morning', 'evening']),
});

export const resolveNoShowsResponseSchema = z.object({
  /** How many confirmed-but-unboarded seats were deducted as no-shows. */
  noShows: z.number().int(),
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
      /** How the seat was taken (#230) — the standby share the Today card shows. */
      source: z.enum(['confirmation', 'default', 'standby']),
      /** Marked as not having turned up by the driver (#227). Still boardable. */
      noShow: z.boolean(),
    }),
  ),
});

/**
 * Board a rider the driver has already identified by face and photo (#227).
 *
 * No code: the whole point of the photo pass is the case where a code will not
 * scan or the rider cannot produce one, and requiring one here would defeat it.
 * The assigned-driver check is what stands in its place.
 */
export const boardRiderBodySchema = z.object({
  reservationId: z.string().uuid(),
});

export const boardRiderResponseSchema = z.object({
  riderId: z.string().uuid().nullable(),
  reason: z.enum(['ok', 'not_found', 'already_boarded', 'forbidden']),
  deducted: z.boolean(),
});

/** One rider the driver says did not turn up at their stop (#227). */
export const markNoShowBodySchema = z.object({
  reservationId: z.string().uuid(),
});

export const markNoShowResponseSchema = z.object({
  riderId: z.string().uuid().nullable(),
  reason: z.enum(['ok', 'not_found', 'already_boarded', 'already_no_show', 'forbidden']),
  /** True when this call consumed the seat's ride. */
  deducted: z.boolean(),
});
