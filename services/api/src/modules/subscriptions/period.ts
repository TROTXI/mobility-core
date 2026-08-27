// Billing period arithmetic (#162). Pure and clock-free.

import type { SubscriptionPlan } from './subscription.repository';

/** A half-open billing window: `[start, end)`. */
export interface BillingPeriod {
  start: Date;
  /** Exclusive. */
  end: Date;
}

/**
 * Add whole months, clamping the day to the target month's length.
 *
 * `setUTCMonth` overflows instead: 31 Jan + 1 month becomes 3 March, so a rider
 * subscribing on the 31st would see their renewal drift every cycle.
 *
 * @param from - the starting instant.
 * @param months - whole months to add.
 * @returns the shifted date, day-clamped.
 */
export function addMonthsClamped(from: Date, months: number): Date {
  const day = from.getUTCDate();
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
  const lastDay = new Date(
    Date.UTC(target.getUTCFullYear(), target.getUTCMonth() + 1, 0),
  ).getUTCDate();
  target.setUTCDate(Math.min(day, lastDay));
  return target;
}

/**
 * The billing period a plan buys.
 *
 * @param plan - monthly or annual.
 * @param start - when the period begins.
 * @returns the half-open period.
 */
export function periodFor(plan: SubscriptionPlan, start: Date): BillingPeriod {
  return { start, end: addMonthsClamped(start, plan === 'annual' ? 12 : 1) };
}

/**
 * The period following this one, with no gap.
 *
 * Starts where the last ended, not "now" — renewing late must not shift a
 * rider's anniversary permanently.
 *
 * @param plan - monthly or annual.
 * @param current - the period ending.
 * @returns the next half-open period.
 */
export function nextPeriod(plan: SubscriptionPlan, current: BillingPeriod): BillingPeriod {
  return periodFor(plan, current.end);
}

/**
 * Whether a period has ended.
 *
 * @param period - the period to test.
 * @param now - the current instant.
 * @returns true when `now` is at or past the exclusive end.
 */
export function hasEnded(period: BillingPeriod, now: Date): boolean {
  return now.getTime() >= period.end.getTime();
}

/**
 * Idempotency key for one period of one subscription.
 *
 * Includes the period end because keying on the subscription alone let
 * conversion fire only once in its lifetime (#162).
 *
 * @param subscriptionId - the subscription.
 * @param periodEnd - the period's exclusive end.
 * @returns a key unique to that period.
 */
export function periodRef(subscriptionId: string, periodEnd: Date): string {
  return `${subscriptionId}:${periodEnd.toISOString()}`;
}
