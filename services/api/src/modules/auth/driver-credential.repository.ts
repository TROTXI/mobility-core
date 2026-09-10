// Driver credentials (#223) — the code and PIN an ops-issued driver signs in
// with. Two implementations: InMemory for dev/tests, Postgres in
// driver-credential.repository.pg.ts (ADR-0009).
//
// The PIN never appears here in plaintext. Callers hash it (driver-pin.ts)
// before it reaches the repository, so a repository this thin cannot leak one.

/** Whether ops currently allows this credential to sign in. */
export type DriverCredentialStatus = 'active' | 'suspended';

/** An ops-issued driver credential. */
export interface DriverCredential {
  id: string;
  driverId: string;
  /** What the driver types. Not secret. */
  driverCode: string;
  /** HMAC of the PIN under the server secret. */
  pinHash: string;
  pinSetAt: Date;
  /** True until the driver replaces the PIN ops issued. */
  mustChangePin: boolean;
  /** Consecutive wrong PINs since the last success. */
  failedAttempts: number;
  /** When the lockout lifts, or null when not locked. */
  lockedUntil: Date | null;
  status: DriverCredentialStatus;
  createdAt: Date;
  updatedAt: Date;
}

/** What issuing a credential needs. */
export interface NewDriverCredential {
  driverId: string;
  driverCode: string;
  pinHash: string;
}

/** Persistence for driver credentials. */
export interface DriverCredentialRepository {
  /**
   * Issue a credential for a driver.
   *
   * @param input - the driver, their code, and the hashed PIN.
   * @returns the stored credential.
   * @throws on a unique violation if the driver or code already has one.
   */
  create(input: NewDriverCredential): Promise<DriverCredential>;
  /**
   * Look up a credential by the code the driver typed.
   *
   * @param driverCode - the canonical code.
   * @returns the credential, or null.
   */
  findByCode(driverCode: string): Promise<DriverCredential | null>;
  /**
   * Look up a driver's credential.
   *
   * @param driverId - the driver.
   * @returns the credential, or null.
   */
  findByDriverId(driverId: string): Promise<DriverCredential | null>;
  /**
   * Replace the PIN and clear the lockout, as a rotation or an ops reset.
   *
   * @param id - the credential.
   * @param patch - the new hash and whether it still has to be changed.
   * @param patch.pinHash - the new keyed hash.
   * @param patch.mustChangePin - true for an ops-issued PIN, false for the
   *   driver's own choice.
   * @returns the updated credential, or null if it does not exist.
   */
  setPin(
    id: string,
    patch: { pinHash: string; mustChangePin: boolean },
  ): Promise<DriverCredential | null>;
  /**
   * Record a wrong PIN, locking the credential once the budget is spent.
   *
   * Returns the updated row so the caller can tell the driver when the lock
   * lifts without a second read.
   *
   * @param id - the credential.
   * @param lockAfter - failures tolerated before locking.
   * @param lockFor - how long the lock lasts, in milliseconds.
   * @returns the updated credential, or null if it does not exist.
   */
  recordFailure(id: string, lockAfter: number, lockFor: number): Promise<DriverCredential | null>;
  /**
   * Clear the failure count and any lock, after a successful sign-in or an ops
   * unlock.
   *
   * @param id - the credential.
   * @returns the updated credential, or null if it does not exist.
   */
  clearFailures(id: string): Promise<DriverCredential | null>;
  /**
   * Suspend or reinstate a credential.
   *
   * @param id - the credential.
   * @param status - the status to set.
   * @returns the updated credential, or null if it does not exist.
   */
  setStatus(id: string, status: DriverCredentialStatus): Promise<DriverCredential | null>;
}

/** In-memory {@link DriverCredentialRepository} for dev and unit tests. */
export class InMemoryDriverCredentialRepository implements DriverCredentialRepository {
  private readonly byId = new Map<string, DriverCredential>();

  async create(input: NewDriverCredential): Promise<DriverCredential> {
    // Mirror the table's UNIQUE constraints, including the SQLSTATE, so the
    // service's duplicate handling is exercised by the fakes too (ADR-0009).
    for (const existing of this.byId.values()) {
      if (existing.driverId === input.driverId || existing.driverCode === input.driverCode) {
        throw Object.assign(new Error('duplicate driver credential'), { code: '23505' });
      }
    }
    const now = new Date();
    const credential: DriverCredential = {
      id: crypto.randomUUID(),
      driverId: input.driverId,
      driverCode: input.driverCode,
      pinHash: input.pinHash,
      pinSetAt: now,
      mustChangePin: true,
      failedAttempts: 0,
      lockedUntil: null,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    };
    this.byId.set(credential.id, credential);
    return credential;
  }

  async findByCode(driverCode: string): Promise<DriverCredential | null> {
    for (const credential of this.byId.values()) {
      if (credential.driverCode === driverCode) return credential;
    }
    return null;
  }

  async findByDriverId(driverId: string): Promise<DriverCredential | null> {
    for (const credential of this.byId.values()) {
      if (credential.driverId === driverId) return credential;
    }
    return null;
  }

  async setPin(
    id: string,
    patch: { pinHash: string; mustChangePin: boolean },
  ): Promise<DriverCredential | null> {
    const credential = this.byId.get(id);
    if (!credential) return null;
    const updated: DriverCredential = {
      ...credential,
      pinHash: patch.pinHash,
      mustChangePin: patch.mustChangePin,
      pinSetAt: new Date(),
      failedAttempts: 0,
      lockedUntil: null,
      updatedAt: new Date(),
    };
    this.byId.set(id, updated);
    return updated;
  }

  async recordFailure(
    id: string,
    lockAfter: number,
    lockFor: number,
  ): Promise<DriverCredential | null> {
    const credential = this.byId.get(id);
    if (!credential) return null;
    const failedAttempts = credential.failedAttempts + 1;
    const updated: DriverCredential = {
      ...credential,
      failedAttempts,
      lockedUntil:
        failedAttempts >= lockAfter ? new Date(Date.now() + lockFor) : credential.lockedUntil,
      updatedAt: new Date(),
    };
    this.byId.set(id, updated);
    return updated;
  }

  async clearFailures(id: string): Promise<DriverCredential | null> {
    const credential = this.byId.get(id);
    if (!credential) return null;
    const updated: DriverCredential = {
      ...credential,
      failedAttempts: 0,
      lockedUntil: null,
      updatedAt: new Date(),
    };
    this.byId.set(id, updated);
    return updated;
  }

  async setStatus(id: string, status: DriverCredentialStatus): Promise<DriverCredential | null> {
    const credential = this.byId.get(id);
    if (!credential) return null;
    const updated: DriverCredential = { ...credential, status, updatedAt: new Date() };
    this.byId.set(id, updated);
    return updated;
  }
}
