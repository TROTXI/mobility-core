import type { PoolClient, QueryResultRow } from 'pg';
import type { Actor, Body, Outcome } from './service.js';
import { cursorCodec } from './cursor.js';
import { fail } from './errors.js';

/** Trip reads a signed-in rider may make. No driver identity, no raw trace. */
export const tripReads = ['listTrips', 'getTrip', 'getLiveTrip'] as const;
export type TripRead = (typeof tripReads)[number];

/**
 * A fix this old or newer is what the rider is watching now. Beyond it the
 * marker is labelled stale rather than quietly presented as current.
 */
export const LIVE_AGE_SECONDS = 30;
/**
 * Past this the position is too old to predict from. The marker and its
 * timestamp are still returned, because "here a while ago" is honest and
 * useful; a predicted arrival computed from it would not be.
 */
export const ETA_AGE_LIMIT_SECONDS = 120;
/**
 * A segment speed learned from fewer runs than this is not yet evidence, so
 * the estimate says it fell back rather than claiming observation.
 */
export const MIN_OBSERVED_SAMPLES = 3;
/**
 * The speed used where nothing has been learned. A stated default awaiting a
 * measured one, and labelled as fallback wherever it reaches a rider.
 */
export const FALLBACK_SPEED_MPS = 6;

const notFound = () => fail(404, 'not_found', 'Resource not found.');
const iso = (value: Date) => value.toISOString();
const day = (value: Date | string) =>
  typeof value === 'string' ? value : value.toISOString().slice(0, 10);

export function tripId(value: unknown): string {
  if (
    typeof value !== 'string' ||
    !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)
  )
    return notFound();
  return value.toLowerCase();
}

/** The catalogue view: what is running, never who is driving or riding. */
function view(r: QueryResultRow): Body {
  return {
    id: r.id,
    departureId: r.departure_id,
    serviceDate: day(r.service_date),
    runNumber: r.run_number,
    routeId: r.route_id,
    patternId: r.pattern_id,
    patternVersionId: r.pattern_version_id,
    direction: r.direction,
    scheduledAt: iso(r.scheduled_at),
    status: r.status,
    vehicleLabel: r.vehicle_label ?? null,
  };
}

export class Trips {
  private readonly cursors;
  constructor(secret: Buffer) {
    this.cursors = cursorCodec(secret);
  }

  async read(
    client: PoolClient,
    operation: TripRead,
    actor: Actor,
    params: { id?: string },
    query: Record<string, string | undefined>,
  ): Promise<Outcome> {
    if (operation === 'listTrips') return this.list(client, actor, query);
    const trip = (
      await client.query(
        `SELECT t.*,r.id AS route_id,p.id AS pattern_id,p.direction,v.label AS vehicle_label,sc.service_window
        FROM app.trips t
        JOIN app.service_schedules sc
          ON sc.id=t.schedule_id AND sc.pattern_version_id=t.pattern_version_id
        JOIN app.route_pattern_versions pv ON pv.id=t.pattern_version_id AND pv.state<>'draft'
        JOIN app.route_patterns p ON p.id=pv.pattern_id
        JOIN app.routes r ON r.id=p.route_id AND r.archived_at IS NULL
        LEFT JOIN app.vehicles v ON v.id=t.vehicle_id
        WHERE t.id=$1`,
        [tripId(params.id)],
      )
    ).rows[0];
    if (!trip) return notFound();
    if (operation === 'getTrip') return { status: 200, body: { data: view(trip) }, headers: {} };
    return this.live(client, actor, trip);
  }

