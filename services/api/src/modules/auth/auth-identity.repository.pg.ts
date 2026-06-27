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
  created_at: Date;
}

function toAuthIdentity(row: AuthIdentityRow): AuthIdentity {
  return {
    id: row.id,
    userId: row.user_id,
    provider: row.provider,
    providerId: row.provider_id,
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
      `INSERT INTO auth_identity (user_id, provider, provider_id)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [input.userId, input.provider, input.providerId],
    );
    return toAuthIdentity(rows[0]!);
  }
}
