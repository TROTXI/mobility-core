import type { Pool, PoolClient } from 'pg';
import type { CommuteSubmit, CommuteDecision, CommuteSlotInput } from './commute.schema';
import { commuteResponse, commuteSlotResponse, commuteEvent } from './commute.schema';

export class CommuteConflict extends Error {
  constructor(
    readonly code: string,
    message: string,
    readonly httpStatus: 403 | 404 | 409 = 409,
  ) {
    super(message);
  }
}
interface Membership {
  id: string;
  status: string;
  current_period_id: string;
  period_end: Date | null;
  fare_pesewas: number | null;
}
interface Period {
  id: string;
  status: string;
}
const camel = (row: Record<string, unknown>) =>
  Object.fromEntries(
    Object.entries(row).map(([key, value]) => [
      key.replace(/_([a-z])/g, (_, letter: string) => letter.toUpperCase()),
      value instanceof Date ? value.toISOString() : value,
    ]),
  );
const requestSelect = `SELECT q.*, q.requested_date::text AS requested_date, q.effective_date::text AS effective_date,
  u.display_name AS rider_name,r.name AS route_name,old.name AS from_route_name,
  pickup.name AS pickup_stop_name,dropoff.name AS dropoff_stop_name,
  s.status AS subscription_status,s.period_end,
  EXISTS(SELECT 1 FROM subscription_pauses p WHERE p.request_id=q.id AND p.resumed_at IS NULL) AS paused
  FROM commute_requests q JOIN users u ON u.id=q.user_id AND u.deleted_at IS NULL
  JOIN subscriptions s ON s.id=q.subscription_id JOIN routes r ON r.id=q.route_id
  LEFT JOIN routes old ON old.id=q.from_route_id
  JOIN stops pickup ON pickup.id=q.pickup_stop_id JOIN stops dropoff ON dropoff.id=q.dropoff_stop_id`;

