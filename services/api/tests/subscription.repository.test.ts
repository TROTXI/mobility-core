import { describe, expect, it } from 'vitest';
import { InMemorySubscriptionRepository } from '../src/modules/subscriptions/subscription.repository';

describe('InMemorySubscriptionRepository', () => {
  it('creates a subscription with active status and returns it', async () => {
    const repo = new InMemorySubscriptionRepository();
    const created = await repo.create({ userId: 'user-1', plan: 'monthly' });

    expect(created.id).toBeTruthy();
    expect(created.userId).toBe('user-1');
    expect(created.plan).toBe('monthly');
    expect(created.status).toBe('active');
    expect(created.createdAt).toBeInstanceOf(Date);
  });

  it('finds the active subscription for a user', async () => {
    const repo = new InMemorySubscriptionRepository();
    await repo.create({ userId: 'user-1', plan: 'monthly' });

    const found = await repo.findActiveByUser('user-1');
    expect(found?.plan).toBe('monthly');
  });

  it('returns null when the user has no active subscription', async () => {
    const repo = new InMemorySubscriptionRepository();
    expect(await repo.findActiveByUser('user-1')).toBeNull();
  });

  it('returns null for a different user', async () => {
    const repo = new InMemorySubscriptionRepository();
    await repo.create({ userId: 'user-1', plan: 'monthly' });

    expect(await repo.findActiveByUser('user-2')).toBeNull();
  });
});
