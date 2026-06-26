import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';

async function spec() {
  const app = await buildApp();
  const res = await app.inject({ method: 'GET', url: '/docs/json' });
  expect(res.statusCode).toBe(200);
  return res.json();
}

describe('OpenAPI spec', () => {
  it('declares a Bearer (JWT) security scheme', async () => {
    const s = await spec();
    expect(s.components.securitySchemes.bearerAuth).toMatchObject({
      type: 'http',
      scheme: 'bearer',
      bearerFormat: 'JWT',
    });
  });

  it('marks GET /me as requiring bearer auth and tags it', async () => {
    const me = (await spec()).paths['/me'].get;
    expect(me.security).toContainEqual({ bearerAuth: [] });
    expect(me.tags).toContain('auth');
    // Documented outcomes, including the rate-limit response.
    expect(Object.keys(me.responses)).toEqual(expect.arrayContaining(['200', '401', '404', '429']));
  });

  it('documents the system routes with a response schema', async () => {
    const s = await spec();
    const healthz = s.paths['/healthz'].get;
    expect(healthz.tags).toContain('system');
    expect(healthz.responses['200']).toBeTruthy();
  });

  it('describes the user response shape', async () => {
    const props = (await spec()).paths['/me'].get.responses['200'].content['application/json']
      .schema.properties;
    expect(Object.keys(props)).toEqual(
      expect.arrayContaining(['id', 'displayName', 'phone', 'avatarUrl', 'role', 'createdAt']),
    );
  });
});
