// Contract schemas for feature flags + minimum supported version (#27), rendered
// into the OpenAPI spec via the zod type provider (ADR-0008). The public GET
// /flags returns a slim shape (no ops-only fields); admin ops reuse the full row.

import { z } from 'zod';
import { APP_PLATFORMS } from './min-version.repository';

// --- public (GET /flags) ---

/** A single flag as the apps see it — no ops metadata (description/timestamps). */
export const publicFlagSchema = z.object({
  key: z.string(),
  enabled: z.boolean(),
  rolloutPercentage: z.number().int(),
});

/**
 * Where the clients fetch basemap tiles, and the credit they must display.
 *
 * Served from the API rather than compiled into each client on purpose (#178).
 * The bucket's public hostname is not portable — an `r2.dev` URL carries a
 * generated hash — so moving to a custom domain would otherwise mean shipping
 * new builds of the rider app, the driver app and the console. Here it is a
 * config change.
 *
 * `attribution` travels with the URL because it is a licence condition, not
 * decoration: OSM data is ODbL and the OpenMapTiles schema adds its own credit.
 * Keeping them together makes it hard to render the map without the notice.
 */
export const mapTilesSchema = z.object({
  /** PMTiles archive URL, or null when tiles are not configured. */
  url: z.string().nullable(),
  attribution: z.string(),
});

/**
 * The launch/session payload: the flag set, the per-platform force-update
 * floor, and the basemap config. A platform with no configured minimum is
 * `null` (no force-update yet).
 */
export const flagsResponseSchema = z.object({
  flags: z.array(publicFlagSchema),
  minSupportedVersion: z.object({
    ios: z.string().nullable(),
    android: z.string().nullable(),
  }),
  mapTiles: mapTilesSchema,
});

// --- admin (full rows) ---

/** The full flag row returned by admin ops. */
export const featureFlagResponseSchema = z.object({
  key: z.string(),
  enabled: z.boolean(),
  rolloutPercentage: z.number().int(),
  description: z.string().nullable(),
  updatedAt: z.date(),
});

/** A per-platform minimum version row returned by admin ops. */
export const minVersionResponseSchema = z.object({
  platform: z.enum(APP_PLATFORMS),
  version: z.string(),
  updatedAt: z.date(),
});
