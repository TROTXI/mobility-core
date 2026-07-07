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

  it('findAll returns every driver', async () => {
    const repo = new InMemoryDriverRepository();
    await repo.create({ fullName: 'A' });
    await repo.create({ fullName: 'B' });
    expect(await repo.findAll()).toHaveLength(2);
  });

  it('update merges a partial patch and can clear a nullable field', async () => {
    const repo = new InMemoryDriverRepository();
    const driver = await repo.create({ fullName: 'Kwame', phone: '+233200000000' });
    const updated = await repo.update(driver.id, { licenseNumber: 'DL-1', phone: null });
    expect(updated).toMatchObject({ fullName: 'Kwame', licenseNumber: 'DL-1', phone: null });
  });

  it('update returns null for an unknown id', async () => {
    const repo = new InMemoryDriverRepository();
    expect(await repo.update('does-not-exist', { fullName: 'x' })).toBeNull();
  });
});
