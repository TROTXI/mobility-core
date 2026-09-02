// Apple token revocation (#213). Apple requires an app offering both Sign in
// with Apple and account deletion to revoke at Apple's end on delete, and
// revoking needs a token that only the authorization-code exchange yields.

import { describe, expect, it } from 'vitest';
import { InMemoryAuthIdentityRepository } from '../src/modules/auth/auth-identity.repository';
import { AuthService } from '../src/modules/auth/auth.service';
import { FakeAppleTokenClient } from '../src/modules/auth/apple-token.client';
import { FakeIdTokenVerifier } from '../src/modules/auth/id-token-verifier';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemorySessionRepository } from '../src/modules/auth/session.repository';
import { InMemoryDeviceTokenRepository } from '../src/modules/devices/device-token.repository';
import { AccountDeletionService } from '../src/modules/users/account-deletion.service';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';
import { FakeObjectStore } from '../src/storage/object-store';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};

function setup(withAppleTokens = true) {
  const users = new InMemoryUserRepository();
  const authIdentities = new InMemoryAuthIdentityRepository();
  const appleTokens = new FakeAppleTokenClient();
  const service = new AuthService({
    users,
    authIdentities,
    sessions: new InMemorySessionRepository(),
    jwt: createJwtService(auth),
    verifiers: { apple: new FakeIdTokenVerifier('apple'), google: new FakeIdTokenVerifier() },
    appleTokens: withAppleTokens ? appleTokens : undefined,
    refreshTtlDays: 30,
  });
  const deletion = new AccountDeletionService({
    users,
    sessions: new InMemorySessionRepository(),
    authIdentities,
    devices: new InMemoryDeviceTokenRepository(),
    objectStore: new FakeObjectStore(),
    appleTokens: withAppleTokens ? appleTokens : undefined,
  });
  return { users, authIdentities, appleTokens, service, deletion };
}

const token = (sub: string) => JSON.stringify({ sub });

describe('Apple authorization-code exchange', () => {
  it('exchanges the code and keeps the refresh token against the identity', async () => {
    const { service, authIdentities, appleTokens } = setup();
    const result = await service.signIn(token('a-1'), 'apple', { authorizationCode: 'code-1' });

    expect(appleTokens.exchanged).toEqual(['code-1']);
    const [identity] = await authIdentities.listForUser(result.user.id);
    expect(identity?.providerRefreshToken).toBe('fake-apple-refresh-code-1');
  });

  it('signs in normally when the client sends no code', async () => {
    const { service, authIdentities, appleTokens } = setup();
    const result = await service.signIn(token('a-2'), 'apple');

    expect(appleTokens.exchanged).toEqual([]);
    const [identity] = await authIdentities.listForUser(result.user.id);
    expect(identity?.providerRefreshToken).toBeNull();
  });

  it('backfills a rider who linked Apple before we asked for codes', async () => {
    const { service, authIdentities } = setup();
    const first = await service.signIn(token('a-3'), 'apple');
    await service.signIn(token('a-3'), 'apple', { authorizationCode: 'code-later' });

    const [identity] = await authIdentities.listForUser(first.user.id);
    expect(identity?.providerRefreshToken).toBe('fake-apple-refresh-code-later');
  });

  it('never exchanges a code for Google', async () => {
    const { service, appleTokens } = setup();
    await service.signIn(token('g-1'), 'google', { authorizationCode: 'code-1' });
    expect(appleTokens.exchanged).toEqual([]);
  });

  it('still signs the rider in when Apple rejects the exchange', async () => {
    // Losing revocation is bad. Turning a rider away at the login screen because
    // Apple's token endpoint is having a bad minute is worse.
    const { users, authIdentities } = setup();
    const service = new AuthService({
      users,
      authIdentities,
      sessions: new InMemorySessionRepository(),
      jwt: createJwtService(auth),
      verifiers: { apple: new FakeIdTokenVerifier('apple') },
      appleTokens: {
        exchangeCode: async () => {
          throw new Error('apple is down');
        },
        revoke: async () => {},
      },
      refreshTtlDays: 30,
    });

    const result = await service.signIn(token('a-4'), 'apple', { authorizationCode: 'code-1' });
    expect(result.accessToken).toBeTruthy();
    const [identity] = await authIdentities.listForUser(result.user.id);
    expect(identity?.providerRefreshToken).toBeNull();
  });
});

describe('account deletion revokes at Apple', () => {
  it('revokes the stored token before unlinking', async () => {
    const { service, deletion, appleTokens } = setup();
    const { user } = await service.signIn(token('a-1'), 'apple', { authorizationCode: 'code-1' });

    expect(await deletion.deleteAccount(user.id)).toBe(true);
    expect(appleTokens.revoked).toEqual(['fake-apple-refresh-code-1']);
  });

  it('has nothing to revoke for a Google-only account', async () => {
    const { service, deletion, appleTokens } = setup();
    const { user } = await service.signIn(token('g-1'), 'google');

    await deletion.deleteAccount(user.id);
    expect(appleTokens.revoked).toEqual([]);
  });

  it('still erases the account when Apple refuses the revocation', async () => {
    // The rider asked to be deleted. Apple being unreachable cannot leave the
    // erasure half-done with their sessions already dead.
    const { users, authIdentities, service } = setup();
    const { user } = await service.signIn(token('a-1'), 'apple', { authorizationCode: 'code-1' });
    const deletion = new AccountDeletionService({
      users,
      sessions: new InMemorySessionRepository(),
      authIdentities,
      devices: new InMemoryDeviceTokenRepository(),
      objectStore: new FakeObjectStore(),
      appleTokens: {
        exchangeCode: async () => ({ refreshToken: null }),
        revoke: async () => {
          throw new Error('apple is down');
        },
      },
    });

    expect(await deletion.deleteAccount(user.id)).toBe(true);
    expect(await authIdentities.listForUser(user.id)).toEqual([]);
  });

  it('deletes as it always did when Apple is unconfigured', async () => {
    const { service, deletion, authIdentities } = setup(false);
    const { user } = await service.signIn(token('a-1'), 'apple', { authorizationCode: 'code-1' });

    expect(await deletion.deleteAccount(user.id)).toBe(true);
    expect(await authIdentities.listForUser(user.id)).toEqual([]);
  });
});
