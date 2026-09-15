import { test } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID, randomBytes, createHmac } from 'node:crypto';
import { PaymentRecovery } from '../src/payments/recovery.js';
import { PaystackEvidence } from '../src/payments/provider.js';
import { setup, at, renewAt, files } from './helpers/financial-fixture.js';
import { migrate, grantRuntime } from '../src/db/migrate.js';
import { MembershipService } from '../src/membership/service.js';
import type { MembershipOperation } from '../src/membership/service.js';
import { FinancialFoundation } from '../src/payments/foundation.js';
import { TransportError } from '../src/transport/errors.js';
import type { Actor, Body, Outcome } from '../src/transport/service.js';
import { createTransportApp } from '../src/http/app.js';

const data = (out: Outcome) => (out.body as any).data;
const code = (wanted: string) => (e: unknown) => e instanceof TransportError && e.code === wanted;
async function httpFixture(t: TestContext) {
  const f = await fixture(t);
  const app = await createTransportApp({
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 7),
    authorizeSession: f.dependencies.authorizeSession,
    coordinateReservations: f.membership.coordinateReservations,
    membership: f.membership,
    verifyAccess: async (h) =>
      h === 'Bearer rider' ? f.actor : h === 'Bearer ops' ? f.admin : null,
    minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
  });
  t.after(() => app.close());
  const rider = {
    authorization: 'Bearer rider',
    'x-trotxi-client': 'commuter',
    'x-trotxi-build': '1',
    'x-trotxi-platform': 'android',
  };
  const admin = { authorization: 'Bearer ops', 'x-trotxi-client': 'ops', 'x-trotxi-build': '1' };
  const get = async (url: string, headers: Record<string, string> = rider, status = 200) => {
    const r = await app.inject({ url, headers });
    assert.equal(r.statusCode, status, r.body);
    return r.json();
  };
  return { ...f, app, rider, adminHeaders: admin, get };
}

test('COM-18: HTTP request status and slot route filters narrow results and bind normalized cursors', async (t) => {
  const f = await httpFixture(t);
  await f.buy();
  await f.buy(f.other);
  const rejected = [];
  for (let n = 0; n < 2; n++) {
    const r = await f.request();
    await f.decide(r.id, { action: 'reject' });
    rejected.push(r.id);
  }
  await f.request();
  const other = await f.request(f.other);
  await f.decide(other.id, { action: 'reject' });
  for (const [path, headers, expected] of [
    ['/v1/me/commute-requests', f.rider, 2],
    ['/v1/ops/commute-requests', f.adminHeaders, 3],
  ] as const) {
    const all = await f.get(`${path}?status=rejected`, headers);
    assert.equal(all.data.length, expected);
    assert.ok(all.data.every((r: any) => r.status === 'rejected'));
    assert.equal((await f.get(`${path}?status=approved`, headers)).data.length, 0);
    const first = await f.get(`${path}?status=rejected&limit=1`, headers);
    assert.ok(first.page.nextCursor);
    const cursor = encodeURIComponent(first.page.nextCursor);
    const second = await f.get(`${path}?status=rejected&limit=1&cursor=${cursor}`, headers);
    assert.notEqual(first.data[0].id, second.data[0].id);
    assert.equal(second.data[0].status, 'rejected');
    assert.equal(
      (await f.get(`${path}?status=submitted&cursor=${cursor}`, headers, 400)).error.code,
      'invalid_cursor',
    );
    await f.get(`${path}?status=made-up`, headers, 400);
  }
  const own = await f.get('/v1/me/commute-requests?status=rejected');
  assert.deepEqual(own.data.map((r: any) => r.id).sort(), rejected.sort());
  for (let n = 0; n < 3; n++) await f.slot();
  const unrelated = (
    await f.owner.query("INSERT INTO app.routes(name) VALUES ('Unrelated') RETURNING id")
  ).rows[0].id;
  assert.equal(
    (await f.get(`/v1/ops/commute-slots?routeId=${unrelated}`, f.adminHeaders)).data.length,
    0,
  );
  const first = await f.get(
    `/v1/ops/commute-slots?routeId=${f.input.routeId}&limit=1`,
    f.adminHeaders,
  );
  assert.ok(first.page.nextCursor);
  const cursor = encodeURIComponent(first.page.nextCursor);
  const second = await f.get(
    `/v1/ops/commute-slots?routeId=${f.input.routeId.toUpperCase()}&limit=1&cursor=${cursor}`,
    f.adminHeaders,
  );
  assert.equal(second.data[0].routeId, f.input.routeId);
  assert.notEqual(second.data[0].id, first.data[0].id);
  assert.equal(
    (
      await f.get(
        `/v1/ops/commute-slots?routeId=${unrelated}&cursor=${cursor}`,
        f.adminHeaders,
        400,
      )
    ).error.code,
    'invalid_cursor',
  );
  await f.get('/v1/ops/commute-slots?routeId=not-a-uuid', f.adminHeaders, 400);
  assert.equal((await f.get('/v1/ops/commute-slots?limit=200', f.adminHeaders)).data.length, 3);
});

