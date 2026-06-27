import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (token: string) => ({ authorization: `Bearer ${token}` });

describe('GET /me (authenticate guard)', () => {
  it('rejects a request with no Authorization header', async () => {
    const app = await buildApp({ auth, users: new InMemoryUserRepository() });
    const res = await app.inject({ method: 'GET', url: '/me' });
    expect(res.statusCode).toBe(401);
  });

  it('rejects a non-bearer Authorization header', async () => {
    const app = await buildApp({ auth, users: new InMemoryUserRepository() });
    const res = await app.inject({
      method: 'GET',
      url: '/me',
      headers: { authorization: 'Basic abc' },
    });
    expect(res.statusCode).toBe(401);
  });

  it('rejects an invalid token', async () => {
    const app = await buildApp({ auth, users: new InMemoryUserRepository() });
    const res = await app.inject({ method: 'GET', url: '/me', headers: bearer('garbage') });
    expect(res.statusCode).toBe(401);
  });

  it('returns 404 when no user repository is configured', async () => {
    const app = await buildApp({ auth });
    const token = await jwt.signAccessToken({ userId: 'x', role: 'commuter' });
    const res = await app.inject({ method: 'GET', url: '/me', headers: bearer(token) });
    expect(res.statusCode).toBe(404);
  });

  it('returns 404 when the token is valid but the user is gone', async () => {
    const app = await buildApp({ auth, users: new InMemoryUserRepository() });
    const token = await jwt.signAccessToken({ userId: 'missing', role: 'commuter' });
    const res = await app.inject({ method: 'GET', url: '/me', headers: bearer(token) });
    expect(res.statusCode).toBe(404);
  });

  it('returns the authenticated user with a valid token', async () => {
    const users = new InMemoryUserRepository();
    const user = await users.create({ displayName: 'Ama' });
    const app = await buildApp({ auth, users });
    const token = await jwt.signAccessToken({ userId: user.id, role: user.role });

    const res = await app.inject({ method: 'GET', url: '/me', headers: bearer(token) });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ id: user.id, displayName: 'Ama', role: 'commuter' });
  });
});

describe('requireRole guard', () => {
  // Register a throwaway admin-only route as a plugin so the root decorators
  // (authenticate/requireRole) are loaded before the route is defined.
  async function appWithAdminRoute() {
    const app = await buildApp({ auth, users: new InMemoryUserRepository() });
    await app.register(async (instance) => {
      instance.get(
        '/admin-only',
        { preHandler: [instance.authenticate, instance.requireRole('admin')] },
        async () => ({ ok: true }),
      );
      // No authenticate in front: exercises the "no principal" branch.
      instance.get('/role-only', { preHandler: instance.requireRole('admin') }, async () => ({
        ok: true,
      }));
    });
    return app;
  }

  it('allows a user whose role matches', async () => {
    const app = await appWithAdminRoute();
    const token = await jwt.signAccessToken({ userId: 'admin-1', role: 'admin' });
    const res = await app.inject({ method: 'GET', url: '/admin-only', headers: bearer(token) });
    expect(res.statusCode).toBe(200);
  });

  it('forbids a user whose role does not match', async () => {
    const app = await appWithAdminRoute();
    const token = await jwt.signAccessToken({ userId: 'commuter-1', role: 'commuter' });
    const res = await app.inject({ method: 'GET', url: '/admin-only', headers: bearer(token) });
    expect(res.statusCode).toBe(403);
  });

  it('rejects when used without prior authentication', async () => {
    const app = await appWithAdminRoute();
    const res = await app.inject({ method: 'GET', url: '/role-only' });
    expect(res.statusCode).toBe(401);
  });
});
