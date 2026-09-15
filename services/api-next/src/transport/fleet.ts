import type { PoolClient, QueryResultRow } from 'pg';
import type { Actor, Body, Outcome } from './service.js';
import { cursorCodec } from './cursor.js';
import { fail } from './errors.js';

export const fleetCommands = ['createVehicle', 'updateVehicle'] as const;
export type FleetCommand = (typeof fleetCommands)[number];
export const fleetReads = ['listOpsVehicles'] as const;
export type FleetRead = (typeof fleetReads)[number];

type Kind = 'vehicle';
// Only this constant map selects SQL identifiers; no request string becomes SQL.
const tables = { vehicle: 'app.vehicles' } as const;
const editToken = (kind: Kind, row: QueryResultRow) => `"${kind}:${row.id}:${row.version}"`;
const notFound = () => fail(404, 'not_found', 'Resource not found.');
// Trimmed and upper-cased so "gt 1234-20" and "GT 1234-20" cannot both occupy
// the operating fleet. Internal spacing is collapsed rather than removed:
// plates are read aloud and written down, and spacing is not the identifier.
const normalizePlate = (value: string) => value.trim().replace(/\s+/g, ' ').toUpperCase();

export function fleetId(value: unknown): string {
  if (
    typeof value !== 'string' ||
    !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)
  )
    return notFound();
  return value.toLowerCase();
}

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
    return body;
  }

  async lock(client: PoolClient, operation: FleetCommand, target: string): Promise<FleetLocked> {
    if (operation === 'createVehicle') return { row: null };
    const row = (
      await client.query(`SELECT * FROM ${tables.vehicle} WHERE id=$1 FOR UPDATE`, [
        fleetId(target),
      ])
    ).rows[0];
    if (!row) return notFound();
    return { row };
  }

  precondition(operation: FleetCommand, locked: FleetLocked, ifMatch?: string) {
    if (operation !== 'updateVehicle') return;
    if (!ifMatch) fail(428, 'precondition_required', 'Supply the resource edit token in If-Match.');
    if (ifMatch !== editToken('vehicle', locked.row!))
      fail(412, 'precondition_failed', 'The resource changed. Refresh it and try again.');
  }

  async execute(
    client: PoolClient,
    actor: Actor,
    operation: FleetCommand,
    target: string,
    body: Body,
    commandId: string,
  ): Promise<Outcome> {
    let id: string;
    let before: Body = {};
    if (operation === 'createVehicle') {
      id = (
        await client.query(
          'INSERT INTO app.vehicles(plate,label,make,colour,capacity) VALUES ($1,$2,$3,$4,$5) RETURNING id',
          [body.plate, body.label ?? null, body.make ?? null, body.colour ?? null, body.capacity],
        )
      ).rows[0].id;
    } else {
      id = fleetId(target);
      before = (await this.load(client, [id]))[0]!;
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
      for (const field of [
        ['plate', 'plate'],
        ['label', 'label'],
        ['make', 'make'],
        ['colour', 'colour'],
        ['capacity', 'capacity'],
      ] as const)
        if (body[field[0]] !== undefined) set(field[1], body[field[0]]);
      if (body.archived !== undefined)
        columns.push(
          body.archived
            ? 'archived_at=COALESCE(archived_at,clock_timestamp())'
            : 'archived_at=NULL',
        );
      await client.query(`UPDATE app.vehicles SET ${columns.join(',')} WHERE id=$1`, values);
    }
    const data = (await this.load(client, [id]))[0]!;
    await client.query(
      `INSERT INTO app.fleet_events(actor_user_id,command_id,vehicle_id,operation,before_state,after_state)
      VALUES ($1,$2,$3,$4,$5,$6)`,
      [actor.userId, commandId, id, operation, before, data],
    );
    const created = operation === 'createVehicle';
    const headers: Record<string, string> = {
      etag: editToken('vehicle', { id, version: data.version }),
    };
    if (created) headers.location = `/v1/ops/vehicles/${id}`;
    return { status: created ? 201 : 200, body: { data }, headers };
  }

  private async load(client: PoolClient, ids: string[]): Promise<Body[]> {
    if (!ids.length) return [];
    const rows = (
      await client.query(
        `SELECT *,to_char(created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
        FROM app.vehicles WHERE id=ANY($1::uuid[])`,
        [ids],
      )
    ).rows;
    return rows.map((r) => ({
      id: r.id,
      plate: r.plate,
      label: r.label,
      make: r.make,
      colour: r.colour,
      capacity: r.capacity,
      archived: r.archived_at !== null,
      editToken: editToken('vehicle', r),
      createdAt: r.created_at.toISOString(),
      updatedAt: r.updated_at.toISOString(),
      version: r.version,
    }));
  }

  /** Ops fleet page. Cursors bind the caller and resource, as elsewhere. */
  async read(
    client: PoolClient,
    operation: FleetRead,
    actor: Actor,
    query: Record<string, string | undefined>,
  ): Promise<Outcome> {
    if (operation !== 'listOpsVehicles') return notFound();
    const limit = query.limit === undefined ? 50 : Number(query.limit);
    if (
      !Number.isInteger(limit) ||
      limit < 1 ||
      limit > 200 ||
      (query.limit !== undefined && !/^[1-9]\d*$/.test(query.limit))
    )
      fail(400, 'invalid_query', 'Invalid page size.');
    const now = (await client.query('SELECT clock_timestamp() AS now')).rows[0].now as Date;
    const context = `fleet:vehicles:${actor.userId}`;
    const cursor = query.cursor ? this.cursors.decode(query.cursor, context, now) : null;
    const rows = (
      await client.query(
        `SELECT id,to_char(created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
        FROM app.vehicles
        WHERE ($1::timestamptz IS NULL OR (created_at,id)<($1::timestamptz,$2::uuid))
        ORDER BY created_at DESC,id DESC LIMIT $3`,
        [cursor?.time ?? null, cursor?.id ?? null, limit + 1],
      )
    ).rows;
    const page = rows.slice(0, limit);
    const data = await this.load(
      client,
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
