import { describe, expect, it } from 'vitest';
import { InMemoryLedgerRepository } from '../src/modules/ledger/ledger.repository';

describe('InMemoryLedgerRepository', () => {
  it('appends an entry', async () => {
    const ledger = new InMemoryLedgerRepository();
    const entry = await ledger.append({
      userId: 'u1',
      delta: 250,
      reason: 'subscription_grant',
      refType: 'payment',
      refId: 'pay-1',
      idempotencyKey: 'grant:pay-1',
    });
    expect(entry.id).toBeTruthy();
    expect(entry.delta).toBe(250);
    expect(entry.reason).toBe('subscription_grant');
    expect(entry.createdAt).toBeInstanceOf(Date);
  });

  it('is idempotent — a repeated key returns the existing entry and does not double-count', async () => {
    const ledger = new InMemoryLedgerRepository();
    const first = await ledger.append({
      userId: 'u1',
      delta: 250,
      reason: 'subscription_grant',
      refType: 'payment',
      idempotencyKey: 'grant:pay-1',
    });
    const again = await ledger.append({
      userId: 'u1',
      delta: 250,
      reason: 'subscription_grant',
      refType: 'payment',
      idempotencyKey: 'grant:pay-1',
    });
    expect(again.id).toBe(first.id);
    expect(await ledger.balanceOf('u1')).toBe(250); // not 500
  });

  it('derives balance as the sum of deltas (grants and debits)', async () => {
    const ledger = new InMemoryLedgerRepository();
    await ledger.append({
      userId: 'u1',
      delta: 250,
      reason: 'subscription_grant',
      refType: 'payment',
      idempotencyKey: 'k1',
    });
    await ledger.append({
      userId: 'u1',
      delta: -3,
      reason: 'boarding',
      refType: 'boarding',
      idempotencyKey: 'k2',
    });
    expect(await ledger.balanceOf('u1')).toBe(247);
  });

  it('returns 0 for a user with no entries', async () => {
    const ledger = new InMemoryLedgerRepository();
    expect(await ledger.balanceOf('nobody')).toBe(0);
  });
});
