import { test } from 'node:test';
import assert from 'node:assert/strict';
import { setup } from './helpers/financial-fixture.js';
import { TransportService } from '../src/transport/service.js';

async function fixture(t: Parameters<typeof setup>[0]) {
  const f = await setup(t);
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [f.adminId]);
  const actor = { userId: f.adminId, sessionId: f.adminId };
  const service = new TransportService({ ...f.dependencies, cursorSecret: Buffer.alloc(32, 9) });
  const day = new Date(Date.now() + 86400000).toISOString().slice(0, 10);
  const input = { serviceDate: day, routeId: f.input.routeId };
  return { ...f, actor, service, day, input, legs: f.input.legs };
}
test('GEN-01 repeat and concurrent generation preserve one receipt-backed run per departure', async (t) => {
  const f = await fixture(t);
  const results = await Promise.all([
    f.service.generateTrips(f.actor, f.input),
    f.service.generateTrips(f.actor, f.input),
  ]);
  assert.equal(
    results.reduce((n, r) => n + (r.body as any).data.succeeded, 0),
    2,
  );
  const rows = (await f.owner.query('SELECT * FROM app.trips')).rows;
  assert.equal(rows.length, 2);
  assert.ok(
    rows.every(
      (r) =>
        r.run_number === 1 && r.status === 'scheduled' && !r.assigned_driver_id && !r.vehicle_id,
    ),
  );
  assert.equal(
    (
      await f.owner.query(
        'SELECT count(*)::int n FROM app.trip_events WHERE command_id IS NOT NULL',
      )
    ).rows[0].n,
    2,
  );
  assert.equal(((await f.service.generateTrips(f.actor, f.input)).body as any).data.succeeded, 0);
});
test('GEN-02 cancelled/rescheduled runs retain identity; archived corridors and bad days produce no run', async (t) => {
  const f = await fixture(t);
  await f.service.generateTrips(f.actor, f.input);
  await f.owner.query("UPDATE app.trips SET status='cancelled' WHERE schedule_id=$1", [
    f.legs[0]!.scheduleId,
  ]);
  await f.owner.query(
    "UPDATE app.trips SET scheduled_at=scheduled_at+interval '1 hour' WHERE schedule_id=$1",
    [f.legs[1]!.scheduleId],
  );
  const before = (await f.owner.query('SELECT * FROM app.trips ORDER BY id')).rows;
  await f.service.generateTrips(f.actor, f.input);
  assert.deepEqual((await f.owner.query('SELECT * FROM app.trips ORDER BY id')).rows, before);
  await f.owner.query('UPDATE app.routes SET archived_at=clock_timestamp() WHERE id=$1', [
    f.input.routeId,
  ]);
  const next = new Date(Date.parse(f.day) + 86400000).toISOString().slice(0, 10);
  assert.equal(
    ((await f.service.generateTrips(f.actor, { ...f.input, serviceDate: next })).body as any).data
      .considered,
    0,
  );
  await assert.rejects(f.service.generateTrips(f.actor, { serviceDate: '2026-02-30' }));
  await assert.rejects(f.service.generateTrips(f.other, f.input), (e: any) => e.status === 403);
});
test('GEN-03 conflicting eligible schedules fail visibly rather than pick one arbitrarily', async (t) => {
  const f = await fixture(t);
  await f.owner.query(
    `INSERT INTO app.service_schedules(pattern_version_id,pattern_id,departure_id,service_window,local_departure,time_zone,weekdays,effective_from,effective_to)
    SELECT pattern_version_id,pattern_id,departure_id,service_window,local_departure,time_zone,weekdays,effective_from,effective_to
    FROM app.service_schedules WHERE id=$1`,
    [f.legs[0]!.scheduleId],
  );
  const result = (await f.service.generateTrips(f.actor, f.input)).body as any;
  assert.equal(result.data.failed, 1);
  assert.equal(result.data.failures[0].reason, 'ambiguous_schedule');
  assert.equal(result.data.succeeded, 1);
});
