import { test } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { setup, at } from './helpers/financial-fixture.js';
import { MembershipService } from '../src/membership/service.js';
import { FinancialFoundation } from '../src/payments/foundation.js';
import { createTransportApp } from '../src/http/app.js';
import { TransportError } from '../src/transport/errors.js';
import type { Actor } from '../src/transport/service.js';

type Response = { statusCode: number; body: string; json(): any };
function expectStatus(response: Response, code: number) {
  assert.equal(response.statusCode, code, response.body);
  return response.json().data;
}

/** A paid rider on a published corridor, a driver, and an HTTP surface. */
async function fixture(t: TestContext) {
  const f = await setup(t);
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [f.adminId]);
  const admin = { userId: f.adminId, sessionId: f.adminId };
  const now = new Date(at);
  const membership = new MembershipService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 9),
    now: () => now,
    fareForSelection: async () => 600,
  });
  const financial = new FinancialFoundation({
    ...f.dependencies,
    assertCheckoutAllowed: membership.assertCheckoutAllowed,
    assertPeriodCanClose: membership.assertPeriodCanClose,
    materializeAssignment: membership.materializeAssignment,
  });
  const buy = async (who: Actor = f.actor) => {
    const p = await financial.checkout(who, f.input, randomUUID(), now);
    assert.equal(await financial.fulfill(f.settle(p, now)), 'fulfilled');
    return f.period(p.id);
  };
  /** A driver with a real account, so the assigned-driver grant is testable. */
  const driverUser = (
    await f.owner.query("INSERT INTO app.users(role) VALUES ('driver') RETURNING id")
  ).rows[0].id;
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [driverUser]);
  const driverId = (
    await f.owner.query(
      "INSERT INTO app.drivers(user_id,name) VALUES ($1,'Trip fixture') RETURNING id",
      [driverUser],
    )
  ).rows[0].id;
  const outbound = f.input.legs[0]!;

  const trip = async (options: { day?: string; status?: string; scheduleId?: string } = {}) => {
    const scheduleId = options.scheduleId ?? outbound.scheduleId;
    const vehicle = (
      await f.owner.query(
        "INSERT INTO app.vehicles(plate,capacity,label) VALUES ($1,20,'Bus 7') RETURNING id",
        [randomUUID().slice(0, 8).toUpperCase()],
      )
    ).rows[0].id;
    const row = (
      await f.owner.query(
        `INSERT INTO app.trips(schedule_id,departure_id,pattern_version_id,service_date,scheduled_at,assigned_driver_id,vehicle_id)
        SELECT id,departure_id,pattern_version_id,$2::date,$2::date+local_departure,$3,$4
        FROM app.service_schedules WHERE id=$1 RETURNING *`,
        [scheduleId, options.day ?? '2026-01-02', driverId, vehicle],
      )
    ).rows[0];
    if (options.status === 'active' || options.status === 'completed')
      await f.owner.query(
        "UPDATE app.trips SET status='active',started_at=clock_timestamp() WHERE id=$1",
        [row.id],
      );
    if (options.status === 'completed')
      await f.owner.query(
        "UPDATE app.trips SET status='completed',completed_at=clock_timestamp() WHERE id=$1",
        [row.id],
      );
    if (options.status === 'cancelled')
      await f.owner.query("UPDATE app.trips SET status='cancelled' WHERE id=$1", [row.id]);
    return row;
  };
  /** A live marker a given number of metres along the published line. */
  const place = async (tripId: string, metres: number, agoSeconds = 0) => {
    const position = (
      await f.owner.query(
        `INSERT INTO app.trip_positions
          (trip_id,client_fix_id,captured_at,effective_captured_at,received_at,location,payload_digest)
        SELECT $1,gen_random_uuid(),statement_timestamp()-make_interval(secs => $3),
          statement_timestamp()-make_interval(secs => $3),statement_timestamp(),
          ST_LineInterpolatePoint(g.line,LEAST(1,$2::float8/ST_Length(g.line::geography))),
          encode(sha256(gen_random_uuid()::text::bytea),'hex')
        FROM app.trips t
        JOIN app.route_pattern_versions v ON v.id=t.pattern_version_id
        JOIN app.route_geometries g ON g.id=v.geometry_id
        WHERE t.id=$1 RETURNING id`,
        [tripId, metres, agoSeconds],
      )
    ).rows[0].id;
    await f.owner.query(
      `INSERT INTO app.trip_live_positions(trip_id,position_id,effective_captured_at,received_at,location)
      SELECT trip_id,id,effective_captured_at,received_at,location FROM app.trip_positions WHERE id=$1
      ON CONFLICT (trip_id) DO UPDATE SET position_id=EXCLUDED.position_id,
        effective_captured_at=EXCLUDED.effective_captured_at,received_at=EXCLUDED.received_at,
        location=EXCLUDED.location,updated_at=clock_timestamp()`,
      [position],
    );
  };
  /** A second published corridor, so "only this route" means something. */
  const corridor = async (name: string) => {
    const one = async (sql: string, args: unknown[] = []) =>
      (await f.owner.query(sql + ' RETURNING id', args)).rows[0].id as string;
    const route = await one('INSERT INTO app.routes(name) VALUES ($1)', [name]);
    const pattern = await one(
      "INSERT INTO app.route_patterns(route_id,direction) VALUES ($1,'outbound')",
      [route],
    );
    const version = await one(
      'INSERT INTO app.route_pattern_versions(pattern_id,revision) VALUES ($1,1)',
      [pattern],
    );
    const physical = await one(
      'INSERT INTO app.stops(name,latitude,longitude) VALUES ($1,5.6,-0.2)',
      [name],
    );
    const occurrences: string[] = [];
    for (let ordinal = 0; ordinal < 2; ordinal++)
      occurrences.push(
        await one(
          `INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude)
          VALUES ($1,$2,$3,$4,5.6,-0.2)`,
          [version, physical, ordinal, name],
        ),
      );
    const geometry = await one(
      `INSERT INTO app.route_geometries(pattern_version_id,source,line)
      VALUES ($1,'configured',ST_GeomFromText('LINESTRING(-0.2 5.6,-0.21 5.6,-0.2 5.6)',4326))`,
      [version],
    );
    for (const [index, occurrence] of occurrences.entries())
      await f.owner.query('INSERT INTO app.geometry_stop_distances VALUES ($1,$2,$3,$4)', [
        geometry,
        version,
        occurrence,
        index * 1000,
      ]);
    await f.owner.query("UPDATE app.route_geometries SET state='published' WHERE id=$1", [
      geometry,
    ]);
    await f.owner.query(
      `UPDATE app.route_pattern_versions
      SET state='published',geometry_id=$2,effective_from='2025-01-01' WHERE id=$1`,
      [version, geometry],
    );
    const departure = await one('INSERT INTO app.service_departures(pattern_id) VALUES ($1)', [
      pattern,
    ]);
    const schedule = await one(
      `INSERT INTO app.service_schedules(departure_id,pattern_id,pattern_version_id,service_window,local_departure,weekdays,effective_from)
      VALUES ($1,$2,$3,'morning','07:30',ARRAY[1,2,3,4,5,6,7]::smallint[],'2025-01-01')`,
      [departure, pattern, version],
    );
    return { routeId: route, scheduleId: schedule, patternVersionId: version };
  };
  /** Drive a request to a consented pause, the way ops would. */
  const pauseCoverage = async () => {
    const data = (o: any) => (o.body as any).data;
    const request = data(
      await membership.command(
        f.actor,
        'createCommuteRequest',
        undefined,
        {
          routeId: f.input.routeId,
          legs: f.input.legs,
          requestedDate: '2026-01-02',
          pauseIfWaitlisted: true,
        } as never,
        randomUUID(),
      ),
    );
    for (const action of ['waitlist', 'pause']) {
      const current = data(await membership.read(admin, 'listOpsCommuteRequests')).find(
        (r: any) => r.id === request.id,
      );
      await membership.command(
        admin,
        'decideCommuteRequest',
        request.id,
        { action, note: 'Trip fixture decision' } as never,
        randomUUID(),
        current.editToken,
      );
    }
    return request.id as string;
  };
  const app = await createTransportApp({
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 9),
    authorizeSession: f.dependencies.authorizeSession,
    coordinateReservations: membership.coordinateReservations,
    membership,
    verifyAccess: async (header) =>
      ({
        'Bearer rider': f.actor,
        'Bearer other': f.other,
        'Bearer ops': admin,
        'Bearer driver': { userId: driverUser, sessionId: driverUser },
      })[header as string] ?? null,
    minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
  });
  t.after(() => app.close());
  const get = (path: string, who = 'rider') =>
    app.inject({
      method: 'GET',
      url: path,
      headers: {
        ...(who === 'none' ? {} : { authorization: `Bearer ${who}` }),
        'x-trotxi-client': who === 'ops' ? 'ops' : who === 'driver' ? 'driver' : 'commuter',
        'x-trotxi-build': '1',
        ...(who === 'ops' ? {} : { 'x-trotxi-platform': 'android' }),
      },
    }) as Promise<Response>;
  return {
    ...f,
    admin,
    membership,
    financial,
    buy,
    trip,
    place,
    corridor,
    pauseCoverage,
    get,
    driverId,
    driverUser,
  };
}

