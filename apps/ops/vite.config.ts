import { defineConfig } from 'vitest/config';
import { loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

/**
 * The API this console talks to is a build input, never a default: a missing
 * value used to fall back to staging, so a production build could quietly
 * point at the wrong backend. Tests run without one and never call it.
 */
function requireApiBaseUrl(mode: string) {
  if (mode === 'test') return;
  const value = loadEnv(mode, process.cwd(), 'VITE_').VITE_API_BASE_URL ?? '';
  let url: URL;
  try {
    url = new URL(value);
  } catch {
    throw new Error('Set VITE_API_BASE_URL to the API this Ops build should use.');
  }
  const local = ['localhost', '127.0.0.1', '[::1]'].includes(url.hostname);
  if (url.protocol !== 'https:' && !(local && url.protocol === 'http:'))
    throw new Error('VITE_API_BASE_URL must use HTTPS outside local development.');
}

export default defineConfig(({ mode }) => {
  requireApiBaseUrl(mode);
  return {
    plugins: [react()],
    server: { port: 4175 },
    preview: { port: 4175 },
    build: { sourcemap: true },
    test: {
      environment: 'jsdom',
      setupFiles: './src/test/setup.ts',
      coverage: {
        reporter: ['text', 'lcov'],
        include: ['src/**/*.{ts,tsx}'],
        exclude: ['src/generated/**', 'src/main.tsx'],
      },
    },
  };
});
