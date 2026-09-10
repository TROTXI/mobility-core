// Driver sign-in end to end (#223): issue, sign in, rotate, lock out, suspend.

import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { DriverAuthService } from '../src/modules/auth/driver-auth.service';
import { InMemoryDriverCredentialRepository } from '../src/modules/auth/driver-credential.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemorySessionRepository } from '../src/modules/auth/session.repository';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });

async function setup() {
  const credentials = new InMemoryDriverCredentialRepository();
  const drivers = new InMemoryDriverRepository();
  const users = new InMemoryUserRepository();
  const sessions = new InMemorySessionRepository();
  const driverAuth = new DriverAuthService({
    credentials,
    drivers,
    users,
    sessions,
    jwt: createJwtService(auth),
    secret: auth.secret,
    refreshTtlDays: 30,
    shiftTtlHours: 12,
  });

  const driver = await drivers.create({ fullName: 'Kwame Asare' });
  const issued = await driverAuth.issueCredential(driver.id);
  const app = await buildApp({ auth, driverAuth, users, drivers });
  return { app, driverAuth, credentials, drivers, users, sessions, driver, issued };
}

const signIn = (app: Awaited<ReturnType<typeof buildApp>>, body: Record<string, unknown>) =>
  app.inject({ method: 'POST', url: '/auth/driver', payload: body });

describe('POST /auth/driver', () => {
  it('signs a driver in with the code and PIN ops issued', async () => {
    const { app, issued, driver } = await setup();
    const res = await signIn(app, { driverCode: issued.driverCode, pin: issued.pin });

    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.driver).toMatchObject({ id: driver.id, fullName: 'Kwame Asare' });
    expect(body.accessToken).toEqual(expect.any(String));
    // Ops issued this PIN, so the app must send them to change it.
    expect(body.mustChangePin).toBe(true);
  });

  it('issues a token carrying the driver role', async () => {
    const { app, issued } = await setup();
    const { accessToken } = (
      await signIn(app, {
        driverCode: issued.driverCode,
        pin: issued.pin,
      })
    ).json();

    const claims = await createJwtService(auth).verifyAccessToken(accessToken);
    expect(claims.role).toBe('driver');
  });

  it('accepts the code however the driver types it', async () => {
    const { app, issued } = await setup();
    const typed = issued.driverCode.replace('DR-', '').toLowerCase();
    expect((await signIn(app, { driverCode: typed, pin: issued.pin })).statusCode).toBe(200);
  });

  it('answers the same 401 for an unknown code and a wrong PIN', async () => {
    // Distinguishing them would enumerate which codes exist, and a driver code
    // is written on depot whiteboards.
    const { app, issued } = await setup();
    const unknown = await signIn(app, { driverCode: 'DR-ZZZZ', pin: issued.pin });
    const wrongPin = await signIn(app, { driverCode: issued.driverCode, pin: '000042' });

    expect(unknown.statusCode).toBe(401);
    expect(wrongPin.statusCode).toBe(401);
    expect(unknown.json()).toEqual(wrongPin.json());
  });

  it('locks the credential after five wrong PINs and says when it lifts', async () => {
    const { app, issued } = await setup();
    for (let i = 0; i < 4; i++) {
      expect((await signIn(app, { driverCode: issued.driverCode, pin: '000042' })).statusCode).toBe(
        401,
      );
    }
    const locking = await signIn(app, { driverCode: issued.driverCode, pin: '000042' });
    expect(locking.statusCode).toBe(423);
    expect(Number(locking.headers['retry-after'])).toBeGreaterThan(0);

    // The correct PIN is refused too, which is what makes the lock a lock.
    const correct = await signIn(app, { driverCode: issued.driverCode, pin: issued.pin });
    expect(correct.statusCode).toBe(423);
  });

  it('resets the failure count once a sign-in succeeds', async () => {
    const { app, issued, credentials, driver } = await setup();
    await signIn(app, { driverCode: issued.driverCode, pin: '000042' });
    await signIn(app, { driverCode: issued.driverCode, pin: issued.pin });

    const credential = await credentials.findByDriverId(driver.id);
    expect(credential?.failedAttempts).toBe(0);
  });

  it('refuses a suspended credential and kills its live sessions', async () => {
    const { app, driverAuth, issued, driver, drivers, sessions } = await setup();
    await signIn(app, { driverCode: issued.driverCode, pin: issued.pin });
    // Re-read: the driver was created before issueCredential linked the account.
    const userId = (await drivers.findById(driver.id))!.userId!;
    expect(await sessions.listActiveForUser(userId)).toHaveLength(1);

    await driverAuth.setStatus(driver.id, 'suspended');

    expect((await signIn(app, { driverCode: issued.driverCode, pin: issued.pin })).statusCode).toBe(
      403,
    );
    // Stopping someone driving means now, not whenever their token expires.
    expect(await sessions.listActiveForUser(userId)).toHaveLength(0);
  });

  it('shortens the session when the handset is not the driver’s own', async () => {
    // A shared depot phone must not stay signed in past the shift that used it.
    const { app, issued, sessions, driver, drivers } = await setup();
    await signIn(app, { driverCode: issued.driverCode, pin: issued.pin });
    const shift = (
      await sessions.listActiveForUser((await drivers.findById(driver.id))!.userId!)
    )[0]!;

    const shiftMs = shift.expiresAt.getTime() - Date.now();
    expect(shiftMs).toBeLessThan(13 * 60 * 60 * 1000);
    expect(shiftMs).toBeGreaterThan(11 * 60 * 60 * 1000);
  });

  it('gives the full lifetime when the driver claims the handset', async () => {
    const { app, issued, sessions, driver, drivers } = await setup();
    await signIn(app, {
      driverCode: issued.driverCode,
      pin: issued.pin,
      rememberDevice: true,
    });
    const session = (
      await sessions.listActiveForUser((await drivers.findById(driver.id))!.userId!)
    )[0]!;

    const days = (session.expiresAt.getTime() - Date.now()) / (24 * 60 * 60 * 1000);
    expect(days).toBeGreaterThan(29);
  });

  it('503s when driver sign-in is not wired', async () => {
    const app = await buildApp({ auth });
    expect((await signIn(app, { driverCode: 'DR-B7K9', pin: '482913' })).statusCode).toBe(503);
  });
});

