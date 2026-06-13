import { existsSync } from 'node:fs';
import { resolve } from 'node:path';

/**
 * Loads .env file in local development using Node's built-in process.loadEnvFile
 * No-op when .env doesn't exist (production injects env directly)
 */
export function loadDotenv(): void {
  const envPath = resolve(process.cwd(), '.env');

  if (existsSync(envPath)) {
    try {
      process.loadEnvFile(envPath);
    } catch (error) {
      console.error('Failed to load .env file:', error);
      throw error;
    }
  }
  // No-op when .env doesn't exist - production injects env directly
}

