// Scan events — the boarding audit trail (#20). Every pass verification (or photo
// fallback) is one append-only row. Repository pattern (ADR-0009): interface +
// InMemory here, Postgres in *.pg.ts.

/** Outcome of a scan. */
export type ScanResult = 'valid' | 'invalid' | 'expired';
/** How the rider was verified. */
export type ScanMethod = 'qr' | 'photo';

/** A recorded boarding scan. */
export interface ScanEvent {
  id: string;
  /** The pass owner; null when the pass was invalid/forged (unattributable). */
  riderId: string | null;
  /** The driver who scanned. */
  scannedBy: string | null;
  /** The trip, if known (no FK yet — trips are #18). */
  tripId: string | null;
  result: ScanResult;
  method: ScanMethod;
  createdAt: Date;
}

/** Fields to record a scan; the rest (id, timestamp) are set by the repo. */
export interface NewScanEvent {
  riderId: string | null;
  scannedBy: string | null;
  tripId: string | null;
  result: ScanResult;
  method: ScanMethod;
}

/** Persistence for boarding scan events (append-only). */
export interface ScanEventRepository {
  /**
   * Record a scan event.
   *
   * @param input - the scan to record.
   * @returns the persisted event.
   */
  record(input: NewScanEvent): Promise<ScanEvent>;
  /**
   * List a rider's recent scans, newest first (audit / "my rides").
   *
   * @param riderId - the rider whose scans to list.
   * @returns the rider's scan events.
   */
  listForRider(riderId: string): Promise<ScanEvent[]>;
}

/** In-memory {@link ScanEventRepository} for dev and unit tests. */
export class InMemoryScanEventRepository implements ScanEventRepository {
  private readonly events: ScanEvent[] = [];

  async record(input: NewScanEvent): Promise<ScanEvent> {
    const event: ScanEvent = {
      id: crypto.randomUUID(),
      riderId: input.riderId,
      scannedBy: input.scannedBy,
      tripId: input.tripId,
      result: input.result,
      method: input.method,
      createdAt: new Date(),
    };
    this.events.push(event);
    return event;
  }

  async listForRider(riderId: string): Promise<ScanEvent[]> {
    return this.events
      .filter((e) => e.riderId === riderId)
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  }
}
