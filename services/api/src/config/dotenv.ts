import { existsSync } from 'node:fs';

/**
 * Load a local `.env` file if present, using Node's built-in `process.loadEnvFile`
 * (Node 20.12+ / 22). Production injects env vars directly, so a missing file is
 * a no-op. The path is overridable to keep this testable without touching a real
 * project `.env`.
 *
 * @param path - the dotenv file to load; overridable for tests.
 */
export function loadDotenv(path = '.env'): void {
  if (existsSync(path)) {
    process.loadEnvFile(path);
  }
}
