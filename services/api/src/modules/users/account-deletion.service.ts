// Account erasure (#30). ANONYMISES rather than deletes: payments and both
// ledgers cascade off users, so DELETE FROM users would destroy the financial
// record of what a rider paid.
//
// Order matters — access is cut first, then provider links, then the PII.

import type { AppleTokenClient } from '../auth/apple-token.client';
import type { AuthIdentityRepository } from '../auth/auth-identity.repository';
import type { SessionRepository } from '../auth/session.repository';
import type { DeviceTokenRepository } from '../devices/device-token.repository';
import type { ObjectStore } from '../../storage/object-store';
import type { UserRepository } from './user.repository';

/** Collaborators for {@link AccountDeletionService}. */
export interface AccountDeletionDeps {
  users: UserRepository;
  sessions: SessionRepository;
  authIdentities: AuthIdentityRepository;
  devices: DeviceTokenRepository;
  objectStore: ObjectStore;
  /**
   * Apple's token endpoints (#213). Undefined when unconfigured, in which case
   * deletion behaves as it always did.
   */
  appleTokens?: AppleTokenClient;
}

/** Erases a user's personal data across every store that holds it. */
export class AccountDeletionService {
  /** @param deps - the repositories and object store to clear. */
  constructor(private readonly deps: AccountDeletionDeps) {}

  /**
   * Erase an account. Idempotent, so a retry after a timeout is safe.
   *
   * @param userId - the account to erase.
   * @returns true when the user existed, false when there was nothing to erase.
   */
  async deleteAccount(userId: string): Promise<boolean> {
    const user = await this.deps.users.findById(userId);
    if (!user) return false;

    // Cut access first: an app mid-request must not keep acting as this account.
    await this.deps.sessions.revokeAllForUser(userId);
    await this.deps.devices.removeForUser(userId);

    // Tell Apple before we forget the link. Apple requires an app offering both
    // Sign in with Apple and account deletion to revoke here; unlinking on our
    // side alone leaves us listed under the rider's Apple ID for an account that
    // no longer exists, and it is checked at App Store review.
    await this.revokeAppleAccess(userId);

    // Unlink providers, so signing in again creates a NEW user.
    await this.deps.authIdentities.deleteForUser(userId);

    // The only PII outside Postgres. Best effort — a storage failure must not
    // block the rest of the erasure.
    if (user.avatarUrl) {
      try {
        await this.deps.objectStore.deleteObject(user.avatarUrl);
      } catch {
        // Orphaned object; the record linking it to a person is gone regardless.
      }
    }

    // Keep the row and its id so the ledgers stay balanced.
    await this.deps.users.anonymise(userId);
    return true;
  }

  /**
   * Revoke our access at Apple for every Apple identity on this account.
   *
   * Best effort. A rider asked us to delete their account, and Apple being
   * unreachable is not a reason to refuse them, or to abandon the erasure
   * half-done with their sessions already dead.
   *
   * @param userId - the account being erased.
   */
  private async revokeAppleAccess(userId: string): Promise<void> {
    if (!this.deps.appleTokens) return;
    const identities = await this.deps.authIdentities.listForUser(userId);
    for (const identity of identities) {
      if (identity.provider !== 'apple' || !identity.providerRefreshToken) continue;
      try {
        await this.deps.appleTokens.revoke(identity.providerRefreshToken);
      } catch {
        // Nothing useful to do: the account still has to go.
      }
    }
  }
}
