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
});

export const checkoutResponseSchema = z.object({
  authorizationUrl: z.string(),
  reference: z.string(),
});

export const webhookResponseSchema = z.object({
  received: z.boolean(),
});
