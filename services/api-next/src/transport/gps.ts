import type { PoolClient, QueryResultRow } from 'pg';
import type { Actor, Body, Outcome } from './service.js';
import { cursorCodec } from './cursor.js';
import { fail } from './errors.js';

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
 * How far ahead of the server a device clock may be and still be believed.
 * Beyond this the capture is clamped rather than refused: a driver with a
 * wrong phone clock still needs their bus to appear on the rider's map, and
 * refusing the fix would take the bus off it.
 */
export const MAX_FUTURE_SKEW_MS = 120_000;
/**
 * How far behind the server a capture may be and still be stored at all. A
 * queue older than this is history, not a live fix, and replaying it must not
 * quietly become today's trace.
 */
export const MAX_UPLOAD_AGE_MS = 24 * 60 * 60 * 1000;
/**
 * How long a raw trace is kept before the purge redacts it. This is a promise
 * to drivers, not a tuning knob: only an explicit trace hold extends it, and
 * only for the incident and receipt window that hold names.
 */
export const RETENTION_DAYS = 30;
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
export function effectiveCapture(capturedAt: Date, now: Date) {
  const ahead = capturedAt.getTime() - now.getTime();
  if (ahead > MAX_FUTURE_SKEW_MS) return { at: now, adjusted: true };
  if (-ahead > MAX_UPLOAD_AGE_MS) return null;
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
        'SELECT id,status FROM app.trips WHERE id=$1 AND assigned_driver_id=$2 FOR SHARE',
        [tripId, driverId],
      )
    ).rows[0];
    if (!trip) return notFound();
    if (trip.status !== 'active')
      fail(409, 'trip_not_active', 'Positions are only accepted while the run is active.');
    const now = (await client.query('SELECT clock_timestamp() AS now')).rows[0].now as Date;
    const capturedAt = new Date(String(body.capturedAt));
    if (!Number.isFinite(capturedAt.getTime()))
      fail(400, 'invalid_capture_time', 'Supply a real capture time.');
    const effective = effectiveCapture(capturedAt, now);
    if (!effective)
      fail(409, 'capture_too_old', 'This fix is older than the accepted upload window.');
    // An offline replay of the same fix is the same row, not a second one.
    const stored = (
      await client.query(
        `INSERT INTO app.trip_positions
          (trip_id,client_fix_id,captured_at,effective_captured_at,clock_adjusted,accuracy_meters,location)
        VALUES ($1,$2,$3,$4,$5,$6,ST_SetSRID(ST_MakePoint($7,$8),4326))
        ON CONFLICT (trip_id,client_fix_id) DO UPDATE SET trip_id=EXCLUDED.trip_id
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
        ],
      )
    ).rows[0];
    // Advance the marker only for a strictly newer capture. The trigger refuses
    // a backwards move, so the guard here is the WHERE, not a read-then-write.
    const advanced = await client.query(
      `INSERT INTO app.trip_live_positions
        (trip_id,position_id,effective_captured_at,received_at,location)
      VALUES ($1,$2,$3,$4,$5)
      ON CONFLICT (trip_id) DO UPDATE
        SET position_id=EXCLUDED.position_id,
            effective_captured_at=EXCLUDED.effective_captured_at,
            received_at=EXCLUDED.received_at,
            location=EXCLUDED.location,
            -- A run still reporting after its old trace was purged gets its
            -- marker back: there is a fresh location again, so the projection
            -- is no longer a redaction.
            redacted_at=NULL,
            updated_at=clock_timestamp()
        WHERE app.trip_live_positions.effective_captured_at<EXCLUDED.effective_captured_at
      RETURNING trip_id`,
      [tripId, stored.id, stored.effective_captured_at, stored.received_at, stored.location],
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
            SELECT p.effective_captured_at AS at,
                   ST_LineLocatePoint(l.line,p.location)*l.length_m AS along_m
            FROM app.trip_positions p CROSS JOIN line l
            WHERE p.trip_id=$1 AND p.location IS NOT NULL
              AND (p.accuracy_meters IS NULL OR p.accuracy_meters<=$4)
          ), bounds AS (
            SELECT s.ordinal AS from_ordinal,d.distance_meters AS from_m,
                   lead(d.distance_meters) OVER (ORDER BY s.ordinal) AS to_m
            FROM app.route_pattern_stops s
            JOIN app.geometry_stop_distances d
              ON d.stop_occurrence_id=s.id AND d.geometry_id=$2
            WHERE s.pattern_version_id=$3
          ), crossings AS (
            SELECT b.from_ordinal,b.to_m-b.from_m AS metres,
                   (SELECT min(f.at) FROM fixes f WHERE f.along_m>=b.from_m) AS entered,
                   (SELECT min(f.at) FROM fixes f WHERE f.along_m>=b.to_m) AS left_at
            FROM bounds b WHERE b.to_m IS NOT NULL AND b.to_m>b.from_m
          ), observed AS (
            SELECT c.from_ordinal,
                   c.metres/EXTRACT(EPOCH FROM (c.left_at-c.entered)) AS mps
            FROM crossings c
            WHERE c.entered IS NOT NULL AND c.left_at IS NOT NULL AND c.left_at>c.entered
          )
          INSERT INTO app.segment_samples
            (trip_id,pattern_version_id,service_window,from_ordinal,metres_per_second,observed_at)
          SELECT $1,$3,$5,o.from_ordinal,o.mps,$6 FROM observed o
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
    for (const { version, window } of recompute.values())
      await client.query(
        `INSERT INTO app.segment_speeds
          (pattern_version_id,service_window,from_ordinal,metres_per_second,sample_count,geometry_id)
        SELECT r.pattern_version_id,r.service_window,r.from_ordinal,
               percentile_cont(0.5) WITHIN GROUP (ORDER BY r.metres_per_second),
               count(*),v.geometry_id
        FROM (
          SELECT s.*,row_number() OVER (
            PARTITION BY s.from_ordinal ORDER BY s.observed_at DESC,s.trip_id DESC) AS recency
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
    return { status: 200, body: { data: result }, headers: {} };
  }

  /**
   * Redact traces past the retention promise.
   *
   * Nothing is deleted: the fix, its trip and its timings stay, the location
   * goes. An active trace hold keeps the fixes inside its receipt window and
   * only those, so an incident retains its evidence without retaining the
   * driver's whole history. A trip that ends the sweep still holding
   * something counts as blocked, which is how the queue stays visible.
   */
  private async purge(client: PoolClient, limit: number): Promise<Outcome> {
    const result = started();
    const deadline = new Date(
      ((await client.query('SELECT clock_timestamp() AS now')).rows[0].now as Date).getTime() -
        RETENTION_DAYS * 86_400_000,
    );
    const due = (
      await client.query(
        `SELECT p.trip_id FROM app.trip_positions p
        WHERE p.redacted_at IS NULL AND p.received_at<$1
        GROUP BY p.trip_id ORDER BY p.trip_id LIMIT $2`,
        [deadline, limit],
      )
    ).rows;
    result.considered = due.length;
    for (const { trip_id: tripId } of due)
      await perResource(client, result, tripId, async () => {
        await client.query(
          `UPDATE app.trip_positions p
          SET location=NULL,redacted_at=clock_timestamp()
          WHERE p.trip_id=$1 AND p.redacted_at IS NULL AND p.received_at<$2
            AND NOT EXISTS (
              SELECT 1 FROM app.trace_holds h
              WHERE h.trip_id=p.trip_id AND h.state='active'
                AND p.received_at>=h.received_from AND p.received_at<h.received_to)`,
          [tripId, deadline],
        );
        // The live marker is redacted exactly when the fix behind it is, so
        // the rider's map can never outlive the trace it was drawn from.
        await client.query(
          `UPDATE app.trip_live_positions lp
          SET location=NULL,redacted_at=clock_timestamp()
          WHERE lp.trip_id=$1 AND lp.redacted_at IS NULL
            AND EXISTS (SELECT 1 FROM app.trip_positions p
              WHERE p.id=lp.position_id AND p.redacted_at IS NOT NULL)`,
          [tripId],
        );
        const held = (
          await client.query(
            `SELECT 1 FROM app.trip_positions
            WHERE trip_id=$1 AND redacted_at IS NULL AND received_at<$2 LIMIT 1`,
            [tripId, deadline],
          )
        ).rowCount;
        return held ? 'blocked' : 'succeeded';
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