describe('POST /auth/driver/pin', () => {
  /**
   * Sign in and return the access token.
   *
   * @param ctx - the fixture.
   * @returns the driver's access token.
   */
  async function tokenFor(ctx: Awaited<ReturnType<typeof setup>>): Promise<string> {
    const res = await signIn(ctx.app, {
      driverCode: ctx.issued.driverCode,
      pin: ctx.issued.pin,
    });
    return res.json().accessToken as string;
  }

  it('rotates the PIN and clears the must-change flag', async () => {
    const ctx = await setup();
    const token = await tokenFor(ctx);

    const res = await ctx.app.inject({
      method: 'POST',
      url: '/auth/driver/pin',
      headers: bearer(token),
      payload: { currentPin: ctx.issued.pin, newPin: '839215' },
    });
    expect(res.statusCode).toBe(204);

    const after = await signIn(ctx.app, {
      driverCode: ctx.issued.driverCode,
      pin: '839215',
    });
    expect(after.statusCode).toBe(200);
    expect(after.json().mustChangePin).toBe(false);
  });

  it('refuses a trivial replacement', async () => {
    const ctx = await setup();
    const token = await tokenFor(ctx);
    const res = await ctx.app.inject({
      method: 'POST',
      url: '/auth/driver/pin',
      headers: bearer(token),
      payload: { currentPin: ctx.issued.pin, newPin: '111111' },
    });
    expect(res.statusCode).toBe(400);
    expect(res.json().error).toBe('weak_pin');
  });

  it('refuses when the current PIN is wrong', async () => {
    const ctx = await setup();
    const token = await tokenFor(ctx);
    const res = await ctx.app.inject({
      method: 'POST',
      url: '/auth/driver/pin',
      headers: bearer(token),
      payload: { currentPin: '000042', newPin: '839215' },
    });
    expect(res.statusCode).toBe(401);
  });

  it('needs the driver role', async () => {
    const ctx = await setup();
    const commuter = await createJwtService(auth).signAccessToken({
      userId: '11111111-1111-4111-8111-111111111111',
      role: 'commuter',
    });
    const res = await ctx.app.inject({
      method: 'POST',
      url: '/auth/driver/pin',
      headers: bearer(commuter),
      payload: { currentPin: '482913', newPin: '839215' },
    });
    expect(res.statusCode).toBe(403);
  });
});

describe('ops credential lifecycle', () => {
  it('links an auth account to the driver on issue', async () => {
    // drivers.user_id has been nullable since migration 015 "until driver
    // sign-in lands". This is what lands it.
    const { drivers, driver, users } = await setup();
    const linked = await drivers.findById(driver.id);
    expect(linked?.userId).toEqual(expect.any(String));
    expect((await users.findById(linked!.userId!))?.role).toBe('driver');
  });

  it('refuses a second credential for the same driver', async () => {
    const { driverAuth, driver } = await setup();
    await expect(driverAuth.issueCredential(driver.id)).rejects.toMatchObject({ code: '23505' });
  });

  it('reset-pin replaces the PIN, forces a change, and evicts live sessions', async () => {
    const ctx = await setup();
    await signIn(ctx.app, { driverCode: ctx.issued.driverCode, pin: ctx.issued.pin });
    const userId = (await ctx.drivers.findById(ctx.driver.id))!.userId!;
    expect(await ctx.sessions.listActiveForUser(userId)).toHaveLength(1);

    const { pin } = await ctx.driverAuth.resetPin(ctx.driver.id);

    expect(await ctx.sessions.listActiveForUser(userId)).toHaveLength(0);
    expect(
      (
        await signIn(ctx.app, {
          driverCode: ctx.issued.driverCode,
          pin: ctx.issued.pin,
        })
      ).statusCode,
    ).toBe(401);
    const res = await signIn(ctx.app, { driverCode: ctx.issued.driverCode, pin });
    expect(res.statusCode).toBe(200);
    expect(res.json().mustChangePin).toBe(true);
  });

  it('unlock lets a locked-out driver back in', async () => {
    const ctx = await setup();
    for (let i = 0; i < 5; i++) {
      await signIn(ctx.app, { driverCode: ctx.issued.driverCode, pin: '000042' });
    }
    expect(
      (
        await signIn(ctx.app, {
          driverCode: ctx.issued.driverCode,
          pin: ctx.issued.pin,
        })
      ).statusCode,
    ).toBe(423);

    await ctx.driverAuth.unlock(ctx.driver.id);

    expect(
      (
        await signIn(ctx.app, {
          driverCode: ctx.issued.driverCode,
          pin: ctx.issued.pin,
        })
      ).statusCode,
    ).toBe(200);
  });
});
