// Shared state and lookups for the membership sub-domains. Internal to
// src/membership: the public surface is MembershipService in service.ts.
import { beginTransaction } from '../db/transaction.js';
import { createHash } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import type { Actor, ReservationChange } from '../transport/service.js';
import { fail, mapDatabaseError } from '../transport/errors.js';
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
  'getReservation',
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
export type Row = Record<string, any>;
export const digest = (s: string) => createHash('sha256').update(s).digest('hex');
export const date = (d: Date) => d.toISOString().slice(0, 10); // Africa/Accra is UTC.
// pg parses DATE as local midnight; preserve its calendar fields on every host.
export const dayString = (d: Date | string) =>
  d instanceof Date
    ? `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
    : d;
export const iso = (d: Date) => d.toISOString();
export const token = (r: Row) => `"membership:${r.id}:${r.version}"`;
export const id = (value: unknown): string => {
  if (typeof value !== 'string' || !/^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i.test(value))
    fail(404, 'not_found', 'Resource not found.');
  return value.toLowerCase();
};
export const audit = (r: Row) => ({
  createdAt: iso(r.created_at),
  updatedAt: iso(r.updated_at),
  version: r.version,
});
export const ops = (op: string) =>
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

export class MembershipCore {
  readonly cursors;
  constructor(readonly options: MembershipOptions) {
    this.cursors = cursorCodec(options.cursorSecret);
  }
  now() {
    return this.options.now?.() ?? new Date();
  }
  async tx<T>(work: (c: PoolClient) => Promise<T>): Promise<T> {
    const c = await this.options.pool.connect();
    try {
      await beginTransaction(c);
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
  async authorize(c: PoolClient, actor: Actor, operation: string) {
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
  async lockUser(c: PoolClient, userId: string) {
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
  async period(c: PoolClient, userId: string) {
    await c.query('SELECT app.settle_personal_pauses($1)', [userId]);
    const b = (
      await c.query(
        "SELECT b.*,p.fare_pesewas,to_jsonb(p)->'offer_terms' AS offer_terms FROM app.billing_periods b JOIN app.purchases p ON p.id=b.purchase_id WHERE b.user_id=$1 AND b.state='open' AND b.starts_at<=$2 ORDER BY b.starts_at DESC LIMIT 1 FOR UPDATE OF b",
        [userId, this.now()],
      )
    ).rows[0];
    if (!b) fail(409, 'coverage_required', 'Current paid coverage is required.');
    return b;
  }
  async blocks(c: PoolClient, userId: string, periodId: string | null) {
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
  async periodForDeparture(
    c: PoolClient,
    userId: string,
    day: string,
    direction: string,
    tripId: string | null,
  ) {
    await c.query('SELECT app.settle_personal_pauses($1)', [userId]);
    // The rider lock protects assignment changes. Discover without a trip lock,
    // lock funding first, then reserve() locks/rechecks the departure. Upcoming
    // paid coverage may fund a future trip without becoming current coverage.
    const periods = (
      await c.query(
        `SELECT b.*,p.fare_pesewas,to_jsonb(p)->'offer_terms' AS offer_terms
         FROM app.billing_periods b JOIN app.purchases p ON p.id=b.purchase_id
         WHERE b.user_id=$1 AND b.state='open' AND EXISTS (
           SELECT 1 FROM app.commute_assignments a
           JOIN app.commute_selection_legs l ON l.selection_id=a.selection_id
           JOIN app.trips t ON t.schedule_id=l.schedule_id AND t.service_date=$2
           WHERE a.period_id=b.id AND a.effective_from<=$2
             AND (a.effective_to IS NULL OR $2<a.effective_to) AND l.direction=$3
             AND ($4::uuid IS NULL OR t.id=$4)
             AND b.starts_at<=t.scheduled_at AND t.scheduled_at<b.effective_ends_at
         ) ORDER BY b.starts_at FOR UPDATE OF b`,
        [userId, day, direction, tripId],
      )
    ).rows;
    if (!periods.length)
      fail(409, 'coverage_required', 'Paid coverage for this departure is required.');
    if (periods.length !== 1)
      fail(409, 'departure_unavailable', 'Select a single funded departure.');
    return periods[0]!;
  }
  assertCheckoutAllowed: NonNullable<FinancialDependencies['assertCheckoutAllowed']> = async (
    c,
    b,
  ) => {
    await c.query('SELECT app.settle_personal_pauses($1)', [b.userId]);
    const periods = (
      await c.query("SELECT id FROM app.billing_periods WHERE membership_id=$1 AND state='open'", [
        b.membershipId,
      ])
    ).rows;
    if ((await this.blocks(c, b.userId, null)).length)
      fail(409, 'membership_blocked', 'Resolve the current membership block first.');
    for (const period of periods) {
      if (
        (await this.blocks(c, b.userId, period.id)).length ||
        (
          await c.query(
            "SELECT 1 FROM app.personal_pauses WHERE period_id=$1 AND state='planned'",
            [period.id],
          )
        ).rowCount
      )
        fail(
          409,
          'membership_blocked',
          'Resolve pauses and payment blocks before buying renewal coverage.',
        );
    }
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
  async selection(c: PoolClient, routeId: string, legs: PurchaseLeg[]) {
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
  async selectionView(c: PoolClient, selectionId: string, view = false) {
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
    // Period closure owns assignment/slot cleanup. A prepaid period must leave
    // the current assignment usable, including if the renewal is later refunded.
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
  async cancelFuture(c: PoolClient, periodId: string, from: string | null, reversing = false) {
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
  async requestView(c: PoolClient, r: Row, admin: boolean) {
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
  async slotView(c: PoolClient, r: Row) {
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
  reservationView(r: Row) {
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
  restrictionView(r: Row) {
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
  match(r: Row, supplied?: string) {
    if (!supplied) fail(428, 'precondition_required', 'Supply the current edit token.');
    if (supplied !== token(r))
      fail(412, 'precondition_failed', 'Reload this resource before editing.');
  }
}
