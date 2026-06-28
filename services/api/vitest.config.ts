import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      include: ['src/**/*.ts'],
      // The entrypoint, *.pg.ts repositories, and db scripts run only against
      // real infrastructure — the e2e suite covers those. The unit gate applies
      // to the logic layer (services + in-memory repos).
      exclude: [
        'src/server.ts',
        'src/db/**',
        'src/**/*.pg.ts',
        'src/**/*.redis.ts',
        'src/**/*.google.ts',
        'src/**/*.live.ts',
      ],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },
    },
  },
});
