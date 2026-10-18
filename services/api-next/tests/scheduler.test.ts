import assert from 'node:assert/strict';
import test from 'node:test';
import { EventEmitter } from 'node:events';
import { JOBS, type JobResult } from '../src/runtime/maintenance.js';
import { scheduledGroups, schedulerDelay } from '../src/runtime/job-schedule.js';
import {
  drainScheduledJob,
  MaintenanceScheduler,
  validateScheduler,
} from '../src/runtime/scheduler.js';
import type { Backend } from '../src/runtime/compose.js';

const batch = (considered = 0, succeeded = considered, blocked = 0) => ({
  considered,
  succeeded,
  blocked,
  failed: 0,
  failures: [],
});
const result = (considered = 0, succeeded = considered, blocked = 0): JobResult => ({
  job: 'personal-pause-resumes',
  status: 200,
  body: { data: batch(considered, succeeded, blocked) },
});

test('all worker capabilities have a schedule, with UTC dates and existing service cutoffs', () => {
  const at = (time: string) => scheduledGroups(new Date(time));
  const groups = at('2026-12-31T23:30:00Z');
  assert.deepEqual(
    [...new Set(groups.flatMap((g) => g.jobs.map((j) => j.job)))].sort(),
    [...JOBS].sort(),
  );
  const asks = groups.find((g) => g.name === 'asks')!;
  assert.deepEqual(
    asks.jobs.map((j) => [j.travelDate, j.direction]),
    [
      ['2027-01-01', 'outbound'],
      ['2027-01-01', 'return'],
    ],
  );
  assert.equal(
    at('2026-12-31T20:59:59Z').some((g) => g.name === 'asks'),
    false,
  );
  assert.equal(
    at('2026-12-31T21:00:00Z').some((g) => g.name === 'asks'),
    true,
  );
  assert.equal(
    at('2026-12-31T01:29:59Z').some((g) => g.name === 'nightly'),
    false,
  );
  assert.equal(at('2026-12-31T23:29:59Z').filter((g) => g.name === 'no-shows').length, 0);
  assert.equal(groups.filter((g) => g.name === 'no-shows').length, 1);
  const midnight = at('2027-01-01T00:00:00Z');
  assert.equal(midnight.find((g) => g.name === 'defaults')!.jobs[0]!.travelDate, '2027-01-01');
  const catchUp = midnight.find((g) => g.name === 'no-shows-catch-up')!;
  assert.equal(catchUp.jobs[0]!.travelDate, '2026-12-31');
  assert.notEqual(
    catchUp.key,
    groups.find((g) => g.name === 'no-shows')!.key,
    'successful 23:30 settlement must not suppress the full-day catch-up',
  );
  const dates = midnight
    .find((g) => g.name === 'timetable')!
    .jobs.filter((j) => j.job === 'trip-generation')
    .map((j) => j.travelDate);
  assert.equal(dates.length, 8);
  assert.equal(dates[0], '2027-01-01');
  assert.equal(dates.at(-1), '2027-01-08');
  assert.equal(new Set(groups.map((g) => g.key)).size, groups.length);
  assert.ok(groups.every((g) => g.key.length <= 80));
});

test('periodic slots remain stable inside their window and tick jitter never runs early', () => {
  const key = (time: string) =>
    scheduledGroups(new Date(time)).find((g) => g.name === 'payments')!.key;
  assert.equal(key('2026-10-18T01:00:00Z'), key('2026-10-18T01:14:59Z'));
  assert.notEqual(key('2026-10-18T01:14:59Z'), key('2026-10-18T01:15:00Z'));
  assert.equal(
    schedulerDelay(() => 0),
    60_000,
  );
  assert.equal(
    schedulerDelay(() => 0.5),
    65_000,
  );
  assert.equal(
    schedulerDelay(() => 1),
    70_000,
  );
});

