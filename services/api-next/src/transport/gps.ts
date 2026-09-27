import type { PoolClient, QueryResultRow } from 'pg';
import type { Actor, Body, Outcome } from './service.js';
import { cursorCodec } from './cursor.js';
import { canonical } from './service.js';
import { fail } from './errors.js';
import { createHash } from 'node:crypto';

export const gpsCommands = [
  'recordPosition',
  'createTraceHold',
  'releaseTraceHold',
  'runRouteLearning',
  'runGpsRetention',
] as const;
export type GpsCommand = (typeof gpsCommands)[number];
export const gpsReads = ['listTraceHolds'] as const;
export type GpsRead = (typeof gpsReads)[number];
/** Only the assigned driver reports position; the rest is ops. */
export const driverGpsOperations = ['recordPosition'] as const;

/**
 * A capture further ahead of the server than this is refused outright: that is
 * a broken clock, not skew, and nothing it reports can be placed in time. A
 * smaller lead is kept as the device's word and clamped to the server's clock
 * for every purpose that orders or ages a fix, because a believed future time
 * freezes the marker until the clock catches up to it.
 */
export const MAX_FUTURE_SKEW_MS = 120_000;
/**
 * How far behind the server a capture may be and still be stored at all. A
 * queue older than this is history, not a live fix, and replaying it must not
 * quietly become today's trace.
 */
export const MAX_UPLOAD_AGE_MS = 24 * 60 * 60 * 1000;
/**
 * How long one run may keep collecting. A trip left active for longer is
 * forgotten, not driving, and must not go on minting fixes that the retention
 * clock then has to carry for a further thirty days.
 */
export const MAX_COLLECTION_SESSION_MS = 24 * 60 * 60 * 1000;
/**
 * A fix reported as worse than this cannot be placed on a road, so learning
 * ignores it. The live marker still shows it: a rough position of the bus
 * beats none.
 */
export const MAX_LEARNING_ACCURACY_METERS = 50;
/**
 * Speeds outside this band are a bad projection, a stalled bus or a fix that
 * jumped, not a segment worth learning from.
 */
export const MIN_LEARNED_SPEED_MPS = 0.5;
export const MAX_LEARNED_SPEED_MPS = 25;
/**
 * How many recent samples a segment speed is computed from. Older runs fall
 * out of the window so the estimate follows the road as it is now.
 */
export const SPEED_SAMPLE_WINDOW = 200;

export interface Maintenance extends Body {
  considered: number;
  succeeded: number;
  blocked: number;
  failed: number;
  failures: { resourceId: string; reason: string }[];
}
const started = (): Maintenance => ({
  considered: 0,
  succeeded: 0,
  blocked: 0,
  failed: 0,
  failures: [],
});
/** A batch size the caller asked for, clamped to what the contract allows. */
function batchLimit(value: unknown): number {
  const limit = typeof value === 'number' ? value : 100;
  if (!Number.isInteger(limit) || limit < 1 || limit > 100)
    fail(400, 'invalid_request', 'Supply a batch limit between 1 and 100.');
  return limit;
}
/** One resource's failure must not lose the whole batch. */
async function perResource(
  client: PoolClient,
  result: Maintenance,
  id: string,
  work: () => Promise<'succeeded' | 'blocked'>,
) {
  await client.query('SAVEPOINT resource');
  try {
    result[await work()] += 1;
    await client.query('RELEASE SAVEPOINT resource');
  } catch (error) {
    await client.query('ROLLBACK TO SAVEPOINT resource');
    await client.query('RELEASE SAVEPOINT resource');
    result.failed += 1;
    if (result.failures.length < 100)
      result.failures.push({
        resourceId: id,
        reason: (error instanceof Error ? error.message : 'unknown').slice(0, 100),
      });
  }
}

/**
 * Hold creation and the retention sweep contend for one lock per trip, so a
 * hold is either created before the trace it names is deleted or refused
 * because that trace is already gone.
 */
