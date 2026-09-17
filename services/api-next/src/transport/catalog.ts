import type { PoolClient, QueryResultRow } from 'pg';
import type { Actor, Body, Outcome } from './service.js';
import { cursorCodec } from './cursor.js';
import { fail } from './errors.js';

export const catalogCommands = [
  'createRoute',
  'updateRoute',
  'createStop',
  'updateStop',
  'createPattern',
  'createPatternVersion',
  'publishPatternVersion',
] as const;
export type CatalogCommand = (typeof catalogCommands)[number];
export const publicCatalogReads = [
  'listRoutes',
  'getRoute',
  'getPattern',
  'getPatternVersion',
  'getGeometry',
  'listRouteSchedules',
] as const;
export const catalogReads = [
  ...publicCatalogReads,
  'listOpsRoutes',
  'listOpsStops',
  'listPatterns',
  'listPatternVersions',
  'getOpsPatternVersion',
] as const;
export type CatalogRead = (typeof catalogReads)[number];
type Kind = 'route' | 'stop' | 'pattern' | 'version' | 'geometry' | 'schedule';
// Only this constant map selects SQL identifiers; no request string becomes SQL.
const tables = {
  route: 'app.routes',
  stop: 'app.stops',
  pattern: 'app.route_patterns',
  version: 'app.route_pattern_versions',
  geometry: 'app.route_geometries',
  schedule: 'app.service_schedules',
} as const;
const activeVersion = (alias: string) => `${alias}.state <> 'draft'
  AND ${alias}.effective_from <= transaction_timestamp()
  AND (${alias}.effective_to IS NULL OR ${alias}.effective_to > transaction_timestamp())`;
const currentRoute = (
  alias: 'r' | 'x',
) => `${alias}.archived_at IS NULL AND EXISTS (SELECT 1 FROM app.route_patterns p
  JOIN app.route_pattern_versions v ON v.pattern_id=p.id WHERE p.route_id=${alias}.id AND ${activeVersion('v')})`;
const iso = (date: Date | null) => date?.toISOString() ?? null;
const editToken = (kind: Kind, row: QueryResultRow) => `"${kind}:${row.id}:${row.version}"`;
const notFound = () => fail(404, 'not_found', 'Resource not found.');
export function catalogId(value: unknown): string {
  if (
    typeof value !== 'string' ||
    !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)
  )
    return notFound();
  return value.toLowerCase();
}
interface Locked {
  row: QueryResultRow | null;
  versions?: QueryResultRow[];
}

export class Catalog {
  private readonly cursors;
  constructor(secret: Buffer) {
    this.cursors = cursorCodec(secret);
  }

  normalize(operation: CatalogCommand, input: Body): Body {
    const body = structuredClone(input);
    if (body.name !== undefined && !String(body.name).trim())
      fail(400, 'invalid_name', 'A non-blank name is required.');
    if (operation === 'updateRoute' || operation === 'updateStop')
      if (!Object.keys(body).length) fail(400, 'empty_edit', 'Supply at least one field to edit.');
    if (operation === 'createPattern') body.routeId = catalogId(body.routeId);
    if (operation === 'createPatternVersion') {
      const stops = body.stops as Body[];
      for (const stop of stops) {
        stop.stopId = catalogId(stop.stopId);
        if (!String(stop.name).trim())
          fail(400, 'invalid_name', 'A non-blank stop name is required.');
      }
      const geometry = body.geometry as Body;
      const distances = geometry.stopDistancesMeters as number[];
      if (
        distances.length !== stops.length ||
        distances.some((d, i) => i > 0 && d < distances[i - 1]!)
      )
        fail(400, 'invalid_stop_distances', 'Supply one ordered distance per stop occurrence.');
    }
    return body;
  }

