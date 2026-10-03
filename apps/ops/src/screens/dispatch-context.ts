export function dispatchDate(value: string | null): string | null {
  if (!value || !/^\d{4}-\d{2}-\d{2}$/.test(value)) return null;
  const parsed = new Date(`${value}T00:00:00Z`);
  return Number.isFinite(parsed.getTime()) && parsed.toISOString().slice(0, 10) === value
    ? value
    : null;
}

export function dispatchLink(date: string | undefined, tripId?: string) {
  const params = new URLSearchParams();
  if (dispatchDate(date ?? null)) params.set('date', date!);
  // Service window and route direction are independent. Overview exposes
  // no direction, so keep both directions visible on the destination board.
  if (tripId) params.set('search', tripId);
  return `/trips?${params}`;
}
