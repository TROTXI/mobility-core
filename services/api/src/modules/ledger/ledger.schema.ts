import { z } from 'zod';

export const balanceResponseSchema = z.object({
  /** Remaining GHS value of the rider's tokens (1 token = 1 GHS). */
  balanceGhs: z.number().int(),
});
