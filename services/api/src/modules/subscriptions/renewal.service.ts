// What happens when a billing period ends (#162).
//
// Nothing did this before. `status` could be 'expired' but no job ever set it,
// so a lapsed subscription stayed 'active' forever — and because of the partial
// unique index (003_subscriptions_constraints), that stale row also blocked the
// rider from ever subscribing again. Their only route back was an admin
// deleting a row by hand.
//
// This sweep expires them. It deliberately does NOT auto-renew: taking money
// without the rider initiating it needs a stored mandate we do not have, and
// #128 (E5b, credit-netted renewal) is where that belongs. Expiring is the
// honest half we can do correctly today.

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
   * Expire every active subscription whose period has ended.
   *
   * Idempotent: an already-expired subscription is not returned by
   * `findEndedPeriods` (it filters on `status = 'active'`), so re-running is a
   * no-op rather than a double transition.
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
