import { createHash, randomUUID } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import type { Actor, Body, Outcome, ReservationChange } from '../transport/service.js';
import { canonical } from '../transport/service.js';
import { fail, mapDatabaseError, TransportError } from '../transport/errors.js';
import { cursorCodec } from '../transport/cursor.js';
import type { FinancialDependencies, PurchaseLeg } from '../payments/foundation.js';

export const membershipOperations = [
  'getPersonalPause',
  'previewPersonalPause',
  'createPersonalPause',
  'resumePersonalPause',
  'runPersonalPauseResumes',
  'getMembership',
  'listCommuteRequests',
  'createCommuteRequest',
  'withdrawCommuteRequest',
  'listOpsCommuteRequests',
  'decideCommuteRequest',
  'listCommuteEvents',
  'listCommuteSlots',
  'createCommuteSlot',
  'retireCommuteSlot',
  'listReservations',
  'decideReservation',
  'createAccountRestriction',
  'releaseAccountRestriction',
  'runAskDispatch',
  'runReservationDefaults',
] as const;
export type MembershipOperation = (typeof membershipOperations)[number];
export interface MembershipOptions {
  pool: Pool;
  authorizeSession: FinancialDependencies['authorizeSession'];
  cursorSecret: Buffer;
  // Must read authoritative pricing using THIS client, never an external call.
  // Until pricing is composed, application of a transfer fails closed.
  fareForSelection?: (c: PoolClient, selectionId: string) => Promise<number | null>;
  now?: () => Date;
}
type Row = Record<string, any>;
const digest = (s: string) => createHash('sha256').update(s).digest('hex');
const date = (d: Date) => d.toISOString().slice(0, 10); // Africa/Accra is UTC.
// pg parses DATE as local midnight; preserve its calendar fields on every host.
const dayString = (d: Date | string) =>
  d instanceof Date
    ? `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
    : d;
const iso = (d: Date) => d.toISOString();
const token = (r: Row) => `"membership:${r.id}:${r.version}"`;
const id = (value: unknown): string => {
  if (typeof value !== 'string' || !/^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i.test(value))
    fail(404, 'not_found', 'Resource not found.');
  return value.toLowerCase();
};
const audit = (r: Row) => ({
  createdAt: iso(r.created_at),
  updatedAt: iso(r.updated_at),
  version: r.version,
});
const ops = (op: string) =>
  [
    'listOpsCommuteRequests',
    'decideCommuteRequest',
    'listCommuteEvents',
    'listCommuteSlots',
    'createCommuteSlot',
    'retireCommuteSlot',
    'createAccountRestriction',
    'releaseAccountRestriction',
    'runAskDispatch',
    'runReservationDefaults',
    'runPersonalPauseResumes',
  ].includes(op);

export class MembershipService {
  private readonly cursors;
  constructor(private readonly options: MembershipOptions) {
    this.cursors = cursorCodec(options.cursorSecret);
  }
  private now() {
    return this.options.now?.() ?? new Date();
  }
  private async tx<T>(work: (c: PoolClient) => Promise<T>): Promise<T> {
    const c = await this.options.pool.connect();
    try {
      await c.query(
        "BEGIN; SET LOCAL TIME ZONE 'UTC'; SET LOCAL lock_timeout='3s'; SET LOCAL statement_timeout='10s'",
      );
      const out = await work(c);
      await c.query('COMMIT');
      return out;
    } catch (e) {
      await c.query('ROLLBACK');
      throw mapDatabaseError(e);
    } finally {
      c.release();
    }
  }
  private async authorize(c: PoolClient, actor: Actor, operation: string) {
    await this.options.authorizeSession(c, actor);
    const user = (
      await c.query('SELECT role FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR SHARE', [
        actor.userId,
      ])
    ).rows[0];
    if (!user) fail(401, 'unauthenticated', 'Account unavailable.');
    if (user.role !== (ops(operation) ? 'admin' : 'commuter'))
      fail(403, 'forbidden', 'This operation is not permitted.');
  }
  private async lockUser(c: PoolClient, userId: string) {
    if (
      !(
        await c.query(
          "SELECT id FROM app.users WHERE id=$1 AND deleted_at IS NULL AND role='commuter' FOR UPDATE",
          [userId],
        )
      ).rowCount
    )
      fail(404, 'not_found', 'Rider not found.');
  }
  private async period(c: PoolClient, userId: string) {
    await c.query('SELECT app.settle_personal_pauses($1)', [userId]);
    const b = (
      await c.query(
        "SELECT b.*,p.fare_pesewas FROM app.billing_periods b JOIN app.purchases p ON p.id=b.purchase_id WHERE b.user_id=$1 AND b.state='open' FOR UPDATE OF b",
        [userId],
      )
    ).rows[0];
    if (!b) fail(409, 'coverage_required', 'Current paid coverage is required.');
    return b;
  }
  private async blocks(c: PoolClient, userId: string, periodId: string | null) {
    return (
      await c.query(
        `SELECT 'ops_restriction' AS kind,'account' AS scope,NULL::uuid AS "periodId" FROM app.account_restrictions WHERE user_id=$1 AND released_at IS NULL
      UNION ALL SELECT 'dispute','period',period_id FROM app.payment_access_blocks WHERE period_id=$2 AND released_at IS NULL
      UNION ALL SELECT 'paused','period',period_id FROM app.membership_pauses WHERE period_id=$2 AND ended_at IS NULL
      UNION ALL SELECT 'paused','period',period_id FROM app.personal_pauses WHERE period_id=$2 AND app.personal_pause_blocks(period_id,app.personal_pause_now())`,
        [userId, periodId],
      )
    ).rows;
  }
  assertCheckoutAllowed: NonNullable<FinancialDependencies['assertCheckoutAllowed']> = async (
    c,
    b,
  ) => {
    await c.query('SELECT app.settle_personal_pauses($1)', [b.userId]);
    const period = (
      await c.query("SELECT id FROM app.billing_periods WHERE membership_id=$1 AND state='open'", [
        b.membershipId,
      ])
    ).rows[0];
    if ((await this.blocks(c, b.userId, period?.id ?? null)).length)
      fail(409, 'membership_blocked', 'Resolve the current membership block first.');
  };
  assertPeriodCanClose: NonNullable<FinancialDependencies['assertPeriodCanClose']> = async (
    c,
    b,
  ) => {
    await c.query('SELECT app.settle_personal_pauses($1)', [b.userId]);
    if (
      (
        await c.query(`SELECT 1 FROM app.personal_pauses WHERE period_id=$1 AND state='planned'`, [
          b.periodId,
        ])
      ).rowCount
    )
      fail(409, 'period_paused', 'Personal pause time must settle before period close.');
    if (
      (
        await c.query(
          'SELECT 1 FROM app.membership_pauses WHERE period_id=$1 AND ended_at IS NULL',
          [b.periodId],
        )
      ).rowCount
    )
      fail(409, 'period_paused', 'Resume coverage before closing it.');
    if (
      (
        await c.query(
          "SELECT 1 FROM app.reservations WHERE period_id=$1 AND (status='reserved' OR (status IN ('boarded','no_show') AND settled_at IS NULL))",
          [b.periodId],
        )
      ).rowCount
    )
      fail(409, 'period_service_unsettled', 'Funded service must settle before period close.');
  };
  private async selection(c: PoolClient, routeId: string, legs: PurchaseLeg[]) {
    const s = (
      await c.query('INSERT INTO app.commute_selections(route_id) VALUES ($1) RETURNING id', [
        id(routeId),
      ])
    ).rows[0].id;
    for (const l of legs)
      await c.query('INSERT INTO app.commute_selection_legs VALUES ($1,$2,$3,$4,$5,$6)', [
        s,
        l.direction,
        id(l.scheduleId),
        id(l.patternVersionId),
        id(l.pickupOccurrenceId),
        id(l.dropoffOccurrenceId),
      ]);
    return s as string;
  }
  private async selectionView(c: PoolClient, selectionId: string, view = false) {
    const s = (
      await c.query(
        'SELECT s.route_id,r.name FROM app.commute_selections s JOIN app.routes r ON r.id=s.route_id WHERE s.id=$1',
        [selectionId],
      )
    ).rows[0];
    const legs = (
      await c.query(
        `SELECT l.direction,l.schedule_id AS "scheduleId",l.pattern_version_id AS "patternVersionId",l.pickup_occurrence_id AS "pickupOccurrenceId",l.dropoff_occurrence_id AS "dropoffOccurrenceId",
      to_char(d.local_departure,'HH24:MI') AS "localDeparture",d.time_zone AS "timeZone",a.name AS "pickupName",b.name AS "dropoffName"
      FROM app.commute_selection_legs l JOIN app.service_schedules d ON d.id=l.schedule_id JOIN app.route_pattern_stops a ON a.id=l.pickup_occurrence_id JOIN app.route_pattern_stops b ON b.id=l.dropoff_occurrence_id WHERE selection_id=$1 ORDER BY direction`,
        [selectionId],
      )
    ).rows;
    return {
      routeId: s.route_id,
      routeName: s.name,
      legs: legs.map((l) =>
        view
          ? l
          : {
              direction: l.direction,
              scheduleId: l.scheduleId,
              patternVersionId: l.patternVersionId,
              pickupOccurrenceId: l.pickupOccurrenceId,
              dropoffOccurrenceId: l.dropoffOccurrenceId,
            },
      ),
    };
  }
  materializeAssignment: NonNullable<FinancialDependencies['materializeAssignment']> = async (
    c,
    b,
  ) => {
    const p = (
      await c.query('SELECT route_id FROM app.purchases WHERE id=$1 AND user_id=$2', [
        b.purchaseId,
        b.userId,
      ])
    ).rows[0];
    const legs = (
      await c.query(
        'SELECT direction,schedule_id AS "scheduleId",pattern_version_id AS "patternVersionId",pickup_occurrence_id AS "pickupOccurrenceId",dropoff_occurrence_id AS "dropoffOccurrenceId" FROM app.purchase_legs WHERE purchase_id=$1 ORDER BY direction',
        [b.purchaseId],
      )
    ).rows as PurchaseLeg[];
    const selection = await this.selection(c, p.route_id, legs);
    await c.query(
      'UPDATE app.commute_assignments SET effective_to=greatest(effective_from,$2::date) WHERE membership_id=$1 AND effective_to IS NULL',
      [b.membershipId, date(b.now)],
    );
    await c.query(
      'INSERT INTO app.commute_assignments(user_id,membership_id,period_id,selection_id,purchase_id,effective_from) VALUES ($1,$2,$3,$4,$5,$6)',
      [b.userId, b.membershipId, b.periodId, selection, b.purchaseId, date(b.now)],
    );
  };
  // Caller already owns rider/period locks. No nested transaction or ledger write.
  reversePeriod = async (
    c: PoolClient,
    b: { userId: string; periodId: string; purchaseId: string },
  ) => {
    await this.cancelFuture(c, b.periodId, null, true);
  };
  private async cancelFuture(
    c: PoolClient,
    periodId: string,
    from: string | null,
    reversing = false,
  ) {
    await c.query(
      `SELECT t.id FROM app.trips t WHERE EXISTS(SELECT 1 FROM app.reservations r WHERE r.trip_id=t.id AND r.period_id=$1 AND r.status IN ('reserved','pending','unseated')) ORDER BY t.id FOR UPDATE`,
      [periodId],
    );
    if (
      !reversing &&
      (
        await c.query(
          `SELECT 1 FROM app.reservations r JOIN app.trips t ON t.id=r.trip_id WHERE r.period_id=$1 AND
      ((r.status IN ('boarded','no_show') AND r.settled_at IS NULL) OR (r.status='reserved' AND (t.status<>'scheduled' OR t.scheduled_at<=$2)))`,
          [periodId, this.now()],
        )
      ).rowCount
    )
      fail(409, 'service_unsettled', 'Settle current service before changing the commute.');
    await c.query(
      "UPDATE app.reservations SET status='operator_cancelled' WHERE period_id=$1 AND status IN ('reserved','pending','unseated') AND ($2::date IS NULL OR service_date>=$2)",
      [periodId, from],
    );
  }
  // Transport owns the trip lock. NEVER acquire rider or period locks here:
  // finance/reserve acquire them before trip locks. Cancellation changes no money.
  coordinateReservations = async (c: PoolClient, change: ReservationChange) => {
    const t = change.before;
    if (change.operation === 'cancelTrip') {
      await c.query(
        "UPDATE app.reservations SET status='operator_cancelled' WHERE trip_id=$1 AND status IN ('reserved','pending','unseated')",
        [t.id],
      );
      return;
    }
    if (change.operation === 'assignTrip') {
      // Explicit null removes a vehicle; it is not an omitted patch field.
      const vehicle = 'vehicleId' in change.input ? change.input.vehicleId : t.vehicle_id;
      const n = (
        await c.query(
          "SELECT count(*)::int AS n FROM app.reservations WHERE trip_id=$1 AND status IN ('reserved','boarded','no_show')",
          [t.id],
        )
      ).rows[0].n;
      const capacity = vehicle
        ? (await c.query('SELECT capacity FROM app.vehicles WHERE id=$1 FOR SHARE', [vehicle]))
            .rows[0]?.capacity
        : 0;
      if (n > Number(capacity ?? 0))
        fail(
          409,
          'reserved_capacity',
          'The replacement vehicle cannot carry existing reservations.',
        );
    }
    if (change.operation === 'rescheduleTrip') {
      const when = new Date(String(change.input.scheduledAt));
      if (
        (
          await c.query(
            `SELECT 1 FROM app.reservations r JOIN app.billing_periods b ON b.id=r.period_id WHERE r.trip_id=$1 AND r.status='reserved' AND NOT(b.starts_at<=$2 AND $2<b.effective_ends_at)`,
            [t.id, when],
          )
        ).rowCount
      )
        fail(
          409,
          'funded_departure_outside_coverage',
          'The new time falls outside funded coverage.',
        );
    }
  };
  private async requestView(c: PoolClient, r: Row, admin: boolean) {
    const s = await this.selectionView(c, r.selection_id);
    const paused = !!(
      await c.query(
        'SELECT 1 FROM app.membership_pauses WHERE request_id=$1 AND ended_at IS NULL',
        [r.id],
      )
    ).rowCount;
    return {
      id: r.id,
      status: r.status,
      requested: {
        routeId: s.routeId,
        legs: s.legs,
        requestedDate: dayString(r.requested_date),
        pauseIfWaitlisted: r.pause_consent,
        ...(r.note ? { note: r.note } : {}),
      },
      effectiveDate: r.effective_date ? dayString(r.effective_date) : null,
      paused,
      decisionNote: r.decision_note,
      ...audit(r),
      ...(admin
        ? { riderId: r.user_id, slotId: r.slot_id, decidedBy: r.decided_by, editToken: token(r) }
        : {}),
    };
  }
  private async slotView(c: PoolClient, r: Row) {
    const s = await this.selectionView(c, r.selection_id);
    return {
      id: r.id,
      routeId: s.routeId,
      legs: s.legs,
      availableFrom: dayString(r.available_from),
      state: r.state,
      editToken: token(r),
      ...audit(r),
    };
  }
  private reservationView(r: Row) {
    return {
      id: r.id,
      tripId: r.trip_id,
      travelDate: dayString(r.service_date),
      direction: r.direction,
      status: r.status,
      source: r.source,
      pickupOccurrenceId: r.pickup_occurrence_id,
      dropoffOccurrenceId: r.dropoff_occurrence_id,
      ...audit(r),
    };
  }
  private restrictionView(r: Row) {
    return {
      id: r.id,
      userId: r.user_id,
      reason: r.reason,
      reviewAt: iso(r.review_at),
      active: r.released_at === null,
      editToken: token(r),
      ...audit(r),
    };
  }
  private async render(c: PoolClient, op: string, resource: string, admin: boolean) {
    if (op === 'createPersonalPause' || op === 'resumePersonalPause')
      return this.personalPauseView(c, resource);
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
  private match(r: Row, supplied?: string) {
    if (!supplied) fail(428, 'precondition_required', 'Supply the current edit token.');
    if (supplied !== token(r))
      fail(412, 'precondition_failed', 'Reload this resource before editing.');
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
      return (await this.insertPersonalPause(c, actor.userId, input)).id;
    if (op === 'resumePersonalPause') {
      await this.period(c, actor.userId);
      const resumeDate = this.personalDate(input.resumeDate);
      const row = (
        await c.query(
          `UPDATE app.personal_pauses SET resume_date=$3 WHERE id=$1 AND user_id=$2
        AND state='planned' AND resume_date>$3 RETURNING id`,
          [target, actor.userId, resumeDate],
        )
      ).rows[0];
      if (!row) fail(409, 'personal_resume_not_allowed', 'Choose an earlier future service day.');
      return row.id;
    }
    if (op === 'createCommuteRequest') {
      const b = await this.period(c, actor.userId);
      if (b.effective_ends_at <= now || String(input.requestedDate) < date(now))
        fail(409, 'coverage_required', 'Choose a date within current service.');
      const selection = await this.selection(
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
      const selection = await this.selection(
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
      this.match(r, match);
      if (r.state !== 'available')
        fail(409, 'slot_in_use', 'Only an available slot can be retired.');
      await c.query("UPDATE app.commute_slots SET state='retired' WHERE id=$1", [target]);
      return target;
    }
    if (op === 'createAccountRestriction')
      return (
        await c.query(
          'INSERT INTO app.account_restrictions(user_id,actor_user_id,reason,review_at) VALUES ($1,$2,$3,$4) RETURNING id',
          [target, actor.userId, input.reason, input.reviewAt],
        )
      ).rows[0].id;
    if (op === 'releaseAccountRestriction') {
      const r = (
        await c.query('SELECT * FROM app.account_restrictions WHERE id=$1 FOR UPDATE', [target])
      ).rows[0];
      if (!r) fail(404, 'not_found', 'Restriction not found.');
      this.match(r, match);
      if (r.released_at) fail(409, 'restriction_released', 'Restriction already released.');
      await c.query(
        'UPDATE app.account_restrictions SET released_at=$2,released_by=$3,release_reason=$4 WHERE id=$1',
        [target, now, actor.userId, input.reason],
      );
      return target;
    }
    if (op === 'decideReservation') return this.reserve(c, actor, input);
    const r = (await c.query('SELECT * FROM app.commute_requests WHERE id=$1 FOR UPDATE', [target]))
      .rows[0];
    if (!r) fail(404, 'not_found', 'Request not found.');
    if (op === 'decideCommuteRequest') this.match(r, match);
    if (!['submitted', 'waitlisted', 'approved'].includes(r.status))
      fail(409, 'request_terminal', 'This request is already closed.');
    const action = op === 'withdrawCommuteRequest' ? 'cancel' : String(input.action);
    const b = (
      await c.query(
        'SELECT b.*,p.fare_pesewas FROM app.billing_periods b JOIN app.purchases p ON p.id=b.purchase_id WHERE b.id=$1 FOR UPDATE OF b',
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
      if ((await this.blocks(c, r.user_id, b.id)).length)
        fail(409, 'membership_blocked', 'Resolve existing restrictions first.');
      await this.cancelFuture(c, b.id, null);
      await c.query(
        'INSERT INTO app.membership_pauses(request_id,period_id,user_id,started_at,ends_before) VALUES ($1,$2,$3,$4,$5)',
        [r.id, b.id, r.user_id, now, b.effective_ends_at],
      );
    } else if (action === 'resume') {
      await this.resume(c, r, b, pause, now);
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
      const offered = await this.selectionView(c, slot.selection_id),
        requested = await this.selectionView(c, r.selection_id);
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
      const fare = await this.options.fareForSelection?.(c, r.selection_id);
      if (!Number.isSafeInteger(fare) || fare !== b.fare_pesewas)
        fail(409, 'fare_review_required', 'Transfer pricing requires review.');
      if (pause) await this.resume(c, r, b, pause, now);
      else if (b.effective_ends_at <= now || (await this.blocks(c, r.user_id, b.id)).length)
        fail(409, 'membership_blocked', 'Current usable coverage is required.');
      await this.cancelFuture(c, b.id, date(now));
      // Never backdate a commute over already-operated service. Approved date is
      // the earliest application date; actual assignment starts on application.
      await c.query(
        "UPDATE app.commute_slots SET state='available' WHERE id IN (SELECT r.slot_id FROM app.commute_requests r JOIN app.commute_assignments a ON a.request_id=r.id WHERE a.membership_id=$1 AND a.effective_to IS NULL)",
        [b.membership_id],
      );
      await c.query(
        'UPDATE app.commute_assignments SET effective_to=greatest(effective_from,$2::date) WHERE membership_id=$1 AND effective_to IS NULL',
        [b.membership_id, date(now)],
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
  private async resume(c: PoolClient, r: Row, b: Row, pause: Row | undefined, now: Date) {
    if (!pause) fail(409, 'not_paused', 'Coverage is not paused.');
    if ((await this.blocks(c, r.user_id, b.id)).some((x) => x.kind !== 'paused'))
      fail(409, 'membership_blocked', 'Resolve the independent access block first.');
    const end = new Date(pause.ends_before.getTime() + now.getTime() - pause.started_at.getTime());
    await c.query('UPDATE app.billing_periods SET effective_ends_at=$2 WHERE id=$1', [b.id, end]);
    await c.query(
      "UPDATE app.membership_pauses SET ended_at=$2,ends_after=$3,end_reason='resumed' WHERE id=$1",
      [pause.id, now, end],
    );
  }
  private async reserve(
    c: PoolClient,
    actor: Actor,
    input: Body,
    mode: 'confirmation' | 'ask' | 'default' = 'confirmation',
  ): Promise<string> {
    const day = String(input.travelDate),
      direction = String(input.direction),
      now = this.now();
    if (day < date(now)) fail(409, 'service_day_past', 'Cannot change a past service day.');
    // Period before trip locks for acquisition. Decline needs no funding lock.
    const funding = input.decision === 'decline' ? null : await this.period(c, actor.userId);
    const old = (
      await c.query(
        "SELECT * FROM app.reservations WHERE user_id=$1 AND service_date=$2 AND direction=$3 AND status<>'operator_cancelled'",
        [actor.userId, day, direction],
      )
    ).rows[0];
    if (old && ['boarded', 'no_show'].includes(old.status))
      fail(409, 'reservation_terminal', 'This service has already settled.');
    if (old?.trip_id) {
      const trip = (await c.query('SELECT * FROM app.trips WHERE id=$1 FOR UPDATE', [old.trip_id]))
        .rows[0];
      if (trip.status !== 'scheduled' || trip.scheduled_at <= now)
        fail(409, 'service_started', 'This departure is no longer changeable.');
    }
    if (input.decision === 'decline') {
      if (old) {
        await c.query(
          "UPDATE app.reservations SET status='declined',source='confirmation' WHERE id=$1",
          [old.id],
        );
        return old.id;
      }
      return (
        await c.query(
          "INSERT INTO app.reservations(user_id,service_date,direction,status,source) VALUES ($1,$2,$3,'declined','confirmation') RETURNING id",
          [actor.userId, day, direction],
        )
      ).rows[0].id;
    }
    const b = funding!;
    if ((await this.blocks(c, actor.userId, b.id)).length)
      fail(409, 'membership_blocked', 'Resolve the current access block first.');
    const leg = (
      await c.query(
        `SELECT a.id AS assignment_id,a.selection_id,l.* FROM app.commute_assignments a JOIN app.commute_selection_legs l ON l.selection_id=a.selection_id WHERE a.period_id=$1 AND a.effective_from<=$2 AND (a.effective_to IS NULL OR $2<a.effective_to) AND l.direction=$3`,
        [b.id, day, direction],
      )
    ).rows[0];
    if (!leg) fail(409, 'commute_unavailable', 'No effective commute for this date.');
    const trips = (
      await c.query(
        'SELECT * FROM app.trips WHERE schedule_id=$1 AND service_date=$2 AND ($3::uuid IS NULL OR id=$3) ORDER BY id FOR UPDATE',
        [leg.schedule_id, day, input.tripId ? id(input.tripId) : null],
      )
    ).rows;
    const t = trips[0];
    if (
      trips.length !== 1 ||
      t.status !== 'scheduled' ||
      t.scheduled_at <= now ||
      t.scheduled_at < b.starts_at ||
      t.scheduled_at >= b.effective_ends_at
    )
      fail(409, 'departure_unavailable', 'A funded upcoming departure is required.');
    const rides = Number(
      (
        await c.query(
          'SELECT coalesce(sum(delta_rides),0) AS n FROM app.ride_entries WHERE period_id=$1',
          [b.id],
        )
      ).rows[0].n,
    );
    const held = Number(
      (
        await c.query(
          "SELECT count(*) AS n FROM app.reservations WHERE period_id=$1 AND status='reserved' AND id<>$2",
          [b.id, old?.id ?? randomUUID()],
        )
      ).rows[0].n,
    );
    if (rides <= held && mode !== 'ask')
      fail(409, 'rides_unavailable', 'No unreserved rides remain.');
    const values = [
      actor.userId,
      day,
      direction,
      b.id,
      leg.assignment_id,
      leg.selection_id,
      t.id,
      leg.schedule_id,
      leg.pattern_version_id,
      leg.pickup_occurrence_id,
      leg.dropoff_occurrence_id,
      mode === 'ask' ? 'pending' : 'reserved',
      mode === 'confirmation' ? 'confirmation' : 'default',
    ];
    if (old) {
      await c.query(
        "UPDATE app.reservations SET period_id=$4,assignment_id=$5,selection_id=$6,trip_id=$7,schedule_id=$8,pattern_version_id=$9,pickup_occurrence_id=$10,dropoff_occurrence_id=$11,status=$12,source=$13 WHERE user_id=$1 AND service_date=$2 AND direction=$3 AND status<>'operator_cancelled'",
        values,
      );
      return old.id;
    }
    return (
      await c.query(
        'INSERT INTO app.reservations(user_id,service_date,direction,period_id,assignment_id,selection_id,trip_id,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id,status,source) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13) RETURNING id',
        values,
      )
    ).rows[0].id;
  }
  async maintenance(
    actor: Actor,
    op: 'runAskDispatch' | 'runReservationDefaults',
    input: { travelDate: string; direction: string; limit?: number; routeId?: string },
  ): Promise<Outcome> {
    const limit = input.limit ?? 100,
      day = input.travelDate;
    if (
      !Number.isInteger(limit) ||
      limit < 1 ||
      limit > 100 ||
      !/^\d{4}-\d\d-\d\d$/.test(day) ||
      day < date(this.now()) ||
      !['outbound', 'return'].includes(input.direction)
    )
      fail(400, 'invalid_request', 'Invalid service-day batch.');
    const candidates = await this.tx(async (c) => {
      await this.authorize(c, actor, op);
      if (op === 'runReservationDefaults')
        return (
          await c.query(
            `SELECT r.user_id AS id FROM app.reservations r JOIN app.commute_selections s ON s.id=r.selection_id
        WHERE r.service_date=$1 AND r.direction=$2 AND r.status='pending' AND ($3::uuid IS NULL OR s.route_id=$3) ORDER BY r.created_at,r.id LIMIT $4`,
            [day, input.direction, input.routeId ?? null, limit],
          )
        ).rows;
      return (
        await c.query(
          `SELECT b.user_id AS id FROM app.billing_periods b JOIN app.memberships m ON m.id=b.membership_id AND m.lifecycle='open'
        JOIN app.users u ON u.id=b.user_id AND u.deleted_at IS NULL
        JOIN app.commute_assignments a ON a.period_id=b.id AND a.effective_from<=$1 AND (a.effective_to IS NULL OR $1<a.effective_to)
        JOIN app.commute_selection_legs l ON l.selection_id=a.selection_id AND l.direction=$2
        JOIN app.commute_selections s ON s.id=l.selection_id
        JOIN app.trips t ON t.schedule_id=l.schedule_id AND t.service_date=$1 AND t.status='scheduled' AND t.scheduled_at>$4
        WHERE b.state='open' AND b.starts_at<=t.scheduled_at AND t.scheduled_at<b.effective_ends_at
        AND ($3::uuid IS NULL OR s.route_id=$3)
        AND NOT EXISTS(SELECT 1 FROM app.reservations r WHERE r.user_id=b.user_id AND r.service_date=$1 AND r.direction=$2)
        AND NOT EXISTS(SELECT 1 FROM app.membership_pauses p WHERE p.period_id=b.id AND p.ended_at IS NULL)
        AND NOT app.personal_pause_blocks(b.id,$1::date::timestamp AT TIME ZONE 'Africa/Accra')
        AND NOT EXISTS(SELECT 1 FROM app.payment_access_blocks p WHERE p.period_id=b.id AND p.released_at IS NULL)
        AND NOT EXISTS(SELECT 1 FROM app.account_restrictions r WHERE r.user_id=b.user_id AND r.released_at IS NULL)
        ORDER BY b.user_id LIMIT $5`,
          [day, input.direction, input.routeId ?? null, this.now(), limit],
        )
      ).rows;
    });
    const result = {
      considered: candidates.length,
      succeeded: 0,
      blocked: 0,
      failed: 0,
      failures: [] as { resourceId: string; reason: string }[],
    };
    for (const rider of candidates) {
      try {
        const changed = await this.tx(async (c) => {
          await this.lockUser(c, rider.id);
          await this.authorize(c, actor, op);
          const current = (
            await c.query(
              'SELECT * FROM app.reservations WHERE user_id=$1 AND service_date=$2 AND direction=$3 ORDER BY created_at DESC LIMIT 1',
              [rider.id, day, input.direction],
            )
          ).rows[0];
          if (op === 'runAskDispatch' && current) return false;
          if (op === 'runReservationDefaults' && current?.status !== 'pending') return false;
          await c.query('SAVEPOINT booking');
          try {
            const reservation = await this.reserve(
              c,
              { userId: rider.id, sessionId: '' },
              { travelDate: day, direction: input.direction, decision: 'confirm' },
              op === 'runAskDispatch' ? 'ask' : 'default',
            );
            if (op === 'runAskDispatch')
              await c.query(
                'INSERT INTO app.reservation_prompts(reservation_id,requested_by) VALUES ($1,$2)',
                [reservation, actor.userId],
              );
            return true;
          } catch (e) {
            await c.query('ROLLBACK TO SAVEPOINT booking');
            if (op === 'runReservationDefaults' && current) {
              const capacity =
                (e as { message?: string }).message === 'reservation_capacity' ||
                (e instanceof TransportError && e.code === 'rides_unavailable');
              const blocked =
                e instanceof TransportError &&
                [
                  'membership_blocked',
                  'coverage_required',
                  'commute_unavailable',
                  'departure_unavailable',
                  'service_started',
                ].includes(e.code);
              if (capacity || blocked) {
                await c.query('UPDATE app.reservations SET status=$2 WHERE id=$1', [
                  current.id,
                  capacity ? 'unseated' : 'operator_cancelled',
                ]);
                return false;
              }
            }
            throw e;
          }
        });
        if (changed) result.succeeded++;
        else result.blocked++;
      } catch (e) {
        result.failed++;
        result.failures.push({
          resourceId: rider.id,
          reason:
            e instanceof TransportError && [401, 403, 404, 409].includes(e.status)
              ? e.code
              : 'unexpected_error',
        });
      }
    }
    return { status: 200, body: { data: result }, headers: {} };
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
      if (op === 'getPersonalPause') {
        await c.query('SELECT app.settle_personal_pauses($1)', [actor.userId]);
        const row = (
          await c.query(
            'SELECT id FROM app.personal_pauses WHERE user_id=$1 ORDER BY created_at DESC,id DESC LIMIT 1',
            [actor.userId],
          )
        ).rows[0];
        return {
          status: 200,
          headers: {},
          body: { data: row ? await this.personalPauseView(c, row.id) : null },
        } as Outcome;
      }
      if (op === 'getMembership')
        return {
          status: 200,
          body: { data: await this.membership(c, actor.userId) },
          headers: {},
        } as Outcome;
      const limit = Number(query.limit ?? 50);
      if (!Number.isInteger(limit) || limit < 1 || limit > 200)
        fail(400, 'invalid_query', 'Invalid page limit.');
      const table =
        op === 'listCommuteSlots'
          ? 'commute_slots'
          : op === 'listReservations'
            ? 'reservations'
            : op === 'listCommuteEvents'
              ? 'membership_events'
              : 'commute_requests';
      const filters: Record<string, string> = {};
      if (
        ['listCommuteRequests', 'listOpsCommuteRequests'].includes(op) &&
        query.status !== undefined
      ) {
        if (
          !['submitted', 'waitlisted', 'approved', 'applied', 'rejected', 'cancelled'].includes(
            query.status,
          )
        )
          fail(400, 'invalid_query', 'Unknown commute request status.');
        filters.status = query.status;
      }
      if (op === 'listCommuteSlots' && query.routeId !== undefined) {
        if (!/^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i.test(query.routeId))
          fail(400, 'invalid_query', 'Supply a valid route identifier.');
        filters.routeId = query.routeId.toLowerCase();
      }
      if (op === 'listReservations') {
        if ((query.fromDate === undefined) !== (query.toDate === undefined))
          fail(400, 'invalid_query', 'Supply both reservation dates.');
        const today = date(this.now());
        filters.fromDate = query.fromDate ?? date(new Date(Date.parse(today) - 6 * 86400000));
        filters.toDate = query.toDate ?? today;
        const validDate = (value: string) =>
          /^\d{4}-\d{2}-\d{2}$/.test(value) &&
          Number.isFinite(Date.parse(value)) &&
          date(new Date(value)) === value;
        if (
          !validDate(filters.fromDate) ||
          !validDate(filters.toDate) ||
          filters.fromDate > filters.toDate ||
          Date.parse(filters.toDate) - Date.parse(filters.fromDate) >= 31 * 86400000
        )
          fail(400, 'invalid_query', 'Supply an ordered range of at most 31 calendar days.');
      }
      const clock = table === 'membership_events' ? 'occurred_at' : 'created_at';
      const context = canonical([
        actor.userId,
        op,
        target ? id(target) : null,
        `${clock},id`,
        filters,
      ]);
      const cursor = query.cursor ? this.cursors.decode(query.cursor, context, this.now()) : null;
      let where = 'true';
      const args: unknown[] = [];
      if (op === 'listCommuteEvents') {
        const request = (
          await c.query(
            'SELECT r.id FROM app.commute_requests r JOIN app.users u ON u.id=r.user_id AND u.deleted_at IS NULL WHERE r.id=$1',
            [id(target)],
          )
        ).rows[0];
        if (!request) fail(404, 'not_found', 'Request not found.');
        args.push(request.id);
        where = 'x.resource_id=$1';
      } else if (!ops(op)) {
        args.push(actor.userId);
        where = 'x.user_id=$1';
      } else if (op === 'listOpsCommuteRequests')
        where = 'EXISTS(SELECT 1 FROM app.users u WHERE u.id=x.user_id AND u.deleted_at IS NULL)';
      if (filters.status !== undefined) {
        args.push(filters.status);
        where += ` AND x.status=$${args.length}`;
      }
      if (filters.routeId !== undefined) {
        args.push(filters.routeId);
        where += ` AND EXISTS(SELECT 1 FROM app.commute_selections s WHERE s.id=x.selection_id AND s.route_id=$${args.length}::uuid)`;
      }
      if (filters.fromDate !== undefined) {
        args.push(filters.fromDate, filters.toDate);
        where += ` AND x.service_date BETWEEN $${args.length - 1}::date AND $${args.length}::date`;
      }
      if (cursor) {
        args.push(cursor.time, cursor.id);
        where += ` AND (x.${clock},x.id)<($${args.length - 1}::timestamptz,$${args.length}::uuid)`;
      }
      args.push(limit + 1);
      const rows = (
        await c.query(
          `SELECT x.*,to_char(x.${clock} AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time FROM app.${table} x WHERE ${where} ORDER BY x.${clock} DESC,x.id DESC LIMIT $${args.length}`,
          args,
        )
      ).rows;
      const data = [];
      for (const r of rows.slice(0, limit))
        data.push(
          table === 'commute_slots'
            ? await this.slotView(c, r)
            : table === 'reservations'
              ? this.reservationView(r)
              : table === 'membership_events'
                ? { id: r.id, action: r.action, note: null, occurredAt: iso(r.occurred_at) }
                : await this.requestView(c, r, ops(op)),
        );
      const last = rows[limit - 1];
      return {
        status: 200,
        body: {
          data,
          page: {
            nextCursor:
              rows.length > limit
                ? this.cursors.encode(last.cursor_time, last.id, context, this.now())
                : null,
          },
        },
        headers: {},
      } as Outcome;
    });
  }
  private personalDate(value: unknown): string {
    if (
      typeof value !== 'string' ||
      !/^(?!0000)\d{4}-\d{2}-\d{2}$/.test(value) ||
      !Number.isFinite(Date.parse(value)) ||
      new Date(value).toISOString().slice(0, 10) !== value
    )
      fail(400, 'invalid_request', 'Supply a real calendar date.');
    return value;
  }
  private async personalPauseView(c: PoolClient, pauseId: string): Promise<Body> {
    const p = (
      await c.query(
        `SELECT *,to_char(start_date,'YYYY-MM-DD') AS start_day,to_char(resume_date,'YYYY-MM-DD') AS resume_day,
      CASE WHEN state='terminated' THEN 'terminated' WHEN resume_date<=(app.personal_pause_now() AT TIME ZONE 'Africa/Accra')::date THEN 'resumed'
      WHEN start_date<=(app.personal_pause_now() AT TIME ZONE 'Africa/Accra')::date THEN 'paused' ELSE 'scheduled' END AS phase,
      ends_before+make_interval(days=>resume_date-start_date) AS expected_end FROM app.personal_pauses WHERE id=$1`,
        [pauseId],
      )
    ).rows[0];
    return {
      id: p.id,
      startDate: p.start_day,
      resumeDate: p.resume_day,
      status: p.phase,
      projectedEndsAt: p.state === 'terminated' ? null : iso(p.expected_end),
      extensionApplied: p.state === 'completed',
    };
  }
  private async insertPersonalPause(c: PoolClient, userId: string, input: Body) {
    const start = this.personalDate(input.startDate),
      resume = this.personalDate(input.resumeDate);
    const b = await this.period(c, userId);
    if ((await c.query('SELECT 1 FROM app.personal_pauses WHERE period_id=$1', [b.id])).rowCount)
      fail(409, 'personal_pause_used', 'This paid period already has a personal pause.');
    const cancelled = (
      await c.query(
        `SELECT id FROM app.reservations WHERE period_id=$1 AND service_date>=$2 AND service_date<$3
      AND status IN ('pending','reserved','unseated') ORDER BY service_date,direction`,
        [b.id, start, resume],
      )
    ).rows.map((r) => r.id);
    const row = (
      await c.query(
        `INSERT INTO app.personal_pauses(period_id,user_id,start_date,original_resume_date,resume_date,ends_before)
      VALUES ($1,$2,$3,$4,$4,$5) RETURNING id`,
        [b.id, userId, start, resume, b.effective_ends_at],
      )
    ).rows[0];
    return { id: row.id as string, cancelled };
  }
  async previewPersonalPause(actor: Actor, input: Body): Promise<Outcome> {
    return this.tx(async (c) => {
      await this.lockUser(c, actor.userId);
      await this.authorize(c, actor, 'previewPersonalPause');
      // Validate through the exact database rules without keeping a pause,
      // cancellation, version increment or command. No provider calls occur.
      await c.query('SAVEPOINT preview');
      const created = await this.insertPersonalPause(c, actor.userId, input);
      const view = await this.personalPauseView(c, created.id);
      await c.query('ROLLBACK TO SAVEPOINT preview');
      return {
        status: 200,
        headers: {},
        body: {
          data: {
            startDate: view.startDate!,
            resumeDate: view.resumeDate!,
            projectedEndsAt: view.projectedEndsAt!,
            cancelledReservationIds: created.cancelled,
          },
        },
      };
    });
  }
  async resumeDuePersonalPauses(actor: Actor, limit = 100): Promise<Outcome> {
    if (!Number.isInteger(limit) || limit < 1 || limit > 100)
      fail(400, 'invalid_request', 'Invalid batch limit.');
    const rows = await this.tx(async (c) => {
      await this.authorize(c, actor, 'runPersonalPauseResumes');
      return (
        await c.query(
          `SELECT id,user_id FROM app.personal_pauses WHERE state='planned'
        AND resume_date<=(app.personal_pause_now() AT TIME ZONE 'Africa/Accra')::date ORDER BY resume_date,id LIMIT $1`,
          [limit],
        )
      ).rows;
    });
    const result = {
      considered: rows.length,
      succeeded: 0,
      blocked: 0,
      failed: 0,
      failures: [] as { resourceId: string; reason: string }[],
    };
    for (const row of rows)
      try {
        const n = await this.tx(async (c) => {
          await this.lockUser(c, row.user_id);
          await this.authorize(c, actor, 'runPersonalPauseResumes');
          return Number(
            (await c.query('SELECT app.settle_personal_pauses($1) n', [row.user_id])).rows[0].n,
          );
        });
        if (n) result.succeeded++;
        else result.blocked++;
      } catch {
        result.failed++;
        result.failures.push({ resourceId: row.id, reason: 'personal_resume_failed' });
      }
    return { status: 200, headers: {}, body: { data: result } };
  }
  private async membership(c: PoolClient, userId: string) {
    await c.query('SELECT app.settle_personal_pauses($1)', [userId]);
    const m = (await c.query('SELECT * FROM app.memberships WHERE user_id=$1', [userId])).rows[0];
    const b = (
      await c.query("SELECT * FROM app.billing_periods WHERE user_id=$1 AND state='open'", [userId])
    ).rows[0];
    const blocks = await this.blocks(c, userId, b?.id ?? null),
      paused = blocks.some((x) => x.kind === 'paused');
    const now = this.now();
    const current = b && (b.effective_ends_at > now || paused) ? b : null;
    const a = current
      ? (
          await c.query(
            'SELECT * FROM app.commute_assignments WHERE period_id=$1 AND effective_from<=$2 AND (effective_to IS NULL OR $2<effective_to)',
            [b.id, date(now)],
          )
        ).rows[0]
      : null;
    const r = (
      await c.query(
        `SELECT coalesce((SELECT sum(delta_rides) FROM app.ride_entries WHERE period_id=$2),0)::text AS rides,
      coalesce((SELECT sum(delta_pesewas) FROM app.credit_entries WHERE user_id=$1),0)::text AS credit,
      coalesce((SELECT sum(amount_pesewas) FROM app.credit_holds WHERE user_id=$1 AND state='held'),0)::text AS held`,
        [userId, current?.id ?? null],
      )
    ).rows[0];
    const credit = Number(r.credit),
      held = Number(r.held),
      rides = Number(r.rides);
    if (![credit, held, rides].every(Number.isSafeInteger) || credit < held || rides < 0)
      fail(409, 'balance_requires_review', 'Balances require reconciliation.');
    const ended = (
      await c.query(
        'SELECT max(effective_ends_at) AS ended FROM app.billing_periods WHERE user_id=$1 AND effective_ends_at<=$2',
        [userId, now],
      )
    ).rows[0].ended;
    const money = (n: number) => ({ amountMinor: n, currency: 'GHS' });
    return {
      membership: m ? { id: m.id, lifecycle: m.lifecycle } : null,
      coverage: current
        ? {
            id: b.id,
            startsAt: iso(b.starts_at),
            endsAt: paused ? null : iso(b.effective_ends_at),
            state: b.state,
            paused,
            renewalMode: 'manual',
          }
        : null,
      lastCoverageEndedAt: ended ? iso(ended) : null,
      access: { canReserve: !!current && !!a && blocks.length === 0 && rides > 0, blocks },
      commute: a
        ? {
            id: a.id,
            ...(await this.selectionView(c, a.selection_id, true)),
            effectiveFrom: dayString(a.effective_from),
            effectiveTo: a.effective_to ? dayString(a.effective_to) : null,
          }
        : null,
      entitlements: {
        remainingRides: rides,
        credit: money(credit),
        heldCredit: money(held),
        availableCredit: money(credit - held),
      },
    };
  }
}
