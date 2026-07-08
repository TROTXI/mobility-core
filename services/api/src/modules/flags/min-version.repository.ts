// Minimum-supported-version repository (#27) — the apps' force-update floor.
// One row per platform holding the lowest app build the API still supports; the
// apps compare their version against it on launch (via GET /flags) and force an
// update below it. Repository pattern (ADR-0009): interface + InMemory here,
// Postgres in *.pg.ts.

/** App platforms that carry a minimum supported version. */
export const APP_PLATFORMS = ['ios', 'android'] as const;
export type AppPlatform = (typeof APP_PLATFORMS)[number];

/** The minimum supported app version for one platform. */
export interface MinVersion {
  platform: AppPlatform;
  /** Semver string, e.g. "1.2.0". Opaque to the API — the apps compare it. */
  version: string;
  updatedAt: Date;
}

/** Persistence for per-platform minimum versions (Postgres in prod, in-memory in dev/tests). */
export interface MinVersionRepository {
  /** Returns the minimum version for every configured platform. */
  findAll(): Promise<MinVersion[]>;
  /**
   * Look up the minimum version for a platform.
   *
   * @param platform - the app platform.
   * @returns the row, or null if none is configured yet.
   */
  get(platform: AppPlatform): Promise<MinVersion | null>;
  /**
   * Set (create or replace) the minimum version for a platform.
   *
   * @param platform - the app platform.
   * @param version - the new minimum version.
   * @returns the persisted row.
   */
  set(platform: AppPlatform, version: string): Promise<MinVersion>;
}

/** In-memory {@link MinVersionRepository} for dev and unit tests. */
export class InMemoryMinVersionRepository implements MinVersionRepository {
  private readonly versions = new Map<AppPlatform, MinVersion>();

  async findAll(): Promise<MinVersion[]> {
    return [...this.versions.values()].sort((a, b) => a.platform.localeCompare(b.platform));
  }

  async get(platform: AppPlatform): Promise<MinVersion | null> {
    return this.versions.get(platform) ?? null;
  }

  async set(platform: AppPlatform, version: string): Promise<MinVersion> {
    const row: MinVersion = { platform, version, updatedAt: new Date() };
    this.versions.set(platform, row);
    return row;
  }
}
