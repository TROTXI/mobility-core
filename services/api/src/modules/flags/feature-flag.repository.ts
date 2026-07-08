// Feature-flag repository (#27) — the "deploy != release" keystone for the pilot.
// A flag is a keyed switch the apps read on launch via GET /flags: `enabled` is
// the kill-switch and `rolloutPercentage` is %-rollout-ready (returned as-is; a
// real cohort/bucketing evaluator lands with PostHog). Repository pattern
// (ADR-0009): interface + InMemory here, Postgres in *.pg.ts.

import { applyPatch } from '../../lib/patch';

/** A feature flag: a keyed kill-switch with a rollout percentage. */
export interface FeatureFlag {
  /** Stable identifier the apps gate on, e.g. "live_positions". */
  key: string;
  /** The kill-switch — false hides the feature regardless of rollout. */
  enabled: boolean;
  /** 0–100. Returned as-is; per-user bucketing is a later (PostHog) concern. */
  rolloutPercentage: number;
  /** Ops note; not surfaced to the apps. */
  description: string | null;
  updatedAt: Date;
}

/**
 * Editable flag fields for an upsert (admin, #27). All optional — on create,
 * omitted fields fall back to defaults (disabled, 100% rollout, no description);
 * on update, the patch merges over the existing row (omitted = unchanged).
 */
export interface FeatureFlagUpsert {
  enabled?: boolean;
  rolloutPercentage?: number;
  description?: string | null;
}

/** Persistence for feature flags (Postgres in prod, in-memory in dev/tests). */
export interface FeatureFlagRepository {
  /** Returns every flag, ordered by key. Read by GET /flags and admin ops. */
  findAll(): Promise<FeatureFlag[]>;
  /**
   * Look up a single flag by key.
   *
   * @param key - the flag key.
   * @returns the flag, or null if it doesn't exist.
   */
  findByKey(key: string): Promise<FeatureFlag | null>;
  /**
   * Create or update a flag by key (idempotent — the app's kill-switch).
   *
   * @param key - the flag key.
   * @param input - the fields to set; omitted fields default (create) or are
   *   left unchanged (update).
   * @returns the persisted flag.
   */
  upsert(key: string, input: FeatureFlagUpsert): Promise<FeatureFlag>;
}

/**
 * Build a fresh flag row from an upsert input, applying the create defaults.
 *
 * @param key - the flag key.
 * @param input - the fields provided on create; omitted fields default.
 * @returns the new flag row.
 */
function newFlag(key: string, input: FeatureFlagUpsert): FeatureFlag {
  return {
    key,
    enabled: input.enabled ?? false,
    rolloutPercentage: input.rolloutPercentage ?? 100,
    description: input.description ?? null,
    updatedAt: new Date(),
  };
}

/** In-memory {@link FeatureFlagRepository} for dev and unit tests. */
export class InMemoryFeatureFlagRepository implements FeatureFlagRepository {
  private readonly flags = new Map<string, FeatureFlag>();

  async findAll(): Promise<FeatureFlag[]> {
    return [...this.flags.values()].sort((a, b) => a.key.localeCompare(b.key));
  }

  async findByKey(key: string): Promise<FeatureFlag | null> {
    return this.flags.get(key) ?? null;
  }

  async upsert(key: string, input: FeatureFlagUpsert): Promise<FeatureFlag> {
    const existing = this.flags.get(key);
    const flag: FeatureFlag = existing
      ? { ...applyPatch(existing, input), updatedAt: new Date() }
      : newFlag(key, input);
    this.flags.set(key, flag);
    return flag;
  }
}
