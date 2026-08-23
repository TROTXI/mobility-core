// Reference repository pattern: an interface with two implementations -
// InMemory (tests + zero-infra dev) and Postgres (real runs, see *.pg.ts).
// The server picks one by DATABASE_URL. Copy this shape for new domain modules.

/** Display name left behind after erasure — never a real person's name. */
export const ANONYMISED_DISPLAY_NAME = 'Deleted user';

export const USER_ROLES = ['commuter', 'driver', 'admin'] as const;
export type UserRole = (typeof USER_ROLES)[number];

/** A platform user (commuter, driver, or admin). */
export interface User {
  id: string;
  displayName: string;
  /** Set when the account was erased on request (#30); PII columns are cleared. */
  deletedAt: Date | null;
  /** Verified address from the social identity provider; null for pre-#182 rows. */
  email: string | null;
  /** E.164 normalised (+233…), captured from a successful Paystack charge. */
  phone: string | null;
  avatarUrl: string | null;
  role: UserRole;
  createdAt: Date;
}

/** Fields needed to create a user; the rest default or are server-set. */
export interface NewUser {
  displayName: string;
  email?: string | null;
  phone?: string | null;
  /** Defaults to `commuter` when omitted. */
  role?: UserRole;
}

/** Persistence for users. Backed by Postgres in prod, in-memory in dev/tests. */
export interface UserRepository {
  /**
   * Create a user.
   *
   * @param input - the user to create.
   * @returns the persisted user, with generated id and defaults applied.
   */
  create(input: NewUser): Promise<User>;
  /**
   * Look up a user by id.
   *
   * @param id - the user id.
   * @returns the user, or null if not found.
   */
  findById(id: string): Promise<User | null>;
  /**
   * Update a user's editable profile fields.
   *
   * @param id - the user id.
   * @param patch - the fields to change.
   * @param patch.displayName - the new display name.
   * @returns the updated user, or null if not found.
   */
  updateProfile(id: string, patch: { displayName: string }): Promise<User | null>;
  /**
   * Set (or clear) a user's stored avatar object key.
   *
   * @param id - the user id.
   * @param key - the object-store key, or null to remove the avatar.
   * @returns the updated user, or null if not found.
   */
  setAvatarKey(id: string, key: string | null): Promise<User | null>;
  /**
   * Change a user's role (admin op, #26). The JWT carries the role at sign-in,
   * so the change takes effect on the user's next token refresh/sign-in.
   *
   * @param id - the user id.
   * @param role - the role to grant.
   * @returns the updated user, or null if not found.
   */
  setRole(id: string, role: UserRole): Promise<User | null>;
  /**
   * Fill in contact details we did not have before, without overwriting details
   * we already hold. Used to backfill users who signed up before #182 (on their
   * next sign-in) and to capture the payer's phone from the Paystack webhook.
   *
   * A field is written only when the stored value is null, so a rider who edits
   * their profile is never silently reverted by a later webhook.
   *
   * @param id - the user to backfill.
   * @param contact - the contact details to fill in where missing.
   * @param contact.email - verified email, or undefined to leave alone.
   * @param contact.phone - E.164 phone, or undefined to leave alone.
   * @returns the updated user, or null if not found.
   */
  backfillContact(
    id: string,
    contact: { email?: string | null; phone?: string | null },
  ): Promise<User | null>;
  /**
   * Erase a user's personal data while keeping the row (#30).
   *
   * Not a DELETE: payments, entitlement_ledger and credit_ledger all cascade off
   * users, so removing the row would destroy the financial record of what the
   * rider paid and was charged. Those are our books and have to outlive a
   * deletion request; the person behind them does not.
   *
   * Idempotent — anonymising twice is a no-op, so a retried request is safe.
   *
   * @param id - the user to erase.
   * @returns the anonymised user, or null if not found.
   */
  anonymise(id: string): Promise<User | null>;
}

/** In-memory {@link UserRepository} for dev and unit tests. */
export class InMemoryUserRepository implements UserRepository {
  private readonly users = new Map<string, User>();

  async create(input: NewUser): Promise<User> {
    const user: User = {
      id: crypto.randomUUID(),
      displayName: input.displayName,
      deletedAt: null,
      email: input.email ?? null,
      phone: input.phone ?? null,
      avatarUrl: null,
      role: input.role ?? 'commuter',
      createdAt: new Date(),
    };
    this.users.set(user.id, user);
    return user;
  }

  async findById(id: string): Promise<User | null> {
    return this.users.get(id) ?? null;
  }

  async updateProfile(id: string, patch: { displayName: string }): Promise<User | null> {
    const user = this.users.get(id);
    if (!user) return null;
    const updated = { ...user, displayName: patch.displayName };
    this.users.set(id, updated);
    return updated;
  }

  async setAvatarKey(id: string, key: string | null): Promise<User | null> {
    const user = this.users.get(id);
    if (!user) return null;
    const updated = { ...user, avatarUrl: key };
    this.users.set(id, updated);
    return updated;
  }

  async setRole(id: string, role: UserRole): Promise<User | null> {
    const user = this.users.get(id);
    if (!user) return null;
    const updated = { ...user, role };
    this.users.set(id, updated);
    return updated;
  }

  async backfillContact(
    id: string,
    contact: { email?: string | null; phone?: string | null },
  ): Promise<User | null> {
    const user = this.users.get(id);
    if (!user) return null;
    const updated: User = {
      ...user,
      email: user.email ?? contact.email ?? null,
      phone: user.phone ?? contact.phone ?? null,
    };
    this.users.set(id, updated);
    return updated;
  }

  async anonymise(id: string): Promise<User | null> {
    const user = this.users.get(id);
    if (!user) return null;
    const updated: User = {
      ...user,
      displayName: ANONYMISED_DISPLAY_NAME,
      email: null,
      phone: null,
      avatarUrl: null,
      deletedAt: user.deletedAt ?? new Date(),
    };
    this.users.set(id, updated);
    return updated;
  }
}