  async lock(
    client: PoolClient,
    operation: CatalogCommand,
    target: string,
    child?: string,
  ): Promise<Locked> {
    if (['createRoute', 'createStop', 'createPattern'].includes(operation)) return { row: null };
    const kind =
      operation === 'updateRoute' ? 'route' : operation === 'updateStop' ? 'stop' : 'pattern';
    const parent = (
      await client.query(`SELECT * FROM ${tables[kind]} WHERE id=$1 FOR UPDATE`, [
        catalogId(target),
      ])
    ).rows[0];
    if (!parent) return notFound();
    if (operation !== 'publishPatternVersion') return { row: parent };
    // Serialize publication/revision numbering per pattern, then lock versions
    // before the route: trip/schedule guards already use version -> route.
    const versions = (
      await client.query(
        `SELECT * FROM app.route_pattern_versions WHERE pattern_id=$1 AND
          (id=$2 OR id=(SELECT id FROM app.route_pattern_versions WHERE pattern_id=$1 AND state<>'draft'
            ORDER BY effective_from DESC LIMIT 1)) ORDER BY id FOR UPDATE`,
        [target, catalogId(child)],
      )
    ).rows;
    const row = versions.find((v) => v.id === catalogId(child));
    if (!row) return notFound(); // Parent/child ownership before replay or If-Match.
    return { row, versions };
  }

  precondition(operation: CatalogCommand, locked: Locked, ifMatch?: string) {
    if (!['updateRoute', 'updateStop', 'publishPatternVersion'].includes(operation)) return;
    if (!ifMatch) fail(428, 'precondition_required', 'Supply the resource edit token in If-Match.');
    const kind =
      operation === 'updateRoute' ? 'route' : operation === 'updateStop' ? 'stop' : 'version';
    if (ifMatch !== editToken(kind, locked.row!))
      fail(412, 'precondition_failed', 'The resource changed. Refresh it and try again.');
  }

  private async availableRoute(client: PoolClient, id: string) {
    const row = (
      await client.query('SELECT archived_at FROM app.routes WHERE id=$1 FOR SHARE', [id])
    ).rows[0];
    if (!row) return notFound();
    if (row.archived_at) fail(409, 'archived_route', 'The corridor is archived.');
  }

