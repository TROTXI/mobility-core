import { z } from 'zod';
import { periodCloseResultSchema } from '../modules/payments/payments.schema';

const maintenanceResultSchema = z.object({ periods: periodCloseResultSchema }).passthrough();

/**
 * Fail the scheduled run when the API isolated accounting work for ops review.
 *
 * The API completes the batch and returns HTTP 200 so later periods are not
 * retried. The cron still exits non-zero to make the partial failure visible in
 * Render, using only the API's bounded identifiers and reason codes.
 *
 * @param body - successful maintenance endpoint response body.
 * @throws when the response contract is invalid or any period failed to close.
 */
export function assertMaintenancePeriodCloseSucceeded(body: string): void {
  let json: unknown;
  try {
    json = JSON.parse(body);
  } catch {
    throw new Error('payment maintenance returned invalid JSON');
  }
  const result = maintenanceResultSchema.safeParse(json);
  if (!result.success) throw new Error('payment maintenance returned an invalid response');
  if (result.data.periods.failed === 0) return;

  const failures = result.data.periods.failures
    .slice(0, 10)
    .map((failure) => `${failure.periodId}:${failure.reason}`)
    .join(', ');
  throw new Error(
    `payment maintenance isolated ${result.data.periods.failed} period close failure(s)` +
      (failures ? `: ${failures}` : ''),
  );
}