export const traceLockKey = (tripId: string) => `trotxi:gps:trace:${tripId}`;
/**
 * Recomputing a published speed reads every recent sample, so two sweeps
 * touching the same route and window take turns rather than one overwriting
 * the other's aggregate with a median taken before it committed.
 */
export const speedsLockKey = (patternVersionId: string, serviceWindow: string) =>
  `trotxi:gps:speeds:${patternVersionId}:${serviceWindow}`;
const lock = (client: PoolClient, key: string) =>
  client.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [key]);
const retentionDeadline = async (client: PoolClient) =>
  (
    await client.query(
      'SELECT clock_timestamp() - make_interval(days => app.trace_retention_days()) AS at',
    )
  ).rows[0].at as Date;

const digest = (value: string) => createHash('sha256').update(value).digest('hex');
const notFound = () => fail(404, 'not_found', 'Resource not found.');
const editToken = (row: QueryResultRow) => `"hold:${row.id}:${row.version}"`;
const iso = (value: Date) => value.toISOString();

export function gpsId(value: unknown): string {
  if (
    typeof value !== 'string' ||
    !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)
  )
    return notFound();
  return value.toLowerCase();
}

/**
 * Decide the capture time the server will believe.
 *
 * The device's own value is always preserved; this only chooses what orders
 * fixes and decides freshness.
 */
export function effectiveCapture(
  capturedAt: Date,
  now: Date,
): { at: Date; adjusted: boolean } | 'ahead' | 'stale' {
  const ahead = capturedAt.getTime() - now.getTime();
  if (ahead > MAX_FUTURE_SKEW_MS) return 'ahead';
  if (ahead > 0) return { at: now, adjusted: true };
  if (-ahead > MAX_UPLOAD_AGE_MS) return 'stale';
  return { at: capturedAt, adjusted: false };
}

export interface GpsLocked {
  row: QueryResultRow | null;
}

export class Gps {
  private readonly cursors;
  constructor(secret: Buffer) {
    this.cursors = cursorCodec(secret);
  }

  normalize(operation: GpsCommand, input: Body): Body {
    const body = structuredClone(input);
    if (operation === 'recordPosition' && typeof body.clientFixId === 'string')
      body.clientFixId = body.clientFixId.toLowerCase();
    if (operation === 'createTraceHold') {
      body.incidentId = gpsId(body.incidentId);
      body.tripId = gpsId(body.tripId);
    }
    return body;
  }

  async lock(client: PoolClient, operation: GpsCommand, target: string): Promise<GpsLocked> {
    if (operation !== 'releaseTraceHold') return { row: null };
    const row = (
      await client.query('SELECT * FROM app.trace_holds WHERE id=$1 FOR UPDATE', [gpsId(target)])
    ).rows[0];
    if (!row) return notFound();
    return { row };
  }

  precondition(operation: GpsCommand, locked: GpsLocked, ifMatch?: string) {
    if (operation !== 'releaseTraceHold') return;
    if (!ifMatch) fail(428, 'precondition_required', 'Supply the resource edit token in If-Match.');
    if (ifMatch !== editToken(locked.row!))
      fail(412, 'precondition_failed', 'The resource changed. Refresh it and try again.');
  }

  async execute(
    client: PoolClient,
    actor: Actor,
    operation: GpsCommand,
    target: string,
    body: Body,
    commandId: string,
    driverId: string | null,
  ): Promise<Outcome> {
    if (operation === 'recordPosition') return this.record(client, gpsId(target), body, driverId!);
    if (operation === 'createTraceHold') return this.createHold(client, actor, body, commandId);
    if (operation === 'runRouteLearning') return this.learn(client, batchLimit(body.limit));
    if (operation === 'runGpsRetention') return this.purge(client, batchLimit(body.limit));
    return this.releaseHold(client, actor, gpsId(target), body, commandId);
  }

