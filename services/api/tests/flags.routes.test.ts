import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemoryFeatureFlagRepository } from '../src/modules/flags/feature-flag.repository';
import { InMemoryMinVersionRepository } from '../src/modules/flags/min-version.repository';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const adminToken = () => jwt.signAccessToken({ userId: 'admin-1', role: 'admin' });
const commuterToken = () => jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });

const TILES_URL = 'https://pub-test.r2.dev/ghana.pmtiles';
const ATTRIBUTION = '© OpenStreetMap contributors · © OpenMapTiles';

async function flagsApp() {
  const featureFlags = new InMemoryFeatureFlagRepository();
  const minVersions = new InMemoryMinVersionRepository();
  const app = await buildApp({ auth, featureFlags, minVersions, mapTilesUrl: TILES_URL });
  return { app, featureFlags, minVersions };
}

describe('GET /flags (public)', () => {
  it('is public and returns an empty payload when nothing is configured', async () => {
    const { app } = await flagsApp();
    const res = await app.inject({ method: 'GET', url: '/flags' });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({
      flags: [],
      minSupportedVersion: { ios: null, android: null },
      mapTiles: { url: TILES_URL, attribution: ATTRIBUTION },
    });
  });

  it('degrades gracefully (empty payload) when the stores are unwired', async () => {
    const app = await buildApp({ auth });
    const res = await app.inject({ method: 'GET', url: '/flags' });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({
      flags: [],
      minSupportedVersion: { ios: null, android: null },
      // No tiles configured -> null, and the client renders without a basemap
      // rather than failing on a URL that was never set.
      mapTiles: { url: null, attribution: ATTRIBUTION },
    });
  });

  it('serves the basemap URL so clients do not compile it in (#178)', async () => {
    // The r2.dev hostname carries a generated hash and is not portable. Serving
    // it here means moving to a custom domain is a config change rather than a
    // new build of the rider app, the driver app and the console.
    const { app } = await flagsApp();
    const res = await app.inject({ method: 'GET', url: '/flags' });
    expect(res.json().mapTiles.url).toBe(TILES_URL);
  });

  it('always returns attribution, even with no tiles configured', async () => {
    // Attribution is a licence condition, not decoration: ODbL for the OSM data
    // and CC-BY for the OpenMapTiles schema. It travels with the URL so a client
    // cannot render a map without having been handed the notice.
    const app = await buildApp({ auth });
    const res = await app.inject({ method: 'GET', url: '/flags' });
    expect(res.json().mapTiles.attribution).toContain('OpenStreetMap');
    expect(res.json().mapTiles.attribution).toContain('OpenMapTiles');
  });

  it('returns the flag set (slim shape) and per-platform min versions', async () => {
    const { app, featureFlags, minVersions } = await flagsApp();
    await featureFlags.upsert('live_positions', {
      enabled: true,
      rolloutPercentage: 50,
      description: 'ops note not shown to apps',
    });
    await minVersions.set('ios', '1.2.0');
    await minVersions.set('android', '1.1.0');

    const res = await app.inject({ method: 'GET', url: '/flags' });
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.minSupportedVersion).toEqual({ ios: '1.2.0', android: '1.1.0' });
    expect(body.flags).toEqual([{ key: 'live_positions', enabled: true, rolloutPercentage: 50 }]);
    // Ops metadata is not leaked to the public payload.
    expect(body.flags[0]).not.toHaveProperty('description');
  });
});

describe('admin flags + min-versions', () => {
  it('401 without a token, 403 for a non-admin', async () => {
    const { app } = await flagsApp();
    expect((await app.inject({ method: 'GET', url: '/admin/flags' })).statusCode).toBe(401);
    const forbidden = await app.inject({
      method: 'GET',
      url: '/admin/flags',
      headers: bearer(await commuterToken()),
    });
    expect(forbidden.statusCode).toBe(403);
  });

  it('503 when the flag store is unwired', async () => {
    const app = await buildApp({ auth });
    const res = await app.inject({
      method: 'GET',
      url: '/admin/flags',
      headers: bearer(await adminToken()),
    });
    expect(res.statusCode).toBe(503);
  });

  it('upserts a flag and lists it', async () => {
    const { app } = await flagsApp();
    const token = await adminToken();

    const created = await app.inject({
      method: 'PUT',
      url: '/admin/flags/beta_ui',
      headers: bearer(token),
      payload: { enabled: true, rolloutPercentage: 25 },
    });
    expect(created.statusCode).toBe(200);
    expect(created.json()).toMatchObject({ key: 'beta_ui', enabled: true, rolloutPercentage: 25 });

    // Kill-switch: flip enabled, leave rollout unchanged.
    const flipped = await app.inject({
      method: 'PUT',
      url: '/admin/flags/beta_ui',
      headers: bearer(token),
      payload: { enabled: false },
    });
    expect(flipped.json()).toMatchObject({ enabled: false, rolloutPercentage: 25 });

    const list = await app.inject({
      method: 'GET',
      url: '/admin/flags',
      headers: bearer(token),
    });
    expect(list.json()).toHaveLength(1);
  });

  it('sets a platform minimum version and lists it', async () => {
    const { app } = await flagsApp();
    const token = await adminToken();

    const set = await app.inject({
      method: 'PUT',
      url: '/admin/min-versions/ios',
      headers: bearer(token),
      payload: { version: '2.0.0' },
    });
    expect(set.statusCode).toBe(200);
    expect(set.json()).toMatchObject({ platform: 'ios', version: '2.0.0' });

    const list = await app.inject({
      method: 'GET',
      url: '/admin/min-versions',
      headers: bearer(token),
    });
    expect(list.json()).toEqual([expect.objectContaining({ platform: 'ios', version: '2.0.0' })]);
  });

  it('rejects an unknown platform (422 from the enum schema)', async () => {
    const { app } = await flagsApp();
    const res = await app.inject({
      method: 'PUT',
      url: '/admin/min-versions/windows',
      headers: bearer(await adminToken()),
      payload: { version: '1.0.0' },
    });
    expect(res.statusCode).toBe(400);
  });
});
