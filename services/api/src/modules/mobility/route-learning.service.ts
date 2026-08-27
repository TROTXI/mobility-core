// Learning a corridor from the runs already driven (#179, #181). Turns the
// 5-second trace every completed trip leaves in trip_positions into the two
// things the ETA needs: the road the bus actually follows, and how fast it
// actually moves along each stretch. Both improve as runs accumulate.

import { directionOf, type ServiceWindow } from './direction';
import type { RouteStopPoint } from './eta';
import type { RouteStopRepository } from './route-stop.repository';
import { deriveRouteGeometry, stopDistancesAlong, type Trace } from './route-geometry';
import type { RouteGeometryRepository } from './route-geometry.repository';
import { aggregateSegmentSpeeds, type TimedTrace } from './segment-speed.aggregate';
import type { SegmentSpeedRepository } from './segment-speed.repository';
import type { StopRepository } from './stop.repository';
import type { TripPositionRepository } from './trip-position.repository';
import type { TripRepository } from './trip.repository';

/**
 * Completed runs to read back, **per direction** — overall would let one window
 * starve the other below the sample threshold, keeping its cold-start speed.
 */
const RUNS_TO_CONSIDER = 5;

/** Collaborators for {@link RouteLearningService}. */
export interface RouteLearningDeps {
  trips: TripRepository;
  tripPositions: TripPositionRepository;
  routeStops: RouteStopRepository;
  stops: StopRepository;
  geometry: RouteGeometryRepository;
  segmentSpeeds: SegmentSpeedRepository;
}

/** What a learning pass produced, for the admin response and the cron log. */
export interface RouteLearningResult {
  routeId: string;
  /** Completed runs found and used. */
  runsUsed: number;
  /** True when a path was derived and persisted. */
  geometryUpdated: boolean;
  /** Segments that cleared the sample threshold, by direction. */
  segmentsLearned: Record<ServiceWindow, number>;
}

/** Derives route geometry and segment speeds from completed trips. */
export class RouteLearningService {
  /** @param deps - the trip, position, stop and output repositories. */
  constructor(private readonly deps: RouteLearningDeps) {}

  /**
   * Learn one route from its completed runs.
   *
   * Safe to re-run: geometry is overwritten rather than appended (a route has
   * one current shape) and speeds are replaced per direction, so repeating a
   * pass converges rather than compounding.
   *
   * @param routeId - the route to learn.
   * @returns what the pass found and wrote.
   */
  async learnRoute(routeId: string): Promise<RouteLearningResult> {
    const result: RouteLearningResult = {
      routeId,
      runsUsed: 0,
      geometryUpdated: false,
      segmentsLearned: { morning: 0, evening: 0 },
    };

    const stopPoints = await this.resolveStops(routeId);
    if (stopPoints.length < 2) return result;

    const all = await this.deps.trips.findAll({ routeId, status: 'completed' });
    if (all.length === 0) return result;

    // Newest first, then take the most recent N of EACH direction: a corridor's
    // recent shape beats its historical one when a road closes or a stop moves,
    // and neither window may crowd the other out.
    const byDirection = new Map<ServiceWindow, typeof all>();
    for (const window of ['morning', 'evening'] as const) {
      byDirection.set(
        window,
        all
          .filter((t) => directionOf(t.scheduledAt) === window)
          .sort((a, b) => b.scheduledAt.getTime() - a.scheduledAt.getTime())
          .slice(0, RUNS_TO_CONSIDER),
      );
    }

    const traces = new Map<ServiceWindow, TimedTrace[]>();
    for (const [window, trips] of byDirection) {
      const timed: TimedTrace[] = [];
      for (const trip of trips) {
        const fixes = await this.deps.tripPositions.findAllForTrip(trip.id);
        if (fixes.length < 2) continue;
        timed.push({
          tripId: trip.id,
          fixes: fixes.map((f) => ({
            latitude: f.latitude,
            longitude: f.longitude,
            recordedAt: f.recordedAt,
          })),
        });
      }
      traces.set(window, timed);
      result.runsUsed += timed.length;
    }
    if (result.runsUsed === 0) return result;

    await this.learnGeometry(routeId, traces, stopPoints, result);
    await this.learnSpeeds(routeId, traces, stopPoints, result);
    return result;
  }

