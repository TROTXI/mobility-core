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
  /**
   * Riders left `pending` because their trip was already full (#161).
   *
   * Reported rather than silently dropped: a non-zero count means demand
   * exceeded the bus, which is exactly the signal ops needs to put a second
   * vehicle on that corridor — and the trigger for the standby pool (#105).
   */
  skippedFull: z.number().int(),
});
