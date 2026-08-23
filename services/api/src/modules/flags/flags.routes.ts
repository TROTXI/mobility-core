// Public feature-flags endpoint (#27) — the "deploy != release" keystone. The
// apps fetch GET /flags on launch/session to gate features (kill-switch +
// %-rollout) and to run their force-update check (min_supported_version per
// platform). Intentionally public and un-throttled, like GET /routes: it must
// answer before a user signs in, and it degrades gracefully (empty set) when the
// stores are unwired so the app can always boot.

import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import type { FeatureFlagRepository } from './feature-flag.repository';
import type { MinVersionRepository } from './min-version.repository';
import { flagsResponseSchema } from './flags.schema';

/**
 * Credit required by the data licences, shown on every surface that renders a
 * map. Two parties, not one: the underlying data is OpenStreetMap (ODbL) and
 * the tiles are built with the OpenMapTiles schema, whose CC-BY grant carries
 * its own visible-credit condition.
 */
const MAP_ATTRIBUTION = '© OpenStreetMap contributors · © OpenMapTiles';

/**
 * Register the public flags route (`GET /flags`).
 *
 * @param app - the Fastify instance to register on.
 * @param opts - route dependencies (both optional; absent -> empty payload).
 * @param opts.featureFlags - the feature-flag repository.
 * @param opts.minVersions - the minimum-supported-version repository.
 * @param opts.mapTilesUrl - public PMTiles archive URL (#178); absent -> null,
 *   and clients render without a basemap rather than failing.
 */
export async function flagsRoutes(
  app: FastifyInstance,
  opts: {
    featureFlags?: FeatureFlagRepository;
    minVersions?: MinVersionRepository;
    mapTilesUrl?: string;
  },
): Promise<void> {
  app.withTypeProvider<ZodTypeProvider>().get(
    '/flags',
    {
      schema: {
        tags: ['flags'],
        summary: 'Feature flags + minimum supported app version (fetched on launch)',
        response: { 200: flagsResponseSchema },
      },
    },
    async () => {
      const flags = opts.featureFlags ? await opts.featureFlags.findAll() : [];
      const versions = opts.minVersions ? await opts.minVersions.findAll() : [];

      const minSupportedVersion: { ios: string | null; android: string | null } = {
        ios: null,
        android: null,
      };
      for (const v of versions) {
        minSupportedVersion[v.platform] = v.version;
      }

      return {
        flags: flags.map((f) => ({
          key: f.key,
          enabled: f.enabled,
          rolloutPercentage: f.rolloutPercentage,
        })),
        minSupportedVersion,
        mapTiles: {
          url: opts.mapTilesUrl ?? null,
          attribution: MAP_ATTRIBUTION,
        },
      };
    },
  );
}