  private async list(
    client: PoolClient,
    actor: Actor,
    query: Record<string, string | undefined>,
  ): Promise<Outcome> {
    const limit = query.limit === undefined ? 50 : Number(query.limit);
    if (
      !Number.isInteger(limit) ||
      limit < 1 ||
      limit > 200 ||
      (query.limit !== undefined && !/^[1-9]\d*$/.test(query.limit))
    )
      fail(400, 'invalid_query', 'Invalid page size.');
    const dates = (value: string | undefined, name: string) => {
      if (value === undefined) return null;
      // A date this service accepts has to be a date PostgreSQL accepts. Date
      // .parse rolls the thirtieth of February into March, so the round trip
      // catches a day that never existed; year zero survives that round trip
      // and PostgreSQL refuses it anyway, so the pattern excludes it.
      if (
        !/^(?!0000)\d{4}-\d\d-\d\d$/.test(value) ||
        Number.isNaN(Date.parse(value)) ||
        new Date(value).toISOString().slice(0, 10) !== value
      )
        fail(400, 'invalid_query', `Supply a calendar date for ${name}.`);
      return value;
    };
    const from = dates(query.fromDate, 'fromDate'),
      to = dates(query.toDate, 'toDate');
    if (from && to && from > to)
      fail(400, 'invalid_query', 'Supply an ordered service-date range.');
    const routeId = query.routeId === undefined ? null : tripId(query.routeId);
    const now = (await client.query('SELECT clock_timestamp() AS now')).rows[0].now as Date;
    // Every filter joins the signed context. A cursor from one query must not
    // decode against another and silently hide matching departures.
    const context = `trips:listTrips:${actor.userId}:${from ?? ''}:${to ?? ''}:${routeId ?? ''}`;
    const cursor = query.cursor ? this.cursors.decode(query.cursor, context, now) : null;
    const values: unknown[] = [
      from,
      to,
      routeId,
      cursor?.time ?? null,
      cursor?.id ?? null,
      limit + 1,
    ];
    const rows = (
      await client.query(
        `SELECT t.*,r.id AS route_id,p.id AS pattern_id,p.direction,v.label AS vehicle_label,
          to_char(t.scheduled_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
        FROM app.trips t
        JOIN app.route_pattern_versions pv ON pv.id=t.pattern_version_id AND pv.state<>'draft'
        JOIN app.route_patterns p ON p.id=pv.pattern_id
        JOIN app.routes r ON r.id=p.route_id AND r.archived_at IS NULL
        LEFT JOIN app.vehicles v ON v.id=t.vehicle_id
        WHERE ($1::date IS NULL OR t.service_date>=$1)
          AND ($2::date IS NULL OR t.service_date<=$2)
          AND ($3::uuid IS NULL OR r.id=$3)
          AND ($4::timestamptz IS NULL OR (t.scheduled_at,t.id)>($4::timestamptz,$5::uuid))
        ORDER BY t.scheduled_at,t.id LIMIT $6`,
        values,
      )
    ).rows;
    const page = rows.slice(0, limit);
    const last = page[page.length - 1];
    return {
      status: 200,
      body: {
        data: page.map(view),
        page: {
          nextCursor:
            rows.length > limit && last
              ? this.cursors.encode(last.cursor_time, last.id, context, now)
              : null,
        },
      },
      headers: {},
    };
  }

  /**
   * Where the bus is, for someone entitled to watch this one.
   *
   * Entitlement is decided from current database facts before any state is
   * returned, because the answer itself discloses the trip. A caller without
   * it gets the same 404 whether the trip is missing, someone else's, or
   * theirs on a period that has been paused, disputed or restricted.
   */
  private async live(client: PoolClient, actor: Actor, trip: QueryResultRow): Promise<Outcome> {
    const entitled = await this.entitlement(client, actor, trip);
    if (!entitled) return notFound();
    const now = (await client.query('SELECT clock_timestamp() AS now')).rows[0].now as Date;
    const ended = ['completed', 'cancelled'].includes(trip.status);
    const fix = ended
      ? undefined
      : (
          await client.query(
            `SELECT effective_captured_at,received_at,
              ST_Y(location) AS latitude,ST_X(location) AS longitude
            FROM app.trip_live_positions WHERE trip_id=$1
              AND received_at>=clock_timestamp()-make_interval(days=>app.trace_retention_days())`,
            [trip.id],
          )
        ).rows[0];
    const age = fix
      ? Math.max(
          0,
          Math.round((now.getTime() - (fix.effective_captured_at as Date).getTime()) / 1000),
        )
      : null;
    const state = ended
      ? 'ended'
      : trip.status !== 'active'
        ? 'not_started'
        : !fix
          ? 'awaiting_fix'
          : age! <= LIVE_AGE_SECONDS
            ? 'live'
            : 'stale';
    return {
      status: 200,
      body: {
        data: {
          tripId: trip.id,
          patternVersionId: trip.pattern_version_id,
          geometryId: (await this.geometry(client, trip.pattern_version_id)) ?? null,
          riderPickupOccurrenceId: entitled.pickupOccurrenceId,
          state,
          position:
            fix && !ended
              ? {
                  location: { latitude: Number(fix.latitude), longitude: Number(fix.longitude) },
                  capturedAt: iso(fix.effective_captured_at),
                  receivedAt: iso(fix.received_at),
                  ageSeconds: age!,
                }
              : null,
          // A prediction from a position this old would be a guess wearing a
          // number. The marker and its time still go out; the arrival does not.
          etas:
            fix && !ended && age! <= ETA_AGE_LIMIT_SECONDS
              ? await this.etas(client, trip, fix)
              : [],
          serverTime: iso(now),
        },
      },
      headers: {},
    };
  }

