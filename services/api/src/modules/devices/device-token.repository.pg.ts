import type { Pool } from 'pg';
import type { DevicePlatform, DeviceToken, DeviceTokenRepository } from './device-token.repository';

interface DeviceTokenRow {
  id: string;
  user_id: string;
  fcm_token: string;
  platform: DevicePlatform;
  created_at: Date;
  updated_at: Date;
}

function toDeviceToken(row: DeviceTokenRow): DeviceToken {
  return {
    id: row.id,
    userId: row.user_id,
    fcmToken: row.fcm_token,
    platform: row.platform,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export class PgDeviceTokenRepository implements DeviceTokenRepository {
  constructor(private readonly pool: Pool) {}

  async register(userId: string, fcmToken: string, platform: DevicePlatform): Promise<DeviceToken> {
    const { rows } = await this.pool.query<DeviceTokenRow>(
      `INSERT INTO device_tokens (user_id, fcm_token, platform)
       VALUES ($1, $2, $3)
       ON CONFLICT (fcm_token)
       DO UPDATE SET user_id = EXCLUDED.user_id, platform = EXCLUDED.platform, updated_at = now()
       RETURNING *`,
      [userId, fcmToken, platform],
    );
    return toDeviceToken(rows[0]!);
  }

  async removeByToken(fcmToken: string): Promise<void> {
    await this.pool.query(`DELETE FROM device_tokens WHERE fcm_token = $1`, [fcmToken]);
  }

  async listForUser(userId: string): Promise<DeviceToken[]> {
    const { rows } = await this.pool.query<DeviceTokenRow>(
      `SELECT * FROM device_tokens WHERE user_id = $1 ORDER BY updated_at DESC`,
      [userId],
    );
    return rows.map(toDeviceToken);
  }
}
