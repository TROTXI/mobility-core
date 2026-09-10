// Postgres {@link DriverCredentialRepository} (#223). Network adapter: excluded
// from unit coverage like the other *.pg.ts files, exercised by the e2e suite.

import type { Pool } from 'pg';
import type {
  DriverCredential,
  DriverCredentialRepository,
  DriverCredentialStatus,
  NewDriverCredential,
} from './driver-credential.repository';

interface DriverCredentialRow {
  id: string;
  driver_id: string;
  driver_code: string;
  pin_hash: string;
  pin_set_at: Date;
  must_change_pin: boolean;
  failed_attempts: number;
  locked_until: Date | null;
  status: DriverCredentialStatus;
  created_at: Date;
  updated_at: Date;
}

/**
 * Map a row to the domain shape.
 *
 * @param row - the database row.
 * @returns the credential.
 */
function toCredential(row: DriverCredentialRow): DriverCredential {
  return {
    id: row.id,
    driverId: row.driver_id,
    driverCode: row.driver_code,
    pinHash: row.pin_hash,
    pinSetAt: row.pin_set_at,
    mustChangePin: row.must_change_pin,
    failedAttempts: row.failed_attempts,
    lockedUntil: row.locked_until,
    status: row.status,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export class PgDriverCredentialRepository implements DriverCredentialRepository {
  constructor(private readonly pool: Pool) {}

  async create(input: NewDriverCredential): Promise<DriverCredential> {
    const { rows } = await this.pool.query<DriverCredentialRow>(
      `INSERT INTO driver_credentials (driver_id, driver_code, pin_hash)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [input.driverId, input.driverCode, input.pinHash],
    );
    return toCredential(rows[0]!);
  }

  async findByCode(driverCode: string): Promise<DriverCredential | null> {
    const { rows } = await this.pool.query<DriverCredentialRow>(
      'SELECT * FROM driver_credentials WHERE driver_code = $1',
      [driverCode],
    );
    return rows[0] ? toCredential(rows[0]) : null;
  }

  async findByDriverId(driverId: string): Promise<DriverCredential | null> {
    const { rows } = await this.pool.query<DriverCredentialRow>(
      'SELECT * FROM driver_credentials WHERE driver_id = $1',
      [driverId],
    );
    return rows[0] ? toCredential(rows[0]) : null;
  }

  async setPin(
    id: string,
    patch: { pinHash: string; mustChangePin: boolean },
  ): Promise<DriverCredential | null> {
    // Clearing the lock here is deliberate: an ops reset is the documented way
    // out of a lockout (frame 06's "Request a new PIN"), so setting a PIN has
    // to release it or the driver is still stuck with a code that now works.
    const { rows } = await this.pool.query<DriverCredentialRow>(
      `UPDATE driver_credentials
          SET pin_hash        = $2,
              must_change_pin = $3,
              pin_set_at      = now(),
              failed_attempts = 0,
              locked_until    = NULL,
              updated_at      = now()
        WHERE id = $1
        RETURNING *`,
      [id, patch.pinHash, patch.mustChangePin],
    );
    return rows[0] ? toCredential(rows[0]) : null;
  }

  async recordFailure(
    id: string,
    lockAfter: number,
    lockFor: number,
  ): Promise<DriverCredential | null> {
    // Counted and judged in ONE statement. Read-then-write would let two
    // concurrent guesses both read the same count and both write it back as
    // one, which is exactly the race a brute-force script produces.
    const { rows } = await this.pool.query<DriverCredentialRow>(
      `UPDATE driver_credentials
          SET failed_attempts = failed_attempts + 1,
              locked_until    = CASE
                                  WHEN failed_attempts + 1 >= $2
                                  THEN now() + make_interval(secs => $3::double precision)
                                  ELSE locked_until
                                END,
              updated_at      = now()
        WHERE id = $1
        RETURNING *`,
      [id, lockAfter, lockFor / 1000],
    );
    return rows[0] ? toCredential(rows[0]) : null;
  }

  async clearFailures(id: string): Promise<DriverCredential | null> {
    const { rows } = await this.pool.query<DriverCredentialRow>(
      `UPDATE driver_credentials
          SET failed_attempts = 0, locked_until = NULL, updated_at = now()
        WHERE id = $1
        RETURNING *`,
      [id],
    );
    return rows[0] ? toCredential(rows[0]) : null;
  }

  async setStatus(id: string, status: DriverCredentialStatus): Promise<DriverCredential | null> {
    const { rows } = await this.pool.query<DriverCredentialRow>(
      `UPDATE driver_credentials
          SET status = $2, updated_at = now()
        WHERE id = $1
        RETURNING *`,
      [id, status],
    );
    return rows[0] ? toCredential(rows[0]) : null;
  }
}
