// Paged lists of requests, slots, reservations and request events.
import type { PoolClient } from 'pg';
import type { Actor, Outcome } from '../transport/service.js';
import { canonical } from '../transport/service.js';
import { fail } from '../transport/errors.js';
import { date, id, iso, ops, type MembershipCore, type MembershipOperation } from './core.js';

export async function listMembership(
  m: MembershipCore,
  c: PoolClient,
  actor: Actor,
  op: MembershipOperation,
  query: Record<string, string | undefined>,
  target: string | undefined,
): Promise<Outcome> {
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
    const today = date(m.now());
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
  const context = canonical([actor.userId, op, target ? id(target) : null, `${clock},id`, filters]);
  const cursor = query.cursor ? m.cursors.decode(query.cursor, context, m.now()) : null;
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
        ? await m.slotView(c, r)
        : table === 'reservations'
          ? m.reservationView(r)
          : table === 'membership_events'
            ? { id: r.id, action: r.action, note: null, occurredAt: iso(r.occurred_at) }
            : await m.requestView(c, r, ops(op)),
    );
  const last = rows[limit - 1];
  return {
    status: 200,
    body: {
      data,
      page: {
        nextCursor:
          rows.length > limit
            ? m.cursors.encode(last.cursor_time, last.id, context, m.now())
            : null,
      },
    },
    headers: {},
  } as Outcome;
}
