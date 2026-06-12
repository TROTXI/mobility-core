import { describe, expect, it } from 'vitest';
import { loadEnv } from '../src/config/env';

describe('loadEnv', () => {
  it('applies defaults for an empty environment', () => {
    const env = loadEnv({});
    expect(env).toEqual({ NODE_ENV: 'development', PORT: 3000, HOST: '0.0.0.0' });
  });

  it('parses provided values', () => {
    const env = loadEnv({ NODE_ENV: 'test', PORT: '3100', HOST: '127.0.0.1' });
    expect(env).toEqual({ NODE_ENV: 'test', PORT: 3100, HOST: '127.0.0.1' });
  });

  it('rejects invalid values with a readable message', () => {
    expect(() => loadEnv({ PORT: 'not-a-port' })).toThrow(/Invalid environment configuration/);
  });
});
