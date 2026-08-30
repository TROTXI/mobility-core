// Pricing arithmetic (#103, ADR-0015). Integers only: rates are basis points
// (10000 = 1.0), money is pesewas.
//
//   rider price     = fare x rides per period x multiplier
//   operator payout = fare x rides DELIVERED  x (1 - take rate)
//
// The rider buys rides; the operator is paid for seats actually run. That gap
// is the margin.

/** One basis point is 1/10000. 10000 bp = 1.0 = parity. */
export const BASIS_POINTS = 10_000;

/** The ops-editable levers for one plan. Mirrors the plan_pricing row. */
export interface PlanPricing {
  ridesPerPeriod: number;
  /** What the rider pays relative to spot. 10000 = parity (ADR-0015 §4). */
  priceMultiplierBp: number;
  /** Our share of the fare, in basis points. */
  takeRateBp: number;
  /** What one unused ride converts to at period end. */
  creditPesewasPerRide: number;
}

/** A priced plan, ready to charge and to snapshot onto the subscription. */
export interface DerivedPrice {
  /** What the rider is charged, in pesewas. */
  pricePesewas: number;
  /** Rides granted for the period. */
  ridesGranted: number;
  /** The corridor fare this was derived from, for the audit trail. */
  farePesewas: number;
  /** Credit value per unused ride, frozen with the rest. */
  creditPesewasPerRide: number;
}

/**
 * Multiply a pesewa amount by a basis-point rate, rounding half up.
 *
 * Explicit rounding: Paystack cannot charge a fraction of a pesewa.
 *
 * @param pesewas - the amount to scale.
 * @param bp - the rate in basis points.
 * @returns the scaled amount in whole pesewas.
 */
export function applyBp(pesewas: number, bp: number): number {
  return Math.round((pesewas * bp) / BASIS_POINTS);
}

/**
 * What a rider pays for a plan on a corridor.
 *
 * @param farePesewas - the corridor's fare in force.
 * @param pricing - the plan's ops-configured levers.
 * @returns the price plus everything to snapshot alongside it.
 */
export function derivePrice(farePesewas: number, pricing: PlanPricing): DerivedPrice {
  const spend = farePesewas * pricing.ridesPerPeriod;
  return {
    pricePesewas: applyBp(spend, pricing.priceMultiplierBp),
    ridesGranted: pricing.ridesPerPeriod,
    farePesewas,
    creditPesewasPerRide: pricing.creditPesewasPerRide,
  };
}

/**
 * Smallest amount we will send to Paystack. Below this a charge is not worth
 * attempting, so credit is capped to leave at least this much payable and the
 * remainder stays in the ledger for the next renewal.
 */
export const MIN_CHARGE_PESEWAS = 100;

/** How a checkout splits between Ride Credit and money. */
export interface NettedCharge {
  /** Credit to debit on success. */
  appliedCreditPesewas: number;
  /** What Paystack is asked for. */
  chargePesewas: number;
}

/**
 * Split a price between the rider's credit balance and money.
 *
 * Credit never takes the charge below {@link MIN_CHARGE_PESEWAS}: the unused
 * remainder is not lost, it simply stays on the ledger for the next renewal.
 *
 * @param pricePesewas - the derived price for the period.
 * @param creditBalancePesewas - the rider's current Ride Credit balance.
 * @returns how much credit is applied and how much is charged.
 */
export function netCharge(pricePesewas: number, creditBalancePesewas: number): NettedCharge {
  const spendable = Math.max(0, Math.min(creditBalancePesewas, pricePesewas - MIN_CHARGE_PESEWAS));
  return { appliedCreditPesewas: spendable, chargePesewas: pricePesewas - spendable };
}

/**
 * What the operator earns for the seats actually run.
 *
 * @param farePesewas - the fare in force when the rides were delivered.
 * @param ridesDelivered - seats actually carried.
 * @param takeRateBp - our share, in basis points.
 * @returns the operator's payout in pesewas.
 */
export function deriveOperatorPayout(
  farePesewas: number,
  ridesDelivered: number,
  takeRateBp: number,
): number {
  const gross = farePesewas * ridesDelivered;
  return gross - applyBp(gross, takeRateBp);
}

/**
 * Revenue on a subscription, given how much was actually travelled.
 *
 * At parity with a zero take rate this equals the value of unused rides.
 *
 * @param price - the derived price the rider paid.
 * @param ridesDelivered - seats actually carried in the period.
 * @param takeRateBp - our share, in basis points.
 * @returns revenue in pesewas; negative means the period lost money.
 */
export function deriveRevenue(
  price: DerivedPrice,
  ridesDelivered: number,
  takeRateBp: number,
): number {
  const payout = deriveOperatorPayout(price.farePesewas, ridesDelivered, takeRateBp);
  return price.pricePesewas - payout;
}
