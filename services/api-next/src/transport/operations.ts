import type { PoolClient } from 'pg';
import type { Actor, Outcome } from './service.js';
import { fail } from './errors.js';

export const operationsReads = [
  'listOpsOperators',
  'listOpsDeliveries',
  'listOpsAuditEvents',
  'getOpsReportSummary',
] as const;
export type OperationsRead = (typeof operationsReads)[number];

interface Cursors {
  encode(time: string, id: string, context: string, now: Date): string;
  decode(token: string, context: string, now: Date): { time: string; id: string };
}

function pageInput(
  query: Record<string, string | undefined>,
  context: string,
  cursors: Cursors,
  now: Date,
) {
  const limit = query.limit === undefined ? 50 : Number(query.limit);
  if (!Number.isInteger(limit) || limit < 1 || limit > 200)
    fail(400, 'invalid_limit', 'Page size must be between 1 and 200.');
  return {
    limit,
    cursor: query.cursor ? cursors.decode(query.cursor, context, now) : null,
  };
}

const money = (amountMinor: number) => ({ amountMinor, currency: 'GHS' });

export async function readOperations(
  client: PoolClient,
  operation: OperationsRead,
  query: Record<string, string | undefined>,
  cursors: Cursors,
  actor: Actor,
): Promise<Outcome> {
  const now = (await client.query<{ now: Date }>('SELECT clock_timestamp() AS now')).rows[0]!.now;

  if (operation === 'getOpsReportSummary') {
    if (Object.keys(query).some((key) => !['fromDate', 'toDate'].includes(key)))
      fail(400, 'invalid_query', 'Unsupported query parameters.');
    const toDate = query.toDate ?? now.toISOString().slice(0, 10);
    const fromDate =
      query.fromDate ??
      new Date(Date.parse(`${toDate}T00:00:00Z`) - 29 * 86400000).toISOString().slice(0, 10);
    const valid = (value: string) =>
      /^\d{4}-\d{2}-\d{2}$/.test(value) &&
      new Date(`${value}T00:00:00Z`).toISOString().slice(0, 10) === value;
    if (
      !valid(fromDate) ||
      !valid(toDate) ||
      toDate < fromDate ||
      Date.parse(`${toDate}T00:00:00Z`) - Date.parse(`${fromDate}T00:00:00Z`) > 366 * 86400000
    )
      fail(400, 'invalid_date_range', 'Supply an ordered date range of at most 367 days.');
    const row = (
      await client.query(
        `WITH rider AS (
        SELECT count(*)::int AS total,
          count(*) FILTER (WHERE b.id IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM app.membership_pauses mp WHERE mp.period_id=b.id AND mp.ended_at IS NULL
          ))::int AS active,
          count(*) FILTER (WHERE b.id IS NOT NULL AND EXISTS (
            SELECT 1 FROM app.membership_pauses mp WHERE mp.period_id=b.id AND mp.ended_at IS NULL
          ))::int AS paused,
          count(*) FILTER (WHERE EXISTS (
            SELECT 1 FROM app.account_restrictions ar WHERE ar.user_id=u.id AND ar.released_at IS NULL
          ))::int AS restricted
        FROM app.users u LEFT JOIN app.memberships m ON m.user_id=u.id
        LEFT JOIN app.billing_periods b ON b.membership_id=m.id AND b.state='open'
          AND (b.effective_ends_at>$3 OR EXISTS (
            SELECT 1 FROM app.membership_pauses mp WHERE mp.period_id=b.id AND mp.ended_at IS NULL))
        WHERE u.role='commuter' AND u.deleted_at IS NULL
      ), trip AS (
        SELECT count(*)::int AS total,
          count(*) FILTER (WHERE status='completed')::int AS completed,
          count(*) FILTER (WHERE status='cancelled')::int AS cancelled
        FROM app.trips WHERE service_date BETWEEN $1::date AND $2::date
      ), attendance AS (
        SELECT count(*) FILTER (WHERE r.status='boarded')::int AS boarded,
          count(*) FILTER (WHERE r.status='no_show')::int AS no_show
        FROM app.reservations r WHERE r.service_date BETWEEN $1::date AND $2::date
      ), collected AS (
        SELECT COALESCE(sum(amount_pesewas),0)::bigint AS total FROM app.payment_collections
        WHERE paid_at >= $1::date AND paid_at < ($2::date+1)
      ), refunded AS (
        SELECT COALESCE(sum(amount_pesewas),0)::bigint AS total FROM app.payment_refunds
        WHERE state='processed' AND created_at >= $1::date AND created_at < ($2::date+1)
      ), delivery AS (
        SELECT count(*) FILTER (WHERE state='pending')::int AS pending,
          count(*) FILTER (WHERE state='failed')::int AS failed
        FROM (
          SELECT state FROM app.email_outbox WHERE created_at >= $1::date AND created_at < ($2::date+1)
          UNION ALL
          SELECT state FROM app.push_deliveries WHERE created_at >= $1::date AND created_at < ($2::date+1)
        ) d
      )
      SELECT rider.total AS rider_total,rider.active,rider.paused,rider.restricted,
        trip.total AS trip_total,trip.completed,trip.cancelled,attendance.boarded,attendance.no_show,
        collected.total AS collected,refunded.total AS refunded,delivery.pending,delivery.failed,
        (SELECT count(*)::int FROM app.payment_reviews WHERE state='open') AS open_reviews
      FROM rider,trip,attendance,collected,refunded,delivery`,
        [fromDate, toDate, now],
      )
    ).rows[0]!;
    return {
      status: 200,
      body: {
        data: {
          generatedAt: now.toISOString(),
          fromDate,
          toDate,
          riders: {
            total: row.rider_total,
            active: row.active,
            paused: row.paused,
            restricted: row.restricted,
          },
          trips: {
            total: row.trip_total,
            completed: row.completed,
            cancelled: row.cancelled,
            boarded: row.boarded,
            noShows: row.no_show,
          },
          payments: {
            collected: money(Number(row.collected)),
            refunded: money(Number(row.refunded)),
            openReviews: row.open_reviews,
          },
          delivery: { pending: row.pending, failed: row.failed },
        },
      },
      headers: {},
    };
  }

  const context = `ops:${operation}:${actor.userId}:${query.channel ?? ''}:${query.area ?? ''}:${query.state ?? ''}`;
  const { limit, cursor } = pageInput(query, context, cursors, now);
  const page = (rows: Array<Record<string, any>>) => {
    const visible = rows.slice(0, limit);
    const last = visible.at(-1) as { cursor_time?: string; id?: string } | undefined;
    return {
      rows: visible,
      nextCursor:
        rows.length > limit && last?.cursor_time && last.id
          ? cursors.encode(last.cursor_time, last.id, context, now)
          : null,
    };
  };

  if (operation === 'listOpsOperators') {
    if (Object.keys(query).some((key) => !['cursor', 'limit'].includes(key)))
      fail(400, 'invalid_query', 'Unsupported query parameters.');
    const rows = (
      await client.query(
        `SELECT u.id,u.display_name,u.email,u.version,u.created_at,
        count(DISTINCT pk.id) FILTER (WHERE pk.revoked_at IS NULL)::int AS passkey_count,
        count(DISTINCT s.id) FILTER (WHERE s.revoked_at IS NULL AND s.expires_at>$1)::int AS active_sessions,
        max(pk.last_used_at) AS last_passkey_used_at,
        to_char(u.created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
      FROM app.users u LEFT JOIN app.admin_passkeys pk ON pk.user_id=u.id
      LEFT JOIN app.auth_sessions s ON s.user_id=u.id
      WHERE u.role='admin' AND u.deleted_at IS NULL
        AND ($2::timestamptz IS NULL OR (u.created_at,u.id)<($2::timestamptz,$3::uuid))
      GROUP BY u.id ORDER BY u.created_at DESC,u.id DESC LIMIT $4`,
        [now, cursor?.time ?? null, cursor?.id ?? null, limit + 1],
      )
    ).rows;
    const result = page(rows);
    return {
      status: 200,
      body: {
        data: result.rows.map((r) => ({
          id: r.id,
          displayName: r.display_name || 'Administrator',
          email: r.email ?? null,
          passkeyCount: Number(r.passkey_count),
          activeSessions: Number(r.active_sessions),
          lastPasskeyUsedAt: r.last_passkey_used_at
            ? new Date(r.last_passkey_used_at as string).toISOString()
            : null,
          joinedAt: new Date(r.created_at as string).toISOString(),
          editToken: `"user:${r.id}:${r.version}"`,
        })),
        page: { nextCursor: result.nextCursor },
      },
      headers: {},
    };
  }

  if (operation === 'listOpsDeliveries') {
    if (Object.keys(query).some((key) => !['cursor', 'limit', 'channel', 'state'].includes(key)))
      fail(400, 'invalid_query', 'Unsupported query parameters.');
    const channel = query.channel;
    if (channel !== undefined && channel !== 'email' && channel !== 'push')
      fail(400, 'invalid_query', 'Channel must be email or push.');
    const state = query.state;
    if (
      state !== undefined &&
      !['pending', 'accepted', 'cancelled', 'failed', 'unknown'].includes(state)
    )
      fail(400, 'invalid_query', 'Unsupported delivery state.');
    const rows = (
      await client.query(
        `WITH deliveries AS (
        SELECT id,'email'::text AS channel,kind,user_id,state,attempts,provider_id,failure_code,created_at
        FROM app.email_outbox
        UNION ALL
        SELECT id,'push',CASE WHEN trip_event_id IS NULL THEN 'reservation_prompt' ELSE 'driver_schedule' END,
          user_id,state,attempts,provider_id,failure_code,created_at FROM app.push_deliveries
      ) SELECT *,to_char(created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
      FROM deliveries WHERE ($1::text IS NULL OR channel=$1) AND ($2::text IS NULL OR state=$2)
        AND ($3::timestamptz IS NULL OR (created_at,id)<($3::timestamptz,$4::uuid))
      ORDER BY created_at DESC,id DESC LIMIT $5`,
        [channel ?? null, state ?? null, cursor?.time ?? null, cursor?.id ?? null, limit + 1],
      )
    ).rows;
    const result = page(rows);
    return {
      status: 200,
      body: {
        data: result.rows.map((r) => ({
          id: r.id,
          channel: r.channel,
          kind: r.kind,
          userId: r.user_id,
          state: r.state,
          attempts: Number(r.attempts),
          providerId: r.provider_id ?? null,
          failureCode: r.failure_code ?? null,
          createdAt: new Date(r.created_at as string).toISOString(),
        })),
        page: { nextCursor: result.nextCursor },
      },
      headers: {},
    };
  }

  if (Object.keys(query).some((key) => !['cursor', 'limit', 'area'].includes(key)))
    fail(400, 'invalid_query', 'Unsupported query parameters.');
  const area = query.area;
  const allowedAreas = [
    'catalog',
    'trip',
    'schedule',
    'fleet',
    'driver',
    'membership',
    'boarding',
    'pricing',
    'configuration',
    'security',
  ];
  if (area !== undefined && !allowedAreas.includes(area))
    fail(400, 'invalid_query', 'Unsupported audit area.');
  const rows = (
    await client.query(
      `WITH events AS (
      SELECT id,'trip'::text area,operation action,actor_user_id,trip_id::text target_id,reason,created_at occurred_at FROM app.trip_events
      UNION ALL SELECT id,'schedule',operation,actor_user_id,schedule_id::text,NULL,created_at FROM app.schedule_events
      UNION ALL SELECT id,'catalog',operation,actor_user_id,coalesce(route_id,stop_id,pattern_id,pattern_version_id)::text,reason,created_at FROM app.catalog_events
      UNION ALL SELECT id,'fleet',operation,actor_user_id,coalesce(vehicle_id,incident_id,request_id)::text,NULL,created_at FROM app.fleet_events
      UNION ALL SELECT id,'driver',operation,actor_user_id,driver_id::text,reason,created_at FROM app.driver_events
      UNION ALL SELECT id,'membership',action,actor_user_id,resource_id::text,NULL,occurred_at FROM app.membership_events
      UNION ALL SELECT id,'boarding',method,actor_user_id,reservation_id::text,NULL,occurred_at FROM app.boarding_events
      UNION ALL SELECT id,'pricing',action,actor_user_id,resource_id,NULL,occurred_at FROM app.pricing_events
      UNION ALL SELECT id,'configuration',action,actor_user_id,target,reason,occurred_at FROM app.config_events
      UNION ALL SELECT id,'security',action,actor_user_id,user_id::text,NULL,occurred_at FROM app.admin_passkey_events
    ) SELECT e.*,coalesce(u.display_name,'Administrator') actor_name,
      to_char(e.occurred_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
    FROM events e JOIN app.users u ON u.id=e.actor_user_id
    WHERE ($1::text IS NULL OR e.area=$1)
      AND ($2::timestamptz IS NULL OR (e.occurred_at,e.id)<($2::timestamptz,$3::uuid))
    ORDER BY e.occurred_at DESC,e.id DESC LIMIT $4`,
      [area ?? null, cursor?.time ?? null, cursor?.id ?? null, limit + 1],
    )
  ).rows;
  const result = page(rows);
  return {
    status: 200,
    body: {
      data: result.rows.map((r) => ({
        id: r.id,
        area: r.area,
        action: r.action,
        actorId: r.actor_user_id,
        actorName: r.actor_name,
        targetId: r.target_id,
        reason: r.reason ?? null,
        occurredAt: new Date(r.occurred_at as string).toISOString(),
      })),
      page: { nextCursor: result.nextCursor },
    },
    headers: {},
  };
}
