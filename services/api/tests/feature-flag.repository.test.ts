import { describe, expect, it } from 'vitest';
import { InMemoryFeatureFlagRepository } from '../src/modules/flags/feature-flag.repository';

describe('InMemoryFeatureFlagRepository', () => {
  it('creates a flag with defaults (disabled, 100% rollout, no description)', async () => {
    const repo = new InMemoryFeatureFlagRepository();
    const flag = await repo.upsert('live_positions', {});
    expect(flag).toMatchObject({
      key: 'live_positions',
      enabled: false,
      rolloutPercentage: 100,
      description: null,
    });
    expect(flag.updatedAt).toBeInstanceOf(Date);
  });

  it('creates a flag with the provided values', async () => {
    const repo = new InMemoryFeatureFlagRepository();
    const flag = await repo.upsert('beta_ui', {
      enabled: true,
      rolloutPercentage: 25,
      description: 'gradual UI rollout',
    });
    expect(flag).toMatchObject({
      key: 'beta_ui',
      enabled: true,
      rolloutPercentage: 25,
      description: 'gradual UI rollout',
    });
  });

  it('upsert merges a partial patch over an existing flag', async () => {
    const repo = new InMemoryFeatureFlagRepository();
    await repo.upsert('beta_ui', { enabled: true, rolloutPercentage: 25 });
    const updated = await repo.upsert('beta_ui', { enabled: false });
    // enabled changes; rolloutPercentage is left unchanged.
    expect(updated).toMatchObject({ key: 'beta_ui', enabled: false, rolloutPercentage: 25 });
  });

  it('findByKey returns null for an unknown key', async () => {
    const repo = new InMemoryFeatureFlagRepository();
    expect(await repo.findByKey('nope')).toBeNull();
  });

  it('findAll returns every flag ordered by key', async () => {
    const repo = new InMemoryFeatureFlagRepository();
    await repo.upsert('zebra', {});
    await repo.upsert('alpha', {});
    const keys = (await repo.findAll()).map((f) => f.key);
    expect(keys).toEqual(['alpha', 'zebra']);
  });
});
