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

export function fixDescription(trip: Trip): string | null {
  if (trip.status !== 'active') return null;
  if (trip.fixAgeSeconds === null || !trip.lastPosition) return 'No GPS fix';
  const age =
    trip.fixAgeSeconds < 60
      ? `${trip.fixAgeSeconds} sec`
      : `${Math.floor(trip.fixAgeSeconds / 60)} min`;
  return trip.badge === 'stale_gps' ? `GPS stale · ${age} old` : `GPS · ${age} old`;
}

/** A failed poll must not leave the last successful fix looking fresh forever. */
export function withObservedAge(
  trip: Trip,
  elapsedSeconds: number,
  staleAfterSeconds: number,
): Trip {
  if (trip.status !== 'active') return trip;
  const age =
    trip.fixAgeSeconds === null
      ? null
      : trip.fixAgeSeconds + Math.max(0, Math.floor(elapsedSeconds));
  return {
    ...trip,
    fixAgeSeconds: age,
    badge: age === null || age > staleAfterSeconds ? 'stale_gps' : trip.badge,
  };
}
