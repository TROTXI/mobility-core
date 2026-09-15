import { describe, expect, it } from 'vitest';
import { InMemoryTripPositionRepository } from '../src/modules/mobility/trip-position.repository';

const TRIP_A = '00000000-0000-4000-8000-0000000000a1';
const TRIP_B = '00000000-0000-4000-8000-0000000000b2';

describe('InMemoryTripPositionRepository', () => {
  it('records a fix and returns it as the latest', async () => {
    const repo = new InMemoryTripPositionRepository();
    const fix = await repo.record({ tripId: TRIP_A, latitude: 5.6, longitude: -0.19 });

    expect(fix.id).toBeTruthy();
    expect(fix.recordedAt).toBeInstanceOf(Date);
    expect(fix.receivedAt).toBeInstanceOf(Date);
    expect(fix.clientFixId).toBeNull();
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

  it('preserves capture time and deduplicates a client fix within a trip', async () => {
    const repo = new InMemoryTripPositionRepository();
    const recordedAt = new Date('2026-09-14T10:00:00.000Z');
    const clientFixId = '11111111-1111-4111-8111-111111111111';

    const first = await repo.record({
      tripId: TRIP_A,
      latitude: 5.6,
      longitude: -0.19,
      recordedAt,
      clientFixId,
    });
    const replay = await repo.record({
      tripId: TRIP_A,
      latitude: 9,
      longitude: 9,
      recordedAt: new Date('2026-09-14T10:01:00.000Z'),
      clientFixId,
    });

    expect(replay).toEqual(first);
    expect(first.recordedAt).toEqual(recordedAt);
    expect(await repo.findAllForTrip(TRIP_A)).toHaveLength(1);
  });

  it('orders delayed offline fixes by capture time, not receipt order', async () => {
    const repo = new InMemoryTripPositionRepository();
    await repo.record({
      tripId: TRIP_A,
      latitude: 2,
      longitude: 2,
      recordedAt: new Date('2026-09-14T10:02:00.000Z'),
    });
    await repo.record({
      tripId: TRIP_A,
      latitude: 1,
      longitude: 1,
      recordedAt: new Date('2026-09-14T10:01:00.000Z'),
    });

    expect(await repo.findLatest(TRIP_A)).toMatchObject({ latitude: 2, longitude: 2 });
    expect((await repo.findAllForTrip(TRIP_A)).map((fix) => fix.latitude)).toEqual([1, 2]);
  });
});
