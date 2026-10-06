import { createHash, randomBytes } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import type { Actor } from '../transport/service.js';
import { fail, mapDatabaseError, requireReason } from '../transport/errors.js';
import { beginTransaction } from '../db/transaction.js';
import { cursorCodec } from '../transport/cursor.js';
import type { VerifiedIdentity } from './types.js';

export const teamOperations = [
  'listOpsTeam',
  'inviteOperator',
  'resendOperatorInvitation',
  'cancelOperatorInvitation',
  'updateOperatorAccess',
] as const;
export type TeamOperation = (typeof teamOperations)[number];
export interface OpsInvitationEmail {
  queueInvitation(
    c: PoolClient,
    input: {
      ownerId: string;
      id: string;
      version: number;
      email: string;
      name: string;
      token: string;
      expiresAt: Date;
      origin: string;
    },
  ): Promise<string>;
  sendQueued(id: string): Promise<void>;
}
const hash = (value: string) => createHash('sha256').update(value).digest('hex');
export const teamLock = (c: PoolClient) =>
  c.query("SELECT pg_advisory_xact_lock(hashtextextended('trotxi:ops-team',0))");
export async function requireSuperadmin(c: PoolClient, actor: Actor) {
  const r = (
    await c.query(
      "SELECT 1 FROM app.users WHERE id=$1 AND role='admin' AND is_superadmin AND deleted_at IS NULL FOR SHARE",
      [actor.userId],
    )
  ).rowCount;
  if (!r) fail(403, 'superadmin_required', 'Only a superadmin can manage operator access.');
}
/**
 * Changing who can operate needs a passkey check from moments ago, not the
 * eight-hour session elevation. A session taken over inside that window could
 * otherwise invite an address its holder controls, and that account would
 * outlive the stolen session. Same code as elevation, so the console asks for
 * the passkey; the operator repeats the change afterwards.
 */
export const RECENT_PASSKEY_MINUTES = 5;
export async function requireRecentPasskey(c: PoolClient, actor: Actor) {
  const fresh = (
    await c.query(
      `SELECT 1 FROM app.auth_sessions WHERE id=$1 AND user_id=$2
       AND admin_verified_at > clock_timestamp() - make_interval(mins => ${RECENT_PASSKEY_MINUTES})`,
      [actor.sessionId, actor.userId],
    )
  ).rowCount;
  if (!fresh) fail(403, 'passkey_required', 'Confirm with your passkey to change operator access.');
}
export async function finishInvitation(c: PoolClient, userId: string) {
  const pending = (await c.query('SELECT ops_invite_pending FROM app.users WHERE id=$1', [userId]))
    .rows[0]?.ops_invite_pending;
  if (!pending) return;
  const changed = await c.query(
    "UPDATE app.ops_invitations SET state='accepted',token_hash=NULL,email=NULL,name=NULL WHERE user_id=$1 AND state='claimed' AND expires_at>clock_timestamp() RETURNING id",
    [userId],
  );
  if (!changed.rowCount) fail(403, 'invitation_expired', 'Ask a superadmin for a new invitation.');
  await c.query('UPDATE app.users SET ops_invite_pending=false WHERE id=$1', [userId]);
  await c.query(
    "INSERT INTO app.ops_team_events(actor_user_id,target_id,action) VALUES ($1,$2,'invitation_accepted')",
    [userId, changed.rows[0].id],
  );
}
/** Call only after Google signature, audience and verified-email checks. */
export async function claimInvitation(
  c: PoolClient,
  identity: VerifiedIdentity,
  token: string,
  existingId?: string,
): Promise<string> {
  if (identity.provider !== 'google' || !identity.email || !/^[A-Za-z0-9_-]{43}$/.test(token))
    fail(403, 'invitation_invalid', 'This invitation cannot be used with this account.');
  await teamLock(c);
  const invite = (
    await c.query(
      "SELECT * FROM app.ops_invitations WHERE token_hash=$1 AND state IN ('pending','claimed') AND expires_at>clock_timestamp() FOR UPDATE",
      [hash(token)],
    )
  ).rows[0];
  if (
    !invite ||
    invite.email !== identity.email.toLowerCase() ||
    (invite.user_id && invite.user_id !== existingId)
  )
    fail(403, 'invitation_invalid', 'This invitation cannot be used with this account.');
  let userId = existingId;
  if (userId) {
    const user = (
      await c.query('SELECT * FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR UPDATE', [
        userId,
      ])
    ).rows[0];
    // Only an invitee resuming their own setup continues an existing account.
    // A rider's account is never converted: cancelling unfinished setup would
    // then delete their rider history along with it.
    if (!user || user.role !== 'admin' || !user.ops_invite_pending)
      fail(
        409,
        'operator_account_conflict',
        'This Google account is already used for Trotxi. Use a separate Google account for Operations.',
      );
  } else
    userId = (
      await c.query(
        "INSERT INTO app.users(role,display_name,email) VALUES ('commuter',$1,$2) RETURNING id",
        [invite.name, identity.email],
      )
    ).rows[0].id;
  await c.query("UPDATE app.users SET role='admin',ops_invite_pending=true,email=$2 WHERE id=$1", [
    userId,
    invite.email,
  ]);
  await c.query(
    'UPDATE app.auth_sessions SET revoked_at=COALESCE(revoked_at,clock_timestamp()) WHERE user_id=$1',
    [userId],
  );
  await c.query("UPDATE app.ops_invitations SET user_id=$2,state='claimed' WHERE id=$1", [
    invite.id,
    userId,
  ]);
  return userId!;
}

