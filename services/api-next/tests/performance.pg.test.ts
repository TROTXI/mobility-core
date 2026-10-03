import test from 'node:test';
import assert from 'node:assert/strict';
import { setup } from './helpers/financial-fixture.js';
import { beginTransaction } from '../src/db/transaction.js';

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
