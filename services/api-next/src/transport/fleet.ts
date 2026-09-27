import type { PoolClient, QueryResultRow } from 'pg';
import type { Actor, Body, Outcome } from './service.js';
import { cursorCodec } from './cursor.js';
import { fail } from './errors.js';

export const fleetCommands = [
  'createVehicle',
  'updateVehicle',
  'reportIncident',
  'decideIncident',
  'createDriverRequest',
  'withdrawDriverRequest',
  'decideDriverRequest',
] as const;
export type FleetCommand = (typeof fleetCommands)[number];
export const fleetReads = [
  'listOpsVehicles',
  'listDriverIncidents',
  'listOpsIncidents',
  'listDriverRequests',
  'listOpsDriverRequests',
  'listDriverAvailableRoutes',
] as const;
export type FleetRead = (typeof fleetReads)[number];
/** Operations a signed-in driver performs against their own records. */
export const driverFleetOperations = [
  'reportIncident',
  'createDriverRequest',
  'withdrawDriverRequest',
  'listDriverIncidents',
  'listDriverRequests',
  'listDriverAvailableRoutes',
] as const;

type Kind = 'vehicle' | 'incident' | 'request' | 'route';
// Only this constant map selects SQL identifiers; no request string becomes SQL.
const tables = {
  vehicle: 'app.vehicles',
  incident: 'app.driver_incidents',
  request: 'app.driver_requests',
  route: 'app.routes',
} as const;
// driver_incidents and driver_requests sit outside migration 001's bump_version
// trigger list, so every update below advances both columns explicitly. Without
// it the edit token never moves and a stale If-Match would always pass.
const BUMP = 'version=version+1,updated_at=clock_timestamp()';
const editToken = (kind: Kind, row: QueryResultRow) => `"${kind}:${row.id}:${row.version}"`;
const notFound = () => fail(404, 'not_found', 'Resource not found.');
// Trimmed and upper-cased so "gt 1234-20" and "GT 1234-20" cannot both occupy
// the operating fleet. Internal spacing is collapsed rather than removed:
// plates are read aloud and written down, and spacing is not the identifier.
const normalizePlate = (value: string) => value.trim().replace(/\s+/g, ' ').toUpperCase();
const subjectColumn = {
  vehicle: 'vehicle_id',
  incident: 'incident_id',
  request: 'request_id',
} as const;
const kindOf = (operation: FleetCommand): Exclude<Kind, 'route'> =>
  operation.endsWith('Vehicle')
    ? 'vehicle'
    : operation.endsWith('Incident')
      ? 'incident'
      : 'request';

export function fleetId(value: unknown): string {
  if (
    typeof value !== 'string' ||
    !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)
  )
    return notFound();
  return value.toLowerCase();
}
const trimmed = (value: unknown, field: string, max: number) => {
  if (value === undefined || value === null) return null;
  const text = String(value).trim();
  if (!text || text.length > max) fail(400, `invalid_${field}`, `Supply a usable ${field}.`);
  return text;
};

export interface FleetLocked {
  row: QueryResultRow | null;
}

export class Fleet {
  private readonly cursors;
  constructor(secret: Buffer) {
    this.cursors = cursorCodec(secret);
  }

  /**
   * Canonicalize before the caller hashes this body: a retry spelled
   * "gt 1234-20" must land in the same replay scope as "GT 1234-20" rather than
   * mint a second bus.
   */
  normalize(operation: FleetCommand, input: Body): Body {
    const body = structuredClone(input);
    if (operation === 'updateVehicle' && !Object.keys(body).length)
      fail(400, 'empty_edit', 'Supply at least one field to edit.');
    if (typeof body.plate === 'string') {
      body.plate = normalizePlate(body.plate);
      if (!body.plate) fail(400, 'invalid_plate', 'A non-blank registration plate is required.');
    }
    for (const field of ['label', 'make', 'colour'])
      if (typeof body[field] === 'string') {
        body[field] = (body[field] as string).trim();
        if (!body[field]) fail(400, `invalid_${field}`, `Supply a non-blank ${field} or null.`);
      }
    if (operation === 'reportIncident' && body.tripId !== undefined && body.tripId !== null)
      body.tripId = fleetId(body.tripId);
    if (operation === 'createDriverRequest' && body.routeId !== undefined)
      body.routeId = fleetId(body.routeId);
    return body;
  }

