// Zod schemas for the subscriptions domain. Enums are exported as const arrays
// so they can be reused in the repository types and future CHECK constraints
// without duplicating the literal values. Drives both runtime validation and
// the OpenAPI spec via the zod type provider (ADR-0008).

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
