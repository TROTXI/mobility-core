// Which service window a trip belongs to (#181, E3/E4). Shared rather than
// duplicated in the ETA path: two definitions of "morning" would drift, and the
// disagreement shows up as riders asked about one run and charged for another.
//
// Ghana runs on UTC (GMT+0), so no offset is applied.

/** A service window. Mirrors the direction CHECK on reservations. */
export type ServiceWindow = 'morning' | 'evening';

/**
 * A trip's service window, from its scheduled time.
 *
 * Pilot heuristic: before noon is the morning run, otherwise the evening one.
 * Correct while each corridor runs once each way per day; replace this — in one
 * place — when trips carry an explicit direction.
 *
 * @param scheduledAt - the trip's scheduled departure.
 * @returns the service window the trip belongs to.
 */
export function directionOf(scheduledAt: Date): ServiceWindow {
  return scheduledAt.getUTCHours() < 12 ? 'morning' : 'evening';
}
