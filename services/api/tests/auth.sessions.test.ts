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
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const googleToken = (sub: string) => JSON.stringify({ sub, name: 'Ama' });

function make() {
  const users = new InMemoryUserRepository();
  const authService = new AuthService({
    users,
    authIdentities: new InMemoryAuthIdentityRepository(),
    sessions: new InMemorySessionRepository(),
    jwt,
    verifier: new FakeIdTokenVerifier(),
    refreshTtlDays: 30,
  });
  return { users, authService };
}
const accessFor = (userId: string) => jwt.signAccessToken({ userId, role: 'commuter' });

describe('GET /me/sessions + DELETE /me/sessions/:id', () => {
  it('requires authentication', async () => {
    const { users, authService } = make();
    const app = await buildApp({ auth, users, authService });
    expect((await app.inject({ method: 'GET', url: '/me/sessions' })).statusCode).toBe(401);
  });

  it('lists active sessions (no secrets) and revokes one', async () => {
    const { users, authService } = make();
    const app = await buildApp({ auth, users, authService });
    const signIn = await authService.signIn(googleToken('g-1'));
    await authService.signIn(googleToken('g-1')); // a second device for the same user
    const token = await accessFor(signIn.user.id);

    const list = await app.inject({ method: 'GET', url: '/me/sessions', headers: bearer(token) });
    expect(list.statusCode).toBe(200);
    const { sessions } = list.json();
    expect(sessions).toHaveLength(2);
    expect(sessions[0]).toHaveProperty('id');
    expect(sessions[0]).not.toHaveProperty('refreshTokenHash'); // never leak the hash

    const del = await app.inject({
      method: 'DELETE',
      url: `/me/sessions/${sessions[0].id}`,
      headers: bearer(token),
    });
    expect(del.statusCode).toBe(204);

    const after = await app.inject({ method: 'GET', url: '/me/sessions', headers: bearer(token) });
    expect(after.json().sessions).toHaveLength(1);
  });

  it("cannot revoke another user's session", async () => {
    const { users, authService } = make();
    const app = await buildApp({ auth, users, authService });
    const a = await authService.signIn(googleToken('g-1'));
    const b = await authService.signIn(googleToken('g-2'));
    const bSessionId = (await authService.listSessions(b.user.id))[0]!.id;

    const res = await app.inject({
      method: 'DELETE',
      url: `/me/sessions/${bSessionId}`,
      headers: bearer(await accessFor(a.user.id)),
    });
    expect(res.statusCode).toBe(204); // idempotent, but a no-op

    expect(await authService.listSessions(b.user.id)).toHaveLength(1); // B's session survives
  });

  it('rejects a non-uuid session id with 400', async () => {
    const { users, authService } = make();
    const app = await buildApp({ auth, users, authService });
    const res = await app.inject({
      method: 'DELETE',
      url: '/me/sessions/not-a-uuid',
      headers: bearer(await accessFor('rider-1')),
    });
    expect(res.statusCode).toBe(400);
  });
});