  async execute(
    client: PoolClient,
    actor: Actor,
    operation: CatalogCommand,
    target: string,
    body: Body,
    commandId: string,
    locked: Locked,
  ): Promise<Outcome> {
    let kind: Kind, id: string;
    let before: Body = {},
      extraAfter: Body = {};
    if (operation === 'createRoute') {
      kind = 'route';
      id = (
        await client.query(
          'INSERT INTO app.routes(name,description,accepts_driver_requests) VALUES ($1,$2,$3) RETURNING id',
          [body.name, body.description ?? null, body.acceptsDriverRequests ?? false],
        )
      ).rows[0].id;
    } else if (operation === 'createStop') {
      kind = 'stop';
      const point = body.location as Body;
      id = (
        await client.query(
          'INSERT INTO app.stops(name,latitude,longitude) VALUES ($1,$2,$3) RETURNING id',
          [body.name, point.latitude, point.longitude],
        )
      ).rows[0].id;
    } else if (operation === 'updateRoute' || operation === 'updateStop') {
      kind = operation === 'updateRoute' ? 'route' : 'stop';
      id = target;
      before = (await this.load(client, kind, [id], false))[0]!;
      // Archival may hide a corridor, but must not strand a scheduled/active run.
      // Creating/starting trips takes a SHARE route lock and cannot race past this.
      if (kind === 'route' && body.archived === true) {
        const trips = await client.query(
          `SELECT 1 FROM app.trips t JOIN app.route_pattern_versions v ON v.id=t.pattern_version_id
          JOIN app.route_patterns p ON p.id=v.pattern_id WHERE p.route_id=$1 AND t.status IN ('scheduled','active') LIMIT 1`,
          [id],
        );
        if (trips.rowCount)
          fail(
            409,
            'route_has_open_trips',
            'Resolve scheduled and active trips before archiving this corridor.',
          );
      }
      const columns: string[] = [],
        values: unknown[] = [id];
      const set = (column: string, value: unknown) => {
        values.push(value);
        columns.push(`${column}=$${values.length}`);
      };
      if (body.name !== undefined) set('name', body.name);
      if (kind === 'route') {
        if (body.description !== undefined) set('description', body.description);
        if (body.acceptsDriverRequests !== undefined)
          set('accepts_driver_requests', body.acceptsDriverRequests);
      } else if (body.location !== undefined) {
        set('latitude', (body.location as Body).latitude);
        set('longitude', (body.location as Body).longitude);
      }
      if (body.archived !== undefined)
        columns.push(
          body.archived
            ? 'archived_at=COALESCE(archived_at,clock_timestamp())'
            : 'archived_at=NULL',
        );
      await client.query(`UPDATE ${tables[kind]} SET ${columns.join(',')} WHERE id=$1`, values);
    } else if (operation === 'createPattern') {
      kind = 'pattern';
      await this.availableRoute(client, String(body.routeId));
      id = (
        await client.query(
          'INSERT INTO app.route_patterns(route_id,direction) VALUES ($1,$2) RETURNING id',
          [body.routeId, body.direction],
        )
      ).rows[0].id;
    } else if (operation === 'createPatternVersion') {
      kind = 'version';
      await this.availableRoute(client, locked.row!.route_id);
      const stops = body.stops as Body[];
      await this.availableStops(
        client,
        stops.map((s) => String(s.stopId)),
      );
      id = (
        await client.query(
          `INSERT INTO app.route_pattern_versions(pattern_id,revision)
        SELECT $1,COALESCE(max(revision),0)+1 FROM app.route_pattern_versions WHERE pattern_id=$1 RETURNING id`,
          [target],
        )
      ).rows[0].id;
      const occurrences: string[] = [];
      for (const [ordinal, stop] of stops.entries()) {
        const point = stop.location as Body;
        occurrences.push(
          (
            await client.query(
              `INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude)
          VALUES ($1,$2,$3,$4,$5,$6) RETURNING id`,
              [id, stop.stopId, ordinal, stop.name, point.latitude, point.longitude],
            )
          ).rows[0].id,
        );
      }
      const geometry = body.geometry as Body;
      const coordinates = (geometry.points as Body[]).map((p) => [p.longitude, p.latitude]);
      const geom = (
        await client.query(
          `WITH candidate AS (SELECT ST_SetSRID(ST_GeomFromGeoJSON($2),4326) AS line)
          INSERT INTO app.route_geometries(pattern_version_id,source,line)
          SELECT $1,'configured',line FROM candidate WHERE ST_IsValid(line) AND ST_Length(line::geography)>0
          RETURNING id,ST_Length(line::geography) AS length`,
          [id, JSON.stringify({ type: 'LineString', coordinates })],
        )
      ).rows[0];
      if (!geom) fail(400, 'invalid_geometry', 'Supply a non-empty valid configured path.');
      const distances = geometry.stopDistancesMeters as number[];
      if (geom.length <= 0 || distances.some((d) => d > Number(geom.length) + 1))
        fail(400, 'invalid_stop_distances', 'Distances must fit a non-empty configured path.');
      await client.query(
        `INSERT INTO app.geometry_stop_distances(geometry_id,pattern_version_id,stop_occurrence_id,distance_meters)
        SELECT $1,$2,x.id,x.distance FROM unnest($3::uuid[],$4::float8[]) AS x(id,distance)`,
        [geom.id, id, occurrences, distances],
      );
      await client.query('UPDATE app.route_pattern_versions SET geometry_id=$2 WHERE id=$1', [
        id,
        geom.id,
      ]);
    } else {
      kind = 'version';
      id = locked.row!.id;
      const row = locked.row!;
      before = (await this.load(client, kind, [id], false))[0]!;
      if (row.state !== 'draft')
        fail(409, 'already_published', 'Create a new draft to change a published definition.');
      const pattern = (
        await client.query('SELECT route_id FROM app.route_patterns WHERE id=$1', [target])
      ).rows[0];
      await this.availableRoute(client, pattern.route_id);
      const stopIds = (
        await client.query(
          'SELECT stop_id FROM app.route_pattern_stops WHERE pattern_version_id=$1',
          [id],
        )
      ).rows.map((s) => s.stop_id);
      await this.availableStops(client, stopIds);
      const from = new Date(String(body.effectiveFrom));
      const published = locked.versions!.filter((v) => v.state !== 'draft');
      if (published.some((v) => v.effective_from >= from))
        fail(
          409,
          'publication_order_conflict',
          'Publish after existing revisions; do not rewrite their effective start.',
        );
      const previous = published.find((v) => v.effective_to === null || v.effective_to > from);
      if (previous) {
        before = { ...before, previousVersion: this.interval(previous) };
        // Deferred constraints refuse closure if ANY non-cancelled trip would
        // fall outside its version. No implicit reassignment or reservation edit.
        const retired = (
          await client.query(
            "UPDATE app.route_pattern_versions SET state='retired',effective_to=$2 WHERE id=$1 RETURNING *",
            [previous.id, from],
          )
        ).rows[0];
        extraAfter = { previousVersion: this.interval(retired) };
      }
      await client.query(
        "UPDATE app.route_geometries SET state='published' WHERE id=$1 AND state='draft'",
        [row.geometry_id],
      );
      await client.query(
        "UPDATE app.route_pattern_versions SET state='published',effective_from=$2 WHERE id=$1",
        [id, from],
      );
    }
    const data = (await this.load(client, kind, [id], false))[0]!;
    const column = {
      route: 'route_id',
      stop: 'stop_id',
      pattern: 'pattern_id',
      version: 'pattern_version_id',
    }[kind as 'route' | 'stop' | 'pattern' | 'version'];
    await client.query(
      `INSERT INTO app.catalog_events(actor_user_id,command_id,${column},operation,before_state,after_state,reason)
      VALUES ($1,$2,$3,$4,$5,$6,$7)`,
      [
        actor.userId,
        commandId,
        id,
        operation,
        before,
        { ...data, ...extraAfter },
        body.reason ?? null,
      ],
    );
    const created = operation.startsWith('create');
    const headers: Record<string, string> = {
      etag: editToken(kind, { id, version: data.version }),
    };
    if (created)
      headers.location =
        kind === 'version'
          ? `/v1/ops/route-patterns/${target}/versions/${id}`
          : `/v1/ops/${kind === 'pattern' ? 'route-patterns' : kind + 's'}/${id}`;
    return { status: created ? 201 : 200, body: { data }, headers };
  }

