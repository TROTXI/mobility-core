import { describe, expect, it } from 'vitest';
import type { components } from '../generated/api';
import { homeTrips, homeTripStatus, needsOperatorAttention } from './overview-view';

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
});
