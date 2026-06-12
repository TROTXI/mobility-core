import { defineConfig } from '@playwright/test';

const PORT = Number(process.env.E2E_PORT ?? 3100);
const BASE_URL = `http://127.0.0.1:${PORT}`;

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI ? [['list'], ['html', { open: 'never' }]] : 'list',
  use: {
    baseURL: BASE_URL,
  },
  // When the API gains a datastore: add a globalSetup that provisions a
  // dedicated e2e database (drop/recreate + migrate + seed) and inject its
  // DATABASE_URL below, so runs are hermetic and never touch dev data.
  webServer: {
    command: 'npx tsx src/server.ts',
    cwd: '../services/api',
    url: `${BASE_URL}/healthz`,
    reuseExistingServer: false,
    timeout: 60_000,
    env: {
      PORT: String(PORT),
      HOST: '127.0.0.1',
      NODE_ENV: 'test',
    },
  },
});
