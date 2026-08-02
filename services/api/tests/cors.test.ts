// CORS for browser clients (the live demo page, a web dashboard). Auth is a
// bearer token, not cookies, so reflecting any origin is safe; an allowlist
// locks it down when configured.

import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';

describe('CORS', () => {
  it('reflects any origin by default (bearer auth, no credentials)', async () => {
    const app = await buildApp();
    const res = await app.inject({
      method: 'OPTIONS',
      url: '/routes',
      headers: { origin: 'https://demo.example', 'access-control-request-method': 'GET' },
    });
    expect(res.headers['access-control-allow-origin']).toBe('https://demo.example');
    // no cookies ride along
    expect(res.headers['access-control-allow-credentials']).toBeUndefined();
  });

  it('sets the CORS header on an actual GET', async () => {
    const app = await buildApp();
    const res = await app.inject({
      method: 'GET',
      url: '/healthz',
      headers: { origin: 'https://demo.example' },
    });
    expect(res.statusCode).toBe(200);
    expect(res.headers['access-control-allow-origin']).toBe('https://demo.example');
  });

  it('restricts to the allowlist when configured', async () => {
    const app = await buildApp({ corsOrigins: ['https://allowed.app'] });
    const ok = await app.inject({
      method: 'GET',
      url: '/healthz',
      headers: { origin: 'https://allowed.app' },
    });
    expect(ok.headers['access-control-allow-origin']).toBe('https://allowed.app');

    const blocked = await app.inject({
      method: 'GET',
      url: '/healthz',
      headers: { origin: 'https://evil.app' },
    });
    // origin not echoed back for a disallowed site
    expect(blocked.headers['access-control-allow-origin']).toBeUndefined();
  });
});
