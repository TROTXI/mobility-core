// Daily PIN boarding (#20, E4 layer 2). A rider gets a 4-digit PIN on confirm;
// the driver types it against the manifest to board offline — same debit as the
// QR scan, idempotent per reservation.

import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';
import { hashPin, verifyPin } from '../src/modules/reservations/pin';
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

const confirm = async (app: Awaited<ReturnType<typeof buildApp>>, token: string) =>
  app.inject({
    method: 'POST',
    url: '/me/reservations',
    headers: bearer(token),
    payload: { travelDate: today(), direction: 'morning', travelling: true },
  });

const verify = (
  app: Awaited<ReturnType<typeof buildApp>>,
  driverToken: string,
  reservationId: string,
  pin: string,
) =>
  app.inject({
    method: 'POST',
    url: '/boarding/verify-pin',
    headers: bearer(driverToken),
    payload: { reservationId, pin },
  });

const rides = async (app: Awaited<ReturnType<typeof buildApp>>, riderToken: string) =>
  (await app.inject({ method: 'GET', url: '/me/rides', headers: bearer(riderToken) })).json()
    .remainingRides;

describe('pin helper', () => {
  it('hash is keyed + constant-time verify; null hash never matches', () => {
    const h = hashPin('1234', 'secret');
    expect(h).not.toBe('1234'); // hashed, not plaintext
    expect(hashPin('1234', 'other')).not.toBe(h); // keyed by the secret
    expect(verifyPin('1234', h, 'secret')).toBe(true);
    expect(verifyPin('9999', h, 'secret')).toBe(false);
    expect(verifyPin('1234', null, 'secret')).toBe(false);
  });
});

describe('POST /me/reservations issues a PIN', () => {
  it('returns a 4-digit pin on confirm, none on decline, and never stores plaintext', async () => {
    const { app, reservations, riderToken, riderId } = await setup();
    const body = (await confirm(app, riderToken)).json();
    expect(body.pin).toMatch(/^\d{4}$/);
    // stored value is the hash, not the plaintext
    const stored = await reservations.find(riderId, today(), 'morning');
    expect(stored?.pinHash).toBe(hashPin(body.pin, auth.secret));

    const declined = await app.inject({
      method: 'POST',
      url: '/me/reservations',
      headers: bearer(riderToken),
      payload: { travelDate: today(), direction: 'evening', travelling: false },
    });
    expect(declined.json().pin).toBeUndefined();
  });
});

describe('POST /boarding/verify-pin', () => {
  it('requires the driver role (commuter → 403)', async () => {
    const { app, riderToken } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/boarding/verify-pin',
      headers: bearer(riderToken),
      payload: { reservationId: crypto.randomUUID(), pin: '1234' },
    });
    expect(res.statusCode).toBe(403);
  });

  it('the correct PIN boards the seat and debits one ride', async () => {
    const { app, reservations, riderToken, driverToken, riderId } = await setup();
    const { id, pin } = (await confirm(app, riderToken)).json();

    const res = await verify(app, driverToken, id, pin);
    expect(res.json()).toMatchObject({ valid: true, reason: 'ok', deducted: true, riderId });
    expect(await rides(app, riderToken)).toBe(43);
    expect((await reservations.findById(id))?.status).toBe('boarded');
  });

  it('a wrong PIN does not board or debit', async () => {
    const { app, riderToken, driverToken } = await setup();
    const { id, pin } = (await confirm(app, riderToken)).json();
    const wrong = pin === '0000' ? '1111' : '0000';

    const res = await verify(app, driverToken, id, wrong);
    expect(res.json()).toMatchObject({ valid: false, reason: 'invalid', deducted: false });
    expect(await rides(app, riderToken)).toBe(44);
  });

  it('re-verifying an already-boarded seat is idempotent (no second debit)', async () => {
    const { app, riderToken, driverToken } = await setup();
    const { id, pin } = (await confirm(app, riderToken)).json();
    await verify(app, driverToken, id, pin); // boards, -1
    expect(await rides(app, riderToken)).toBe(43);

    const again = await verify(app, driverToken, id, pin);
    expect(again.json()).toMatchObject({ valid: true, reason: 'already_boarded', deducted: false });
    expect(await rides(app, riderToken)).toBe(43); // unchanged
  });

  it('an unknown reservation id returns not_found', async () => {
    const { app, driverToken } = await setup();
    const res = await verify(app, driverToken, crypto.randomUUID(), '1234');
    expect(res.json()).toMatchObject({ valid: false, reason: 'not_found', deducted: false });
  });

  it('rejects a non-4-digit PIN (400)', async () => {
    const { app, driverToken } = await setup();
    const res = await verify(app, driverToken, crypto.randomUUID(), '12');
    expect(res.statusCode).toBe(400);
  });
});
