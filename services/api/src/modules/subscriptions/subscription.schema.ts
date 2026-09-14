import { z } from 'zod';

export const currentSubscriptionResponseSchema = z.discriminatedUnion('subscribed', [
  z.object({
    subscribed: z.literal(false),
    subscription: z.null(),
  }),
  z.object({
    subscribed: z.literal(true),
    subscription: z.object({
      id: z.string().uuid(),
      plan: z.enum(['monthly', 'annual']),
      status: z.enum(['active', 'suspended']),
      /** An independent lifecycle dimension: a disputed subscription can also be paused. */
      paused: z.boolean(),
      routeId: z.string().uuid().nullable(),
      pickupStopId: z.string().uuid().nullable(),
      dropoffStopId: z.string().uuid().nullable(),
      periodStart: z.date().nullable(),
      /** Null while paused because paid time is extended only when the rider resumes. */
      renewsAt: z.date().nullable(),
    }),
  }),
]);
