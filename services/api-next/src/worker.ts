import { readConfiguration } from './runtime/config.js';
import { composeBackend } from './runtime/compose.js';
import { JOBS, runJob } from './runtime/maintenance.js';
import type { Job } from './runtime/maintenance.js';
import { jobFailed, jobLog } from './runtime/job-outcome.js';

/**
 * The scheduled maintenance entry point.
 *
 *   node dist/worker.js <job> [travel-date] [outbound|return]
 *
 * One job per invocation, so a scheduler failure is attributable to one job
 * and a rerun repeats exactly that work. A job that does not finish exits
 * non-zero: a cron that reports success for a sweep that refused is how
 * retention and erasure quietly stop happening.
 */
const [name, ...rest] = process.argv.slice(2);
if (!JOBS.includes(name as Job)) {
  process.stderr.write(`Usage: worker <${JOBS.join('|')}> [travel-date] [outbound|return]\n`);
  process.exit(2);
}
const backend = await composeBackend(readConfiguration());
try {
  const result = await runJob(backend, {
    job: name as Job,
    travelDate: rest[0],
    direction: rest[1] as 'outbound' | 'return' | undefined,
  });
  process.stdout.write(`${jobLog(result)}\n`);
  if (jobFailed(result)) process.exitCode = 1;
} catch (error) {
  process.stderr.write(`${JSON.stringify({ job: name, failed: String(error) })}\n`);
  process.exitCode = 1;
} finally {
  await backend.close();
}
