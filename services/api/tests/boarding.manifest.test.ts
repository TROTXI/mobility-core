// Driver manifest (#20, E4) — the photo pass. A trip's confirmed riders with
// name + signed avatar URL + boarded status, restricted to the trip's ASSIGNED
// driver (rider PII — a driver role alone is not enough).

import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const OTHER_TRIP = crypto.randomUUID();
const DATE = '2026-07-09';

/** Wire users + reservations + a trip assigned to driver-1. Returns the trip id. */
async function setup() {
  const users = new InMemoryUserRepository();
  const reservations = new InMemoryReservationRepository();
  const trips = new InMemoryTripRepository();
  const drivers = new InMemoryDriverRepository();
  const driver = await drivers.create({ fullName: 'Driver One', userId: 'driver-1' });
  const trip = await trips.create({
    routeId: crypto.randomUUID(),
    assignedDriverId: driver.id,
    scheduledAt: new Date(`${DATE}T06:30:00Z`),
  });
  const app = await buildApp({ auth, users, reservations, trips, drivers });
  const driverToken = await jwt.signAccessToken({ userId: 'driver-1', role: 'driver' });
  return { users, reservations, trips, drivers, driver, app, driverToken, tripId: trip.id };
}

const manifest = (app: Awaited<ReturnType<typeof buildApp>>, token: string, tripId: string) =>
  app.inject({ method: 'GET', url: `/boarding/manifest?tripId=${tripId}`, headers: bearer(token) });

describe('GET /boarding/manifest', () => {
  it('requires the driver role (commuter → 403)', async () => {
    const { app, tripId } = await setup();
    const commuter = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });
    expect((await manifest(app, commuter, tripId)).statusCode).toBe(403);
  });

  it('rejects a driver who is not the trip’s assigned driver (403)', async () => {
    const { app, tripId } = await setup();
    // a valid driver token, but this user has no driver record / not assigned
    const other = await jwt.signAccessToken({ userId: 'driver-2', role: 'driver' });
    expect((await manifest(app, other, tripId)).statusCode).toBe(403);
  });

  it('404 when the trip does not exist', async () => {
    const { app, driverToken } = await setup();
    expect((await manifest(app, driverToken, crypto.randomUUID())).statusCode).toBe(404);
  });

  it('lists confirmed riders for the trip with name + signed photo', async () => {
    const { app, users, reservations, driverToken, tripId } = await setup();
    const ama = await users.create({ displayName: 'Ama Mensah' });
    await users.setAvatarKey(ama.id, `avatars/${ama.id}`);
    const kofi = await users.create({ displayName: 'Kofi B' }); // no avatar

    await reservations.respond({
      userId: ama.id,
      tripId,
      travelDate: DATE,
      direction: 'morning',
      travelling: true,
    });
    await reservations.respond({
      userId: kofi.id,
      tripId,
      travelDate: DATE,
      direction: 'morning',
      travelling: true,
    });

    const res = await manifest(app, driverToken, tripId);
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.tripId).toBe(tripId);
    expect(body.riders).toHaveLength(2);
    const amaRow = body.riders.find((r: { userId: string }) => r.userId === ama.id);
    expect(amaRow).toMatchObject({ name: 'Ama Mensah', boarded: false, direction: 'morning' });
    expect(amaRow.avatarUrl).toContain('avatars/'); // signed URL of the stored key
    const kofiRow = body.riders.find((r: { userId: string }) => r.userId === kofi.id);
    expect(kofiRow).toMatchObject({ name: 'Kofi B', avatarUrl: null });
  });

  it('excludes declined seats and other trips; shows boarded status', async () => {
    const { app, users, reservations, driverToken, tripId } = await setup();
    const yes = await users.create({ displayName: 'Yes Rider' });
    const no = await users.create({ displayName: 'No Rider' });
    const other = await users.create({ displayName: 'Other Trip' });

    const confirmed = await reservations.respond({
      userId: yes.id,
      tripId,
      travelDate: DATE,
      direction: 'morning',
      travelling: true,
    });
    await reservations.markBoarded(confirmed.id);
    await reservations.respond({
      userId: no.id,
      tripId,
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

    const body = (await manifest(app, driverToken, tripId)).json();
    expect(body.riders).toHaveLength(1);
    expect(body.riders[0]).toMatchObject({ userId: yes.id, boarded: true });
  });

  it('orders morning before evening (not alphabetical)', async () => {
    const { app, users, reservations, driverToken, tripId } = await setup();
    const m = await users.create({ displayName: 'Morning Rider' });
    const e = await users.create({ displayName: 'Evening Rider' });
    // insert evening first so a stable/alphabetical sort would keep it first
    await reservations.respond({
      userId: e.id,
      tripId,
      travelDate: DATE,
      direction: 'evening',
      travelling: true,
    });
    await reservations.respond({
      userId: m.id,
      tripId,
      travelDate: DATE,
      direction: 'morning',
      travelling: true,
    });

    const riders = (await manifest(app, driverToken, tripId)).json().riders;
    expect(riders.map((row: { direction: string }) => row.direction)).toEqual([
      'morning',
      'evening',
    ]);
  });

  it('empty manifest for a trip with no reservations', async () => {
    const { app, driverToken, tripId } = await setup();
    const body = (await manifest(app, driverToken, tripId)).json();
    expect(body).toEqual({ tripId, riders: [] });
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
