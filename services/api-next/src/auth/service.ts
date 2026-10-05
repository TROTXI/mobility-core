import { beginTransaction } from '../db/transaction.js';
import type { Pool, PoolClient } from 'pg';
import { TransportError, fail, mapDatabaseError } from '../transport/errors.js';
import type { Actor, AuthorizedActor } from '../transport/service.js';
import { cursorCodec } from '../transport/cursor.js';
import { accessTokens, hashToken, newRefresh, providerTokenBox } from './credentials.js';
import type { AccessConfig } from './credentials.js';
import type { IdTokenVerifier, Provider } from './types.js';
import type { AppleTokenClient } from './apple-token-types.js';
import type { PasskeyRelyingParty } from './passkeys.js';
import { phoneVerificationStatus, type PhoneOtp } from './phone-otp.js';
import {
  OpsTeam,
  teamOperations,
  type OpsInvitationEmail,
  type TeamOperation,
} from './ops-team.js';
import { driverSignIn } from './driver-signin.js';
import { passkeyCeremony } from './passkey-flow.js';
import { socialSignIn } from './social-signin.js';

export const authOperations = [
  ...teamOperations,
  'signInOpsGoogle',
  'requestPhoneSignIn',
  'verifyPhoneSignIn',
  'startPhoneVerification',
  'confirmPhoneVerification',
  'getVerification',
  'signInGoogle',
  'signInApple',
  'signInDriver',
  'refreshSession',
  'logoutSession',
  'getAccount',
  'listSessions',
  'revokeSession',
  'getPasskeyStatus',
  'startPasskeyRegistration',
  'finishPasskeyRegistration',
  'startPasskeyAuthentication',
  'finishPasskeyAuthentication',
  'resetOperatorPasskeys',
] as const;
/** The only operations an admin session that has not passed the check may call. */
export const passkeyOperations = [
  'getPasskeyStatus',
  'startPasskeyRegistration',
  'finishPasskeyRegistration',
  'startPasskeyAuthentication',
  'finishPasskeyAuthentication',
  'resetOperatorPasskeys',
] as const;
export type PasskeyOperation = (typeof passkeyOperations)[number];
/**
 * How long a passed check lasts. The design's session card says eight hours,
 * one shift: after that the console asks for a code again, and the session
 * itself stays signed in.
 */
export const ADMIN_ELEVATION_HOURS = 8;
export const PASSKEY_CHALLENGE_SECONDS = 300;
export const publicAuthOperations = [
  'signInOpsGoogle',
  'requestPhoneSignIn',
  'verifyPhoneSignIn',
  'signInGoogle',
  'signInApple',
  'signInDriver',
  'refreshSession',
  'logoutSession',
] as const;
export type AuthOperation = (typeof authOperations)[number];
/** A lockout the client can wait out. The HTTP layer turns this into Retry-After. */
export class LockedError extends TransportError {
  constructor(
    code: string,
    message: string,
    public readonly retryAfterSeconds: number,
  ) {
    super(423, code, message);
  }
}
export class DriverLockedError extends LockedError {
  constructor(retryAfterSeconds: number) {
    super('driver_locked', 'Too many attempts. Please try again later.', retryAfterSeconds);
  }
}
export interface AuthOptions {
  opsEmail?: OpsInvitationEmail;
  opsOrigin?: string;
  eraseOperator?: (c: PoolClient, actor: Actor, target: string) => Promise<void>;
  phoneOtp?: PhoneOtp;
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
  /** Standards verifier bound to the exact Ops origin and relying-party ID. */
  passkeys?: PasskeyRelyingParty;
  // URL signing must be local; never make a network call while holding auth locks.
  avatarUrl?: (objectKey: string) => string;
}
export type User = {
  id: string;
  role: string;
  display_name: string | null;
  email: string | null;
  phone: string | null;
  avatar_object_key: string | null;
  created_at: Date;
  deleted_at: Date | null;
  is_superadmin?: boolean;
  ops_invite_pending?: boolean;
};
export const denied = () => new TransportError(401, 'unauthenticated', 'Sign in to continue.');
export const result = (data?: unknown) => ({
  status: data === undefined ? 204 : 200,
  headers: {} as Record<string, string>,
  body: data === undefined ? undefined : { data },
});

