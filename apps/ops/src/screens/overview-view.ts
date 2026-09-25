import type { components } from '../generated/api';

type Trip = components['schemas']['OpsOverview']['trips'][number];

export function needsOperatorAttention(trip: Trip): boolean {
  return (
    trip.badge === 'stale_gps' ||
    trip.badge === 'unassigned' ||
    (trip.status === 'completed' && trip.reserved > 0)
  );
}

/** Healthy scheduled runs belong on Dispatch, not a board titled "in motion". */
export function homeTrips(trips: Trip[]): Trip[] {
  return trips
    .filter((trip) => trip.status === 'active' || needsOperatorAttention(trip))
    .sort((a, b) => Number(needsOperatorAttention(b)) - Number(needsOperatorAttention(a)));
}

export function homeTripStatus(trip: Trip): string {
  if (trip.status === 'scheduled') return trip.badge === 'unassigned' ? 'unassigned' : 'scheduled';
  if (trip.status === 'completed') return trip.reserved > 0 ? 'awaiting resolution' : 'completed';
  if (trip.status === 'cancelled') return 'cancelled';
  return trip.badge;
}