  private interval(row: QueryResultRow): Body {
    return {
      id: row.id,
      state: row.state,
      effectiveFrom: iso(row.effective_from),
      effectiveTo: iso(row.effective_to),
      version: row.version,
    };
  }
  private async availableStops(client: PoolClient, ids: string[]) {
    const unique = [...new Set(ids)].sort();
    const stops = (
      await client.query(
        'SELECT id,archived_at FROM app.stops WHERE id=ANY($1::uuid[]) ORDER BY id FOR SHARE',
        [unique],
      )
    ).rows;
    if (stops.length !== unique.length || stops.some((s) => s.archived_at))
      fail(409, 'unavailable_stop', 'Every occurrence must reference an available physical stop.');
  }

  // Page IDs are chosen first; each resource family then loads one bounded page
  // and one bulk occurrence query, never a per-resource stop fetch.
  private async load(
    client: PoolClient,
    kind: Kind,
    ids: string[],
    publicRead: boolean,
  ): Promise<Body[]> {
    if (!ids.length) return [];
    const rows = (
      await client.query(
        `SELECT *,${kind === 'schedule' ? 'effective_from::text,effective_to::text,' : ''}
      to_char(created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time FROM ${tables[kind]} WHERE id=ANY($1::uuid[])`,
        [ids],
      )
    ).rows;
    const related =
      kind === 'route'
        ? (
            await client.query(
              `SELECT p.route_id,p.id FROM app.route_patterns p WHERE p.route_id=ANY($1::uuid[])
      ${publicRead ? `AND EXISTS (SELECT 1 FROM app.route_pattern_versions v WHERE v.pattern_id=p.id AND ${activeVersion('v')})` : ''} ORDER BY p.direction,p.id`,
              [ids],
            )
          ).rows
        : kind === 'pattern'
          ? (
              await client.query(
                `SELECT pattern_id,id FROM app.route_pattern_versions v WHERE pattern_id=ANY($1::uuid[]) AND ${activeVersion('v')}`,
                [ids],
              )
            ).rows
          : kind === 'version'
            ? (
                await client.query(
                  'SELECT * FROM app.route_pattern_stops WHERE pattern_version_id=ANY($1::uuid[]) ORDER BY ordinal',
                  [ids],
                )
              ).rows
            : [];
    const mapped = rows.map((r): Body => {
      const audit = {
        createdAt: r.created_at.toISOString(),
        updatedAt: r.updated_at?.toISOString(),
        version: r.version,
      };
      const base = { id: r.id, ...audit };
      if (kind === 'route')
        return {
          ...base,
          name: r.name,
          description: r.description,
          acceptsDriverRequests: r.accepts_driver_requests,
          archived: r.archived_at !== null,
          patternIds: related.filter((p) => p.route_id === r.id).map((p) => p.id),
          editToken: editToken(kind, r),
        };
      if (kind === 'stop')
        return {
          ...base,
          name: r.name,
          location: { latitude: r.latitude, longitude: r.longitude },
          archived: r.archived_at !== null,
          editToken: editToken(kind, r),
        };
      if (kind === 'pattern')
        return {
          ...base,
          routeId: r.route_id,
          direction: r.direction,
          publishedVersionId: related.find((v) => v.pattern_id === r.id)?.id ?? null,
        };
      if (kind === 'version')
        return {
          ...base,
          ...this.interval(r),
          patternId: r.pattern_id,
          revision: r.revision,
          geometryId: r.geometry_id,
          editToken: editToken(kind, r),
          stops: related
            .filter((s) => s.pattern_version_id === r.id)
            .map((s) => ({
              id: s.id,
              stopId: s.stop_id,
              ordinal: s.ordinal,
              name: s.name,
              location: { latitude: s.latitude, longitude: s.longitude },
            })),
        };
      return {
        ...base,
        departureId: r.departure_id,
        patternId: r.pattern_id,
        patternVersionId: r.pattern_version_id,
        serviceWindow: r.service_window,
        localDeparture: String(r.local_departure).slice(0, 5),
        timeZone: r.time_zone,
        weekdays: r.weekdays,
        effectiveFrom: r.effective_from,
        effectiveTo: r.effective_to,
      };
    });
    return ids.map((id) => mapped.find((r) => r.id === id)!);
  }

