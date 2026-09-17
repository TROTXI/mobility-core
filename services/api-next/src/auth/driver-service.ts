import { randomUUID } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { canonical } from '../transport/service.js';
import type { Actor, Body } from '../transport/service.js';
import { catalogId } from '../transport/catalog.js';
import { cursorCodec } from '../transport/cursor.js';
import { fail, mapDatabaseError, TransportError } from '../transport/errors.js';
import { AuthService, DriverLockedError } from './service.js';
import { credentialReplay } from './secret-replay.js';
import { hashToken } from './credentials.js';
import {
  generateDriverCode,
  generatePin,
  hashDriverPin,
  isTrivialPin,
  normalizeDriverCode,
  verifyDriverPin,
} from './driver-pin.js';

export const driverOperations = [
  'getDriverSelf',
  'listOpsDrivers',
  'createDriver',
  'updateDriver',
  'issueDriverCredential',
  'resetDriverPin',
  'changeCredentialState',
  'changeDriverPin',
] as const;
export type DriverOperation = (typeof driverOperations)[number];
type Row = {
  id: string;
  user_id: string | null;
  name: string;
  phone: string | null;
  license_number: string | null;
  archived_at: Date | null;
  version: number;
  created_at: Date;
  updated_at: Date;
};
type Output = { status: number; body: unknown; headers: Record<string, string> };
export interface DriverOptions {
  pool: Pool;
  auth: AuthService;
  pinSecret: string;
  replayKey: Buffer;
  cursorSecret: Buffer;
}
const secretOperation = (op: string) => op === 'issueDriverCredential' || op === 'resetDriverPin';
const editToken = (row: Row) => `"driver:${row.id}:${row.version}"`;
function view(row: Row) {
  return {
    id: row.id,
    userId: row.user_id,
    name: row.name,
    phone: row.phone,
    licenseNumber: row.license_number,
    archived: row.archived_at !== null,
    version: row.version,
    editToken: editToken(row),
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
  };
}
const success = (status = 204, body?: unknown, headers: Record<string, string> = {}): Output => ({
  status,
  body,
  headers,
});

