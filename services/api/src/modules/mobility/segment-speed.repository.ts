// Observed median speed per route segment, direction and service window (#181).
//
// This is what replaces the flat ASSUMED_SPEED_KPH in eta.ts. Aggregated from
// completed runs rather than bought from a traffic vendor: a traffic API models
// a generic vehicle on a generic road, this measures our vehicles on our
// corridors at the exact times we run them.
//
// Repository pattern (ADR-0009): interface + InMemory here, Postgres in *.pg.ts.

import type { SegmentSpeed } from './eta';

/** Which service window an observation belongs to. Mirrors the DB CHECK. */
export type ServiceDirection = 'morning' | 'evening';

/** A persisted observation for one segment of one route. */
export interface SegmentSpeedRow {
  routeId: string;
  /** Segment between route_stops.seq = fromSeq and fromSeq + 1. */
  fromSeq: number;
  direction: ServiceDirection;
  medianSpeedMs: number;
  sampleCount: number;
  computedAt: Date;
}

/** Persistence for `segment_speeds`. */
export interface SegmentSpeedRepository {
  /**
   * Speeds for one route and direction, keyed by segment index for
   * {@link computeEtas}.
   *
   * Returns a Map rather than an array because the ETA path does a lookup per
   * segment on every position read — the hottest query we have during a run.
   *
   * @param routeId - the route.
   * @param direction - the service window.
   * @returns segment index -> observed speed. Empty when nothing is known yet,
   *   in which case every segment falls back to the cold-start speed.
   */
  findByRoute(routeId: string, direction: ServiceDirection): Promise<Map<number, SegmentSpeed>>;
  /**
   * Replace the observations for a route and direction.
   *
   * A full replace, not a merge: the aggregation recomputes every segment from
   * the same window of runs, so a partial update could leave one segment's
   * median from a different sample than its neighbour's.
   *
   * @param routeId - the route.
   * @param direction - the service window.
   * @param rows - the recomputed observations.
   */
  replace(
    routeId: string,
    direction: ServiceDirection,
    rows: readonly Omit<SegmentSpeedRow, 'routeId' | 'direction' | 'computedAt'>[],
  ): Promise<void>;
}

/** In-memory {@link SegmentSpeedRepository} for dev and unit tests. */
export class InMemorySegmentSpeedRepository implements SegmentSpeedRepository {
  private readonly rows = new Map<string, SegmentSpeedRow[]>();

  private key(routeId: string, direction: ServiceDirection): string {
    return `${routeId}:${direction}`;
  }

  async findByRoute(
    routeId: string,
    direction: ServiceDirection,
  ): Promise<Map<number, SegmentSpeed>> {
    const found = this.rows.get(this.key(routeId, direction)) ?? [];
    return new Map(
      found.map((r) => [
        r.fromSeq,
        { fromSeq: r.fromSeq, metresPerSecond: r.medianSpeedMs, sampleCount: r.sampleCount },
      ]),
    );
  }

  async replace(
    routeId: string,
    direction: ServiceDirection,
    rows: readonly Omit<SegmentSpeedRow, 'routeId' | 'direction' | 'computedAt'>[],
  ): Promise<void> {
    this.rows.set(
      this.key(routeId, direction),
      rows.map((r) => ({ ...r, routeId, direction, computedAt: new Date() })),
    );
  }
}
