// People read these messages, not parsers. Ghana keeps GMT all year, so one
// fixed zone is exact; the suffix says which clock the time is on.
const ghana = new Intl.DateTimeFormat('en-GB', {
  timeZone: 'Africa/Accra',
  weekday: 'short',
  day: 'numeric',
  month: 'short',
  year: 'numeric',
  hour: '2-digit',
  minute: '2-digit',
  hourCycle: 'h23',
});

/** For example `Sat 31 Oct 2026, 00:00 GMT`. */
export function ghanaTime(at: Date): string {
  const part = Object.fromEntries(ghana.formatToParts(at).map((p) => [p.type, p.value]));
  return `${part.weekday} ${part.day} ${part.month} ${part.year}, ${part.hour}:${part.minute} GMT`;
}
