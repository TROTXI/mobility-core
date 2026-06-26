// Zod schemas for the mobility domain. These serve dual purpose: runtime
// validation of responses and OpenAPI spec generation via the zod type
// provider (ADR-0008). stopResponseSchema exposes lat/lng as plain numbers
// rather than a PostGIS geometry — the Pg adapter handles the conversion.

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

// routeWithStopsResponseSchema extends the base route shape with an ordered
// list of stops. seq is included so clients can render the route in the correct
// direction without re-sorting.
export const routeWithStopsResponseSchema = routeResponseSchema.extend({
  stops: z.array(
    stopResponseSchema.extend({
      seq: z.number().int(),
    }),
  ),
});
