// Driver sign-in (#223). Drivers are issued by an operator rather than
// self-registering, so the credential is a code ops hands out plus a PIN only
// the driver knows. Everything downstream of a token is unchanged: the access
// token still carries `role: 'driver'`, and the assigned-driver checks resolve
// through `drivers.user_id` exactly as they already do.
//
// Lockout is durable (driver_credentials.locked_until) rather than cached. The
// boarding-code budget fails OPEN because a rider must never be stranded at the
// kerb; a credential check has to fail CLOSED, and a counter in a cache can be
// cleared by flushing it.

import type { DriverRepository } from '../mobility/driver.repository';
import type { User, UserRepository } from '../users/user.repository';
import type {
  DriverCredential,
  DriverCredentialRepository,
  DriverCredentialStatus,
} from './driver-credential.repository';
import {
  generateDriverCode,
  generatePin,
  hashDriverPin,
  isTrivialPin,
  normalizeDriverCode,
  verifyDriverPin,
} from './driver-pin';
import type { JwtService } from './jwt';
import { issueSessionTokens, type AuthTokens } from './session-issuer';
import type { SessionRepository } from './session.repository';

/** Wrong code, wrong PIN, or no credential. Routes map it to 401. */
export class InvalidDriverCredentialsError extends Error {}

/** Too many wrong PINs. Routes map it to 423. */
export class DriverCredentialLockedError extends Error {
  /** @param retryAfterSeconds - how long until the lock lifts. */
  constructor(readonly retryAfterSeconds: number) {
    super('Too many incorrect PINs');
  }
}

/** Ops has suspended this credential. Routes map it to 403. */
export class DriverCredentialSuspendedError extends Error {}

/** A PIN that is refused on sight (trivial, or the one already in use). */
export class WeakPinError extends Error {}

/** The driver has no credential, or the credential has no driver. */
export class DriverNotFoundError extends Error {}

/** A successful driver sign-in. */
export interface DriverAuthResult extends AuthTokens {
  user: User;
  driver: { id: string; fullName: string };
  /** True while the driver is still using the PIN ops issued. */
  mustChangePin: boolean;
}

/** A freshly issued credential. The plaintext appears here and nowhere else. */
export interface IssuedCredential {
  driverCode: string;
  /** Shown to ops once, never recoverable. */
  pin: string;
}

/** Collaborators for {@link DriverAuthService}. */
export interface DriverAuthServiceDeps {
  credentials: DriverCredentialRepository;
  drivers: DriverRepository;
  users: UserRepository;
  sessions: SessionRepository;
  jwt: JwtService;
  /** Server key the PIN hash is computed under. */
  secret: string;
  /** Refresh lifetime when the driver ticks "Remember this device". */
  refreshTtlDays: number;
  /**
   * Refresh lifetime when they do not. A shared depot handset must not stay
   * signed in past the shift that used it.
   */
  shiftTtlHours: number;
}

/** Wrong PINs tolerated before the credential locks. */
const LOCK_AFTER_ATTEMPTS = 5;

/** How long a lock lasts. */
const LOCK_DURATION_MS = 15 * 60 * 1000;

/** Driver sign-in, PIN rotation, and the ops-side credential lifecycle. */
export class DriverAuthService {
  /** @param deps - repositories, the token signer, and the PIN key. */
  constructor(private readonly deps: DriverAuthServiceDeps) {}

