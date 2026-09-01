import { describe, expect, it } from 'vitest';
import {
  InMemoryReservationRepository,
  type ReservationResponse,
} from '../src/modules/reservations/reservation.repository';

const TRIP = 'aaaaaaaa-1111-4111-8111-aaaaaaaaaaaa';
const DATE = '2026-08-26';

function confirm(userId: string, tripId: string | null = TRIP): ReservationResponse {
  return {
    userId,
    tripId,
    travelDate: DATE,
    direction: 'morning',
    travelling: true,
    pinHash: null,
  };
}

describe('seat capacity on confirmation (#161)', () => {
  it('refuses a rider once the vehicle is full', async () => {
    const repo = new InMemoryReservationRepository();
    // A 2-seat bus.
    expect(await repo.respondWithinCapacity(confirm('u1'), 2)).not.toBeNull();
    expect(await repo.respondWithinCapacity(confirm('u2'), 2)).not.toBeNull();
    expect(await repo.respondWithinCapacity(confirm('u3'), 2)).toBeNull();
  });

  it('lets a rider re-confirm a seat they already hold', async () => {
    // Re-confirming is not a new seat; refusing it would strand a rider who
    // taps the push twice on a full bus they are already on.
    const repo = new InMemoryReservationRepository();
    await repo.respondWithinCapacity(confirm('u1'), 1);
    expect(await repo.respondWithinCapacity(confirm('u1'), 1)).not.toBeNull();
  });

  it('never refuses a decline', async () => {
    const repo = new InMemoryReservationRepository();
    await repo.respondWithinCapacity(confirm('u1'), 1);
    const declined = await repo.respondWithinCapacity({ ...confirm('u2'), travelling: false }, 1);
    expect(declined?.status).toBe('declined');
  });

  it('frees the seat when a rider declines after confirming', async () => {
    const repo = new InMemoryReservationRepository();
    await repo.respondWithinCapacity(confirm('u1'), 1);
    await repo.respondWithinCapacity({ ...confirm('u1'), travelling: false }, 1);

    expect(await repo.countSeatsTaken(TRIP)).toBe(0);
    expect(await repo.respondWithinCapacity(confirm('u2'), 1)).not.toBeNull();
  });

  it('counts only reserved and boarded against the ceiling', async () => {
    // A no-show has already been charged for a seat the vehicle no longer needs
    // to hold, so it must not keep occupying one.
    const repo = new InMemoryReservationRepository();
    const r1 = await repo.respondWithinCapacity(confirm('u1'), 5);
    const r2 = await repo.respondWithinCapacity(confirm('u2'), 5);
    await repo.markBoarded(r1!.id);
    await repo.markNoShow(r2!.id);

    expect(await repo.countSeatsTaken(TRIP)).toBe(1);
  });

  it('does not constrain a trip with no vehicle assigned', async () => {
    // Ops routinely creates trips before crewing them; treating that as zero
    // would stop anyone reserving until a bus was attached.
    const repo = new InMemoryReservationRepository();
    for (const u of ['u1', 'u2', 'u3']) {
      expect(await repo.respond(confirm(u, null))).not.toBeNull();
    }
  });
});

describe('cutoff default-yes respects capacity', () => {
  /** Seed `n` pending reservations on the trip. */
  async function pending(repo: InMemoryReservationRepository, n: number) {
    for (let i = 0; i < n; i++) {
      await repo.createPending({
        userId: `p${i}`,
        tripId: TRIP,
        travelDate: DATE,
        direction: 'morning',
      });
    }
  }

  it('does not default riders into seats that do not exist', async () => {
    // The bug this closes: at 21:00 the cutoff used to flip every pending
    // rider to reserved regardless of the bus, making an overfull trip worse
    // with nobody watching.
    const repo = new InMemoryReservationRepository();
    await repo.respondWithinCapacity(confirm('confirmed'), 3);
    await pending(repo, 5);

    const result = await repo.markDefaultTravelling(DATE, 'morning', async () => 3);

    expect(result.defaulted).toBe(2); // 3 seats, 1 already taken
    expect(result.skippedFull).toBe(3);
    expect(await repo.countSeatsTaken(TRIP)).toBe(3);
  });

  it('defaults everyone when no capacity resolver is supplied', async () => {
    const repo = new InMemoryReservationRepository();
    await pending(repo, 4);
    const result = await repo.markDefaultTravelling(DATE, 'morning');
    expect(result).toEqual({ defaulted: 4, skippedFull: 0 });
  });

  it('treats an unlimited trip as unlimited', async () => {
    const repo = new InMemoryReservationRepository();
    await pending(repo, 4);
    const result = await repo.markDefaultTravelling(DATE, 'morning', async () => null);
    expect(result).toEqual({ defaulted: 4, skippedFull: 0 });
  });

  it('marks the riders it could not seat `unseated`, not `pending` (#210)', async () => {
    // Leaving them pending was the bug: the app kept asking them to confirm a
    // seat that no longer existed, and nothing ever explained why.
    const repo = new InMemoryReservationRepository();
    await pending(repo, 4);

    await repo.markDefaultTravelling(DATE, 'morning', async () => 2);

    const statuses = (await repo.listForTrip(TRIP)).map((r) => r.status).sort();
    expect(statuses).toEqual(['reserved', 'reserved', 'unseated', 'unseated']);
    expect(await repo.listReserved(DATE, 'morning')).toHaveLength(2);
  });

  it('unseats the riders asked last, keeping the queue explainable', async () => {
    const repo = new InMemoryReservationRepository();
    await pending(repo, 3);

    await repo.markDefaultTravelling(DATE, 'morning', async () => 1);

    const byUser = new Map((await repo.listForTrip(TRIP)).map((r) => [r.userId, r.status]));
    expect(byUser.get('p0')).toBe('reserved');
    expect(byUser.get('p1')).toBe('unseated');
    expect(byUser.get('p2')).toBe('unseated');
  });

  it('an unseated rider holds no seat and is never swept up as a no-show', async () => {
    // The whole point of the status: they were never on the van, so they must
    // not be charged a ride for missing it.
    const repo = new InMemoryReservationRepository();
    await pending(repo, 3);

    await repo.markDefaultTravelling(DATE, 'morning', async () => 1);

    expect(await repo.countSeatsTaken(TRIP)).toBe(1);
    const reserved = await repo.listReserved(DATE, 'morning');
    expect(reserved.every((r) => r.status === 'reserved')).toBe(true);
    expect(reserved).toHaveLength(1);
  });

  it('leaves a second cutoff run with nothing to do', async () => {
    const repo = new InMemoryReservationRepository();
    await pending(repo, 3);

    await repo.markDefaultTravelling(DATE, 'morning', async () => 1);
    const again = await repo.markDefaultTravelling(DATE, 'morning', async () => 1);

    // Unseated is terminal, so a re-run cannot resurrect or re-skip anyone.
    expect(again).toEqual({ defaulted: 0, skippedFull: 0 });
  });
});
