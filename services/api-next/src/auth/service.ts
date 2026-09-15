import type { Pool, PoolClient } from 'pg';
import { errors as joseErrors } from 'jose';
import { ZodError } from 'zod';
import { TransportError, fail, mapDatabaseError } from '../transport/errors.js';
import type { Actor } from '../transport/service.js';
import { cursorCodec } from '../transport/cursor.js';
import { accessTokens, hashToken, newRefresh, providerTokenBox } from './credentials.js';
import type { AccessConfig } from './credentials.js';
import type { IdTokenVerifier, Provider, VerifiedIdentity } from './types.js';
import type { AppleTokenClient } from './apple-token-types.js';
import { normalizeDriverCode, verifyDriverPin } from './driver-pin.js';

export const authOperations = [
  'signInGoogle',
  'signInApple',
  'signInDriver',
  'refreshSession',
  'logoutSession',
  'getAccount',
  'listSessions',
  'revokeSession',
] as const;
export const publicAuthOperations = [
  'signInGoogle',
  'signInApple',
  'signInDriver',
  'refreshSession',
  'logoutSession',
] as const;
export type AuthOperation = (typeof authOperations)[number];
export class DriverLockedError extends TransportError {
  constructor(public readonly retryAfterSeconds: number) {
    super(423, 'driver_locked', 'Too many attempts. Please try again later.');
  }
}
export interface AuthOptions {
  pool: Pool;
  access: AccessConfig;
  pinSecret: string;
  cursorSecret: Buffer;
  refreshTtlDays: number;
  shiftTtlHours: number;
  google?: IdTokenVerifier;
  apple?: IdTokenVerifier;
  appleTokens?: AppleTokenClient;
  providerEncryptionKey?: Buffer;
  // URL signing must be local; never make a network call while holding auth locks.
  avatarUrl?: (objectKey: string) => string;
}
type User = {
  id: string;
  role: string;
  display_name: string | null;
  email: string | null;
  phone: string | null;
  avatar_object_key: string | null;
  created_at: Date;
  deleted_at: Date | null;
};
const denied = () => new TransportError(401, 'unauthenticated', 'Sign in to continue.');
const result = (data?: unknown) => ({
  status: data === undefined ? 204 : 200,
  headers: {} as Record<string, string>,
  body: data === undefined ? undefined : { data },
});

export class AuthService {
  readonly tokens;
  private readonly cursor;
  private readonly box;
  constructor(private readonly options: AuthOptions) {
    this.tokens = accessTokens(options.access);
    this.cursor = cursorCodec(options.cursorSecret);
    if (
      Buffer.byteLength(options.pinSecret) < 32 ||
      !Number.isInteger(options.refreshTtlDays) ||
      options.refreshTtlDays <= 0 ||
      options.refreshTtlDays > 90 ||
      !Number.isInteger(options.shiftTtlHours) ||
      options.shiftTtlHours <= 0 ||
      options.shiftTtlHours > 24
    )
      throw new Error('Explicit PIN secret and bounded device/shift lifetimes required');
    if (options.appleTokens && !options.providerEncryptionKey)
      throw new Error('Apple code exchange requires encrypted credential storage');
    this.box = options.providerEncryptionKey
      ? providerTokenBox(options.providerEncryptionKey)
      : undefined;
  }

