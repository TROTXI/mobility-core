import { describe, expect, it } from 'vitest';
import { AuthService } from '../src/modules/auth/auth.service';
import { InMemoryAuthIdentityRepository } from '../src/modules/auth/auth-identity.repository';
import { FakeIdTokenVerifier } from '../src/modules/auth/id-token-verifier';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemorySessionRepository } from '../src/modules/auth/session.repository';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';

const authConfig: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};

function makeService(users = new InMemoryUserRepository()) {
  const service = new AuthService({
    users,
    authIdentities: new InMemoryAuthIdentityRepository(),
    sessions: new InMemorySessionRepository(),
    jwt: createJwtService(authConfig),
    verifier: new FakeIdTokenVerifier(),
    refreshTtlDays: 30,
  });
  return { service, users };
}

const token = (sub: string, email?: string) =>
  JSON.stringify({ sub, name: 'Ama Boateng', ...(email ? { email } : {}) });

describe('sign-in contactability (#182)', () => {
  it('persists the verified email instead of discarding it', async () => {
    const { service } = makeService();
    const result = await service.signIn(token('g-1', 'ama@example.com'));
    expect(result.user.email).toBe('ama@example.com');
  });

  it('reports isNewUser only on the sign-in that created the account', async () => {
    const { service } = makeService();
    expect((await service.signIn(token('g-1', 'ama@example.com'))).isNewUser).toBe(true);
    expect((await service.signIn(token('g-1', 'ama@example.com'))).isNewUser).toBe(false);
  });

  it('backfills a missing email on a later sign-in', async () => {
    // Anyone who signed up before this shipped would otherwise stay
    // permanently uncontactable; they get filled in next time they open the app.
    const users = new InMemoryUserRepository();
    const { service } = makeService(users);

    const first = await service.signIn(token('g-2')); // provider sent no email
    expect(first.user.email).toBeNull();

    const second = await service.signIn(token('g-2', 'kojo@example.com'));
    expect(second.user.id).toBe(first.user.id);
    expect(second.user.email).toBe('kojo@example.com');
  });

  it('never overwrites contact details we already hold', async () => {
    const users = new InMemoryUserRepository();
    const { service } = makeService(users);

    const first = await service.signIn(token('g-3', 'original@example.com'));
    await service.signIn(token('g-3', 'changed@example.com'));

    expect((await users.findById(first.user.id))!.email).toBe('original@example.com');
  });
});

describe('backfillContact', () => {
  it('fills only the missing field and leaves the other alone', async () => {
    const users = new InMemoryUserRepository();
    const user = await users.create({ displayName: 'Ama', email: 'ama@example.com' });

    const updated = await users.backfillContact(user.id, {
      email: 'other@example.com',
      phone: '+233244123456',
    });

    expect(updated!.email).toBe('ama@example.com'); // kept
    expect(updated!.phone).toBe('+233244123456'); // filled
  });
});
