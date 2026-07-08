import { z } from 'zod';
import type { SubscriptionPlan } from '../subscriptions/subscription.repository';

// Single source for the plan values; `satisfies` makes TS error if these drift
// from the SubscriptionPlan union.
const PLANS = ['monthly', 'annual'] as const satisfies readonly SubscriptionPlan[];

export const subscribeBodySchema = z.object({
  plan: z.enum(PLANS),
  /** The route/corridor the rider commutes (E3); pins the subscription so the
   * daily ask-dispatch knows which riders to prompt. Optional for now. */
  routeId: z.string().uuid().optional(),
});

export const checkoutResponseSchema = z.object({
  authorizationUrl: z.string(),
  reference: z.string(),
});

export const webhookResponseSchema = z.object({
  received: z.boolean(),
});
