import type { Pool } from 'pg';
import type { NewVehicle, Vehicle, VehicleRepository } from './vehicle.repository';

interface VehicleRow {
  id: string;
  registration: string;
  label: string | null;
  capacity: number;
  created_at: Date;
}

function toVehicle(row: VehicleRow): Vehicle {
  return {
    id: row.id,
    registration: row.registration,
    label: row.label,
    capacity: row.capacity,
    createdAt: row.created_at,
  };
}

export class PgVehicleRepository implements VehicleRepository {
  constructor(private readonly pool: Pool) {}

  async create(input: NewVehicle): Promise<Vehicle> {
    const { rows } = await this.pool.query<VehicleRow>(
      `INSERT INTO vehicles (registration, label, capacity)
       VALUES ($1, $2, $3) RETURNING *`,
      [input.registration, input.label ?? null, input.capacity ?? 0],
    );
    return toVehicle(rows[0]!);
  }

  async findById(id: string): Promise<Vehicle | null> {
    const { rows } = await this.pool.query<VehicleRow>('SELECT * FROM vehicles WHERE id = $1', [
      id,
    ]);
    return rows[0] ? toVehicle(rows[0]) : null;
  }
}
