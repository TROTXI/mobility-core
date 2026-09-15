import { test } from 'node:test';
import assert from 'node:assert/strict';
import { billingEnd, priceTerms } from '../src/payments/terms.js';
test('FIN-U01: baseline price and rounding are preserved with exact integer arithmetic', () => {
  assert.deepEqual(
    priceTerms({
      farePesewas: 600,
      ridesGranted: 44,
      priceMultiplierBp: 10000,
      conversionRatePesewas: 45,
    }),
    {
      pricePesewas: 26400,
      farePesewas: 600,
      ridesGranted: 44,
      priceMultiplierBp: 10000,
      conversionRatePesewas: 45,
    },
  );
  assert.equal(
    priceTerms({
      farePesewas: 101,
      ridesGranted: 1,
      priceMultiplierBp: 15000,
      conversionRatePesewas: 0,
    }).pricePesewas,
    152,
  );
  for (const value of [NaN, Infinity, 1.5, -1, 2147483648])
    assert.throws(() =>
      priceTerms({
        farePesewas: value,
        ridesGranted: 44,
        priceMultiplierBp: 10000,
        conversionRatePesewas: 45,
      }),
    );
  assert.throws(() =>
    priceTerms({
      farePesewas: 1,
      ridesGranted: 1,
      priceMultiplierBp: 10000,
      conversionRatePesewas: 0,
    }),
  );
  assert.throws(() =>
    priceTerms({
      farePesewas: 2147483647,
      ridesGranted: 2147483647,
      priceMultiplierBp: 2147483647,
      conversionRatePesewas: 0,
    }),
  );
});
test('FIN-U02: monthly/annual UTC periods clamp end of month and preserve time', () => {
  assert.equal(
    billingEnd('monthly', new Date('2026-01-31T12:34:56.789Z')).toISOString(),
    '2026-02-28T12:34:56.789Z',
  );
  assert.equal(
    billingEnd('annual', new Date('2024-02-29T00:00:00Z')).toISOString(),
    '2025-02-28T00:00:00.000Z',
  );
});