  private async transaction<T>(work: (client: PoolClient) => Promise<T>): Promise<T> {
    const client = await this.options.pool.connect();
    try {
      await client.query('BEGIN');
      await client.query("SET LOCAL TIME ZONE 'UTC'");
      await client.query("SET LOCAL lock_timeout='3s'");
      await client.query("SET LOCAL statement_timeout='10s'");
      const output = await work(client);
      await client.query('COMMIT');
      return output;
    } catch (error) {
      await client.query('ROLLBACK');
      throw mapDatabaseError(error);
    } finally {
      client.release();
    }
  }
  private async now(client: PoolClient): Promise<Date> {
    return (await client.query('SELECT clock_timestamp() AS now')).rows[0].now;
  }
  private account(user: User) {
    if (user.avatar_object_key && !this.options.avatarUrl)
      fail(503, 'avatar_signer_unavailable', 'Account details are temporarily unavailable.');
    return {
      id: user.id,
      role: user.role,
      displayName: user.display_name || 'New user',
      phone: user.phone,
      avatarUrl: user.avatar_object_key ? this.options.avatarUrl!(user.avatar_object_key) : null,
      createdAt: user.created_at.toISOString(),
    };
  }
  // Global auth lock order: user, session, refresh credential, driver/credential.
  // Exclusive user locks serialize refresh/revoke/PIN state against transport's
  // shared session authorization for the whole command transaction.
  private async user(client: PoolClient, id: string, write = false): Promise<User> {
    const row = (
      await client.query<User>(
        `SELECT * FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR ${write ? 'UPDATE' : 'SHARE'}`,
        [id],
      )
    ).rows[0];
    if (!row) throw denied();
    return row;
  }
  private async driverAllowed(client: PoolClient, user: User) {
    if (user.role !== 'driver') return;
    const row = (
      await client.query(
        `SELECT c.status FROM app.drivers d JOIN app.driver_credentials c ON c.driver_id=d.id
      WHERE d.user_id=$1 AND d.archived_at IS NULL FOR SHARE OF d,c`,
        [user.id],
      )
    ).rows[0];
    if (!row || row.status !== 'active') throw denied();
  }
  // Used by transport INSIDE its transaction. A valid signature is not access.
  readonly authorizeSession = async (client: PoolClient, actor: Actor): Promise<void> => {
    const user = await this.user(client, actor.userId);
    const session = (
      await client.query(
        `SELECT id FROM app.auth_sessions
      WHERE id=$1 AND user_id=$2 AND revoked_at IS NULL AND expires_at>clock_timestamp() FOR SHARE`,
        [actor.sessionId, actor.userId],
      )
    ).rows[0];
    if (!session) throw denied();
    await this.driverAllowed(client, user);
  };

  private async issue(
    client: PoolClient,
    user: User,
    sessionId: string,
    expiresAt: Date,
    now: Date,
  ) {
    const refreshToken = newRefresh();
    await client.query(
      'INSERT INTO app.refresh_credentials(token_hash,session_id,created_at,expires_at) VALUES ($1,$2,$3,$4)',
      [hashToken(refreshToken), sessionId, now, expiresAt],
    );
    const accessExpires = new Date(
      Math.min(expiresAt.getTime(), now.getTime() + this.options.access.ttlSeconds * 1000),
    );
    // Sign before COMMIT: signing/storage failures leave the old refresh usable.
    const accessToken = await this.tokens.sign(
      { userId: user.id, sessionId },
      user.role,
      now,
      accessExpires,
    );
    return {
      accessToken,
      refreshToken,
      accessExpiresAt: new Date(Math.floor(accessExpires.getTime() / 1000) * 1000).toISOString(),
      refreshExpiresAt: expiresAt.toISOString(),
      account: this.account(user),
    };
  }
  private async newSession(client: PoolClient, user: User, ttlMs: number, rolling = true) {
    const now = await this.now(client),
      expires = new Date(now.getTime() + ttlMs);
    const row = (
      await client.query(
        `INSERT INTO app.auth_sessions(user_id,created_at,expires_at,refresh_ttl_seconds) VALUES ($1,$2,$3,$4) RETURNING id`,
        [user.id, now, expires, rolling ? Math.ceil(ttlMs / 1000) : null],
      )
    ).rows[0];
    return this.issue(client, user, row.id, expires, now);
  }

