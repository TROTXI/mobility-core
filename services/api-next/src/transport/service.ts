import { createHash, randomUUID } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { cursorCodec } from './cursor.js';
import { fail, mapDatabaseError } from './errors.js';
import {
  Catalog,
  catalogCommands,
  catalogReads,
  publicCatalogReads,
  catalogId,
} from './catalog.js';
import type { CatalogCommand, CatalogRead } from './catalog.js';
import { Fleet, fleetCommands, fleetReads, driverFleetOperations } from './fleet.js';
import { Gps, gpsCommands, gpsReads, driverGpsOperations } from './gps.js';
import { Trips, tripReads } from './trips.js';
import type { TripRead } from './trips.js';
import type { GpsCommand, GpsRead, GpsLocked } from './gps.js';
import { overviewReads, readOverview } from './overview.js';
import type { OverviewRead } from './overview.js';
import type { FleetCommand, FleetRead, FleetLocked } from './fleet.js';

export type Command =
  | CatalogCommand
  | FleetCommand
  | GpsCommand
  | 'createSchedule'
  | 'createTrip'
  | 'assignTrip'
  | 'rescheduleTrip'
  | 'cancelTrip'
  | 'startTrip'
  | 'completeTrip'
  | 'recordArrival';
export type Read =
  'listSchedules' | 'listOpsTrips' | 'listDriverTrips' | FleetRead | GpsRead | OverviewRead;
type Json = null | boolean | number | string | Json[] | { [key: string]: Json };
export type Body = Record<string, Json>;
export interface Outcome {
  status: number;
  body: Json;
  headers: Record<string, string>;
}
export interface Actor {
  userId: string;
  sessionId: string;
}
export interface TripRow {
  id: string;
  schedule_id: string;
  departure_id: string;
  pattern_version_id: string;
  service_date: string;
  run_number: number;
  assigned_driver_id: string | null;
  vehicle_id: string | null;
  status: 'scheduled' | 'active' | 'completed' | 'cancelled';
  scheduled_at: Date;
  current_stop_occurrence_id: string | null;
  started_at: Date | null;
  completed_at: Date | null;
  version: number;
}
export interface ReservationChange {
  operation: 'assignTrip' | 'rescheduleTrip' | 'cancelTrip';
  before: Readonly<TripRow>;
  input: Readonly<Body>;
  actorUserId: string;
}
export interface Dependencies {
  pool: Pool;
  cursorSecret: Buffer;
  // Must validate session/credential revocation using this transaction, not a
  // client role claim. There is no permissive default until identity lands.
  authorizeSession: (client: PoolClient, actor: Actor) => Promise<void>;
  // Trip lock is already held. Validate/release/update affected reservations
  // using THIS client or throw; never commit or call external services here.
  coordinateReservations?: (client: PoolClient, change: ReservationChange) => Promise<void>;
}
export function canonical(value: Json): string {
  if (Array.isArray(value)) return `[${value.map(canonical).join(',')}]`;
  if (value !== null && typeof value === 'object')
    return `{${Object.keys(value)
      .sort()
      .map((k) => `${JSON.stringify(k)}:${canonical(value[k]!)}`)
      .join(',')}}`;
  return JSON.stringify(value);
}
const digest = (text: string) => createHash('sha256').update(text).digest('hex');
export const tripEditToken = (trip: Pick<TripRow, 'id' | 'version'>) =>
  `"trip:${trip.id}:${trip.version}"`;
const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
function resourceId(value: Json | undefined): string {
  if (typeof value !== 'string' || !uuidPattern.test(value))
    fail(404, 'not_found', 'Resource not found.');
  return value.toLowerCase();
}
function state(t: TripRow): Body {
  return {
    status: t.status,
    scheduledAt: t.scheduled_at.toISOString(),
    assignedDriverId: t.assigned_driver_id,
    vehicleId: t.vehicle_id,
    currentStopOccurrenceId: t.current_stop_occurrence_id,
    version: t.version,
  };
}
const driverOperation = (operation: string) =>
  ['startTrip', 'completeTrip', 'recordArrival', 'listDriverTrips'].includes(operation) ||
  (driverFleetOperations as readonly string[]).includes(operation) ||
  (driverGpsOperations as readonly string[]).includes(operation);