test('COM-19: HTTP reservation dates are inclusive, paired, bounded and cursor-bound with a seven-day default', async (t) => {
  const f = await httpFixture(t);
  await f.buy();
  for (const travelDate of ['2026-01-02', '2026-01-03', '2026-01-10']) {
    await f.trip(1, travelDate);
    await f.command('decideReservation', {
      travelDate,
      direction: 'outbound',
      decision: 'confirm',
    });
  }
  const path = '/v1/me/reservations';
  const range = 'fromDate=2026-01-02&toDate=2026-01-03';
  assert.deepEqual((await f.get(`${path}?${range}`)).data.map((r: any) => r.travelDate).sort(), [
    '2026-01-02',
    '2026-01-03',
  ]);
  assert.equal((await f.get(`${path}?fromDate=2030-01-01&toDate=2030-01-02`)).data.length, 0);
  const first = await f.get(`${path}?${range}&limit=1`);
  assert.ok(first.page.nextCursor);
  const cursor = encodeURIComponent(first.page.nextCursor);
  const second = await f.get(`${path}?${range}&cursor=${cursor}`);
  assert.notEqual(first.data[0].id, second.data[0].id);
  assert.equal(
    (await f.get(`${path}?fromDate=2026-01-02&toDate=2026-01-10&cursor=${cursor}`, f.rider, 400))
      .error.code,
    'invalid_cursor',
  );
  for (const query of [
    'fromDate=2026-01-02',
    'toDate=2026-01-02',
    'fromDate=2026-01-03&toDate=2026-01-02',
    'fromDate=2026-01-01&toDate=2026-02-01',
    'fromDate=2026-02-30&toDate=2026-03-01',
  ])
    await f.get(`${path}?${query}`, f.rider, 400);
  assert.equal((await f.get(`${path}?fromDate=2026-01-01&toDate=2026-01-31`)).data.length, 3);
  f.setNow('2026-01-10T12:00:00Z');
  assert.deepEqual(
    (await f.get(path)).data.map((r: any) => r.travelDate),
    ['2026-01-10'],
  );
});

test('COM-20: restriction authorization precedes subject existence and revoked-session disclosure', async (t) => {
  const f = await httpFixture(t);
  const targets = [f.actor.userId, randomUUID(), f.admin.userId];
  const attempt = (target: string, headers: Record<string, string>) =>
    f.app.inject({
      method: 'POST',
      url: `/v1/ops/users/${target}/restrictions`,
      headers: { ...headers, 'idempotency-key': randomUUID() },
      payload: { reason: 'Test restriction', reviewAt: '2026-01-05T00:00:00Z' },
    });
  for (const target of targets) {
    const r = await attempt(target, { ...f.adminHeaders, authorization: 'Bearer rider' });
    assert.equal(r.statusCode, 403, r.body);
  }
  await f.owner.query('UPDATE app.test_fin_sessions SET active=false WHERE user_id=$1', [
    f.actor.userId,
  ]);
  for (const target of targets) {
    const r = await attempt(target, { ...f.adminHeaders, authorization: 'Bearer rider' });
    assert.equal(r.statusCode, 401, r.body);
  }
  for (const target of targets.slice(1)) {
    const r = await attempt(target, f.adminHeaders);
    assert.equal(r.statusCode, 404, r.body);
  }
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.account_restrictions')).rows[0].n,
    0,
  );
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.membership_commands')).rows[0].n,
    0,
  );
});

test('COM-21: create retries preserve declared 201 and current ETag without repeating mutations', async (t) => {
  const f = await httpFixture(t);
  await f.buy();
  for (const [url, payload, headers, table] of [
    [
      '/v1/ops/commute-slots',
      { routeId: f.input.routeId, legs: f.input.legs, availableFrom: '2026-01-02' },
      f.adminHeaders,
      'commute_slots',
    ],
    [
      '/v1/me/commute-requests',
      {
        routeId: f.input.routeId,
        legs: f.input.legs,
        requestedDate: '2026-01-02',
        pauseIfWaitlisted: true,
      },
      f.rider,
      'commute_requests',
    ],
    [
      `/v1/ops/users/${f.actor.userId}/restrictions`,
      { reason: 'Test', reviewAt: '2026-01-05T00:00:00Z' },
      f.adminHeaders,
      'account_restrictions',
    ],
  ] as const) {
    const key = randomUUID();
    const send = () =>
      f.app.inject({
        method: 'POST',
        url,
        payload,
        headers: { ...headers, 'idempotency-key': key },
      });
    const first = await send();
    assert.equal(first.statusCode, 201, first.body);
    const replay = await send();
    assert.equal(replay.statusCode, 201, replay.body);
    assert.deepEqual(replay.json(), first.json());
    assert.equal(replay.headers.etag, first.headers.etag);
    if (first.json().data.editToken)
      assert.equal(replay.headers.etag, replay.json().data.editToken);
    assert.equal((await f.owner.query(`SELECT count(*)::int n FROM app.${table}`)).rows[0].n, 1);
    if (table === 'commute_slots') {
      await f.command(
        'retireCommuteSlot',
        {},
        first.json().data.id,
        first.json().data.editToken,
        f.admin,
      );
      const current = await send();
      assert.equal(current.statusCode, 201, current.body);
      assert.equal(current.json().data.state, 'retired');
      assert.notEqual(current.headers.etag, first.headers.etag);
      assert.equal(current.headers.etag, current.json().data.editToken);
    }
  }
});

