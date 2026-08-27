// Billing period arithmetic (#162). Pure and clock-free, so the same inputs
// always give the same period and the awkward dates are testable.
//
// Periods are half-open: [start, end). The instant `end` arrives the period is
// over. Inclusive ends invite off-by-one-second arguments for a rider who
// subscribed at 23:59:59, and there is no good answer to "is 1 Sep 00:00:00 in
// August's period" other than "no".

import type { SubscriptionPlan } from './subscription.repository';

/** A half-open billing window. */
export interface BillingPeriod {
  start: Date;
  /** Exclusive. */
  end: Date;
}

/**
 * Add whole months to a date, clamping the day to the target month's length.
 *
 * JavaScript's `setUTCMonth` overflows instead of clamping: 31 Jan + 1 month
 * becomes 3 March (or 2 March in a leap year), because February has no 31st.
 * A rider who subscribes on the 31st would silently get a period ending in the
 * following month, and their renewal date would drift further every cycle.
 *
 * Clamping to the 28th/29th/30th instead keeps the renewal on or before the
 * anniversary, which is the behaviour every subscription business uses and the
 * one a rider can predict.
 *
 * @param from - the starting instant.
 * @param months - whole months to add.
 * @returns the shifted date, day-clamped.
 */
export function addMonthsClamped(from: Date, months: number): Date {
  const day = from.getUTCDate();
  // Day 1 of the target month, then clamp the day onto it — never overflows.
  const target = new Date(
    Date.UTC(
      from.getUTCFullYear(),
      from.getUTCMonth() + months,
      1,
      from.getUTCHours(),
      from.getUTCMinutes(),
      from.getUTCSeconds(),
      from.getUTCMilliseconds(),
    ),
  );
  const lastDayOfTarget = new Date(
    Date.UTC(target.getUTCFullYear(), target.getUTCMonth() + 1, 0),
  ).getUTCDate();
  target.setUTCDate(Math.min(day, lastDayOfTarget));
  return target;
}

/**
 * The billing period a plan buys, starting now.
 *
 * @param plan - monthly or annual.
 * @param start - when the period begins (activation time).
 * @returns the half-open period.
 */
export function periodFor(plan: SubscriptionPlan, start: Date): BillingPeriod {
  return { start, end: addMonthsClamped(start, plan === 'annual' ? 12 : 1) };
}

/**
 * The period that follows this one, with no gap.
 *
 * The next period starts exactly where the last ended, not "now": renewing a
 * day late must not shift a rider's anniversary forward permanently.
 *
 * @param plan - monthly or annual.
 * @param current - the period ending.
 * @returns the next half-open period.
 */
export function nextPeriod(plan: SubscriptionPlan, current: BillingPeriod): BillingPeriod {
  return periodFor(plan, current.end);
}

/**
 * Whether a period has ended as of `now`.
 *
 * @param period - the period to test.
 * @param now - the current instant.
 * @returns true when `now` is at or past the exclusive end.
 */
export function hasEnded(period: BillingPeriod, now: Date): boolean {
  return now.getTime() >= period.end.getTime();
}

/**
 * A stable identifier for one period of one subscription.
 *
 * This is the fix at the heart of #162. Conversion was keyed on the
 * subscription id alone, so it could only ever run once in that
 * subscription's lifetime — scheduling it would zero a rider who subscribed
 * days earlier, then no-op forever afterwards. Including the period end makes
 * the key unique per cycle, which is what lets the job run every month and
 * still be safe to retry within one.
 *
 * @param subscriptionId - the subscription.
 * @param periodEnd - the period's exclusive end.
 * @returns a key stable for that period and no other.
 */
export function periodRef(subscriptionId: string, periodEnd: Date): string {
  return `${subscriptionId}:${periodEnd.toISOString()}`;
}
