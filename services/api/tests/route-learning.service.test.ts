import { describe, expect, it } from 'vitest';
import { RouteLearningService } from '../src/modules/mobility/route-learning.service';
import { InMemoryRouteGeometryRepository } from '../src/modules/mobility/route-geometry.repository';
import { InMemorySegmentSpeedRepository } from '../src/modules/mobility/segment-speed.repository';
import { InMemoryTripPositionRepository } from '../src/modules/mobility/trip-position.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryRouteStopRepository } from '../src/modules/mobility/route-stop.repository';
import { InMemoryStopRepository } from '../src/modules/mobility/stop.repository';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';

/** Build a corridor of `count` stops on a straight line, ~1 km apart. */
async function corridor(stopsRepo: InMemoryStopRepository, count: number) {
  const made = [];
  for (let i = 0; i < count; i++) {
    made.push(
      await stopsRepo.create({ name: `Stop ${i}`, latitude: 5.6, longitude: -0.19 + i * 0.009 }),
    );
  }
  return made;
}

async function setup(stopCount = 4) {
  const routes = new InMemoryRouteRepository();
  const stops = new InMemoryStopRepository();
  const routeStops = new InMemoryRouteStopRepository();
  const trips = new InMemoryTripRepository();
  const tripPositions = new InMemoryTripPositionRepository();
  const geometry = new InMemoryRouteGeometryRepository();
  const segmentSpeeds = new InMemorySegmentSpeedRepository();

  const route = await routes.create({ name: 'Madina ⇄ Circle' });
  const made = await corridor(stops, stopCount);
  for (const [i, s] of made.entries()) {
    await routeStops.create({ routeId: route.id, stopId: s.id, seq: i });
  }

  const service = new RouteLearningService({
    trips,
    tripPositions,
    routeStops,
    stops,
    geometry,
    segmentSpeeds,
  });
  return { service, route, made, trips, tripPositions, geometry, segmentSpeeds };
}

/**
 * Record a completed run as a REAL trace: a fix every 5 seconds, interpolated
 * between consecutive stops. That density matters — the derivation discards
 * jumps over 350 m as GPS glitches, so one fix per stop (a kilometre apart)
 * would correctly be thrown away as noise rather than treated as a route.
 */
async function completedRun(
  ctx: Awaited<ReturnType<typeof setup>>,
  hourUtc: number,
  secondsPerLeg: number,
) {
  const scheduledAt = new Date(Date.UTC(2026, 7, 24, hourUtc, 0, 0));
  const trip = await ctx.trips.create({
    routeId: ctx.route.id,
    scheduledAt,
    status: 'completed',
  });

  const FIX_INTERVAL_S = 5;
  let elapsed = 0;
  for (let leg = 0; leg < ctx.made.length - 1; leg++) {
    const from = ctx.made[leg]!;
    const to = ctx.made[leg + 1]!;
    const steps = Math.max(1, Math.round(secondsPerLeg / FIX_INTERVAL_S));

    for (let step = 0; step < steps; step++) {
      const t = step / steps;
      const rec = await ctx.tripPositions.record({
        tripId: trip.id,
        latitude: from.latitude + (to.latitude - from.latitude) * t,
        longitude: from.longitude + (to.longitude - from.longitude) * t,
      });
      // record() stamps recordedAt itself; override so the trace has real timing.
      (rec as { recordedAt: Date }).recordedAt = new Date(scheduledAt.getTime() + elapsed * 1000);
      elapsed += FIX_INTERVAL_S;
    }
  }

  // Final fix at the terminus.
  const last = ctx.made[ctx.made.length - 1]!;
  const rec = await ctx.tripPositions.record({
    tripId: trip.id,
    latitude: last.latitude,
    longitude: last.longitude,
  });
  (rec as { recordedAt: Date }).recordedAt = new Date(scheduledAt.getTime() + elapsed * 1000);

  return trip;
}

describe('RouteLearningService', () => {
  it('derives geometry from a single completed run', async () => {
    const ctx = await setup();
    await completedRun(ctx, 7, 200);

    const result = await ctx.service.learnRoute(ctx.route.id);

    expect(result.runsUsed).toBe(1);
    expect(result.geometryUpdated).toBe(true);
    const saved = await ctx.geometry.findByRoute(ctx.route.id);
    expect(saved?.source).toBe('traces');
    expect(saved!.points.length).toBeGreaterThan(1);
  });

  it('records how far along the path each stop sits', async () => {
    const ctx = await setup();
    await completedRun(ctx, 7, 200);
    await ctx.service.learnRoute(ctx.route.id);

    const distances = ctx.geometry.stopDistances.get(ctx.route.id)!;
    expect(distances.size).toBe(4);
    expect(distances.get(0)).toBe(0);
    // Stops in order must be increasingly far along the route.
    expect(distances.get(3)!).toBeGreaterThan(distances.get(1)!);
  });

  it('learns morning and evening separately, never pooled', async () => {
    const ctx = await setup();
    // Morning is slow (rush hour), evening is fast. Averaging them would erase
    // exactly the signal this exists to capture.
    for (let i = 0; i < 3; i++) await completedRun(ctx, 7, 400);
    for (let i = 0; i < 3; i++) await completedRun(ctx, 18, 100);

    await ctx.service.learnRoute(ctx.route.id);

    const morning = await ctx.segmentSpeeds.findByRoute(ctx.route.id, 'morning');
    const evening = await ctx.segmentSpeeds.findByRoute(ctx.route.id, 'evening');

    expect(morning.size).toBeGreaterThan(0);
    expect(evening.size).toBeGreaterThan(0);
    expect(evening.get(0)!.metresPerSecond).toBeGreaterThan(morning.get(0)!.metresPerSecond * 3);
  });

  it('does nothing for a route with no completed runs', async () => {
    const ctx = await setup();
    const result = await ctx.service.learnRoute(ctx.route.id);

    expect(result.runsUsed).toBe(0);
    expect(result.geometryUpdated).toBe(false);
    expect(await ctx.geometry.findByRoute(ctx.route.id)).toBeNull();
  });

  it('ignores trips that are scheduled but not completed', async () => {
    const ctx = await setup();
    await ctx.trips.create({
      routeId: ctx.route.id,
      scheduledAt: new Date(Date.UTC(2026, 7, 24, 7)),
      status: 'scheduled',
    });
    expect((await ctx.service.learnRoute(ctx.route.id)).runsUsed).toBe(0);
  });

  it('converges rather than compounds when re-run', async () => {
    const ctx = await setup();
    for (let i = 0; i < 3; i++) await completedRun(ctx, 7, 200);

    const first = await ctx.service.learnRoute(ctx.route.id);
    const second = await ctx.service.learnRoute(ctx.route.id);

    expect(second.runsUsed).toBe(first.runsUsed);
    expect(second.segmentsLearned.morning).toBe(first.segmentsLearned.morning);
    const speeds = await ctx.segmentSpeeds.findByRoute(ctx.route.id, 'morning');
    // Replaced, not appended: sample counts must not double.
    expect(speeds.get(0)!.sampleCount).toBe(3);
  });

  it('learnAll covers every route that has completed runs', async () => {
    const ctx = await setup();
    await completedRun(ctx, 7, 200);
    const results = await ctx.service.learnAll();
    expect(results).toHaveLength(1);
    expect(results[0]!.routeId).toBe(ctx.route.id);
  });
});