  async read(
    client: PoolClient,
    operation: CatalogRead,
    actor: Actor | null,
    params: { id?: string; versionId?: string },
    query: Record<string, string | undefined>,
  ): Promise<Outcome> {
    const publicRead = (publicCatalogReads as readonly string[]).includes(operation);
    const target = params.id === undefined ? null : catalogId(params.id);
    const child = params.versionId === undefined ? null : catalogId(params.versionId);
    let kind: Kind,
      where = 'true',
      values: unknown[] = [];
    if (operation === 'getGeometry') {
      const g = (
        await client.query(
          `SELECT g.*,ST_AsGeoJSON(g.line)::json AS geo FROM app.route_geometries g
        JOIN app.route_pattern_versions v ON v.id=g.pattern_version_id JOIN app.route_patterns p ON p.id=v.pattern_id
        JOIN app.routes r ON r.id=p.route_id WHERE g.id=$1 AND g.state='published' AND v.state<>'draft' AND r.archived_at IS NULL`,
          [target],
        )
      ).rows[0];
      if (!g) return notFound();
      const distances = (
        await client.query(
          `SELECT d.stop_occurrence_id AS "stopOccurrenceId",d.distance_meters AS "distanceMeters"
        FROM app.geometry_stop_distances d JOIN app.route_pattern_stops s ON s.id=d.stop_occurrence_id WHERE geometry_id=$1 ORDER BY s.ordinal`,
          [target],
        )
      ).rows;
      return {
        status: 200,
        headers: { etag: `"geometry:${g.id}"` },
        body: {
          data: {
            id: g.id,
            patternVersionId: g.pattern_version_id,
            source: g.source,
            createdAt: g.created_at.toISOString(),
            points: g.geo.coordinates.map(([longitude, latitude]: number[]) => ({
              latitude,
              longitude,
            })),
            stopDistances: distances,
          },
        },
      };
    }
    if (['listRoutes', 'getRoute', 'listOpsRoutes'].includes(operation)) {
      kind = 'route';
      where = publicRead ? currentRoute('x') : 'true';
    } else if (operation === 'listOpsStops') kind = 'stop';
    else if (operation === 'listPatterns' || operation === 'getPattern') {
      kind = 'pattern';
      // A schedule/trip can name a published future or retired pattern absent
      // from Route.patternIds (the current-time projection). Its explicit
      // owner remains readable; draft-only and archived corridors stay hidden.
      if (publicRead)
        where = `EXISTS (SELECT 1 FROM app.routes r WHERE r.id=x.route_id AND r.archived_at IS NULL)
        AND EXISTS (SELECT 1 FROM app.route_pattern_versions v WHERE v.pattern_id=x.id AND v.state<>'draft')`;
    } else if (operation === 'listRouteSchedules') {
      kind = 'schedule';
      if (
        !(
          await client.query(`SELECT 1 FROM app.routes r WHERE r.id=$1 AND ${currentRoute('r')}`, [
            target,
          ])
        ).rowCount
      )
        return notFound();
      if (query.routeId !== undefined && catalogId(query.routeId) !== target)
        fail(400, 'invalid_filter', 'Route filter must match the requested corridor.');
      values = [target];
      where = `EXISTS (SELECT 1 FROM app.route_pattern_versions v JOIN app.route_patterns p ON p.id=v.pattern_id
        WHERE v.id=x.pattern_version_id AND p.route_id=$1 AND v.state<>'draft'
        AND (v.effective_to IS NULL OR v.effective_to>transaction_timestamp()))
        AND (x.effective_to IS NULL OR x.effective_to>=CURRENT_DATE)`;
    } else {
      kind = 'version';
      values = [target];
      where = 'x.pattern_id=$1';
      if (!(await client.query('SELECT 1 FROM app.route_patterns WHERE id=$1', [target])).rowCount)
        return notFound();
      if (publicRead)
        where += ` AND x.state<>'draft' AND EXISTS (SELECT 1 FROM app.route_patterns p JOIN app.routes r ON r.id=p.route_id WHERE p.id=x.pattern_id AND r.archived_at IS NULL)`;
    }
    const list = operation.startsWith('list');
    if (!list) {
      values.push(kind === 'version' ? child : target);
      const result = (
        await client.query(
          `SELECT x.id FROM ${tables[kind]} x WHERE ${where} AND x.id=$${values.length}`,
          values,
        )
      ).rows[0];
      if (!result) return notFound();
      const data = (await this.load(client, kind, [result.id], publicRead))[0]!;
      // Pattern/route projections contain time-dependent links: never advertise
      // shared caching based solely on their parent row's version.
      return {
        status: 200,
        body: { data },
        headers: {
          etag: String(data.editToken ?? editToken(kind, { id: data.id, version: data.version })),
        },
      };
    }
    const limit = query.limit === undefined ? 50 : Number(query.limit);
    if (!Number.isInteger(limit) || limit < 1 || limit > 200)
      fail(400, 'invalid_limit', 'Page size must be between 1 and 200.');
    const now = new Date();
    const context = JSON.stringify([actor?.userId ?? 'public', operation, target, limit]);
    const cursor = query.cursor ? this.cursors.decode(query.cursor, context, now) : null;
    if (cursor) {
      values.push(cursor.time, cursor.id);
      where += ` AND (x.created_at,x.id)<($${values.length - 1}::timestamptz,$${values.length}::uuid)`;
    }
    values.push(limit + 1);
    const rows = (
      await client.query(
        `SELECT x.id,to_char(x.created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS time
      FROM ${tables[kind]} x WHERE ${where} ORDER BY x.created_at DESC,x.id DESC LIMIT $${values.length}`,
        values,
      )
    ).rows;
    const page = rows.slice(0, limit),
      last = page.at(-1);
    return {
      status: 200,
      body: {
        data: await this.load(
          client,
          kind,
          page.map((r) => r.id),
          publicRead,
        ),
        page: {
          nextCursor:
            rows.length > limit && last
              ? this.cursors.encode(last.time, last.id, context, now)
              : null,
        },
      },
      headers: {},
    };
  }
}