test('drains beyond 100, bounds work, and rejects failures instead of reporting success', async () => {
  let calls = 0;
  await drainScheduledJob(
    { job: 'personal-pause-resumes' },
    async (request) => {
      assert.equal(request.limit, 100);
      return result(++calls < 3 ? 100 : 17);
    },
    () => false,
  );
  assert.equal(calls, 3);
  calls = 0;
  await assert.rejects(
    drainScheduledJob(
      { job: 'personal-pause-resumes' },
      async () => {
        calls++;
        return result(100);
      },
      () => false,
    ),
    /backlog_remaining/,
  );
  assert.equal(calls, 10);
  calls = 0;
  await assert.rejects(
    drainScheduledJob(
      { job: 'personal-pause-resumes' },
      async () => {
        calls++;
        return result(100, 0, 100);
      },
      () => false,
    ),
    /backlog_remaining/,
  );
  assert.equal(calls, 1);
  await assert.rejects(
    drainScheduledJob(
      { job: 'payments' },
      async () => ({
        job: 'payments',
        status: 403,
        body: { error: 'forbidden' },
      }),
      () => false,
    ),
    /scheduler_job_failed/,
  );
  await assert.rejects(
    drainScheduledJob(
      { job: 'payments' },
      async () => ({
        job: 'payments',
        status: 200,
        body: {},
      }),
      () => false,
    ),
    /maintenance_contract_drift/,
  );
});

test('retention backlog is drained but a stalled retention job is not a success', async () => {
  let calls = 0;
  const run = async (): Promise<JobResult> => ({
    job: 'payment-evidence-retention',
    status: 200,
    body: { redacted: 100, batches: 1, backlogRemaining: ++calls < 2 },
  });
  await drainScheduledJob({ job: 'payment-evidence-retention' }, run, () => false);
  assert.equal(calls, 2);
  await assert.rejects(
    drainScheduledJob(
      { job: 'payment-evidence-retention' },
      async () => ({
        job: 'payment-evidence-retention',
        status: 200,
        body: { redacted: 0, batches: 1, backlogRemaining: true },
      }),
      () => false,
    ),
  );
});

test('stopping, elapsed budgets and expired service days prevent another batch', async () => {
  let calls = 0,
    clock = 0;
  const run = async () => {
    calls++;
    clock += 45_000;
    return result(100);
  };
  await assert.rejects(
    drainScheduledJob(
      { job: 'personal-pause-resumes' },
      run,
      () => false,
      () => clock,
    ),
    /backlog_remaining/,
  );
  assert.equal(calls, 1);
  await assert.rejects(
    drainScheduledJob({ job: 'personal-pause-resumes' }, run, () => true),
    /stopped/,
  );
  assert.equal(calls, 1);
  await assert.rejects(
    drainScheduledJob(
      { job: 'ask-dispatch', travelDate: '2026-10-17', direction: 'outbound' },
      run,
      () => false,
      () => Date.parse('2026-10-18'),
    ),
    /service_day_expired/,
  );
  assert.equal(calls, 1);
});

function fixture(now: Date) {
  const records = new Map<string, { started_at: Date; state: string | null }>();
  const ids = new Map<string, string>();
  const log: Record<string, unknown>[] = [];
  let locked = false,
    releases = 0,
    destroyed = false,
    failQuery = false;
  const client = Object.assign(new EventEmitter(), {
    query: async (sql: string, values: unknown[]) => {
      if (failQuery) throw new Error('private connection string must not be logged');
      if (sql.includes('pg_try_advisory_lock')) {
        const acquired = !locked;
        if (acquired) locked = true;
        return { rows: [{ acquired }] };
      }
      if (sql.includes('pg_advisory_unlock')) {
        locked = false;
        return { rows: [] };
      }
      const row = records.get(values[0] as string);
      return { rows: row ? [row] : [] };
    },
    release: (broken: boolean) => {
      releases++;
      destroyed = broken;
    },
  });
  const backend = {
    maintenanceUserId: 'service',
    pool: { connect: async () => client },
    maintenanceAudit: {
      startWorker: async (_actor: string, key: string) => {
        const id = String(ids.size);
        ids.set(id, key);
        records.set(key, { started_at: now, state: null });
        return id;
      },
      finish: async (id: string, status: number) => {
        records.get(ids.get(id)!)!.state = status === 200 ? 'completed' : 'failed';
      },
    },
  } as unknown as Backend;
  return {
    backend,
    records,
    log,
    client,
    state: () => ({ locked, releases, destroyed }),
    setLocked: () => {
      locked = true;
    },
    failQuery: () => {
      failQuery = true;
    },
  };
}

