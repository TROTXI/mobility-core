import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';

describe('GET /metrics', () => {
  it('exposes runtime + RED metrics in Prometheus format', async () => {
    const app = await buildApp();
    await app.inject({ method: 'GET', url: '/healthz' }); // generate one sample

    const res = await app.inject({ method: 'GET', url: '/metrics' });
    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toContain('text/plain');
    // runtime (memory + event-loop lag) and the RED histogram
    expect(res.body).toContain('process_resident_memory_bytes');
    expect(res.body).toContain('nodejs_eventloop_lag_seconds');
    expect(res.body).toContain('http_request_duration_seconds');
    expect(res.body).toContain('route="/healthz"');
  });

  it('does not record the scrape itself or unmatched routes', async () => {
    const app = await buildApp();
    await app.inject({ method: 'GET', url: '/no-such-route' }); // 404, no template
    await app.inject({ method: 'GET', url: '/metrics' });

    const res = await app.inject({ method: 'GET', url: '/metrics' });
    expect(res.body).not.toContain('route="/metrics"');
    expect(res.body).not.toContain('/no-such-route');
  });

  it('requires a bearer token when one is configured', async () => {
    const app = await buildApp({ metrics: { token: 'secret-token' } });

    expect((await app.inject({ method: 'GET', url: '/metrics' })).statusCode).toBe(401);
    expect(
      (
        await app.inject({
          method: 'GET',
          url: '/metrics',
          headers: { authorization: 'Bearer wrong' },
        })
      ).statusCode,
    ).toBe(401);
    const ok = await app.inject({
      method: 'GET',
      url: '/metrics',
      headers: { authorization: 'Bearer secret-token' },
    });
    expect(ok.statusCode).toBe(200);
  });

  it('is disabled (404) when unprotected exposure is off and no token is set', async () => {
    const app = await buildApp({ metrics: { allowUnprotected: false } });
    expect((await app.inject({ method: 'GET', url: '/metrics' })).statusCode).toBe(404);
  });
});