  /**
   * A fix from the assigned driver of an active run.
   *
   * The durable row is the source of truth; the live projection only advances
   * when this fix is genuinely newer than what riders are already seeing, so a
   * queued upload arriving late cannot move the marker backwards.
   */
  private async record(
    client: PoolClient,
    tripId: string,
    body: Body,
    driverId: string,
  ): Promise<Outcome> {
    const trip = (
      await client.query(
        'SELECT id,status,started_at FROM app.trips WHERE id=$1 AND assigned_driver_id=$2 FOR SHARE',
        [tripId, driverId],
      )
    ).rows[0];
    if (!trip) return notFound();
    if (trip.status !== 'active')
      fail(409, 'trip_not_active', 'Positions are only accepted while the run is active.');
    const now = (await client.query('SELECT clock_timestamp() AS now')).rows[0].now as Date;
    // A run left active is forgotten, not driving. Collecting past this would
    // hand the retention clock another thirty days of fixes to carry.
    if (now.getTime() - (trip.started_at as Date).getTime() > MAX_COLLECTION_SESSION_MS)
      fail(
        409,
        'collection_session_expired',
        'This run has been collecting for over a day and needs an operator to close it.',
      );
    const capturedAt = new Date(String(body.capturedAt));
    if (!Number.isFinite(capturedAt.getTime()))
      fail(400, 'invalid_capture_time', 'Supply a real capture time.');
    // A capture from before the wheels turned belongs to some other interval.
    if (capturedAt < (trip.started_at as Date))
      fail(409, 'capture_before_start', 'This fix predates the start of the run.');
    const effective = effectiveCapture(capturedAt, now);
    if (effective === 'ahead')
      fail(409, 'capture_ahead', 'This capture time is too far ahead of the server clock.');
    if (effective === 'stale')
      fail(409, 'capture_too_old', 'This fix is older than the accepted upload window.');
    // The identity a client replays with is the fix, so the same identity has
    // to mean the same fix. An offline replay returns the original receipt; a
    // different reading wearing that identity is refused rather than lost.
    const payload = digest(
      canonical([
        capturedAt.toISOString(),
        Number(body.latitude),
        Number(body.longitude),
        body.accuracyMeters === undefined || body.accuracyMeters === null
          ? null
          : Number(body.accuracyMeters),
      ]),
    );
    const inserted = (
      await client.query(
        `INSERT INTO app.trip_positions
          (trip_id,client_fix_id,captured_at,effective_captured_at,clock_adjusted,accuracy_meters,location,payload_digest)
        VALUES ($1,$2,$3,$4,$5,$6,ST_SetSRID(ST_MakePoint($7,$8),4326),$9)
        ON CONFLICT (trip_id,client_fix_id) DO NOTHING
        RETURNING *`,
        [
          tripId,
          body.clientFixId,
          capturedAt,
          effective.at,
          effective.adjusted,
          body.accuracyMeters ?? null,
          body.longitude,
          body.latitude,
          payload,
        ],
      )
    ).rows[0];
    const stored =
      inserted ??
      (
        await client.query(
          'SELECT * FROM app.trip_positions WHERE trip_id=$1 AND client_fix_id=$2',
          [tripId, body.clientFixId],
        )
      ).rows[0];
    if (!inserted && stored.payload_digest !== payload)
      fail(409, 'fix_payload_conflict', 'That fix identity was already used for a different fix.');
    // Advance the marker only for a strictly newer capture. The trigger refuses
    // a backwards move, so the guard here is the WHERE, not a read-then-write.
    // Selected straight from the stored row rather than rebuilt from values
    // that have been through the service: the projection has to be the fix,
    // to the microsecond, or the guard below rightly refuses it.
    const advanced = await client.query(
      `INSERT INTO app.trip_live_positions
        (trip_id,position_id,effective_captured_at,received_at,location)
      SELECT p.trip_id,p.id,p.effective_captured_at,p.received_at,p.location
      FROM app.trip_positions p WHERE p.id=$1
      ON CONFLICT (trip_id) DO UPDATE
        SET position_id=EXCLUDED.position_id,
            effective_captured_at=EXCLUDED.effective_captured_at,
            received_at=EXCLUDED.received_at,
            location=EXCLUDED.location,
            updated_at=clock_timestamp()
        WHERE app.trip_live_positions.effective_captured_at<EXCLUDED.effective_captured_at
      RETURNING trip_id`,
      [stored.id],
    );
    return {
      status: 200,
      body: {
        data: {
          clientFixId: stored.client_fix_id,
          receivedAt: iso(stored.received_at),
          capturedAt: iso(stored.captured_at),
          effectiveCapturedAt: iso(stored.effective_captured_at),
          acceptedForLive: advanced.rowCount === 1,
          clockAdjusted: stored.clock_adjusted,
        },
      },
      headers: {},
    };
  }