test('another replica holding the lock prevents any work; completed slots survive restart', async () => {
  const now = new Date('2026-10-18T12:00:00Z');
  const f = fixture(now);
  let calls = 0;
  const run = async () => {
    calls++;
    return result();
  };
  await new MaintenanceScheduler(
    f.backend,
    (e) => f.log.push(e),
    run,
    () => now.getTime(),
  ).tick(now);
  assert.ok(calls > 0);
  const before = calls;
  await new MaintenanceScheduler(
    f.backend,
    (e) => f.log.push(e),
    run,
    () => now.getTime(),
  ).tick(now);
  assert.equal(calls, before);
  assert.deepEqual(f.state(), { locked: false, releases: 2, destroyed: false });
  f.setLocked();
  await new MaintenanceScheduler(
    f.backend,
    (e) => f.log.push(e),
    run,
    () => now.getTime(),
  ).tick(new Date('2026-10-18T12:16:00Z'));
  assert.equal(calls, before);
});

test('failures are audited, do not block other jobs, and daily slots retry after five minutes', async () => {
  const now = new Date('2026-10-18T12:00:00Z');
  const f = fixture(now);
  const requests: string[] = [];
  const scheduler = new MaintenanceScheduler(
    f.backend,
    (e) => f.log.push(e),
    async (request) => {
      requests.push(request.job);
      if (request.job === 'push') throw new Error('private provider token');
      return result();
    },
    () => now.getTime(),
  );
  await scheduler.tick(now);
  assert.ok(requests.includes('payment-evidence-retention'));
  assert.ok(f.log.some((e) => e.status === 'failed'));
  assert.equal(JSON.stringify(f.log).includes('private'), false);
  const daily = scheduledGroups(now).find((g) => g.name === 'defaults')!;
  f.records.set(daily.key, { started_at: now, state: 'failed' });
  requests.length = 0;
  await scheduler.tick(new Date(now.getTime() + 4 * 60_000));
  assert.equal(requests.includes('reservation-defaults'), false);
  await scheduler.tick(new Date(now.getTime() + 5 * 60_000));
  assert.equal(requests.includes('reservation-defaults'), true);
  await scheduler.stop();
  requests.length = 0;
  await scheduler.tick(new Date(now.getTime() + 60 * 60_000));
  assert.equal(requests.length, 0);
});

test('uncertain lock queries destroy the connection rather than returning it to the pool', async () => {
  const f = fixture(new Date());
  f.failQuery();
  await assert.rejects(new MaintenanceScheduler(f.backend, () => {}).tick());
  assert.equal(f.state().destroyed, true);
  assert.equal(f.client.listenerCount('error'), 0);
});

test('timer ticks never overlap, duplicate starts are ignored, and stop awaits in-flight work', async (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] });
  const now = new Date();
  const f = fixture(now);
  let calls = 0,
    release!: () => void,
    entered!: () => void;
  const workStarted = new Promise<void>((resolve) => {
    entered = resolve;
  });
  const work = new Promise<void>((resolve) => {
    release = resolve;
  });
  const scheduler = new MaintenanceScheduler(
    f.backend,
    () => {},
    async () => {
      calls++;
      entered();
      await work;
      return result();
    },
  );
  scheduler.start();
  scheduler.start();
  t.mock.timers.tick(70_000);
  await workStarted;
  t.mock.timers.tick(300_000);
  assert.equal(calls, 1);
  let stopped = false;
  const stopping = scheduler.stop().then(() => {
    stopped = true;
  });
  await Promise.resolve();
  assert.equal(stopped, false);
  release();
  await stopping;
  t.mock.timers.tick(300_000);
  assert.equal(calls, 1);
  assert.equal(f.state().locked, false);
});

test('startup requires configured delivery providers and a non-interactive service identity', async () => {
  const backend = {} as Backend;
  await assert.rejects(validateScheduler(backend), /requires_push_and_messaging/);
  backend.push = {} as Backend['push'];
  backend.sms = {} as Backend['sms'];
  let eligible = false;
  backend.pool = {
    query: async (sql: string) => {
      assert.ok(sql.includes("s.issued_for='interactive'"));
      assert.ok(sql.includes('u.deleted_at IS NULL'));
      return { rowCount: eligible ? 1 : 0 };
    },
  } as unknown as Backend['pool'];
  await assert.rejects(validateScheduler(backend), /requires_service_identity/);
  eligible = true;
  await validateScheduler(backend);
});
