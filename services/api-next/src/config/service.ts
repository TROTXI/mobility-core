import { createHash } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { fail } from '../transport/errors.js';
import { canonical } from '../transport/service.js';
import type { Actor, Body, Outcome } from '../transport/service.js';

export const configOperations = [
  'listFlags',
  'setFlag',
  'listMinimumVersions',
  'setMinimumVersion',
  'changeRole',
] as const;
export type ConfigOperation = (typeof configOperations)[number];
/** Unauthenticated, and answered without reading anything private. */
export const publicConfigOperations = [
  'getRoot',
  'getHealth',
  'getReadiness',
  'getBuild',
  'getBootstrap',
] as const;
export type PublicConfigOperation = (typeof publicConfigOperations)[number];

export interface BuildIdentity {
  service: string;
  version: string;
  commit: string;
}
export interface MapTiles {
  url: string | null;
  styleUrl: string | null;
  darkStyleUrl: string | null;
  attribution: string;
}
export interface SupportContacts {
  phone: string | null;
  whatsapp: string | null;
  email: string | null;
  hours: string | null;
}
export interface ConfigOptions {
  pool: Pool;
  authorizeSession: (client: PoolClient, actor: Actor) => Promise<void>;
  build: BuildIdentity;
  mapTiles: MapTiles;
  support?: SupportContacts;
  /** Used only where the database has no row for an app and platform. */
  fallbackBuilds: {
    driver: { ios: number; android: number };
    commuter: { ios: number; android: number };
  };
  docsUrl?: string;
  now?: () => Date;
}

type Row = Record<string, any>;
const digest = (value: string) => createHash('sha256').update(value).digest('hex');
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const roles = ['commuter', 'driver', 'admin'];
const apps = ['commuter', 'driver'];
const platforms = ['ios', 'android'];
const flagToken = (r: Row) => `"flag:${r.key}:${r.version}"`;
const versionToken = (r: Row) => `"minversion:${r.app}:${r.platform}:${r.version}"`;
const userToken = (r: Row) => `"user:${r.id}:${r.version}"`;

/**
 * Which builds are still admitted, what clients are told at start-up, and who
 * changed a role.
 */
export class ConfigService {
  constructor(private readonly options: ConfigOptions) {
    const floors = options.fallbackBuilds;
    if (
      !floors ||
      ![
        floors.driver?.ios,
        floors.driver?.android,
        floors.commuter?.ios,
        floors.commuter?.android,
      ].every((n) => Number.isInteger(n) && n > 0)
    )
      throw new Error('Explicit fallback build floors are required');
    const tiles = options.mapTiles;
    if (!tiles || typeof tiles.attribution !== 'string' || !tiles.attribution.length)
      throw new Error('Explicit map tile configuration and attribution are required');
  }
  private now() {
    return this.options.now?.() ?? new Date();
  }
  private async tx<T>(work: (c: PoolClient) => Promise<T>): Promise<T> {
    const c = await this.options.pool.connect();
    try {
      await c.query('BEGIN');
      await c.query("SET LOCAL TIME ZONE 'UTC'");
      await c.query("SET LOCAL lock_timeout='3s'");
      await c.query("SET LOCAL statement_timeout='10s'");
      const result = await work(c);
      await c.query('COMMIT');
      return result;
    } catch (error) {
      await c.query('ROLLBACK').catch(() => undefined);
      throw error;
    } finally {
      c.release();
    }
  }
  private async authorize(c: PoolClient, actor: Actor) {
    await this.options.authorizeSession(c, actor);
    const user = (
      await c.query('SELECT role FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR SHARE', [
        actor.userId,
      ])
    ).rows[0];
    if (!user) fail(401, 'unauthenticated', 'Sign in to continue.');
    if (user.role !== 'admin') fail(403, 'forbidden', 'This operation is not permitted.');
  }

  /**
   * The floor a build must clear, from the database when ops has set one and
   * from the deployment's own configuration when it has not, so a fresh
   * database still refuses an ancient build rather than admitting everything.
   */
  async minimumBuild(app: 'commuter' | 'driver', platform: 'ios' | 'android'): Promise<number> {
    const row = await this.tx((c) =>
      c.query('SELECT min_supported_build FROM app.minimum_versions WHERE app=$1 AND platform=$2', [
        app,
        platform,
      ]),
    );
    return row.rows[0]?.min_supported_build ?? this.options.fallbackBuilds[app][platform];
  }