export class DriverService {
  private readonly replay;
  private readonly cursor;
  constructor(private readonly options: DriverOptions) {
    this.replay = credentialReplay(options.replayKey);
    this.cursor = cursorCodec(options.cursorSecret);
    if (Buffer.byteLength(options.pinSecret) < 32)
      throw new Error('Explicit PIN signing secret required');
  }
  private async transaction<T>(work: (client: PoolClient) => Promise<T>): Promise<T> {
    const client = await this.options.pool.connect();
    try {
      await client.query('BEGIN');
      await client.query("SET LOCAL TIME ZONE 'UTC'");
      await client.query("SET LOCAL lock_timeout='3s'");
      await client.query("SET LOCAL statement_timeout='10s'");
      const result = await work(client);
      await client.query('COMMIT');
      return result;
    } catch (error) {
      await client.query('ROLLBACK');
      throw mapDatabaseError(error);
    } finally {
      client.release();
    }
  }
  private async authorize(client: PoolClient, actor: Actor, self: boolean) {
    await this.options.auth.authorizeSession(client, actor);
    const user = (
      await client.query('SELECT role FROM app.users WHERE id=$1 AND deleted_at IS NULL', [
        actor.userId,
      ])
    ).rows[0];
    if (user?.role !== (self ? 'driver' : 'admin'))
      fail(403, 'forbidden', 'This operation is not available to your account.');
  }
  private async linkedUser(client: PoolClient, id: string) {
    const user = (
      await client.query(
        "SELECT id FROM app.users WHERE id=$1 AND deleted_at IS NULL AND role='driver'",
        [id],
      )
    ).rows[0];
    if (!user)
      fail(
        409,
        'invalid_driver_account',
        'Link an existing active driver account, or omit userId to provision one on credential issue.',
      );
  }
  /**
   * The driver's own record. The sign-in response carries it once and a
   * session outlives that by weeks, so an app that stays signed in has no
   * other way back to a licence number or a suspended credential.
   *
   * Narrower than the ops view of the same row on purpose: a driver reads
   * their own identity and whether their PIN still works, not the moderation
   * state ops keeps about them.
   */
  async self(actor: Actor): Promise<Output> {
    return this.transaction(async (client) => {
      await this.authorize(client, actor, true);
      const row = (
        await client.query(
          `SELECT d.id, d.name, d.phone, d.license_number,
             c.driver_code, c.status, c.must_change_pin, c.locked_until
           FROM app.drivers d
           LEFT JOIN app.driver_credentials c ON c.driver_id = d.id
           WHERE d.user_id = $1 AND d.archived_at IS NULL`,
          [actor.userId],
        )
      ).rows[0];
      // A user with the driver role and no live driver row is not a driver any
      // more. Saying so beats returning an empty shell the app has to guess at.
      if (!row) fail(404, 'not_found', 'Resource not found.');
      return {
        status: 200,
        body: {
          data: {
            id: row.id,
            name: row.name,
            phone: row.phone,
            licenseNumber: row.license_number,
            // Absent until ops issues one. The app shows "not yet issued"
            // rather than a code it invented.
            credential: row.driver_code
              ? {
                  driverCode: row.driver_code,
                  status: row.status,
                  mustChangePin: row.must_change_pin,
                  lockedUntil: row.locked_until ? new Date(row.locked_until).toISOString() : null,
                }
              : null,
          },
        },
        headers: {},
      };
    });
  }
  async list(actor: Actor, query: Record<string, string | undefined>): Promise<Output> {
    return this.transaction(async (client) => {
      await this.authorize(client, actor, false);
      const limit = query.limit === undefined ? 50 : Number(query.limit);
      if (
        !Number.isInteger(limit) ||
        limit < 1 ||
        limit > 200 ||
        (query.limit !== undefined && !/^[1-9]\d*$/.test(query.limit))
      )
        fail(400, 'invalid_query', 'Invalid page size.');
      const now = (await client.query('SELECT clock_timestamp() AS now')).rows[0].now as Date,
        context = `drivers:${actor.userId}`;
      const cursor = query.cursor ? this.cursor.decode(query.cursor, context, now) : null;
      const rows = (
        await client.query(
          `SELECT *,to_char(created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
        FROM app.drivers WHERE ($1::timestamptz IS NULL OR (created_at,id)>($1::timestamptz,$2::uuid)) ORDER BY created_at,id LIMIT $3`,
          [cursor?.time ?? null, cursor?.id ?? null, limit + 1],
        )
      ).rows;
      const page = rows.slice(0, limit),
        last = page.at(-1);
      return success(200, {
        data: page.map(view),
        page: {
          nextCursor:
            rows.length > limit
              ? this.cursor.encode(last.cursor_time, last.id, context, now)
              : null,
        },
      });
    });
  }
  async command(
    actor: Actor,
    op: Exclude<DriverOperation, 'listOpsDrivers'>,
    rawTarget: string | undefined,
    input: Body,
    key: string,
    ifMatch?: string,
  ): Promise<Output> {
    for (let attempt = 0; ; attempt++) {
      try {
        return await this.execute(actor, op, rawTarget, input, key, ifMatch);
      } catch (error) {
        // Concurrent first issue may have linked a principal after discovery.
        // Restart from scratch instead of locking that user AFTER its driver.
        if (
          !(error instanceof TransportError) ||
          error.code !== 'driver_link_changed' ||
          attempt >= 2
        )
          throw error;
      }
    }
  }
  private async execute(
    actor: Actor,
    op: Exclude<DriverOperation, 'listOpsDrivers'>,
    rawTarget: string | undefined,
    input: Body,
    key: string,
    ifMatch?: string,
  ): Promise<Output> {
    const self = op === 'changeDriverPin',
      create = op === 'createDriver';
    const target = create ? 'collection' : self ? catalogId(actor.userId) : catalogId(rawTarget);
    const body = { ...input };
    if (typeof body.userId === 'string') body.userId = catalogId(body.userId);
    if (typeof body.code === 'string') body.code = normalizeDriverCode(body.code);
    const keyHash = hashToken(key),
      inputHash = this.replay.digest(canonical(body));
    const output = await this.transaction(async (client) => {
      // Non-locking identity discovery only; no response before authorization.
      // Acquire ALL existing principals in UUID order before session/driver/credential
      // locks. This avoids shared-to-exclusive upgrades and cross-account cycles.
      const peek = create
        ? undefined
        : (
            await client.query<Row>(
              self
                ? 'SELECT * FROM app.drivers WHERE user_id=$1'
                : 'SELECT * FROM app.drivers WHERE id=$1',
              [target],
            )
          ).rows[0];
      const users = [
        catalogId(actor.userId),
        peek?.user_id,
        typeof body.userId === 'string' ? body.userId : undefined,
      ].filter((v): v is string => !!v);
      await client.query(
        'SELECT id FROM app.users WHERE id=ANY($1::uuid[]) ORDER BY id FOR UPDATE',
        [users],
      );
      await this.authorize(client, actor, self);
      let driver = create
        ? undefined
        : (
            await client.query<Row>('SELECT * FROM app.drivers WHERE id=$1 FOR UPDATE', [
              peek?.id ?? null,
            ])
          ).rows[0];
      if (!create && !driver) fail(404, 'not_found', 'Driver not found.');
      if (driver && driver.user_id !== peek?.user_id)
        fail(409, 'driver_link_changed', 'Driver linkage changed; retry the request.');
      const existing = (
        await client.query(
          'SELECT * FROM app.driver_commands WHERE actor_user_id=$1 AND operation=$2 AND target=$3 AND key_hash=$4',
          [actor.userId, op, target, keyHash],
        )
      ).rows[0];
      const now = (await client.query('SELECT clock_timestamp() AS now')).rows[0].now as Date;
      if (existing) {
        if (existing.input_hash !== inputHash)
          fail(409, 'idempotency_conflict', 'This key was used for different input.');
        if (secretOperation(op)) {
          if (
            existing.replay_expires_at <= now ||
            !existing.secret_ciphertext ||
            driver?.archived_at
          )
            fail(
              409,
              'secret_no_longer_available',
              'Issue a new reset request; the old secret is no longer available.',
            );
          const current = (
            await client.query(
              'SELECT pin_version,status FROM app.driver_credentials WHERE driver_id=$1 FOR SHARE',
              [driver!.id],
            )
          ).rows[0];
          // Suspension blocks sign-in, not ops recovery. Reset does not reactivate
          // it; retry may still deliver the current PIN to the authorized issuer.
          if (!current || current.pin_version !== existing.pin_version)
            fail(
              409,
              'secret_no_longer_available',
              'The credential has changed; this secret is no longer available.',
            );
          if (driver!.user_id) await this.linkedUser(client, driver!.user_id);
          const scope = canonical([actor.userId, op, target, keyHash, inputHash, existing.id]);
          return success(
            existing.response_status,
            this.replay.open(existing.secret_ciphertext, scope),
            existing.response_headers,
          );
        }
        if (
          existing.replay_expires_at <= now ||
          (existing.response_status !== 204 && existing.response_body === null)
        )
          fail(409, 'idempotency_expired', 'Use a new command key.');
        return success(
          existing.response_status,
          existing.response_body ?? undefined,
          existing.response_headers,
        );
      }
      if (op === 'updateDriver') {
        if (ifMatch === undefined)
          fail(428, 'precondition_required', 'Supply the driver edit token.');
        if (ifMatch !== editToken(driver!))
          fail(412, 'precondition_failed', 'The driver changed; reload it before editing.');
      }
      let response: Output,
        pinVersion: number | null = null;
      if (create) {
        const name = String(body.name).trim();
        if (!name) fail(400, 'invalid_request', 'Driver name is required.');
        if (typeof body.userId === 'string') await this.linkedUser(client, body.userId);
        driver = (
          await client.query<Row>(
            'INSERT INTO app.drivers(name,phone,license_number,user_id) VALUES ($1,$2,$3,$4) RETURNING *',
            [name, body.phone ?? null, body.licenseNumber ?? null, body.userId ?? null],
          )
        ).rows[0]!;
        response = success(
          201,
          { data: view(driver) },
          { ETag: editToken(driver), Location: `/v1/ops/drivers/${driver.id}` },
        );
      } else if (op === 'updateDriver') {
        if (!Object.keys(body).length)
          fail(400, 'invalid_request', 'Supply at least one driver field.');
        if (typeof body.userId === 'string') await this.linkedUser(client, body.userId);
        if (body.archived === true && !driver!.archived_at) {
          // Hold driver exclusive; guard_trip takes SHARE before any new assignment.
          // Do not lock trips here (trip commands acquire those before the driver).
          if (
            (
              await client.query(
                "SELECT 1 FROM app.trips WHERE assigned_driver_id=$1 AND status IN ('scheduled','active') LIMIT 1",
                [driver!.id],
              )
            ).rowCount
          )
            fail(
              409,
              'driver_has_open_trips',
              'Reassign or cancel open trips before archiving this driver.',
            );
        }
        const values: unknown[] = [driver!.id],
          sets: string[] = [];
        for (const [field, column] of Object.entries({
          name: 'name',
          phone: 'phone',
          licenseNumber: 'license_number',
          userId: 'user_id',
          archived: 'archived_at',
        })) {
          if (body[field] === undefined) continue;
          let value: unknown = body[field];
          if (field === 'name') {
            value = String(value).trim();
            if (!value) fail(400, 'invalid_request', 'Driver name is required.');
          }
          if (field === 'archived') value = value ? (driver!.archived_at ?? now) : null;
          values.push(value);
          sets.push(`${column}=$${values.length}`);
        }
        const oldUser = driver!.user_id;
        driver = (
          await client.query<Row>(
            `UPDATE app.drivers SET ${sets.join(',')},version=version+1,updated_at=clock_timestamp() WHERE id=$1 RETURNING *`,
            values,
          )
        ).rows[0]!;
        if (oldUser && (driver.archived_at || oldUser !== driver.user_id))
          await this.revoke(client, oldUser, now);
        response = success(200, { data: view(driver) }, { ETag: editToken(driver) });
      } else {
        if (driver!.archived_at) fail(409, 'driver_archived', 'This driver is archived.');
        let credential = (
          await client.query('SELECT * FROM app.driver_credentials WHERE driver_id=$1 FOR UPDATE', [
            driver!.id,
          ])
        ).rows[0];
        if (op === 'issueDriverCredential') {
          if (credential) fail(409, 'credential_exists', 'This driver already has a credential.');
          if (driver!.user_id) await this.linkedUser(client, driver!.user_id);
          else {
            const user = (
              await client.query(
                "INSERT INTO app.users(role,display_name,phone) VALUES ('driver',$1,$2) RETURNING id",
                [driver!.name, driver!.phone],
              )
            ).rows[0];
            driver = (
              await client.query<Row>(
                'UPDATE app.drivers SET user_id=$2,version=version+1,updated_at=clock_timestamp() WHERE id=$1 RETURNING *',
                [driver!.id, user.id],
              )
            ).rows[0]!;
          }
          const pin = generatePin(),
            provided = typeof body.code === 'string' ? body.code : undefined;
          if (provided && !/^DR-[23456789ABCDEFGHJKMNPQRSTVWXYZ]{4}$/.test(provided))
            fail(
              400,
              'invalid_driver_code',
              'Use a four-character driver code from the supported alphabet.',
            );
          for (let attempt = 0; attempt < 5; attempt++) {
            credential = (
              await client.query(
                `INSERT INTO app.driver_credentials(driver_id,driver_code,pin_hash) VALUES ($1,$2,$3)
              ON CONFLICT(driver_code) DO NOTHING RETURNING *`,
                [
                  driver!.id,
                  provided ?? generateDriverCode(),
                  hashDriverPin(pin, this.options.pinSecret),
                ],
              )
            ).rows[0];
            if (credential) break;
            if (provided) fail(409, 'driver_code_taken', 'This driver code is already in use.');
          }
          if (!credential)
            fail(
              409,
              'driver_code_unavailable',
              'Could not allocate a driver code; retry with a new request.',
            );
          pinVersion = credential.pin_version;
          response = success(
            201,
            { data: { code: credential.driver_code, pin } },
            { Location: `/v1/ops/drivers/${driver!.id}/credentials` },
          );
        } else {
          if (!credential || !driver!.user_id)
            fail(404, 'not_found', 'Driver credential not found.');
          await this.linkedUser(client, driver!.user_id);
          if (op === 'changeCredentialState') {
            if (body.action === 'unlock')
              await client.query(
                'UPDATE app.driver_credentials SET failed_attempts=0,locked_until=NULL,updated_at=$2 WHERE driver_id=$1',
                [driver!.id, now],
              );
            else {
              await client.query(
                'UPDATE app.driver_credentials SET status=$2,updated_at=$3 WHERE driver_id=$1',
                [driver!.id, body.action === 'suspend' ? 'suspended' : 'active', now],
              );
              if (body.action === 'suspend') await this.revoke(client, driver!.user_id, now);
            }
            response = success();
          } else {
            if (op === 'changeDriverPin') {
              if (credential.locked_until && credential.locked_until > now)
                return new DriverLockedError(
                  Math.max(
                    1,
                    Math.ceil((credential.locked_until.getTime() - now.getTime()) / 1000),
                  ),
                );
              if (
                !verifyDriverPin(
                  String(body.currentPin),
                  credential.pin_hash,
                  this.options.pinSecret,
                )
              ) {
                const attempts = credential.failed_attempts + 1;
                await client.query(
                  "UPDATE app.driver_credentials SET failed_attempts=$2,locked_until=CASE WHEN $2>=5 THEN $3::timestamptz+interval '15 minutes' ELSE locked_until END,updated_at=$3 WHERE driver_id=$1",
                  [driver!.id, attempts, now],
                );
                return attempts >= 5
                  ? new DriverLockedError(900)
                  : new TransportError(
                      401,
                      'invalid_driver_credentials',
                      'Current PIN is incorrect.',
                    );
              }
              if (
                isTrivialPin(String(body.newPin)) ||
                verifyDriverPin(String(body.newPin), credential.pin_hash, this.options.pinSecret)
              )
                fail(
                  400,
                  'weak_pin',
                  'Choose a different PIN that is not repeated or sequential digits.',
                );
            }
            let pin = op === 'changeDriverPin' ? String(body.newPin) : generatePin();
            while (
              op === 'resetDriverPin' &&
              verifyDriverPin(pin, credential.pin_hash, this.options.pinSecret)
            )
              pin = generatePin();
            credential = (
              await client.query(
                `UPDATE app.driver_credentials SET pin_hash=$2,must_change_pin=$3,pin_version=pin_version+1,
              failed_attempts=0,locked_until=NULL,pin_set_at=$4,updated_at=$4 WHERE driver_id=$1 RETURNING *`,
                [
                  driver!.id,
                  hashDriverPin(pin, this.options.pinSecret),
                  op === 'resetDriverPin',
                  now,
                ],
              )
            ).rows[0];
            // Baseline revokes ALL sessions, including the one changing its PIN.
            await this.revoke(client, driver!.user_id, now);
            if (op === 'resetDriverPin') {
              pinVersion = credential.pin_version;
              response = success(200, { data: { code: credential.driver_code, pin } });
            } else response = success();
          }
        }
      }
      const commandId = randomUUID(),
        scope = canonical([actor.userId, op, target, keyHash, inputHash, commandId]);
      const expires = new Date(now.getTime() + (secretOperation(op) ? 300000 : 7 * 86400000));
      await client.query(
        `INSERT INTO app.driver_commands(id,actor_user_id,driver_id,operation,target,key_hash,input_hash,response_status,response_body,response_headers,secret_ciphertext,pin_version,created_at,replay_expires_at)
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)`,
        [
          commandId,
          actor.userId,
          driver!.id,
          op,
          target,
          keyHash,
          inputHash,
          response.status,
          secretOperation(op) ? null : (response.body ?? null),
          response.headers,
          secretOperation(op) ? this.replay.seal(response.body, scope) : null,
          pinVersion,
          now,
          expires,
        ],
      );
      await client.query(
        'INSERT INTO app.driver_events(driver_id,actor_user_id,command_id,operation,reason) VALUES ($1,$2,$3,$4,$5)',
        [
          driver!.id,
          actor.userId,
          commandId,
          op,
          typeof body.reason === 'string' ? body.reason : null,
        ],
      );
      return response;
    });
    // Authentication failures with durable counters commit, but occupy no receipt.
    if (output instanceof TransportError) throw output;
    return output;
  }
  private async revoke(client: PoolClient, userId: string, now: Date) {
    await client.query(
      'UPDATE app.auth_sessions SET revoked_at=COALESCE(revoked_at,$2) WHERE user_id=$1',
      [userId, now],
    );
  }
}

// No new public maintenance endpoint. A deployment worker must schedule this
// bounded physical erasure before launch; logical expiry does not depend on it.
export async function purgeExpiredDriverSecrets(pool: Pool, limit = 100): Promise<number> {
  if (!Number.isInteger(limit) || limit < 1 || limit > 1000) throw new Error('Invalid purge limit');
  const result = await pool.query(
    `WITH expired AS (SELECT id FROM app.driver_commands WHERE secret_ciphertext IS NOT NULL
    AND replay_expires_at<=clock_timestamp() ORDER BY replay_expires_at,id LIMIT $1 FOR UPDATE SKIP LOCKED)
    UPDATE app.driver_commands c SET secret_ciphertext=NULL FROM expired e WHERE c.id=e.id`,
    [limit],
  );
  return result.rowCount ?? 0;
}