  private async geometry(client: PoolClient, patternVersionId: string) {
    return (
      await client.query('SELECT geometry_id FROM app.route_pattern_versions WHERE id=$1', [
        patternVersionId,
      ])
    ).rows[0]?.geometry_id as string | null | undefined;
  }

  /**
   * Whether this caller may watch this trip, and where they board it.
   *
   * Null means no entitlement. An entitled caller with no stop of their own,
   * ops or the assigned driver, carries a null pickup, so "not allowed" and
   * "allowed, boards nowhere" can never be confused for one another.
   */
  private async entitlement(
    client: PoolClient,
    actor: Actor,
    trip: QueryResultRow,
  ): Promise<{ pickupOccurrenceId: string | null } | null> {
    const user = (
      await client.query(
        'SELECT role FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR SHARE',
        [actor.userId],
      )
    ).rows[0];
    if (!user) fail(401, 'unauthenticated', 'Sign in to continue.');
    // Ops sees any trip; a driver sees the run they were assigned and no other.
    if (user.role === 'admin') return { pickupOccurrenceId: null };
    if (user.role === 'driver')
      return (
        await client.query(
          `SELECT 1 FROM app.trips t JOIN app.drivers d ON d.id=t.assigned_driver_id
          WHERE t.id=$1 AND d.user_id=$2 AND d.archived_at IS NULL`,
          [trip.id, actor.userId],
        )
      ).rowCount
        ? { pickupOccurrenceId: null }
        : null;
    // A rider watches the corridor their funded commute puts them on, whether
    // or not they have booked a seat. That grant asks whether they are covered
    // now: coverage that has since lapsed buys no more watching. A seat held on
    // this run is the separate grant, and it is what carries a delayed
    // departure across the deadline it was funded for.
    const byCommute = (
      await client.query(
        `SELECT l.pickup_occurrence_id FROM app.billing_periods b
        JOIN app.memberships m ON m.id=b.membership_id AND m.lifecycle='open'
        JOIN app.commute_assignments a ON a.period_id=b.id
          AND a.effective_from<=$2::date AND (a.effective_to IS NULL OR $2::date<a.effective_to)
        JOIN app.commute_selection_legs l
          ON l.selection_id=a.selection_id AND l.schedule_id=$3
        WHERE b.user_id=$1 AND b.state='open'
          AND b.starts_at<=clock_timestamp() AND clock_timestamp()<b.effective_ends_at
          AND NOT EXISTS (SELECT 1 FROM app.membership_pauses p
            WHERE p.period_id=b.id AND p.ended_at IS NULL)
          AND NOT EXISTS (SELECT 1 FROM app.payment_access_blocks p
            WHERE p.period_id=b.id AND p.released_at IS NULL)
        LIMIT 1`,
        [actor.userId, day(trip.service_date), trip.schedule_id],
      )
    ).rows[0];
    const bySeat = byCommute
      ? undefined
      : (
          await client.query(
            `SELECT r.pickup_occurrence_id FROM app.reservations r
            JOIN app.billing_periods b ON b.id=r.period_id AND b.state<>'reversed'
              AND b.starts_at<=$3 AND $3<b.effective_ends_at
            WHERE r.user_id=$1 AND r.trip_id=$2 AND r.status IN ('reserved','boarded')
              AND NOT EXISTS (SELECT 1 FROM app.membership_pauses p
                WHERE p.period_id=b.id AND p.ended_at IS NULL)
              AND NOT EXISTS (SELECT 1 FROM app.payment_access_blocks p
                WHERE p.period_id=b.id AND p.released_at IS NULL)
            LIMIT 1`,
            [actor.userId, trip.id, trip.scheduled_at],
          )
        ).rows[0];
    const own = byCommute ?? bySeat;
    if (!own) return null;
    // An account-wide restriction withdraws live access even where funding
    // would otherwise allow it.
    if (
      (
        await client.query(
          'SELECT 1 FROM app.account_restrictions WHERE user_id=$1 AND released_at IS NULL LIMIT 1',
          [actor.userId],
        )
      ).rowCount
    )
      return null;
    return { pickupOccurrenceId: own.pickup_occurrence_id as string };
  }

