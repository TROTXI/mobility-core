// Payment recovery cron. A single idempotent endpoint drains durable Paystack
// events, verifies stale unresolved payments, then closes only periods whose
// reservations have reached a terminal outcome.

import { createJwtService, type AuthConfig } from '../modules/auth/jwt';
import { assertMaintenancePeriodCloseSucceeded } from './payments-maintenance-result';

async function main(): Promise<void> {
  const secret = process.env.JWT_SECRET;
  const baseUrl = process.env.API_BASE_URL;
  if (!secret) throw new Error('JWT_SECRET is required');
  if (!baseUrl) throw new Error('API_BASE_URL is required');

  const auth: AuthConfig = {
    secret,
    accessTtl: '5m',
    issuer: process.env.JWT_ISSUER ?? 'trotxi',
    audience: process.env.JWT_AUDIENCE ?? 'trotxi-api',
  };
  const token = await createJwtService(auth).signAccessToken({
    userId: 'cron-payments-maintenance',
    role: 'admin',
  });
  const url = `${baseUrl.replace(/\/$/, '')}/admin/payments/maintenance`;
  const response = await fetch(url, {
    method: 'POST',
    headers: { authorization: `Bearer ${token}` },
    signal: AbortSignal.timeout(30_000),
  });
  const body = await response.text();
  if (!response.ok) {
    throw new Error(`payment maintenance -> HTTP ${response.status}: ${body}`);
  }
  console.log(`payment maintenance -> ${response.status} ${body}`);
  assertMaintenancePeriodCloseSucceeded(body);
}

main().catch((error: unknown) => {
  console.error('payment maintenance cron failed:', error);
  process.exit(1);
});
