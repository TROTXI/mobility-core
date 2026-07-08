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
 * The launch/session payload: the flag set plus the per-platform force-update
 * floor. A platform with no configured minimum is `null` (no force-update yet).
 */
export const flagsResponseSchema = z.object({
  flags: z.array(publicFlagSchema),
  minSupportedVersion: z.object({
    ios: z.string().nullable(),
    android: z.string().nullable(),
  }),
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
