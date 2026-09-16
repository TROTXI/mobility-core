import { z } from 'zod';
import type { JobResult } from './maintenance.js';

const count = z.number().int().nonnegative().safe();
const batch = z
  .object({
    considered: count,
    succeeded: count,
    blocked: count,
    failed: count,
    failures: z.array(z.object({ resourceId: z.string(), reason: z.string() })),
  })
  .strict();
const envelope = (schema: z.ZodType) => z.object({ data: schema }).strict();
const schemas = {
  payments: envelope(z.object({ inbox: batch, reconciliation: batch, periods: batch }).strict()),
  'ask-dispatch': envelope(batch),
  'reservation-defaults': envelope(batch),
  'no-shows': envelope(batch),
  'route-learning': envelope(batch),
  'gps-retention': envelope(batch),
  erasures: z.object({ considered: count, completed: count, failed: count }).strict(),
  'driver-secrets': z.object({ cleared: count }).strict(),
  admission: z.object({ cleared: count }).strict(),
};

/** HTTP 200 means a batch completed, not that every item succeeded. */
export function jobFailed(result: JobResult): boolean {
  if (result.status < 200 || result.status >= 300) return true;
  const parsed = schemas[result.job].safeParse(result.body);
  if (!parsed.success) throw new Error(`maintenance_contract_drift:${result.job}`);
  const failures = (value: any): boolean => {
    if (!value || typeof value !== 'object') return false;
    if (typeof value.failed === 'number' && value.failed > 0) return true;
    if (Array.isArray(value.failures) && value.failures.length > 0) return true;
    return Object.values(value).some(failures);
  };
  return failures(parsed.data) || (result.retention?.overdueSeconds ?? 0) > 3600;
}

/** Preserve counts, bound detailed failure logging. No provider payloads. */
export function jobLog(result: JobResult): string {
  return JSON.stringify(result, (key, value) =>
    key === 'failures' && Array.isArray(value) ? value.slice(0, 10) : value,
  );
}
