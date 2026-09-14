import { describe, expect, it } from 'vitest';
import { assertDelivery, readConfig } from '../scripts/payments-staging-smoke.mjs';

const environment = {
  SMOKE_PHASE: 'setup',
  API_BASE_URL: 'https://trotxi-api-staging.onrender.com',
  PAYSTACK_SECRET_KEY: 'sk_test_fake',
  JWT_SECRET: 'fake-test-signing-key',
};
const fixture = 'c6ae9875-0000-4000-8000-000000000001';
describe('staging verification safety guards (no network or database)', () => {
  it('generates isolated fixture identities, and derives a stable route across phases', () => {
    const first = readConfig(environment);
    const second = readConfig(environment);
    expect(first.userId).not.toBe(second.userId);
    expect(first.routeId).not.toBe(second.routeId);
    const continued = readConfig({
      ...environment,
      SMOKE_PHASE: 'verify-delivery',
      FIXTURE_ID: first.userId,
      JWT_SECRET: '',
    });
    expect(continued.routeId).toBe(first.routeId);
    expect(continued.label).toBe(first.label);
  });
  it.each(['verify-delivery', 'replay'])('requires an explicit fixture for %s', (phase) => {
    expect(() => readConfig({ ...environment, SMOKE_PHASE: phase })).toThrow(/fixture UUID/);
    expect(
      readConfig({ ...environment, SMOKE_PHASE: phase, FIXTURE_ID: fixture, JWT_SECRET: '' })
        .userId,
    ).toBe(fixture);
  });
  it.each([
    { PAYSTACK_SECRET_KEY: 'sk_live_fake' },
    { API_BASE_URL: 'https://example.com' },
    { SMOKE_PHASE: 'close-renew' },
    { FIXTURE_ID: 'not-a-uuid' },
    { JWT_SECRET: '' },
  ])('rejects unsafe or invalid configuration %j', (override) => {
    expect(() => readConfig({ ...environment, ...override })).toThrow();
  });
});

describe('automatic-delivery assertions', () => {
  const payment = {
    reference: 'trotxi-test',
    status: 'fulfilled',
    provider_domain: 'test',
    provider_transaction_id: '123',
    purpose: 'subscription',
    currency: 'GHS',
    amount: 26400,
    gross_amount_pesewas: 26400,
    applied_credit_pesewas: 0,
    rides_granted: 44,
  };
  const provider = {
    reference: 'trotxi-test',
    status: 'success',
    domain: 'test',
    id: 123,
    amount: 26400,
    currency: 'GHS',
  };
  const allocations = { count: 1, rides: 44 };
  const events = [{ status: 'processed', is_replay: false }];
  const period = { status: 'open' };
  it('accepts a matched settlement with a processed non-replay event', () => {
    expect(() => assertDelivery(payment, provider, allocations, events, period)).not.toThrow();
  });
  it.each([
    { status: 'pending' },
    { provider_domain: 'live' },
    { provider_transaction_id: '456' },
    { amount: 1 },
    { rides_granted: 88 },
  ])('rejects mismatched payment %j', (override) => {
    expect(() =>
      assertDelivery({ ...payment, ...override }, provider, allocations, events, period),
    ).toThrow();
  });
  it.each([{ domain: 'live' }, { status: 'failed' }, { currency: 'USD' }, { reference: 'other' }])(
    'rejects mismatched provider %j',
    (override) => {
      expect(() =>
        assertDelivery(payment, { ...provider, ...override }, allocations, events, period),
      ).toThrow();
    },
  );
  it('rejects double allocations, replay-only evidence, unfinished inbox work and missing periods', () => {
    expect(() =>
      assertDelivery(payment, provider, { count: 2, rides: 44 }, events, period),
    ).toThrow();
    expect(() => assertDelivery(payment, provider, allocations, [], period)).toThrow();
    expect(() =>
      assertDelivery(
        payment,
        provider,
        allocations,
        [{ status: 'processed', is_replay: true }],
        period,
      ),
    ).toThrow();
    expect(() =>
      assertDelivery(payment, provider, allocations, [...events, { status: 'failed' }], period),
    ).toThrow();
    expect(() => assertDelivery(payment, provider, allocations, events, undefined)).toThrow();
  });
});
