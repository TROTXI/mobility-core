import { z } from 'zod';

export const stopResponseSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  latitude: z.number(),
  longitude: z.number(),
  createdAt: z.date(),
});

export const routeResponseSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  description: z.string().nullable(),
  createdAt: z.date(),
});

export const routeWithStopsResponseSchema = routeResponseSchema.extend({
  stops: z.array(
    stopResponseSchema.extend({
      seq: z.number().int(),
    }),
  ),
});
