import { z } from 'zod';
import type { SubscriptionPlan } from '../subscriptions/subscription.repository';

// Single source for the plan values; `satisfies` makes TS error if these drift
// from the SubscriptionPlan union.
export const PLANS = ['monthly', 'annual'] as const satisfies readonly SubscriptionPlan[];

export const subscribeBodySchema = z.object({
  plan: z.enum(PLANS),
  /**
   * The corridor the rider commutes. **Required since #103**: the price is
   * derived from that corridor's regulated fare, so there is no meaningful
   * price for "some route". It also pins the subscription so the daily
   * ask-dispatch knows which riders to prompt (E3).
   */
  routeId: z.string().uuid(),
  /**
   * Where the rider boards and alights (#204). Optional so existing clients keep
   * working; without them the rider is pinned to the corridor only, and the
   * live-position response cannot say which stop is theirs.
   */
  pickupStopId: z.string().uuid().optional(),
  dropoffStopId: z.string().uuid().optional(),
});

export const checkoutResponseSchema = z.object({
  authorizationUrl: z.string(),
  reference: z.string(),
  /** Full period price before credit — what the rider would owe with none. */
  pricePesewas: z.number().int(),
  /** Ride Credit netted off (#128); 0 when the rider has none. */
  appliedCreditPesewas: z.number().int(),
  /** What Paystack will actually charge: `pricePesewas - appliedCreditPesewas`. */
  chargePesewas: z.number().int(),
});

export const webhookResponseSchema = z.object({
  received: z.boolean(),
});

export const operationsReviewQuerySchema = z.object({
  limit: z.coerce.number().int().min(1).max(500).default(100),
});

export const operationsReviewSchema = z.object({
  id: z.string(),
  kind: z.enum(['refund', 'dispute', 'manual_review']),
  paymentReference: z.string(),
  userId: z.string(),
  paymentStatus: z.string(),
  status: z.string(),
  amountPesewas: z.number().int(),
  resolution: z.string().nullable(),
  consumedRides: z.number().int().nullable(),
  unrecoveredCreditPesewas: z.number().int().nullable(),
  estimatedDebtPesewas: z.number().int().nullable(),
  createdAt: z.date(),
  updatedAt: z.date(),
});

export const periodCloseFailureSchema = z.object({
  periodId: z
    .string()
    .describe('Opaque stable accounting identifier; clients must not assume UUID format'),
  reason: z.enum([
    'missing_period_accounting',
    'period_not_found',
    'missing_conversion_rate',
    'unexpected_error',
  ]),
});

export const periodCloseResultSchema = z.object({
  considered: z.number().int(),
  closed: z.number().int(),
  blocked: z.number().int(),
  failed: z.number().int(),
  failures: z.array(periodCloseFailureSchema),
  riders: z.number().int(),
  ridesConverted: z.number().int(),
  creditPesewas: z.number().int(),
});
