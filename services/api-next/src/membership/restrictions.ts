// Ops restrictions on a rider account.
import type { PoolClient } from 'pg';
import type { Actor, Body } from '../transport/service.js';
import { fail } from '../transport/errors.js';
import type { MembershipCore, MembershipOperation } from './core.js';
import type { RestrictionRow } from './rows.js';

export async function mutateRestriction(
  m: MembershipCore,
  c: PoolClient,
  actor: Actor,
  op: MembershipOperation,
  target: string,
  input: Body,
  match: string | undefined,
  now: Date,
): Promise<string> {
  if (op === 'createAccountRestriction')
    return (
      await c.query(
        'INSERT INTO app.account_restrictions(user_id,actor_user_id,reason,review_at) VALUES ($1,$2,$3,$4) RETURNING id',
        [target, actor.userId, input.reason, input.reviewAt],
      )
    ).rows[0].id;
  if (op === 'releaseAccountRestriction') {
    const r = (
      await c.query<RestrictionRow>(
        'SELECT * FROM app.account_restrictions WHERE id=$1 FOR UPDATE',
        [target],
      )
    ).rows[0];
    if (!r) fail(404, 'not_found', 'Restriction not found.');
    m.match(r, match);
    if (r.released_at) fail(409, 'restriction_released', 'Restriction already released.');
    await c.query(
      'UPDATE app.account_restrictions SET released_at=$2,released_by=$3,release_reason=$4 WHERE id=$1',
      [target, now, actor.userId, input.reason],
    );
    return target;
  }
  fail(400, 'invalid_action', 'Unsupported restriction action.');
}
