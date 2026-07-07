import type { Pool } from 'pg';
import type { Driver, DriverRepository, NewDriver } from './driver.repository';

interface DriverRow {
  id: string;
  full_name: string;
  phone: string | null;
  license_number: string | null;
  user_id: string | null;
  created_at: Date;
}

function toDriver(row: DriverRow): Driver {
  return {
    id: row.id,
    fullName: row.full_name,
    phone: row.phone,
    licenseNumber: row.license_number,
    userId: row.user_id,
    createdAt: row.created_at,
  };
}

export class PgDriverRepository implements DriverRepository {
  constructor(private readonly pool: Pool) {}

  async create(input: NewDriver): Promise<Driver> {
    const { rows } = await this.pool.query<DriverRow>(
      `INSERT INTO drivers (full_name, phone, license_number, user_id)
       VALUES ($1, $2, $3, $4) RETURNING *`,
      [input.fullName, input.phone ?? null, input.licenseNumber ?? null, input.userId ?? null],
    );
    return toDriver(rows[0]!);
  }

  async findById(id: string): Promise<Driver | null> {
    const { rows } = await this.pool.query<DriverRow>('SELECT * FROM drivers WHERE id = $1', [id]);
    return rows[0] ? toDriver(rows[0]) : null;
  }
}
