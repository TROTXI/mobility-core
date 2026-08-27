import { z } from 'zod';

export const ridesResponseSchema = z.object({
  /** Rides left in the current subscription period. */
  remainingRides: z.number().int(),
  /** Ride Credit balance in pesewas (carries toward the next renewal). */
  creditPesewas: z.number().int(),
  /**
   * Rides the current period started with, so the app can show "23 of 40".
   * Null without an active subscription, or on a pre-#103 row.
   */
  ridesPerPeriod: z.number().int().nullable(),
  /**
   * When the current period ends — the "renews 1 Sep" line in the designs.
   * Null without an active subscription (#162).
   */
  renewsAt: z.date().nullable(),
});