const commands = new Set([
  ...catalogCommands,
  ...fleetCommands,
  ...gpsCommands,
  'createSchedule',
  'createTrip',
  'assignTrip',
  'rescheduleTrip',
  'cancelTrip',
  'startTrip',
  'completeTrip',
  'recordArrival',
]);
export class TransportService {
  private readonly cursors;
  private readonly catalog;
  private readonly fleet;
  private readonly gps;
  private readonly trips;
  constructor(private readonly deps: Dependencies) {
    if (typeof deps.authorizeSession !== 'function')
      throw new Error('A current-session authorization adapter is required');
    this.cursors = cursorCodec(deps.cursorSecret);
    this.catalog = new Catalog(deps.cursorSecret);
    this.fleet = new Fleet(deps.cursorSecret);
    this.gps = new Gps(deps.cursorSecret);
    this.trips = new Trips(deps.cursorSecret);
  }
  private async transaction<T>(
    work: (client: PoolClient) => Promise<T>,
    consistentRead = false,
  ): Promise<T> {
    let client: PoolClient | undefined;
    try {
      client = await this.deps.pool.connect();
      await client.query(consistentRead ? 'BEGIN ISOLATION LEVEL REPEATABLE READ' : 'BEGIN');
      await client.query("SET LOCAL TIME ZONE 'UTC'");
      await client.query("SET LOCAL lock_timeout='3s'");
      await client.query("SET LOCAL statement_timeout='10s'");
      const result = await work(client);
      await client.query('COMMIT');
      return result;
    } catch (error) {
      if (client) await client.query('ROLLBACK').catch(() => undefined);
      throw mapDatabaseError(error);
    } finally {
      client?.release();
    }
  }
  private async authorize(
    client: PoolClient,
    actor: Actor,
    operation: string,
  ): Promise<string | null> {
    await this.deps.authorizeSession(client, actor);
    const user = (
      await client.query(
        'SELECT role FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR SHARE',
        [resourceId(actor.userId)],
      )
    ).rows[0];
    if (!user) fail(401, 'unauthenticated', 'Sign in to continue.');
    const isDriver = driverOperation(operation);
    if (user.role !== (isDriver ? 'driver' : 'admin'))
      fail(403, 'forbidden', 'This operation is not available to your account.');
    if (!isDriver) return null;
    const driver = (
      await client.query(
        'SELECT id FROM app.drivers WHERE user_id=$1 AND archived_at IS NULL FOR SHARE',
        [actor.userId],
      )
    ).rows[0];
    if (!driver) fail(404, 'not_found', 'Resource not found.');
    return driver.id as string;
  }
  private async ownedTrip(
    client: PoolClient,
    target: string,
    driverId: string | null,
  ): Promise<TripRow> {
    const row = (
      await client.query(
        `SELECT *,service_date::text FROM app.trips
      WHERE id=$1 AND ($2::uuid IS NULL OR assigned_driver_id=$2) FOR UPDATE`,
        [resourceId(target), driverId],
      )
    ).rows[0];
    if (!row) fail(404, 'not_found', 'Resource not found.');
    return row as TripRow;
  }
  private normalize(operation: Command, input: Body): Body {
    if ((catalogCommands as readonly string[]).includes(operation))
      return this.catalog.normalize(operation as CatalogCommand, input);
    if ((fleetCommands as readonly string[]).includes(operation))
      return this.fleet.normalize(operation as FleetCommand, input);
    if ((gpsCommands as readonly string[]).includes(operation))
      return this.gps.normalize(operation as GpsCommand, input);
    const body = structuredClone(input);
    // PostgreSQL UUID identity is case-insensitive. Match it in comparisons,
    // input hashes and retry scopes rather than treating spelling as identity.
    for (const field of [
      'patternVersionId',
      'scheduleId',
      'stopOccurrenceId',
      'driverId',
      'vehicleId',
    ])
      if (body[field] !== undefined && body[field] !== null) body[field] = resourceId(body[field]);
    if (operation === 'createSchedule' && (body.departure as Body).kind === 'existing') {
      const departure = body.departure as Body;
      departure.departureId = resourceId(departure.departureId);
    }
    if (operation === 'createTrip') body.runNumber ??= 1;
    if (operation === 'recordArrival') body.correction ??= false;
    if (operation === 'createSchedule') {
      const days = body.weekdays as number[];
      if (
        new Set(days).size !== days.length ||
        (body.effectiveTo !== null && String(body.effectiveTo) < String(body.effectiveFrom))
      )
        fail(400, 'invalid_schedule', 'Schedule weekdays must be unique and dates ordered.');
      body.weekdays = [...days].sort((a, b) => a - b);
    }
    return body;
  }
  async command(
    actor: Actor,
    operation: Command,
    target: string,
    input: Body,
    key: string,
    ifMatch?: string,
    childId?: string,
  ): Promise<Outcome> {
    if (!commands.has(operation)) fail(404, 'not_found', 'Operation not found.');
    actor = { ...actor, userId: resourceId(actor.userId) };
    if (target !== 'collection') target = resourceId(target);
    if (childId !== undefined) childId = catalogId(childId);
    const body = this.normalize(operation, input);
    if (operation === 'recordPosition') {
      // The reviewed wire contract is fix_id, not command idempotency. The
      // unique (trip, clientFixId) row and payload digest are the durable
      // receipt. Never cache past assignment/session checks in a second,
      // seven-day command receipt, nor retain an extra receipt per GPS fix.
      return this.transaction(async (client) => {
        const driverId = await this.authorize(client, actor, operation);
        return this.gps.execute(client, actor, operation, target, body, randomUUID(), driverId);
      });
    }
    const catalog = (catalogCommands as readonly string[]).includes(operation);
    const fleet = (fleetCommands as readonly string[]).includes(operation);
    const gps = (gpsCommands as readonly string[]).includes(operation);
    // Nested version identity is part of the receipt scope, not just its parent.
    const receiptTarget = childId === undefined ? target : `${target}/${childId}`;
    if (!key || key.length > 128)
      fail(400, 'idempotency_key_required', 'Supply an Idempotency-Key of 1 to 128 characters.');
    const keyHash = digest(key),
      inputHash = digest(canonical(body));
    return this.transaction(async (client) => {
      // Fixed lock order: receipt -> session/user/driver -> trip -> references.
      // It is the same for different HTTP workers and application instances.
      await client.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
        canonical([actor.userId, operation, receiptTarget, keyHash]),
      ]);
      const driverId = await this.authorize(client, actor, operation);
      // ownedTrip throws 404 for a missing or foreign resource, before replay
      // lookup and before any 428/412 precondition result (for ops and drivers).
      const locked = catalog
        ? await this.catalog.lock(client, operation as CatalogCommand, target, childId)
        : null;
      const fleetLocked: FleetLocked | null = fleet
        ? await this.fleet.lock(client, operation as FleetCommand, target, driverId)
        : null;
      const gpsLocked: GpsLocked | null = gps
        ? await this.gps.lock(client, operation as GpsCommand, target)
        : null;
      const trip =
        catalog || fleet || gps || target === 'collection'
          ? null
          : await this.ownedTrip(client, target, driverId);
      const prior = (
        await client.query(
          `SELECT *, replay_expires_at <= clock_timestamp() AS expired
        FROM app.transport_commands WHERE actor_user_id=$1 AND operation=$2 AND target=$3 AND key_hash=$4`,
          [actor.userId, operation, receiptTarget, keyHash],
        )
      ).rows[0];
      if (prior) {
        if (prior.input_hash !== inputHash)
          fail(
            409,
            'idempotency_payload_conflict',
            'This key was already used for different input.',
          );
        if (prior.expired)
          fail(
            409,
            'idempotency_key_expired',
            'This replay window has expired. Refresh the resource before another action.',
          );
        return {
          status: prior.response_status,
          body: prior.response_body,
          headers: prior.response_headers,
        };
      }
      if (locked) this.catalog.precondition(operation as CatalogCommand, locked, ifMatch);
      if (fleetLocked) this.fleet.precondition(operation as FleetCommand, fleetLocked, ifMatch);
      if (gpsLocked) this.gps.precondition(operation as GpsCommand, gpsLocked, ifMatch);
      if (['recordArrival', 'assignTrip', 'rescheduleTrip', 'cancelTrip'].includes(operation)) {
        if (!ifMatch)
          fail(428, 'precondition_required', 'Supply the resource edit token in If-Match.');
        if (!trip || ifMatch !== tripEditToken(trip))
          fail(412, 'precondition_failed', 'The resource changed. Refresh it and try again.');
      }
      const commandId = randomUUID();
      let result: Outcome;
      if (gps)
        result = await this.gps.execute(
          client,
          actor,
          operation as GpsCommand,
          target,
          body,
          commandId,
          driverId,
        );
      else if (fleet)
        result = await this.fleet.execute(
          client,
          actor,
          operation as FleetCommand,
          target,
          body,
          commandId,
          driverId,
        );
      else if (locked)
        result = await this.catalog.execute(
          client,
          actor,
          operation as CatalogCommand,
          target,
          body,
          commandId,
          locked,
        );
      else if (operation === 'createSchedule')
        result = await this.createSchedule(client, actor, body, commandId);
      else if (operation === 'createTrip')
        result = await this.createTrip(client, actor, body, commandId);
      else {
        if (!trip) fail(404, 'not_found', 'Resource not found.');
        result = await this.changeTrip(client, actor, operation, trip, body, commandId);
      }
      await client.query(
        `INSERT INTO app.transport_commands
        (id,actor_user_id,operation,target,key_hash,input_hash,response_status,response_body,response_headers,replay_expires_at)
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,clock_timestamp()+interval '7 days')`,
        [
          commandId,
          actor.userId,
          operation,
          receiptTarget,
          keyHash,
          inputHash,
          result.status,
          result.body,
          result.headers,
        ],
      );
      return result;
    });
  }
  /**
   * Trip reads for a signed-in rider. Not readCatalog: those authorize the ops
   * role, and these belong to anyone with an account. Each one decides its own
   * entitlement from current facts rather than from the session's role.
   */
  async readTrips(
    actor: Actor | null,
    operation: TripRead,
    params: { id?: string },
    query: Record<string, string | undefined>,
  ): Promise<Outcome> {
    if (!(tripReads as readonly string[]).includes(operation))
      fail(404, 'not_found', 'Operation not found.');
    if (!actor) fail(401, 'unauthenticated', 'Sign in to continue.');
    const caller = { ...actor, userId: resourceId(actor.userId) };
    return this.transaction(async (client) => {
      await this.deps.authorizeSession(client, caller);
      return this.trips.read(client, operation as TripRead, caller, params, query);
    }, true);
  }
  async readCatalog(
    actor: Actor | null,
    operation: CatalogRead,
    params: { id?: string; versionId?: string },
    query: Record<string, string | undefined>,
  ): Promise<Outcome> {
    if (!(catalogReads as readonly string[]).includes(operation))
      fail(404, 'not_found', 'Operation not found.');
    if (actor) actor = { ...actor, userId: resourceId(actor.userId) };
    return this.transaction(async (client) => {
      if (!(publicCatalogReads as readonly string[]).includes(operation)) {
        if (!actor) fail(401, 'unauthenticated', 'Sign in to continue.');
        await this.authorize(client, actor, operation);
      }
      // One snapshot for a composed page; concurrent publication/archival cannot
      // leak drafts or mix an old geometry with a new occurrence collection.
      return this.catalog.read(client, operation, actor, params, query);
    }, true);
  }
  private async createSchedule(
    client: PoolClient,
    actor: Actor,
    input: Body,
    commandId: string,
  ): Promise<Outcome> {
    const versionId = resourceId(input.patternVersionId);
    const version = (
      await client.query(
        'SELECT id,pattern_id FROM app.route_pattern_versions WHERE id=$1 FOR UPDATE',
        [versionId],
      )
    ).rows[0];
    if (!version) fail(404, 'not_found', 'Resource not found.');
    const choice = input.departure as Body;
    let departureId: string;
    if (choice.kind === 'new') {
      departureId = (
        await client.query(
          'INSERT INTO app.service_departures(pattern_id) VALUES ($1) RETURNING id',
          [version.pattern_id],
        )
      ).rows[0].id;
    } else {
      departureId = resourceId(choice.departureId);
      const departure = (
        await client.query('SELECT id FROM app.service_departures WHERE id=$1 AND pattern_id=$2', [
          departureId,
          version.pattern_id,
        ])
      ).rows[0];
      if (!departure)
        fail(409, 'invalid_departure', 'The departure does not belong to this pattern.');
    }
    const row = (
      await client.query(
        `INSERT INTO app.service_schedules
      (pattern_version_id,pattern_id,departure_id,service_window,local_departure,time_zone,weekdays,effective_from,effective_to)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING id`,
        [
          versionId,
          version.pattern_id,
          departureId,
          input.serviceWindow,
          input.localDeparture,
          input.timeZone,
          input.weekdays,
          input.effectiveFrom,
          input.effectiveTo,
        ],
      )
    ).rows[0];
    const data = clean((await this.scheduleRows(client, 's.id=$1', [row.id]))[0]!);
    await client.query(
      `INSERT INTO app.schedule_events(schedule_id,actor_user_id,command_id,operation,after_state)
      VALUES ($1,$2,$3,'create',$4)`,
      [row.id, actor.userId, commandId, data],
    );
    return {
      status: 201,
      body: { data },
      headers: { location: `/v1/ops/service-schedules/${row.id}` },
    };
  }
  private async createTrip(
    client: PoolClient,
    actor: Actor,
    input: Body,
    commandId: string,
  ): Promise<Outcome> {
    const scheduleId = resourceId(input.scheduleId);
    const schedule = (
      await client.query('SELECT * FROM app.service_schedules WHERE id=$1', [scheduleId])
    ).rows[0];
    if (!schedule) fail(404, 'not_found', 'Resource not found.');
    const row = (
      await client.query(
        `INSERT INTO app.trips(schedule_id,departure_id,pattern_version_id,service_date,scheduled_at,run_number)
      VALUES ($1,$2,$3,$4,$5,$6) RETURNING *,service_date::text`,
        [
          scheduleId,
          schedule.departure_id,
          schedule.pattern_version_id,
          input.serviceDate,
          input.scheduledAt,
          input.runNumber,
        ],
      )
    ).rows[0] as TripRow;
    await this.event(client, actor, commandId, 'create', null, row, null);
    const result = await this.tripOutcome(client, row, true);
    return {
      ...result,
      status: 201,
      headers: { ...result.headers, location: `/v1/ops/trips/${row.id}` },
    };
  }
  private async event(
    client: PoolClient,
    actor: Actor,
    commandId: string,
    operation: string,
    before: TripRow | null,
    after: TripRow,
    reason: Json | undefined,
  ) {
    await client.query(
      `INSERT INTO app.trip_events(trip_id,actor_user_id,command_id,operation,reason,before_state,after_state)
      VALUES ($1,$2,$3,$4,$5,$6,$7)`,
      [
        after.id,
        actor.userId,
        commandId,
        operation,
        reason ?? null,
        before ? state(before) : {},
        state(after),
      ],
    );
  }
  private async changeTrip(
    client: PoolClient,
    actor: Actor,
    operation: Command,
    trip: TripRow,
    input: Body,
    commandId: string,
  ): Promise<Outcome> {
    let sql: string, values: unknown[], event: string;
    const ops = !driverOperation(operation);
    if (operation === 'startTrip' || operation === 'completeTrip') {
      const target = operation === 'startTrip' ? 'active' : 'completed';
      if (trip.status === target) return this.tripOutcome(client, trip, false);
      if (trip.status !== (target === 'active' ? 'scheduled' : 'active'))
        fail(409, 'illegal_transition', 'This trip cannot make that transition.');
      sql =
        target === 'active'
          ? "status='active', started_at=clock_timestamp()"
          : "status='completed', completed_at=GREATEST(started_at,clock_timestamp())";
      values = [];
      event = target === 'active' ? 'start' : 'complete';
    } else if (operation === 'recordArrival') {
      if (trip.status !== 'active')
        fail(409, 'illegal_transition', 'Only active trips can record arrivals.');
      const occurrence = resourceId(input.stopOccurrenceId);
      const stops = (
        await client.query(
          'SELECT id,ordinal FROM app.route_pattern_stops WHERE pattern_version_id=$1',
          [trip.pattern_version_id],
        )
      ).rows;
      const next = stops.find((s) => s.id === occurrence),
        current = stops.find((s) => s.id === trip.current_stop_occurrence_id);
      if (!next)
        fail(409, 'invalid_stop_occurrence', 'The stop does not belong to this trip version.');
      if (current && next.ordinal < current.ordinal && !input.correction)
        fail(
          409,
          'explicit_correction_required',
          'Backward progress requires an explicit correction.',
        );
      if (trip.current_stop_occurrence_id === occurrence)
        return this.tripOutcome(client, trip, false);
      sql = 'current_stop_occurrence_id=$2';
      values = [occurrence];
      event = input.correction ? 'correct_arrival' : 'arrive';
    } else {
      if (trip.status !== 'scheduled')
        fail(409, 'illegal_transition', 'Only unstarted trips can be edited or cancelled.');
      if (!this.deps.coordinateReservations)
        fail(
          503,
          'reservation_coordinator_unavailable',
          'Booking-aware trip edits are not available yet.',
        );
      if (operation === 'assignTrip') {
        for (const field of ['driverId', 'vehicleId'])
          if (input[field] !== null) resourceId(input[field]);
        sql = 'assigned_driver_id=$2,vehicle_id=$3';
        values = [input.driverId, input.vehicleId];
        event = 'assign';
      } else if (operation === 'rescheduleTrip') {
        sql = 'scheduled_at=$2';
        values = [input.scheduledAt];
        event = 'reschedule';
      } else if (operation === 'cancelTrip') {
        if (!String(input.reason ?? '').trim())
          fail(400, 'reason_required', 'Supply a cancellation reason.');
        sql = "status='cancelled'";
        values = [];
        event = 'cancel';
      } else return fail(404, 'not_found', 'Operation not found.');
      await this.deps.coordinateReservations(client, {
        operation,
        before: trip,
        input,
        actorUserId: actor.userId,
      });
    }
    const updated = (
      await client.query(`UPDATE app.trips SET ${sql} WHERE id=$1 RETURNING *,service_date::text`, [
        trip.id,
        ...values,
      ])
    ).rows[0] as TripRow;
    await this.event(client, actor, commandId, event, trip, updated, input.reason);
    return this.tripOutcome(client, updated, ops);
  }
  private async tripOutcome(client: PoolClient, trip: TripRow, ops: boolean): Promise<Outcome> {
    const data = clean((await this.tripRows(client, 't.id=$1', [trip.id], ops))[0]!);
    return { status: 200, body: { data }, headers: { etag: tripEditToken(trip) } };
  }
  private async scheduleRows(
    client: PoolClient,
    where: string,
    values: unknown[],
    order = '',
  ): Promise<Body[]> {
    const rows = (
      await client.query(
        `SELECT s.*,s.effective_from::text,s.effective_to::text,
      to_char(s.created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
      FROM app.service_schedules s JOIN app.route_patterns p ON p.id=s.pattern_id WHERE ${where} ${order}`,
        values,
      )
    ).rows;
    return rows.map((s) => ({
      id: s.id,
      departureId: s.departure_id,
      patternVersionId: s.pattern_version_id,
      patternId: s.pattern_id,
      serviceWindow: s.service_window,
      localDeparture: s.local_departure.slice(0, 5),
      timeZone: s.time_zone,
      weekdays: s.weekdays,
      effectiveFrom: s.effective_from,
      effectiveTo: s.effective_to,
      createdAt: s.created_at.toISOString(),
      updatedAt: s.updated_at.toISOString(),
      version: s.version,
      _cursor: s.cursor_time,
    }));
  }
  private async tripRows(
    client: PoolClient,
    where: string,
    values: unknown[],
    ops: boolean,
    order = '',
  ): Promise<Body[]> {
    const rows = (
      await client.query(
        `SELECT t.*,t.service_date::text,p.route_id,p.id AS pattern_id,p.direction,v.label AS vehicle_label,v.plate AS vehicle_plate,
      to_char(t.scheduled_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
      FROM app.trips t JOIN app.route_pattern_versions pv ON pv.id=t.pattern_version_id
      JOIN app.route_patterns p ON p.id=pv.pattern_id LEFT JOIN app.vehicles v ON v.id=t.vehicle_id
      WHERE ${where} ${order}`,
        values,
      )
    ).rows;
    // One bounded occurrence query for the whole page, never N+1 per rider/trip.
    const versions = [...new Set(rows.map((t) => t.pattern_version_id))];
    const stops = versions.length
      ? (
          await client.query(
            `SELECT * FROM app.route_pattern_stops
      WHERE pattern_version_id=ANY($1::uuid[]) ORDER BY pattern_version_id,ordinal`,
            [versions],
          )
        ).rows
      : [];
    return rows.map((t) => ({
      id: t.id,
      departureId: t.departure_id,
      serviceDate: t.service_date,
      runNumber: t.run_number,
      routeId: t.route_id,
      patternId: t.pattern_id,
      patternVersionId: t.pattern_version_id,
      direction: t.direction,
      scheduledAt: t.scheduled_at.toISOString(),
      status: t.status,
      vehicleLabel: t.vehicle_label,
      vehiclePlate: t.vehicle_plate ?? null,
      startedAt: t.started_at?.toISOString() ?? null,
      completedAt: t.completed_at?.toISOString() ?? null,
      currentStopOccurrenceId: t.current_stop_occurrence_id,
      version: t.version,
      editToken: tripEditToken(t),
      stops: stops
        .filter((s) => s.pattern_version_id === t.pattern_version_id)
        .map((s) => ({
          id: s.id,
          stopId: s.stop_id,
          ordinal: s.ordinal,
          name: s.name,
          location: { latitude: s.latitude, longitude: s.longitude },
        })),
      ...(ops
        ? {
            scheduleId: t.schedule_id,
            assignedDriverId: t.assigned_driver_id,
            vehicleId: t.vehicle_id,
          }
        : {}),
      _cursor: t.cursor_time,
    }));
  }
  async list(
    actor: Actor,
    operation: Read,
    query: Record<string, string | undefined>,
  ): Promise<Outcome> {
    actor = { ...actor, userId: resourceId(actor.userId) };
    return this.transaction(async (client) => {
      const driverId = await this.authorize(client, actor, operation);
      if ((fleetReads as readonly string[]).includes(operation))
        return this.fleet.read(client, operation as FleetRead, actor, query, driverId);
      if ((gpsReads as readonly string[]).includes(operation))
        return this.gps.read(client, operation as GpsRead, actor, query);
      // One statement, so one snapshot: the board's numbers cannot disagree
      // with each other without a second query to disagree with.
      if ((overviewReads as readonly string[]).includes(operation))
        return readOverview(client, query);
      const now = new Date();
      const schedules = operation === 'listSchedules';
      const limit = query.limit === undefined ? 50 : Number(query.limit);
      if (!Number.isInteger(limit) || limit < 1 || limit > 200)
        fail(400, 'invalid_limit', 'Page size must be between 1 and 200.');
      const routeId = query.routeId ? resourceId(query.routeId) : null;
      const today = now.toISOString().slice(0, 10);
      const from =
          query.fromDate ?? new Date(Date.parse(today) - 6 * 86400000).toISOString().slice(0, 10),
        to = query.toDate ?? today;
      if (
        !schedules &&
        ((query.fromDate === undefined) !== (query.toDate === undefined) ||
          !validDate(from) ||
          !validDate(to) ||
          to < from ||
          Date.parse(to) - Date.parse(from) >= 31 * 86400000)
      )
        fail(400, 'invalid_date_range', 'Supply an ordered date range of at most 31 days.');
      const context = canonical([
        actor.userId,
        driverId,
        operation,
        routeId,
        limit,
        schedules ? null : from,
        schedules ? null : to,
      ]);
      const cursor = query.cursor ? this.cursors.decode(query.cursor, context, now) : null;
      const values: unknown[] = [routeId];
      let where = '($1::uuid IS NULL OR p.route_id=$1)';
      const column = schedules ? 's.created_at' : 't.scheduled_at',
        table = schedules ? 's' : 't',
        direction = schedules ? 'DESC' : 'ASC',
        comparison = schedules ? '<' : '>';
      if (!schedules) {
        values.push(driverId, from, to);
        where +=
          ' AND ($2::uuid IS NULL OR t.assigned_driver_id=$2) AND t.scheduled_at >= $3::date::timestamptz AND t.scheduled_at < ($4::date+1)::timestamptz';
      }
      if (cursor) {
        values.push(cursor.time, cursor.id);
        where += ` AND (${column},${table}.id) ${comparison} ($${values.length - 1}::timestamptz,$${values.length}::uuid)`;
      }
      values.push(limit + 1);
      const order = `ORDER BY ${column} ${direction},${table}.id ${direction} LIMIT $${values.length}${schedules ? '' : ' FOR SHARE OF t'}`;
      const rows = schedules
        ? await this.scheduleRows(client, where, values, order)
        : await this.tripRows(client, where, values, operation === 'listOpsTrips', order);
      const more = rows.length > limit,
        page = rows.slice(0, limit),
        last = page.at(-1);
      const nextCursor =
        more && last
          ? this.cursors.encode(String(last._cursor), String(last.id), context, now)
          : null;
      return { status: 200, body: { data: page.map(clean), page: { nextCursor } }, headers: {} };
    });
  }
}
function clean(row: Body): Body {
  const { _cursor, ...rest } = row;
  return rest;
}
function validDate(date: string) {
  return (
    /^\d{4}-\d\d-\d\d$/.test(date) &&
    Number.isFinite(Date.parse(date)) &&
    new Date(date).toISOString().slice(0, 10) === date
  );
}