  async lock(
    client: PoolClient,
    operation: FleetCommand,
    target: string,
    driverId: string | null,
  ): Promise<FleetLocked> {
    if (['createVehicle', 'reportIncident', 'createDriverRequest'].includes(operation))
      return { row: null };
    const kind = kindOf(operation);
    // A driver only ever addresses their own record; ops address any. Ownership
    // is part of the lookup, so a foreign id is 404 rather than 403.
    const scope = driverId === null ? '' : ' AND driver_id=$2';
    const row = (
      await client.query(
        `SELECT * FROM ${tables[kind]} WHERE id=$1${scope} FOR UPDATE`,
        driverId === null ? [fleetId(target)] : [fleetId(target), driverId],
      )
    ).rows[0];
    if (!row) return notFound();
    return { row };
  }

  precondition(operation: FleetCommand, locked: FleetLocked, ifMatch?: string) {
    if (!['updateVehicle', 'decideIncident', 'decideDriverRequest'].includes(operation)) return;
    if (!ifMatch) fail(428, 'precondition_required', 'Supply the resource edit token in If-Match.');
    if (ifMatch !== editToken(kindOf(operation), locked.row!))
      fail(412, 'precondition_failed', 'The resource changed. Refresh it and try again.');
  }

  async execute(
    client: PoolClient,
    actor: Actor,
    operation: FleetCommand,
    target: string,
    body: Body,
    commandId: string,
    driverId: string | null,
  ): Promise<Outcome> {
    const kind = kindOf(operation);
    let id: string;
    let before: Body = {};
    if (operation === 'createVehicle') {
      id = (
        await client.query(
          'INSERT INTO app.vehicles(plate,label,make,colour,capacity) VALUES ($1,$2,$3,$4,$5) RETURNING id',
          [body.plate, body.label ?? null, body.make ?? null, body.colour ?? null, body.capacity],
        )
      ).rows[0].id;
    } else if (operation === 'updateVehicle') {
      id = fleetId(target);
      before = (await this.load(client, kind, [id]))[0]!;
      // Archival hides a bus from new assignment but must not strand a run it is
      // already carrying. Trip assignment locks the vehicle and cannot race past.
      if (body.archived === true) {
        const open = await client.query(
          `SELECT 1 FROM app.trips WHERE vehicle_id=$1 AND status IN ('scheduled','active') LIMIT 1`,
          [id],
        );
        if (open.rowCount)
          fail(
            409,
            'vehicle_has_open_trips',
            'Reassign scheduled and active trips before archiving this vehicle.',
          );
      }
      const columns: string[] = [],
        values: unknown[] = [id];
      const set = (column: string, value: unknown) => {
        values.push(value);
        columns.push(`${column}=$${values.length}`);
      };
      for (const field of ['plate', 'label', 'make', 'colour', 'capacity'] as const)
        if (body[field] !== undefined) set(field, body[field]);
      if (body.archived !== undefined)
        columns.push(
          body.archived
            ? 'archived_at=COALESCE(archived_at,clock_timestamp())'
            : 'archived_at=NULL',
        );
      await client.query(`UPDATE app.vehicles SET ${columns.join(',')} WHERE id=$1`, values);
    } else if (operation === 'reportIncident') {
      id = await this.reportIncident(client, body, driverId!);
    } else if (operation === 'decideIncident') {
      id = fleetId(target);
      before = (await this.load(client, kind, [id]))[0]!;
      if (before.status === 'resolved')
        fail(409, 'incident_already_resolved', 'This report has already been resolved.');
      await client.query(
        `UPDATE app.driver_incidents
        SET status=$2,resolution=$3,handled_by=$4,handled_at=clock_timestamp(),${BUMP}
        WHERE id=$1`,
        [id, body.status, trimmed(body.resolution, 'resolution', 2000), actor.userId],
      );
    } else if (operation === 'createDriverRequest') {
      id = await this.createRequest(client, body, driverId!);
    } else if (operation === 'withdrawDriverRequest') {
      id = fleetId(target);
      before = (await this.load(client, kind, [id]))[0]!;
      if (before.status !== 'pending')
        fail(409, 'request_not_pending', 'Only a pending request can be withdrawn.');
      await client.query(`UPDATE app.driver_requests SET status='withdrawn',${BUMP} WHERE id=$1`, [
        id,
      ]);
    } else {
      id = fleetId(target);
      before = (await this.load(client, kind, [id]))[0]!;
      if (before.status !== 'pending')
        fail(409, 'request_not_pending', 'This request has already been decided.');
      // Recording that ops agreed is the whole effect. Moving a driver onto a
      // route stays a separate, deliberate assignment command, so nothing here
      // touches trips.assigned_driver_id or vehicle_id.
      await client.query(
        `UPDATE app.driver_requests
        SET status=$2,decision_note=$3,decided_by=$4,decided_at=clock_timestamp(),${BUMP}
        WHERE id=$1`,
        [id, body.status, trimmed(body.decisionNote, 'decisionNote', 2000), actor.userId],
      );
    }
    const data = (await this.load(client, kind, [id]))[0]!;
    await client.query(
      `INSERT INTO app.fleet_events(actor_user_id,command_id,${subjectColumn[kind]},operation,before_state,after_state)
      VALUES ($1,$2,$3,$4,$5,$6)`,
      [actor.userId, commandId, id, operation, before, data],
    );
    const created = operation.startsWith('create') || operation === 'reportIncident';
    const headers: Record<string, string> = {
      etag: editToken(kind, { id, version: data.version }),
    };
    if (created)
      headers.location =
        kind === 'vehicle'
          ? `/v1/ops/vehicles/${id}`
          : kind === 'incident'
            ? `/v1/driver/incidents/${id}`
            : `/v1/driver/requests/${id}`;
    return { status: created ? 201 : 200, body: { data }, headers };
  }

