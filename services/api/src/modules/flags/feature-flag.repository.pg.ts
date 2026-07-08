import type { Pool } from 'pg';
import { applyPatch } from '../../lib/patch';
import type {
  FeatureFlag,
  FeatureFlagRepository,
  FeatureFlagUpsert,
} from './feature-flag.repository';

interface FeatureFlagRow {
  key: string;
  enabled: boolean;
  rollout_percentage: number;
  description: string | null;
  updated_at: Date;
}

function toFlag(row: FeatureFlagRow): FeatureFlag {
  return {
    key: row.key,
    enabled: row.enabled,
    rolloutPercentage: row.rollout_percentage,
    description: row.description,
    updatedAt: row.updated_at,
  };
}

export class PgFeatureFlagRepository implements FeatureFlagRepository {
  constructor(private readonly pool: Pool) {}

  async findAll(): Promise<FeatureFlag[]> {
    const { rows } = await this.pool.query<FeatureFlagRow>(
      'SELECT * FROM feature_flags ORDER BY key',
    );
    return rows.map(toFlag);
  }

  async findByKey(key: string): Promise<FeatureFlag | null> {
    const { rows } = await this.pool.query<FeatureFlagRow>(
      'SELECT * FROM feature_flags WHERE key = $1',
      [key],
    );
    return rows[0] ? toFlag(rows[0]) : null;
  }

  async upsert(key: string, input: FeatureFlagUpsert): Promise<FeatureFlag> {
    // Merge the patch over the existing row (or the create defaults) so an
    // omitted field is left unchanged rather than reset to NULL/default.
    const existing = await this.findByKey(key);
    const next = existing
      ? applyPatch(existing, input)
      : {
          enabled: input.enabled ?? false,
          rolloutPercentage: input.rolloutPercentage ?? 100,
          description: input.description ?? null,
        };
    const { rows } = await this.pool.query<FeatureFlagRow>(
      `INSERT INTO feature_flags (key, enabled, rollout_percentage, description, updated_at)
       VALUES ($1, $2, $3, $4, now())
       ON CONFLICT (key) DO UPDATE
         SET enabled = EXCLUDED.enabled,
             rollout_percentage = EXCLUDED.rollout_percentage,
             description = EXCLUDED.description,
             updated_at = now()
       RETURNING *`,
      [key, next.enabled, next.rolloutPercentage, next.description],
    );
    return toFlag(rows[0]!);
  }
}