test('TRP-01 the trip list is for signed-in riders, live corridors only, in departure order', async (t) => {
  const f = await fixture(t);
  await f.buy();
  const first = await f.trip({ day: '2026-01-02' });
  const second = await f.trip({ day: '2026-01-03' });
  const elsewhere = await f.corridor('Second corridor');
  const other = await f.trip({ day: '2026-01-02', scheduleId: elsewhere.scheduleId });

  assert.equal((await f.get('/v1/trips', 'none')).statusCode, 401);
  const listed = expectStatus(await f.get('/v1/trips'), 200);
  assert.deepEqual(
    listed.map((x: any) => x.id),
    [first.id, other.id, second.id],
    'every published departure, earliest first, across corridors',
  );
  assert.equal(listed[0].vehicleLabel, 'Bus 7');
  assert.equal('assignedDriverId' in listed[0], false, 'the catalogue never names the driver');
  assert.equal('vehicleId' in listed[0], false);

  assert.deepEqual(
    expectStatus(await f.get(`/v1/trips?routeId=${elsewhere.routeId}`), 200).map((x: any) => x.id),
    [other.id],
    'one corridor means one corridor',
  );
  assert.deepEqual(
    expectStatus(await f.get('/v1/trips?fromDate=2026-01-03&toDate=2026-01-03'), 200).map(
      (x: any) => x.id,
    ),
    [second.id],
  );
  assert.equal((await f.get('/v1/trips?fromDate=2026-13-01')).statusCode, 400);
  assert.equal((await f.get('/v1/trips?fromDate=2026-01-05&toDate=2026-01-01')).statusCode, 400);

  // An archived corridor takes its departures out of the catalogue with it.
  await f.owner.query('UPDATE app.routes SET archived_at=clock_timestamp() WHERE id=$1', [
    elsewhere.routeId,
  ]);
  assert.deepEqual(
    expectStatus(await f.get('/v1/trips'), 200).map((x: any) => x.id),
    [first.id, second.id],
  );
});

