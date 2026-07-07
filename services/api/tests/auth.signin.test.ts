import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryAuthIdentityRepository } from '../src/modules/auth/auth-identity.repository';
import { AuthService } from '../src/modules/auth/auth.service';
import { FakeIdTokenVerifier } from '../src/modules/auth/id-token-verifier';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemorySessionRepository } from '../src/modules/auth/session.repository';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const googleToken = (sub: string) => JSON.stringify({ sub, name: 'Ama', email: `${sub}@x.com` });

async function appWithAuth() {
  const users = new InMemoryUserRepository();
  const authService = new AuthService({
    users,
    authIdentities: new InMemoryAuthIdentityRepository(),
    sessions: new InMemorySessionRepository(),
    jwt: createJwtService(auth),
    verifier: new FakeIdTokenVerifier(),
    refreshTtlDays: 30,
  });
  return buildApp({ auth, users, authService });
}

describe('POST /auth/google', () => {
  it('signs in, returns user + tokens, and the access token works on /me', async () => {
    const app = await appWithAuth();
    const res = await app.inject({
      method: 'POST',
      url: '/auth/google',
      payload: { idToken: googleToken('g-1') },
    });
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.user).toMatchObject({ displayName: 'Ama', role: 'commuter' });
    expect(body.accessToken).toBeTruthy();
    expect(body.refreshToken).toBeTruthy();

    const me = await app.inject({
      method: 'GET',
      url: '/me',
      headers: { authorization: `Bearer ${body.accessToken}` },
    });
    expect(me.statusCode).toBe(200);
    expect(me.json()).toMatchObject({ id: body.user.id });
  });

  it('rejects an invalid id token with 401', async () => {
    const app = await appWithAuth();
    const res = await app.inject({
      method: 'POST',
      url: '/auth/google',
      payload: { idToken: 'not-json' },
    });
    expect(res.statusCode).toBe(401);
  });

  it('returns 503 when no auth service is wired', async () => {
    const app = await buildApp({ auth });
    const res = await app.inject({
      method: 'POST',
      url: '/auth/google',
      payload: { idToken: googleToken('g-1') },
    });
    expect(res.statusCode).toBe(503);
  });

  it('returns 503 when the service has no verifier configured', async () => {
    const authService = new AuthService({
      users: new InMemoryUserRepository(),
      authIdentities: new InMemoryAuthIdentityRepository(),
      sessions: new InMemorySessionRepository(),
      jwt: createJwtService(auth),
      refreshTtlDays: 30,
    });
    const app = await buildApp({ auth, authService });
    const res = await app.inject({
      method: 'POST',
      url: '/auth/google',
      payload: { idToken: googleToken('g-1') },
    });
    expect(res.statusCode).toBe(503);
  });
});

describe('POST /auth/refresh and /auth/logout', () => {
  it('rotates tokens and rejects reuse of the old refresh token', async () => {
    const app = await appWithAuth();
    const signin = (
      await app.inject({
        method: 'POST',
        url: '/auth/google',
        payload: { idToken: googleToken('g-1') },
      })
    ).json();

    const refreshed = await app.inject({
      method: 'POST',
      url: '/auth/refresh',
      payload: { refreshToken: signin.refreshToken },
    });
    expect(refreshed.statusCode).toBe(200);
    expect(refreshed.json().refreshToken).not.toBe(signin.refreshToken);

    const reuse = await app.inject({
      method: 'POST',
      url: '/auth/refresh',
      payload: { refreshToken: signin.refreshToken },
    });
    expect(reuse.statusCode).toBe(401);
  });

  it('logout revokes the token (204) and refresh then fails', async () => {
    const app = await appWithAuth();
    const signin = (
      await app.inject({
        method: 'POST',
        url: '/auth/google',
        payload: { idToken: googleToken('g-1') },
      })
    ).json();

    const out = await app.inject({
      method: 'POST',
      url: '/auth/logout',
      payload: { refreshToken: signin.refreshToken },
    });
    expect(out.statusCode).toBe(204);

    const after = await app.inject({
      method: 'POST',
      url: '/auth/refresh',
      payload: { refreshToken: signin.refreshToken },
    });
    expect(after.statusCode).toBe(401);
  });

  it('refresh returns 503 and logout returns 204 when no auth service is wired', async () => {
    const app = await buildApp({ auth });
    const refresh = await app.inject({
      method: 'POST',
      url: '/auth/refresh',
      payload: { refreshToken: 'x' },
    });
    expect(refresh.statusCode).toBe(503);
    const logout = await app.inject({
      method: 'POST',
      url: '/auth/logout',
      payload: { refreshToken: 'x' },
    });
    expect(logout.statusCode).toBe(204);
  });
});