  private async createHold(
    client: PoolClient,
    actor: Actor,
    body: Body,
    commandId: string,
  ): Promise<Outcome> {
    // Taken before anything is read, so the deadline below and the sweep's
    // delete cannot interleave.
    await lock(client, traceLockKey(String(body.tripId)));
    const incident = (
      await client.query('SELECT trip_id FROM app.driver_incidents WHERE id=$1 FOR SHARE', [
        body.incidentId,
      ])
    ).rows[0];
    if (!incident) return notFound();
    if (
      !(await client.query('SELECT 1 FROM app.trips WHERE id=$1 FOR SHARE', [body.tripId])).rowCount
    )
      return notFound();
    const from = new Date(String(body.receivedFrom)),
      to = new Date(String(body.receivedTo)),
      review = new Date(String(body.reviewAt));
    if (![from, to, review].every((d) => Number.isFinite(d.getTime())) || to <= from)
      fail(400, 'invalid_interval', 'Supply an ordered receipt interval and review date.');
    // A hold that reaches back past the retention deadline is promising
    // evidence the sweep is already entitled to have deleted. Say so rather
    // than record a hold over nothing.
    if (from < (await retentionDeadline(client)))
      fail(
        409,
        'trace_already_expired',
        'That receipt interval reaches past the retention deadline, so the trace it names may already be gone.',
      );
    const row = (
      await client.query(
        `INSERT INTO app.trace_holds(incident_id,trip_id,received_from,received_to,reason,review_at,created_by)
        VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
        [body.incidentId, body.tripId, from, to, String(body.reason).trim(), review, actor.userId],
      )
    ).rows[0];
    await this.audit(client, actor, commandId, row.id, 'createTraceHold', {}, this.hold(row));
    return {
      status: 201,
      body: { data: this.hold(row) },
      headers: { etag: editToken(row), location: `/v1/ops/trace-holds/${row.id}` },
    };
  }

  private async releaseHold(
    client: PoolClient,
    actor: Actor,
    id: string,
    body: Body,
    commandId: string,
  ): Promise<Outcome> {
    const before = (await client.query('SELECT * FROM app.trace_holds WHERE id=$1', [id])).rows[0];
    if (before.state !== 'active')
      fail(409, 'hold_already_released', 'This hold has already been released.');
    const row = (
      await client.query(
        `UPDATE app.trace_holds
        SET state='released',released_by=$2,release_reason=$3,released_at=clock_timestamp(),
            version=version+1,updated_at=clock_timestamp()
        WHERE id=$1 RETURNING *`,
        [id, actor.userId, String(body.reason).trim()],
      )
    ).rows[0];
    await this.audit(
      client,
      actor,
      commandId,
      id,
      'releaseTraceHold',
      this.hold(before),
      this.hold(row),
    );
    return { status: 200, body: { data: this.hold(row) }, headers: { etag: editToken(row) } };
  }

  private async audit(
    client: PoolClient,
    actor: Actor,
    commandId: string,
    holdId: string,
    operation: string,
    before: Body,
    after: Body,
  ) {
    await client.query(
      `INSERT INTO app.gps_events(actor_user_id,command_id,hold_id,operation,before_state,after_state)
      VALUES ($1,$2,$3,$4,$5,$6)`,
      [actor.userId, commandId, holdId, operation, before, after],
    );
  }

  private hold(r: QueryResultRow): Body {
    return {
      id: r.id,
      incidentId: r.incident_id,
      tripId: r.trip_id,
      receivedFrom: iso(r.received_from),
      receivedTo: iso(r.received_to),
      reason: r.reason,
      reviewAt: iso(r.review_at),
      state: r.state,
      editToken: editToken(r),
      createdAt: iso(r.created_at),
      updatedAt: iso(r.updated_at),
      version: r.version,
    };
  }

  /**
   * Fold finished runs into the learned speeds.
   *
   * Each fix is projected onto the published line, which turns a trace into a
   * distance travelled. A segment's speed is the ground it covers divided by
   * the time between the bus first reaching its start and first reaching its
   * end, so a bus that idles mid-segment is described honestly rather than
   * dropped. Every trip contributes at most one sample per segment, and the
   * published speed is the median of the recent ones, so one crawl through a
   * flooded road does not become the route's new truth.
   */
  private async learn(client: PoolClient, limit: number): Promise<Outcome> {
    const result = started();
    const candidates = (
      await client.query(
        `SELECT t.id,t.pattern_version_id,t.completed_at,s.service_window,v.geometry_id
        FROM app.trips t
        JOIN app.service_schedules s
          ON s.id=t.schedule_id AND s.pattern_version_id=t.pattern_version_id
        JOIN app.route_pattern_versions v ON v.id=t.pattern_version_id
        LEFT JOIN app.trip_learning l ON l.trip_id=t.id
        WHERE t.status='completed' AND l.trip_id IS NULL AND v.geometry_id IS NOT NULL
        ORDER BY t.completed_at,t.id LIMIT $1
        FOR UPDATE OF t SKIP LOCKED`,
        [limit],
      )
    ).rows;
    result.considered = candidates.length;
    const recompute = new Map<string, { version: string; window: string }>();
    for (const trip of candidates)
      await perResource(client, result, trip.id, async () => {
        const learned = await client.query(
          `WITH line AS (
            SELECT g.line,ST_Length(g.line::geography) AS length_m
            FROM app.route_geometries g
            WHERE g.id=$2 AND g.pattern_version_id=$3 AND g.state='published'
          ), fixes AS (
            SELECT p.effective_captured_at AS at,p.id,
                   ST_LineLocatePoint(l.line,p.location)*l.length_m AS along_m
            FROM app.trip_positions p CROSS JOIN line l
            WHERE p.trip_id=$1 AND NOT p.clock_adjusted
              AND (p.accuracy_meters IS NULL OR p.accuracy_meters<=$4)
          ), bounds AS (
            SELECT s.ordinal AS from_ordinal,d.distance_meters AS from_m,
                   lead(d.distance_meters) OVER (ORDER BY s.ordinal) AS to_m
            FROM app.route_pattern_stops s
            JOIN app.geometry_stop_distances d
              ON d.stop_occurrence_id=s.id AND d.geometry_id=$2
            WHERE s.pattern_version_id=$3
          ), edges AS (
            SELECT b.from_ordinal,e.mark,e.at_m
            FROM bounds b
            CROSS JOIN LATERAL (VALUES ('enter',b.from_m),('exit',b.to_m)) AS e(mark,at_m)
            WHERE b.to_m IS NOT NULL AND b.to_m>b.from_m
          ), steps AS (
            SELECT f.at,f.id,f.along_m,
                   lag(f.at) OVER w AS from_at,lag(f.along_m) OVER w AS from_m
            FROM fixes f WINDOW w AS (ORDER BY f.at,f.id)
          ), times AS (
            -- A boundary is crossed between two observations the bus made back
            -- to back, and the moment is interpolated between them. Picking the
            -- nearest fix on each side by distance instead would happily pair
            -- readings from different passes: a trace that runs on, backtracks
            -- and returns would be credited with a crossing it never made, and
            -- a sparse trace with ground it was already past.
            SELECT e.from_ordinal,e.mark,(
              SELECT CASE WHEN s.along_m>s.from_m
                       THEN s.from_at+(s.at-s.from_at)*((e.at_m-s.from_m)/(s.along_m-s.from_m))
                       ELSE s.from_at END
              FROM steps s
              WHERE s.from_m IS NOT NULL AND s.from_m<=e.at_m AND s.along_m>=e.at_m
              ORDER BY s.at,s.id LIMIT 1) AS at
            FROM edges e
          ), spans AS (
            SELECT b.from_ordinal,b.to_m-b.from_m AS metres,
                   max(t.at) FILTER (WHERE t.mark='enter') AS entered,
                   max(t.at) FILTER (WHERE t.mark='exit') AS left_at
            FROM bounds b JOIN times t ON t.from_ordinal=b.from_ordinal AND t.at IS NOT NULL
            GROUP BY b.from_ordinal,b.from_m,b.to_m
          ), observed AS (
            SELECT s.from_ordinal,
                   s.metres/EXTRACT(EPOCH FROM (s.left_at-s.entered)) AS mps
            FROM spans s
            WHERE s.entered IS NOT NULL AND s.left_at IS NOT NULL AND s.left_at>s.entered
          )
          INSERT INTO app.segment_samples
            (pattern_version_id,service_window,from_ordinal,metres_per_second,observed_on)
          SELECT $3,$5,o.from_ordinal,o.mps,$6::date FROM observed o
          WHERE o.mps BETWEEN $7 AND $8
          RETURNING from_ordinal`,
          [
            trip.id,
            trip.geometry_id,
            trip.pattern_version_id,
            MAX_LEARNING_ACCURACY_METERS,
            trip.service_window,
            trip.completed_at,
            MIN_LEARNED_SPEED_MPS,
            MAX_LEARNED_SPEED_MPS,
          ],
        );
        // The marker is written either way: a run that taught us nothing has
        // still been looked at, and must not come back on the next sweep.
        await client.query(
          `INSERT INTO app.trip_learning
            (trip_id,pattern_version_id,geometry_id,service_window,segments_learned)
          VALUES ($1,$2,$3,$4,$5)`,
          [
            trip.id,
            trip.pattern_version_id,
            trip.geometry_id,
            trip.service_window,
            learned.rowCount ?? 0,
          ],
        );
        if (!learned.rowCount) return 'blocked';
        recompute.set(`${trip.pattern_version_id}:${trip.service_window}`, {
          version: trip.pattern_version_id,
          window: trip.service_window,
        });
        return 'succeeded';
      });
    // Sorted so two sweeps touching the same pair of routes take the locks in
    // the same order and cannot deadlock against each other.
    for (const key of [...recompute.keys()].sort()) {
      const { version, window } = recompute.get(key)!;
      await lock(client, speedsLockKey(version, window));
      await client.query(
        `INSERT INTO app.segment_speeds
          (pattern_version_id,service_window,from_ordinal,metres_per_second,sample_count,geometry_id)
        SELECT r.pattern_version_id,r.service_window,r.from_ordinal,
               percentile_cont(0.5) WITHIN GROUP (ORDER BY r.metres_per_second),
               count(*),v.geometry_id
        FROM (
          SELECT s.*,row_number() OVER (
            PARTITION BY s.from_ordinal ORDER BY s.observed_on DESC,s.id DESC) AS recency
          FROM app.segment_samples s
          WHERE s.pattern_version_id=$1 AND s.service_window=$2
        ) r
        JOIN app.route_pattern_versions v ON v.id=r.pattern_version_id
        WHERE r.recency<=$3 AND v.geometry_id IS NOT NULL
        GROUP BY r.pattern_version_id,r.service_window,r.from_ordinal,v.geometry_id
        ON CONFLICT (pattern_version_id,service_window,from_ordinal) DO UPDATE
          SET metres_per_second=EXCLUDED.metres_per_second,
              sample_count=EXCLUDED.sample_count,
              geometry_id=EXCLUDED.geometry_id,
              computed_at=clock_timestamp()`,
        [version, window, SPEED_SAMPLE_WINDOW],
      );
    }
    return { status: 200, body: { data: result }, headers: {} };
  }

  /**
   * Delete traces past the retention deadline.
   *
   * The batch is chosen from fixes that can actually be deleted, and bounded
   * by fixes rather than by trips, so a trip whose whole trace is held cannot
   * take a slot from a trip the sweep could have finished. An active hold
   * keeps the fixes inside the receipt window it names and only those, so an
   * incident retains its evidence without retaining a driver's whole history.
   */
  private async purge(client: PoolClient, limit: number): Promise<Outcome> {
    const result = started();
    const deadline = await retentionDeadline(client);
    const held = `NOT EXISTS (SELECT 1 FROM app.trace_holds h
      WHERE h.trip_id=%s.trip_id AND h.state='active'
        AND %s.received_at>=h.received_from AND %s.received_at<h.received_to)`;
    const unheld = (alias: string) => held.replaceAll('%s', alias);
    const due = (
      await client.query(
        `SELECT p.trip_id,array_agg(p.id) AS ids FROM (
          SELECT q.id,q.trip_id FROM app.trip_positions q
          WHERE q.received_at<$1 AND ${unheld('q')}
          ORDER BY q.received_at,q.id LIMIT $2
        ) p GROUP BY p.trip_id ORDER BY p.trip_id`,
        [deadline, limit],
      )
    ).rows;
    result.considered = due.length;
    for (const { trip_id: tripId, ids } of due)
      await perResource(client, result, tripId, async () => {
        // Hold creation takes this same lock, so a hold committed while the
        // sweep was choosing its batch is seen by the deletes below rather
        // than losing the evidence it was created to keep. The predicate is
        // repeated there because the lock orders the two, and the trigger
        // underneath refuses the delete outright if either of us is wrong.
        await lock(client, traceLockKey(tripId));
        await client.query(
          `DELETE FROM app.trip_live_positions lp
          WHERE lp.trip_id=$1 AND lp.position_id=ANY($2::uuid[]) AND ${unheld('lp')}`,
          [tripId, ids],
        );
        await client.query(
          `DELETE FROM app.trip_positions p WHERE p.id=ANY($1::uuid[]) AND ${unheld('p')}`,
          [ids],
        );
        const kept = (
          await client.query(
            'SELECT 1 FROM app.trip_positions WHERE trip_id=$1 AND received_at<$2 LIMIT 1',
            [tripId, deadline],
          )
        ).rowCount;
        return kept ? 'blocked' : 'succeeded';
      });
    return { status: 200, body: { data: result }, headers: {} };
  }

  async read(
    client: PoolClient,
    operation: GpsRead,
    actor: Actor,
    query: Record<string, string | undefined>,
  ): Promise<Outcome> {
    if (operation !== 'listTraceHolds') return notFound();
    const limit = query.limit === undefined ? 50 : Number(query.limit);
    if (
      !Number.isInteger(limit) ||
      limit < 1 ||
      limit > 200 ||
      (query.limit !== undefined && !/^[1-9]\d*$/.test(query.limit))
    )
      fail(400, 'invalid_query', 'Invalid page size.');
    const values: unknown[] = [];
    const now = (await client.query('SELECT clock_timestamp() AS now')).rows[0].now as Date;
    // The reviewed contract offers no filter here, so there is none to bind.
    // Anything added later must join this context, or a cursor from one query
    // would decode against another and silently hide matching rows.
    const context = `gps:${operation}:${actor.userId}`;
    const cursor = query.cursor ? this.cursors.decode(query.cursor, context, now) : null;
    values.push(cursor?.time ?? null, cursor?.id ?? null, limit + 1);
    const rows = (
      await client.query(
        `SELECT x.*,to_char(x.created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
        FROM app.trace_holds x
        WHERE ($${values.length - 2}::timestamptz IS NULL
            OR (x.created_at,x.id)<($${values.length - 2}::timestamptz,$${values.length - 1}::uuid))
        ORDER BY x.created_at DESC,x.id DESC LIMIT $${values.length}`,
        values,
      )
    ).rows;
    const page = rows.slice(0, limit);
    const last = page[page.length - 1];
    return {
      status: 200,
      body: {
        data: page.map((r) => this.hold(r)),
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
}
