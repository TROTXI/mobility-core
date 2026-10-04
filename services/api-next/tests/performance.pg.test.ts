import test from 'node:test';
import assert from 'node:assert/strict';
import { setup } from './helpers/financial-fixture.js';
import { beginTransaction } from '../src/db/transaction.js';

test('request and retention paths reach their rows through an index', async (t) => {
  const f = await setup(t);
  const c = await f.owner.connect();
  const id = '00000000-0000-4000-8000-000000000000';
  // Empty tables, so the planner is told sequential scans are off. A plan that
  // still names a table scan, or reads an index whose leading column is not
  // the one searched, has no index to use.
  const paths: [string, string, string | string[]][] = [
    [
      'offered reservation directional quota',
      `SELECT count(*) FROM app.reservations WHERE period_id=$1 AND direction='outbound'
       AND id<>$1 AND status IN ('reserved','boarded','no_show')`,
      'reservations_period_direction_committed',
    ],
    [
      'offered period directional charges',
      `SELECT count(*) FROM app.reservation_charges c JOIN app.reservations r ON r.id=c.reservation_id
       WHERE c.period_id=$1 AND r.direction='outbound'`,
      'reservation_charges_period',
    ],
    [
      'membership assignment',
      `SELECT * FROM app.commute_assignments WHERE period_id=$1 AND effective_from<=current_date
       AND (effective_to IS NULL OR current_date<effective_to)`,
      // Both indexes start with period_id. PostgreSQL may prefer the new
      // period-scoped exclusion index introduced for prepaid renewals.
      ['commute_assignments_period', 'commute_assignments_period_dates_excl'],
    ],
    [
      'trip summary counts',
      'SELECT count(*) FROM app.reservations WHERE trip_id=$1',
      'reservations_trip',
    ],
    [
      'trip summary boarding charges',
      `SELECT count(DISTINCT e.reservation_id) FROM app.boarding_events e
       JOIN app.reservation_charges r ON r.reservation_id=e.reservation_id WHERE r.trip_id=$1`,
      'reservation_charges_trip',
    ],
    [
      'trip summary boarding events',
      `SELECT count(DISTINCT e.reservation_id) FROM app.boarding_events e
       JOIN app.reservation_charges r ON r.reservation_id=e.reservation_id WHERE r.trip_id=$1`,
      'boarding_events_reservation',
    ],
    [
      'GPS retention foreign key check',
      'SELECT 1 FROM app.trip_live_positions WHERE position_id=$1',
      'trip_live_positions_position',
    ],
    [
      'latest personal pause',
      'SELECT * FROM app.personal_pauses WHERE user_id=$1 ORDER BY created_at DESC,id DESC LIMIT 1',
      'personal_pauses_user_latest',
    ],
  ];
  try {
    await c.query('BEGIN');
    await c.query('SET LOCAL enable_seqscan=off');
    await c.query('SET LOCAL enable_bitmapscan=off');
    for (const [path, sql, index] of paths) {
      const plan = (await c.query(`EXPLAIN (FORMAT JSON) ${sql}`, [id])).rows[0]['QUERY PLAN'];
      const text = JSON.stringify(plan);
      const indexes = Array.isArray(index) ? index : [index];
      assert.match(
        text,
        new RegExp(`"Index Name":"(?:${indexes.join('|')})"`),
        `${path} uses ${indexes.join(' or ')}`,
      );
      if (path === 'membership assignment')
        assert.match(text, /"Index Cond":"\(period_id =/, `${path} seeks by period`);
      assert.doesNotMatch(text, /"Node Type":"Seq Scan"/, `${path} scans no table`);
    }
  } finally {
    await c.query('ROLLBACK');
    c.release();
  }
});

test('batched transaction setup preserves safety limits, isolation and pooled connection cleanup', async (t) => {
  const f = await setup(t);
  const c = await f.runtime.connect();
  const settings = async () =>
    (
      await c.query(`SELECT current_setting('TimeZone') AS zone,
    current_setting('lock_timeout') AS lock_timeout,
    current_setting('statement_timeout') AS statement_timeout,
    current_setting('transaction_isolation') AS isolation`)
    ).rows[0];
  try {
    const before = await settings();
    for (const snapshot of [false, true]) {
      await beginTransaction(c, snapshot);
      assert.deepEqual(await settings(), {
        zone: 'UTC',
        lock_timeout: '3s',
        statement_timeout: '10s',
        isolation: snapshot ? 'repeatable read' : 'read committed',
      });
      await c.query(snapshot ? 'ROLLBACK' : 'COMMIT');
      assert.deepEqual(await settings(), before);
    }
    await beginTransaction(c);
    await assert.rejects(c.query('SELECT 1/0'));
    await c.query('ROLLBACK');
    assert.deepEqual(await settings(), before);
    assert.equal((await c.query('SELECT 1 AS value')).rows[0].value, 1);
  } finally {
    await c.query('ROLLBACK');
    c.release();
  }
});
