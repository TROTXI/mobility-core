import type { Pool } from 'pg';
import type { NewUser, User, UserRepository, UserRole } from './user.repository';

interface UserRow {
  id: string;
  display_name: string;
  phone: string | null;
  avatar_url: string | null;
  role: UserRole;
  created_at: Date;
}

function toUser(row: UserRow): User {
  return {
    id: row.id,
    displayName: row.display_name,
    phone: row.phone,
    avatarUrl: row.avatar_url,
    role: row.role,
    createdAt: row.created_at,
  };
}

export class PgUserRepository implements UserRepository {
  constructor(private readonly pool: Pool) {}

  async create(input: NewUser): Promise<User> {
    const { rows } = await this.pool.query<UserRow>(
      `INSERT INTO users (display_name, phone, role)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [input.displayName, input.phone ?? null, input.role ?? 'commuter'],
    );
    return toUser(rows[0]!);
  }

  async findById(id: string): Promise<User | null> {
    const { rows } = await this.pool.query<UserRow>('SELECT * FROM users WHERE id = $1', [id]);
    return rows[0] ? toUser(rows[0]) : null;
  }
}
