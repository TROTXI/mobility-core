import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { AccountDeletionService } from '../src/modules/users/account-deletion.service';
import {
  ANONYMISED_DISPLAY_NAME,
  InMemoryUserRepository,
} from '../src/modules/users/user.repository';
import { InMemoryAuthIdentityRepository } from '../src/modules/auth/auth-identity.repository';
import { InMemorySessionRepository } from '../src/modules/auth/session.repository';
import { InMemoryDeviceTokenRepository } from '../src/modules/devices/device-token.repository';
import { FakeObjectStore } from '../src/storage/object-store';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);

async function setup({ wired = true }: { wired?: boolean } = {}) {
  const users = new InMemoryUserRepository();
  const objectStore = new FakeObjectStore();
  const user = await users.create({
    displayName: 'Ama',
    email: 'ama@example.com',
    phone: '+233244123456',
  });

  const accountDeletion = wired
    ? new AccountDeletionService({
        users,
        sessions: new InMemorySessionRepository(),
        authIdentities: new InMemoryAuthIdentityRepository(),
        devices: new InMemoryDeviceTokenRepository(),
        objectStore,
      })
    : undefined;

  const app = await buildApp({ auth, users, objectStore, accountDeletion });
  const token = await jwt.signAccessToken({ userId: user.id, role: 'commuter' });
  return { app, users, user, token };
}

describe('DELETE /me', () => {
  it('erases the caller and returns 204', async () => {
    const { app, users, user, token } = await setup();

    const res = await app.inject({
      method: 'DELETE',
      url: '/me',
      headers: { authorization: `Bearer ${token}` },
    });

    expect(res.statusCode).toBe(204);
    const after = await users.findById(user.id);
    expect(after?.displayName).toBe(ANONYMISED_DISPLAY_NAME);
    expect(after?.email).toBeNull();
    expect(after?.phone).toBeNull();
  });

  it('requires authentication', async () => {
    const { app } = await setup();
    const res = await app.inject({ method: 'DELETE', url: '/me' });
    expect(res.statusCode).toBe(401);
  });

  it('is idempotent, so a retry after a timeout still reads as success', async () => {
    const { app, token } = await setup();
    const headers = { authorization: `Bearer ${token}` };

    expect((await app.inject({ method: 'DELETE', url: '/me', headers })).statusCode).toBe(204);
    expect((await app.inject({ method: 'DELETE', url: '/me', headers })).statusCode).toBe(204);
  });

  it('returns 503 when deletion is not configured, rather than pretending', async () => {
    const { app, token } = await setup({ wired: false });
    const res = await app.inject({
      method: 'DELETE',
      url: '/me',
      headers: { authorization: `Bearer ${token}` },
    });
    expect(res.statusCode).toBe(503);
  });
});
