import { describe, expect, it } from 'vitest';
import { CreditService } from '../src/modules/entitlements/credit.service';
import { RenewalService } from '../src/modules/subscriptions/renewal.service';
import { InMemorySubscriptionRepository } from '../src/modules/subscriptions/subscription.repository';
import { InMemoryCreditLedgerRepository } from '../src/modules/entitlements/credit-ledger.repository';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';
import { periodFor, nextPeriod } from '../src/modules/subscriptions/period';

const AUG = new Date('2026-08-12T09:00:00Z');
const CREDIT_PER_RIDE = 45;

async function setup() {
  const subscriptions = new InMemorySubscriptionRepository();
  const credits = new InMemoryCreditLedgerRepository();
  const entitlements = new InMemoryEntitlementLedgerRepository();

  const period = periodFor('monthly', AUG);
  const sub = await subscriptions.create({
    userId: 'rider-1',
    plan: 'monthly',
    routeId: null,
    periodStart: period.start,
    periodEnd: period.end,
  });
  // 44 rides allocated, 13 travelled -> 31 unused.
  await entitlements.record({
    userId: 'rider-1',
    deltaRides: 44,
    reason: 'allocation',
    idempotencyKey: 'alloc-1',
  });
  await entitlements.record({
    userId: 'rider-1',
    deltaRides: -13,
    reason: 'boarding',
    idempotencyKey: 'board-1',
  });

  const credit = new CreditService({
    subscriptions,
    credits,
    entitlements,
    creditPesewasPerRide: CREDIT_PER_RIDE,
  });
  const renewal = new RenewalService({ subscriptions });
  return { subscriptions, credits, entitlements, credit, renewal, sub, period };
}

describe('credit conversion is keyed per period (#162)', () => {
  it('does not convert a rider whose period is still running', async () => {
    // The bug this closes: conversion used to sweep every ACTIVE subscription,
    // so scheduling it would have zeroed someone three days into their month.
    const { credit, entitlements } = await setup();

    const result = await credit.convertAllActive(new Date('2026-08-20T00:00:00Z'));

    expect(result.riders).toBe(0);
    expect(await entitlements.remainingRides('rider-1')).toBe(31);
  });

  it('converts once the period has ended', async () => {
    const { credit, entitlements, period } = await setup();

    const result = await credit.convertAllActive(period.end);

    expect(result.riders).toBe(1);
    expect(result.ridesConverted).toBe(31);
    expect(result.creditPesewas).toBe(31 * CREDIT_PER_RIDE);
    expect(await entitlements.remainingRides('rider-1')).toBe(0);
  });

  it('is a no-op when re-run within the same period', async () => {
    const { credit, credits, period } = await setup();

    await credit.convertAllActive(period.end);
    const second = await credit.convertAllActive(period.end);

    expect(second.riders).toBe(0);
    expect(await credits.balancePesewas('rider-1')).toBe(31 * CREDIT_PER_RIDE);
  });

  it('converts AGAIN in the next period — the month-two case that was broken', async () => {
    // Keyed on sub.id, the second period silently no-opped forever. This is
    // the single most important assertion in the file.
    const { credit, credits, entitlements, subscriptions, sub, period } = await setup();

    await credit.convertAllActive(period.end);

    // Roll into September and travel a little.
    const second = nextPeriod('monthly', period);
    await subscriptions.rollPeriod(sub.id, {
      periodStart: second.start,
      periodEnd: second.end,
    });
    await entitlements.record({
      userId: 'rider-1',
      deltaRides: 44,
      reason: 'allocation',
      idempotencyKey: 'alloc-2',
    });
    await entitlements.record({
      userId: 'rider-1',
      deltaRides: -40,
      reason: 'boarding',
      idempotencyKey: 'board-2',
    });

    const result = await credit.convertAllActive(second.end);

    expect(result.riders).toBe(1);
    expect(result.ridesConverted).toBe(4);
    expect(await credits.balancePesewas('rider-1')).toBe((31 + 4) * CREDIT_PER_RIDE);
  });
});

describe('period-end expiry sweep (#162)', () => {
  it('leaves a running subscription alone', async () => {
    const { renewal, subscriptions } = await setup();

    const result = await renewal.sweep(new Date('2026-08-20T00:00:00Z'));

    expect(result.expired).toBe(0);
    expect(await subscriptions.findActiveByUser('rider-1')).not.toBeNull();
  });

  it('expires a subscription whose period has ended', async () => {
    // Before this, nothing ever set `expired` — and the one-active-per-user
    // index meant the stale row blocked the rider from subscribing again.
    const { renewal, subscriptions, period } = await setup();

    const result = await renewal.sweep(period.end);

    expect(result.expired).toBe(1);
    expect(await subscriptions.findActiveByUser('rider-1')).toBeNull();
  });

  it('lets the rider subscribe again once expired', async () => {
    const { renewal, subscriptions, period } = await setup();
    await renewal.sweep(period.end);

    const fresh = periodFor('monthly', period.end);
    await expect(
      subscriptions.create({
        userId: 'rider-1',
        plan: 'monthly',
        routeId: null,
        periodStart: fresh.start,
        periodEnd: fresh.end,
      }),
    ).resolves.toBeDefined();
  });

  it('is idempotent', async () => {
    const { renewal, period } = await setup();
    await renewal.sweep(period.end);
    expect((await renewal.sweep(period.end)).expired).toBe(0);
  });
});
