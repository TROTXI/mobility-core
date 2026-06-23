import { afterEach, describe, expect, it } from 'vitest';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { loadDotenv } from '../src/config/dotenv';

// NOTE: tests operate on a throwaway temp directory, never the project's real
// `.env`, so running the suite can't clobber a developer's local config.
describe('loadDotenv', () => {
  const KEY = 'TROTXI_DOTENV_TEST_VAR';
  afterEach(() => {
    delete process.env[KEY];
  });

  it('loads variables from a .env file when present', () => {
    const dir = mkdtempSync(join(tmpdir(), 'trotxi-dotenv-'));
    const file = join(dir, '.env');
    writeFileSync(file, `${KEY}=hello\n`);
    try {
      loadDotenv(file);
      expect(process.env[KEY]).toBe('hello');
    } finally {
      rmSync(dir, { recursive: true, force: true });
    }
  });

  it('is a no-op when the file is absent', () => {
    const missing = join(tmpdir(), 'trotxi-definitely-missing.env');
    expect(() => loadDotenv(missing)).not.toThrow();
    expect(process.env[KEY]).toBeUndefined();
  });
});
