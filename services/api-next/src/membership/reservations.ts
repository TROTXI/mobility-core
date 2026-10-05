// Reservations: a rider deciding a departure, the reservation detail, and the
// ask-dispatch and default batches that book on their behalf.
import { randomUUID } from 'node:crypto';
import type { PoolClient } from 'pg';
import type { Actor, Body, Outcome } from '../transport/service.js';
import { fail, TransportError } from '../transport/errors.js';
import { date, id, iso, type MembershipCore } from './core.js';

export async function reserve(
  m: MembershipCore,
  c: PoolClient,
  actor: Actor,
  input: Body,
  mode: 'confirmation' | 'ask' | 'default' = 'confirmation',
): Promise<string> {
  const day = String(input.travelDate),
    direction = String(input.direction),
    now = m.now();
  if (day < date(now)) fail(409, 'service_day_past', 'Cannot change a past service day.');
  // Period before trip locks for acquisition. Decline needs no funding lock.
  const funding =
    input.decision === 'decline'
      ? null
      : await m.periodForDeparture(
          c,
          actor.userId,
          day,
          direction,
          input.tripId ? id(input.tripId) : null,
        );
  const old = (
    await c.query(
      "SELECT * FROM app.reservations WHERE user_id=$1 AND service_date=$2 AND direction=$3 AND status<>'operator_cancelled'",
      [actor.userId, day, direction],
    )
  ).rows[0];
  if (old && ['boarded', 'no_show'].includes(old.status))
    fail(409, 'reservation_terminal', 'This service has already settled.');
  if (old?.trip_id) {
    const trip = (await c.query('SELECT * FROM app.trips WHERE id=$1 FOR UPDATE', [old.trip_id]))
      .rows[0];
    if (trip.status !== 'scheduled' || trip.scheduled_at <= now)
      fail(409, 'service_started', 'This departure is no longer changeable.');
  }
  if (input.decision === 'decline') {
    if (old) {
      await c.query(
        "UPDATE app.reservations SET status='declined',source='confirmation' WHERE id=$1",
        [old.id],
      );
      return old.id;
    }
    return (
      await c.query(
        "INSERT INTO app.reservations(user_id,service_date,direction,status,source) VALUES ($1,$2,$3,'declined','confirmation') RETURNING id",
        [actor.userId, day, direction],
      )
    ).rows[0].id;
  }
  const b = funding!;
  if (b.offer_terms) {
    const terms = b.offer_terms as import('./offer-terms.js').OfferTerms;
    const offeredLeg = terms.legs.find((l) => l.direction === direction);
    if (!offeredLeg?.travelDays.includes(new Date(`${day}T00:00:00Z`).getUTCDay() || 7))
      fail(409, 'travel_day_not_covered', 'This weekday is not included in your offer.');
    const balance = (
      await c.query('SELECT * FROM app.offer_ride_balances($1) WHERE direction=$2', [
        b.id,
        direction,
      ])
    ).rows[0];
    const alreadyHeld = old?.period_id === b.id && old?.status === 'reserved' ? 1 : 0;
    if (!balance || balance.granted - balance.charged - balance.held + alreadyHeld <= 0)
      fail(409, 'journey_rides_exhausted', 'No rides remain for this direction.');
  }
  if ((await m.blocks(c, actor.userId, b.id)).length)
    fail(409, 'membership_blocked', 'Resolve the current access block first.');
  const leg = (
    await c.query(
      `SELECT a.id AS assignment_id,a.selection_id,l.* FROM app.commute_assignments a JOIN app.commute_selection_legs l ON l.selection_id=a.selection_id WHERE a.period_id=$1 AND a.effective_from<=$2 AND (a.effective_to IS NULL OR $2<a.effective_to) AND l.direction=$3`,
      [b.id, day, direction],
    )
  ).rows[0];
  if (!leg) fail(409, 'commute_unavailable', 'No effective commute for this date.');
  const trips = (
    await c.query(
      'SELECT * FROM app.trips WHERE schedule_id=$1 AND service_date=$2 AND ($3::uuid IS NULL OR id=$3) ORDER BY id FOR UPDATE',
      [leg.schedule_id, day, input.tripId ? id(input.tripId) : null],
    )
  ).rows;
  const t = trips[0];
  if (
    trips.length !== 1 ||
    t.status !== 'scheduled' ||
    t.scheduled_at <= now ||
    t.scheduled_at < b.starts_at ||
    t.scheduled_at >= b.effective_ends_at
  )
    fail(409, 'departure_unavailable', 'A funded upcoming departure is required.');
  const rides = Number(
    (
      await c.query(
        'SELECT coalesce(sum(delta_rides),0) AS n FROM app.ride_entries WHERE period_id=$1',
        [b.id],
      )
    ).rows[0].n,
  );
  const held = Number(
    (
      await c.query(
        "SELECT count(*) AS n FROM app.reservations WHERE period_id=$1 AND status='reserved' AND id<>$2",
        [b.id, old?.id ?? randomUUID()],
      )
    ).rows[0].n,
  );
  if (rides <= held && mode !== 'ask')
    fail(409, 'rides_unavailable', 'No unreserved rides remain.');
  const values = [
    actor.userId,
    day,
    direction,
    b.id,
    leg.assignment_id,
    leg.selection_id,
    t.id,
    leg.schedule_id,
    leg.pattern_version_id,
    leg.pickup_occurrence_id,
    leg.dropoff_occurrence_id,
    mode === 'ask' ? 'pending' : 'reserved',
    mode === 'confirmation' ? 'confirmation' : 'default',
  ];
  if (old) {
    await c.query(
      "UPDATE app.reservations SET period_id=$4,assignment_id=$5,selection_id=$6,trip_id=$7,schedule_id=$8,pattern_version_id=$9,pickup_occurrence_id=$10,dropoff_occurrence_id=$11,status=$12,source=$13 WHERE user_id=$1 AND service_date=$2 AND direction=$3 AND status<>'operator_cancelled'",
      values,
    );
    return old.id;
  }
  return (
    await c.query(
      'INSERT INTO app.reservations(user_id,service_date,direction,period_id,assignment_id,selection_id,trip_id,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id,status,source) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13) RETURNING id',
      values,
    )
  ).rows[0].id;
}
export async function runReservationBatch(
  m: MembershipCore,
  actor: Actor,
  op: 'runAskDispatch' | 'runReservationDefaults',
  input: { travelDate: string; direction: string; limit?: number; routeId?: string },
): Promise<Outcome> {
  const limit = input.limit ?? 100,
    day = input.travelDate;
  if (
    !Number.isInteger(limit) ||
    limit < 1 ||
    limit > 100 ||
    !/^\d{4}-\d\d-\d\d$/.test(day) ||
    day < date(m.now()) ||
    !['outbound', 'return'].includes(input.direction)
  )
    fail(400, 'invalid_request', 'Invalid service-day batch.');
  const candidates = await m.tx(async (c) => {
    await m.authorize(c, actor, op);
    if (op === 'runReservationDefaults')
      return (
        await c.query(
          `SELECT r.user_id AS id FROM app.reservations r JOIN app.commute_selections s ON s.id=r.selection_id
      WHERE r.service_date=$1 AND r.direction=$2 AND r.status='pending' AND ($3::uuid IS NULL OR s.route_id=$3) ORDER BY r.created_at,r.id LIMIT $4`,
          [day, input.direction, input.routeId ?? null, limit],
        )
      ).rows;
    return (
      await c.query(
        `SELECT b.user_id AS id FROM app.billing_periods b JOIN app.memberships m ON m.id=b.membership_id AND m.lifecycle='open'
      JOIN app.purchases purchase ON purchase.id=b.purchase_id
      JOIN app.users u ON u.id=b.user_id AND u.deleted_at IS NULL
      JOIN app.commute_assignments a ON a.period_id=b.id AND a.effective_from<=$1 AND (a.effective_to IS NULL OR $1<a.effective_to)
      JOIN app.commute_selection_legs l ON l.selection_id=a.selection_id AND l.direction=$2
      JOIN app.commute_selections s ON s.id=l.selection_id
      JOIN app.trips t ON t.schedule_id=l.schedule_id AND t.service_date=$1 AND t.status='scheduled' AND t.scheduled_at>$4
      WHERE b.state='open' AND b.starts_at<=t.scheduled_at AND t.scheduled_at<b.effective_ends_at
      AND (purchase.offer_terms IS NULL OR EXISTS(
        SELECT 1 FROM jsonb_array_elements(purchase.offer_terms->'legs') ol
        WHERE ol->>'direction'=$2 AND (ol->'travelDays') @> to_jsonb(ARRAY[extract(isodow FROM $1::date)::integer])))
      AND ($3::uuid IS NULL OR s.route_id=$3)
      AND NOT EXISTS(SELECT 1 FROM app.reservations r WHERE r.user_id=b.user_id AND r.service_date=$1 AND r.direction=$2)
      AND NOT EXISTS(SELECT 1 FROM app.membership_pauses p WHERE p.period_id=b.id AND p.ended_at IS NULL)
      AND NOT app.personal_pause_blocks(b.id,$1::date::timestamp AT TIME ZONE 'Africa/Accra')
      AND NOT EXISTS(SELECT 1 FROM app.payment_access_blocks p WHERE p.period_id=b.id AND p.released_at IS NULL)
      AND NOT EXISTS(SELECT 1 FROM app.account_restrictions r WHERE r.user_id=b.user_id AND r.released_at IS NULL)
      ORDER BY b.user_id LIMIT $5`,
        [day, input.direction, input.routeId ?? null, m.now(), limit],
      )
    ).rows;
  });
  const result = {
    considered: candidates.length,
    succeeded: 0,
    blocked: 0,
    failed: 0,
    failures: [] as { resourceId: string; reason: string }[],
  };
  for (const rider of candidates) {
    try {
      const changed = await m.tx(async (c) => {
        await m.lockUser(c, rider.id);
        await m.authorize(c, actor, op);
        const current = (
          await c.query(
            'SELECT * FROM app.reservations WHERE user_id=$1 AND service_date=$2 AND direction=$3 ORDER BY created_at DESC LIMIT 1',
            [rider.id, day, input.direction],
          )
        ).rows[0];
        if (op === 'runAskDispatch' && current) return false;
        if (op === 'runReservationDefaults' && current?.status !== 'pending') return false;
        await c.query('SAVEPOINT booking');
        try {
          const reservation = await reserve(
            m,
            c,
            { userId: rider.id, sessionId: '' },
            { travelDate: day, direction: input.direction, decision: 'confirm' },
            op === 'runAskDispatch' ? 'ask' : 'default',
          );
          if (op === 'runAskDispatch')
            await c.query(
              'INSERT INTO app.reservation_prompts(reservation_id,requested_by) VALUES ($1,$2)',
              [reservation, actor.userId],
            );
          return true;
        } catch (e) {
          await c.query('ROLLBACK TO SAVEPOINT booking');
          if (op === 'runReservationDefaults' && current) {
            const capacity =
              (e as { message?: string }).message === 'reservation_capacity' ||
              (e instanceof TransportError && e.code === 'rides_unavailable');
            const blocked =
              e instanceof TransportError &&
              [
                'membership_blocked',
                'coverage_required',
                'commute_unavailable',
                'departure_unavailable',
                'service_started',
              ].includes(e.code);
            if (capacity || blocked) {
              await c.query('UPDATE app.reservations SET status=$2 WHERE id=$1', [
                current.id,
                capacity ? 'unseated' : 'operator_cancelled',
              ]);
              return false;
            }
          }
          throw e;
        }
      });
      if (changed) result.succeeded++;
      else result.blocked++;
    } catch (e) {
      result.failed++;
      result.failures.push({
        resourceId: rider.id,
        reason:
          e instanceof TransportError && [401, 403, 404, 409].includes(e.status)
            ? e.code
            : 'unexpected_error',
      });
    }
  }
  return { status: 200, body: { data: result }, headers: {} };
}

