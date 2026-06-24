// Reference repository pattern: an interface with two implementations -
// InMemory (tests + zero-infra dev) and Postgres (real runs, see *.pg.ts).
// The server picks one by DATABASE_URL. Copy this shape for new domain modules.

export type UserRole = 'commuter' | 'driver' | 'admin';

export interface User {
  id: string;
  displayName: string;
  phone: string | null;
  avatarUrl: string | null;
  role: UserRole;
  createdAt: Date;
}

export interface NewUser {
  displayName: string;
  phone?: string | null;
  role?: UserRole;
}

export interface UserRepository {
  create(input: NewUser): Promise<User>;
  findById(id: string): Promise<User | null>;
}

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
