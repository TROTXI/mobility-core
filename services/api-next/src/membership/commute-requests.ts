// Commute requests and the slots Ops offers against them.
import type { PoolClient } from 'pg';
import type { Actor, Body } from '../transport/service.js';
import { canonical } from '../transport/service.js';
import { fail } from '../transport/errors.js';
import type { PurchaseLeg } from '../payments/foundation.js';
import {
  date,
  dayString,
  id,
  type MembershipCore,
  type MembershipOperation,
  type Row,
} from './core.js';

export async function mutateCommuteRequest(
  m: MembershipCore,
  c: PoolClient,
  actor: Actor,
  op: MembershipOperation,
  target: string,
  input: Body,
  match: string | undefined,
  now: Date,
): Promise<string> {
  if (op === 'createCommuteRequest') {
    const b = await m.period(c, actor.userId);
    if (b.offer_terms)
      fail(
        409,
        'fresh_offer_required',
        'Request a new subscription offer to change a priced journey.',
      );
    if (b.effective_ends_at <= now || String(input.requestedDate) < date(now))
      fail(409, 'coverage_required', 'Choose a date within current service.');
    const selection = await m.selection(
      c,
      String(input.routeId),
      input.legs as unknown as PurchaseLeg[],
    );
    return (
      await c.query(
        'INSERT INTO app.commute_requests(user_id,membership_id,period_id,selection_id,requested_date,pause_consent,note) VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING id',
        [
          actor.userId,
          b.membership_id,
          b.id,
          selection,
          input.requestedDate,
          input.pauseIfWaitlisted ?? false,
          input.note ?? null,
        ],
      )
    ).rows[0].id;
  }
  if (op === 'createCommuteSlot') {
    const selection = await m.selection(
      c,
      String(input.routeId),
      input.legs as unknown as PurchaseLeg[],
    );
    return (
      await c.query(
        'INSERT INTO app.commute_slots(selection_id,available_from) VALUES ($1,$2) RETURNING id',
        [selection, input.availableFrom],
      )
    ).rows[0].id;
  }
  if (op === 'retireCommuteSlot') {
    const r = (await c.query('SELECT * FROM app.commute_slots WHERE id=$1 FOR UPDATE', [target]))
      .rows[0];
    if (!r) fail(404, 'not_found', 'Slot not found.');
    m.match(r, match);
    if (r.state !== 'available') fail(409, 'slot_in_use', 'Only an available slot can be retired.');
    await c.query("UPDATE app.commute_slots SET state='retired' WHERE id=$1", [target]);
    return target;
  }
  const r = (await c.query('SELECT * FROM app.commute_requests WHERE id=$1 FOR UPDATE', [target]))
    .rows[0];
  if (!r) fail(404, 'not_found', 'Request not found.');
  if (op === 'decideCommuteRequest') m.match(r, match);
  if (!['submitted', 'waitlisted', 'approved'].includes(r.status))
    fail(409, 'request_terminal', 'This request is already closed.');
  const action = op === 'withdrawCommuteRequest' ? 'cancel' : String(input.action);
  if (
    ['approve', 'apply', 'pause'].includes(action) &&
    (await c.query('SELECT app.has_pending_renewal($1) AS blocked', [r.period_id])).rows[0].blocked
  )
    fail(409, 'renewal_dates_locked', 'Resolve the upcoming renewal before changing the commute.');
  const b = (
    await c.query(
      "SELECT b.*,p.fare_pesewas,to_jsonb(p)->'offer_terms' AS offer_terms FROM app.billing_periods b JOIN app.purchases p ON p.id=b.purchase_id WHERE b.id=$1 FOR UPDATE OF b",
      [r.period_id],
    )
  ).rows[0];
  if (b.state !== 'open') fail(409, 'coverage_required', 'This coverage has ended.');
  const pause = (
    await c.query(
      'SELECT * FROM app.membership_pauses WHERE request_id=$1 AND ended_at IS NULL FOR UPDATE',
      [r.id],
    )
  ).rows[0];
  if (['cancel', 'reject', 'waitlist'].includes(action)) {
    if (pause)
      fail(409, 'resume_required', 'Resume coverage before closing or changing the request.');
    if (r.slot_id)
      await c.query("UPDATE app.commute_slots SET state='available' WHERE id=$1", [r.slot_id]);
    await c.query(
      'UPDATE app.commute_requests SET status=$2,slot_id=NULL,effective_date=NULL,decision_note=$3,decided_by=$4 WHERE id=$1',
      [
        r.id,
        action === 'waitlist' ? 'waitlisted' : action === 'reject' ? 'rejected' : 'cancelled',
        input.note ?? null,
        actor.userId,
      ],
    );
    return r.id;
  }
  if (action === 'pause') {
    if (r.status !== 'waitlisted' || !r.pause_consent || pause || b.effective_ends_at <= now)
      fail(409, 'pause_not_allowed', 'Pause requires consent and current waitlisted coverage.');
    if ((await m.blocks(c, r.user_id, b.id)).length)
      fail(409, 'membership_blocked', 'Resolve existing restrictions first.');
    await m.cancelFuture(c, b.id, null);
    await c.query(
      'INSERT INTO app.membership_pauses(request_id,period_id,user_id,started_at,ends_before) VALUES ($1,$2,$3,$4,$5)',
      [r.id, b.id, r.user_id, now, b.effective_ends_at],
    );
  } else if (action === 'resume') {
    await resume(m, c, r, b, pause, now);
  } else if (action === 'approve') {
    if (r.status === 'approved') fail(409, 'already_approved', 'Request already holds a slot.');
    const slot = (
      await c.query('SELECT * FROM app.commute_slots WHERE id=$1 FOR UPDATE', [id(input.slotId)])
    ).rows[0];
    const effective = String(input.effectiveDate);
    const ends = pause
      ? new Date(pause.ends_before.getTime() + now.getTime() - pause.started_at.getTime())
      : b.effective_ends_at;
    if (
      !slot ||
      slot.state !== 'available' ||
      dayString(slot.available_from) > effective ||
      dayString(r.requested_date) > effective ||
      effective < date(now) ||
      effective >= date(ends)
    )
      fail(409, 'slot_unavailable', 'Select an available slot and valid effective date.');
    const offered = await m.selectionView(c, slot.selection_id),
      requested = await m.selectionView(c, r.selection_id);
    if (
      offered.routeId !== requested.routeId ||
      canonical(offered.legs) !== canonical(requested.legs)
    )
      fail(409, 'slot_mismatch', 'The slot must match both requested legs.');
    await c.query("UPDATE app.commute_slots SET state='held' WHERE id=$1", [slot.id]);
    await c.query(
      "UPDATE app.commute_requests SET status='approved',slot_id=$2,effective_date=$3,decided_by=$4 WHERE id=$1",
      [r.id, slot.id, effective, actor.userId],
    );
  } else if (action === 'apply') {
    if (r.status !== 'approved' || dayString(r.effective_date) > date(now))
      fail(409, 'application_not_due', 'Approved effective date has not arrived.');
    if (b.offer_terms)
      fail(
        409,
        'fresh_offer_required',
        'Changing a priced journey requires a new subscription offer.',
      );
    const fare = await m.options.fareForSelection?.(c, r.selection_id);
    if (!Number.isSafeInteger(fare) || fare !== b.fare_pesewas)
      fail(409, 'fare_review_required', 'Transfer pricing requires review.');
    if (pause) await resume(m, c, r, b, pause, now);
    else if (b.effective_ends_at <= now || (await m.blocks(c, r.user_id, b.id)).length)
      fail(409, 'membership_blocked', 'Current usable coverage is required.');
    await m.cancelFuture(c, b.id, date(now));
    // Never backdate a commute over already-operated service. Approved date is
    // the earliest application date; actual assignment starts on application.
    await c.query(
      "UPDATE app.commute_slots SET state='available' WHERE id IN (SELECT r.slot_id FROM app.commute_requests r JOIN app.commute_assignments a ON a.request_id=r.id WHERE a.period_id=$1 AND a.effective_to IS NULL)",
      [b.id],
    );
    await c.query(
      'UPDATE app.commute_assignments SET effective_to=greatest(effective_from,$2::date) WHERE period_id=$1 AND effective_to IS NULL',
      [b.id, date(now)],
    );
    await c.query(
      'INSERT INTO app.commute_assignments(user_id,membership_id,period_id,selection_id,request_id,effective_from) VALUES ($1,$2,$3,$4,$5,$6)',
      [r.user_id, b.membership_id, b.id, r.selection_id, r.id, date(now)],
    );
    await c.query("UPDATE app.commute_requests SET status='applied' WHERE id=$1", [r.id]);
    await c.query("UPDATE app.commute_slots SET state='assigned' WHERE id=$1", [r.slot_id]);
  } else fail(400, 'invalid_action', 'Unsupported request action.');
  await c.query('UPDATE app.commute_requests SET decision_note=$2,decided_by=$3 WHERE id=$1', [
    r.id,
    input.note,
    actor.userId,
  ]);
  return r.id;
}
export async function resume(
  m: MembershipCore,
  c: PoolClient,
  r: Row,
  b: Row,
  pause: Row | undefined,
  now: Date,
) {
  if (!pause) fail(409, 'not_paused', 'Coverage is not paused.');
  if ((await m.blocks(c, r.user_id, b.id)).some((x) => x.kind !== 'paused'))
    fail(409, 'membership_blocked', 'Resolve the independent access block first.');
  const end = new Date(pause.ends_before.getTime() + now.getTime() - pause.started_at.getTime());
  await c.query('UPDATE app.billing_periods SET effective_ends_at=$2 WHERE id=$1', [b.id, end]);
  await c.query(
    "UPDATE app.membership_pauses SET ended_at=$2,ends_after=$3,end_reason='resumed' WHERE id=$1",
    [pause.id, now, end],
  );
}