  /**
   * Everything a client needs before it has signed in.
   *
   * Flags are published as definitions rather than as decisions: the reviewed
   * schema carries the rollout percentage to the client, so the client decides
   * its own bucket. No reviewed operation is gated by a flag on this side, so
   * nothing here evaluates one.
   */
  async bootstrap(): Promise<Outcome> {
    const { versions, flags } = await this.tx(async (c) => ({
      versions: (await c.query('SELECT * FROM app.minimum_versions ORDER BY app,platform')).rows,
      flags: (await c.query('SELECT * FROM app.feature_flags ORDER BY key')).rows,
    }));
    const configured = new Map(versions.map((v) => [`${v.app}:${v.platform}`, v]));
    const applications = [];
    for (const app of apps)
      for (const platform of platforms) {
        const row = configured.get(`${app}:${platform}`);
        applications.push({
          app,
          platform,
          minSupportedBuild:
            row?.min_supported_build ??
            this.options.fallbackBuilds[app as 'commuter'][platform as 'ios'],
          storeUrl: row?.store_url ?? null,
          apiMajor: 1,
        });
      }
    return {
      status: 200,
      body: {
        serverTime: this.now().toISOString(),
        applications,
        operations: this.options.support ?? {
          phone: null,
          whatsapp: null,
          email: null,
          hours: null,
        },
        mapTiles: { ...this.options.mapTiles },
        flags: flags.map((f) => ({
          key: f.key,
          enabled: f.enabled,
          rolloutPercentage: Number(f.rollout_percentage),
        })),
      } as unknown as Body,
      headers: {},
    } as Outcome;
  }

  root(): Outcome {
    return {
      status: 200,
      body: { docs: this.options.docsUrl ?? '/docs', health: '/healthz' },
      headers: {},
    } as Outcome;
  }
  build(): Outcome {
    return { status: 200, body: { ...this.options.build }, headers: {} } as Outcome;
  }
  /** Liveness answers for the process alone; readiness asks the database. */
  health(): Outcome {
    return { status: 200, body: { status: 'ok' }, headers: {} } as Outcome;
  }
  async readiness(): Promise<Outcome> {
    try {
      // The runtime role cannot read the migration table by design, so
      // readiness asks what it can: a round trip, and the schema present.
      const row = await this.tx((c) =>
        c.query("SELECT to_regclass('app.users') IS NOT NULL AS ready"),
      );
      if (!row.rows[0]?.ready) throw new Error('schema_absent');
      return { status: 200, body: { status: 'ok' }, headers: {} } as Outcome;
    } catch {
      return { status: 503, body: { status: 'unavailable' }, headers: {} } as Outcome;
    }
  }

  private flagView(r: Row): Body {
    return {
      key: r.key,
      enabled: r.enabled,
      rolloutPercentage: Number(r.rollout_percentage),
      description: r.description,
      version: r.version,
    };
  }
  private versionView(r: Row): Body {
    return {
      app: r.app,
      platform: r.platform,
      minSupportedBuild: r.min_supported_build,
      apiMajor: r.api_major,
      storeUrl: r.store_url,
      version: r.version,
    };
  }

  async read(actor: Actor, operation: ConfigOperation): Promise<Outcome> {
    return this.tx(async (c) => {
      await this.authorize(c, actor);
      if (operation === 'listFlags') {
        const rows = (await c.query('SELECT * FROM app.feature_flags ORDER BY key')).rows;
        return {
          status: 200,
          body: { data: rows.map((r) => this.flagView(r)), page: { nextCursor: null } },
          headers: {},
        } as Outcome;
      }
      const rows = (await c.query('SELECT * FROM app.minimum_versions ORDER BY app,platform')).rows;
      return {
        status: 200,
        body: { data: rows.map((r) => this.versionView(r)), page: { nextCursor: null } },
        headers: {},
      } as Outcome;
    });
  }

