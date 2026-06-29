// Reference repository pattern: an interface with two implementations -
// InMemory (tests + zero-infra dev) and Postgres (real runs, see *.pg.ts).
// The server picks one by DATABASE_URL. Copy this shape for new domain modules.

export const USER_ROLES = ['commuter', 'driver', 'admin'] as const;
export type UserRole = (typeof USER_ROLES)[number];

/** A platform user (commuter, driver, or admin). */
export interface User {
  id: string;
  displayName: string;
  phone: string | null;
  avatarUrl: string | null;
  role: UserRole;
  createdAt: Date;
}

/** Fields needed to create a user; the rest default or are server-set. */
export interface NewUser {
  displayName: string;
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
}

/** In-memory {@link UserRepository} for dev and unit tests. */
export class InMemoryUserRepository implements UserRepository {
  private readonly users = new Map<string, User>();

  async create(input: NewUser): Promise<User> {
    const user: User = {
      id: crypto.randomUUID(),
      displayName: input.displayName,
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
}
