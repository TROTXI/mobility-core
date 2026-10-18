import assert from 'node:assert/strict';
import test from 'node:test';
import type { Pool } from 'pg';
import { ConfigService } from '../src/config/service.js';

test('build floors coalesce concurrent reads, expire without sliding, and retry failures', async () => {
  let now = 0,
    calls = 0,
    build = 4,
    failed = false;
  const config = new ConfigService({
    pool: {
      query: async () => {
        calls++;
        if (failed) throw new Error('database unavailable');
        return { rows: [{ min_supported_build: build }] };
      },
    } as unknown as Pool,
    authorizeSession: async () => {},
    build: { service: 'test', version: '1', commit: 'test' },
    cursorSecret: Buffer.alloc(32, 1),
    mapTiles: { url: null, styleUrl: null, darkStyleUrl: null, attribution: 'test' },
    fallbackBuilds: { driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
    floorCacheMs: 30_000,
    now: () => new Date(now),
  });
  assert.deepEqual(
    await Promise.all(Array.from({ length: 20 }, () => config.minimumBuild('driver', 'ios'))),
    Array(20).fill(4),
  );
  assert.equal(calls, 1);
  build = 5;
  now = 29_999;
  assert.equal(await config.minimumBuild('driver', 'ios'), 4);
  now = 30_000;
  failed = true;
  await assert.rejects(config.minimumBuild('driver', 'ios'));
  failed = false;
  assert.equal(await config.minimumBuild('driver', 'ios'), 5);
  assert.equal(calls, 3);
  assert.equal(await config.minimumBuild('commuter', 'android'), 5);
  assert.equal(calls, 4, 'floors are scoped to app and platform');
});
