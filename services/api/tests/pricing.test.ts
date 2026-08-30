import { describe, expect, it } from 'vitest';
import {
  applyBp,
  BASIS_POINTS,
  derivePrice,
  deriveOperatorPayout,
  deriveRevenue,
  MIN_CHARGE_PESEWAS,
  netCharge,
  type PlanPricing,
} from '../src/modules/payments/pricing';

/** GHS 6 a trip, 44 rides — a plausible Accra month. */
const FARE = 600;
const PARITY: PlanPricing = {
  ridesPerPeriod: 44,
  priceMultiplierBp: BASIS_POINTS,
  takeRateBp: 0,
  creditPesewasPerRide: 45,
};

describe('applyBp', () => {
  it('is exact at parity', () => {
    expect(applyBp(26_400, BASIS_POINTS)).toBe(26_400);
  });

  it('returns whole pesewas — Paystack cannot charge a fraction', () => {
    // 333 bp of 1000 is 33.3 pesewas; a float would leak the .3 into a total.
    expect(Number.isInteger(applyBp(1000, 333))).toBe(true);
    expect(applyBp(1000, 333)).toBe(33);
  });
});

describe('derivePrice', () => {
  it('prices a month at the corridor fare when the multiplier is parity', () => {
    const price = derivePrice(FARE, PARITY);
    // Exactly what the rider already spends: 600 × 44 = GHS 264.
    expect(price.pricePesewas).toBe(26_400);
    expect(price.ridesGranted).toBe(44);
  });

  it('carries the fare through for the audit trail', () => {
    // Answers "why did this rider pay that" after the fare has moved twice.
    expect(derivePrice(FARE, PARITY).farePesewas).toBe(FARE);
  });

  it('supports a discount, parity and a premium — the multiplier is not a discount', () => {
    const discounted = derivePrice(FARE, { ...PARITY, priceMultiplierBp: 9_000 });
    const parity = derivePrice(FARE, PARITY);
    const premium = derivePrice(FARE, { ...PARITY, priceMultiplierBp: 11_000 });

    expect(discounted.pricePesewas).toBeLessThan(parity.pricePesewas);
    expect(premium.pricePesewas).toBeGreaterThan(parity.pricePesewas);
  });

  it('recomputes when the fare moves — prices are derived, never stored', () => {
    const before = derivePrice(600, PARITY).pricePesewas;
    const after = derivePrice(700, PARITY).pricePesewas;
    expect(after).toBeGreaterThan(before);
  });
});

describe('deriveOperatorPayout', () => {
  it('pays the whole fare through when we take nothing', () => {
    expect(deriveOperatorPayout(FARE, 31, 0)).toBe(FARE * 31);
  });

  it('withholds our share', () => {
    // 20% take on 31 delivered rides.
    expect(deriveOperatorPayout(FARE, 31, 2_000)).toBe(FARE * 31 * 0.8);
  });

  it('pays for rides DELIVERED, not rides sold', () => {
    // The rider bought 44 and travelled 31. The operator carried 31 seats.
    const sold = deriveOperatorPayout(FARE, 44, 2_000);
    const delivered = deriveOperatorPayout(FARE, 31, 2_000);
    expect(delivered).toBeLessThan(sold);
  });
});

describe('deriveRevenue', () => {
  it('at parity with a zero take rate, revenue is exactly the unused rides', () => {
    // Worth seeing rather than discovering: with no take rate we earn only what
    // riders did not travel, which is an uncomfortable business to be in.
    const price = derivePrice(FARE, PARITY);
    expect(deriveRevenue(price, 31, 0)).toBe(FARE * (44 - 31));
  });

  it('a take rate earns on every delivered ride, not just the unused ones', () => {
    const price = derivePrice(FARE, PARITY);
    expect(deriveRevenue(price, 31, 2_000)).toBeGreaterThan(deriveRevenue(price, 31, 0));
  });

  it('a fully-travelled month at parity with no take rate earns nothing', () => {
    const price = derivePrice(FARE, PARITY);
    expect(deriveRevenue(price, 44, 0)).toBe(0);
  });

  it('goes negative when the take rate cannot cover a premium-free month', () => {
    // A rider who somehow travels more than they bought (standby, goodwill)
    // costs us money. The formula must show that rather than clamp it.
    const price = derivePrice(FARE, PARITY);
    expect(deriveRevenue(price, 50, 0)).toBeLessThan(0);
  });
});

describe('netCharge', () => {
  it('applies the whole balance when it is comfortably under the price', () => {
    expect(netCharge(26_400, 5_000)).toEqual({
      appliedCreditPesewas: 5_000,
      chargePesewas: 21_400,
    });
  });

  it('applies nothing when the rider has no credit', () => {
    expect(netCharge(26_400, 0)).toEqual({ appliedCreditPesewas: 0, chargePesewas: 26_400 });
  });

  it('leaves the Paystack floor payable rather than charging zero', () => {
    expect(netCharge(26_400, 30_000)).toEqual({
      appliedCreditPesewas: 26_400 - MIN_CHARGE_PESEWAS,
      chargePesewas: MIN_CHARGE_PESEWAS,
    });
  });

  it('applies nothing when the price is already at or below the floor', () => {
    expect(netCharge(MIN_CHARGE_PESEWAS, 9_999)).toEqual({
      appliedCreditPesewas: 0,
      chargePesewas: MIN_CHARGE_PESEWAS,
    });
  });
});
