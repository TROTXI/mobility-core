import { metrics } from '@opentelemetry/api';
import type { Counter } from '@opentelemetry/api';
import type { Pool, PoolClient } from 'pg';

/**
 * The business signals Grafana alerts on.
 *
 * Two failures in one week were silent until a person noticed. A paid
 * subscription sat unapplied for hours because nothing drained the webhook
 * inbox. And the job meant to drain it failed on every run for a day, before
 * it ever reached this service, so no request metric could have seen it.
 *
 * Both show up in one number: how long the oldest unprocessed webhook has been
 * waiting. It climbs whether the job fails, never runs, or runs and fails
 * quietly. So the state here is read from the database, not counted as events
 * pass through this process, which also means it survives a restart.
 *
 * Instruments are created on first use. The metrics API has no proxy: a meter
 * taken before the SDK registers its provider stays a no-op for good.
 */
const METER = 'trotxi';

let jobRuns: Counter | undefined;

/**
 * A maintenance response only succeeded if nothing inside it failed. HTTP 200
 * means the batch ran, not that every item in it did: the same rule the worker
 * applies through jobFailed.
 */
export function batchFailed(status: number, body: unknown): boolean {
  if (status < 200 || status >= 300) return true;
  const failed = (value: unknown): boolean => {
    if (!value || typeof value !== 'object') return false;
    const record = value as Record<string, unknown>;
    if (typeof record.failed === 'number' && record.failed > 0) return true;
    if (Array.isArray(record.failures) && record.failures.length > 0) return true;
    return Object.values(record).some(failed);
  };
  return failed(body);
}

/** One scheduled job run, by operation and outcome. */
export function recordJob(operation: string, status: number, payload: unknown): void {
  jobRuns ??= metrics
    .getMeter(METER)
    .createCounter('trotxi_job_runs', { description: 'Scheduled maintenance job runs.' });
  let body: unknown = payload;
  if (typeof payload === 'string') {
    try {
      body = JSON.parse(payload);
    } catch {
      body = null;
    }
  }
  // Not `job`: Prometheus reserves that label for the service, and the OTLP
  // conversion overwrites it, which would fold every job into one series.
  jobRuns.add(1, {
    operation,
    outcome: batchFailed(status, body) ? 'failed' : 'succeeded',
  });
}

export interface BusinessState {
  inboxReady: number;
  inboxOldestReadySeconds: number;
  inboxQuarantined: number;
  purchasesUnresolved: number;
  purchasesUnresolvedOldestSeconds: number;
  tripsActive: number;
  tripsStaleGps: number;
  tripsUnassignedToday: number;
  boardedToday: number;
  noShowsToday: number;
  reservedToday: number;
}

/**
 * One statement, so every gauge in an export is from the same instant.
 *
 * Stale uses the same threshold as the ops board, so Grafana and the
 * dispatcher's screen never disagree about which bus has gone quiet.
 */
const STATE = `
  SELECT
    (SELECT count(*) FROM app.payment_events WHERE state = 'ready')::int AS inbox_ready,
    COALESCE((SELECT extract(epoch FROM clock_timestamp() - min(received_at))
      FROM app.payment_events WHERE state = 'ready'), 0)::int AS inbox_oldest_ready_seconds,
    (SELECT count(*) FROM app.payment_events WHERE state = 'quarantined')::int AS inbox_quarantined,
    (SELECT count(*) FROM app.purchases
      WHERE state IN ('awaiting_payment', 'processing', 'review_required'))::int AS purchases_unresolved,
    COALESCE((SELECT extract(epoch FROM clock_timestamp() - min(created_at)) FROM app.purchases
      WHERE state IN ('awaiting_payment', 'processing', 'review_required')), 0)::int
      AS purchases_unresolved_oldest_seconds,
    (SELECT count(*) FROM app.trips WHERE status = 'active')::int AS trips_active,
    (SELECT count(*) FROM app.trips t
      LEFT JOIN app.trip_live_positions lp ON lp.trip_id = t.id
      WHERE t.status = 'active'
        AND (lp.effective_captured_at IS NULL
          OR lp.effective_captured_at < clock_timestamp() - make_interval(secs => $1)))::int
      AS trips_stale_gps,
    (SELECT count(*) FROM app.trips
      WHERE status = 'scheduled' AND service_date = $2::date
        AND (assigned_driver_id IS NULL OR vehicle_id IS NULL))::int AS trips_unassigned_today,
    (SELECT count(*) FROM app.reservations
      WHERE service_date = $2::date AND status = 'boarded')::int AS boarded_today,
    (SELECT count(*) FROM app.reservations
      WHERE service_date = $2::date AND status = 'no_show')::int AS no_shows_today,
    (SELECT count(*) FROM app.reservations
      WHERE service_date = $2::date AND status = 'reserved')::int AS reserved_today`;

