// Vehicle repository — a vehicle is a bus in the fleet, identified by its
// registration (plate). It carries only fleet metadata; a vehicle is placed on a
// specific run by a trip's vehicle_id. Two implementations: InMemory for unit
// tests and zero-infra dev, Postgres (vehicle.repository.pg.ts) for real runs.

/** A bus in the fleet, identified by its registration (plate). */
export interface Vehicle {
  id: string;
  registration: string;
  label: string | null;
  capacity: number;
  createdAt: Date;
}

/** Fields needed to create a {@link Vehicle}. */
export interface NewVehicle {
  registration: string;
  label?: string | null;
  capacity?: number;
}

/** Persistence for vehicles (Postgres in prod, in-memory in dev/tests). */
export interface VehicleRepository {
  /**
   * Create a vehicle.
   *
   * @param input - the vehicle's registration and optional metadata.
   * @returns the created vehicle.
   */
  create(input: NewVehicle): Promise<Vehicle>;
  /**
   * Look up a vehicle by id.
   *
   * @param id - the vehicle id.
   * @returns the vehicle, or null if it doesn't exist.
   */
  findById(id: string): Promise<Vehicle | null>;
}

/** In-memory {@link VehicleRepository} for dev and unit tests. */
export class InMemoryVehicleRepository implements VehicleRepository {
  private readonly vehicles = new Map<string, Vehicle>();

  async create(input: NewVehicle): Promise<Vehicle> {
    const vehicle: Vehicle = {
      id: crypto.randomUUID(),
      registration: input.registration,
      label: input.label ?? null,
      capacity: input.capacity ?? 0,
      createdAt: new Date(),
    };
    this.vehicles.set(vehicle.id, vehicle);
    return vehicle;
  }

  async findById(id: string): Promise<Vehicle | null> {
    return this.vehicles.get(id) ?? null;
  }
}
