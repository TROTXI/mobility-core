import type { Pool } from 'pg';
import type {
  Reservation,
  ReservationDirection,
  ReservationRepository,
  ReservationResponse,
  ReservationStatus,
  ReservationSource,
  PendingReservation,
} from './reservation.repository';

interface ReservationRow {
  id: string;
  user_id: string;
  trip_id: string | null;
  travel_date: string; // pg returns DATE as 'YYYY-MM-DD'
  direction: ReservationDirection;
  status: ReservationStatus;
  source: ReservationSource;
  daily_pin_hash: string | null;
  confirmed_at: Date | null;
  created_at: Date;
  updated_at: Date;
}

function toReservation(row: ReservationRow): Reservation {
  return {
    id: row.id,
    userId: row.user_id,
    tripId: row.trip_id,
    travelDate: row.travel_date,
    direction: row.direction,
    status: row.status,
    source: row.source,
    pinHash: row.daily_pin_hash,
    confirmedAt: row.confirmed_at,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export class PgReservationRepository implements ReservationRepository {
  constructor(private readonly pool: Pool) {}

  async respond(input: ReservationResponse): Promise<Reservation> {
    const status: ReservationStatus = input.travelling ? 'reserved' : 'declined';
    const { rows } = await this.pool.query<ReservationRow>(
      `INSERT INTO reservations (user_id, trip_id, travel_date, direction, status, source, daily_pin_hash, confirmed_at)
       VALUES ($1, $2, $3, $4, $5, 'confirmation', $6, now())
       ON CONFLICT (user_id, travel_date, direction)
       DO UPDATE SET trip_id = COALESCE(EXCLUDED.trip_id, reservations.trip_id),
                     status = EXCLUDED.status,
                     source = 'confirmation',
                     daily_pin_hash = EXCLUDED.daily_pin_hash,
                     confirmed_at = now(),
                     updated_at = now()
       RETURNING *`,
      [
        input.userId,
        input.tripId ?? null,
        input.travelDate,
        input.direction,
        status,
        input.pinHash ?? null,
      ],
    );
    return toReservation(rows[0]!);
  }

  async createPending(input: PendingReservation): Promise<Reservation> {
    const { rows } = await this.pool.query<ReservationRow>(
      `INSERT INTO reservations (user_id, trip_id, travel_date, direction, status, source)
       VALUES ($1, $2, $3, $4, 'pending', 'confirmation')
       ON CONFLICT (user_id, travel_date, direction) DO UPDATE SET updated_at = reservations.updated_at
       RETURNING *`,
      [input.userId, input.tripId ?? null, input.travelDate, input.direction],
    );
    return toReservation(rows[0]!);
  }

  async markDefaultTravelling(
    travelDate: string,
    direction: ReservationDirection,
  ): Promise<number> {
    const { rowCount } = await this.pool.query(
      `UPDATE reservations
         SET status = 'reserved', source = 'default', confirmed_at = now(), updated_at = now()
       WHERE travel_date = $1 AND direction = $2 AND status = 'pending'`,
      [travelDate, direction],
    );
    return rowCount ?? 0;
  }

  async listForUser(userId: string, opts?: { fromDate?: string }): Promise<Reservation[]> {
    const { rows } = await this.pool.query<ReservationRow>(
      `SELECT * FROM reservations
       WHERE user_id = $1 AND ($2::date IS NULL OR travel_date >= $2::date)
       ORDER BY travel_date DESC, direction`,
      [userId, opts?.fromDate ?? null],
    );
    return rows.map(toReservation);
  }

  async find(
    userId: string,
    travelDate: string,
    direction: ReservationDirection,
  ): Promise<Reservation | null> {
    const { rows } = await this.pool.query<ReservationRow>(
      `SELECT * FROM reservations WHERE user_id = $1 AND travel_date = $2 AND direction = $3`,
      [userId, travelDate, direction],
    );
    return rows[0] ? toReservation(rows[0]) : null;
  }

  async findBoardable(userId: string, travelDate: string): Promise<Reservation | null> {
    // Earliest still-open leg (morning before evening — explicit, not
    // alphabetical); boarded seats excluded.
    const { rows } = await this.pool.query<ReservationRow>(
      `SELECT * FROM reservations
       WHERE user_id = $1 AND travel_date = $2 AND status = 'reserved'
       ORDER BY CASE direction WHEN 'morning' THEN 0 ELSE 1 END
       LIMIT 1`,
      [userId, travelDate],
    );
    return rows[0] ? toReservation(rows[0]) : null;
  }

  async markBoarded(id: string): Promise<Reservation | null> {
    const { rows } = await this.pool.query<ReservationRow>(
      `UPDATE reservations SET status = 'boarded', updated_at = now() WHERE id = $1 RETURNING *`,
      [id],
    );
    return rows[0] ? toReservation(rows[0]) : null;
  }

  /** Still-`reserved` reservations for a day+direction (no-show candidates, E4). */
  async listReserved(travelDate: string, direction: ReservationDirection): Promise<Reservation[]> {
    const { rows } = await this.pool.query<ReservationRow>(
      `SELECT * FROM reservations
       WHERE travel_date = $1 AND direction = $2 AND status = 'reserved'`,
      [travelDate, direction],
    );
    return rows.map(toReservation);
  }

  /** Mark a reservation `no_show` (caller deducts the ride, E4). */
  async markNoShow(id: string): Promise<Reservation | null> {
    const { rows } = await this.pool.query<ReservationRow>(
      `UPDATE reservations SET status = 'no_show', updated_at = now() WHERE id = $1 RETURNING *`,
      [id],
    );
    return rows[0] ? toReservation(rows[0]) : null;
  }

  async listForTrip(tripId: string): Promise<Reservation[]> {
    const { rows } = await this.pool.query<ReservationRow>(
      `SELECT * FROM reservations WHERE trip_id = $1
       ORDER BY CASE direction WHEN 'morning' THEN 0 ELSE 1 END`,
      [tripId],
    );
    return rows.map(toReservation);
  }

  async findById(id: string): Promise<Reservation | null> {
    const { rows } = await this.pool.query<ReservationRow>(
      'SELECT * FROM reservations WHERE id = $1',
      [id],
    );
    return rows[0] ? toReservation(rows[0]) : null;
  }
}
