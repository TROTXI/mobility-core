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
   * Look up a LIVE user by id.
   *
   * Erased accounts (#30) are invisible here even though the row survives for
   * the ledgers. An access token outlives the erasure that revoked its session,
   * so without this the deleted account keeps answering `GET /me` and keeps
   * accepting writes for the rest of the token's lifetime.
   *
   * @param id - the user id.
   * @returns the user, or null if not found or erased.
   */
  findById(id: string): Promise<User | null>;
  /**
   * Look up a user by id INCLUDING erased accounts.
   *
   * The one reader that can see past `deleted_at`, for the erasure path itself:
   * a retried deletion has to find the row it already anonymised in order to
   * converge. Everything product-facing uses {@link UserRepository.findById}
   * instead, which cannot see erased accounts at all.
   *
   * @param id - the user id.
   * @returns the user, erased or not, or null if the row does not exist.
   */
  findByIdIncludingErased(id: string): Promise<User | null>;
  /**
   * Update a user's editable profile fields.
   *
   * @param id - the user id.
   * @param patch - the fields to change.
   * @param patch.displayName - the new display name.
   * @returns the updated user, or null if not found or erased.
   */
  updateProfile(id: string, patch: { displayName: string }): Promise<User | null>;
  /**
   * Set (or clear) a user's stored avatar object key.
   *
   * @param id - the user id.
   * @param key - the object-store key, or null to remove the avatar.
   * @returns the updated user, or null if not found or erased.
   */
  setAvatarKey(id: string, key: string | null): Promise<User | null>;
  /**
   * Change a user's role (admin op, #26). The JWT carries the role at sign-in,
   * so the change takes effect on the user's next token refresh/sign-in.
   *
   * @param id - the user id.
   * @param role - the role to grant.
   * @returns the updated user, or null if not found or erased.
   */
  setRole(id: string, role: UserRole): Promise<User | null>;
  /**
   * Fill in missing contact details without overwriting what we hold (#182).
   *
   * Only writes where the stored value is null, so a webhook never reverts a
   * detail the rider edited, and never on an erased account: Paystack re-delivers
   * `charge.success` for days, and a retry landing after deletion would put the
   * rider's phone number back on a row we told them was wiped.
   *
   * @param id - the user to backfill.
   * @param contact - the contact details to fill in where missing.
   * @param contact.email - verified email, or undefined to leave alone.
   * @param contact.phone - E.164 phone, or undefined to leave alone.
   * @returns the updated user, or null if not found or erased.
   */
  backfillContact(
    id: string,
    contact: { email?: string | null; phone?: string | null },
  ): Promise<User | null>;
  /**
   * Erase a user's personal data while keeping the row (#30).
   *
   * Not a DELETE: payments and both ledgers cascade off users, so removing the
   * row would destroy the financial record. Idempotent.
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

  /**
   * The row only if it is a live account, mirroring the `deleted_at IS NULL`
   * predicate the Postgres adapter applies (ADR-0009: the fakes must refuse
   * what the real one refuses, or the tests certify behaviour we do not have).
   *
   * @param id - the user id.
   * @returns the live user, or undefined when absent or erased.
   */
  private live(id: string): User | undefined {
    const user = this.users.get(id);
    return user && user.deletedAt === null ? user : undefined;
  }

  async findById(id: string): Promise<User | null> {
    return this.live(id) ?? null;
  }

  async findByIdIncludingErased(id: string): Promise<User | null> {
    return this.users.get(id) ?? null;
  }

  async updateProfile(id: string, patch: { displayName: string }): Promise<User | null> {
    const user = this.live(id);
    if (!user) return null;
    const updated = { ...user, displayName: patch.displayName };
    this.users.set(id, updated);
    return updated;
  }

  async setAvatarKey(id: string, key: string | null): Promise<User | null> {
    const user = this.live(id);
    if (!user) return null;
    const updated = { ...user, avatarUrl: key };
    this.users.set(id, updated);
    return updated;
  }

  async setRole(id: string, role: UserRole): Promise<User | null> {
    const user = this.live(id);
    if (!user) return null;
    const updated = { ...user, role };
    this.users.set(id, updated);
    return updated;
  }

  async backfillContact(
    id: string,
    contact: { email?: string | null; phone?: string | null },
  ): Promise<User | null> {
    const user = this.live(id);
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
