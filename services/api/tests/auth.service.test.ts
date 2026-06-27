import { describe, expect, it } from 'vitest';
import {
  InMemoryAuthIdentityRepository,
  type AuthIdentityRepository,
} from '../src/modules/auth/auth-identity.repository';
import {
  AuthService,
  InvalidRefreshTokenError,
  SignInNotConfiguredError,
} from '../src/modules/auth/auth.service';
import { FakeIdTokenVerifier } from '../src/modules/auth/id-token-verifier';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemorySessionRepository } from '../src/modules/auth/session.repository';
import { hashToken } from '../src/modules/auth/tokens';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';

const authConfig: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(authConfig);
const googleToken = (sub: string, name = 'Ama') =>
  JSON.stringify({ sub, name, email: `${sub}@example.com` });

function makeService() {
  const users = new InMemoryUserRepository();
  const authIdentities = new InMemoryAuthIdentityRepository();
  const sessions = new InMemorySessionRepository();
  const service = new AuthService({
    users,
    authIdentities,
    sessions,
    jwt,
    verifier: new FakeIdTokenVerifier(),
    refreshTtlDays: 30,
  });
  return { users, authIdentities, sessions, service };
}

describe('AuthService.signIn', () => {
  it('creates user + identity + session and issues verifiable tokens', async () => {
    const { service, users, sessions } = makeService();
    const result = await service.signIn(googleToken('g-1'));

    expect(result.user.displayName).toBe('Ama');
    expect(await users.findById(result.user.id)).not.toBeNull();
    expect(await jwt.verifyAccessToken(result.accessToken)).toEqual({
      userId: result.user.id,
      role: 'commuter',
    });
    expect(await sessions.findByHash(hashToken(result.refreshToken))).not.toBeNull();
  });

  it('falls back to a default display name when the provider returns no name', async () => {
    const { service } = makeService();
    const result = await service.signIn(JSON.stringify({ sub: 'g-min' }));
    expect(result.user.displayName).toBe('New User');
  });

  it('reuses the same user on repeat sign-in with the same identity', async () => {
    const { service } = makeService();
    const a = await service.signIn(googleToken('g-1'));
    const b = await service.signIn(googleToken('g-1'));
    expect(b.user.id).toBe(a.user.id);
  });

  it('throws when no verifier is configured', async () => {
    const service = new AuthService({
      users: new InMemoryUserRepository(),
      authIdentities: new InMemoryAuthIdentityRepository(),
      sessions: new InMemorySessionRepository(),
      jwt,
      refreshTtlDays: 30,
    });
    await expect(service.signIn(googleToken('g-1'))).rejects.toBeInstanceOf(
      SignInNotConfiguredError,
    );
  });

  it('rejects an invalid id token', async () => {
    const { service } = makeService();
    await expect(service.signIn('not-json')).rejects.toThrow();
  });

  it('recovers from a concurrent first-sign-in race (unique violation)', async () => {
    const users = new InMemoryUserRepository();
    const winner = await users.create({ displayName: 'Winner' });
    let raced = false;
    const authIdentities: AuthIdentityRepository = {
      findByProvider: async (provider, providerId) =>
        raced ? { id: 'x', userId: winner.id, provider, providerId, createdAt: new Date() } : null,
      create: async () => {
        raced = true; // the "winner" created it between our check and our insert
        throw Object.assign(new Error('duplicate'), { code: '23505' });
      },
    };
    const service = new AuthService({
      users,
      authIdentities,
      sessions: new InMemorySessionRepository(),
      jwt,
      verifier: new FakeIdTokenVerifier(),
      refreshTtlDays: 30,
    });

    const result = await service.signIn(googleToken('g-1'));
    expect(result.user.id).toBe(winner.id);
  });

  it('propagates non-unique errors from identity creation', async () => {
    const authIdentities: AuthIdentityRepository = {
      findByProvider: async () => null,
      create: async () => {
        throw new Error('db down');
      },
    };
    const service = new AuthService({
      users: new InMemoryUserRepository(),
      authIdentities,
      sessions: new InMemorySessionRepository(),
      jwt,
      verifier: new FakeIdTokenVerifier(),
      refreshTtlDays: 30,
    });
    await expect(service.signIn(googleToken('g-1'))).rejects.toThrow('db down');
  });
});

describe('AuthService.refresh', () => {
  it('rotates: issues new tokens and invalidates the old refresh token', async () => {
    const { service } = makeService();
    const { refreshToken } = await service.signIn(googleToken('g-1'));

    const rotated = await service.refresh(refreshToken);
    expect(rotated.accessToken).toBeTruthy();
    expect(rotated.refreshToken).not.toBe(refreshToken);

    await expect(service.refresh(refreshToken)).rejects.toBeInstanceOf(InvalidRefreshTokenError);
    expect((await service.refresh(rotated.refreshToken)).accessToken).toBeTruthy();
  });

  it('rejects an unknown refresh token', async () => {
    const { service } = makeService();
    await expect(service.refresh('nope')).rejects.toBeInstanceOf(InvalidRefreshTokenError);
  });

  it('rejects an expired session', async () => {
    const { service, users, sessions } = makeService();
    const user = await users.create({ displayName: 'Old' });
    const raw = 'expired-token';
    await sessions.create({
      userId: user.id,
      refreshTokenHash: hashToken(raw),
      expiresAt: new Date(Date.now() - 1000),
    });
    await expect(service.refresh(raw)).rejects.toBeInstanceOf(InvalidRefreshTokenError);
  });
});

describe('AuthService.logout', () => {
  it('revokes the session so the refresh token stops working', async () => {
    const { service } = makeService();
    const { refreshToken } = await service.signIn(googleToken('g-1'));
    await service.logout(refreshToken);
    await expect(service.refresh(refreshToken)).rejects.toBeInstanceOf(InvalidRefreshTokenError);
  });

  it('is a no-op for an unknown token', async () => {
    const { service } = makeService();
    await expect(service.logout('whatever')).resolves.toBeUndefined();
  });
});
