// Driver manifest (#20, E4) — the photo pass. A trip's confirmed riders with
// name + signed avatar URL + boarded status, driver-role gated.

import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const TRIP = crypto.randomUUID();
const OTHER_TRIP = crypto.randomUUID();
const DATE = '2026-07-09';

async function setup() {
  const users = new InMemoryUserRepository();
  const reservations = new InMemoryReservationRepository();
  const app = await buildApp({ auth, users, reservations });
  const driverToken = await jwt.signAccessToken({ userId: 'driver-1', role: 'driver' });
  return { users, reservations, app, driverToken };
}

const manifest = (
  app: Awaited<ReturnType<typeof buildApp>>,
  token: string,
  tripId: string = TRIP,
) =>
  app.inject({ method: 'GET', url: `/boarding/manifest?tripId=${tripId}`, headers: bearer(token) });

describe('GET /boarding/manifest', () => {
  it('requires the driver role (commuter → 403)', async () => {
    const { app } = await setup();
    const commuter = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });
    expect((await manifest(app, commuter)).statusCode).toBe(403);
  });

  it('lists confirmed riders for the trip with name + signed photo', async () => {
    const { app, users, reservations, driverToken } = await setup();
    const ama = await users.create({ displayName: 'Ama Mensah' });
    await users.setAvatarKey(ama.id, `avatars/${ama.id}`);
    const kofi = await users.create({ displayName: 'Kofi B' }); // no avatar

    await reservations.respond({
      userId: ama.id,
      tripId: TRIP,
      travelDate: DATE,
      direction: 'morning',
      travelling: true,
    });
    await reservations.respond({
      userId: kofi.id,
      tripId: TRIP,
      travelDate: DATE,
      direction: 'morning',
      travelling: true,
    });

    const res = await manifest(app, driverToken);
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.tripId).toBe(TRIP);
    expect(body.riders).toHaveLength(2);
    const amaRow = body.riders.find((r: { userId: string }) => r.userId === ama.id);
    expect(amaRow).toMatchObject({ name: 'Ama Mensah', boarded: false, direction: 'morning' });
    expect(amaRow.avatarUrl).toContain('avatars/'); // signed URL of the stored key
    const kofiRow = body.riders.find((r: { userId: string }) => r.userId === kofi.id);
    expect(kofiRow).toMatchObject({ name: 'Kofi B', avatarUrl: null });
  });

  it('excludes declined seats and other trips; shows boarded status', async () => {
    const { app, users, reservations, driverToken } = await setup();
    const yes = await users.create({ displayName: 'Yes Rider' });
    const no = await users.create({ displayName: 'No Rider' });
    const other = await users.create({ displayName: 'Other Trip' });

    const confirmed = await reservations.respond({
      userId: yes.id,
      tripId: TRIP,
      travelDate: DATE,
      direction: 'morning',
      travelling: true,
    });
    await reservations.markBoarded(confirmed.id);
    await reservations.respond({
      userId: no.id,
      tripId: TRIP,
      travelDate: DATE,
      direction: 'morning',
      travelling: false, // declined → excluded
    });
    await reservations.respond({
      userId: other.id,
      tripId: OTHER_TRIP,
      travelDate: DATE,
      direction: 'morning',
      travelling: true, // different trip → excluded
    });

    const body = (await manifest(app, driverToken)).json();
    expect(body.riders).toHaveLength(1);
    expect(body.riders[0]).toMatchObject({ userId: yes.id, boarded: true });
  });

  it('empty manifest for a trip with no reservations', async () => {
    const { app, driverToken } = await setup();
    const body = (await manifest(app, driverToken)).json();
    expect(body).toEqual({ tripId: TRIP, riders: [] });
  });

  it('400 when tripId is missing or not a uuid', async () => {
    const { app, driverToken } = await setup();
    expect(
      (
        await app.inject({
          method: 'GET',
          url: '/boarding/manifest',
          headers: bearer(driverToken),
        })
      ).statusCode,
    ).toBe(400);
    expect((await manifest(app, driverToken, 'not-a-uuid')).statusCode).toBe(400);
  });
});
