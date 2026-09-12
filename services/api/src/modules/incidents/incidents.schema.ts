// Contract schemas for driver incident reporting (#226), rendered into the
// OpenAPI spec via the zod type provider (ADR-0008).

import { z } from 'zod';
import { INCIDENT_CATEGORIES, INCIDENT_STATUSES } from './driver-incident.repository';

export const fileIncidentBodySchema = z.object({
  /** The run it happened on. Omit for a yard report before any trip starts. */
  tripId: z.string().uuid().optional(),
  category: z.enum(INCIDENT_CATEGORIES),
  /**
   * Free text, often typed one-handed at a kerb. Capped rather than unbounded:
   * the category is the routable part, and an uncapped column reachable by any
   * driver token is a cheap way to fill a database.
   */
  note: z.string().max(2000).optional(),
  /** Current or last-known position, as the screen says it attaches. */
  lat: z.number().min(-90).max(90).optional(),
  lng: z.number().min(-180).max(180).optional(),
});

export const incidentResponseSchema = z.object({
  id: z.string().uuid(),
  tripId: z.string().uuid().nullable(),
  vehicleId: z.string().uuid().nullable(),
  category: z.enum(INCIDENT_CATEGORIES),
  note: z.string().nullable(),
  lat: z.number().nullable(),
  lng: z.number().nullable(),
  status: z.enum(INCIDENT_STATUSES),
  resolution: z.string().nullable(),
  occurredAt: z.date(),
  createdAt: z.date(),
});

/** The ops view adds who filed it — the driver's own list already knows. */
export const adminIncidentResponseSchema = incidentResponseSchema.extend({
  driverId: z.string().uuid(),
  handledBy: z.string().uuid().nullable(),
  handledAt: z.date().nullable(),
});

export const listIncidentsQuerySchema = z.object({
  status: z.enum(INCIDENT_STATUSES).optional(),
});

export const decideIncidentBodySchema = z.object({
  /**
   * `open` is absent on purpose: this endpoint records that someone looked, and
   * reopening a report by PATCHing it back would erase who closed it and when.
   */
  status: z.enum(['acknowledged', 'resolved']),
  resolution: z.string().max(2000).optional(),
});
