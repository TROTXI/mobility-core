// Driver repository — a driver operates a vehicle on a trip. Modelled as its own
// entity (not just a user) because drivers are onboarded/managed by ops before
// any app sign-in exists; the optional userId links a driver to an auth
// principal once driver sign-in lands, which is how GPS reporting is later
// authorized (only the assigned driver — system-design §7, #25). Two
// implementations: InMemory for dev/tests, Postgres (driver.repository.pg.ts).

/** A driver who operates a vehicle on a trip. */
export interface Driver {
  id: string;
  fullName: string;
  phone: string | null;
  licenseNumber: string | null;
  /** Links to an auth principal once driver sign-in lands (GPS authz, #25). */
  userId: string | null;
  createdAt: Date;
}

/** Fields needed to create a {@link Driver}. */
export interface NewDriver {
  fullName: string;
  phone?: string | null;
  licenseNumber?: string | null;
  userId?: string | null;
}

/** Persistence for drivers (Postgres in prod, in-memory in dev/tests). */
export interface DriverRepository {
  /**
   * Create a driver.
   *
   * @param input - the driver's name and optional contact/license details.
   * @returns the created driver.
   */
  create(input: NewDriver): Promise<Driver>;
  /**
   * Look up a driver by id.
   *
   * @param id - the driver id.
   * @returns the driver, or null if it doesn't exist.
   */
  findById(id: string): Promise<Driver | null>;
}

/** In-memory {@link DriverRepository} for dev and unit tests. */
export class InMemoryDriverRepository implements DriverRepository {
  private readonly drivers = new Map<string, Driver>();

  async create(input: NewDriver): Promise<Driver> {
    const driver: Driver = {
      id: crypto.randomUUID(),
      fullName: input.fullName,
      phone: input.phone ?? null,
      licenseNumber: input.licenseNumber ?? null,
      userId: input.userId ?? null,
      createdAt: new Date(),
    };
    this.drivers.set(driver.id, driver);
    return driver;
  }

  async findById(id: string): Promise<Driver | null> {
    return this.drivers.get(id) ?? null;
  }
}
