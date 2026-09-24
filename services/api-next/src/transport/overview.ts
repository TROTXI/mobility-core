import type { PoolClient } from 'pg';
import type { Outcome } from './service.js';
import { fail } from './errors.js';

export const overviewReads = ['getOpsOverview'] as const;
export type OverviewRead = (typeof overviewReads)[number];

/**
 * A fix older than this means the bus stopped reporting, not that the network
 * hiccuped. Drivers publish every five seconds, so this is sixty missed fixes.
 * One constant in one place: if the board and the console each decided this,
 * they would disagree, and the one that matters is whichever the dispatcher is
 * looking at.
 */
export const STALE_FIX_AFTER_SECONDS = 300;

/**
 * The live board, in one query.
 *
 * Reservation counts are aggregated in SQL rather than by loading rows, and
 * every per-trip fact is joined in the same statement, so the cost does not
 * grow with the number of buses. The board polls every ten seconds; this is
 * the hottest read the service has.
 */
const BOARD = `
  WITH windowed AS (
    SELECT t.id, t.scheduled_at, t.status, t.assigned_driver_id, t.vehicle_id,
           t.pattern_version_id
    FROM app.trips t
    JOIN app.service_schedules s ON s.id = t.schedule_id AND s.service_window = $1
    WHERE t.service_date = $2
  ),
  counts AS (
    SELECT r.trip_id,
      count(*) FILTER (WHERE r.status IN ('reserved','boarded','no_show'))::int AS confirmed,
      count(*) FILTER (WHERE r.status = 'boarded')::int AS boarded,
      count(*) FILTER (WHERE r.status = 'no_show')::int AS no_show,
      count(*) FILTER (WHERE r.status = 'reserved')::int AS reserved
    FROM app.reservations r
    JOIN windowed w ON w.id = r.trip_id
    -- Every count below already sits inside these statuses. Saying so lets the
    -- planner use reservations_trip_seats, which is partial on exactly them.
    WHERE r.status IN ('reserved', 'boarded', 'no_show')
    GROUP BY r.trip_id
  )
  SELECT w.id, w.scheduled_at, w.status,
    ro.name AS route_name,
    w.assigned_driver_id AS driver_id, d.name AS driver_name,
    w.vehicle_id, v.label AS vehicle_label, v.plate AS vehicle_plate, v.capacity,
    COALESCE(c.confirmed, 0) AS confirmed,
    COALESCE(c.boarded, 0) AS boarded,
    COALESCE(c.no_show, 0) AS no_show,
    COALESCE(c.reserved, 0) AS reserved,
    lp.effective_captured_at AS last_fix_at,
    ST_Y(lp.location) AS latitude, ST_X(lp.location) AS longitude
  FROM windowed w
  LEFT JOIN counts c ON c.trip_id = w.id
  LEFT JOIN app.drivers d ON d.id = w.assigned_driver_id
  LEFT JOIN app.vehicles v ON v.id = w.vehicle_id
  LEFT JOIN app.trip_live_positions lp ON lp.trip_id = w.id
  LEFT JOIN app.route_pattern_versions pv ON pv.id = w.pattern_version_id
  LEFT JOIN app.route_patterns rp ON rp.id = pv.pattern_id
  LEFT JOIN app.routes ro ON ro.id = rp.route_id
  ORDER BY w.scheduled_at, w.id`;

interface Row {
  id: string;
  scheduled_at: Date;
  status: 'scheduled' | 'active' | 'completed' | 'cancelled';
  route_name: string | null;
  driver_id: string | null;
  driver_name: string | null;
  vehicle_id: string | null;
  vehicle_label: string | null;
  vehicle_plate: string | null;
  capacity: number | null;
  confirmed: number;
  boarded: number;
  no_show: number;
  reserved: number;
  last_fix_at: Date | null;
  latitude: number | null;
  longitude: number | null;
}

/**
 * Trips carry an explicit service_date, so the board matches on that rather
 * than bracketing scheduled_at between two timestamps. A run at 05:40 belongs
 * to the day the schedule says it does, not to whichever day its instant falls
 * in once a time zone is applied.
 *
 * Accra keeps no daylight saving and sits on UTC, so today in Accra is today in
 * UTC. That is stated here rather than assumed at the call site, because it
 * stops being true the moment a second city is added.
 */
function serviceDay(now: Date): string {
  return now.toISOString().slice(0, 10);
}

