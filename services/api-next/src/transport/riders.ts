import type { PoolClient } from 'pg';
import type { Actor, Outcome } from './service.js';
import { fail } from './errors.js';

export const riderReads = ['listOpsRiders', 'getOpsRiderSummary', 'getOpsRiderDetail'] as const;
export type RiderRead = (typeof riderReads)[number];

interface Cursors {
  encode(time: string, id: string, context: string, now: Date): string;
  decode(token: string, context: string, now: Date): { time: string; id: string };
}

/**
 * Every commuter, with what they can do today.
 *
 * The list and the summary share this so they cannot disagree about who is
 * active. A period is current while it still covers now, or while a pause
 * holds it open, which is the same rule GET /v1/me/membership applies.
 *
 * Each ledger is aggregated once and joined by key, rather than summed per
 * rider. ride_entries has no index on period_id and credit_entries none on
 * user_id, so a per-rider sum is a scan per rider: an N+1 hidden inside one
 * statement. One pass over each ledger costs the same however many riders
 * there are. The open period is found through membership_id, which has a
 * unique partial index because a membership holds at most one open period.
 *
 * Rides used counts boardings and no-shows only. Conversions and refunds move
 * the balance too, but they are not rides anybody took.
 */
const RIDER_STATE = `
  WITH rides AS (
    SELECT period_id,
      sum(delta_rides)::int AS remaining,
      (-sum(delta_rides) FILTER (WHERE reason IN ('boarding', 'no_show')))::int AS used
    FROM app.ride_entries
    GROUP BY period_id
  ),
  credit AS (
    SELECT user_id, sum(delta_pesewas) AS total FROM app.credit_entries GROUP BY user_id
  ),
  held AS (
    SELECT user_id, sum(amount_pesewas) AS total
    FROM app.credit_holds
    WHERE state = 'held'
    GROUP BY user_id
  ),
  base AS (
    SELECT u.id, u.display_name, u.phone, u.email, u.role, u.version, u.created_at,
      (m.id IS NOT NULL) AS has_membership,
      op.purchase_id,
      COALESCE(op.paused, false) AS paused,
      CASE WHEN op.id IS NOT NULL AND (op.effective_ends_at > $1 OR op.paused)
        THEN op.id END AS period_id
    FROM app.users u
    LEFT JOIN app.memberships m ON m.user_id = u.id
    LEFT JOIN LATERAL (
      SELECT b.id, b.purchase_id, b.effective_ends_at,
        EXISTS (SELECT 1 FROM app.membership_pauses mp
                WHERE mp.period_id = b.id AND mp.ended_at IS NULL) AS paused
      FROM app.billing_periods b
      WHERE b.membership_id = m.id AND b.state = 'open'
    ) op ON true
    WHERE u.role = 'commuter' AND u.deleted_at IS NULL
  ),
  rider_state AS (
    SELECT b.id, b.display_name, b.phone, b.email, b.role, b.version, b.created_at,
      CASE
        WHEN b.period_id IS NULL THEN CASE WHEN b.has_membership THEN 'lapsed' ELSE 'none' END
        WHEN b.paused THEN 'paused'
        ELSE 'active'
      END AS status,
      CASE WHEN b.period_id IS NOT NULL THEN p.plan END AS plan,
      CASE WHEN b.period_id IS NOT NULL THEN ro.name END AS route_name,
      CASE WHEN b.period_id IS NOT NULL THEN COALESCE(r.remaining, 0) END AS rides_left,
      CASE WHEN b.period_id IS NOT NULL THEN COALESCE(r.used, 0) END AS rides_used,
      (COALESCE(c.total, 0) - COALESCE(h.total, 0))::bigint AS available_credit
    FROM base b
    LEFT JOIN app.purchases p ON p.id = b.purchase_id
    LEFT JOIN app.routes ro ON ro.id = p.route_id
    LEFT JOIN rides r ON r.period_id = b.period_id
    LEFT JOIN credit c ON c.user_id = b.id
    LEFT JOIN held h ON h.user_id = b.id
  )`;