test('TRP-02 a cursor belongs to the query that issued it', async (t) => {
  const f = await fixture(t);
  await f.buy();
  for (const day of ['2026-01-02', '2026-01-03', '2026-01-04']) await f.trip({ day });
  const page = await f.get('/v1/trips?limit=1');
  const cursor = page.json().page.nextCursor;
  assert.ok(cursor, 'three departures do not fit one page');
  assert.equal(
    expectStatus(await f.get(`/v1/trips?limit=1&cursor=${encodeURIComponent(cursor)}`), 200)[0].id,
    (await f.get('/v1/trips?limit=2')).json().data[1].id,
    'the next page continues where the first stopped',
  );
  // The same cursor under a different filter would silently hide departures.
  assert.equal(
    (await f.get(`/v1/trips?limit=1&fromDate=2026-01-03&cursor=${encodeURIComponent(cursor)}`))
      .statusCode,
    400,
  );
});

test('TRP-03 getTrip is the catalogue view, and archived service is absent', async (t) => {
  const f = await fixture(t);
  await f.buy();
  const row = await f.trip({ status: 'active' });
  const data = expectStatus(await f.get(`/v1/trips/${row.id}`), 200);
  assert.partialDeepStrictEqual(data, {
    id: row.id,
    serviceDate: '2026-01-02',
    runNumber: 1,
    direction: 'outbound',
    status: 'active',
    vehicleLabel: 'Bus 7',
  });
  assert.equal((await f.get(`/v1/trips/${randomUUID()}`)).statusCode, 404);
  assert.equal((await f.get('/v1/trips/not-a-uuid')).statusCode, 404);

  const elsewhere = await f.corridor('Archived corridor');
  const doomed = await f.trip({ day: '2026-01-05', scheduleId: elsewhere.scheduleId });
  assert.equal((await f.get(`/v1/trips/${doomed.id}`)).statusCode, 200);
  await f.owner.query('UPDATE app.routes SET archived_at=clock_timestamp() WHERE id=$1', [
    elsewhere.routeId,
  ]);
  assert.equal(
    (await f.get(`/v1/trips/${doomed.id}`)).statusCode,
    404,
    'an archived corridor takes its departures with it',
  );
});