  /**
   * A roadside or yard report. The trip is optional by design: a fault found
   * before any run starts still has to be reportable, and the vehicle is taken
   * from the trip rather than trusted from the caller.
   */
  private async reportIncident(client: PoolClient, body: Body, driverId: string) {
    let vehicleId: string | null = null;
    if (body.tripId) {
      const trip = (
        await client.query(
          'SELECT vehicle_id FROM app.trips WHERE id=$1 AND assigned_driver_id=$2 FOR SHARE',
          [body.tripId, driverId],
        )
      ).rows[0];
      if (!trip) return notFound();
      vehicleId = trip.vehicle_id;
    }
    const point = (body.location ?? null) as Body | null;
    return (
      await client.query(
        `INSERT INTO app.driver_incidents(driver_id,trip_id,vehicle_id,category,note,latitude,longitude)
        VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING id`,
        [
          driverId,
          body.tripId ?? null,
          vehicleId,
          body.category,
          trimmed(body.note, 'note', 2000),
          point ? point.latitude : null,
          point ? point.longitude : null,
        ],
      )
    ).rows[0].id;
  }

  /**
   * A driver asking ops for something. A route-change may only name a corridor
   * ops has opened to requests, so a new route collects nothing until someone
   * deliberately opens it.
   */
  private async createRequest(client: PoolClient, body: Body, driverId: string) {
    const kind = body.kind === 'leave' ? 'leave' : 'route_change';
    if (body.kind !== 'leave' && body.kind !== 'route_change')
      fail(400, 'invalid_request_kind', 'Choose a route change or leave.');
    if (kind === 'route_change') {
      const route = (
        await client.query(
          'SELECT accepts_driver_requests,archived_at FROM app.routes WHERE id=$1 FOR SHARE',
          [body.routeId],
        )
      ).rows[0];
      if (!route) return notFound();
      if (!route.accepts_driver_requests || route.archived_at)
        fail(409, 'route_not_accepting_requests', 'That corridor is not accepting requests.');
    }
    const existing = await client.query(
      "SELECT 1 FROM app.driver_requests WHERE driver_id=$1 AND status='pending' LIMIT 1",
      [driverId],
    );
    if (existing.rowCount)
      fail(409, 'request_already_open', 'Resolve your open request before sending another.');
    return (
      await client.query(
        `INSERT INTO app.driver_requests(driver_id,kind,route_id,from_date,to_date,note)
        VALUES ($1,$2,$3,$4::date,$5::date,$6) RETURNING id`,
        [
          driverId,
          kind,
          kind === 'route_change' ? body.routeId : null,
          body.fromDate ?? null,
          kind === 'leave' ? body.toDate : null,
          trimmed(body.note, 'note', 2000),
        ],
      )
    ).rows[0].id;
  }

