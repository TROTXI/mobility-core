// Driver repository — a driver operates a vehicle on a trip. Modelled as its own
// entity (not just a user) because drivers are onboarded/managed by ops before
// any app sign-in exists; the optional userId links a driver to an auth
// principal once driver sign-in lands, which is how GPS reporting is later
// authorized (only the assigned driver — system-design §7, #25). Two
// implementations: InMemory for dev/tests, Postgres (driver.repository.pg.ts).

import { applyPatch } from '../../lib/patch';

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

/** Editable {@link Driver} fields for a partial update (admin, #26). */
export interface DriverUpdate {
  fullName?: string;
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
  /**
   * Look up a driver by the auth principal linked via userId. This resolves a
   * signed-in user to their driver record — the basis for GPS-reporting authz
   * (only the assigned driver may report a trip's position, #25).
   *
   * @param userId - the auth user id.
   * @returns the linked driver, or null if none is linked to that user.
   */
  findByUserId(userId: string): Promise<Driver | null>;
  /** Returns all drivers. Used by admin ops (#26). */
  findAll(): Promise<Driver[]>;
  /**
   * Update a driver's editable fields (partial — omitted fields are unchanged).
   *
   * @param id - the driver id.
   * @param patch - the fields to change.
   * @returns the updated driver, or null if not found.
   */
  update(id: string, patch: DriverUpdate): Promise<Driver | null>;
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

  async findByUserId(userId: string): Promise<Driver | null> {
    for (const driver of this.drivers.values()) {
      if (driver.userId === userId) return driver;
    }
    return null;
  }

  async findAll(): Promise<Driver[]> {
    return Array.from(this.drivers.values());
  }

  async update(id: string, patch: DriverUpdate): Promise<Driver | null> {
    const existing = this.drivers.get(id);
    if (!existing) return null;
    const updated = applyPatch(existing, patch);
    this.drivers.set(id, updated);
    return updated;
  }
}
