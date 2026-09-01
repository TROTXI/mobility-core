// Apple sign-in (#168). Mirrors POST /auth/google exactly, with the two things
// Apple does differently: the name arrives once, outside the token, and the
// provider is configured independently so one missing client id cannot take the
// other provider's sign-in down.

import { createHash } from 'node:crypto';
import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryAuthIdentityRepository } from '../src/modules/auth/auth-identity.repository';
import { AuthService } from '../src/modules/auth/auth.service';
import { FakeIdTokenVerifier } from '../src/modules/auth/id-token-verifier';
import { nonceMatches } from '../src/modules/auth/id-token-verifier.apple';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemorySessionRepository } from '../src/modules/auth/session.repository';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const appleToken = (sub: string, email?: string) =>
  JSON.stringify(email ? { sub, email } : { sub });

async function appWithApple(providers = { google: true, apple: true }) {
  const users = new InMemoryUserRepository();
  const verifiers: Record<string, FakeIdTokenVerifier> = {};
  if (providers.google) verifiers.google = new FakeIdTokenVerifier('google');
  if (providers.apple) verifiers.apple = new FakeIdTokenVerifier('apple');
  const authService = new AuthService({
    users,
    authIdentities: new InMemoryAuthIdentityRepository(),
    sessions: new InMemorySessionRepository(),
    jwt: createJwtService(auth),
    verifiers,
    refreshTtlDays: 30,
  });
  return { app: await buildApp({ auth, users, authService }), users };
}

const signIn = (app: Awaited<ReturnType<typeof buildApp>>, payload: Record<string, unknown>) =>
  app.inject({ method: 'POST', url: '/auth/apple', payload });

describe('POST /auth/apple', () => {
  it('signs in, returns user + tokens, and the access token works on /me', async () => {
    const { app } = await appWithApple();
    const res = await signIn(app, { idToken: appleToken('a-1', 'ama@example.com') });

    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.accessToken).toBeTruthy();
    expect(body.refreshToken).toBeTruthy();

    const me = await app.inject({
      method: 'GET',
      url: '/me',
      headers: { authorization: `Bearer ${body.accessToken}` },
    });
    expect(me.statusCode).toBe(200);
    expect(me.json().id).toBe(body.user.id);
  });

  it('reuses the same user on repeat sign-in', async () => {
    const { app } = await appWithApple();
    const first = (await signIn(app, { idToken: appleToken('a-1') })).json();
    const second = (await signIn(app, { idToken: appleToken('a-1') })).json();
    expect(second.user.id).toBe(first.user.id);
  });

  it('keeps the name Apple sends once, on the sign-in that creates the account', async () => {
    // Apple returns the name on the FIRST authorization only, outside the token.
    // Dropping it here loses it permanently and the driver's manifest shows a
    // blank where a rider should be.
    const { app } = await appWithApple();
    const res = await signIn(app, { idToken: appleToken('a-1'), fullName: 'Ama Serwaa' });
    expect(res.json().user.displayName).toBe('Ama Serwaa');
  });

  it('falls back to the default name when Apple sends none', async () => {
    const { app } = await appWithApple();
    const res = await signIn(app, { idToken: appleToken('a-2') });
    expect(res.json().user.displayName).toBe('New User');
  });

  it('cannot rename an existing account', async () => {
    // fullName is client-supplied rather than a signed claim, so it must only
    // ever fill a blank, never overwrite. Otherwise anyone holding a valid token
    // can relabel the account on every sign-in.
    const { app } = await appWithApple();
    await signIn(app, { idToken: appleToken('a-1'), fullName: 'Ama Serwaa' });
    const again = await signIn(app, { idToken: appleToken('a-1'), fullName: 'Someone Else' });
    expect(again.json().user.displayName).toBe('Ama Serwaa');
  });

  it('bounds a long name rather than storing it whole', async () => {
    const { app } = await appWithApple();
    const res = await signIn(app, { idToken: appleToken('a-3'), fullName: 'A'.repeat(500) });
    expect(res.statusCode).toBe(400); // rejected at the schema edge
  });

  it('truncates a name that passes the schema but is still absurd', async () => {
    // The schema stops the abusive case at 200; this is the merely silly one,
    // where we keep something usable rather than a paragraph on the manifest.
    const { app } = await appWithApple();
    const res = await signIn(app, { idToken: appleToken('a-5'), fullName: 'A'.repeat(150) });
    expect(res.json().user.displayName).toHaveLength(80);
  });

  it('keeps a private-relay address, which is real and deliverable', async () => {
    const { app, users } = await appWithApple();
    const res = await signIn(app, {
      idToken: appleToken('a-4', 'xyz@privaterelay.appleid.com'),
    });
    const user = await users.findById(res.json().user.id);
    expect(user?.email).toBe('xyz@privaterelay.appleid.com');
  });

  it('treats the same subject id from Apple and Google as two different people', async () => {
    // auth_identities is keyed on (provider, provider_id). Collapsing on the
    // subject alone would let one provider's id take over another's account.
    const { app } = await appWithApple();
    const viaApple = (await signIn(app, { idToken: appleToken('shared-sub') })).json();
    const viaGoogle = (
      await app.inject({
        method: 'POST',
        url: '/auth/google',
        payload: { idToken: JSON.stringify({ sub: 'shared-sub' }) },
      })
    ).json();
    expect(viaGoogle.user.id).not.toBe(viaApple.user.id);
  });

  it('rejects an invalid token with 401', async () => {
    const { app } = await appWithApple();
    const res = await signIn(app, { idToken: 'not-a-token' });
    expect(res.statusCode).toBe(401);
  });

  it('returns 503 when Apple is unconfigured but leaves Google working', async () => {
    // The whole reason verifiers are per-provider: shipping Apple config late
    // must not be able to break the sign-in that already works.
    const { app } = await appWithApple({ google: true, apple: false });

    expect((await signIn(app, { idToken: appleToken('a-1') })).statusCode).toBe(503);

    const google = await app.inject({
      method: 'POST',
      url: '/auth/google',
      payload: { idToken: JSON.stringify({ sub: 'g-1' }) },
    });
    expect(google.statusCode).toBe(200);
  });
});

describe('Apple nonce matching', () => {
  it('accepts the hashed form the Apple SDKs send', () => {
    const raw = 'random-value';
    expect(nonceMatches(createHash('sha256').update(raw).digest('hex'), raw)).toBe(true);
  });

  it('accepts the raw form some clients send', () => {
    expect(nonceMatches('random-value', 'random-value')).toBe(true);
  });

  it('rejects anything else', () => {
    expect(nonceMatches('someone-elses-nonce', 'random-value')).toBe(false);
  });
});
