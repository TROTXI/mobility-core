// Expiry sweep for ended billing periods (#162).
//
// Nothing set `expired` before, so a lapsed subscription stayed active — and
// the one-active-per-user index meant that stale row blocked the rider from
// subscribing again. Does NOT auto-renew: charging without the rider
// initiating it needs a stored mandate we lack (#128).

import { hasEnded, type BillingPeriod } from './period';
import type { Subscription, SubscriptionRepository } from './subscription.repository';

/** What a sweep did. */
export interface RenewalSweepResult {
  /** Subscriptions moved to `expired`. */
  expired: number;
  /** Subscriptions examined. */
  considered: number;
}

/** Collaborators for {@link RenewalService}. */
export interface RenewalDeps {
  subscriptions: SubscriptionRepository;
}

/** Expires subscriptions whose billing period has ended. */
export class RenewalService {
  /** @param deps - the subscription store. */
  constructor(private readonly deps: RenewalDeps) {}

  /**
   * Expire every active subscription whose period has ended. Idempotent —
   * `findEndedPeriods` filters on `status = 'active'`.
   *
   * @param now - the instant to judge against; injectable so the behaviour at
   *   a period boundary is testable without waiting a month.
   * @returns how many were considered and how many expired.
   */
  async sweep(now: Date = new Date()): Promise<RenewalSweepResult> {
    const due = await this.deps.subscriptions.findEndedPeriods(now);
    let expired = 0;

    for (const sub of due) {
      // findEndedPeriods already filters on period_end <= now, but re-checking
      // through the same predicate the rest of the system uses means one
      // definition of "ended" rather than two that can drift.
      if (!this.isDue(sub, now)) continue;
      await this.deps.subscriptions.rollPeriod(sub.id, { status: 'expired' });
      expired++;
    }

    return { expired, considered: due.length };
  }

  /**
   * Whether a subscription's period has ended.
   *
   * @param sub - the subscription.
   * @param now - the instant to judge against.
   * @returns true when the period is over.
   */
  private isDue(sub: Subscription, now: Date): boolean {
    if (!sub.periodStart || !sub.periodEnd) return false;
    const period: BillingPeriod = { start: sub.periodStart, end: sub.periodEnd };
    return hasEnded(period, now);
  }
}