export class PgCommuteService {
  constructor(private readonly pool: Pool) {}
  private async admin(actor: string) {
    const { rowCount } = await this.pool.query(
      `SELECT id FROM users WHERE id=$1 AND role='admin' AND deleted_at IS NULL`,
      [actor],
    );
    if (!rowCount)
      throw new CommuteConflict('forbidden', 'An active operations account is required', 403);
  }
  async list(userId?: string, options: { status?: string; limit?: number; offset?: number } = {}) {
    const { rows } = await this.pool.query(
      `${requestSelect} WHERE ($1::uuid IS NULL OR q.user_id=$1)
      AND ($2::text IS NULL OR q.status=$2) ORDER BY q.created_at DESC,q.id DESC LIMIT $3 OFFSET $4`,
      [userId ?? null, options.status ?? null, options.limit ?? 200, options.offset ?? 0],
    );
    return rows.map((row) => commuteResponse.parse(camel(row)));
  }
  async slots() {
    const { rows } = await this.pool.query(
      `SELECT c.id,c.route_id,r.name AS route_name,c.morning_departure,c.evening_return,c.available_from::text,c.status,c.request_id,c.subscription_id FROM commute_slots c JOIN routes r ON r.id=c.route_id ORDER BY c.created_at DESC LIMIT 200`,
    );
    return rows.map((row) => commuteSlotResponse.parse(camel(row)));
  }
  async createSlot(actor: string, input: CommuteSlotInput) {
    await this.admin(actor);
    const { rows } = await this.pool.query(
      `INSERT INTO commute_slots(route_id,morning_departure,evening_return,available_from,created_by) VALUES($1,$2,$3,$4,$5) RETURNING id`,
      [input.routeId, input.morningDeparture, input.eveningReturn, input.availableFrom, actor],
    );
    return rows[0] as { id: string };
  }
  async retireSlot(id: string, actor: string) {
    await this.admin(actor);
    const retired = await this.pool.query(
      `UPDATE commute_slots SET status='retired' WHERE id=$1 AND status='available' RETURNING id`,
      [id],
    );
    if (!retired.rowCount)
      throw new CommuteConflict('slot_in_use', 'Only an available slot can be retired');
    return { id };
  }
  async events(id: string) {
    const { rows } = await this.pool.query(
      `SELECT id,actor_id,action,note,created_at FROM commute_request_events WHERE request_id=$1 ORDER BY created_at,id`,
      [id],
    );
    return rows.map((row) => commuteEvent.parse(camel(row)));
  }
  private async tx<T>(userId: string, fn: (c: PoolClient) => Promise<T>): Promise<T> {
    const c = await this.pool.connect();
    try {
      await c.query('BEGIN');
      await c.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [userId]);
      const result = await fn(c);
      await c.query('COMMIT');
      return result;
    } catch (error) {
      await c.query('ROLLBACK');
      throw error;
    } finally {
      c.release();
    }
  }
  private async event(c: PoolClient, id: string, actor: string, action: string, note: string) {
    await c.query(
      'INSERT INTO commute_request_events(request_id,actor_id,action,note) VALUES($1,$2,$3,$4)',
      [id, actor, action, note],
    );
  }
  private async validateStops(
    c: PoolClient,
    input: { routeId: string; pickupStopId: string; dropoffStopId: string },
  ) {
    const { rows } = await c.query(
      `SELECT a.seq AS pickup,b.seq AS dropoff FROM route_stops a JOIN route_stops b ON b.route_id=a.route_id WHERE a.route_id=$1 AND a.stop_id=$2 AND b.stop_id=$3`,
      [input.routeId, input.pickupStopId, input.dropoffStopId],
    );
    if (!rows[0] || rows[0].pickup >= rows[0].dropoff)
      throw new CommuteConflict(
        'invalid_stops',
        'Choose ordered pickup and destination stops on the requested route',
      );
  }
  async submit(userId: string, input: CommuteSubmit) {
    return this.tx(userId, async (c) => {
      const today = new Date().toISOString().slice(0, 10);
      if (input.requestedDate < today)
        throw new CommuteConflict('past_date', 'Choose today or a future date');
      const { rows } = await c.query(
        `SELECT s.* FROM subscriptions s JOIN users u ON u.id=s.user_id AND u.deleted_at IS NULL WHERE s.user_id=$1 AND s.status='active' FOR UPDATE OF s`,
        [userId],
      );
      const sub = rows[0];
      if (!sub?.current_period_id || !sub.period_end || sub.period_end <= new Date())
        throw new CommuteConflict(
          'membership_required',
          'An active, unexpired, period-linked subscription is required',
        );
      const open = await c.query(
        `SELECT id FROM commute_requests WHERE user_id=$1 AND status IN ('pending','waitlisted','approved')`,
        [userId],
      );
      if (open.rowCount)
        throw new CommuteConflict(
          'request_exists',
          'You already have a request awaiting a decision',
        );
      await this.validateStops(c, input);
      const inserted = await c.query(
        `INSERT INTO commute_requests(user_id,subscription_id,period_id,from_route_id,route_id,pickup_stop_id,dropoff_stop_id,morning_departure,evening_return,requested_date,pause_if_waitlisted,note) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12) RETURNING id`,
        [
          userId,
          sub.id,
          sub.current_period_id,
          sub.route_id,
          input.routeId,
          input.pickupStopId,
          input.dropoffStopId,
          input.morningDeparture,
          input.eveningReturn,
          input.requestedDate,
          input.pauseIfWaitlisted,
          input.note,
        ],
      );
      const id = inserted.rows[0]!.id as string;
      await this.event(c, id, userId, 'submitted', input.note);
      return { id };
    });
  }
  private async settleFuture(c: PoolClient, userId: string) {
    // Stabilize scheduled/active state against a driver starting the trip.
    await c.query(
      `SELECT t.id FROM trips t WHERE EXISTS (
      SELECT 1 FROM reservations r WHERE r.trip_id=t.id AND r.user_id=$1
        AND r.status IN ('pending','reserved','boarded','no_show')
    ) ORDER BY t.id FOR UPDATE`,
      [userId],
    );
    const busy = await c.query(
      `SELECT r.id FROM reservations r LEFT JOIN trips t ON t.id=r.trip_id WHERE r.user_id=$1 AND ((r.status IN ('pending','reserved') AND (t.id IS NULL OR t.scheduled_at<=now())) OR (r.status IN ('reserved','boarded','no_show') AND t.status='active')) LIMIT 1`,
      [userId],
    );
    if (busy.rowCount)
      throw new CommuteConflict(
        'unsettled_trip',
        'Finish or settle existing trips before pausing or applying a change',
      );
    await c.query(
      `UPDATE reservations r SET status='operator_cancelled',updated_at=now() FROM trips t WHERE r.user_id=$1 AND r.trip_id=t.id AND r.status IN ('pending','reserved') AND t.status='scheduled' AND t.scheduled_at>now()`,
      [userId],
    );
  }
  private async resume(c: PoolClient, sub: Membership, period: Period) {
    const paused = await c.query(
      `SELECT * FROM subscription_pauses WHERE subscription_id=$1 AND resumed_at IS NULL FOR UPDATE`,
      [sub.id],
    );
    if (!paused.rows[0]) return;
    if (sub.status !== 'active' || period.status !== 'open')
      throw new CommuteConflict(
        'membership_restricted',
        'Resolve payment or subscription restrictions before resuming',
      );
    const pause = paused.rows[0];
    const now = new Date();
    const end = new Date(
      pause.original_period_end.getTime() + Math.max(0, now.getTime() - pause.started_at.getTime()),
    );
    await c.query(`UPDATE subscriptions SET period_end=$1 WHERE id=$2`, [end, sub.id]);
    await c.query(`UPDATE subscription_periods SET period_end=$1 WHERE id=$2`, [end, period.id]);
    await c.query(
      `UPDATE subscription_pauses SET resumed_at=$1,extended_period_end=$2 WHERE id=$3`,
      [now, end, pause.id],
    );
  }
  async decide(id: string, actor: string, input: CommuteDecision, ownerOnly = false) {
    if (!ownerOnly) await this.admin(actor);
    const found = await this.pool.query('SELECT user_id FROM commute_requests WHERE id=$1', [id]);
    const owner = found.rows[0]?.user_id as string | undefined;
    if (!owner || (ownerOnly && owner !== actor))
      throw new CommuteConflict('not_found', 'Request not found', 404);
    if (ownerOnly && input.action !== 'cancel')
      throw new CommuteConflict('forbidden', 'Only operations can decide requests', 403);
    return this.tx(owner, async (c) => {
      const { rows } = await c.query(
        'SELECT *,requested_date::text,effective_date::text FROM commute_requests WHERE id=$1 FOR UPDATE',
        [id],
      );
      const q = rows[0]!;
      const subscriptions = await c.query('SELECT * FROM subscriptions WHERE id=$1 FOR UPDATE', [
        q.subscription_id,
      ]);
      const sub = subscriptions.rows[0]!;
      const periods = await c.query('SELECT * FROM subscription_periods WHERE id=$1 FOR UPDATE', [
        sub.current_period_id,
      ]);
      const period = periods.rows[0];
      const pause = await c.query(
        'SELECT id,request_id FROM subscription_pauses WHERE subscription_id=$1 AND resumed_at IS NULL',
        [sub.id],
      );
      const action = input.action;
      if (
        (action === 'apply' && q.status === 'applied') ||
        (action === 'cancel' && q.status === 'cancelled') ||
        (action === 'reject' && q.status === 'rejected')
      )
        return { id, status: q.status };
      if (action === 'resume') {
        if (!pause.rowCount) return { id, status: q.status };
        if (pause.rows[0].request_id !== id)
          throw new CommuteConflict(
            'pause_mismatch',
            'Resume using the request that paused this subscription',
          );
        if (!period) throw new CommuteConflict('period_missing', 'Current period is missing');
        await this.resume(c, sub, period);
        await c.query(`UPDATE commute_requests SET decision_note=$2,updated_at=now() WHERE id=$1`, [
          id,
          input.note,
        ]);
        await this.event(c, id, actor, 'resumed', input.note);
        return { id, status: q.status };
      }
      if (!['pending', 'waitlisted', 'approved'].includes(q.status))
        throw new CommuteConflict('request_closed', 'This request is already closed');
      if (action === 'cancel' || action === 'reject') {
        if (pause.rowCount)
          throw new CommuteConflict(
            'resume_required',
            'Resume the subscription before closing its paused request',
          );
        await c.query(
          `UPDATE commute_slots SET status='available',request_id=NULL WHERE request_id=$1 AND status='held'`,
          [id],
        );
        const status = action === 'cancel' ? 'cancelled' : 'rejected';
        await c.query(
          `UPDATE commute_requests SET status=$2,decision_note=$3,updated_at=now() WHERE id=$1`,
          [id, status, input.note],
        );
        await this.event(c, id, actor, action, input.note);
        return { id, status };
      }
      if (
        !period ||
        sub.current_period_id !== q.period_id ||
        sub.status !== 'active' ||
        period.status !== 'open'
      )
        throw new CommuteConflict(
          'membership_changed',
          'The membership changed or is restricted; operations must review it before proceeding',
        );
      if (!pause.rowCount && (!sub.period_end || sub.period_end <= new Date()))
        throw new CommuteConflict('period_ended', 'The current subscription period has ended');
      if (action === 'waitlist') {
        if (q.status === 'approved')
          throw new CommuteConflict(
            'already_approved',
            'Reject the approval to release its slot first',
          );
        await c.query(
          `UPDATE commute_requests SET status='waitlisted',decision_note=$2,updated_at=now() WHERE id=$1`,
          [id, input.note],
        );
      } else if (action === 'pause') {
        if (q.status !== 'waitlisted' || !q.pause_if_waitlisted)
          throw new CommuteConflict(
            'pause_not_authorized',
            'Pausing requires a waitlisted request and the rider’s explicit consent',
          );
        if (pause.rowCount) return { id, status: q.status };
        await this.settleFuture(c, owner);
        await c.query(
          `INSERT INTO subscription_pauses(subscription_id,period_id,request_id,original_period_end) VALUES($1,$2,$3,$4)`,
          [sub.id, period.id, id, sub.period_end],
        );
      } else if (action === 'approve') {
        if (q.status === 'approved')
          throw new CommuteConflict('already_approved', 'This request already holds a slot');
        const effective = input.effectiveDate;
        if (
          !input.slotId ||
          !effective ||
          effective < q.requested_date ||
          effective < new Date().toISOString().slice(0, 10)
        )
          throw new CommuteConflict(
            'invalid_approval',
            'Choose an available slot and an effective date no earlier than the requested date or today',
          );
        await this.validateStops(c, {
          routeId: q.route_id,
          pickupStopId: q.pickup_stop_id,
          dropoffStopId: q.dropoff_stop_id,
        });
        await this.sameFare(c, sub, q.route_id);
        const slot = await c.query(
          `UPDATE commute_slots SET status='held',request_id=$1 WHERE id=$2 AND status='available' AND route_id=$3 AND morning_departure=$4 AND evening_return=$5 AND available_from<=$6 RETURNING id`,
          [id, input.slotId, q.route_id, q.morning_departure, q.evening_return, effective],
        );
        if (!slot.rowCount)
          throw new CommuteConflict(
            'slot_unavailable',
            'The selected recurring slot is no longer available or does not match',
          );
        await c.query(
          `UPDATE commute_requests SET status='approved',effective_date=$2,decision_note=$3,updated_at=now() WHERE id=$1`,
          [id, effective, input.note],
        );
      } else if (action === 'apply') {
        if (q.status !== 'approved' || q.effective_date > new Date().toISOString().slice(0, 10))
          throw new CommuteConflict(
            'not_effective',
            'Only an approved request whose effective date has arrived can be applied',
          );
        await this.sameFare(c, sub, q.route_id);
        await this.validateStops(c, {
          routeId: q.route_id,
          pickupStopId: q.pickup_stop_id,
          dropoffStopId: q.dropoff_stop_id,
        });
        await this.settleFuture(c, owner);
        await this.resume(c, sub, period);
        await c.query(
          `UPDATE commute_slots SET status='available',subscription_id=NULL,request_id=NULL WHERE subscription_id=$1 AND status='allocated'`,
          [sub.id],
        );
        const claimed = await c.query(
          `UPDATE commute_slots SET status='allocated',subscription_id=$2 WHERE request_id=$1 AND status='held' RETURNING id`,
          [id, sub.id],
        );
        if (!claimed.rowCount)
          throw new CommuteConflict(
            'slot_unavailable',
            'Approval no longer holds a recurring slot',
          );
        await c.query(
          `UPDATE subscriptions SET route_id=$2,pickup_stop_id=$3,dropoff_stop_id=$4 WHERE id=$1`,
          [sub.id, q.route_id, q.pickup_stop_id, q.dropoff_stop_id],
        );
        await c.query(
          `UPDATE commute_requests SET status='applied',decision_note=$2,updated_at=now() WHERE id=$1`,
          [id, input.note],
        );
      }
      await c.query(`UPDATE commute_requests SET decision_note=$2,updated_at=now() WHERE id=$1`, [
        id,
        input.note,
      ]);
      await this.event(c, id, actor, action, input.note);
      return { id };
    });
  }
  private async sameFare(c: PoolClient, sub: Membership, routeId: string) {
    const fare = await c.query(
      `SELECT fare_pesewas FROM corridor_fares WHERE route_id=$1 AND effective_from<=now() AND effective_to IS NULL ORDER BY effective_from DESC LIMIT 1`,
      [routeId],
    );
    if (!sub.fare_pesewas || fare.rows[0]?.fare_pesewas !== sub.fare_pesewas)
      throw new CommuteConflict(
        'fare_review_required',
        'Different or unavailable fare: transfer is blocked until a fare-adjustment policy is implemented',
      );
  }
}