test('TRP-04 live position is for people entitled to watch this run', async (t) => {
  const f = await fixture(t);
  const period = await f.buy();
  const row = await f.trip({ status: 'active' });
  await f.place(row.id, 100);
  const live = (who: string) => f.get(`/v1/trips/${row.id}/live`, who);

  // A funded commute on this corridor is enough; a booking is not required.
  const watching = expectStatus(await live('rider'), 200);
  assert.equal(watching.state, 'live');
  assert.equal(watching.riderPickupOccurrenceId, f.input.legs[0]!.pickupOccurrenceId);
  // Ops and the assigned driver see it; neither of them boards anywhere.
  for (const who of ['ops', 'driver'])
    assert.equal(expectStatus(await live(who), 200).riderPickupOccurrenceId, null);
  assert.equal((await live('none')).statusCode, 401);
  assert.equal((await live('other')).statusCode, 404, 'no coverage, no location');

  // Every withdrawal of entitlement is the same 404, and none of them explain.
  const blocked = async (label: string) =>
    assert.equal((await live('rider')).statusCode, 404, label);
  const request = await f.pauseCoverage();
  assert.equal(
    (await f.owner.query('SELECT 1 FROM app.membership_pauses WHERE request_id=$1', [request]))
      .rowCount,
    1,
    'the fixture really paused something',
  );
  await blocked('paused coverage');
  const current = (f.membership as never as { read: Function }).read;
  void current;
  await f.membership.command(
    f.admin,
    'decideCommuteRequest',
    request,
    { action: 'resume', note: 'Trip fixture resume' } as never,
    randomUUID(),
    ((await f.membership.read(f.admin, 'listOpsCommuteRequests')).body as any).data.find(
      (r: any) => r.id === request,
    ).editToken,
  );
  assert.equal((await live('rider')).statusCode, 200, 'resuming restores the view');

  const restriction = (
    await f.owner.query(
      `INSERT INTO app.account_restrictions(user_id,actor_user_id,reason,review_at)
      VALUES ($1,$2,'under review',clock_timestamp()+interval '30 days') RETURNING id`,
      [f.actor.userId, f.adminId],
    )
  ).rows[0].id;
  await blocked('account restriction');
  await f.owner.query(
    `UPDATE app.account_restrictions SET released_at=clock_timestamp(),released_by=$2,
      release_reason='cleared' WHERE id=$1`,
    [restriction, f.adminId],
  );
  assert.equal((await live('rider')).statusCode, 200, 'and releasing it restores the view');

  // A seat held on this very run stands on its own: a rider whose commute has
  // since moved elsewhere still watches the bus they are booked on. Booking
  // happens while the departure is still scheduled, as it does in service.
  const booked = await f.trip({ day: '2026-01-03' });
  await f.membership.command(
    f.actor,
    'decideReservation',
    undefined,
    { travelDate: '2026-01-03', direction: 'outbound', decision: 'confirm' } as never,
    randomUUID(),
  );
  await f.owner.query(
    "UPDATE app.trips SET status='active',started_at=clock_timestamp() WHERE id=$1",
    [booked.id],
  );
  await f.place(booked.id, 150);
  await f.owner.query(
    'UPDATE app.commute_assignments SET effective_to=$2::date WHERE period_id=$1 AND effective_to IS NULL',
    [period.id, '2026-01-02'],
  );
  assert.equal((await live('rider')).statusCode, 404, 'the commute no longer covers this run');
  const seat = expectStatus(await f.get(`/v1/trips/${booked.id}/live`), 200);
  assert.equal(seat.riderPickupOccurrenceId, f.input.legs[0]!.pickupOccurrenceId);
  await f.owner.query("UPDATE app.reservations SET status='declined' WHERE user_id=$1", [
    f.actor.userId,
  ]);
  assert.equal(
    (await f.get(`/v1/trips/${booked.id}/live`)).statusCode,
    404,
    'a declined seat confers nothing',
  );
});

