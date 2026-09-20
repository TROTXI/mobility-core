import { randomUUID, timingSafeEqual } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import type { Actor, Body, Outcome } from '../transport/service.js';
import { canonical } from '../transport/service.js';
import { TransportError, fail, mapDatabaseError } from '../transport/errors.js';
import { BoardingProofs } from './proofs.js';

export const boardingOperations = [
  'issuePass',
  'getManifest',
  'getTripSummary',
  'boardRider',
  'markNoShow',
  'runNoShows',
] as const;
export type BoardingOperation = (typeof boardingOperations)[number];
type Method = 'qr' | 'code' | 'photo' | 'no_show';
type Evidence = { rid: string; jti?: string; proofUser?: string };
export interface BoardingOptions {
  pool: Pool;
  authorizeSession: (c: PoolClient, actor: Actor) => Promise<void>;
  proofKey: Buffer;
  now?: () => Date;
  // Resolve a stored object key to a short-lived URL, never trust a QR/photo URL.
  avatarUrl: (key: string, expiresInSeconds: number) => Promise<string | null>;
  // Optional auxiliary telemetry, AFTER settlement commits. Required financial
  // receipts/events/ledger writes are never routed through this fail-open port.
  auditScan?: (event: { tripId: string; reservationId: string; method: Method }) => Promise<void>;
}
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const id = (v: string) => {
  if (!uuid.test(v)) fail(404, 'not_found', 'Resource not found.');
  return v.toLowerCase();
};
const out = (data: unknown): Outcome => ({ status: 200, headers: {}, body: { data } as Body });
export class BoardingService {
  private readonly proofs;
  constructor(private readonly options: BoardingOptions) {
    if (typeof options.authorizeSession !== 'function' || typeof options.avatarUrl !== 'function')
      throw new Error('Boarding requires current-session and private-avatar adapters');
    this.proofs = new BoardingProofs(options.proofKey);
  }
  private now() {
    return this.options.now?.() ?? new Date();
  }
  private async tx<T>(fn: (c: PoolClient) => Promise<T>, snapshot = false): Promise<T> {
    const c = await this.options.pool.connect();
    try {
      await c.query(snapshot ? 'BEGIN ISOLATION LEVEL REPEATABLE READ' : 'BEGIN');
      await c.query("SET LOCAL TIME ZONE 'UTC'");
      await c.query("SET LOCAL lock_timeout='3s'");
      await c.query("SET LOCAL statement_timeout='10s'");
      const result = await fn(c);
      await c.query('COMMIT');
      return result;
    } catch (e) {
      await c.query('ROLLBACK');
      throw mapDatabaseError(e);
    } finally {
      c.release();
    }
  }
  private async authorize(c: PoolClient, actor: Actor, role: 'driver' | 'commuter' | 'admin') {
    await this.options.authorizeSession(c, actor);
    const u = (
      await c.query('SELECT role FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR SHARE', [
        actor.userId,
      ])
    ).rows[0];
    if (!u) fail(401, 'unauthenticated', 'Sign in to continue.');
    if (u.role !== role) fail(403, 'forbidden', 'This operation is not permitted.');
    if (role !== 'driver') return null;
    const d = (
      await c.query(
        'SELECT id FROM app.drivers WHERE user_id=$1 AND archived_at IS NULL FOR SHARE',
        [actor.userId],
      )
    ).rows[0];
    if (!d) fail(404, 'not_found', 'Resource not found.');
    return d.id as string;
  }
  private async trip(c: PoolClient, tripId: string, driver: string | null, lock = false) {
    const t = (
      await c.query(
        `SELECT *,service_date::text FROM app.trips WHERE id=$1 AND ($2::uuid IS NULL OR assigned_driver_id=$2)${lock ? ' FOR UPDATE' : ''}`,
        [tripId, driver],
      )
    ).rows[0];
    if (!t) fail(404, 'not_found', 'Resource not found.');
    return t;
  }
  // Global financial order: rider -> period -> trip -> reservation. Initial
  // driver ownership/subject discovery never locks the trip ahead of the rider.
  private async funded(
    c: PoolClient,
    reservationId: string,
    tripId: string,
    driver: string | null,
    ownUser?: string,
  ) {
    const peek = (
      await c.query(
        'SELECT * FROM app.reservations WHERE id=$1 AND trip_id=$2 AND ($3::uuid IS NULL OR user_id=$3)',
        [reservationId, tripId, ownUser ?? null],
      )
    ).rows[0];
    if (!peek) fail(404, 'not_found', 'Resource not found.');
    const user = (await c.query('SELECT * FROM app.users WHERE id=$1 FOR UPDATE', [peek.user_id]))
      .rows[0];
    const period = (
      await c.query('SELECT * FROM app.billing_periods WHERE id=$1 FOR UPDATE', [peek.period_id])
    ).rows[0];
    const trip = await this.trip(c, tripId, driver, true);
    const r = (
      await c.query('SELECT * FROM app.reservations WHERE id=$1 FOR UPDATE', [reservationId])
    ).rows[0];
    if (
      !user ||
      user.deleted_at ||
      !period ||
      r.user_id !== peek.user_id ||
      r.period_id !== peek.period_id ||
      r.trip_id !== trip.id
    )
      fail(409, 'boarding_ineligible', 'The reservation is no longer eligible.');
    const blocked = (
      await c.query(
        `SELECT 1 FROM app.account_restrictions WHERE user_id=$1 AND released_at IS NULL
      UNION ALL SELECT 1 FROM app.payment_access_blocks WHERE period_id=$2 AND released_at IS NULL
      UNION ALL SELECT 1 FROM app.membership_pauses WHERE period_id=$2 AND ended_at IS NULL
      UNION ALL SELECT 1 WHERE app.personal_pause_blocks($2,app.personal_pause_now())`,
        [r.user_id, r.period_id],
      )
    ).rowCount;
    const membership = (
      await c.query('SELECT lifecycle FROM app.memberships WHERE id=$1', [period.membership_id])
    ).rows[0];
    if (
      blocked ||
      membership?.lifecycle !== 'open' ||
      !['open', 'closed'].includes(period.state) ||
      !['reserved', 'boarded', 'no_show'].includes(r.status) ||
      trip.status === 'cancelled'
    )
      fail(409, 'boarding_ineligible', 'The reservation is no longer eligible.');
    return { r, trip, period };
  }
  async issue(actor: Actor, reservationId: string) {
    const rid = id(reservationId);
    return this.tx(async (c) => {
      // Only the authenticated own-user lock may precede authorization.
      await c.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [actor.userId]);
      await this.authorize(c, actor, 'commuter');
      const peek = (
        await c.query('SELECT trip_id FROM app.reservations WHERE id=$1 AND user_id=$2', [
          rid,
          actor.userId,
        ])
      ).rows[0];
      if (!peek?.trip_id) fail(404, 'not_found', 'Resource not found.');
      const { r, trip } = await this.funded(c, rid, peek.trip_id, null, actor.userId);
      if (!['scheduled', 'active'].includes(trip.status))
        fail(409, 'trip_not_boardable', 'This trip is not boarding.');
      return out(
        await this.proofs.issue(
          { userId: r.user_id, reservationId: r.id, tripId: trip.id },
          this.now(),
        ),
      );
    });
  }
  async read(actor: Actor, op: 'getManifest' | 'getTripSummary', tripId: string) {
    const data = await this.tx(async (c) => {
      const driver = await this.authorize(c, actor, 'driver');
      const trip = await this.trip(c, id(tripId), driver);
      if (op === 'getTripSummary') {
        const row = (
          await c.query(
            `SELECT count(*) FILTER(WHERE status='boarded')::int AS boarded,
          count(*) FILTER(WHERE status='no_show')::int AS "noShows",count(*) FILTER(WHERE status='unseated')::int AS unseated
          FROM app.reservations WHERE trip_id=$1`,
            [trip.id],
          )
        ).rows[0];
        const methods = (
          await c.query(
            `SELECT count(DISTINCT e.reservation_id) FILTER(WHERE e.method='qr')::int AS scanned,
          count(DISTINCT e.reservation_id) FILTER(WHERE e.method='code')::int AS "codeVerified",
          count(DISTINCT e.reservation_id) FILTER(WHERE e.method='photo')::int AS "photoVerified"
          FROM app.boarding_events e JOIN app.reservation_charges r ON r.reservation_id=e.reservation_id WHERE r.trip_id=$1`,
            [trip.id],
          )
        ).rows[0];
        return { tripId: trip.id, status: trip.status, ...row, ...methods };
      }
      const rows = (
        await c.query(
          `SELECT r.*,u.display_name,u.avatar_object_key FROM app.reservations r JOIN app.users u ON u.id=r.user_id
        WHERE r.trip_id=$1 AND r.status IN ('reserved','boarded','no_show') AND u.deleted_at IS NULL ORDER BY r.id LIMIT 501`,
          [trip.id],
        )
      ).rows;
      if (rows.length > 500)
        fail(409, 'manifest_too_large', 'The complete manifest exceeds its supported size.');
      const now = this.now();
      return {
        tripId: trip.id,
        revision: randomUUID(),
        generatedAt: now.toISOString(),
        expiresAt: new Date(now.getTime() + 120000).toISOString(),
        complete: true,
        riders: rows.map((r) => ({
          reservationId: r.id,
          displayName: r.display_name ?? 'Rider',
          avatarUrl: null,
          objectKey: r.avatar_object_key,
          status: r.status,
          pickupOccurrenceId: r.pickup_occurrence_id,
          dropoffOccurrenceId: r.dropoff_occurrence_id,
        })),
      };
    }, true);
    if ('riders' in data)
      for (const r of data.riders) {
        if (r.objectKey) r.avatarUrl = await this.options.avatarUrl(r.objectKey, 120);
        delete r.objectKey;
      }
    return out(data);
  }
  private async qrEvidence(target: string, token: string): Promise<Evidence> {
    const proof = await this.proofs.verify(token, this.now());
    if (proof.tripId !== target)
      fail(409, 'invalid_boarding_proof', 'The pass belongs to another trip.');
    return { rid: proof.reservationId, jti: proof.jti, proofUser: proof.userId };
  }
  private async codeEvidence(c: PoolClient, target: string, code: string): Promise<Evidence> {
    if (!/^[A-Z2-9]{4}$/.test(code)) fail(400, 'invalid_request', 'Invalid boarding code.');
    const rows = (
      await c.query(
        "SELECT id FROM app.reservations WHERE trip_id=$1 AND status IN ('reserved','boarded','no_show') ORDER BY id LIMIT 501",
        [target],
      )
    ).rows;
    if (rows.length > 500) fail(409, 'manifest_too_large', 'The trip exceeds its supported size.');
    const matches = rows.filter((r) =>
      timingSafeEqual(Buffer.from(this.proofs.code(r.id, target)), Buffer.from(code)),
    );
    if (matches.length !== 1)
      fail(
        409,
        'invalid_boarding_proof',
        'The code is invalid or ambiguous; use another verification method.',
      );
    return { rid: matches[0].id };
  }
  async command(
    actor: Actor,
    op: 'boardRider' | 'markNoShow' | 'runNoShows',
    tripId: string,
    input: Body,
    key: string,
    reservationId?: string,
  ) {
    const target = id(tripId);
    if (typeof key !== 'string' || !key.length || key.length > 128)
      fail(400, 'invalid_request', 'Supply a bounded Idempotency-Key.');
    const normalized = { ...input };
    if (typeof normalized.reservationId === 'string')
      normalized.reservationId = id(normalized.reservationId);
    if (typeof normalized.code === 'string') normalized.code = normalized.code.toUpperCase();
    const method: Method = op === 'boardRider' ? (normalized.kind as Method) : 'no_show';
    if (op === 'boardRider' && !['qr', 'code', 'photo'].includes(method))
      fail(400, 'invalid_request', 'Invalid boarding method.');
    if (op === 'boardRider') {
      const fields: Partial<Record<Method, string>> = {
        qr: 'token',
        code: 'code',
        photo: 'reservationId',
      };
      const field = fields[method];
      if (
        !field ||
        typeof normalized[field] !== 'string' ||
        Object.keys(normalized).some((key) => key !== 'kind' && key !== field)
      )
        fail(400, 'invalid_request', 'Supply exactly one boarding verification method.');
    }
    const kh = this.proofs.digest(`command:${actor.userId}:${op}:${target}:${key}`);
    const ih = this.proofs.digest(
      canonical({ input: normalized, reservationId: reservationId ? id(reservationId) : null }),
    );
    const admitted = await this.tx(async (c) => {
      const driver = await this.authorize(c, actor, op === 'runNoShows' ? 'admin' : 'driver');
      await this.trip(c, target, driver);
      if (method !== 'code') return true;
      const budget = (
        await c.query(
          `INSERT INTO app.boarding_code_attempts(trip_id,actor_user_id,window_start,attempts)
          VALUES($1,$2,$3,1) ON CONFLICT(trip_id,actor_user_id) DO UPDATE SET
          attempts=CASE WHEN app.boarding_code_attempts.window_start<=$3::timestamptz-interval '15 minutes' THEN 1 ELSE least(31,app.boarding_code_attempts.attempts+1) END,
          window_start=CASE WHEN app.boarding_code_attempts.window_start<=$3::timestamptz-interval '15 minutes' THEN $3 ELSE app.boarding_code_attempts.window_start END RETURNING attempts`,
          [target, actor.userId, this.now()],
        )
      ).rows[0];
      return budget.attempts <= 30;
    });
    if (!admitted)
      fail(
        429,
        'boarding_code_rate_limited',
        'Use the photo fallback or wait before trying another code.',
      );
    let audit: { tripId: string; reservationId: string; method: Method } | undefined;
    const result = await this.tx(async (c) => {
      const driver = await this.authorize(c, actor, op === 'runNoShows' ? 'admin' : 'driver');
      await this.trip(c, target, driver); // foreign and missing trips are both 404
      await c.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [`boarding:${kh}`]);
      const receipt = (
        await c.query(
          'SELECT * FROM app.boarding_commands WHERE actor_user_id=$1 AND operation=$2 AND target=$3 AND key_hash=$4',
          [actor.userId, op, target, kh],
        )
      ).rows[0];
      if (receipt && receipt.input_hash !== ih)
        fail(409, 'idempotency_conflict', 'This key belongs to different input.');
      if (
        receipt &&
        (this.now().getTime() - receipt.created_at.getTime() >= 7 * 86400000 ||
          receipt.response_body === null)
      )
        fail(409, 'idempotency_expired', 'This command is too old to replay.');
      let rid =
          receipt?.response_body.reservationId ?? (reservationId ? id(reservationId) : undefined),
        jti: string | undefined,
        proofUser: string | undefined;
      if (!receipt && op === 'boardRider') {
        // This is evidence selection, never session/driver authorization: both
        // were mandatory above and ownership is checked again under the lock.
        // Each validated variant has its own resolver; a photo confirmation is
        // the assigned driver's explicit decision, not an unchecked QR token.
        // Static call sites: request fields never name a callable property or
        // choose a function through a dynamic object/Map lookup.
        let evidence: Evidence;
        switch (method) {
          case 'qr':
            evidence = await this.qrEvidence(target, String(normalized.token));
            break;
          case 'code':
            evidence = await this.codeEvidence(c, target, String(normalized.code));
            break;
          case 'photo':
            evidence = { rid: id(String(normalized.reservationId)) };
            break;
          default:
            fail(400, 'invalid_request', 'Invalid boarding method.');
        }
        ({ rid, jti, proofUser } = evidence);
      }
      if (!rid) fail(404, 'not_found', 'Resource not found.');
      const { r, trip, period } = await this.funded(c, rid, target, driver);
      if (proofUser && proofUser !== r.user_id)
        fail(409, 'invalid_boarding_proof', 'Invalid boarding pass.');
      if (receipt)
        return out({
          ...receipt.response_body,
          status: r.status,
          alreadyApplied: true,
          chargedRides: 0,
        });
      if (method !== 'no_show' && !['scheduled', 'active'].includes(trip.status))
        fail(409, 'trip_not_boardable', 'This trip is not boarding.');
      if (
        method !== 'no_show' &&
        trip.status === 'scheduled' &&
        trip.service_date !== this.now().toISOString().slice(0, 10)
      )
        fail(409, 'trip_not_boardable', 'This departure is not boarding today.');
      if (method === 'no_show' && trip.scheduled_at > this.now())
        fail(409, 'departure_not_due', 'This departure has not reached its scheduled time.');
      const next =
        method === 'no_show' ? (r.status === 'boarded' ? 'boarded' : 'no_show') : 'boarded';
      const existing = (
        await c.query('SELECT * FROM app.reservation_charges WHERE reservation_id=$1', [r.id])
      ).rows[0];
      const commandId = randomUUID(),
        chargedAt = this.now();
      if (!existing) {
        if (r.status !== 'reserved' || period.state !== 'open')
          fail(409, 'boarding_ineligible', 'This reservation cannot be charged.');
        const balance = Number(
          (
            await c.query(
              'SELECT coalesce(sum(delta_rides),0) AS n FROM app.ride_entries WHERE period_id=$1',
              [period.id],
            )
          ).rows[0].n,
        );
        if (!Number.isSafeInteger(balance) || balance < 1)
          fail(409, 'insufficient_rides', 'No funded rides remain.');
        await c.query(
          'INSERT INTO app.reservation_charges(reservation_id,period_id,user_id,trip_id,reason,command_id,charged_at) VALUES($1,$2,$3,$4,$5,$6,$7)',
          [
            r.id,
            r.period_id,
            r.user_id,
            trip.id,
            next === 'boarded' ? 'boarding' : 'no_show',
            commandId,
            chargedAt,
          ],
        );
        await c.query('UPDATE app.reservations SET status=$2,settled_at=$3 WHERE id=$1', [
          r.id,
          next,
          chargedAt,
        ]);
        await c.query(
          'INSERT INTO app.ride_entries(user_id,period_id,reason,delta_rides,reservation_id) VALUES($1,$2,$3,-1,$4)',
          [r.user_id, r.period_id, next === 'boarded' ? 'boarding' : 'no_show', r.id],
        );
      } else if (next !== r.status)
        await c.query('UPDATE app.reservations SET status=$2 WHERE id=$1', [r.id, next]);
      if (jti) {
        const claim = await c.query(
          'INSERT INTO app.boarding_qr_uses(jti,reservation_id,command_id) VALUES($1,$2,$3) ON CONFLICT DO NOTHING',
          [jti, r.id, commandId],
        );
        if (!claim.rowCount)
          fail(
            409,
            'boarding_pass_reused',
            'Refresh the boarding pass or use another verification method.',
          );
      }
      const body = {
        reservationId: r.id,
        status: next,
        alreadyApplied: Boolean(existing),
        chargedRides: existing ? 0 : 1,
      };
      await c.query(
        'INSERT INTO app.boarding_commands(id,actor_user_id,operation,target,key_hash,input_hash,response_body,created_at) VALUES($1,$2,$3,$4,$5,$6,$7,$8)',
        [commandId, actor.userId, op, target, kh, ih, body, this.now()],
      );
      if (!existing || next !== r.status)
        await c.query(
          'INSERT INTO app.boarding_events(command_id,actor_user_id,reservation_id,method) VALUES($1,$2,$3,$4)',
          [commandId, actor.userId, r.id, method],
        );
      audit = { tripId: target, reservationId: r.id, method };
      return out(body);
    });
    if (audit && this.options.auditScan)
      try {
        await this.options.auditScan(audit);
      } catch {
        // Auxiliary failure cannot undo the committed attendance/charge. No raw
        // exception is logged here: telemetry adapters may include private data.
        console.warn('boarding_auxiliary_audit_unavailable');
      }
    return result;
  }
  async maintenance(
    actor: Actor,
    input: { travelDate: string; direction: string; routeId?: string; limit?: number },
  ) {
    const limit = input.limit ?? 100;
    if (
      !Number.isInteger(limit) ||
      limit < 1 ||
      limit > 100 ||
      !/^\d{4}-\d{2}-\d{2}$/.test(input.travelDate) ||
      !['outbound', 'return'].includes(input.direction) ||
      !Number.isFinite(Date.parse(input.travelDate)) ||
      new Date(input.travelDate).toISOString().slice(0, 10) !== input.travelDate
    )
      fail(400, 'invalid_request', 'Invalid service-day batch.');
    const rows = await this.tx(async (c) => {
      await this.authorize(c, actor, 'admin');
      return (
        await c.query(
          `SELECT r.id,r.trip_id FROM app.reservations r JOIN app.commute_selections s ON s.id=r.selection_id
        JOIN app.trips t ON t.id=r.trip_id JOIN app.billing_periods b ON b.id=r.period_id
        JOIN app.memberships m ON m.id=b.membership_id JOIN app.users u ON u.id=r.user_id
        WHERE r.status='reserved' AND r.service_date=$1 AND r.direction=$2 AND ($3::uuid IS NULL OR s.route_id=$3)
        AND t.status<>'cancelled' AND t.scheduled_at<=$5 AND b.state='open' AND m.lifecycle='open' AND u.deleted_at IS NULL
        AND NOT EXISTS(SELECT 1 FROM app.account_restrictions WHERE user_id=r.user_id AND released_at IS NULL)
        AND NOT EXISTS(SELECT 1 FROM app.payment_access_blocks WHERE period_id=r.period_id AND released_at IS NULL)
        AND NOT EXISTS(SELECT 1 FROM app.membership_pauses WHERE period_id=r.period_id AND ended_at IS NULL)
        ORDER BY r.id LIMIT $4`,
          [
            input.travelDate,
            input.direction,
            input.routeId ? id(input.routeId) : null,
            limit,
            this.now(),
          ],
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
        const value = await this.command(
          actor,
          'runNoShows',
          row.trip_id,
          {},
          `no-show:${row.id}`,
          row.id,
        );
        if ((value.body as any).data.chargedRides === 1) result.succeeded++;
        else result.blocked++;
      } catch (e) {
        if (e instanceof TransportError && [401, 403].includes(e.status)) throw e;
        if (e instanceof TransportError && [404, 409].includes(e.status)) result.blocked++;
        else {
          result.failed++;
          result.failures.push({ resourceId: row.id, reason: 'settlement_failed' });
        }
      }
    return out(result);
  }
}
