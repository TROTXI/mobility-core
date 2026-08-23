import type { Pool } from 'pg';
import {
  ANONYMISED_DISPLAY_NAME,
  type NewUser,
  type User,
  type UserRepository,
  type UserRole,
} from './user.repository';

interface UserRow {
  id: string;
  display_name: string;
  deleted_at: Date | null;
  email: string | null;
  phone: string | null;
  avatar_url: string | null;
  role: UserRole;
  created_at: Date;
}

function toUser(row: UserRow): User {
  return {
    id: row.id,
    displayName: row.display_name,
    deletedAt: row.deleted_at,
    email: row.email,
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
      `INSERT INTO users (display_name, email, phone, role)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [input.displayName, input.email ?? null, input.phone ?? null, input.role ?? 'commuter'],
    );
    return toUser(rows[0]!);
  }

  async findById(id: string): Promise<User | null> {
    const { rows } = await this.pool.query<UserRow>('SELECT * FROM users WHERE id = $1', [id]);
    return rows[0] ? toUser(rows[0]) : null;
  }

  async updateProfile(id: string, patch: { displayName: string }): Promise<User | null> {
    const { rows } = await this.pool.query<UserRow>(
      `UPDATE users SET display_name = $2, updated_at = now() WHERE id = $1 RETURNING *`,
      [id, patch.displayName],
    );
    return rows[0] ? toUser(rows[0]) : null;
  }

  async setAvatarKey(id: string, key: string | null): Promise<User | null> {
    const { rows } = await this.pool.query<UserRow>(
      `UPDATE users SET avatar_url = $2, updated_at = now() WHERE id = $1 RETURNING *`,
      [id, key],
    );
    return rows[0] ? toUser(rows[0]) : null;
  }

  async setRole(id: string, role: UserRole): Promise<User | null> {
    const { rows } = await this.pool.query<UserRow>(
      `UPDATE users SET role = $2, updated_at = now() WHERE id = $1 RETURNING *`,
      [id, role],
    );
    return rows[0] ? toUser(rows[0]) : null;
  }

  async backfillContact(
    id: string,
    contact: { email?: string | null; phone?: string | null },
  ): Promise<User | null> {
    // COALESCE keeps whatever is already stored: a webhook must never overwrite
    // a number the rider has since corrected on their profile. Writing the same
    // value twice is therefore a no-op, which is what makes Paystack's webhook
    // re-delivery safe.
    const { rows } = await this.pool.query<UserRow>(
      `UPDATE users
          SET email      = COALESCE(email, $2),
              phone      = COALESCE(phone, $3),
              updated_at = now()
        WHERE id = $1
        RETURNING *`,
      [id, contact.email ?? null, contact.phone ?? null],
    );
    return rows[0] ? toUser(rows[0]) : null;
  }

  async anonymise(id: string): Promise<User | null> {
    // COALESCE on deleted_at keeps the FIRST deletion timestamp, so a retried
    // request does not rewrite when the erasure actually happened.
    const { rows } = await this.pool.query<UserRow>(
      `UPDATE users
          SET display_name = $2,
              email        = NULL,
              phone        = NULL,
              avatar_url   = NULL,
              deleted_at   = COALESCE(deleted_at, now()),
              updated_at   = now()
        WHERE id = $1
        RETURNING *`,
      [id, ANONYMISED_DISPLAY_NAME],
    );
    return rows[0] ? toUser(rows[0]) : null;
  }
}
