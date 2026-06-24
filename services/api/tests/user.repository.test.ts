import { describe, expect, it } from 'vitest';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';

describe('InMemoryUserRepository', () => {
  it('creates a user with defaults and finds it by id', async () => {
    const repo = new InMemoryUserRepository();
    const created = await repo.create({ displayName: 'Ama', phone: '+233200000000' });

    expect(created.id).toBeTruthy();
    expect(created.role).toBe('commuter'); // default
    expect(created.avatarUrl).toBeNull();

    const found = await repo.findById(created.id);
    expect(found?.displayName).toBe('Ama');
    expect(found?.phone).toBe('+233200000000');
  });

  it('honours an explicit role', async () => {
    const repo = new InMemoryUserRepository();
    const driver = await repo.create({ displayName: 'Kofi', role: 'driver' });
    expect(driver.role).toBe('driver');
  });

  it('returns null for an unknown id', async () => {
    const repo = new InMemoryUserRepository();
    expect(await repo.findById('does-not-exist')).toBeNull();
  });
});