  /**
   * Sign a driver in with their code and PIN.
   *
   * A wrong code and a wrong PIN fail identically. Telling them apart would let
   * anyone enumerate which codes exist, and a driver code is written on depot
   * whiteboards and read down phone lines.
   *
   * @param driverCode - the code as typed; case and the `DR-` prefix are
   *   normalised.
   * @param pin - the PIN as typed.
   * @param opts - session options.
   * @param opts.rememberDevice - true for the driver's own handset (full
   *   refresh lifetime), false for a shared one (a shift).
   * @returns the tokens, the user, the driver, and whether the PIN is still the
   *   one ops issued.
   * @throws InvalidDriverCredentialsError on a bad code or PIN.
   * @throws DriverCredentialLockedError when the credential is locked.
   * @throws DriverCredentialSuspendedError when ops has suspended it.
   */
  async signIn(
    driverCode: string,
    pin: string,
    opts: { rememberDevice?: boolean } = {},
  ): Promise<DriverAuthResult> {
    const credential = await this.deps.credentials.findByCode(normalizeDriverCode(driverCode));
    if (!credential) {
      throw new InvalidDriverCredentialsError('Invalid driver code or PIN');
    }
    if (credential.status === 'suspended') {
      throw new DriverCredentialSuspendedError('This driver account is suspended');
    }
    this.assertNotLocked(credential);

    if (!verifyDriverPin(pin, credential.pinHash, this.deps.secret)) {
      const after = await this.deps.credentials.recordFailure(
        credential.id,
        LOCK_AFTER_ATTEMPTS,
        LOCK_DURATION_MS,
      );
      // Say so immediately on the attempt that locks it, rather than letting the
      // driver keep typing into a credential that has already stopped listening.
      if (after) this.assertNotLocked(after);
      throw new InvalidDriverCredentialsError('Invalid driver code or PIN');
    }

    const { user, driver } = await this.resolvePrincipal(credential);
    await this.deps.credentials.clearFailures(credential.id);

    const tokens = await issueSessionTokens(
      { sessions: this.deps.sessions, jwt: this.deps.jwt },
      user,
      { refreshTtlDays: this.refreshTtlFor(opts.rememberDevice ?? false) },
    );
    return {
      ...tokens,
      user,
      driver: { id: driver.id, fullName: driver.fullName },
      mustChangePin: credential.mustChangePin,
    };
  }

  /**
   * Replace a driver's PIN with one of their own choosing.
   *
   * Revokes every other session for the account. A rotation that leaves the old
   * sessions alive changes the credential without evicting whoever prompted the
   * rotation, which is the only reason a driver would be doing this in a hurry.
   *
   * @param userId - the signed-in driver.
   * @param currentPin - the PIN in use.
   * @param newPin - the replacement.
   * @throws InvalidDriverCredentialsError when the current PIN is wrong.
   * @throws WeakPinError when the new PIN is trivial or unchanged.
   * @throws DriverNotFoundError when the caller has no credential.
   */
  async changePin(userId: string, currentPin: string, newPin: string): Promise<void> {
    const credential = await this.credentialForUser(userId);
    if (!verifyDriverPin(currentPin, credential.pinHash, this.deps.secret)) {
      throw new InvalidDriverCredentialsError('Current PIN is incorrect');
    }
    if (isTrivialPin(newPin)) {
      throw new WeakPinError('Choose a PIN that is not a repeat or a run of digits');
    }
    if (verifyDriverPin(newPin, credential.pinHash, this.deps.secret)) {
      throw new WeakPinError('Choose a PIN you have not just used');
    }
    await this.deps.credentials.setPin(credential.id, {
      pinHash: hashDriverPin(newPin, this.deps.secret),
      mustChangePin: false,
    });
    await this.deps.sessions.revokeAllForUser(userId);
  }

  /**
   * Issue a credential for a driver (ops).
   *
   * Also creates and links the driver's auth principal, which is what finally
   * populates the `drivers.user_id` that migration 015 left nullable.
   *
   * @param driverId - the driver to issue for.
   * @returns the code and the one-time PIN, returned once and never again.
   * @throws DriverNotFoundError when the driver does not exist.
   */
  async issueCredential(driverId: string): Promise<IssuedCredential> {
    const driver = await this.deps.drivers.findById(driverId);
    if (!driver) throw new DriverNotFoundError('Driver not found');

    if (!driver.userId) {
      const user = await this.deps.users.create({
        displayName: driver.fullName,
        phone: driver.phone,
        role: 'driver',
      });
      await this.deps.drivers.update(driver.id, { userId: user.id });
    }

    const pin = generatePin();
    // Retry on a code collision rather than failing the request: 810,000 codes
    // makes one unlikely and an operator standing at a desk should not be handed
    // an error they can do nothing about.
    for (let attempt = 0; attempt < 5; attempt++) {
      const driverCode = generateDriverCode();
      try {
        await this.deps.credentials.create({
          driverId,
          driverCode,
          pinHash: hashDriverPin(pin, this.deps.secret),
        });
        return { driverCode, pin };
      } catch (err) {
        // A second credential for the SAME driver is a real conflict, not a
        // collision; only a duplicate code is worth retrying.
        const existing = await this.deps.credentials.findByDriverId(driverId);
        if (existing || !isUniqueViolation(err)) throw err;
      }
    }
    throw new Error('Could not allocate a unique driver code');
  }

