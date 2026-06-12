import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';

describe('app', () => {
  it('describes the service at the root', async () => {
    const app = await buildApp();
    const res = await app.inject({ method: 'GET', url: '/' });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ service: 'trotxi-api' });
  });

  it('reports liveness', async () => {
    const app = await buildApp();
    const res = await app.inject({ method: 'GET', url: '/healthz' });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({ status: 'ok' });
  });

  it('defaults to ready when no readiness probe is wired', async () => {
    const app = await buildApp();
    const res = await app.inject({ method: 'GET', url: '/readyz' });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({ status: 'ready' });
  });

  it('reports ready when the readiness probe passes', async () => {
    const app = await buildApp({ isReady: async () => true });
    const res = await app.inject({ method: 'GET', url: '/readyz' });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({ status: 'ready' });
  });

  it('reports 503 when the readiness probe fails', async () => {
    const app = await buildApp({ isReady: async () => false });
    const res = await app.inject({ method: 'GET', url: '/readyz' });
    expect(res.statusCode).toBe(503);
    expect(res.json()).toEqual({ status: 'not_ready' });
  });
});
