import { z } from 'zod';

const directionSchema = z.enum(['morning', 'evening']);

export const respondBodySchema = z.object({
  /** The trip being confirmed (optional until trips land, #18). */
  tripId: z.string().uuid().optional(),
  /** Travel day as `YYYY-MM-DD`. */
  travelDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'expected YYYY-MM-DD'),
  direction: directionSchema,
  /** true → reserve the seat; false → decline. */
  travelling: z.boolean(),
});

export const listReservationsQuerySchema = z.object({
  /** Optional lower bound (`YYYY-MM-DD`) — defaults to all. */
  from: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'expected YYYY-MM-DD')
    .optional(),
});

export const reservationResponseSchema = z.object({
  id: z.string().uuid(),
  tripId: z.string().nullable(),
  travelDate: z.string(),
  direction: directionSchema,
  status: z.enum([
    'pending',
    'reserved',
    'declined',
    'boarded',
    'no_show',
    'released',
    'operator_cancelled',
  ]),
  source: z.enum(['confirmation', 'default', 'standby']),
  /** The daily 4-digit boarding PIN — returned ONLY when confirming (travelling
   * true); the rider shows it if the QR can't be scanned. Absent otherwise. */
  pin: z.string().optional(),
});

export const reservationListResponseSchema = z.object({
  reservations: z.array(reservationResponseSchema),
});