export async function readOverview(
  client: PoolClient,
  query: Record<string, string | undefined>,
  staleAfterSeconds: number = STALE_FIX_AFTER_SECONDS,
): Promise<Outcome> {
  const serviceWindow = query.window;
  // Required, not defaulted. The schema is explicit that a service window is
  // stated and never inferred from a timestamp, and a server picking one from
  // its own clock is that inference with a friendlier name.
  if (serviceWindow !== 'morning' && serviceWindow !== 'evening')
    fail(400, 'invalid_query', 'Supply window=morning or window=evening.');
  if (Object.keys(query).some((key) => key !== 'window' && key !== 'date'))
    fail(400, 'invalid_query', 'Unsupported query parameters.');
  // A past day is how the morning review works through last night's
  // unresolved seats. The service day is still stated, never inferred.
  if (
    query.date !== undefined &&
    (!/^\d{4}-\d{2}-\d{2}$/.test(query.date) ||
      new Date(`${query.date}T00:00:00Z`).toISOString().slice(0, 10) !== query.date)
  )
    fail(400, 'invalid_query', 'Supply date as YYYY-MM-DD.');

  const now = new Date();
  const day = query.date ?? serviceDay(now);
  const { rows } = await client.query<Row>(BOARD, [serviceWindow, day]);

  const trips = rows.map((row) => {
    const lastFix = row.last_fix_at ? new Date(row.last_fix_at) : null;
    const ageSeconds = lastFix
      ? Math.max(0, Math.floor((now.getTime() - lastFix.getTime()) / 1000))
      : null;
    // A trip only reports once it is running, so an absent fix is only an
    // exception on an active trip. The schema already guarantees an active
    // trip has a driver, which is why unassigned is a scheduled-trip state.
    const stale =
      row.status === 'active' && (ageSeconds === null || ageSeconds > staleAfterSeconds);
    const unassigned =
      row.status === 'scheduled' && (row.driver_id === null || row.vehicle_id === null);
    return {
      tripId: row.id,
      scheduledAt: new Date(row.scheduled_at).toISOString(),
      status: row.status,
      routeName: row.route_name,
      driverId: row.driver_id,
      driverName: row.driver_name,
      vehicleId: row.vehicle_id,
      vehicleLabel: row.vehicle_label,
      vehiclePlate: row.vehicle_plate,
      capacity: row.capacity,
      confirmed: Number(row.confirmed),
      boarded: Number(row.boarded),
      noShow: Number(row.no_show),
      reserved: Number(row.reserved),
      lastFixAt: lastFix ? lastFix.toISOString() : null,
      fixAgeSeconds: ageSeconds,
      lastPosition:
        row.latitude === null || row.longitude === null
          ? null
          : { latitude: row.latitude, longitude: row.longitude },
      badge: stale ? 'stale_gps' : unassigned ? 'unassigned' : 'on_time',
    };
  });

  // Summed from the trips above rather than counted again in SQL, so a tile
  // can never disagree with the table under it. Every per-trip figure is
  // already an SQL aggregate; this adds up a handful of rows, one per bus.
  const running = trips.filter((t) => t.status !== 'cancelled');
  const sum = (list: typeof trips, pick: (t: (typeof trips)[number]) => number) =>
    list.reduce((total, t) => total + pick(t), 0);
  const tiles = {
    trips: trips.length,
    inProgress: trips.filter((t) => t.status === 'active').length,
    completed: trips.filter((t) => t.status === 'completed').length,
    cancelled: trips.length - running.length,
    seatCapacity: sum(running, (t) => t.capacity ?? 0),
    seatsConfirmed: sum(running, (t) => t.confirmed),
    boarded: sum(running, (t) => t.boarded),
    noShows: sum(running, (t) => t.noShow),
    awaitingResolution: sum(
      trips.filter((t) => t.status === 'completed'),
      (t) => t.reserved,
    ),
    staleGps: trips.filter((t) => t.badge === 'stale_gps').length,
    unassigned: trips.filter((t) => t.badge === 'unassigned').length,
  };

  return {
    status: 200,
    // Single-object reads carry the same data envelope every other operation
    // uses, so a client unwraps one way regardless of which it called.
    body: {
      data: {
        generatedAt: now.toISOString(),
        window: serviceWindow,
        serviceDate: day,
        staleFixAfterSeconds: staleAfterSeconds,
        tiles,
        trips,
      },
    },
    headers: {},
  };
}
