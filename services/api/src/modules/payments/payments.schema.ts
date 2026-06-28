import { z } from 'zod';
import type { SubscriptionPlan } from '../subscriptions/subscription.repository';

// Single source for the plan values; `satisfies` makes TS error if these drift
// from the SubscriptionPlan union.
const PLANS = ['monthly', 'annual'] as const satisfies readonly SubscriptionPlan[];

export const initializePaymentBodySchema = z.object({
  plan: z.enum(PLANS),
});

export const initializePaymentResponseSchema = z.object({
  authorizationUrl: z.string(),
  reference: z.string(),
});

export const webhookResponseSchema = z.object({
  received: z.boolean(),
});