  /**
   * Time and ground still to cover to each stop ahead.
   *
   * The bus is placed on the published line, which turns its position into a
   * distance travelled, and the stops ahead are the occurrences it has not
   * reached. Occurrences, not distances: a line that doubles back passes the
   * same ground twice, and projection alone would put the bus at the first
   * place matching its coordinates and offer a stop it called at an hour ago.
   * Recorded arrivals decide what is behind; the projection only refines where
   * it is between them.
   *
   * Each segment contributes the part not yet covered, crossed at its learned
   * speed where enough runs have taught one and at the labelled fallback
   * otherwise, so a rider is never shown an observed-looking number that
   * nothing observed. The run up to the first stop is a segment too: a bus
   * short of its first pickup owes the rider that ground and that wait.
   */
  private async etas(client: PoolClient, trip: QueryResultRow, fix: QueryResultRow) {
    return (
      await client.query(
        `WITH line AS (
          SELECT g.id,g.line,ST_Length(g.line::geography) AS length_m
          FROM app.route_pattern_versions v JOIN app.route_geometries g ON g.id=v.geometry_id
          WHERE v.id=$1
        ), here AS (
          SELECT l.id AS geometry_id FROM line l
        ), reached AS (
          SELECT s.ordinal,d.distance_meters
          FROM app.route_pattern_stops s
          JOIN app.geometry_stop_distances d
            ON d.stop_occurrence_id=s.id AND d.geometry_id=(SELECT geometry_id FROM here)
          WHERE s.id=$7 AND s.pattern_version_id=$1
        ), at AS (
          -- A route that retraces its own path passes the same coordinates
          -- twice, so locating the bus on the whole line answers with the
          -- first of them and a run down the return leg reads as standing
          -- still. Locating it on the line still to run instead makes that
          -- leg count: the search starts where the driver last recorded
          -- arriving, which is the only thing that says which pass this is.
          SELECT CASE
            WHEN r.distance_meters IS NULL
              THEN ST_LineLocatePoint(l.line,ST_SetSRID(ST_MakePoint($2,$3),4326))*l.length_m
            WHEN r.distance_meters >= l.length_m THEN l.length_m
            ELSE r.distance_meters + (l.length_m-r.distance_meters)
              * ST_LineLocatePoint(
                  ST_LineSubstring(l.line,r.distance_meters/l.length_m,1),
                  ST_SetSRID(ST_MakePoint($2,$3),4326))
          END AS along_m,
          coalesce(r.ordinal,-1) AS reached_ordinal
          FROM line l LEFT JOIN reached r ON true
        ), stops AS (
          SELECT s.ordinal,d.stop_occurrence_id,d.distance_meters
          FROM app.geometry_stop_distances d
          JOIN app.route_pattern_stops s
            ON s.id=d.stop_occurrence_id AND s.pattern_version_id=$1
          WHERE d.geometry_id=(SELECT geometry_id FROM here)
        ), segments AS (
          SELECT s.ordinal AS to_ordinal,s.stop_occurrence_id,s.distance_meters AS to_m,
                 coalesce(lag(s.distance_meters) OVER w,0) AS from_m,
                 lag(s.ordinal) OVER w AS from_ordinal
          FROM stops s WINDOW w AS (ORDER BY s.ordinal)
        ), ahead AS (
          SELECT g.to_ordinal,g.stop_occurrence_id,g.to_m - a.along_m AS metres,
                 greatest(g.to_m-greatest(g.from_m,a.along_m),0)
                   / CASE WHEN sp.sample_count>=$4 THEN sp.metres_per_second ELSE $5 END AS seconds,
                 coalesce(sp.sample_count>=$4,false) AS observed
          FROM segments g CROSS JOIN at a
          LEFT JOIN app.segment_speeds sp
            ON sp.pattern_version_id=$1 AND sp.service_window=$6 AND sp.from_ordinal=g.from_ordinal
          WHERE g.to_ordinal>a.reached_ordinal AND g.to_m>a.along_m
        )
        SELECT stop_occurrence_id,metres,
               sum(seconds) OVER (ORDER BY to_ordinal) AS seconds,
               bool_and(observed) OVER (ORDER BY to_ordinal) AS observed
        FROM ahead ORDER BY to_ordinal`,
        [
          trip.pattern_version_id,
          Number(fix.longitude),
          Number(fix.latitude),
          MIN_OBSERVED_SAMPLES,
          FALLBACK_SPEED_MPS,
          trip.service_window,
          trip.current_stop_occurrence_id,
        ],
      )
    ).rows.map((r) => ({
      stopOccurrenceId: r.stop_occurrence_id,
      durationSeconds: Math.max(0, Math.round(Number(r.seconds))),
      distanceMeters: Math.max(0, Number(r.metres)),
      basis: r.observed ? 'observed' : 'fallback',
    }));
  }
}
