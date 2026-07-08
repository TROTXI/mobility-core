import { describe, expect, it } from 'vitest';
import { InMemoryMinVersionRepository } from '../src/modules/flags/min-version.repository';

describe('InMemoryMinVersionRepository', () => {
  it('sets and gets a platform minimum version', async () => {
    const repo = new InMemoryMinVersionRepository();
    const row = await repo.set('ios', '1.2.0');
    expect(row).toMatchObject({ platform: 'ios', version: '1.2.0' });
    expect(row.updatedAt).toBeInstanceOf(Date);
    expect(await repo.get('ios')).toMatchObject({ version: '1.2.0' });
  });

  it('set replaces the existing version for a platform', async () => {
    const repo = new InMemoryMinVersionRepository();
    await repo.set('android', '1.0.0');
    await repo.set('android', '1.5.0');
    expect(await repo.get('android')).toMatchObject({ version: '1.5.0' });
    expect(await repo.findAll()).toHaveLength(1);
  });

  it('get returns null for an unconfigured platform', async () => {
    const repo = new InMemoryMinVersionRepository();
    expect(await repo.get('ios')).toBeNull();
  });

  it('findAll returns every configured platform ordered by name', async () => {
    const repo = new InMemoryMinVersionRepository();
    await repo.set('ios', '2.0.0');
    await repo.set('android', '1.0.0');
    expect((await repo.findAll()).map((v) => v.platform)).toEqual(['android', 'ios']);
  });
});