export class OpsTeam {
  private cursor;
  constructor(
    private options: {
      pool: Pool;
      authorize: (c: PoolClient, a: Actor) => Promise<void>;
      cursorSecret: Buffer;
      email?: OpsInvitationEmail;
      origin?: string;
      eraseOperator?: (c: PoolClient, actor: Actor, target: string) => Promise<void>;
    },
  ) {
    this.cursor = cursorCodec(options.cursorSecret);
  }
  async handle(
    name: TeamOperation,
    actor: Actor,
    body: any,
    query: Record<string, string | undefined>,
    target?: string,
    key?: string,
  ) {
    const c = await this.options.pool.connect();
    let mailId: string | undefined;
    try {
      await beginTransaction(c);
      await teamLock(c);
      await this.options.authorize(c, actor);
      await requireSuperadmin(c, actor);
      const allowedQuery = name === 'listOpsTeam' ? ['cursor', 'limit'] : [];
      if (Object.keys(query).some((field) => !allowedQuery.includes(field)))
        fail(400, 'invalid_query', 'Unsupported query parameters.');
      if (name === 'listOpsTeam') {
        const limit = Number(query.limit ?? 50);
        if (!Number.isInteger(limit) || limit < 1 || limit > 200)
          fail(400, 'invalid_query', 'Use a limit from 1 to 200.');
        const context = JSON.stringify(['ops-team', actor.userId]);
        const after = query.cursor ? this.cursor.decode(query.cursor, context, new Date()) : null;
        const rows = (
          await c.query(
            `SELECT *,to_char(created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time FROM (
          SELECT id,display_name AS name,email,created_at,'member'::text AS kind,'active'::text AS state,is_superadmin,NULL::timestamptz AS expires_at,NULL::text AS email_state FROM app.users WHERE role='admin' AND deleted_at IS NULL AND NOT ops_invite_pending
          UNION ALL
          SELECT i.id,i.name,i.email,i.created_at,'invitation',CASE WHEN i.expires_at<=clock_timestamp() AND i.state='pending' THEN 'expired' ELSE i.state END,false,i.expires_at,
            (SELECT e.state FROM app.email_outbox e WHERE e.kind='ops_invitation' AND e.source_id=i.id ORDER BY e.created_at DESC,e.id DESC LIMIT 1)
          FROM app.ops_invitations i WHERE i.email IS NOT NULL AND i.state<>'accepted'
        ) entries WHERE ($1::timestamptz IS NULL OR (created_at,id)<($1::timestamptz,$2::uuid)) ORDER BY created_at DESC,id DESC LIMIT $3`,
            [after?.time ?? null, after?.id ?? null, limit + 1],
          )
        ).rows;
        const page = rows.slice(0, limit),
          last = page.at(-1);
        await c.query('COMMIT');
        return {
          status: 200,
          headers: {},
          body: {
            data: page.map((r) => ({
              id: r.id,
              name: r.name ?? 'Operator',
              email: r.email,
              kind: r.kind,
              state: r.state,
              isSuperadmin: r.is_superadmin,
              expiresAt: r.expires_at?.toISOString() ?? null,
              emailState: r.email_state,
            })),
            page: {
              nextCursor:
                rows.length > limit && last
                  ? this.cursor.encode(last.cursor_time, last.id, context, new Date())
                  : null,
            },
          },
        };
      }
      if (!key || key.length > 128) fail(400, 'idempotency_key_required', 'Supply a command key.');
      if (
        name !== 'inviteOperator' &&
        (!target || !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(target))
      )
        fail(400, 'invalid_request', 'Invalid account or invitation identifier.');
      target = target?.toLowerCase();
      const reason = requireReason(body);
      const keyHash = hash(JSON.stringify([actor.userId, name, target, key]));
      const inputHash = hash(JSON.stringify(body ?? {}));
      const prior = (
        await c.query('SELECT result_id,input_hash FROM app.ops_team_commands WHERE key_hash=$1', [
          keyHash,
        ])
      ).rows[0];
      if (prior) {
        if (prior.input_hash !== inputHash)
          fail(409, 'idempotency_conflict', 'This key was used for different input.');
        await c.query('COMMIT');
        return { status: 200, headers: {}, body: { data: { id: prior.result_id } } };
      }
      await requireRecentPasskey(c, actor);
      let resultId = target;
      if (name === 'inviteOperator' || name === 'resendOperatorInvitation') {
        if (!this.options.email || !this.options.origin)
          fail(503, 'email_unavailable', 'Invitation email is not configured.');
        const token = randomBytes(32).toString('base64url');
        let invite;
        if (name === 'inviteOperator') {
          const email = String(body.email).trim().toLowerCase();
          if (!body.name.trim()) fail(400, 'invalid_request', 'Supply the operator name.');
          const existing = (
            await c.query('SELECT 1 FROM app.users WHERE lower(email)=$1 AND deleted_at IS NULL', [
              email,
            ])
          ).rowCount;
          if (existing)
            fail(
              409,
              'operator_account_conflict',
              'This address already belongs to a Trotxi account. Invite a separate address for Operations.',
            );
          if (
            (
              await c.query(
                "SELECT 1 FROM app.ops_invitations WHERE email=$1 AND state IN ('pending','claimed')",
                [email],
              )
            ).rowCount
          )
            fail(409, 'invitation_exists', 'Resend or cancel the existing invitation.');
          invite = (
            await c.query(
              "INSERT INTO app.ops_invitations(email,name,token_hash,inviter_id,expires_at) VALUES ($1,$2,$3,$4,clock_timestamp()+interval '48 hours') RETURNING *",
              [email, body.name.trim(), hash(token), actor.userId],
            )
          ).rows[0];
        } else {
          invite = (
            await c.query(
              "UPDATE app.ops_invitations SET token_hash=$2,version=version+1,inviter_id=$3,expires_at=clock_timestamp()+interval '48 hours' WHERE id=$1 AND state='pending' RETURNING *",
              [target, hash(token), actor.userId],
            )
          ).rows[0];
          if (!invite)
            fail(
              409,
              'invitation_not_pending',
              'Only an unclaimed invitation can be resent. Cancel incomplete setup before re-inviting.',
            );
        }
        resultId = invite.id;
        mailId = await this.options.email.queueInvitation(c, {
          ownerId: actor.userId,
          id: invite.id,
          version: invite.version,
          email: invite.email,
          name: invite.name,
          token,
          expiresAt: invite.expires_at,
          origin: this.options.origin,
        });
      } else if (name === 'cancelOperatorInvitation') {
        const invite = (
          await c.query('SELECT * FROM app.ops_invitations WHERE id=$1 FOR UPDATE', [target])
        ).rows[0];
        if (!invite || !['pending', 'claimed'].includes(invite.state))
          fail(409, 'invitation_not_pending', 'This invitation cannot be cancelled.');
        if (invite.user_id) {
          if (!this.options.eraseOperator)
            fail(
              503,
              'account_erasure_unavailable',
              'Account deletion is temporarily unavailable.',
            );
          await this.options.eraseOperator(c, actor, invite.user_id);
        }
        await c.query(
          "UPDATE app.ops_invitations SET state='cancelled',token_hash=NULL,email=NULL,name=NULL WHERE id=$1",
          [target],
        );
      } else {
        if (target === actor.userId)
          fail(403, 'self_access_change', 'Another superadmin must change your access.');
        if (body.action === 'delete') {
          if (!this.options.eraseOperator)
            fail(
              503,
              'account_erasure_unavailable',
              'Account deletion is temporarily unavailable.',
            );
          await this.options.eraseOperator(c, actor, target!);
        } else {
          const user = (
            await c.query(
              "SELECT * FROM app.users WHERE id=$1 AND role='admin' AND deleted_at IS NULL AND NOT ops_invite_pending FOR UPDATE",
              [target],
            )
          ).rows[0];
          if (!user) fail(404, 'not_found', 'Operator not found.');
          if (!['make_superadmin', 'make_admin'].includes(body.action))
            fail(400, 'invalid_request', 'Unsupported access change.');
          await c.query('UPDATE app.users SET is_superadmin=$2 WHERE id=$1', [
            target,
            body.action === 'make_superadmin',
          ]);
          await c.query(
            'UPDATE app.auth_sessions SET revoked_at=COALESCE(revoked_at,clock_timestamp()) WHERE user_id=$1',
            [target],
          );
        }
      }
      await c.query(
        'INSERT INTO app.ops_team_commands(actor_user_id,key_hash,input_hash,result_id) VALUES ($1,$2,$3,$4)',
        [actor.userId, keyHash, inputHash, resultId],
      );
      await c.query(
        'INSERT INTO app.ops_team_events(actor_user_id,target_id,action,reason) VALUES ($1,$2,$3,$4)',
        [actor.userId, resultId, name === 'updateOperatorAccess' ? body.action : name, reason],
      );
      await c.query('COMMIT');
      if (mailId) await this.options.email!.sendQueued(mailId).catch(() => undefined);
      return { status: 200, headers: {}, body: { data: { id: resultId } } };
    } catch (e) {
      await c.query('ROLLBACK');
      throw mapDatabaseError(e);
    } finally {
      c.release();
    }
  }
}
