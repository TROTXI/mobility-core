import { describe, expect, it } from 'vitest';
import { loadEnv } from '../src/config/env';

const DEFAULTS = {
  JWT_ACCESS_TTL: '15m',
  JWT_ISSUER: 'trotxi',
  JWT_AUDIENCE: 'trotxi-api',
  JWT_REFRESH_TTL_DAYS: 30,
  RATE_LIMIT_MAX: 100,
  RATE_LIMIT_WINDOW_SECONDS: 60,
};

describe('loadEnv', () => {
  it('applies defaults for an empty environment', () => {
    const env = loadEnv({});
    expect(env).toEqual({ NODE_ENV: 'development', PORT: 3000, HOST: '0.0.0.0', ...DEFAULTS });
  });

  it('parses provided values', () => {
    const env = loadEnv({ NODE_ENV: 'test', PORT: '3100', HOST: '127.0.0.1' });
    expect(env).toEqual({ NODE_ENV: 'test', PORT: 3100, HOST: '127.0.0.1', ...DEFAULTS });
  });

  it('parses configurable rate-limit thresholds', () => {
    const env = loadEnv({ RATE_LIMIT_MAX: '5', RATE_LIMIT_WINDOW_SECONDS: '30' });
    expect(env.RATE_LIMIT_MAX).toBe(5);
    expect(env.RATE_LIMIT_WINDOW_SECONDS).toBe(30);
  });

  it('rejects invalid values with a readable message', () => {
    expect(() => loadEnv({ PORT: 'not-a-port' })).toThrow(/Invalid environment configuration/);
  });

  it('requires JWT_SECRET in production', () => {
    expect(() => loadEnv({ NODE_ENV: 'production' })).toThrow(/JWT_SECRET/);
  });

  it('accepts a production config with a valid JWT_SECRET', () => {
    const env = loadEnv({ NODE_ENV: 'production', JWT_SECRET: 'x'.repeat(32) });
    expect(env.JWT_SECRET).toHaveLength(32);
  });

  it('rejects a JWT_SECRET shorter than 32 chars', () => {
    expect(() => loadEnv({ JWT_SECRET: 'too-short' })).toThrow(/Invalid environment configuration/);
  });
});
