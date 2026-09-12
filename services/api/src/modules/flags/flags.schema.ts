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
 * Basemap tiles, served from the API rather than compiled into clients (#178) so
 * changing the host is config rather than three app releases.
 *
 * `attribution` travels with the URL because it is a licence condition (ODbL +
 * OpenMapTiles), not decoration.
 */
export const mapTilesSchema = z.object({
  /** PMTiles archive URL, or null when tiles are not configured. */
  url: z.string().nullable(),
  /**
   * MapLibre style for the light theme, or null when unconfigured. Served here
   * for the same reason as `url`: the rider app, the driver app and the ops
   * console all draw the same basemap, and a restyle should be a config change
   * rather than three releases.
   */
  styleUrl: z.string().nullable(),
  /** The dark-theme style. Every screen in the designs has a dark variant. */
  darkStyleUrl: z.string().nullable(),
  attribution: z.string(),
});

/**
 * How to reach operations (#234) — the control room, and the number behind the
 * design's EMERGENCY HELP control.
 *
 * Here rather than in the app bundle for the reason the map styles are here:
 * depots differ, and a number compiled into a shipped build is worse than none.
 * A driver at a roadside dialling a line that no longer answers is the precise
 * failure this exists to prevent, and a change becomes config rather than three
 * app releases.
 *
 * Read before sign-in on purpose. "Can't sign in?" is the screen that needs it
 * most, because PIN recovery runs through a person — `drivers.phone` is
 * nullable, so there is no verified channel to send a reset to.
 *
 * The configured form (every field optional) as the app and server pass it
 * around, separate from the response shape above, where absent means `null`.
 */
export interface OperationsContact {
  phone?: string;
  whatsapp?: string;
  email?: string;
  hours?: string;
}

export const operationsContactSchema = z.object({
  /** Dialled directly, so E.164 (`+233…`). Null when unconfigured. */
  phone: z.string().nullable(),
  /** Often the line that actually gets answered in a depot. */
  whatsapp: z.string().nullable(),
  email: z.string().nullable(),
  /** Free text, e.g. "05:00-22:00 daily". */
  hours: z.string().nullable(),
});

/**
 * The launch/session payload: the flag set, the per-platform force-update
 * floor, the basemap config, and how to reach operations. A platform with no
 * configured minimum is `null` (no force-update yet).
 */
export const flagsResponseSchema = z.object({
  flags: z.array(publicFlagSchema),
  minSupportedVersion: z.object({
    ios: z.string().nullable(),
    android: z.string().nullable(),
  }),
  mapTiles: mapTilesSchema,
  operations: operationsContactSchema,
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