export class AuthService {
  readonly tokens;
  readonly cursor;
  readonly box;
  constructor(readonly options: AuthOptions) {
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

  async transaction<T>(work: (client: PoolClient) => Promise<T>): Promise<T> {
    const client = await this.options.pool.connect();
    try {
      await beginTransaction(client);
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
  async now(client: PoolClient): Promise<Date> {
    return (await client.query('SELECT clock_timestamp() AS now')).rows[0].now;
  }
  account(user: User) {
    if (user.avatar_object_key && !this.options.avatarUrl)
      fail(503, 'avatar_signer_unavailable', 'Account details are temporarily unavailable.');
    return {
      id: user.id,
      role: user.role,
      displayName: user.display_name || 'New user',
      email: user.email,
      phone: user.phone,
      avatarUrl: user.avatar_object_key ? this.options.avatarUrl!(user.avatar_object_key) : null,
      createdAt: user.created_at.toISOString(),
      isSuperadmin: user.is_superadmin === true,
    };
  }
  // Global auth lock order: user, session, refresh credential, driver/credential.
  // Exclusive user locks serialize refresh/revoke/PIN state against transport's
  // shared session authorization for the whole command transaction.
  async user(client: PoolClient, id: string, write = false): Promise<User> {
    const row = (
      await client.query<User>(
        `SELECT * FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR ${write ? 'UPDATE' : 'SHARE'}`,
        [id],
      )
    ).rows[0];
    if (!row) throw denied();
    return row;
  }
  async driverAllowed(
    client: PoolClient,
    user: User,
  ): Promise<{ id: string; must_change_pin: boolean } | undefined> {
    if (user.role !== 'driver') return undefined;
    const row = (
      await client.query(
        `SELECT d.id, c.status, c.must_change_pin FROM app.drivers d JOIN app.driver_credentials c ON c.driver_id=d.id
      WHERE d.user_id=$1 AND d.archived_at IS NULL FOR SHARE OF d,c`,
        [user.id],
      )
    ).rows[0];
    if (!row || row.status !== 'active') throw denied();
    return row;
  }
  // Used by transport INSIDE its transaction. A valid signature is not access.
  /**
   * Every authenticated request passes through here, and so does the second
   * factor: an admin session that has not passed the passkey check, or
   * passed it more than a shift ago, is refused. 403 and not 401, because the
   * session is valid and the client must send the operator through passkey
   * verification, not sign out.
   *
   * allowUnelevated is for the passkey endpoints alone, which are how an
   * admin gets from signed in to verified.
   *
   * The same holds for a driver on an operations-issued temporary PIN: the
   * session is real, but it reaches nothing operational until the driver has
   * set a private PIN. allowPinSetup is for reading their own record and
   * changing the PIN, the only two things that session is for.
   */
  readonly authorizeSession = async (
    client: PoolClient,
    actor: Actor,
    options: { allowUnelevated?: boolean; allowPinSetup?: boolean } = {},
  ): Promise<void> => {
    await this.authorizeActor(client, actor, options);
  };

  // Reuse checked identity within the caller's transaction only. Keep the
  // user -> session -> driver lock order used by revocation and PIN changes.
  readonly authorizeActor = async (
    client: PoolClient,
    actor: Actor,
    options: { allowUnelevated?: boolean; allowPinSetup?: boolean } = {},
  ): Promise<AuthorizedActor> => {
    const user = await this.user(client, actor.userId);
    const session = (
      await client.query(
        `SELECT id,
          (admin_verified_at IS NOT NULL
            AND admin_verified_at > clock_timestamp() - make_interval(hours => ${ADMIN_ELEVATION_HOURS}))
            AS elevated
        FROM app.auth_sessions
        WHERE id=$1 AND user_id=$2 AND revoked_at IS NULL AND expires_at>clock_timestamp() FOR SHARE`,
        [actor.sessionId, actor.userId],
      )
    ).rows[0];
    if (!session) throw denied();
    if (user.ops_invite_pending) {
      const valid = (
        await client.query(
          "SELECT 1 FROM app.ops_invitations WHERE user_id=$1 AND state='claimed' AND expires_at>clock_timestamp()",
          [user.id],
        )
      ).rowCount;
      if (!valid) fail(403, 'invitation_expired', 'Ask a superadmin for a new invitation.');
      if (!options.allowUnelevated) fail(403, 'passkey_required', 'Complete your passkey setup.');
    }
    const driver = await this.driverAllowed(client, user);
    if (driver?.must_change_pin && !options.allowPinSetup)
      fail(403, 'pin_change_required', 'Set your own PIN before you continue.');
    if (user.role === 'admin' && !session.elevated && !options.allowUnelevated)
      fail(403, 'passkey_required', 'Use your passkey to continue.');
    return { role: user.role, driverId: driver?.id ?? null };
  };

  async issue(client: PoolClient, user: User, sessionId: string, expiresAt: Date, now: Date) {
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
  async newSession(client: PoolClient, user: User, ttlMs: number, rolling = true) {
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

  social(
    provider: Provider,
    input: {
      idToken: string;
      nonce?: string;
      displayName?: string;
      authorizationCode?: string;
      invitationToken?: string;
    },
    opsOnly = false,
  ) {
    return socialSignIn(this, provider, input, opsOnly);
  }

  driver(input: { code: string; pin: string; ownDevice: boolean }) {
    return driverSignIn(this, input);
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

  private passkey(name: PasskeyOperation, actor: Actor, body: any, target: string | undefined) {
    return passkeyCeremony(this, name, actor, body, target);
  }

  async handle(
    name: AuthOperation,
    actor: Actor | undefined,
    body: any,
    query: Record<string, string | undefined>,
    target: string | undefined,
    key: string | undefined,
    sourceIp?: string,
  ) {
    if (name === 'signInOpsGoogle') return result(await this.social('google', body, true));
    if ((teamOperations as readonly string[]).includes(name)) {
      if (!actor) throw denied();
      return new OpsTeam({
        pool: this.options.pool,
        authorize: this.authorizeSession,
        cursorSecret: this.options.cursorSecret,
        email: this.options.opsEmail,
        origin: this.options.opsOrigin,
        eraseOperator: this.options.eraseOperator,
      }).handle(name as TeamOperation, actor, body, query, target, key);
    }
    if (name === 'requestPhoneSignIn' || name === 'verifyPhoneSignIn') {
      if (!this.options.phoneOtp)
        fail(503, 'phone_signin_unavailable', 'Phone sign-in is not configured yet.');
      if (name === 'requestPhoneSignIn')
        return result(await this.options.phoneOtp.request(body.phone, sourceIp ?? ''));
      const tokens = await this.transaction(async (client) => {
        const userId = await this.options.phoneOtp!.verify(client, body.challengeId, body.code);
        if (!userId) return null;
        return this.newSession(
          client,
          await this.user(client, userId),
          this.options.refreshTtlDays * 86400000,
        );
      });
      if (!tokens)
        fail(
          401,
          'invalid_otp',
          'This code is invalid, expired or already used. Request a new code.',
        );
      return result(tokens);
    }
    if (name === 'signInGoogle' || name === 'signInApple')
      return result(await this.social(name === 'signInGoogle' ? 'google' : 'apple', body));
    if (name === 'signInDriver') return result(await this.driver(body));
    if (name === 'refreshSession') return result(await this.refresh(body.refreshToken));
    if (name === 'logoutSession') {
      await this.logout(body.refreshToken);
      return result();
    }
    if (!actor) throw denied();
    if (
      name === 'startPhoneVerification' ||
      name === 'confirmPhoneVerification' ||
      name === 'getVerification'
    ) {
      if (name !== 'getVerification' && !this.options.phoneOtp)
        fail(
          503,
          'phone_verification_unavailable',
          'Phone verification is temporarily unavailable.',
        );
      if (name === 'startPhoneVerification')
        return result(
          await this.options.phoneOtp!.request(body.phone, sourceIp ?? '', {
            userId: actor.userId,
            authorize: (client) => this.authorizeSession(client, actor),
          }),
        );
      if (name === 'confirmPhoneVerification') {
        const outcome = await this.transaction((client) =>
          this.options.phoneOtp!.confirmForAccount(
            client,
            actor,
            body.challengeId,
            body.code,
            (c) => this.authorizeSession(c, actor),
          ),
        );
        if (!outcome)
          fail(
            401,
            'invalid_otp',
            'This code is invalid, expired or already used. Request a new code.',
          );
        return result({ status: outcome });
      }
      return this.transaction(async (client) => {
        await this.authorizeSession(client, actor);
        const user = await this.user(client, actor.userId);
        if (user.role !== 'commuter')
          fail(403, 'forbidden', 'Rider verification is for commuters only.');
        const state = await phoneVerificationStatus(client, actor.userId);
        const profileComplete = Boolean(
          user.display_name?.trim() && user.display_name !== 'New commuter',
        );
        const verified = state.phone.status === 'verified';
        return result({
          ...state,
          standbyEligible: verified && profileComplete,
          missing: [...(!verified ? ['phone'] : []), ...(!profileComplete ? ['profile'] : [])],
        });
      });
    }
    if ((passkeyOperations as readonly string[]).includes(name))
      return this.passkey(name as PasskeyOperation, actor, body, target);
    return this.transaction(async (client) => {
      // Revocation takes the exclusive user lock first; do not upgrade a shared
      // lock after session checks (two concurrent revokers would deadlock).
      if (name === 'revokeSession') await this.user(client, actor.userId, true);
      // Reading who you are is part of setting up: the app restores a
      // temporary-PIN session through this read before sending the driver to
      // choose a PIN. Everything else here waits for the private PIN.
      await this.authorizeSession(client, actor, { allowPinSetup: name === 'getAccount' });
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
