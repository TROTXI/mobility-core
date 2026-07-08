import { z } from 'zod';

const dateAndDirection = {
  travelDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'expected YYYY-MM-DD'),
  direction: z.enum(['morning', 'evening']),
};

export const askDispatchBodySchema = z.object(dateAndDirection);
export const resolveDefaultsBodySchema = z.object(dateAndDirection);

export const askDispatchResponseSchema = z.object({
  trips: z.number().int(),
  asked: z.number().int(),
});

export const resolveDefaultsResponseSchema = z.object({
  defaulted: z.number().int(),
});