  private async load(client: PoolClient, kind: Kind, ids: string[]): Promise<Body[]> {
    if (!ids.length) return [];
    const rows = (
      await client.query(
        `SELECT *,to_char(created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
        FROM ${tables[kind]} WHERE id=ANY($1::uuid[])`,
        [ids],
      )
    ).rows;
    // The shared Route shape requires its pattern list, so a corridor a driver
    // may ask for reads the same as one ops browses.
    const patterns =
      kind === 'route'
        ? (
            await client.query(
              'SELECT route_id,id FROM app.route_patterns WHERE route_id=ANY($1::uuid[]) ORDER BY direction,id',
              [ids],
            )
          ).rows
        : [];
    return rows.map((r) => {
      const audit = {
        createdAt: r.created_at.toISOString(),
        updatedAt: r.updated_at?.toISOString(),
        version: r.version,
      };
      if (kind === 'vehicle')
        return {
          id: r.id,
          plate: r.plate,
          label: r.label,
          make: r.make,
          colour: r.colour,
          capacity: r.capacity,
          archived: r.archived_at !== null,
          editToken: editToken(kind, r),
          ...audit,
        };
      if (kind === 'route')
        return {
          id: r.id,
          name: r.name,
          description: r.description,
          patternIds: patterns.filter((p) => p.route_id === r.id).map((p) => p.id),
          acceptsDriverRequests: r.accepts_driver_requests,
          archived: r.archived_at !== null,
          editToken: editToken(kind, r),
          ...audit,
        };
      if (kind === 'incident')
        return {
          id: r.id,
          tripId: r.trip_id,
          vehicleId: r.vehicle_id,
          category: r.category,
          note: r.note,
          location: r.latitude === null ? null : { latitude: r.latitude, longitude: r.longitude },
          status: r.status,
          resolution: r.resolution,
          driverId: r.driver_id,
          handledBy: r.handled_by,
          handledAt: r.handled_at?.toISOString() ?? null,
          editToken: editToken(kind, r),
          ...audit,
        };
      // The contract's request variants are a closed oneOf, so a leave must not
      // carry a routeId key and a route change must not carry a toDate.
      // Each variant is a closed oneOf with non-nullable dates, so an absent
      // value omits its key rather than sending null and matching neither.
      const request: Body = { kind: r.kind };
      if (r.kind === 'leave') {
        request.fromDate = iso(r.from_date);
        request.toDate = iso(r.to_date);
      } else request.routeId = r.route_id;
      if (r.from_date !== null && r.kind !== 'leave') request.fromDate = iso(r.from_date);
      if (r.note !== null) request.note = r.note;
      return {
        id: r.id,
        request,
        status: r.status,
        decisionNote: r.decision_note,
        driverId: r.driver_id,
        decidedBy: r.decided_by,
        editToken: editToken(kind, r),
        ...audit,
      };
    });
  }

  /** Paged reads. Cursors bind the caller and resource, as elsewhere. */
  async read(
    client: PoolClient,
    operation: FleetRead,
    actor: Actor,
    query: Record<string, string | undefined>,
    driverId: string | null,
  ): Promise<Outcome> {
    const limit = query.limit === undefined ? 50 : Number(query.limit);
    if (
      !Number.isInteger(limit) ||
      limit < 1 ||
      limit > 200 ||
      (query.limit !== undefined && !/^[1-9]\d*$/.test(query.limit))
    )
      fail(400, 'invalid_query', 'Invalid page size.');
    const kind: Kind =
      operation === 'listOpsVehicles'
        ? 'vehicle'
        : operation === 'listDriverAvailableRoutes'
          ? 'route'
          : operation.includes('Incident')
            ? 'incident'
            : 'request';
    const values: unknown[] = [];
    const filters: string[] = [];
    // A driver's own list is scoped in the query, before pagination.
    if (driverId !== null && kind !== 'route') {
      values.push(driverId);
      filters.push(`x.driver_id=$${values.length}`);
    }
    if (kind === 'route') filters.push('x.accepts_driver_requests AND x.archived_at IS NULL');
    if (query.status !== undefined) {
      const allowed =
        kind === 'incident'
          ? ['open', 'acknowledged', 'resolved']
          : ['pending', 'approved', 'declined', 'withdrawn'];
      if (!allowed.includes(query.status)) fail(400, 'invalid_query', 'Unknown status filter.');
      values.push(query.status);
      filters.push(`x.status=$${values.length}`);
    }
    const now = (await client.query('SELECT clock_timestamp() AS now')).rows[0].now as Date;
    // The signed context binds the normalized filters as well as the caller and
    // operation. Without the filter a cursor from one query decodes against a
    // different one and silently hides matching rows instead of being refused.
    const context = `fleet:${operation}:${actor.userId}:${query.status ?? ''}`;
    const cursor = query.cursor ? this.cursors.decode(query.cursor, context, now) : null;
    values.push(cursor?.time ?? null, cursor?.id ?? null, limit + 1);
    const rows = (
      await client.query(
        `SELECT x.id,to_char(x.created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
        FROM ${tables[kind]} x
        WHERE ${filters.length ? filters.join(' AND ') : 'true'}
          AND ($${values.length - 2}::timestamptz IS NULL
            OR (x.created_at,x.id)<($${values.length - 2}::timestamptz,$${values.length - 1}::uuid))
        ORDER BY x.created_at DESC,x.id DESC LIMIT $${values.length}`,
        values,
      )
    ).rows;
    const page = rows.slice(0, limit);
    const data = await this.load(
      client,
      kind,
      page.map((r) => r.id),
    );
    const order = new Map(page.map((r, index) => [r.id, index]));
    data.sort((a, b) => order.get(String(a.id))! - order.get(String(b.id))!);
    const last = page[page.length - 1];
    return {
      status: 200,
      body: {
        data,
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
const iso = (value: Date | string | null) =>
  value === null ? null : typeof value === 'string' ? value : value.toISOString().slice(0, 10);