  async social(
    provider: Provider,
    input: { idToken: string; nonce?: string; displayName?: string; authorizationCode?: string },
  ) {
    const verifier = this.options[provider];
    if (!verifier) fail(503, 'provider_unavailable', 'This sign-in provider is not configured.');
    let identity: VerifiedIdentity;
    try {
      identity = await verifier.verify(input.idToken, input.nonce);
    } catch (error) {
      if (
        (error instanceof joseErrors.JOSEError && !(error instanceof joseErrors.JWKSTimeout)) ||
        error instanceof ZodError ||
        (error instanceof Error &&
          /^(Apple (email not verified|nonce mismatch|token carries a nonce)|Google email not verified)/.test(
            error.message,
          ))
      )
        throw denied();
      fail(503, 'provider_unavailable', 'The sign-in provider is temporarily unavailable.');
    }
    if (identity.provider !== provider || !identity.providerId || identity.providerId.length > 1024)
      throw denied();
    // Match the existing best-effort Apple code capture. Never hold SQL locks
    // during provider calls. Erasure/revocation orchestration is a later slice.
    let encrypted: string | null = null;
    if (provider === 'apple' && input.authorizationCode && this.options.appleTokens) {
      try {
        const token = await this.options.appleTokens.exchangeCode(input.authorizationCode);
        if (token.refreshToken) encrypted = this.box!.seal(token.refreshToken, identity.providerId);
      } catch {
        /* Invalid/already-used optional code never invalidates a verified ID token. */
      }
    }
    return this.transaction(async (client) => {
      // Prevent concurrent first sign-ins from leaving an unlinked user behind.
      await client.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
        JSON.stringify(['auth-identity', provider, identity.providerId]),
      ]);
      const existing = (
        await client.query(
          'SELECT user_id FROM app.auth_identities WHERE provider=$1 AND subject=$2',
          [provider, identity.providerId],
        )
      ).rows[0];
      let user: User;
      if (existing) {
        user = await this.user(client, existing.user_id, true);
        if (!user.email && identity.email)
          await client.query('UPDATE app.users SET email=$2 WHERE id=$1', [
            user.id,
            identity.email,
          ]);
        if (encrypted)
          await client.query(
            'UPDATE app.auth_identities SET provider_token_ciphertext=$3 WHERE provider=$1 AND subject=$2',
            [provider, identity.providerId, encrypted],
          );
      } else {
        const displayName =
          (identity.displayName || (provider === 'apple' ? input.displayName : '') || 'New user')
            .trim()
            .slice(0, 200) || 'New user';
        user = (
          await client.query<User>(
            `INSERT INTO app.users(role,display_name,email) VALUES ('commuter',$1,$2) RETURNING *`,
            [displayName, identity.email],
          )
        ).rows[0]!;
        await client.query(
          'INSERT INTO app.auth_identities(user_id,provider,subject,provider_token_ciphertext) VALUES ($1,$2,$3,$4)',
          [user.id, provider, identity.providerId, encrypted],
        );
      }
      await this.driverAllowed(client, user);
      return this.newSession(client, user, this.options.refreshTtlDays * 86400000);
    });
  }

  async driver(input: { code: string; pin: string; ownDevice: boolean }) {
    const output = await this.transaction(async (client) => {
      const match = (
        await client.query(
          `SELECT d.user_id FROM app.driver_credentials c JOIN app.drivers d ON d.id=c.driver_id WHERE c.driver_code=$1`,
          [normalizeDriverCode(input.code)],
        )
      ).rows[0];
      if (!match?.user_id) {
        verifyDriverPin(input.pin, '0'.repeat(64), this.options.pinSecret);
        return denied();
      }
      const user = await this.user(client, match.user_id, true);
      const row = (
        await client.query(
          `SELECT c.*,d.name,d.archived_at FROM app.driver_credentials c JOIN app.drivers d ON d.id=c.driver_id
        WHERE d.user_id=$1 AND c.driver_code=$2 FOR UPDATE OF c FOR SHARE OF d`,
          [user.id, normalizeDriverCode(input.code)],
        )
      ).rows[0];
      if (!row || user.role !== 'driver' || row.archived_at) return denied();
      if (row.status !== 'active')
        return new TransportError(403, 'driver_suspended', 'This driver account is suspended.');
      const now = await this.now(client);
      if (row.locked_until && row.locked_until > now)
        return new DriverLockedError(
          Math.max(1, Math.ceil((row.locked_until.getTime() - now.getTime()) / 1000)),
        );
      if (!verifyDriverPin(input.pin, row.pin_hash, this.options.pinSecret)) {
        const attempts = Number(row.failed_attempts) + 1;
        await client.query(
          `UPDATE app.driver_credentials SET failed_attempts=$2,
          locked_until=CASE WHEN $2>=5 THEN $3::timestamptz+interval '15 minutes' ELSE locked_until END,updated_at=$3 WHERE driver_id=$1`,
          [row.driver_id, attempts, now],
        );
        return attempts >= 5 ? new DriverLockedError(900) : denied();
      }
      await client.query(
        'UPDATE app.driver_credentials SET failed_attempts=0,locked_until=NULL,updated_at=$2 WHERE driver_id=$1',
        [row.driver_id, now],
      );
      const tokens = await this.newSession(
        client,
        user,
        input.ownDevice
          ? this.options.refreshTtlDays * 86400000
          : this.options.shiftTtlHours * 3600000,
        input.ownDevice,
      );
      return {
        ...tokens,
        driver: { id: row.driver_id, name: row.name },
        mustChangePin: row.must_change_pin,
      };
    });
    // Expected rejection follows COMMIT, so lockout counters cannot roll back.
    if (output instanceof TransportError) throw output;
    return output;
  }

  async refresh(token: string) {
    const output = await this.transaction(async (client) => {
      const match = (
        await client.query(
          `SELECT s.user_id FROM app.refresh_credentials c JOIN app.auth_sessions s ON s.id=c.session_id WHERE c.token_hash=$1`,
          [hashToken(token)],
        )
      ).rows[0];
      if (!match) return denied();
      const user = await this.user(client, match.user_id, true);
      const row = (
        await client.query(
          `SELECT s.*,c.consumed_at,c.expires_at AS credential_expires_at FROM app.refresh_credentials c JOIN app.auth_sessions s ON s.id=c.session_id
        WHERE c.token_hash=$1 FOR UPDATE OF s,c`,
          [hashToken(token)],
        )
      ).rows[0];
      const now = await this.now(client);
      if (!row || row.expires_at <= now || row.credential_expires_at <= now) return denied();
      if (row.consumed_at) {
        // Baseline actually revokes ALL user sessions, not only a chain. Retain
        // that security behavior explicitly, including lost-response rejection.
        await client.query(
          'UPDATE app.auth_sessions SET revoked_at=COALESCE(revoked_at,$2) WHERE user_id=$1',
          [user.id, now],
        );
        return denied();
      }
      if (row.revoked_at) return denied();
      await this.driverAllowed(client, user);
      await client.query('UPDATE app.refresh_credentials SET consumed_at=$2 WHERE token_hash=$1', [
        hashToken(token),
        now,
      ]);
      // Do not turn a shared-device shift into a long-lived session on refresh.
      const expires = row.refresh_ttl_seconds
        ? new Date(now.getTime() + row.refresh_ttl_seconds * 1000)
        : row.expires_at;
      await client.query('UPDATE app.auth_sessions SET expires_at=$2 WHERE id=$1', [
        row.id,
        expires,
      ]);
      return this.issue(client, user, row.id, expires, now);
    });
    if (output instanceof TransportError) throw output;
    return output;
  }
  async logout(token: string) {
    await this.transaction(async (client) => {
      const match = (
        await client.query(
          `SELECT s.user_id FROM app.refresh_credentials c JOIN app.auth_sessions s ON s.id=c.session_id WHERE c.token_hash=$1`,
          [hashToken(token)],
        )
      ).rows[0];
      if (!match) return;
      // Logout remains an idempotent credential operation, even after erasure.
      await client.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [match.user_id]);
      await client.query(
        `UPDATE app.auth_sessions s SET revoked_at=COALESCE(s.revoked_at,clock_timestamp())
        FROM app.refresh_credentials c WHERE c.session_id=s.id AND c.token_hash=$1 AND c.consumed_at IS NULL`,
        [hashToken(token)],
      );
    });
  }

  async handle(
    name: AuthOperation,
    actor: Actor | undefined,
    body: any,
    query: Record<string, string | undefined>,
    target: string | undefined,
    key: string | undefined,
  ) {
    if (name === 'signInGoogle' || name === 'signInApple')
      return result(await this.social(name === 'signInGoogle' ? 'google' : 'apple', body));
    if (name === 'signInDriver') return result(await this.driver(body));
    if (name === 'refreshSession') return result(await this.refresh(body.refreshToken));
    if (name === 'logoutSession') {
      await this.logout(body.refreshToken);
      return result();
    }
    if (!actor) throw denied();
    return this.transaction(async (client) => {
      // Revocation takes the exclusive user lock first; do not upgrade a shared
      // lock after session checks (two concurrent revokers would deadlock).
      if (name === 'revokeSession') await this.user(client, actor.userId, true);
      await this.authorizeSession(client, actor);
      if (name === 'getAccount') return result(this.account(await this.user(client, actor.userId)));
      if (name === 'listSessions') {
        const limit = query.limit === undefined ? 50 : Number(query.limit);
        if (
          !Number.isInteger(limit) ||
          limit < 1 ||
          limit > 200 ||
          (query.limit !== undefined && !/^[1-9]\d*$/.test(query.limit))
        )
          fail(400, 'invalid_query', 'Invalid page size.');
        const now = await this.now(client),
          context = `sessions:${actor.userId}`;
        const cursor = query.cursor ? this.cursor.decode(query.cursor, context, now) : null;
        const rows = (
          await client.query(
            `SELECT id,created_at,expires_at,
          to_char(created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
          FROM app.auth_sessions WHERE user_id=$1 AND revoked_at IS NULL AND expires_at>$2
          AND ($3::timestamptz IS NULL OR (created_at,id)>($3::timestamptz,$4::uuid))
          ORDER BY created_at,id LIMIT $5`,
            [actor.userId, now, cursor?.time ?? null, cursor?.id ?? null, limit + 1],
          )
        ).rows;
        const page = rows.slice(0, limit),
          last = page.at(-1);
        return {
          status: 200,
          headers: {},
          body: {
            data: page.map((row) => ({
              id: row.id,
              createdAt: row.created_at.toISOString(),
              expiresAt: row.expires_at.toISOString(),
              current: row.id === actor.sessionId,
            })),
            page: {
              nextCursor:
                rows.length > limit
                  ? this.cursor.encode(last!.cursor_time, last!.id, context, now)
                  : null,
            },
          },
        };
      }
      if (
        !target ||
        !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(target)
      )
        fail(400, 'invalid_request', 'Invalid session identifier.');
      if (!key || key.length > 128)
        fail(400, 'idempotency_key_required', 'Supply an Idempotency-Key of 1 to 128 characters.');
      const existing = (
        await client.query(
          `SELECT replay_expires_at FROM app.auth_commands WHERE actor_user_id=$1 AND target_session_id=$2 AND key_hash=$3`,
          [actor.userId, target, hashToken(key)],
        )
      ).rows[0];
      const now = await this.now(client);
      if (existing) {
        if (existing.replay_expires_at <= now)
          fail(409, 'idempotency_expired', 'Use a new command key.');
        return result();
      }
      await client.query(
        'UPDATE app.auth_sessions SET revoked_at=COALESCE(revoked_at,$3) WHERE id=$1 AND user_id=$2',
        [target, actor.userId, now],
      );
      await client.query(
        `INSERT INTO app.auth_commands(actor_user_id,target_session_id,key_hash,created_at,replay_expires_at) VALUES ($1,$2,$3,$4,$4::timestamptz+interval '7 days')`,
        [actor.userId, target, hashToken(key), now],
      );
      return result();
    });
  }
}