export async function getReservation(
  m: MembershipCore,
  c: PoolClient,
  actor: Actor,
  target: string | undefined,
): Promise<Outcome> {
  // Read through the owned reservation, not the public trip catalogue:
  // history must remain visible after a route is archived, while a
  // pending or declined decision legitimately has no trip or stops.
  const row = (
    await c.query(
      `SELECT r.*,t.id AS detail_trip_id,t.scheduled_at AS trip_scheduled_at,
          t.status AS trip_status,v.label AS vehicle_label,v.plate AS vehicle_plate,
          rt.id AS route_id,rt.name AS route_name,
          pickup.name AS pickup_name,pickup.latitude AS pickup_latitude,
          pickup.longitude AS pickup_longitude,pickup.ordinal AS pickup_ordinal,
          dropoff.name AS dropoff_name,dropoff.latitude AS dropoff_latitude,
          dropoff.longitude AS dropoff_longitude,dropoff.ordinal AS dropoff_ordinal
        FROM app.reservations r
        LEFT JOIN app.trips t ON t.id=r.trip_id
        LEFT JOIN app.vehicles v ON v.id=t.vehicle_id
        LEFT JOIN app.route_pattern_versions pv ON pv.id=r.pattern_version_id
        LEFT JOIN app.route_patterns p ON p.id=pv.pattern_id
        LEFT JOIN app.routes rt ON rt.id=p.route_id
        LEFT JOIN app.route_pattern_stops pickup
          ON pickup.id=r.pickup_occurrence_id AND pickup.pattern_version_id=r.pattern_version_id
        LEFT JOIN app.route_pattern_stops dropoff
          ON dropoff.id=r.dropoff_occurrence_id AND dropoff.pattern_version_id=r.pattern_version_id
        WHERE r.id=$1 AND r.user_id=$2`,
      [id(target), actor.userId],
    )
  ).rows[0];
  if (!row) fail(404, 'not_found', 'Reservation not found.');
  const stop = (kind: 'pickup' | 'dropoff') =>
    row[`${kind}_name`] === null
      ? null
      : {
          occurrenceId: row[`${kind}_occurrence_id`],
          name: row[`${kind}_name`],
          location: {
            latitude: row[`${kind}_latitude`],
            longitude: row[`${kind}_longitude`],
          },
          ordinal: row[`${kind}_ordinal`],
        };
  return {
    status: 200,
    headers: {},
    body: {
      data: {
        reservation: m.reservationView(row),
        route: row.route_id === null ? null : { id: row.route_id, name: row.route_name },
        trip:
          row.detail_trip_id === null
            ? null
            : {
                id: row.detail_trip_id,
                scheduledAt: iso(row.trip_scheduled_at),
                status: row.trip_status,
                vehicleLabel: row.vehicle_label,
                vehiclePlate: row.vehicle_plate,
              },
        pickupStop: stop('pickup'),
        dropoffStop: stop('dropoff'),
      },
    },
  } as Outcome;
}