test('COM-17: automatic invalidation records its cause without inventing a rider decision', async (t) => {
  const f = await fixture(t),
    { period } = await f.buy(),
    r = await f.request();
  await f.financial.closePeriod(period.id, renewAt);
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT status,decided_by,invalidation_reason FROM app.commute_requests WHERE id=$1',
        [r.id],
      )
    ).rows[0],
    { status: 'cancelled', decided_by: null, invalidation_reason: 'period_ended' },
  );
});
test('COM-16: real 012-to-013 upgrade preserves purchase/ledger and materializes only frozen initial legs', async (t) => {
  const f = await setup(t, {}, false, 12),
    p = await f.buy();
  await f.service.fulfill(f.settle(p));
  const before = (await f.owner.query('SELECT * FROM app.purchases')).rows;
  const ledger = (await f.owner.query('SELECT * FROM app.ride_entries')).rows;
  assert.deepEqual(await migrate(f.owner, files.slice(0, 13)), ['013_commute_reservations.sql']);
  await migrate(f.owner, files);
  await grantRuntime(f.owner, f.role);
  assert.deepEqual((await f.owner.query('SELECT * FROM app.purchases')).rows, before);
  assert.deepEqual((await f.owner.query('SELECT * FROM app.ride_entries')).rows, ledger);
  const assignment = (await f.owner.query('SELECT * FROM app.commute_assignments')).rows[0];
  assert.equal(assignment.purchase_id, p.id);
  assert.equal(assignment.user_id, f.actor.userId);
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT direction,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id FROM app.commute_selection_legs ORDER BY direction',
      )
    ).rows,
    (
      await f.owner.query(
        'SELECT direction,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id FROM app.purchase_legs WHERE purchase_id=$1 ORDER BY direction',
        [p.id],
      )
    ).rows,
  );
});
test('RES-04/05: dispatch persists one prompt; bounded defaults seat capacity and mark overflow unseated', async (t) => {
  const f = await fixture(t);
  await f.buy();
  await f.buy(f.other);
  await f.trip(1);
  const input = { travelDate: '2026-01-02', direction: 'outbound', limit: 100 };
  const asked = data(await f.membership.maintenance(f.admin, 'runAskDispatch', input));
  assert.equal(asked.succeeded, 2);
  assert.equal(asked.failed, 0);
  assert.equal(
    data(await f.membership.maintenance(f.admin, 'runAskDispatch', input)).considered,
    0,
  );
  const defaults = data(await f.membership.maintenance(f.admin, 'runReservationDefaults', input));
  assert.deepEqual(defaults, { considered: 2, succeeded: 1, blocked: 1, failed: 0, failures: [] });
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT status,count(*)::int n FROM app.reservations GROUP BY status ORDER BY status',
      )
    ).rows,
    [
      { status: 'reserved', n: 1 },
      { status: 'unseated', n: 1 },
    ],
  );
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.reservation_prompts')).rows[0].n,
    2,
  );
  assert.equal(
    data(await f.membership.maintenance(f.admin, 'runReservationDefaults', input)).considered,
    0,
  );
  assert.equal((await f.owner.query('SELECT count(*)::int n FROM app.ride_entries')).rows[0].n, 2);
});
test('COM-07: erasure cancels requests, releases held slots, scrubs notes and hides queues', async (t) => {
  const f = await fixture(t);
  await f.buy();
  await f.trip();
  await f.reserve();
  const r = await f.request(),
    s = await f.slot();
  await f.decide(r.id, {
    action: 'approve',
    slotId: s.id,
    effectiveDate: '2026-01-02',
    note: 'Sensitive test note',
  });
  await f.owner.query('UPDATE app.users SET deleted_at=clock_timestamp() WHERE id=$1', [
    f.actor.userId,
  ]);
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT status,note,decision_note FROM app.commute_requests WHERE id=$1',
        [r.id],
      )
    ).rows[0],
    { status: 'cancelled', note: null, decision_note: null },
  );
  assert.equal(
    (await f.owner.query('SELECT state FROM app.commute_slots WHERE id=$1', [s.id])).rows[0].state,
    'available',
  );
  assert.equal(data(await f.membership.read(f.admin, 'listOpsCommuteRequests')).length, 0);
  assert.equal(
    (await f.owner.query('SELECT status FROM app.reservations')).rows[0].status,
    'operator_cancelled',
  );
  assert.equal(
    (await f.owner.query('SELECT sum(delta_rides)::int n FROM app.ride_entries')).rows[0].n,
    44,
  );
});
test('COM-13: Paystack full refund reverses funded reservations and approval in the same transaction', async (t) => {
  const f = await fixture(t),
    { purchase, period } = await f.buy();
  await f.trip();
  await f.reserve();
  const r = await f.request(),
    s = await f.slot();
  await f.decide(r.id, { action: 'approve', slotId: s.id, effectiveDate: '2026-01-02' });
  // Generated test-only credentials, no provider account or network requests.
  const secret = 'sk_test_' + randomBytes(16).toString('hex');
  const provider = new PaystackEvidence(secret, randomBytes(32), async () => {
    throw new Error('Unexpected network request');
  });
  const recovery = new PaymentRecovery({
    pool: f.runtime,
    provider,
    foundation: f.financial,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 8),
    reversePeriod: f.membership.reversePeriod,
  });
  const payload = {
    event: 'refund.processed',
    data: {
      transaction_reference: purchase.attempt.reference,
      domain: 'test',
      currency: 'GHS',
      amount: purchase.cashDuePesewas,
      status: 'processed',
      refund_reference: 'refund-013',
    },
  };
  const raw = Buffer.from(JSON.stringify(payload));
  await recovery.acceptWebhook(raw, createHmac('sha512', secret).update(raw).digest('hex'));
  assert.equal((await recovery.processInbox()).succeeded, 1);
  assert.equal((await f.period(purchase.id)).state, 'reversed');
  assert.equal((await f.requestRow(r.id)).status, 'cancelled');
  assert.equal(
    (await f.owner.query('SELECT status FROM app.reservations WHERE period_id=$1', [period.id]))
      .rows[0].status,
    'operator_cancelled',
  );
  assert.equal(
    (
      await f.owner.query(
        'SELECT sum(delta_rides)::int n FROM app.ride_entries WHERE period_id=$1',
        [period.id],
      )
    ).rows[0].n,
    0,
  );
  assert.equal(
    (await f.owner.query('SELECT state FROM app.commute_slots WHERE id=$1', [s.id])).rows[0].state,
    'available',
  );
});
test('COM-14: stale edit tokens fail; page cursors bind owner and resource scope', async (t) => {
  const f = await fixture(t);
  await f.buy();
  const r = await f.request(),
    before = await f.requestRow(r.id);
  await f.decide(r.id, { action: 'waitlist' });
  await assert.rejects(
    f.command(
      'decideCommuteRequest',
      { action: 'reject', note: 'Test' },
      r.id,
      before.editToken,
      f.admin,
    ),
    code('precondition_failed'),
  );
  await f.decide(r.id, { action: 'reject' });
  await f.request();
  const page = (await f.membership.read(f.actor, 'listCommuteRequests', { limit: '1' }))
    .body as any;
  assert.ok(page.page.nextCursor);
  const second = (
    await f.membership.read(f.actor, 'listCommuteRequests', {
      limit: '1',
      cursor: page.page.nextCursor,
    })
  ).body as any;
  assert.equal(second.data[0].id, r.id);
  await assert.rejects(
    f.membership.read(f.other, 'listCommuteRequests', { cursor: page.page.nextCursor }),
    code('invalid_cursor'),
  );
  await assert.rejects(
    f.membership.read(f.actor, 'listReservations', { cursor: page.page.nextCursor }),
    code('invalid_cursor'),
  );
});
test('COM-15: direct SQL close cannot bypass funded service and leave accounting partly converted', async (t) => {
  const f = await fixture(t),
    { period } = await f.buy();
  await f.trip();
  await f.reserve();
  await assert.rejects(
    f.runtime.query("UPDATE app.billing_periods SET state='closed' WHERE id=$1", [period.id]),
    (e: any) => e.code === '23514' && e.message === 'period_has_unsettled_service',
  );
  assert.equal((await f.period(period.purchase_id)).state, 'open');
});
test('RES-07: unassigning the vehicle and moving funded departure outside coverage roll back trip and receipt', async (t) => {
  const f = await fixture(t);
  await f.buy();
  const trip = await f.trip();
  await f.reserve();
  const { TransportService, tripEditToken } = await import('../src/transport/service.js');
  const transport = new TransportService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 7),
    coordinateReservations: f.membership.coordinateReservations,
  });
  await assert.rejects(
    transport.command(
      f.admin,
      'assignTrip',
      trip.id,
      { driverId: trip.assigned_driver_id, vehicleId: null },
      randomUUID(),
      tripEditToken(trip),
    ),
    code('reserved_capacity'),
  );
  await assert.rejects(
    transport.command(
      f.admin,
      'rescheduleTrip',
      trip.id,
      { scheduledAt: '2026-02-03T06:30:00Z' },
      randomUUID(),
      tripEditToken(trip),
    ),
    code('funded_departure_outside_coverage'),
  );
  assert.equal(
    (await f.owner.query('SELECT vehicle_id FROM app.trips WHERE id=$1', [trip.id])).rows[0]
      .vehicle_id,
    trip.vehicle_id,
  );
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.transport_commands')).rows[0].n,
    0,
  );
});
async function fixture(t: TestContext) {
  const f = await setup(t);
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [f.adminId]);
  const admin = { userId: f.adminId, sessionId: f.adminId };
  let now = new Date(at);
  const membership = new MembershipService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 7),
    now: () => now,
    fareForSelection: async () => 600,
  });
  const financial = new FinancialFoundation({
    ...f.dependencies,
    assertCheckoutAllowed: membership.assertCheckoutAllowed,
    assertPeriodCanClose: membership.assertPeriodCanClose,
    materializeAssignment: membership.materializeAssignment,
  });
  const buy = async (actor = f.actor) => {
    const p = await financial.checkout(actor, f.input, randomUUID(), now);
    assert.equal(await financial.fulfill(f.settle(p, now)), 'fulfilled');
    return { purchase: p, period: await f.period(p.id) };
  };
  const command = async (
    op: MembershipOperation,
    input: Record<string, unknown> = {},
    target?: string,
    match?: string,
    actor: Actor = f.actor,
    key = randomUUID(),
  ) => data(await membership.command(actor, op, target, input as Body, key, match));
  const request = (actor = f.actor) =>
    command(
      'createCommuteRequest',
      {
        routeId: f.input.routeId,
        legs: f.input.legs,
        requestedDate: '2026-01-02',
        pauseIfWaitlisted: true,
      },
      undefined,
      undefined,
      actor,
    );
  const slot = () =>
    command(
      'createCommuteSlot',
      { routeId: f.input.routeId, legs: f.input.legs, availableFrom: '2026-01-02' },
      undefined,
      undefined,
      admin,
    );
  const requestRow = async (requestId: string) =>
    data(await membership.read(admin, 'listOpsCommuteRequests')).find(
      (r: any) => r.id === requestId,
    );
  const decide = async (requestId: string, input: Record<string, unknown>, key = randomUUID()) =>
    command(
      'decideCommuteRequest',
      { note: 'Test operations decision', ...input },
      requestId,
      (await requestRow(requestId)).editToken,
      admin,
      key,
    );
  const trip = async (capacity = 1, day = '2026-01-02') => {
    const vehicle = (
      await f.owner.query('INSERT INTO app.vehicles(plate,capacity) VALUES ($1,$2) RETURNING id', [
        randomUUID().slice(0, 8).toUpperCase(),
        capacity,
      ])
    ).rows[0].id;
    const driver = (
      await f.owner.query(
        "INSERT INTO app.drivers(name) VALUES ('Membership fixture') RETURNING id",
      )
    ).rows[0].id;
    return (
      await f.owner.query(
        `INSERT INTO app.trips(schedule_id,departure_id,pattern_version_id,service_date,scheduled_at,assigned_driver_id,vehicle_id)
      SELECT id,departure_id,pattern_version_id,$2::date,$2::date+local_departure,$3,$4 FROM app.service_schedules WHERE id=$1 RETURNING *`,
        [f.input.legs[0]!.scheduleId, day, driver, vehicle],
      )
    ).rows[0];
  };
  const reserve = (actor = f.actor, key = randomUUID()) =>
    command(
      'decideReservation',
      { travelDate: '2026-01-02', direction: 'outbound', decision: 'confirm' },
      undefined,
      undefined,
      actor,
      key,
    );
  return {
    ...f,
    admin,
    membership,
    financial,
    buy,
    command,
    request,
    slot,
    requestRow,
    decide,
    trip,
    reserve,
    setNow: (d: string) => {
      now = new Date(d);
    },
  };
}

