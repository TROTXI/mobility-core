// The rider membership view: coverage, commute, access and balances.
import type { PoolClient } from 'pg';
import { fail } from '../transport/errors.js';
import { date, dayString, iso, type MembershipCore } from './core.js';

export async function membership(m: MembershipCore, c: PoolClient, userId: string) {
  await c.query('SELECT app.settle_personal_pauses($1)', [userId]);
  const row = (await c.query('SELECT * FROM app.memberships WHERE user_id=$1', [userId])).rows[0];
  const now = m.now();
  const periods = (
    await c.query(
      "SELECT * FROM app.billing_periods WHERE user_id=$1 AND state='open' ORDER BY starts_at",
      [userId],
    )
  ).rows;
  const b = periods.filter((p) => p.starts_at <= now).at(-1);
  const upcoming = periods.find((p) => p.starts_at > now);
  const blocks = await m.blocks(c, userId, b?.id ?? null),
    paused = blocks.some((x) => x.kind === 'paused');
  const current = b && b.starts_at <= now && (b.effective_ends_at > now || paused) ? b : null;
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
    membership: row ? { id: row.id, lifecycle: row.lifecycle } : null,
    upcomingCoverage: upcoming
      ? {
          id: upcoming.id,
          startsAt: iso(upcoming.starts_at),
          endsAt: iso(upcoming.effective_ends_at),
          state: upcoming.state,
          paused: false,
          renewalMode: 'manual',
        }
      : null,
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
          ...(await m.selectionView(c, a.selection_id, true)),
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
