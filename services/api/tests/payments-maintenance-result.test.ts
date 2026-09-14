import { describe, expect, it } from 'vitest';
import { assertMaintenancePeriodCloseSucceeded } from '../src/cron/payments-maintenance-result';

function response(
  failures: Array<{ periodId: string; reason: 'missing_conversion_rate' }> = [],
): string {
  return JSON.stringify({
    webhooks: { processed: 0, failed: 0 },
    reconciliation: { considered: 0, fulfilled: 0, failed: 0, unresolved: 0, errors: 0 },
    periods: {
      considered: failures.length,
      closed: 0,
      blocked: 0,
      failed: failures.length,
      failures,
      riders: 0,
      ridesConverted: 0,
      creditPesewas: 0,
    },
  });
}

describe('payment maintenance cron result', () => {
  it('accepts a complete run without isolated close failures', () => {
    expect(() => assertMaintenancePeriodCloseSucceeded(response())).not.toThrow();
  });

  it('fails the scheduled run with only stable period diagnostics', () => {
    expect(() =>
      assertMaintenancePeriodCloseSucceeded(
        response([{ periodId: 'period-stable-id', reason: 'missing_conversion_rate' }]),
      ),
    ).toThrow(
      'payment maintenance isolated 1 period close failure(s): period-stable-id:missing_conversion_rate',
    );
  });

  it('fails closed when the maintenance response contract drifts', () => {
    expect(() => assertMaintenancePeriodCloseSucceeded('{}')).toThrow(
      'payment maintenance returned an invalid response',
    );
  });
});
