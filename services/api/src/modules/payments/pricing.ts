// Deriving what a rider pays and what an operator earns (#103, ADR-0015).
//
// Pure functions over integers. No floats anywhere: rates are basis points
// (10000 = 1.0) and money is pesewas, matching the rest of the money system
// (ADR-0011). A rate that cannot be represented exactly becomes a rounding
// argument with an operator about a month of payouts.
//
//   rider price     = fare x rides per period x multiplier
//   operator payout = fare x rides DELIVERED  x (1 - take rate)
//   trotxi revenue  = rider price - operator payout
//
// Note the asymmetry in the middle term: the rider buys rides, the operator is
// paid for seats actually run. A rider who buys 44 and travels 31 costs us 31
// payouts. That gap is where the margin lives, and it is why the entitlement
// ledger separates `boarding` from `no_show`.

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
 * Rounding is explicit rather than inherited from float behaviour: at parity
 * the result is exact, and away from parity a rider should never be charged a
 * fraction of a pesewa that Paystack cannot represent.
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
 * What the operator earns for the seats they actually ran.
 *
 * Delivered rides, not rides sold — see the file header.
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
 * Our revenue on a subscription, given how much of it was actually travelled.
 *
 * Worth computing rather than assuming: at parity with a zero take rate this is
 * exactly the value of the rides the rider did not use, which is a
 * uncomfortable business to be in and better seen than discovered.
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