  async command(
    actor: Actor,
    operation: ConfigOperation,
    params: { key?: string; app?: string; platform?: string; id?: string },
    input: Body,
    key: string,
    ifMatch?: string,
  ): Promise<Outcome> {
    if (typeof key !== 'string' || !key.length || key.length > 128)
      fail(400, 'idempotency_key_required', 'Supply an Idempotency-Key of 1 to 128 characters.');
    if (!ifMatch) fail(428, 'precondition_required', 'Supply the resource edit token in If-Match.');
    const target =
      operation === 'setFlag'
        ? String(params.key ?? '')
        : operation === 'setMinimumVersion'
          ? `${params.app}:${params.platform}`
          : String(params.id ?? '');
    if (!target || target.length > 200) fail(404, 'not_found', 'Resource not found.');
    const keyHash = digest(`${actor.userId}:${operation}:${target}:${key}`);
    const inputHash = digest(canonical(input));
    return this.tx(async (c) => {
      await this.authorize(c, actor);
      await c.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [`config:${keyHash}`]);
      const prior = (
        await c.query(
          'SELECT * FROM app.config_commands WHERE actor_user_id=$1 AND operation=$2 AND target=$3 AND key_hash=$4',
          [actor.userId, operation, target, keyHash],
        )
      ).rows[0];
      if (prior) {
        if (prior.input_hash !== inputHash)
          fail(409, 'idempotency_conflict', 'This key was already used for different input.');
        if (this.now().getTime() - prior.created_at.getTime() >= 7 * 86400000)
          fail(409, 'idempotency_expired', 'This replay window has expired.');
        return this.render(c, operation, target);
      }
      const change =
        operation === 'setFlag'
          ? await this.writeFlag(c, target, input, ifMatch)
          : operation === 'setMinimumVersion'
            ? await this.writeVersion(c, params, input, ifMatch)
            : await this.writeRole(c, target, input, ifMatch);
      const receipt = (
        await c.query(
          'INSERT INTO app.config_commands(actor_user_id,operation,target,key_hash,input_hash) VALUES ($1,$2,$3,$4,$5) RETURNING id',
          [actor.userId, operation, target, keyHash, inputHash],
        )
      ).rows[0].id;
      await c.query(
        'INSERT INTO app.config_events(command_id,actor_user_id,action,target,reason,before_state,after_state) VALUES ($1,$2,$3,$4,$5,$6,$7)',
        [receipt, actor.userId, operation, target, change.reason, change.before, change.after],
      );
      return this.render(c, operation, target);
    });
  }

  private async render(
    c: PoolClient,
    operation: ConfigOperation,
    target: string,
  ): Promise<Outcome> {
    if (operation === 'setFlag') {
      const row = (await c.query('SELECT * FROM app.feature_flags WHERE key=$1', [target])).rows[0];
      return {
        status: 200,
        body: { data: this.flagView(row) },
        headers: { ETag: flagToken(row) },
      } as Outcome;
    }
    if (operation === 'setMinimumVersion') {
      const [app, platform] = target.split(':');
      const row = (
        await c.query('SELECT * FROM app.minimum_versions WHERE app=$1 AND platform=$2', [
          app,
          platform,
        ])
      ).rows[0];
      return {
        status: 200,
        body: { data: this.versionView(row) },
        headers: { ETag: versionToken(row) },
      } as Outcome;
    }
    const row = (await c.query('SELECT * FROM app.users WHERE id=$1', [target])).rows[0];
    return {
      status: 200,
      body: {
        data: {
          id: row.id,
          displayName: row.display_name || 'New user',
          phone: row.phone ?? null,
          avatarUrl: null,
          role: row.role,
          createdAt: (row.created_at as Date).toISOString(),
        },
      },
      headers: { ETag: userToken(row) },
    } as Outcome;
  }

  /**
   * A caller who can read a resource must say which version they are
   * replacing. `*` is reserved for the two cases where they cannot: a resource
   * that does not exist yet, and a role change, for which the approved
   * contract offers no ops account read at all.
   */
  private precondition(supplied: string, current: string) {
    if (supplied !== current)
      fail(412, 'precondition_failed', 'The resource changed. Refresh it and try again.');
  }

  private async writeFlag(c: PoolClient, key: string, input: Body, ifMatch: string) {
    if (!/^[a-z][a-z0-9_.-]{0,199}$/.test(key)) fail(404, 'not_found', 'Resource not found.');
    const percentage = input.rolloutPercentage;
    if (typeof input.enabled !== 'boolean' || typeof input.description !== 'string')
      fail(400, 'invalid_request', 'Supply the complete flag state.');
    if (
      typeof percentage !== 'number' ||
      !Number.isFinite(percentage) ||
      percentage < 0 ||
      percentage > 100
    )
      fail(400, 'invalid_request', 'Supply a rollout percentage between 0 and 100.');
    const existing = (
      await c.query('SELECT * FROM app.feature_flags WHERE key=$1 FOR UPDATE', [key])
    ).rows[0];
    // A flag that does not exist yet is created by setting it, so `*` is the
    // honest precondition for "I am not replacing a value I have read".
    if (existing) this.precondition(ifMatch, flagToken(existing));
    else if (ifMatch !== '*') fail(412, 'precondition_failed', 'This flag does not exist yet.');
    const row = (
      await c.query(
        `INSERT INTO app.feature_flags(key,enabled,rollout_percentage,description)
        VALUES ($1,$2,$3,$4)
        ON CONFLICT (key) DO UPDATE SET enabled=EXCLUDED.enabled,
          rollout_percentage=EXCLUDED.rollout_percentage,description=EXCLUDED.description
        RETURNING *`,
        [key, input.enabled, percentage, input.description],
      )
    ).rows[0];
    return {
      reason: null,
      before: existing ? this.flagView(existing) : {},
      after: this.flagView(row),
    };
  }

  private async writeVersion(
    c: PoolClient,
    params: { app?: string; platform?: string },
    input: Body,
    ifMatch: string,
  ) {
    const app = String(params.app),
      platform = String(params.platform);
    if (!apps.includes(app) || !platforms.includes(platform))
      fail(404, 'not_found', 'Resource not found.');
    const build = input.minSupportedBuild;
    const storeUrl = String(input.storeUrl ?? '');
    if (!Number.isSafeInteger(build) || (build as number) < 1 || (build as number) > 999999999)
      fail(400, 'invalid_request', 'Supply a whole supported build number.');
    if (input.apiMajor !== 1) fail(400, 'invalid_request', 'Only API major 1 is supported.');
    if (!/^https:\/\/\S{1,470}$/.test(storeUrl))
      fail(400, 'invalid_request', 'Supply the store URL for this application.');
    const existing = (
      await c.query('SELECT * FROM app.minimum_versions WHERE app=$1 AND platform=$2 FOR UPDATE', [
        app,
        platform,
      ])
    ).rows[0];
    if (existing) this.precondition(ifMatch, versionToken(existing));
    else if (ifMatch !== '*')
      fail(412, 'precondition_failed', 'This application floor does not exist yet.');
    const row = (
      await c.query(
        `INSERT INTO app.minimum_versions(app,platform,min_supported_build,api_major,store_url)
        VALUES ($1,$2,$3,1,$4)
        ON CONFLICT (app,platform) DO UPDATE SET min_supported_build=EXCLUDED.min_supported_build,
          api_major=EXCLUDED.api_major,store_url=EXCLUDED.store_url
        RETURNING *`,
        [app, platform, build, storeUrl],
      )
    ).rows[0];
    return {
      reason: null,
      before: existing ? this.versionView(existing) : {},
      after: this.versionView(row),
    };
  }

  private async writeRole(c: PoolClient, id: string, input: Body, ifMatch: string) {
    if (!uuid.test(id)) fail(404, 'not_found', 'Resource not found.');
    const role = String(input.role);
    const reason = typeof input.reason === 'string' ? input.reason.trim() : '';
    if (!roles.includes(role)) fail(400, 'invalid_request', 'Supply a supported role.');
    if (!reason.length || reason.length > 2000)
      fail(400, 'invalid_request', 'Supply a reason for this change.');
    const user = (
      await c.query('SELECT * FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR UPDATE', [id])
    ).rows[0];
    if (!user) fail(404, 'not_found', 'Resource not found.');
    // The one wildcard the service accepts, and only because nothing in the
    // approved contract lets ops read an account to learn its token first.
    if (ifMatch !== '*') this.precondition(ifMatch, userToken(user));
    const before = { id: user.id, role: user.role };
    if (user.role !== role) await c.query('UPDATE app.users SET role=$2 WHERE id=$1', [id, role]);
    return { reason, before, after: { id: user.id, role } };
  }
}