  /**
   * Reset a driver's PIN (ops). This is the recovery path the sign-in screen
   * points at: there is no self-service reset because `drivers.phone` is
   * nullable, so there is no verified channel to send one to.
   *
   * Returns the code alongside the PIN. Operations is reading both down a phone
   * line to a driver who has lost their slip, and a reset that hands back only
   * half of what they need is a reset they cannot actually deliver.
   *
   * @param driverId - the driver.
   * @returns the driver's code and the new one-time PIN.
   * @throws DriverNotFoundError when the driver has no credential.
   */
  async resetPin(driverId: string): Promise<IssuedCredential> {
    const credential = await this.deps.credentials.findByDriverId(driverId);
    if (!credential) throw new DriverNotFoundError('Driver has no credential');
    const pin = generatePin();
    await this.deps.credentials.setPin(credential.id, {
      pinHash: hashDriverPin(pin, this.deps.secret),
      mustChangePin: true,
    });
    // The old PIN is gone, so anything signed in on it should be too.
    const driver = await this.deps.drivers.findById(driverId);
    if (driver?.userId) await this.deps.sessions.revokeAllForUser(driver.userId);
    return { driverCode: credential.driverCode, pin };
  }

  /**
   * Suspend or reinstate a credential (ops). Suspending revokes live sessions,
   * since the point is to stop someone driving now, not at token expiry.
   *
   * @param driverId - the driver.
   * @param status - the status to set.
   * @throws DriverNotFoundError when the driver has no credential.
   */
  async setStatus(driverId: string, status: DriverCredentialStatus): Promise<void> {
    const credential = await this.deps.credentials.findByDriverId(driverId);
    if (!credential) throw new DriverNotFoundError('Driver has no credential');
    await this.deps.credentials.setStatus(credential.id, status);
    if (status === 'suspended') {
      const driver = await this.deps.drivers.findById(driverId);
      if (driver?.userId) await this.deps.sessions.revokeAllForUser(driver.userId);
    }
  }

  /**
   * Clear a lockout (ops), for the driver who locked themselves out and rang in.
   *
   * @param driverId - the driver.
   * @throws DriverNotFoundError when the driver has no credential.
   */
  async unlock(driverId: string): Promise<void> {
    const credential = await this.deps.credentials.findByDriverId(driverId);
    if (!credential) throw new DriverNotFoundError('Driver has no credential');
    await this.deps.credentials.clearFailures(credential.id);
  }

  /**
   * Refresh lifetime in days for this sign-in.
   *
   * @param rememberDevice - whether the driver claimed the handset as theirs.
   * @returns the lifetime to mint the refresh token with.
   */
  private refreshTtlFor(rememberDevice: boolean): number {
    return rememberDevice ? this.deps.refreshTtlDays : this.deps.shiftTtlHours / 24;
  }

  /**
   * Throw when a credential is inside its lockout window.
   *
   * @param credential - the credential being checked.
   * @throws DriverCredentialLockedError while the lock holds.
   */
  private assertNotLocked(credential: DriverCredential): void {
    if (!credential.lockedUntil) return;
    const remainingMs = credential.lockedUntil.getTime() - Date.now();
    if (remainingMs > 0) {
      throw new DriverCredentialLockedError(Math.ceil(remainingMs / 1000));
    }
  }

  /**
   * Resolve a credential to the driver and the auth principal behind it.
   *
   * @param credential - the verified credential.
   * @returns the user and driver.
   * @throws DriverNotFoundError when the link is missing.
   */
  private async resolvePrincipal(
    credential: DriverCredential,
  ): Promise<{ user: User; driver: { id: string; fullName: string } }> {
    const driver = await this.deps.drivers.findById(credential.driverId);
    if (!driver?.userId) throw new DriverNotFoundError('Driver is not linked to an account');
    const user = await this.deps.users.findById(driver.userId);
    if (!user) throw new DriverNotFoundError('Driver account is missing');
    return { user, driver };
  }

  /**
   * The signed-in driver's credential.
   *
   * @param userId - the auth principal.
   * @returns their credential.
   * @throws DriverNotFoundError when there is none.
   */
  private async credentialForUser(userId: string): Promise<DriverCredential> {
    const driver = await this.deps.drivers.findByUserId(userId);
    if (!driver) throw new DriverNotFoundError('No driver for this account');
    const credential = await this.deps.credentials.findByDriverId(driver.id);
    if (!credential) throw new DriverNotFoundError('Driver has no credential');
    return credential;
  }
}

/**
 * True when a pg error is a unique-constraint violation (SQLSTATE 23505).
 *
 * @param err - the caught error (unknown shape).
 * @returns whether it is a Postgres unique-violation.
 */
function isUniqueViolation(err: unknown): boolean {
  return (err as { code?: string }).code === '23505';
}
