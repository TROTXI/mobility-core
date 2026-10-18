import type { JobRequest } from './maintenance.js';

export interface ScheduledGroup {
  name: string;
  /** UTC slot persisted in the existing maintenance audit, not process memory. */
  key: string;
  jobs: JobRequest[];
}
const minute = 60_000;
const dayMs = 86_400_000;
const date = (time: number) => new Date(time).toISOString().slice(0, 10);
const both = (job: JobRequest['job'], travelDate: string): JobRequest[] =>
  (['outbound', 'return'] as const).map((direction) => ({ job, travelDate, direction }));

/** Accra uses UTC. Preserve the existing 21:00 ask / midnight default policy. */
export function scheduledGroups(now: Date): ScheduledGroup[] {
  const time = now.getTime();
  const today = date(time);
  const midnight = Date.parse(today);
  const tomorrow = date(time + dayMs);
  const periodic = (name: string, minutes: number, jobs: JobRequest[]): ScheduledGroup => ({
    name,
    key: `scheduler:${name}:${Math.floor(time / (minutes * minute))}`,
    jobs,
  });
  const daily = (name: string, day: string, jobs: JobRequest[]): ScheduledGroup => ({
    name,
    key: `scheduler:${name}:${day}`,
    jobs,
  });
  return [
    periodic('push', 1, [{ job: 'push' }]),
    periodic('messages', 1, [{ job: 'emails' }]),
    periodic('payments', 15, [{ job: 'payments' }, { job: 'auto-renewals' }]),
    periodic('privacy', 5, [
      { job: 'gps-retention' },
      { job: 'admission' },
      { job: 'driver-secrets' },
      { job: 'erasures' },
    ]),
    // Hourly retries cover newly published schedules and short outages. Include
    // today as well as the next seven days; generation is idempotent.
    periodic('timetable', 60, [
      ...Array.from({ length: 8 }, (_, i) => ({
        job: 'trip-generation' as const,
        travelDate: date(time + i * dayMs),
      })),
      { job: 'personal-pause-resumes' },
    ]),
    // Recheck the complete day even when the 23:30 run succeeded: a departure
    // after that cutoff was not eligible in the earlier run. Use a separate
    // slot so its success cannot suppress this next-day catch-up.
    daily('no-shows-catch-up', date(time - dayMs), both('no-shows', date(time - dayMs))),
    daily('defaults', today, both('reservation-defaults', today)),
    ...(time >= midnight + 90 * minute
      ? [
          daily('nightly', today, [
            { job: 'route-learning' },
            { job: 'incident-retention' },
            { job: 'payment-evidence-retention' },
          ]),
        ]
      : []),
    ...(time >= midnight + 21 * 60 * minute
      ? [daily('asks', today, both('ask-dispatch', tomorrow))]
      : []),
    ...(time >= midnight + (23 * 60 + 30) * minute
      ? [daily('no-shows', today, both('no-shows', today))]
      : []),
  ];
}

/** Add delay, never fire earlier than the normal tick. */
export function schedulerDelay(random = Math.random): number {
  return 60_000 + Math.floor(Math.max(0, Math.min(1, random())) * 10_000);
}
