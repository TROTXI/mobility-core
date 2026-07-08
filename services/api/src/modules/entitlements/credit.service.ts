// CreditService — month-end conversion of unused rides to Ride Credits (E5, the
// Hybrid Subscription Model / ADR-0014). At the end of a period the rider's
// remaining entitlement rides are worth a credit (in pesewas) toward their next
// renewal; the rides themselves are retired so they don't carry forward. Both
// ledgers are append-only and idempotent — running the job twice is a no-op.
//
// PLACEHOLDER pricing: `creditPesewasPerRide` is a stand-in until E5 pricing is
// decided (see #104 — plan price ÷ entitlement vs a fixed table). The mechanism
// ships now; only the number changes later.

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
   * per `periodRef`: the same key writes both ledgers exactly once. Credit is
   * granted *before* the rides are retired, so a retry re-reads the full
   * remaining, recomputes the identical amount, no-ops the already-granted
   * credit, and applies the (still-pending) debit — converging exactly-once.
   *
   * @param userId - the rider whose unused rides to convert.
   * @param periodRef - a stable id for the ending period (the subscription id);
   *   also the idempotency key, so re-running is a no-op.
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
   * Convert unused rides for every active subscriber — the month-end job. Each
   * rider is keyed by their active subscription id, so a re-run (or a run that
   * partially completed) converges without double-crediting.
   *
   * @returns batch totals (riders credited, rides retired, pesewas minted).
   */
  async convertAllActive(): Promise<BatchConversionResult> {
    const subs = await this.deps.subscriptions.findAllActive();
    const totals: BatchConversionResult = { riders: 0, ridesConverted: 0, creditPesewas: 0 };
    for (const sub of subs) {
      const res = await this.convertUnusedRides(sub.userId, sub.id);
      if (res.ridesConverted > 0) {
        totals.riders++;
        totals.ridesConverted += res.ridesConverted;
        totals.creditPesewas += res.creditPesewas;
      }
    }
    return totals;
  }
}
