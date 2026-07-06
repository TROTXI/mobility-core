import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const DATE = '2026-07-06';

describe('ReservationRepository', () => {
  it('respond upserts: confirm → reserved, decline → declined, re-answer overwrites', async () => {
    const repo = new InMemoryReservationRepository();
    const base = { userId: 'u1', travelDate: DATE, direction: 'morning' as const };

    let res = await repo.respond({ ...base, travelling: true });
    expect(res).toMatchObject({ status: 'reserved', source: 'confirmation' });

    res = await repo.respond({ ...base, travelling: false }); // changed mind
    expect(res.status).toBe('declined');

    // still one row for that day+direction
    expect(await repo.listForUser('u1')).toHaveLength(1);
  });

  it('default-yes: pending flips to reserved(default); declined/reserved untouched', async () => {
    const repo = new InMemoryReservationRepository();
    await repo.createPending({ userId: 'a', travelDate: DATE, direction: 'morning' });
    await repo.respond({ userId: 'b', travelDate: DATE, direction: 'morning', travelling: false });
    await repo.respond({ userId: 'c', travelDate: DATE, direction: 'morning', travelling: true });
    // a different direction stays pending
    await repo.createPending({ userId: 'a', travelDate: DATE, direction: 'evening' });

    const count = await repo.markDefaultTravelling(DATE, 'morning');
    expect(count).toBe(1); // only 'a' morning

    expect(await repo.find('a', DATE, 'morning')).toMatchObject({
      status: 'reserved',
      source: 'default',
    });
    expect((await repo.find('b', DATE, 'morning'))?.status).toBe('declined');
    expect((await repo.find('c', DATE, 'morning'))?.source).toBe('confirmation');
    expect((await repo.find('a', DATE, 'evening'))?.status).toBe('pending'); // other direction
  });

  it('createPending is idempotent per day+direction', async () => {
    const repo = new InMemoryReservationRepository();
    await repo.createPending({ userId: 'a', travelDate: DATE, direction: 'morning' });
    await repo.createPending({ userId: 'a', travelDate: DATE, direction: 'morning' });
    expect(await repo.listForUser('a')).toHaveLength(1);
  });

  it('listForUser filters by fromDate and sorts newest first', async () => {
    const repo = new InMemoryReservationRepository();
    await repo.respond({
      userId: 'u1',
      travelDate: '2026-07-01',
      direction: 'morning',
      travelling: true,
    });
    await repo.respond({
      userId: 'u1',
      travelDate: '2026-07-10',
      direction: 'morning',
      travelling: true,
    });
    const list = await repo.listForUser('u1', { fromDate: '2026-07-05' });
    expect(list).toHaveLength(1);
    expect(list[0]!.travelDate).toBe('2026-07-10');
  });
});

describe('POST /me/reservations', () => {
  it('requires authentication', async () => {
    const app = await buildApp({ auth });
    const res = await app.inject({
      method: 'POST',
      url: '/me/reservations',
      payload: { travelDate: DATE, direction: 'morning', travelling: true },
    });
    expect(res.statusCode).toBe(401);
  });

  it('confirms a ride → reserved, and lists it', async () => {
    const reservations = new InMemoryReservationRepository();
    const app = await buildApp({ auth, reservations });
    const token = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });

    const res = await app.inject({
      method: 'POST',
      url: '/me/reservations',
      headers: bearer(token),
      payload: { travelDate: DATE, direction: 'morning', travelling: true },
    });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({
      status: 'reserved',
      source: 'confirmation',
      direction: 'morning',
    });

    const list = await app.inject({
      method: 'GET',
      url: '/me/reservations',
      headers: bearer(token),
    });
    expect(list.json().reservations).toHaveLength(1);
  });

  it('declining returns declined', async () => {
    const app = await buildApp({ auth, reservations: new InMemoryReservationRepository() });
    const token = await jwt.signAccessToken({ userId: 'rider-2', role: 'commuter' });
    const res = await app.inject({
      method: 'POST',
      url: '/me/reservations',
      headers: bearer(token),
      payload: { travelDate: DATE, direction: 'evening', travelling: false },
    });
    expect(res.json().status).toBe('declined');
  });

  it('rejects a malformed travelDate (400)', async () => {
    const app = await buildApp({ auth, reservations: new InMemoryReservationRepository() });
    const token = await jwt.signAccessToken({ userId: 'rider-3', role: 'commuter' });
    const res = await app.inject({
      method: 'POST',
      url: '/me/reservations',
      headers: bearer(token),
      payload: { travelDate: '06-07-2026', direction: 'morning', travelling: true },
    });
    expect(res.statusCode).toBe(400);
  });
});
