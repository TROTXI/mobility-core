import { describe, expect, it } from 'vitest';
import { AccountDeletionService } from '../src/modules/users/account-deletion.service';
import {
  ANONYMISED_DISPLAY_NAME,
  InMemoryUserRepository,
} from '../src/modules/users/user.repository';
import { InMemoryAuthIdentityRepository } from '../src/modules/auth/auth-identity.repository';
import { InMemorySessionRepository } from '../src/modules/auth/session.repository';
import { InMemoryDeviceTokenRepository } from '../src/modules/devices/device-token.repository';
import { FakeObjectStore } from '../src/storage/object-store';

async function make() {
  const users = new InMemoryUserRepository();
  const sessions = new InMemorySessionRepository();
  const authIdentities = new InMemoryAuthIdentityRepository();
  const devices = new InMemoryDeviceTokenRepository();
  const objectStore = new FakeObjectStore();

  const user = await users.create({
    displayName: 'Ama Boateng',
    email: 'ama@example.com',
    phone: '+233244123456',
  });
  await authIdentities.create({ userId: user.id, provider: 'google', providerId: 'g-1' });
  await devices.register(user.id, 'fcm-token-1', 'android');
  const key = await objectStore.putAvatar(user.id, Buffer.from('jpegbytes'), 'image/jpeg');
  await users.setAvatarKey(user.id, key);

  const service = new AccountDeletionService({
    users,
    sessions,
    authIdentities,
    devices,
    objectStore,
  });
  return { service, users, sessions, authIdentities, devices, objectStore, user, key };
}

describe('AccountDeletionService', () => {
  it('clears every piece of personal data', async () => {
    const { service, users, user } = await make();

    expect(await service.deleteAccount(user.id)).toBe(true);

    const after = await users.findById(user.id);
    expect(after?.displayName).toBe(ANONYMISED_DISPLAY_NAME);
    expect(after?.email).toBeNull();
    expect(after?.phone).toBeNull();
    expect(after?.avatarUrl).toBeNull();
    expect(after?.deletedAt).toBeInstanceOf(Date);
  });

  it('keeps the user row so the money tables stay attributable', async () => {
    // payments, entitlement_ledger and credit_ledger all cascade off users.
    // A hard delete would take the financial record with it, which is exactly
    // what this design exists to avoid.
    const { service, users, user } = await make();
    await service.deleteAccount(user.id);
    expect(await users.findById(user.id)).not.toBeNull();
  });

  it('removes the avatar from object storage, not just the column', async () => {
    const { service, objectStore, user, key } = await make();
    expect(objectStore.peek(key)).toBeDefined();

    await service.deleteAccount(user.id);
    expect(objectStore.peek(key)).toBeUndefined();
  });

  it('unlinks providers so signing in again creates a new account', async () => {
    const { service, authIdentities, user } = await make();
    await service.deleteAccount(user.id);
    expect(await authIdentities.findByProvider('google', 'g-1')).toBeNull();
  });

  it('cuts sessions and push devices', async () => {
    const { service, devices, user } = await make();
    await service.deleteAccount(user.id);
    expect(await devices.listForUser(user.id)).toHaveLength(0);
  });

  it('is idempotent — a retried request does not fail or move deletedAt', async () => {
    const { service, users, user } = await make();
    await service.deleteAccount(user.id);
    const first = (await users.findById(user.id))!.deletedAt;

    expect(await service.deleteAccount(user.id)).toBe(true);
    expect((await users.findById(user.id))!.deletedAt).toEqual(first);
  });

  it('reports false for an unknown user', async () => {
    const { service } = await make();
    expect(await service.deleteAccount('00000000-0000-4000-8000-000000000000')).toBe(false);
  });
});
