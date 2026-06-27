import type { Pool } from 'pg';
import type { NewSession, Session, SessionRepository } from './session.repository';

interface SessionRow {
  id: string;
  user_id: string;
  refresh_token_hash: string;
  expires_at: Date;
  revoked_at: Date | null;
  rotated_from: string | null;
  created_at: Date;
}

function toSession(row: SessionRow): Session {
  return {
    id: row.id,
    userId: row.user_id,
    refreshTokenHash: row.refresh_token_hash,
    expiresAt: row.expires_at,
    revokedAt: row.revoked_at,
    rotatedFrom: row.rotated_from,
    createdAt: row.created_at,
  };
}

export class PgSessionRepository implements SessionRepository {
  constructor(private readonly pool: Pool) {}

  async create(input: NewSession): Promise<Session> {
    const { rows } = await this.pool.query<SessionRow>(
      `INSERT INTO sessions (user_id, refresh_token_hash, expires_at, rotated_from)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [input.userId, input.refreshTokenHash, input.expiresAt, input.rotatedFrom ?? null],
    );
    return toSession(rows[0]!);
  }

  async findByHash(refreshTokenHash: string): Promise<Session | null> {
    const { rows } = await this.pool.query<SessionRow>(
      `SELECT * FROM sessions WHERE refresh_token_hash = $1`,
      [refreshTokenHash],
    );
    return rows[0] ? toSession(rows[0]) : null;
  }

  async revoke(id: string): Promise<void> {
    await this.pool.query(
      `UPDATE sessions SET revoked_at = now() WHERE id = $1 AND revoked_at IS NULL`,
      [id],
    );
  }
}
