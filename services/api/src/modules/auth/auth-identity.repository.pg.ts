import type { Pool } from 'pg';
import type {
  AuthIdentity,
  AuthIdentityRepository,
  NewAuthIdentity,
} from './auth-identity.repository';
import type { AuthProvider } from './id-token-verifier';

interface AuthIdentityRow {
  id: string;
  user_id: string;
  provider: AuthProvider;
  provider_id: string;
  provider_refresh_token: string | null;
  created_at: Date;
}

function toAuthIdentity(row: AuthIdentityRow): AuthIdentity {
  return {
    id: row.id,
    userId: row.user_id,
    provider: row.provider,
    providerId: row.provider_id,
    providerRefreshToken: row.provider_refresh_token,
    createdAt: row.created_at,
  };
}

export class PgAuthIdentityRepository implements AuthIdentityRepository {
  constructor(private readonly pool: Pool) {}

  async findByProvider(provider: AuthProvider, providerId: string): Promise<AuthIdentity | null> {
    const { rows } = await this.pool.query<AuthIdentityRow>(
      `SELECT * FROM auth_identity WHERE provider = $1 AND provider_id = $2`,
      [provider, providerId],
    );
    return rows[0] ? toAuthIdentity(rows[0]) : null;
  }

  async create(input: NewAuthIdentity): Promise<AuthIdentity> {
    const { rows } = await this.pool.query<AuthIdentityRow>(
      `INSERT INTO auth_identity (user_id, provider, provider_id, provider_refresh_token)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [input.userId, input.provider, input.providerId, input.providerRefreshToken ?? null],
    );
    return toAuthIdentity(rows[0]!);
  }

  async deleteForUser(userId: string): Promise<void> {
    await this.pool.query('DELETE FROM auth_identity WHERE user_id = $1', [userId]);
  }

  async listForUser(userId: string): Promise<AuthIdentity[]> {
    const { rows } = await this.pool.query<AuthIdentityRow>(
      'SELECT * FROM auth_identity WHERE user_id = $1',
      [userId],
    );
    return rows.map(toAuthIdentity);
  }

  async saveRefreshToken(id: string, refreshToken: string): Promise<void> {
    await this.pool.query('UPDATE auth_identity SET provider_refresh_token = $2 WHERE id = $1', [
      id,
      refreshToken,
    ]);
  }
}
