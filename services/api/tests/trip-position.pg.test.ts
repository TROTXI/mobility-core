import { Pool } from 'pg';
import { describe, expect, it } from 'vitest';
import { PgTripPositionRepository } from '../src/modules/mobility/trip-position.repository.pg';
import { PgTripRepository } from '../src/modules/mobility/trip.repository.pg';

const databaseUrl = process.env['DATABASE_URL'];
const withPostgres = databaseUrl ? describe : describe.skip;

withPostgres('PgTripPositionRepository capture time and replay idempotency', () => {
  it('stores delayed fixes once and keeps the newest captured fix live', async () => {
    const pool = new Pool({ connectionString: databaseUrl, max: 1 });
    const routeId = crypto.randomUUID();
    const tripId = crypto.randomUUID();
    const laterFixId = crypto.randomUUID();
    const olderFixId = crypto.randomUUID();
    try {
      await pool.query('INSERT INTO routes (id, name) VALUES ($1, $2)', [
        routeId,
        'GPS test route',
      ]);
      await pool.query(
        `INSERT INTO trips (id, route_id, status, scheduled_at, started_at)
         VALUES ($1, $2, 'active', $3, $3)`,
        [tripId, routeId, new Date('2026-09-14T10:00:00.000Z')],
      );
      const positions = new PgTripPositionRepository(pool);
      const trips = new PgTripRepository(pool);
      const later = await positions.record({
        tripId,
        latitude: 5.6,
        longitude: -0.19,
        recordedAt: new Date('2026-09-14T10:02:00.000Z'),
        clientFixId: laterFixId,
      });
      const replay = await positions.record({
        tripId,
        latitude: 9,
        longitude: 9,
        recordedAt: new Date('2026-09-14T10:03:00.000Z'),
        clientFixId: laterFixId,
      });
      await positions.record({
        tripId,
        latitude: 5.59,
        longitude: -0.2,
        recordedAt: new Date('2026-09-14T10:01:00.000Z'),
        clientFixId: olderFixId,
      });

      expect(replay).toEqual(later);
      expect(later.receivedAt).toBeInstanceOf(Date);
      expect((await positions.findLatest(tripId))?.clientFixId).toBe(laterFixId);
      expect((await positions.findAllForTrip(tripId)).map((fix) => fix.clientFixId)).toEqual([
        olderFixId,
        laterFixId,
      ]);
      expect(
        (
          await pool.query('SELECT count(*)::int AS count FROM trip_positions WHERE trip_id = $1', [
            tripId,
          ])
        ).rows[0],
      ).toEqual({ count: 2 });

      expect(
        (await trips.updateIfStatus(tripId, 'active', { currentStopSeq: 0 }))?.currentStopSeq,
      ).toBe(0);
      await pool.query("UPDATE trips SET status = 'completed' WHERE id = $1", [tripId]);
      expect(await trips.updateIfStatus(tripId, 'active', { currentStopSeq: 1 })).toBeNull();
      await expect(
        positions.record({
          tripId,
          latitude: 5.61,
          longitude: -0.18,
          clientFixId: crypto.randomUUID(),
        }),
      ).rejects.toMatchObject({ name: 'InactiveTripPositionError' });
      expect(
        (
          await pool.query('SELECT count(*)::int AS count FROM trip_positions WHERE trip_id = $1', [
            tripId,
          ])
        ).rows[0],
      ).toEqual({ count: 2 });
    } finally {
      await pool.query('DELETE FROM routes WHERE id = $1', [routeId]);
      await pool.end();
    }
  });
});
