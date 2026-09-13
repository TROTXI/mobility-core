// Execute only in the staging verification runner. Credentials stay in the
// runner's masked environment and are never included in artifacts or logs.
import { appendFile } from 'node:fs/promises';

const serviceId = process.env.RENDER_STAGING_SERVICE_ID;
const renderKey = process.env.RENDER_API_KEY;
if (serviceId !== 'srv-d8suhkn7f7vs73bigd40' || !renderKey || !process.env.GITHUB_ENV) {
  throw new Error('Expected the configured staging service and GitHub runner');
}
const response = await fetch(
  `https://api.render.com/v1/services/${serviceId}/env-vars/PAYSTACK_SECRET_KEY`,
  { headers: { Authorization: `Bearer ${renderKey}` }, signal: AbortSignal.timeout(15000) },
);
if (!response.ok)
  throw new Error(`Reading staging Paystack configuration: HTTP ${response.status}`);
const data = await response.json();
const key = data.value ?? data.envVar?.value;
if (typeof key !== 'string' || !key.startsWith('sk_test_') || /[\r\n]/.test(key)) {
  throw new Error('Staging verification requires sk_test_; no test was started');
}
console.log(`::add-mask::${key}`);
await appendFile(process.env.GITHUB_ENV, `PAYSTACK_SECRET_KEY=${key}\n`);
console.log('Staging Paystack environment: test');

// Read the signing key only for the phase that creates a commuter checkout.
for (const [name, fallback] of process.env.SMOKE_PHASE === 'setup'
  ? [
      ['JWT_SECRET', null],
      ['JWT_ISSUER', 'trotxi'],
      ['JWT_AUDIENCE', 'trotxi-api'],
    ]
  : []) {
  const res = await fetch(`https://api.render.com/v1/services/${serviceId}/env-vars/${name}`, {
    headers: { Authorization: `Bearer ${renderKey}` },
    signal: AbortSignal.timeout(15000),
  });
  const body = res.ok ? await res.json() : null;
  const value = body?.value ?? body?.envVar?.value ?? (res.status === 404 ? fallback : null);
  if (typeof value !== 'string' || !value || /[\r\n]/.test(value)) {
    throw new Error(`Missing staging ${name}: HTTP ${res.status}`);
  }
  if (name === 'JWT_SECRET') console.log(`::add-mask::${value}`);
  await appendFile(process.env.GITHUB_ENV, `${name}=${value}\n`);
}
