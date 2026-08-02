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
  it('serves an OpenAPI spec that lists the routes', async () => {
    const app = await buildApp();
    const res = await app.inject({ method: 'GET', url: '/docs/json' });
    expect(res.statusCode).toBe(200);
    const spec = res.json();
    expect(spec.openapi).toBeTruthy();
    expect(Object.keys(spec.paths)).toContain('/healthz');
  });

  it('returns version info with name, version and commit', async () => {
    const app = await buildApp();
    const res = await app.inject({ method: 'GET', url: '/version' });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({
      name: 'trotxi-api',
      version: '0.1.0',
      commit: 'dev',
    });
  });

  // Rollback starts with "what is actually running?", so /version must report
  // the deployed commit. Render injects RENDER_GIT_COMMIT; GIT_SHA overrides it
  // for images built elsewhere.
  it.each([
    { env: 'GIT_SHA', value: 'abc1234', expected: 'abc1234' },
    { env: 'RENDER_GIT_COMMIT', value: 'def5678', expected: 'def5678' },
  ])('reports the commit from $env', async ({ env, value, expected }) => {
    const previous = process.env[env];
    process.env[env] = value;
    try {
      const app = await buildApp();
      const res = await app.inject({ method: 'GET', url: '/version' });
      expect(res.json()).toMatchObject({ commit: expected });
    } finally {
      if (previous === undefined) delete process.env[env];
      else process.env[env] = previous;
    }
  });

  // The Dockerfile declares ARG GIT_SHA="", so an unstamped image ships an
  // empty GIT_SHA. It must not mask the platform-injected commit.
  it('ignores an empty GIT_SHA and falls back to the platform commit', async () => {
    process.env['GIT_SHA'] = '';
    process.env['RENDER_GIT_COMMIT'] = 'render123';
    try {
      const app = await buildApp();
      const res = await app.inject({ method: 'GET', url: '/version' });
      expect(res.json()).toMatchObject({ commit: 'render123' });
    } finally {
      delete process.env['GIT_SHA'];
      delete process.env['RENDER_GIT_COMMIT'];
    }
  });

  it('prefers an explicit GIT_SHA over the platform-injected commit', async () => {
    process.env['GIT_SHA'] = 'explicit';
    process.env['RENDER_GIT_COMMIT'] = 'platform';
    try {
      const app = await buildApp();
      const res = await app.inject({ method: 'GET', url: '/version' });
      expect(res.json()).toMatchObject({ commit: 'explicit' });
    } finally {
      delete process.env['GIT_SHA'];
      delete process.env['RENDER_GIT_COMMIT'];
    }
  });
});
