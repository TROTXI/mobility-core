import { expect, test } from '@playwright/test';

test.describe('service health', () => {
  test('root describes the service', async ({ request }) => {
    const res = await request.get('/');
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.service).toBe('trotxi-api');
  });

  test('liveness probe responds', async ({ request }) => {
    const res = await request.get('/healthz');
    expect(res.status()).toBe(200);
    expect(await res.json()).toEqual({ status: 'ok' });
  });

  test('readiness probe responds', async ({ request }) => {
    const res = await request.get('/readyz');
    expect(res.status()).toBe(200);
    expect(await res.json()).toEqual({ status: 'ready' });
  });
  test('version endpoint returns build identity', async ({ request }) => {
    const res = await request.get('/version');
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body).toMatchObject({
      name: 'trotxi-api',
      version: '0.1.0',
      commit: expect.any(String),
    });
  });
});
