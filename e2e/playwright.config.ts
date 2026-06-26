import { defineConfig } from '@playwright/test';
import { E2E_JWT_SECRET } from './fixtures';

const PORT = Number(process.env.E2E_PORT ?? 3100);
const BASE_URL = `http://127.0.0.1:${PORT}`;

// Set (CI, or local `pnpm infra:up`) -> the API under test uses Postgres and the
// DB-backed specs run. Unset -> in-memory, those specs skip.
const DATABASE_URL = process.env.DATABASE_URL;

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI ? [['list'], ['html', { open: 'never' }]] : 'list',
  // Migrates + seeds the e2e database when DATABASE_URL is set (no-op otherwise).
  globalSetup: './global-setup.ts',
  use: {
    baseURL: BASE_URL,
  },
  webServer: {
    command: 'pnpm exec tsx src/server.ts',
    cwd: '../services/api',
    url: `${BASE_URL}/healthz`,
    reuseExistingServer: false,
    timeout: 60_000,
    env: {
      PORT: String(PORT),
      HOST: '127.0.0.1',
      NODE_ENV: 'test',
      // Deterministic secret so specs can mint tokens the server accepts.
      JWT_SECRET: E2E_JWT_SECRET,
      // Pass through when present so the server uses Postgres (see global-setup).
      ...(DATABASE_URL ? { DATABASE_URL } : {}),
    },
  },
});
