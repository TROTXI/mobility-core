import { z } from 'zod';

export const balanceResponseSchema = z.object({
  /** Remaining wallet balance in pesewas (1 GHS = 100 pesewas). */
  balancePesewas: z.number().int(),
});