test('COM-01: payment fulfilment materializes owned immutable commute; submission does not change it', async (t) => {
  const f = await fixture(t),
    { period } = await f.buy();
  const before = (await f.owner.query('SELECT * FROM app.commute_assignments')).rows;
  assert.equal(before.length, 1);
  assert.equal(before[0].period_id, period.id);
  const r = await f.request();
  assert.equal(r.status, 'submitted');
  assert.equal(r.requested.requestedDate, '2026-01-02');
  assert.deepEqual((await f.owner.query('SELECT * FROM app.commute_assignments')).rows, before);
  await assert.rejects(f.request(), code('duplicate_resource'));
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.commute_requests')).rows[0].n,
    1,
  );
  await assert.rejects(
    f.runtime.query('UPDATE app.commute_selection_legs SET direction=direction'),
    (e: any) => e.code === '42501',
  );
  const m = data(await f.membership.read(f.actor, 'getMembership'));
  assert.equal(m.commute.id, before[0].id);
  assert.equal(m.access.canReserve, true);
  assert.equal(m.entitlements.remainingRides, 44);
});
test('COM-02: two actual competing approvals can claim only one transfer slot', async (t) => {
  const f = await fixture(t);
  await f.buy();
  await f.buy(f.other);
  const a = await f.request(),
    b = await f.request(f.other),
    s = await f.slot();
  const blocker = await f.owner.connect();
  await blocker.query('BEGIN');
  await blocker.query('SELECT id FROM app.commute_slots WHERE id=$1 FOR UPDATE', [s.id]);
  const input = { action: 'approve', slotId: s.id, effectiveDate: '2026-01-02' };
  const results = Promise.allSettled([f.decide(a.id, input), f.decide(b.id, input)]);
  try {
    await f.waiters(2);
  } finally {
    await blocker.query('COMMIT');
    blocker.release();
  }
  const out = await results;
  assert.equal(out.filter((r) => r.status === 'fulfilled').length, 1);
  assert.equal(out.filter((r) => r.status === 'rejected').length, 1);
  assert.deepEqual(
    (
      await f.owner.query(
        "SELECT count(*)::int n FROM app.commute_requests WHERE status='approved'",
      )
    ).rows[0],
    { n: 1 },
  );
  assert.equal(
    (await f.owner.query('SELECT state FROM app.commute_slots WHERE id=$1', [s.id])).rows[0].state,
    'held',
  );
});
test('COM-03: pause blocks booking, checkout and close; resume extends only effective end exactly once', async (t) => {
  const f = await fixture(t),
    { period } = await f.buy();
  await f.trip();
  await f.reserve();
  const r = await f.request();
  await f.decide(r.id, { action: 'waitlist' });
  await f.decide(r.id, { action: 'pause' });
  const m = data(await f.membership.read(f.actor, 'getMembership'));
  assert.equal(m.coverage.endsAt, null);
  assert.equal(m.access.canReserve, false);
  assert.equal(
    (await f.owner.query('SELECT status FROM app.reservations')).rows[0].status,
    'operator_cancelled',
  );
  await assert.rejects(f.reserve(), code('membership_blocked'));
  await assert.rejects(
    f.financial.checkout(f.actor, f.input, randomUUID(), renewAt),
    code('membership_blocked'),
  );
  await assert.rejects(f.financial.closePeriod(period.id, renewAt), code('period_paused'));
  await assert.rejects(f.command('withdrawCommuteRequest', {}, r.id), code('resume_required'));
  f.setNow('2026-01-04T00:00:00Z');
  const key = randomUUID();
  await f.decide(r.id, { action: 'resume' }, key);
  await f.decide(r.id, { action: 'resume' }, key);
  const after = await f.period(period.purchase_id);
  assert.equal(after.original_ends_at.toISOString(), period.original_ends_at.toISOString());
  assert.equal(
    after.effective_ends_at.getTime() - period.effective_ends_at.getTime(),
    3 * 86400000,
  );
  assert.equal(
    (await f.owner.query('SELECT sum(delta_rides)::int n FROM app.ride_entries')).rows[0].n,
    44,
  );
});
test('COM-04: approval never changes assignment; apply is explicit, cancels seats, preserves purchased terms', async (t) => {
  const f = await fixture(t),
    { purchase } = await f.buy();
  await f.trip();
  await f.reserve();
  const before = (await f.owner.query('SELECT * FROM app.purchases WHERE id=$1', [purchase.id]))
    .rows[0];
  const r = await f.request(),
    s = await f.slot();
  await f.decide(r.id, { action: 'approve', slotId: s.id, effectiveDate: '2026-01-02' });
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.commute_assignments')).rows[0].n,
    1,
  );
  await assert.rejects(f.decide(r.id, { action: 'apply' }), code('application_not_due'));
  f.setNow('2026-01-02T00:00:00Z');
  const key = randomUUID();
  await f.decide(r.id, { action: 'apply' }, key);
  await f.decide(r.id, { action: 'apply' }, key);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.commute_assignments')).rows[0].n,
    2,
  );
  assert.equal(
    (await f.owner.query('SELECT status FROM app.reservations')).rows[0].status,
    'operator_cancelled',
  );
  assert.deepEqual(
    (await f.owner.query('SELECT * FROM app.purchases WHERE id=$1', [purchase.id])).rows[0],
    before,
  );
});
test('COM-05: unknown fare and active service refuse apply/pause without releasing seats', async (t) => {
  const f = await fixture(t);
  await f.buy();
  const trip = await f.trip();
  await f.reserve();
  const r = await f.request();
  await f.decide(r.id, { action: 'waitlist' });
  f.setNow('2026-01-02T07:00:00Z');
  await assert.rejects(f.decide(r.id, { action: 'pause' }), code('service_unsettled'));
  assert.equal(
    (await f.owner.query('SELECT status FROM app.reservations WHERE trip_id=$1', [trip.id])).rows[0]
      .status,
    'reserved',
  );
  const s = await f.slot();
  await f.decide(r.id, { action: 'approve', slotId: s.id, effectiveDate: '2026-01-02' });
  const unpriced = new MembershipService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 7),
    now: () => new Date('2026-01-02T07:00:00Z'),
  });
  await assert.rejects(
    unpriced.command(
      f.admin,
      'decideCommuteRequest',
      r.id,
      { action: 'apply', note: 'Test' },
      randomUUID(),
      (await f.requestRow(r.id)).editToken,
    ),
    code('fare_review_required'),
  );
});
test('COM-06: period close invalidates open approval and releases its slot atomically', async (t) => {
  const f = await fixture(t),
    { period } = await f.buy(),
    r = await f.request(),
    s = await f.slot();
  await f.decide(r.id, { action: 'approve', slotId: s.id, effectiveDate: '2026-01-02' });
  assert.equal(await f.financial.closePeriod(period.id, renewAt), true);
  assert.equal((await f.requestRow(r.id)).status, 'cancelled');
  assert.equal(
    (await f.owner.query('SELECT state FROM app.commute_slots WHERE id=$1', [s.id])).rows[0].state,
    'available',
  );
  assert.equal(
    (
      await f.owner.query(
        'SELECT count(*)::int n FROM app.commute_assignments WHERE effective_to IS NULL',
      )
    ).rows[0].n,
    0,
  );
});
test('COM-08/09: foreign withdrawal, self approval, invalid legs and revoked replay are refused', async (t) => {
  const f = await fixture(t);
  await f.buy();
  const r = await f.request();
  await assert.rejects(
    f.command('withdrawCommuteRequest', {}, r.id, undefined, f.other),
    code('not_found'),
  );
  await assert.rejects(
    f.command('decideCommuteRequest', { action: 'waitlist', note: 'Test' }, r.id),
    code('forbidden'),
  );
  await assert.rejects(
    f.command(
      'createCommuteSlot',
      {
        routeId: f.input.routeId,
        legs: f.input.legs.map((l) => ({
          ...l,
          pickupOccurrenceId: l.dropoffOccurrenceId,
          dropoffOccurrenceId: l.pickupOccurrenceId,
        })),
        availableFrom: '2026-01-02',
      },
      undefined,
      undefined,
      f.admin,
    ),
    code('transport_conflict'),
  );
  const key = randomUUID();
  await f.command('withdrawCommuteRequest', {}, r.id, undefined, f.actor, key);
  await f.owner.query('UPDATE app.test_fin_sessions SET active=false WHERE user_id=$1', [
    f.actor.userId,
  ]);
  await assert.rejects(
    f.command('withdrawCommuteRequest', {}, r.id, undefined, f.actor, key),
    code('unauthenticated'),
  );
});
test('RES-01/02: concurrent last-seat confirmation holds one seat, re-confirm does not consume capacity', async (t) => {
  const f = await fixture(t);
  await f.buy();
  await f.buy(f.other);
  const trip = await f.trip();
  const blocker = await f.owner.connect();
  await blocker.query('BEGIN');
  await blocker.query('SELECT id FROM app.trips WHERE id=$1 FOR UPDATE', [trip.id]);
  const results = Promise.allSettled([f.reserve(), f.reserve(f.other)]);
  try {
    await f.waiters(2);
  } finally {
    await blocker.query('COMMIT');
    blocker.release();
  }
  const out = await results;
  assert.equal(out.filter((r) => r.status === 'fulfilled').length, 1);
  const row = (await f.owner.query('SELECT * FROM app.reservations')).rows[0];
  const actor = row.user_id === f.actor.userId ? f.actor : f.other;
  const next = await f.reserve(actor);
  assert.equal(next.reservation.id, row.id);
  assert.equal(next.pass, null);
  assert.equal((await f.owner.query('SELECT count(*)::int n FROM app.reservations')).rows[0].n, 1);
});
test('RES-03: decline needs no coverage or rides and can be re-answered after purchase', async (t) => {
  const f = await fixture(t);
  const d = await f.command('decideReservation', {
    travelDate: '2026-01-02',
    direction: 'outbound',
    decision: 'decline',
  });
  assert.equal(d.reservation.status, 'declined');
  await f.buy();
  await f.trip();
  assert.equal((await f.reserve()).reservation.id, d.reservation.id);
});
test('RES-06: unsettled reservation blocks close; real transport cancellation releases it without ledger entries', async (t) => {
  const f = await fixture(t),
    { period } = await f.buy(),
    trip = await f.trip();
  await f.reserve();
  await assert.rejects(
    f.financial.closePeriod(period.id, renewAt),
    code('period_service_unsettled'),
  );
  const { TransportService, tripEditToken } = await import('../src/transport/service.js');
  const transport = new TransportService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 7),
    coordinateReservations: f.membership.coordinateReservations,
  });
  await transport.command(
    f.admin,
    'cancelTrip',
    trip.id,
    { reason: 'Test cancelled service' },
    randomUUID(),
    tripEditToken(trip),
  );
  assert.equal(
    (await f.owner.query('SELECT status FROM app.reservations')).rows[0].status,
    'operator_cancelled',
  );
  assert.equal((await f.owner.query('SELECT count(*)::int n FROM app.ride_entries')).rows[0].n, 1);
  assert.equal(await f.financial.closePeriod(period.id, renewAt), true);
});
test('COM-10: independent account restriction blocks booking until explicitly released; nested ownership checked', async (t) => {
  const f = await fixture(t);
  await f.buy();
  await f.trip();
  const r = await f.command(
    'createAccountRestriction',
    { reason: 'Test review', reviewAt: '2026-01-05T00:00:00Z' },
    f.actor.userId,
    undefined,
    f.admin,
  );
  await assert.rejects(f.reserve(), code('membership_blocked'));
  await assert.rejects(
    f.membership.command(
      f.admin,
      'releaseAccountRestriction',
      r.id,
      { reason: 'Resolved' },
      randomUUID(),
      r.editToken,
      f.other.userId,
    ),
    code('not_found'),
  );
  await f.command('releaseAccountRestriction', { reason: 'Resolved' }, r.id, r.editToken, f.admin);
  assert.equal((await f.reserve()).reservation.status, 'reserved');
});
test('COM-11: failed event write rolls back pause, reservation release and receipt together', async (t) => {
  const f = await fixture(t);
  await f.buy();
  await f.trip();
  await f.reserve();
  const r = await f.request();
  await f.decide(r.id, { action: 'waitlist' });
  await f.owner
    .query(`CREATE FUNCTION app.test_event_failure() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'injected'; END $$;
    CREATE TRIGGER test_event_failure BEFORE INSERT ON app.membership_events FOR EACH ROW EXECUTE FUNCTION app.test_event_failure()`);
  const key = randomUUID();
  await assert.rejects(f.decide(r.id, { action: 'pause' }, key), code('internal_error'));
  assert.equal(
    (await f.owner.query('SELECT count(*)::int n FROM app.membership_pauses')).rows[0].n,
    0,
  );
  assert.equal(
    (await f.owner.query('SELECT status FROM app.reservations')).rows[0].status,
    'reserved',
  );
  await f.owner.query('DROP TRIGGER test_event_failure ON app.membership_events');
  assert.equal((await f.decide(r.id, { action: 'pause' }, key)).paused, true);
});
test('COM-12: HTTP contract exposes commuter membership and ops edit tokens; no unsupported body/filter/foreign access', async (t) => {
  const f = await fixture(t);
  await f.buy();
  const app = await createTransportApp({
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 7),
    authorizeSession: f.dependencies.authorizeSession,
    coordinateReservations: f.membership.coordinateReservations,
    membership: f.membership,
    verifyAccess: async (h) =>
      h === 'Bearer rider' ? f.actor : h === 'Bearer ops' ? f.admin : null,
    minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
  });
  t.after(() => app.close());
  const rider = {
    authorization: 'Bearer rider',
    'x-trotxi-client': 'commuter',
    'x-trotxi-build': '1',
    'x-trotxi-platform': 'android',
  };
  const admin = { authorization: 'Bearer ops', 'x-trotxi-client': 'ops', 'x-trotxi-build': '1' };
  const m = await app.inject({ url: '/v1/me/membership', headers: rider });
  assert.equal(m.statusCode, 200, m.body);
  assert.equal(m.json().data.entitlements.remainingRides, 44);
  const slot = await app.inject({
    method: 'POST',
    url: '/v1/ops/commute-slots',
    headers: { ...admin, 'idempotency-key': randomUUID() },
    payload: { routeId: f.input.routeId, legs: f.input.legs, availableFrom: '2026-01-02' },
  });
  assert.equal(slot.statusCode, 201, slot.body);
  assert.ok(slot.json().data.editToken);
  const list = await app.inject({ url: '/v1/ops/commute-slots', headers: admin });
  assert.equal(list.statusCode, 200, list.body);
  assert.equal(list.json().data[0].editToken, slot.json().data.editToken);
  const denied = await app.inject({
    url: '/v1/ops/commute-slots',
    headers: { ...admin, authorization: 'Bearer rider' },
  });
  assert.equal(denied.statusCode, 403, denied.body);
  assert.equal(
    (await app.inject({ url: '/v1/ops/commute-slots?state=held', headers: admin })).statusCode,
    400,
  );
});