  /**
   * Learn every route that has completed runs. Used by the scheduled pass.
   *
   * @returns one result per route touched.
   */
  async learnAll(): Promise<RouteLearningResult[]> {
    const trips = await this.deps.trips.findAll({ status: 'completed' });
    const routeIds = [...new Set(trips.map((t) => t.routeId))];
    const results: RouteLearningResult[] = [];
    for (const routeId of routeIds) {
      results.push(await this.learnRoute(routeId));
    }
    return results;
  }

  /**
   * Resolve a route's stops in seq order with their coordinates.
   *
   * @param routeId - the route.
   * @returns the ordered stop points; unresolvable stops are dropped.
   */
  private async resolveStops(routeId: string): Promise<RouteStopPoint[]> {
    const routeStops = await this.deps.routeStops.findByRoute(routeId);
    const resolved = await Promise.all(
      routeStops.map(async (rs): Promise<RouteStopPoint | null> => {
        const stop = await this.deps.stops.findById(rs.stopId);
        return stop
          ? {
              stopId: stop.id,
              name: stop.name,
              seq: rs.seq,
              latitude: stop.latitude,
              longitude: stop.longitude,
            }
          : null;
      }),
    );
    return resolved.filter((s): s is RouteStopPoint => s !== null);
  }

  /**
   * Derive and persist the route's path plus each stop's distance along it.
   *
   * @param routeId - the route.
   * @param byDirection - completed runs grouped by service window.
   * @param stopPoints - the route's stops in seq order.
   * @param result - mutated with what was written.
   */
  private async learnGeometry(
    routeId: string,
    byDirection: Map<ServiceWindow, TimedTrace[]>,
    stopPoints: RouteStopPoint[],
    result: RouteLearningResult,
  ): Promise<void> {
    // Derive from ONE direction's runs, the one with the most data. Where a
    // corridor's two windows travel opposite ways along the same road, mixing
    // them would median a forward traversal against a reverse one and produce a
    // path that matches neither.
    const richest = [...byDirection.values()].sort((a, b) => b.length - a.length)[0] ?? [];
    if (richest.length === 0) return;

    const traces: Trace[] = richest.map((t) => ({
      tripId: t.tripId,
      points: t.fixes.map((f) => ({ latitude: f.latitude, longitude: f.longitude })),
    }));

    const derived = deriveRouteGeometry(traces);
    if (!derived) return;

    const distances = stopDistancesAlong(derived.points, stopPoints);
    await this.deps.geometry.save({
      routeId,
      points: derived.points,
      source: derived.source,
      runCount: derived.runCount,
      stopDistances: new Map(stopPoints.map((s, i) => [s.seq, distances[i]!])),
    });
    result.geometryUpdated = true;
  }

  /**
   * Aggregate and persist observed segment speeds, per direction.
   *
   * Morning and evening are learned separately and never pooled: the whole
   * point is that the same stretch of road is a different road at 07:30 than at
   * 18:00, and averaging the two would erase exactly the signal we want.
   *
   * @param routeId - the route.
   * @param byDirection - completed runs grouped by service window.
   * @param stopPoints - the route's stops in seq order.
   * @param result - mutated with what was written.
   */
  private async learnSpeeds(
    routeId: string,
    byDirection: Map<ServiceWindow, TimedTrace[]>,
    stopPoints: RouteStopPoint[],
    result: RouteLearningResult,
  ): Promise<void> {
    for (const direction of ['morning', 'evening'] as const) {
      const forDirection = byDirection.get(direction) ?? [];
      if (forDirection.length === 0) continue;

      const segments = aggregateSegmentSpeeds(forDirection, stopPoints);
      await this.deps.segmentSpeeds.replace(routeId, direction, segments);
      result.segmentsLearned[direction] = segments.length;
    }
  }
}
