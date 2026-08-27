// CreditService — month-end conversion of unused rides to Ride Credits (E5,
// ADR-0014). Remaining rides are retired and become pesewas toward the next
// renewal. Both ledgers are append-only and idempotent.
//
// Keyed per PERIOD, not per subscription (#162) — the old key could only ever
// fire once in a subscription lifetime, which is why this was never scheduled.

import { periodRef as makePeriodRef } from '../subscriptions/period';
import type { CreditLedgerRepository } from './credit-ledger.repository';
import type { EntitlementLedgerRepository } from './entitlement-ledger.repository';
import type { SubscriptionRepository } from '../subscriptions/subscription.repository';

/**
 * Per-ride credit value in PESEWAS. PLACEHOLDER (#104) — ~ monthly fee (2000) ÷
 * rides (44). Replaced when E5 pricing lands; wired via server.ts like the other
 * placeholders (subscription fees, rides-per-period).
 */
export const PLACEHOLDER_CREDIT_PESEWAS_PER_RIDE = 45;

/** Collaborators for {@link CreditService}, injected at app wiring. */
export interface CreditServiceDeps {
  entitlements: EntitlementLedgerRepository;
  credits: CreditLedgerRepository;
  subscriptions: SubscriptionRepository;
  /** Pesewas granted per unused ride (placeholder until E5 pricing). */
  creditPesewasPerRide: number;
}

/** Outcome of converting one rider's unused rides. */
export interface ConversionResult {
  userId: string;
  ridesConverted: number;
  creditPesewas: number;
}

/** Totals from a batch conversion run. */
export interface BatchConversionResult {
  /** Riders who had unused rides converted. */
  riders: number;
  /** Total rides retired across all riders. */
  ridesConverted: number;
  /** Total credit minted, in pesewas. */
  creditPesewas: number;
}

/** Month-end unused-ride → Ride Credit conversion (see the file header). */
export class CreditService {
  /** @param deps - the two ledgers, the subscription store, and the per-ride value. */
  constructor(private readonly deps: CreditServiceDeps) {}

  /**
   * Convert one rider's remaining rides to Ride Credits for a period. Idempotent
   * per `periodRef`. Credit is granted BEFORE the rides are retired, so a retry
   * recomputes the same amount, no-ops the granted credit and applies the
   * still-pending debit — converging exactly-once.
   *
   * @param userId - the rider whose unused rides to convert.
   * @param periodRef - a stable id for the ending period, from
   *   {@link makePeriodRef}: `${subscriptionId}:${periodEnd}`. Also the
   *   idempotency key, so re-running within a period is a no-op while the NEXT
   *   period converts normally.
   * @returns how many rides were converted and the credit minted.
   */
  async convertUnusedRides(userId: string, periodRef: string): Promise<ConversionResult> {
    const remaining = await this.deps.entitlements.remainingRides(userId);
    if (remaining <= 0) return { userId, ridesConverted: 0, creditPesewas: 0 };

    const creditPesewas = remaining * this.deps.creditPesewasPerRide;
    const key = `convert:${periodRef}`;
    await this.deps.credits.record({
      userId,
      deltaPesewas: creditPesewas,
      reason: 'month_end_conversion',
      refType: 'period',
      refId: periodRef,
      idempotencyKey: key,
    });
    await this.deps.entitlements.record({
      userId,
      deltaRides: -remaining,
      reason: 'converted',
      refType: 'period',
      refId: periodRef,
      idempotencyKey: key,
    });
    return { userId, ridesConverted: remaining, creditPesewas };
  }

  /**
   * Convert unused rides for subscribers whose period has ENDED — the month-end
   * job. Keyed per period, so a re-run within one is a no-op.
   *
   * @param now - the instant to judge "period has ended" against; injectable
   *   so the boundary is testable without waiting a month.
   * @returns batch totals (riders credited, rides retired, pesewas minted).
   */
  async convertAllActive(now: Date = new Date()): Promise<BatchConversionResult> {
    // Only subscriptions whose period has actually ENDED — not every active
    // rider. Converting mid-period would zero someone who subscribed three
    // days ago and still has a month of travel ahead of them, which is what
    // made this unsafe to schedule at all before #162.
    const subs = await this.deps.subscriptions.findEndedPeriods(now);
    const totals: BatchConversionResult = { riders: 0, ridesConverted: 0, creditPesewas: 0 };
    for (const sub of subs) {
      // Keyed on the PERIOD, not the subscription. The old key (`sub.id`) could
      // only ever fire once in a subscription's lifetime, so month two onwards
      // silently no-opped.
      if (!sub.periodEnd) continue; // pre-#162 row that somehow escaped backfill
      const res = await this.convertUnusedRides(sub.userId, makePeriodRef(sub.id, sub.periodEnd));
      if (res.ridesConverted > 0) {
        totals.riders++;
        totals.ridesConverted += res.ridesConverted;
        totals.creditPesewas += res.creditPesewas;
      }
    }
    return totals;
  }
}
