import { z } from 'zod';

/** Totals returned by the month-end credit-conversion run. */
export const convertCreditsResponseSchema = z.object({
  /** Riders who had unused rides converted. */
  riders: z.number().int(),
  /** Total rides retired. */
  ridesConverted: z.number().int(),
  /** Total credit minted, in pesewas. */
  creditPesewas: z.number().int(),
});
