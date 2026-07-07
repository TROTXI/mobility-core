import { describe, expect, it } from 'vitest';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';

describe('InMemoryDriverRepository', () => {
  it('creates a driver and finds it by id', async () => {
    const repo = new InMemoryDriverRepository();
    const created = await repo.create({
      fullName: 'Kwame Mensah',
      phone: '+233200000000',
      licenseNumber: 'DL-0001',
    });

    expect(created.id).toBeTruthy();
    expect(created.fullName).toBe('Kwame Mensah');
    expect(created.phone).toBe('+233200000000');
    expect(created.licenseNumber).toBe('DL-0001');

    const found = await repo.findById(created.id);
    expect(found?.fullName).toBe('Kwame Mensah');
  });

  it('defaults optional contact/license/user fields to null', async () => {
    const repo = new InMemoryDriverRepository();
    const created = await repo.create({ fullName: 'Ama Owusu' });
    expect(created.phone).toBeNull();
    expect(created.licenseNumber).toBeNull();
    expect(created.userId).toBeNull();
  });

  it('returns null for an unknown id', async () => {
    const repo = new InMemoryDriverRepository();
    expect(await repo.findById('does-not-exist')).toBeNull();
  });
});
