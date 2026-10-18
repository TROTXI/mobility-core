import assert from 'node:assert/strict';
import test from 'node:test';
import { setup } from './helpers/financial-fixture.js';
import { MaintenanceAudit } from '../src/runtime/maintenance-audit.js';
import { MaintenanceScheduler, validateScheduler } from '../src/runtime/scheduler.js';
import type { Backend } from '../src/runtime/compose.js';
import type { JobRequest, JobResult } from '../src/runtime/maintenance.js';

test('runtime-role scheduler elects one replica, persists slots and rejects human identities', async (t) => {
  const f = await setup(t);
  const userId = (await f.owner.query("INSERT INTO app.users(role) VALUES('admin') RETURNING id"))
    .rows[0].id;
  const backend = {
    pool: f.runtime,
    maintenanceUserId: userId,
    maintenanceAudit: new MaintenanceAudit(f.runtime),
    push: {},
    sms: {},
  } as unknown as Backend;
  await validateScheduler(backend);
  const calls: string[] = [];
  let signal!: () => void, release!: () => void;
  const entered = new Promise<void>((resolve) => {
    signal = resolve;
  });
  const hold = new Promise<void>((resolve) => {
    release = resolve;
  });
  const now = new Date();
  const run = async (_request: JobRequest): Promise<JobResult> => {
    calls.push(_request.job);
    if (calls.length === 1) {
      signal();
      await hold;
    }
    // No business jobs or providers run in this lock/audit integration test.
    return { job: 'driver-secrets', status: 200, body: { cleared: 0 } };
  };
  const first = new MaintenanceScheduler(
    backend,
    () => {},
    run,
    () => now.getTime(),
  );
  const second = new MaintenanceScheduler(
    backend,
    () => {},
    run,
    () => now.getTime(),
  );
  const running = first.tick(now);
  try {
    await entered;
    await second.tick(now);
    assert.equal(calls.length, 1, 'second replica must not invoke any work while the lock is held');
  } finally {
    release();
  }
  await running;
  const before = calls.length;
  assert.ok(before > 1);
  await second.tick(now);
  assert.equal(calls.length, before, 'success is deduplicated across process instances');
  const outcomes = await f.runtime.query(
    `SELECT o.state FROM app.maintenance_run_starts s JOIN app.maintenance_run_outcomes o ON o.run_id=s.id
     WHERE s.actor_user_id=$1 AND s.operation LIKE 'scheduler:%'`,
    [userId],
  );
  assert.ok(outcomes.rows.length > 0);
  assert.ok(outcomes.rows.every((row) => row.state === 'completed'));
  await f.owner.query("UPDATE app.users SET email='human@example.test' WHERE id=$1", [userId]);
  await assert.rejects(validateScheduler(backend), /requires_service_identity/);
});
