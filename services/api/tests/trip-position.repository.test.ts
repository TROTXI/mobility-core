import { describe, expect, it } from 'vitest';
import { InMemoryTripPositionRepository } from '../src/modules/mobility/trip-position.repository';

const TRIP_A = '00000000-0000-0000-0000-0000000000a1';
const TRIP_B = '00000000-0000-0000-0000-0000000000b2';

describe('InMemoryTripPositionRepository', () => {
  it('records a fix and returns it as the latest', async () => {
    const repo = new InMemoryTripPositionRepository();
    const fix = await repo.record({ tripId: TRIP_A, latitude: 5.6, longitude: -0.19 });

    expect(fix.id).toBeTruthy();
    expect(fix.recordedAt).toBeInstanceOf(Date);
    const latest = await repo.findLatest(TRIP_A);
    expect(latest).toMatchObject({ tripId: TRIP_A, latitude: 5.6, longitude: -0.19 });
  });

  it('findLatest returns the most recently recorded fix', async () => {
    const repo = new InMemoryTripPositionRepository();
    await repo.record({ tripId: TRIP_A, latitude: 1, longitude: 1 });
    await repo.record({ tripId: TRIP_A, latitude: 2, longitude: 2 });
    await repo.record({ tripId: TRIP_A, latitude: 3, longitude: 3 });

    const latest = await repo.findLatest(TRIP_A);
    expect(latest).toMatchObject({ latitude: 3, longitude: 3 });
  });

  it('isolates fixes by trip', async () => {
    const repo = new InMemoryTripPositionRepository();
    await repo.record({ tripId: TRIP_A, latitude: 1, longitude: 1 });
    await repo.record({ tripId: TRIP_B, latitude: 9, longitude: 9 });

    expect(await repo.findLatest(TRIP_A)).toMatchObject({ latitude: 1 });
    expect(await repo.findLatest(TRIP_B)).toMatchObject({ latitude: 9 });
  });

  it('returns null when a trip has no fixes', async () => {
    const repo = new InMemoryTripPositionRepository();
    expect(await repo.findLatest(TRIP_A)).toBeNull();
  });
});