const LIST = `${RIDER_STATE}
  SELECT id, display_name, phone, email, role, version, status, plan, route_name, rides_left,
    available_credit, created_at,
    to_char(created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
  FROM rider_state
  WHERE ($2::text IS NULL OR display_name ILIKE $2 OR phone ILIKE $2 OR email ILIKE $2)
    AND ($3::timestamptz IS NULL OR (created_at, id) < ($3::timestamptz, $4::uuid))
  ORDER BY created_at DESC, id DESC
  LIMIT $5`;

const SUMMARY = `${RIDER_STATE}
  SELECT
    count(*) FILTER (WHERE status = 'active')::int AS active,
    count(*) FILTER (WHERE status = 'paused')::int AS paused,
    count(*) FILTER (WHERE status = 'lapsed')::int AS lapsed,
    count(*) FILTER (WHERE status IN ('active', 'paused') AND plan = 'monthly')::int AS monthly,
    count(*) FILTER (WHERE status IN ('active', 'paused') AND plan = 'annual')::int AS annual,
    COALESCE(sum(available_credit), 0)::bigint AS credit_outstanding,
    avg(rides_used) FILTER (WHERE status IN ('active', 'paused')) AS average_rides_used
  FROM rider_state`;

const money = (amountMinor: number) => ({ amountMinor, currency: 'GHS' });

/** A search term is matched as text, never as a pattern the caller controls. */
function pattern(q: string | undefined): string | null {
  if (q === undefined) return null;
  const trimmed = q.trim();
  if (!trimmed.length || trimmed.length > 100)
    fail(400, 'invalid_query', 'Search between 1 and 100 characters.');
  return `%${trimmed.replace(/[\\%_]/g, (c) => `\\${c}`)}%`;
}

