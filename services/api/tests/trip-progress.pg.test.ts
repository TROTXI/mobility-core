import { readFile } from 'node:fs/promises';
import { Client } from 'pg';
import { describe, expect, it } from 'vitest';

const databaseUrl = process.env['DATABASE_URL'];
const withPostgres = databaseUrl ? describe : describe.skip;

withPostgres('forward-only zero-based trip progress migration', () => {
  it('upgrades the old constraint, preserves rows, accepts zero and rejects negatives', async () => {
    const client = new Client({ connectionString: databaseUrl });
    await client.connect();
    try {
      await client.query('BEGIN');
      // TEMP shadows any real trips table. All DDL and fixtures roll back.
      await client.query(`CREATE TEMP TABLE trips (
        id integer PRIMARY KEY,
        current_stop_seq integer,
        CONSTRAINT trips_current_stop_seq_check CHECK (current_stop_seq IS NULL OR current_stop_seq >= 1)
      ) ON COMMIT DROP`);
      await client.query('INSERT INTO trips VALUES (1, NULL), (2, 1), (3, 7)');
      const sql = await readFile(
        new URL('../src/db/migrations/042_zero_based_trip_progress.sql', import.meta.url),
        'utf8',
      );
      await client.query(sql);
      await client.query('UPDATE trips SET current_stop_seq = 0 WHERE id = 1');
      expect((await client.query('SELECT current_stop_seq FROM trips ORDER BY id')).rows).toEqual([
        { current_stop_seq: 0 },
        { current_stop_seq: 1 },
        { current_stop_seq: 7 },
      ]);
      await expect(
        client.query('UPDATE trips SET current_stop_seq = -1 WHERE id = 1'),
      ).rejects.toMatchObject({ code: '23514' });
    } finally {
      await client.query('ROLLBACK');
      await client.end();
    }
  });
});
