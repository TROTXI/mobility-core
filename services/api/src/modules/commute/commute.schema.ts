import { z } from 'zod';

export const commuteTime = z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/);
const morningTime = commuteTime.refine(
  (value) => Number(value.slice(0, 2)) < 12,
  'Morning departure must be before noon',
);
const eveningTime = commuteTime.refine(
  (value) => Number(value.slice(0, 2)) >= 12,
  'Return must be noon or later',
);
export const commuteDate = z.iso.date();
export const commuteSubmit = z.object({
  routeId: z.string().uuid(),
  pickupStopId: z.string().uuid(),
  dropoffStopId: z.string().uuid(),
  morningDeparture: morningTime,
  eveningReturn: eveningTime,
  requestedDate: commuteDate,
  pauseIfWaitlisted: z.boolean().default(false),
  note: z.string().trim().max(1000).default(''),
});
export const commuteDecision = z.object({
  action: z.enum(['waitlist', 'approve', 'reject', 'apply', 'pause', 'resume', 'cancel']),
  slotId: z.string().uuid().optional(),
  effectiveDate: commuteDate.optional(),
  note: z.string().trim().min(1).max(1000),
});
export const commuteSlotInput = z.object({
  routeId: z.string().uuid(),
  morningDeparture: morningTime,
  eveningReturn: eveningTime,
  availableFrom: commuteDate,
});
export const commuteResponse = z.object({
  id: z.string().uuid(),
  userId: z.string().uuid(),
  riderName: z.string(),
  subscriptionId: z.string().uuid(),
  periodId: z.string().uuid().nullable(),
  fromRouteId: z.string().uuid().nullable(),
  fromRouteName: z.string().nullable(),
  routeId: z.string().uuid(),
  routeName: z.string(),
  pickupStopId: z.string().uuid(),
  dropoffStopId: z.string().uuid(),
  pickupStopName: z.string(),
  dropoffStopName: z.string(),
  morningDeparture: commuteTime,
  eveningReturn: commuteTime,
  requestedDate: commuteDate,
  effectiveDate: commuteDate.nullable(),
  pauseIfWaitlisted: z.boolean(),
  note: z.string(),
  decisionNote: z.string().nullable(),
  status: z.enum(['pending', 'waitlisted', 'approved', 'rejected', 'cancelled', 'applied']),
  createdAt: z.string(),
  updatedAt: z.string(),
  paused: z.boolean(),
  subscriptionStatus: z.string(),
  periodEnd: z.string().nullable(),
});
export const commuteSlotResponse = commuteSlotInput.extend({
  id: z.string().uuid(),
  routeName: z.string(),
  status: z.enum(['available', 'held', 'allocated', 'retired']),
  requestId: z.string().uuid().nullable(),
  subscriptionId: z.string().uuid().nullable(),
});
export type CommuteSubmit = z.infer<typeof commuteSubmit>;
export type CommuteDecision = z.infer<typeof commuteDecision>;
export type CommuteSlotInput = z.infer<typeof commuteSlotInput>;
export const commuteEvent = z.object({
  id: z.string().uuid(),
  actorId: z.string().uuid(),
  action: z.string(),
  note: z.string(),
  createdAt: z.string(),
});
