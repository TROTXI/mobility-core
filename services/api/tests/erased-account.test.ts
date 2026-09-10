// An erased account (#30) keeps its row so the ledgers stay attributable, but it
// must stop being someone the API will talk to. Access tokens outlive the
// erasure that revoked their session, and Paystack re-delivers charge.success
// for days, so both routes back onto an erased row are closed here.

import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { AccountDeletionService } from '../src/modules/users/account-deletion.service';
import { InMemoryAuthIdentityRepository } from '../src/modules/auth/auth-identity.repository';
import { InMemorySessionRepository } from '../src/modules/auth/session.repository';
import { InMemoryDeviceTokenRepository } from '../src/modules/devices/device-token.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { FakeObjectStore } from '../src/storage/object-store';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);

async function setup() {
  const users = new InMemoryUserRepository();
  const user = await users.create({ displayName: 'Ama', email: 'ama@example.com' });
  const accountDeletion = new AccountDeletionService({
    users,
    sessions: new InMemorySessionRepository(),
    authIdentities: new InMemoryAuthIdentityRepository(),
    devices: new InMemoryDeviceTokenRepository(),
    objectStore: new FakeObjectStore(),
  });
  const app = await buildApp({ auth, users, accountDeletion });
  // Minted BEFORE the erasure, exactly like the token in the hand of an app
  // that just tapped "delete my account".
  const token = await jwt.signAccessToken({ userId: user.id, role: 'commuter' });
  await accountDeletion.deleteAccount(user.id);
  return { app, users, user, token };
}

const bearer = (t: string) => ({ authorization: `Bearer ${t}` });

describe('an erased account', () => {
  it('cannot read itself with a token minted before the erasure', async () => {
    const { app, token } = await setup();
    const res = await app.inject({ method: 'GET', url: '/me', headers: bearer(token) });
    expect(res.statusCode).toBe(404);
  });

  it('cannot write a display name back onto the row', async () => {
    const { app, token, users, user } = await setup();
    const res = await app.inject({
      method: 'PATCH',
      url: '/me',
      headers: bearer(token),
      payload: { displayName: 'Ama Again' },
    });
    expect(res.statusCode).toBe(404);
    expect((await users.findByIdIncludingErased(user.id))?.displayName).not.toBe('Ama Again');
  });

  it('refuses a late webhook trying to restore the rider’s phone number', async () => {
    // Paystack retries charge.success for days. Landing after deletion, this
    // used to put a real phone number back on a row we told the rider was wiped.
    const { users, user } = await setup();
    expect(await users.backfillContact(user.id, { phone: '+233201234567' })).toBeNull();
    expect((await users.findByIdIncludingErased(user.id))?.phone).toBeNull();
  });

  it('keeps the row itself, so payments and both ledgers stay attributable', async () => {
    const { users, user } = await setup();
    expect(await users.findByIdIncludingErased(user.id)).not.toBeNull();
    expect(await users.findById(user.id)).toBeNull();
  });
});