/** Accra is on UTC with no daylight saving, the same assumption the board states. */
const serviceDay = (now: Date) => now.toISOString().slice(0, 10);

export async function readBusinessState(
  client: Pick<PoolClient, 'query'>,
  options: { staleAfterSeconds: number; now?: Date },
): Promise<BusinessState> {
  const row = (
    await client.query(STATE, [options.staleAfterSeconds, serviceDay(options.now ?? new Date())])
  ).rows[0];
  return {
    inboxReady: row.inbox_ready,
    inboxOldestReadySeconds: row.inbox_oldest_ready_seconds,
    inboxQuarantined: row.inbox_quarantined,
    purchasesUnresolved: row.purchases_unresolved,
    purchasesUnresolvedOldestSeconds: row.purchases_unresolved_oldest_seconds,
    tripsActive: row.trips_active,
    tripsStaleGps: row.trips_stale_gps,
    tripsUnassignedToday: row.trips_unassigned_today,
    boardedToday: row.boarded_today,
    noShowsToday: row.no_shows_today,
    reservedToday: row.reserved_today,
  };
}

const GAUGES: [keyof BusinessState, string, string][] = [
  ['inboxReady', 'trotxi_payment_inbox_ready', 'Paystack events received and not yet processed.'],
  [
    'inboxOldestReadySeconds',
    'trotxi_payment_inbox_oldest_ready_seconds',
    'How long the oldest unprocessed Paystack event has waited. Climbs when nothing drains.',
  ],
  [
    'inboxQuarantined',
    'trotxi_payment_inbox_quarantined',
    'Paystack events set aside for a person to look at.',
  ],
  [
    'purchasesUnresolved',
    'trotxi_purchases_unresolved',
    'Purchases awaiting payment, processing, or needing review. Each one blocks that rider from checkout.',
  ],
  [
    'purchasesUnresolvedOldestSeconds',
    'trotxi_purchases_unresolved_oldest_seconds',
    'Age of the oldest unresolved purchase.',
  ],
  ['tripsActive', 'trotxi_trips_active', 'Runs in progress.'],
  ['tripsStaleGps', 'trotxi_trips_stale_gps', 'Runs in progress whose bus has stopped reporting.'],
  [
    'tripsUnassignedToday',
    'trotxi_trips_unassigned_today',
    "Today's runs still missing a driver or a bus.",
  ],
  ['boardedToday', 'trotxi_reservations_boarded_today', 'Riders boarded today.'],
  ['noShowsToday', 'trotxi_reservations_no_shows_today', 'Riders marked absent today.'],
  ['reservedToday', 'trotxi_reservations_reserved_today', 'Seats held today and not yet settled.'],
];

/**
 * What the platform kills the process for. The V8 heap limit is sized for the
 * machine, not the plan, so heap used against it reads comfortable right up to
 * the moment Render stops a 256 MB instance for exceeding its memory. Resident
 * memory is the number that plan limit is enforced on. CPU time is a counter;
 * its rate is the share of a core in use.
 */
export function observeProcess(): void {
  const meter = metrics.getMeter(METER);
  const rss = meter.createObservableGauge('process.memory.usage', {
    description: 'Resident memory of the API process.',
    unit: 'By',
  });
  const cpu = meter.createObservableCounter('process.cpu.time', {
    description: 'CPU time used by the API process.',
    unit: 's',
  });
  meter.addBatchObservableCallback(
    (observer) => {
      observer.observe(rss, process.memoryUsage.rss());
      const usage = process.cpuUsage();
      observer.observe(cpu, usage.user / 1e6, { 'cpu.mode': 'user' });
      observer.observe(cpu, usage.system / 1e6, { 'cpu.mode': 'system' });
    },
    [rss, cpu],
  );
}

/**
 * Read the state once per export and publish every gauge from it. A query that
 * fails publishes nothing for that interval rather than a false zero, which a
 * "stopped reporting" alert in Grafana then catches.
 */
export function observeBusiness(pool: Pool, staleAfterSeconds: number): void {
  const meter = metrics.getMeter(METER);
  const gauges = GAUGES.map(([key, name, description]) => ({
    key,
    gauge: meter.createObservableGauge(name, { description }),
  }));
  meter.addBatchObservableCallback(
    async (observer) => {
      let state: BusinessState;
      try {
        state = await readBusinessState(pool, { staleAfterSeconds });
      } catch {
        return;
      }
      for (const { key, gauge } of gauges) observer.observe(gauge, state[key]);
    },
    gauges.map((g) => g.gauge),
  );
}
