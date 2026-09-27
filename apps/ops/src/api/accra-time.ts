// datetime-local has no timezone. Ops enters Ghana wall time (GMT, year-round).
export function accraLocalToIso(value: string): string {
  if (!/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/.test(value)) throw new Error('Invalid Accra time');
  const iso = new Date(`${value}:00Z`).toISOString();
  if (iso.slice(0, 16) !== value) throw new Error('Invalid Accra time');
  return iso;
}

export function formatAccraTime(value: string): string {
  return `${new Intl.DateTimeFormat('en-GH', {
    dateStyle: 'medium',
    timeStyle: 'short',
    timeZone: 'Africa/Accra',
  }).format(new Date(value))} GMT`;
}

export function formatAccraClock(value: string): string {
  return `${new Intl.DateTimeFormat('en-GH', {
    hour: '2-digit',
    minute: '2-digit',
    timeZone: 'Africa/Accra',
  }).format(new Date(value))} GMT`;
}
