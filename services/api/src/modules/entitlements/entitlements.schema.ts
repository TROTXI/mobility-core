import { z } from 'zod';

export const ridesResponseSchema = z.object({
  /** Rides left in the current subscription period. */
  remainingRides: z.number().int(),
  /** Ride Credit balance in pesewas (carries toward the next renewal). */
  creditPesewas: z.number().int(),
});
