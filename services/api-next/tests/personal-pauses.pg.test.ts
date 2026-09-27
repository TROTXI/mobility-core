import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { setup } from './helpers/financial-fixture.js';
import { FinancialFoundation } from '../src/payments/foundation.js';
import { MembershipService } from '../src/membership/service.js';
import { TransportService } from '../src/transport/service.js';
import { createTransportApp } from '../src/http/app.js';

async function fixture(t: Parameters<typeof setup>[0], limitedWeekdays = false) {
  const f = await setup(t);
  if (limitedWeekdays) {
    const weekday = new Date(Date.now() + 86400000).getUTCDay() || 7;
    for (const leg of f.input.legs) {
      const departure = (
        await f.owner.query(
          'INSERT INTO app.service_departures(pattern_id) SELECT pattern_id FROM app.service_schedules WHERE id=$1 RETURNING id',
          [leg.scheduleId],
        )
      ).rows[0].id;
      const revision = (
        await f.owner.query(
          `INSERT INTO app.service_schedules(departure_id,pattern_id,pattern_version_id,service_window,local_departure,weekdays,effective_from)
        SELECT $2,pattern_id,pattern_version_id,service_window,local_departure,ARRAY[$3]::smallint[],effective_from
        FROM app.service_schedules WHERE id=$1 RETURNING id`,
          [leg.scheduleId, departure, weekday],
        )
      ).rows[0].id;
      leg.scheduleId = revision;
    }
  }
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [f.adminId]);
  const admin = { userId: f.adminId, sessionId: f.adminId };
  const membership = new MembershipService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 9),
  });
  const financial = new FinancialFoundation({
    ...f.dependencies,
    assertCheckoutAllowed: membership.assertCheckoutAllowed,
    assertPeriodCanClose: membership.assertPeriodCanClose,
    materializeAssignment: membership.materializeAssignment,
  });
  const now = new Date();
  const purchase = await financial.checkout(f.actor, f.input, randomUUID(), now);
  await financial.fulfill(f.settle(purchase, now));
  const day = (n: number) =>
    new Date(Date.parse(now.toISOString().slice(0, 10)) + n * 86400000).toISOString().slice(0, 10);
  const transport = new TransportService({ ...f.dependencies, cursorSecret: Buffer.alloc(32, 9) });
  await transport.generateTrips(admin, { serviceDate: day(1) });
  const vehicle = (
    await f.owner.query(
      "INSERT INTO app.vehicles(plate,capacity) VALUES ('PAUSE-TEST',18) RETURNING id",
    )
  ).rows[0].id;
  await f.owner.query('UPDATE app.trips SET vehicle_id=$1', [vehicle]);
  await membership.command(
    f.actor,
    'decideReservation',
    undefined,
    { travelDate: day(1), direction: 'outbound', decision: 'confirm' },
    randomUUID(),
  );
  const before = (
    await f.owner.query('SELECT * FROM app.billing_periods WHERE user_id=$1', [f.actor.userId])
  ).rows[0];
  const app = await createTransportApp({
    ...f.dependencies,
    cursorSecret: Buffer.alloc(32, 9),
    membership,
    coordinateReservations: membership.coordinateReservations,
    minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
    verifyAccess: async (h) =>
      h === 'Bearer rider' ? f.actor : h === 'Bearer other' ? f.other : admin,
  });
  t.after(() => app.close());
  const headers = {
    authorization: 'Bearer rider',
    'x-trotxi-client': 'commuter',
    'x-trotxi-build': '1',
    'x-trotxi-platform': 'android',
  };
  const post = async (path: string, payload: any, key = randomUUID(), status = 200) => {
    const r = await app.inject({
      method: 'POST',
      url: path,
      headers: { ...headers, 'idempotency-key': key },
      payload,
    });
    assert.equal(r.statusCode, status, r.body);
    return r.json().data;
  };
  // Only this disposable database's owner advances the clock seam. Production
  // runtime cannot replace functions; application callers never supply "now".
  const advance = async (n: number) =>
    f.owner.query(`CREATE OR REPLACE FUNCTION app.personal_pause_now() RETURNS timestamptz
    LANGUAGE sql VOLATILE AS $$ SELECT '${day(n)}T00:00:00Z'::timestamptz $$`);
  return {
    ...f,
    admin,
    membership,
    financial,
    app,
    headers,
    post,
    day,
    before,
    purchase,
    advance,
    input: { startDate: day(1), resumeDate: day(8) },
  };
}
test('PAUSE-01 preview is non-mutating; confirmation releases seats, preserves rides and prevents rebooking', async (t) => {
  const f = await fixture(t);
  const prior = (await f.owner.query('SELECT * FROM app.reservations')).rows;
  assert.equal(prior.length, 1);
  assert.equal(prior[0].status, 'reserved');
  const preview = await f.post('/v1/me/membership/pause-preview', f.input);
  assert.deepEqual(preview.cancelledReservationIds, [prior[0].id]);
  assert.equal(
    preview.projectedEndsAt,
    new Date(f.before.effective_ends_at.getTime() + 7 * 86400000).toISOString(),
  );
  assert.deepEqual((await f.owner.query('SELECT * FROM app.reservations')).rows, prior);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.personal_pauses')).rows[0].n,
    0,
  );
  const key = randomUUID();
  const p = await f.post('/v1/me/membership/pauses', f.input, key, 201);
  assert.equal(p.status, 'scheduled');
  assert.equal((await f.post('/v1/me/membership/pauses', f.input, key, 201)).id, p.id);
  assert.equal(
    (await f.owner.query('SELECT status FROM app.reservations')).rows[0].status,
    'declined',
  );
  assert.equal(
    (await f.owner.query('SELECT sum(delta_rides)::int n FROM app.ride_entries')).rows[0].n,
    44,
  );
  await assert.rejects(
    f.runtime.query("UPDATE app.reservations SET status='reserved' WHERE id=$1", [prior[0].id]),
    /personal_pause_active/,
  );
  await f.post('/v1/me/membership/pauses', f.input, randomUUID(), 409);
  assert.equal(
    (
      await f.owner.query('SELECT effective_ends_at FROM app.billing_periods')
    ).rows[0].effective_ends_at.toISOString(),
    f.before.effective_ends_at.toISOString(),
  );
});
test('PAUSE-02 automatic resume applies calendar days exactly once and keeps the assignment', async (t) => {
  const f = await fixture(t);
  const assignment = (await f.owner.query('SELECT * FROM app.commute_assignments')).rows;
  await f.post('/v1/me/membership/pauses', f.input, randomUUID(), 201);
  await f.advance(1);
  const paused = await f.membership.read(f.actor, 'getMembership');
  assert.equal((paused.body as any).data.coverage.paused, true);
  assert.equal((paused.body as any).data.access.canReserve, false);
  await f.advance(8);
  await Promise.all([
    f.membership.resumeDuePersonalPauses(f.admin),
    f.membership.resumeDuePersonalPauses(f.admin),
  ]);
  await f.membership.resumeDuePersonalPauses(f.admin);
  const b = (await f.owner.query('SELECT * FROM app.billing_periods')).rows[0];
  assert.equal(b.effective_ends_at.getTime(), f.before.effective_ends_at.getTime() + 7 * 86400000);
  assert.deepEqual((await f.owner.query('SELECT * FROM app.commute_assignments')).rows, assignment);
  assert.equal((await f.owner.query('SELECT count(*)::int n FROM app.ride_entries')).rows[0].n, 1);
  const current = await f.app.inject({ url: '/v1/me/membership/pause', headers: f.headers });
  assert.equal(current.statusCode, 200, current.body);
  assert.equal(current.json().data.status, 'resumed');
  assert.equal(current.json().data.extensionApplied, true);
});
test('PAUSE-03 early resume cannot backdate, restores no reservations and extends only actual days', async (t) => {
  const f = await fixture(t);
  const p = await f.post('/v1/me/membership/pauses', f.input, randomUUID(), 201);
  await f.advance(2);
  await f.post(
    `/v1/me/membership/pauses/${p.id}/resume`,
    { resumeDate: f.day(2) },
    randomUUID(),
    409,
  );
  const key = randomUUID();
  await f.post(`/v1/me/membership/pauses/${p.id}/resume`, { resumeDate: f.day(3) }, key);
  await f.post(`/v1/me/membership/pauses/${p.id}/resume`, { resumeDate: f.day(3) }, key);
  const foreign = await f.app.inject({
    method: 'POST',
    url: `/v1/me/membership/pauses/${p.id}/resume`,
    headers: { ...f.headers, authorization: 'Bearer other', 'idempotency-key': randomUUID() },
    payload: { resumeDate: f.day(3) },
  });
  assert.equal(foreign.statusCode, 404);
  await f.advance(3);
  // Reading membership lazily settles even if the periodic worker was late.
  await f.membership.read(f.actor, 'getMembership');
  assert.equal(
    (
      await f.owner.query('SELECT effective_ends_at FROM app.billing_periods')
    ).rows[0].effective_ends_at.getTime(),
    f.before.effective_ends_at.getTime() + 2 * 86400000,
  );
  assert.equal(
    (await f.owner.query('SELECT status FROM app.reservations')).rows[0].status,
    'declined',
  );
});
test('PAUSE-04 range, restrictions and erasure do not bypass policy', async (t) => {
  const f = await fixture(t);
  for (const input of [
    { startDate: f.day(0), resumeDate: f.day(4) },
    { startDate: f.day(1), resumeDate: f.day(3) },
    { startDate: f.day(1), resumeDate: f.day(16) },
    { startDate: '0000-01-01', resumeDate: f.day(4) },
    { startDate: '2026-02-30', resumeDate: f.day(4) },
  ])
    await assert.rejects(
      f.membership.command(f.actor, 'createPersonalPause', undefined, input, randomUUID()),
    );
  await f.owner.query(
    "INSERT INTO app.account_restrictions(user_id,actor_user_id,reason,review_at) VALUES ($1,$2,'test',clock_timestamp()+interval '1 day')",
    [f.actor.userId, f.admin.userId],
  );
  await f.post('/v1/me/membership/pauses', f.input, randomUUID(), 409);
  await f.owner.query(
    "UPDATE app.account_restrictions SET released_at=clock_timestamp(),released_by=$1,release_reason='test'",
    [f.admin.userId],
  );
  await f.post('/v1/me/membership/pauses', f.input, randomUUID(), 201);
  await f.owner.query('UPDATE app.users SET deleted_at=clock_timestamp() WHERE id=$1', [
    f.actor.userId,
  ]);
  await f.advance(8);
  await f.membership.resumeDuePersonalPauses(f.admin);
  assert.equal(
    (await f.owner.query('SELECT state FROM app.personal_pauses')).rows[0].state,
    'terminated',
  );
  assert.equal(
    (
      await f.owner.query('SELECT effective_ends_at FROM app.billing_periods')
    ).rows[0].effective_ends_at.toISOString(),
    f.before.effective_ends_at.toISOString(),
  );
});
test('PAUSE-05 actual service weekdays and a current dispute prevent scheduling', async (t) => {
  const f = await fixture(t, true);
  await f.post(
    '/v1/me/membership/pause-preview',
    { startDate: f.day(2), resumeDate: f.day(9) },
    randomUUID(),
    409,
  );
  await f.post(
    '/v1/me/membership/pause-preview',
    { startDate: f.day(1), resumeDate: f.day(4) },
    randomUUID(),
    409,
  );
  const event = (
    await f.owner.query(
      `INSERT INTO app.payment_events(environment,source,payload_hash,ciphertext)
    VALUES ('test','webhook',repeat('b',64),$1) RETURNING id`,
      [Buffer.alloc(29)],
    )
  ).rows[0].id;
  const dispute = (
    await f.owner.query(
      `INSERT INTO app.payment_disputes(attempt_id,purchase_id,user_id,environment,provider_id,amount_pesewas,state,event_id)
    VALUES ($1,$2,$3,'test','123',100,'created',$4) RETURNING id`,
      [f.purchase.attempt.id, f.purchase.id, f.actor.userId, event],
    )
  ).rows[0].id;
  await f.owner.query(
    `INSERT INTO app.payment_access_blocks(period_id,purchase_id,user_id,dispute_id)
    VALUES ($1,$2,$3,$4)`,
    [f.before.id, f.purchase.id, f.actor.userId, dispute],
  );
  await f.post('/v1/me/membership/pauses', f.input, randomUUID(), 409);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.personal_pauses')).rows[0].n,
    0,
  );
});
test('PAUSE-06 a restriction imposed during a break survives resume and time cannot be closed away', async (t) => {
  const f = await fixture(t);
  await f.post('/v1/me/membership/pauses', f.input, randomUUID(), 201);
  await assert.rejects(
    f.runtime.query("UPDATE app.billing_periods SET state='closed' WHERE id=$1", [f.before.id]),
    /personal_pause_unsettled/,
  );
  await f.owner.query(
    "INSERT INTO app.account_restrictions(user_id,actor_user_id,reason,review_at) VALUES ($1,$2,'test',clock_timestamp()+interval '20 days')",
    [f.actor.userId, f.admin.userId],
  );
  await f.advance(8);
  await f.membership.resumeDuePersonalPauses(f.admin);
  const current = (await f.membership.read(f.actor, 'getMembership')).body as any;
  assert.equal(current.data.coverage.paused, false);
  assert.equal(current.data.access.canReserve, false);
  assert.ok(current.data.access.blocks.some((b: any) => b.kind === 'ops_restriction'));
  assert.equal(
    (
      await f.owner.query(
        'SELECT count(*)::int n FROM app.account_restrictions WHERE released_at IS NULL',
      )
    ).rows[0].n,
    1,
  );
});
