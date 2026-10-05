import { randomUUID } from 'node:crypto';
import type { PoolClient } from 'pg';
import type { Actor, Body, Outcome } from '../transport/service.js';
import { canonical } from '../transport/service.js';
import { fail } from '../transport/errors.js';
import { digest, id, ops, MembershipCore, type MembershipOperation } from './core.js';
import { mutateCommuteRequest } from './commute-requests.js';
import { mutateRestriction } from './restrictions.js';
import { getReservation, reserve, runReservationBatch } from './reservations.js';
import {
  getPersonalPause,
  insertPersonalPause,
  personalPauseView,
  previewPersonalPause,
  resumeDuePersonalPauses,
  resumePersonalPause,
} from './personal-pauses.js';
import { membership } from './coverage.js';
import { listMembership } from './lists.js';

export { membershipOperations, type MembershipOperation, type MembershipOptions } from './core.js';

// The membership API surface. Each sub-domain lives in its own module beside
// this one; this class keeps the shared command envelope (authorization,
// idempotency receipts, events) and routes each operation to its module.
export class MembershipService extends MembershipCore {
  private async render(c: PoolClient, op: string, resource: string, admin: boolean) {
    if (op === 'createPersonalPause' || op === 'resumePersonalPause')
      return personalPauseView(this, c, resource);
    if (op.includes('CommuteSlot'))
      return this.slotView(
        c,
        (await c.query('SELECT * FROM app.commute_slots WHERE id=$1', [resource])).rows[0],
      );
    if (op.includes('Restriction'))
      return this.restrictionView(
        (await c.query('SELECT * FROM app.account_restrictions WHERE id=$1', [resource])).rows[0],
      );
    if (op === 'decideReservation')
      return {
        reservation: this.reservationView(
          (await c.query('SELECT * FROM app.reservations WHERE id=$1', [resource])).rows[0],
        ),
        pass: null,
      };
    return this.requestView(
      c,
      (await c.query('SELECT * FROM app.commute_requests WHERE id=$1', [resource])).rows[0],
      admin,
    );
  }
  private async commandOutcome(c: PoolClient, op: string, resource: string): Promise<Outcome> {
    // Replay renders current state, not a retained snapshot of erasable notes.
    // Its HTTP status and current edit token still obey the original contract.
    const data = await this.render(c, op, resource, ops(op));
    return {
      status: op.startsWith('create') ? 201 : 200,
      body: { data },
      headers: 'editToken' in data ? { ETag: String(data.editToken) } : {},
    } as Outcome;
  }
  async command(
    actor: Actor,
    op: MembershipOperation,
    target: string | undefined,
    input: Body,
    key: string,
    match?: string,
    parentUserId?: string,
  ): Promise<Outcome> {
    if (!key || key.length > 128) fail(400, 'idempotency_key_required', 'Supply a request key.');
    // Normalize identifier fields only; UUID-looking text in a rider's note
    // is still their text, not an identifier we are entitled to rewrite.
    const normalize = (value: Body[string], key = ''): Body[string] => {
      if (Array.isArray(value)) return value.map((v) => normalize(v));
      if (value !== null && typeof value === 'object')
        return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, normalize(v, k)]));
      return typeof value === 'string' && (key === 'id' || key.endsWith('Id')) ? id(value) : value;
    };
    const normalized = normalize(input) as Body;
    const scope = target ? id(target) : actor.userId.toLowerCase();
    return this.tx(async (c) => {
      // Every command authorizes exactly once before target discovery. Rider
      // commands first lock only their authenticated own user, preserving the
      // financial/auth lock order without conditioning authorization on a
      // caller-supplied target or whether its database row exists.
      if (!ops(op)) await this.lockUser(c, actor.userId);
      await this.authorize(c, actor, op);
      // Discover the subject without exposing it, then re-read under rider lock.
      let userId = actor.userId;
      if (op === 'decideCommuteRequest')
        userId = (await c.query('SELECT user_id FROM app.commute_requests WHERE id=$1', [scope]))
          .rows[0]?.user_id;
      if (op === 'createAccountRestriction') userId = scope;
      if (op === 'releaseAccountRestriction')
        userId = (
          await c.query('SELECT user_id FROM app.account_restrictions WHERE id=$1', [scope])
        ).rows[0]?.user_id;
      if (
        ['decideCommuteRequest', 'createAccountRestriction', 'releaseAccountRestriction'].includes(
          op,
        )
      ) {
        if (!userId) fail(404, 'not_found', 'Resource not found.');
        await this.lockUser(c, userId);
      }
      if (parentUserId && id(parentUserId) !== userId)
        fail(404, 'not_found', 'Restriction not found.');
      // Foreign rider resources are refused before receipt lookup or If-Match.
      if (
        (op === 'withdrawCommuteRequest' || op === 'resumePersonalPause') &&
        !(
          await c.query(
            `SELECT 1 FROM app.${op === 'resumePersonalPause' ? 'personal_pauses' : 'commute_requests'} WHERE id=$1 AND user_id=$2`,
            [scope, actor.userId],
          )
        ).rowCount
      )
        fail(404, 'not_found', 'Request not found.');
      await c.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
        JSON.stringify([actor.userId, op, scope, digest(key)]),
      ]);
      const hash = digest(canonical(normalized));
      const old = (
        await c.query(
          'SELECT * FROM app.membership_commands WHERE actor_user_id=$1 AND operation=$2 AND target=$3 AND key_hash=$4',
          [actor.userId, op, scope, digest(key)],
        )
      ).rows[0];
      if (old) {
        if (old.input_hash !== hash)
          fail(409, 'idempotency_conflict', 'This key was used for different input.');
        if (Date.now() - old.created_at.getTime() >= 7 * 86400000)
          fail(409, 'idempotency_expired', 'Use a new request key.');
        return this.commandOutcome(c, op, old.resource_id);
      }
      const resource = await this.mutate(c, actor, op, scope, normalized, match);
      const receipt = randomUUID();
      await c.query(
        'INSERT INTO app.membership_commands(id,actor_user_id,operation,target,key_hash,input_hash,resource_id) VALUES ($1,$2,$3,$4,$5,$6,$7)',
        [receipt, actor.userId, op, scope, digest(key), hash, resource],
      );
      await c.query(
        'INSERT INTO app.membership_events(command_id,actor_user_id,resource_id,action) VALUES ($1,$2,$3,$4)',
        [
          receipt,
          actor.userId,
          resource,
          op === 'decideCommuteRequest' ? String(input.action) : op,
        ],
      );
      return this.commandOutcome(c, op, resource);
    });
  }
  private async mutate(
    c: PoolClient,
    actor: Actor,
    op: MembershipOperation,
    target: string,
    input: Body,
    match?: string,
  ): Promise<string> {
    const now = this.now();
    if (op === 'createPersonalPause')
      return (await insertPersonalPause(this, c, actor.userId, input)).id;
    if (op === 'resumePersonalPause') return resumePersonalPause(this, c, actor, target, input);
    if (op === 'createAccountRestriction' || op === 'releaseAccountRestriction')
      return mutateRestriction(this, c, actor, op, target, input, match, now);
    if (op === 'decideReservation') return reserve(this, c, actor, input);
    return mutateCommuteRequest(this, c, actor, op, target, input, match, now);
  }
  maintenance(
    actor: Actor,
    op: 'runAskDispatch' | 'runReservationDefaults',
    input: { travelDate: string; direction: string; limit?: number; routeId?: string },
  ): Promise<Outcome> {
    return runReservationBatch(this, actor, op, input);
  }
  async read(
    actor: Actor,
    op: MembershipOperation,
    query: Record<string, string | undefined> = {},
    target?: string,
  ): Promise<Outcome> {
    return this.tx(async (c) => {
      if (!ops(op)) await this.lockUser(c, actor.userId);
      await this.authorize(c, actor, op);
      if (op === 'getPersonalPause') return getPersonalPause(this, c, actor);
      if (op === 'getMembership')
        return {
          status: 200,
          body: { data: await membership(this, c, actor.userId) },
          headers: {},
        } as Outcome;
      if (op === 'getReservation') return getReservation(this, c, actor, target);
      return listMembership(this, c, actor, op, query, target);
    });
  }
  previewPersonalPause(actor: Actor, input: Body): Promise<Outcome> {
    return previewPersonalPause(this, actor, input);
  }
  resumeDuePersonalPauses(actor: Actor, limit = 100): Promise<Outcome> {
    return resumeDuePersonalPauses(this, actor, limit);
  }
}
