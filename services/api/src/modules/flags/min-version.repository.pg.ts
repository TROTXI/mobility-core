import type { Pool } from 'pg';
import type { AppPlatform, MinVersion, MinVersionRepository } from './min-version.repository';

interface MinVersionRow {
  platform: AppPlatform;
  version: string;
  updated_at: Date;
}

function toMinVersion(row: MinVersionRow): MinVersion {
  return {
    platform: row.platform,
    version: row.version,
    updatedAt: row.updated_at,
  };
}

export class PgMinVersionRepository implements MinVersionRepository {
  constructor(private readonly pool: Pool) {}

  async findAll(): Promise<MinVersion[]> {
    const { rows } = await this.pool.query<MinVersionRow>(
      'SELECT * FROM app_min_versions ORDER BY platform',
    );
    return rows.map(toMinVersion);
  }

  async get(platform: AppPlatform): Promise<MinVersion | null> {
    const { rows } = await this.pool.query<MinVersionRow>(
      'SELECT * FROM app_min_versions WHERE platform = $1',
      [platform],
    );
    return rows[0] ? toMinVersion(rows[0]) : null;
  }

  async set(platform: AppPlatform, version: string): Promise<MinVersion> {
    const { rows } = await this.pool.query<MinVersionRow>(
      `INSERT INTO app_min_versions (platform, version, updated_at)
       VALUES ($1, $2, now())
       ON CONFLICT (platform) DO UPDATE
         SET version = EXCLUDED.version, updated_at = now()
       RETURNING *`,
      [platform, version],
    );
    return toMinVersion(rows[0]!);
  }
}
