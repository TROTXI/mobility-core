// Account erasure (#30). Required by App Store and Play before either app ships.
//
// Deletion here means ANONYMISE, not DROP. payments, entitlement_ledger and
// credit_ledger all cascade off users, so `DELETE FROM users` would take the
// financial record of what someone paid and what they were charged with it.
// Those are our books; they have to outlive a deletion request. The person
// behind them does not.
//
// Order matters. Sessions and devices are cut first so an in-flight app cannot
// keep acting as the account while the erasure runs; the identity links go next
// so a returning person signs up fresh instead of resurrecting the anonymised
// row; the PII is cleared last, once nothing can still reach it.

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
}

/** Erases a user's personal data across every store that holds it. */
export class AccountDeletionService {
  /** @param deps - the repositories and object store to clear. */
  constructor(private readonly deps: AccountDeletionDeps) {}

  /**
   * Erase an account. Idempotent: running it twice on the same user is a no-op,
   * so a client retrying after a timeout cannot fail or double-report.
   *
   * @param userId - the account to erase.
   * @returns true when the user existed, false when there was nothing to erase.
   */
  async deleteAccount(userId: string): Promise<boolean> {
    const user = await this.deps.users.findById(userId);
    if (!user) return false;

    // 1. Cut access first. An app mid-request must not keep acting as this
    //    account while the rest of the erasure runs.
    await this.deps.sessions.revokeAllForUser(userId);
    await this.deps.devices.removeForUser(userId);

    // 2. Unlink the providers, so signing in with the same Google account
    //    creates a NEW user rather than reopening this one.
    await this.deps.authIdentities.deleteForUser(userId);

    // 3. The avatar is the only personal data outside Postgres — clearing the
    //    column alone would leave the image sitting in the bucket. Best effort:
    //    a storage failure must not block the erasure of everything else, and
    //    the DB no longer points at the object either way.
    if (user.avatarUrl) {
      try {
        await this.deps.objectStore.deleteObject(user.avatarUrl);
      } catch {
        // Orphaned object; the record linking it to a person is gone regardless.
      }
    }

    // 4. Clear the PII, keep the row and its id so the ledgers stay balanced.
    await this.deps.users.anonymise(userId);
    return true;
  }
}
