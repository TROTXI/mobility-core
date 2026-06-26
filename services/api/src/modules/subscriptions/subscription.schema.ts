import { z } from 'zod';

export const SUBSCRIPTION_PLANS = ['monthly', 'annual'] as const;
export const SUBSCRIPTION_STATUSES = ['active', 'cancelled', 'expired'] as const;

export const subscriptionResponseSchema = z.object({
  id: z.string().uuid(),
  userId: z.string().uuid(),
  plan: z.enum(SUBSCRIPTION_PLANS),
  status: z.enum(SUBSCRIPTION_STATUSES),
  createdAt: z.date(),
});

export const createSubscriptionBodySchema = z.object({
  plan: z.enum(SUBSCRIPTION_PLANS),
});
