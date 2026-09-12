// Contract schemas for driver work requests (#232), rendered into the OpenAPI
// spec via the zod type provider (ADR-0008).

import { z } from 'zod';
import { REQUEST_KINDS, REQUEST_STATUSES } from './driver-request.repository';

const isoDate = z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'expected YYYY-MM-DD');

/**
 * A discriminated union rather than one object with everything optional, so the
 * shape the database CHECK enforces is refused at the edge with a readable
 * message instead of surfacing as a constraint violation.
 */
export const submitRequestBodySchema = z.discriminatedUnion('kind', [
  z.object({
    kind: z.literal('route_change'),
    routeId: z.string().uuid(),
    /** When the driver would like it to take effect. */
    fromDate: isoDate.optional(),
    note: z.string().max(1000).optional(),
  }),
  z.object({
    kind: z.literal('leave'),
    fromDate: isoDate,
    toDate: isoDate,
    note: z.string().max(1000).optional(),
  }),
]);

export const requestResponseSchema = z.object({
  id: z.string().uuid(),
  kind: z.enum(REQUEST_KINDS),
  status: z.enum(REQUEST_STATUSES),
  routeId: z.string().uuid().nullable(),
  fromDate: z.string().nullable(),
  toDate: z.string().nullable(),
  note: z.string().nullable(),
  decisionNote: z.string().nullable(),
  decidedAt: z.date().nullable(),
  createdAt: z.date(),
});

/** The ops view adds who asked and who answered. */
export const adminRequestResponseSchema = requestResponseSchema.extend({
  driverId: z.string().uuid(),
  decidedBy: z.string().uuid().nullable(),
});

export const listRequestsQuerySchema = z.object({
  status: z.enum(REQUEST_STATUSES).optional(),
});

export const decideRequestBodySchema = z.object({
  status: z.enum(['approved', 'declined']),
  /**
   * What ops wants the driver to read. Worth having on an approval too: "yes,
   * from the 14th" is a different answer from "yes", and the driver is going to
   * plan around whichever they get.
   */
  decisionNote: z.string().max(1000).optional(),
});

/** A corridor a driver may ask to be moved to. */
export const availableRouteSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  description: z.string().nullable(),
});
