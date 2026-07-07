import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const today = () => new Date().toISOString().slice(0, 10);

/** App wired with shared reservation + entitlement stores, rider pre-allocated rides. */
async function setup(riderId = 'rider-1') {
  const reservations = new InMemoryReservationRepository();
  const entitlements = new InMemoryEntitlementLedgerRepository();
  await entitlements.record({
    userId: riderId,
    deltaRides: 44,
    reason: 'allocation',
    idempotencyKey: `alloc-${riderId}`,
  });
  const app = await buildApp({ auth, reservations, entitlements });
  const riderToken = await jwt.signAccessToken({ userId: riderId, role: 'commuter' });
  const driverToken = await jwt.signAccessToken({ userId: 'driver-1', role: 'driver' });
  return { app, reservations, entitlements, riderToken, driverToken, riderId };
}

const getPass = async (app: Awaited<ReturnType<typeof buildApp>>, riderToken: string) =>
  (await app.inject({ method: 'GET', url: '/me/pass', headers: bearer(riderToken) })).json().pass;

const scan = async (app: Awaited<ReturnType<typeof buildApp>>, driverToken: string, pass: string) =>
  app.inject({
    method: 'POST',
    url: '/boarding/scan',
    headers: bearer(driverToken),
    payload: { pass },
  });

const rides = async (app: Awaited<ReturnType<typeof buildApp>>, riderToken: string) =>
  (await app.inject({ method: 'GET', url: '/me/rides', headers: bearer(riderToken) })).json()
    .remainingRides;

describe('boarding deduction (E4)', () => {
  it('a valid scan of a confirmed rider boards the seat and debits one ride', async () => {
    const { app, reservations, riderToken, driverToken, riderId } = await setup();
    await app.inject({
      method: 'POST',
      url: '/me/reservations',
      headers: bearer(riderToken),
      payload: { travelDate: today(), direction: 'morning', travelling: true },
    });
    expect(await rides(app, riderToken)).toBe(44);

    const res = await scan(app, driverToken, await getPass(app, riderToken));
    expect(res.json()).toMatchObject({ valid: true, riderId, reason: 'ok', deducted: true });
    expect(await rides(app, riderToken)).toBe(43);
    expect((await reservations.find(riderId, today(), 'morning'))?.status).toBe('boarded');
  });

  it('re-scanning a boarded rider (fresh QR) does not double-charge', async () => {
    const { app, riderToken, driverToken } = await setup();
    await app.inject({
      method: 'POST',
      url: '/me/reservations',
      headers: bearer(riderToken),
      payload: { travelDate: today(), direction: 'morning', travelling: true },
    });
    await scan(app, driverToken, await getPass(app, riderToken)); // boards, -1
    expect(await rides(app, riderToken)).toBe(43);

    // a freshly issued pass (new jti) passes single-use, but the seat is boarded
    const replay = await scan(app, driverToken, await getPass(app, riderToken));
    expect(replay.json()).toMatchObject({ valid: true, deducted: false });
    expect(await rides(app, riderToken)).toBe(43); // unchanged
  });

  it('a valid scan with no confirmed reservation boards nothing (no debit)', async () => {
    const { app, riderToken, driverToken } = await setup();
    const res = await scan(app, driverToken, await getPass(app, riderToken));
    expect(res.json()).toMatchObject({ valid: true, reason: 'ok', deducted: false });
    expect(await rides(app, riderToken)).toBe(44);
  });

  it('a declined reservation is not boardable (no debit)', async () => {
    const { app, riderToken, driverToken } = await setup();
    await app.inject({
      method: 'POST',
      url: '/me/reservations',
      headers: bearer(riderToken),
      payload: { travelDate: today(), direction: 'morning', travelling: false },
    });
    const res = await scan(app, driverToken, await getPass(app, riderToken));
    expect(res.json()).toMatchObject({ valid: true, deducted: false });
    expect(await rides(app, riderToken)).toBe(44);
  });

  it('morning boards before evening (earliest open leg first)', async () => {
    const { app, reservations, riderToken, driverToken, riderId } = await setup();
    for (const direction of ['evening', 'morning'] as const) {
      await app.inject({
        method: 'POST',
        url: '/me/reservations',
        headers: bearer(riderToken),
        payload: { travelDate: today(), direction, travelling: true },
      });
    }
    await scan(app, driverToken, await getPass(app, riderToken));
    expect((await reservations.find(riderId, today(), 'morning'))?.status).toBe('boarded');
    expect((await reservations.find(riderId, today(), 'evening'))?.status).toBe('reserved');
    expect(await rides(app, riderToken)).toBe(43);
  });
});
