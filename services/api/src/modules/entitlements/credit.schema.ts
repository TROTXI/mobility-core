import { z } from 'zod';
import { periodCloseFailureSchema } from '../payments/payments.schema';

/** Totals returned by the month-end credit-conversion run. */
export const convertCreditsResponseSchema = z.object({
  /** Riders who had unused rides converted. */
  riders: z.number().int(),
  /** Total rides retired. */
  ridesConverted: z.number().int(),
  /** Total credit minted, in pesewas. */
  creditPesewas: z.number().int(),
  /** Per-period close failures requiring operator reconciliation. */
  failed: z.number().int(),
  failures: z.array(periodCloseFailureSchema),
});