test('TRP-05 a run reports what it is doing, and never predicts from a stale fix', async (t) => {
  const f = await fixture(t);
  await f.buy();
  const shape = (data: any) => ({
    state: data.state,
    position: data.position === null ? null : 'present',
    etas: data.etas.length > 0,
  });
  const live = async (row: { id: string }) =>
    shape(expectStatus(await f.get(`/v1/trips/${row.id}/live`), 200));

  assert.deepEqual(await live(await f.trip({ day: '2026-01-02' })), {
    state: 'not_started',
    position: null,
    etas: false,
  });
  assert.deepEqual(await live(await f.trip({ day: '2026-01-03', status: 'active' })), {
    state: 'awaiting_fix',
    position: null,
    etas: false,
  });

  const running = await f.trip({ day: '2026-01-04', status: 'active' });
  await f.place(running.id, 100);
  const fresh = expectStatus(await f.get(`/v1/trips/${running.id}/live`), 200);
  assert.deepEqual(shape(fresh), { state: 'live', position: 'present', etas: true });
  assert.ok(fresh.position.ageSeconds <= 2, String(fresh.position.ageSeconds));
  assert.ok(fresh.serverTime > fresh.position.capturedAt);

  // A fix the projection is still showing, but old enough to be labelled.
  const lagging = await f.trip({ day: '2026-01-05', status: 'active' });
  await f.place(lagging.id, 200, 60);
  assert.deepEqual(await live(lagging), { state: 'stale', position: 'present', etas: true });

  const ancient = await f.trip({ day: '2026-01-06', status: 'active' });
  await f.place(ancient.id, 300, 130);
  assert.deepEqual(
    await live(ancient),
    { state: 'stale', position: 'present', etas: false },
    'the marker and its age still go out; a predicted arrival does not',
  );

  const done = await f.trip({ day: '2026-01-07', status: 'active' });
  await f.place(done.id, 400);
  await f.owner.query(
    "UPDATE app.trips SET status='completed',completed_at=clock_timestamp() WHERE id=$1",
    [done.id],
  );
  assert.deepEqual(await live(done), { state: 'ended', position: null, etas: false });
});

test('TRP-06 an estimate says what it was built from', async (t) => {
  const f = await fixture(t);
  await f.buy();
  const run = await f.trip({ status: 'active' });
  await f.place(run.id, 0);
  const fallback = expectStatus(await f.get(`/v1/trips/${run.id}/live`), 200).etas;
  assert.equal(fallback.length, 1, 'one stop lies ahead of the origin');
  assert.equal(fallback[0].basis, 'fallback', 'nothing has been learned here yet');
  assert.ok(Math.abs(fallback[0].distanceMeters - 1000) < 20, fallback[0].distanceMeters);
  assert.ok(Math.abs(fallback[0].durationSeconds - 1000 / 6) < 5, fallback[0].durationSeconds);

  // Two runs is not yet evidence, so the estimate still says it fell back.
  const learn = (samples: number) =>
    f.owner.query(
      `INSERT INTO app.segment_speeds
        (pattern_version_id,service_window,from_ordinal,metres_per_second,sample_count,geometry_id)
      SELECT v.id,'morning',0,4,$2,v.geometry_id FROM app.route_pattern_versions v WHERE v.id=$1
      ON CONFLICT (pattern_version_id,service_window,from_ordinal) DO UPDATE
        SET metres_per_second=EXCLUDED.metres_per_second,sample_count=EXCLUDED.sample_count`,
      [run.pattern_version_id, samples],
    );
  await learn(2);
  assert.equal(
    expectStatus(await f.get(`/v1/trips/${run.id}/live`), 200).etas[0].basis,
    'fallback',
  );
  await learn(3);
  const observed = expectStatus(await f.get(`/v1/trips/${run.id}/live`), 200).etas[0];
  assert.equal(observed.basis, 'observed');
  assert.ok(Math.abs(observed.durationSeconds - 1000 / 4) < 5, observed.durationSeconds);
});
