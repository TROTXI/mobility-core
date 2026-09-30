import { describe, expect, it } from 'vitest';
import type { components } from '../generated/api';
import {
  fixDescription,
  homeTrips,
  homeTripStatus,
  needsOperatorAttention,
  withObservedAge,
} from './overview-view';

type Trip = components['schemas']['OpsOverview']['trips'][number];

function trip(
  tripId: string,
  status: Trip['status'],
  badge: Trip['badge'] = 'on_time',
  reserved = 0,
): Trip {
  return {
    tripId,
    scheduledAt: '2026-09-25T06:30:00Z',
    status,
    patternId: 'pattern',
    patternVersionId: 'version',
    routeName: 'Circle - Madina',
    driverId: null,
    driverName: null,
    vehicleId: null,
    vehicleLabel: null,
    vehiclePlate: null,
    capacity: null,
    confirmed: 0,
    boarded: 0,
    noShow: 0,
    reserved,
    lastFixAt: null,
    fixAgeSeconds: null,
    lastPosition: null,
    badge,
  };
}

describe('home monitoring priorities', () => {
  it('shows running trips and exceptions, not healthy future departures', () => {
    const rows = [
      trip('scheduled', 'scheduled'),
      trip('running', 'active'),
      trip('unassigned', 'scheduled', 'unassigned'),
      trip('unsettled', 'completed', 'on_time', 2),
      trip('done', 'completed'),
    ];
    expect(homeTrips(rows).map((row) => row.tripId)).toEqual([
      'unassigned',
      'unsettled',
      'running',
    ]);
    expect(homeTripStatus(rows[0])).toBe('scheduled');
    expect(homeTripStatus(rows[1])).toBe('on_time');
    expect(homeTripStatus(rows[3])).toBe('awaiting resolution');
    expect(needsOperatorAttention(rows[1])).toBe(false);
    expect(needsOperatorAttention(rows[2])).toBe(true);
  });

  it('distinguishes no fix, stale fixes and fresh fixes', () => {
    const missing = trip('missing', 'active', 'stale_gps');
    expect(fixDescription(missing)).toBe('No GPS fix');
    expect(
      fixDescription({
        ...missing,
        lastPosition: { latitude: 5.6, longitude: -0.2 },
        fixAgeSeconds: 480,
      }),
    ).toBe('GPS stale · 8 min old');
    expect(
      fixDescription({
        ...missing,
        badge: 'on_time',
        lastPosition: { latitude: 5.6, longitude: -0.2 },
        fixAgeSeconds: 12,
      }),
    ).toBe('GPS · 12 sec old');
  });

  it('ages the last fix through failed polls and crosses the stale threshold', () => {
    const fresh: Trip = {
      ...trip('running', 'active'),
      lastPosition: { latitude: 5.6, longitude: -0.2 },
      fixAgeSeconds: 290,
    };
    const aged = withObservedAge(fresh, 11, 300);
    expect(aged.fixAgeSeconds).toBe(301);
    expect(aged.badge).toBe('stale_gps');
    expect(fixDescription(aged)).toBe('GPS stale · 5 min old');
    expect(withObservedAge(trip('scheduled', 'scheduled'), 999, 300).status).toBe('scheduled');
  });
});