export async function readRiders(
  client: PoolClient,
  operation: RiderRead,
  query: Record<string, string | undefined>,
  cursors: Cursors,
  actor: Actor,
  params: { id?: string } = {},
): Promise<Outcome> {
  const now = (await client.query('SELECT clock_timestamp() AS now')).rows[0].now as Date;

  if (operation === 'getOpsRiderDetail') {
    if (Object.keys(query).length) fail(400, 'invalid_query', 'Unsupported query parameters.');
    const riderId = params.id;
    if (!riderId || !/^[0-9a-f-]{36}$/i.test(riderId)) fail(404, 'not_found', 'Rider not found.');
    const rider = (
      await client.query(
        `${RIDER_STATE}
      SELECT * FROM rider_state WHERE id=$2::uuid`,
        [now, riderId],
      )
    ).rows[0];
    if (!rider) fail(404, 'not_found', 'Rider not found.');
    const membership = await client.query(
      `SELECT m.id,m.lifecycle,b.id AS period_id,b.starts_at,b.effective_ends_at
        FROM app.memberships m LEFT JOIN app.billing_periods b
          ON b.membership_id=m.id AND b.state='open'
        WHERE m.user_id=$1`,
      [riderId],
    );
    const restrictions = await client.query(
      `SELECT * FROM app.account_restrictions WHERE user_id=$1
        ORDER BY created_at DESC LIMIT 50`,
      [riderId],
    );
    const reservations = await client.query(
      `SELECT r.id,r.service_date::text,r.direction,r.status,t.scheduled_at,ro.name AS route_name
        FROM app.reservations r LEFT JOIN app.trips t ON t.id=r.trip_id
        LEFT JOIN app.route_pattern_versions pv ON pv.id=r.pattern_version_id
        LEFT JOIN app.route_patterns rp ON rp.id=pv.pattern_id
        LEFT JOIN app.routes ro ON ro.id=rp.route_id
        WHERE r.user_id=$1 ORDER BY r.service_date DESC,r.created_at DESC LIMIT 25`,
      [riderId],
    );
    const purchases = await client.query(
      `SELECT id,plan,state,cash_due_pesewas,created_at FROM app.purchases
        WHERE user_id=$1 ORDER BY created_at DESC LIMIT 25`,
      [riderId],
    );
    const membershipRow = membership.rows[0];
    return {
      status: 200,
      body: {
        data: {
          rider: {
            id: rider.id,
            displayName: rider.display_name || 'Rider',
            phone: rider.phone ?? null,
            email: rider.email ?? null,
            role: rider.role,
            status: rider.status,
            plan: rider.plan ?? null,
            routeName: rider.route_name ?? null,
            ridesLeft: rider.rides_left === null ? null : Number(rider.rides_left),
            availableCredit: money(Number(rider.available_credit)),
            joinedAt: new Date(rider.created_at).toISOString(),
            editToken: `"user:${rider.id}:${rider.version}"`,
          },
          membership: membershipRow
            ? {
                id: membershipRow.id,
                lifecycle: membershipRow.lifecycle,
                periodId: membershipRow.period_id ?? null,
                startsAt: membershipRow.starts_at?.toISOString() ?? null,
                endsAt: membershipRow.effective_ends_at?.toISOString() ?? null,
              }
            : null,
          restrictions: restrictions.rows.map((r) => ({
            id: r.id,
            userId: r.user_id,
            reason: r.reason,
            reviewAt: r.review_at.toISOString(),
            active: r.released_at === null,
            editToken: `"restriction:${r.id}:${r.version}"`,
            createdAt: r.created_at.toISOString(),
            updatedAt: r.updated_at.toISOString(),
            version: r.version,
          })),
          reservations: reservations.rows.map((r) => ({
            id: r.id,
            serviceDate: r.service_date,
            direction: r.direction,
            status: r.status,
            routeName: r.route_name ?? null,
            scheduledAt: r.scheduled_at?.toISOString() ?? null,
          })),
          purchases: purchases.rows.map((p) => ({
            id: p.id,
            plan: p.plan,
            state: p.state,
            cashDue: money(Number(p.cash_due_pesewas)),
            createdAt: p.created_at.toISOString(),
          })),
        },
      },
      headers: {},
    };
  }

  if (operation === 'getOpsRiderSummary') {
    if (Object.keys(query).length) fail(400, 'invalid_query', 'Unsupported query parameters.');
    const row = (await client.query(SUMMARY, [now])).rows[0];
    const average = row.average_rides_used === null ? null : Number(row.average_rides_used);
    return {
      status: 200,
      body: {
        data: {
          generatedAt: now.toISOString(),
          active: row.active,
          paused: row.paused,
          lapsed: row.lapsed,
          monthly: row.monthly,
          annual: row.annual,
          creditOutstanding: money(Number(row.credit_outstanding)),
          averageRidesUsed: average === null ? null : Math.round(average * 10) / 10,
        },
      },
      headers: {},
    };
  }

  const limit = query.limit === undefined ? 50 : Number(query.limit);
  if (!Number.isInteger(limit) || limit < 1 || limit > 200)
    fail(400, 'invalid_limit', 'Page size must be between 1 and 200.');
  const q = pattern(query.q);
  // Bound to the caller and the search, so a cursor from one search cannot be
  // replayed against another and silently skip the riders it would have shown.
  const context = `riders:${operation}:${actor.userId}:${q ?? ''}`;
  const cursor = query.cursor ? cursors.decode(query.cursor, context, now) : null;
  const rows = (
    await client.query(LIST, [now, q, cursor?.time ?? null, cursor?.id ?? null, limit + 1])
  ).rows;
  const page = rows.slice(0, limit);
  const last = page[page.length - 1];
  return {
    status: 200,
    body: {
      data: page.map((r) => ({
        id: r.id,
        displayName: r.display_name || 'Rider',
        phone: r.phone ?? null,
        email: r.email ?? null,
        role: r.role,
        status: r.status,
        plan: r.plan ?? null,
        routeName: r.route_name ?? null,
        ridesLeft: r.rides_left === null ? null : Number(r.rides_left),
        availableCredit: money(Number(r.available_credit)),
        joinedAt: new Date(r.created_at).toISOString(),
        editToken: `"user:${r.id}:${r.version}"`,
      })),
      page: {
        nextCursor:
          rows.length > limit && last
            ? cursors.encode(last.cursor_time, last.id, context, now)
            : null,
      },
    },
    headers: {},
  };
}
