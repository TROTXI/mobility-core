// datetime-local has no timezone. Ops enters Ghana wall time (GMT, year-round).
export function accraLocalToIso(value: string): string {
  if (!/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/.test(value)) throw new Error('Invalid Accra time');
  const iso = new Date(`${value}:00Z`).toISOString();
  if (iso.slice(0, 16) !== value) throw new Error('Invalid Accra time');
  return iso;
}
